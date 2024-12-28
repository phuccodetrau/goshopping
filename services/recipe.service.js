import mongoose from 'mongoose';
import { Recipe, Item, Food } from "../models/schema.js";

class RecipeService {
    static async createRecipe(name, description, list_item, group) {
        if (!name || !list_item || list_item.length === 0) {
            return { code: 701, message: "Vui lòng cung cấp đầy đủ thông tin", data: "" };
        }

        const existingRecipe = await Recipe.findOne({ name: name, group: group });
        if (existingRecipe) {
            return { code: 702, message: "Recipe đã tồn tại trong group này", data: "" };
        }
        
        try {
            const createRecipe = new Recipe({ name, description, list_item, group });
            const savedRecipe = await createRecipe.save();
            return { code: 700, message: "Lưu recipe thành công", data: savedRecipe };
        } catch (error) {
            console.error("Lỗi khi tạo recipe:", error);
            throw error;
        }
    }

    static async updateRecipe(recipeName, group, newData) {
        try {
            if (newData.name) {
                const existingRecipe = await Recipe.findOne({
                    name: newData.name,
                    group: group,
                    _id: { $ne: newData._id }
                });
                
                if (existingRecipe) {
                    return { code: 704, message: "Tên recipe mới đã tồn tại trong group này", data: "" };
                }
            }

            const updatedRecipe = await Recipe.findOneAndUpdate(
                { name: recipeName, group: group },
                { $set: newData },
                { new: true }
            );
            
            if (!updatedRecipe) {
                return { code: 703, message: "Không tìm thấy recipe để cập nhật", data: "" };
            }

            return { code: 702, message: "Cập nhật recipe thành công", data: updatedRecipe };
        } catch (error) {
            console.error("Lỗi khi cập nhật recipe:", error);
            throw error;
        }
    }

    static async deleteRecipe(recipeName, group) {
        try {
            const deletedRecipe = await Recipe.findOneAndDelete({ name: recipeName, group: group });
            if (!deletedRecipe) {
                return { code: 705, message: "Không tìm thấy recipe để xóa", data: "" };
            }
            return { code: 704, message: "Xóa recipe thành công", data: deletedRecipe };
        } catch (error) {
            console.error("Lỗi khi xóa recipe:", error);
            throw error;
        }
    }

    static async getRecipeByFood(foodName, group) {
        try {
            const recipes = await Recipe.find({
                group: group,
                list_item: { $elemMatch: { foodName: foodName } }
            });
            if (!recipes || recipes.length === 0) {
                return { code: 706, message: "Không tìm thấy recipe nào với foodName này trong group", data: "" };
            }
            return { code: 707, message: "Tìm kiếm recipe thành công", data: recipes };
        } catch (error) {
            console.error("Lỗi khi tìm kiếm recipe:", error);
            throw error;
        }
    }

    static async getAllRecipe(group) {
        try {
            const recipes = await Recipe.find({ group: group }, 'name description');
            if (!recipes || recipes.length === 0) {
                return { code: 708, message: "Không tìm thấy recipe nào trong group này", data: "" };
            }
            return { code: 709, message: "Lấy danh sách recipe thành công", data: recipes };
        } catch (error) {
            console.error("Lỗi khi lấy danh sách recipe:", error);
            throw error;
        }
    }

    static async getAllFoodInReceipt(recipeName, group) {
        try {
            const recipe = await Recipe.findOne({ name: recipeName, group: group });
            if (!recipe) {
                return { code: 710, message: "Không tìm thấy recipe này", data: "" };
            }
            return { 
                code: 711, 
                message: "Lấy danh sách food trong recipe thành công", 
                data: {
                    list_item: recipe.list_item,
                    description: recipe.description
                }
            };
        } catch (error) {
            console.error("Lỗi khi lấy danh sách food trong recipe:", error);
            throw error;
        }
    }

    static async useRecipe(recipeName, group) {
        // Bắt đầu session cho transaction
        const session = await mongoose.startSession();
        session.startTransaction();

        try {
            // Tìm recipe
            const recipe = await Recipe.findOne({ name: recipeName, group });
            if (!recipe) {
                return { code: 712, message: "Không tìm thấy recipe", data: "" };
            }

            const results = [];
            const operations = []; // Lưu trữ các thao tác cần thực hiện

            // Kiểm tra đủ số lượng trước khi thực hiện
            for (const recipeItem of recipe.list_item) {
                // Tìm các items còn hạn sử dụng, sắp xếp theo ngày hết hạn gần nhất
                const items = await Item.find({
                    foodName: recipeItem.foodName,
                    group: group,
                    expireDate: { $gt: new Date() }
                }).sort({ expireDate: 1 });  // Sắp xếp tăng dần theo ngày hết hạn

                let totalAvailable = items.reduce((sum, item) => sum + item.amount, 0);
                if (totalAvailable < recipeItem.amount) {
                    await session.abortTransaction();
                    session.endSession();
                    return { 
                        code: 713, 
                        message: `Không đủ ${recipeItem.foodName} trong tủ lạnh (cần ${recipeItem.amount}, có ${totalAvailable})`, 
                        data: "" 
                    };
                }

                let remainingAmount = recipeItem.amount;
                let currentIndex = 0;

                // Tính toán các thao tác cần thực hiện
                while (remainingAmount > 0 && currentIndex < items.length) {
                    const currentItem = items[currentIndex];
                    
                    if (currentItem.amount <= remainingAmount) {
                        // Nếu item hiện tại không đủ số lượng cần
                        remainingAmount -= currentItem.amount;
                        operations.push({
                            type: 'delete',
                            itemId: currentItem._id
                        });
                        results.push({
                            foodName: currentItem.foodName,
                            amountUsed: currentItem.amount,
                            itemId: currentItem._id,
                            expireDate: currentItem.expireDate
                        });
                    } else {
                        // Nếu item hiện tại đủ số lượng cần
                        const newAmount = currentItem.amount - remainingAmount;
                        operations.push({
                            type: 'update',
                            itemId: currentItem._id,
                            newAmount: newAmount
                        });
                        results.push({
                            foodName: currentItem.foodName,
                            amountUsed: remainingAmount,
                            itemId: currentItem._id,
                            expireDate: currentItem.expireDate
                        });
                        remainingAmount = 0;
                    }
                    currentIndex++;
                }
            }

            // Thực hiện tất cả các thao tác trong transaction
            for (const operation of operations) {
                if (operation.type === 'delete') {
                    await Item.findByIdAndDelete(operation.itemId).session(session);
                } else if (operation.type === 'update') {
                    await Item.findByIdAndUpdate(
                        operation.itemId,
                        { amount: operation.newAmount }
                    ).session(session);
                }
            }

            // Commit transaction
            await session.commitTransaction();
            session.endSession();

            return { 
                code: 714, 
                message: "Sử dụng recipe thành công", 
                data: {
                    recipeName: recipe.name,
                    usedItems: results
                }
            };
        } catch (error) {
            // Rollback nếu có lỗi
            await session.abortTransaction();
            session.endSession();
            console.error("Lỗi khi sử dụng recipe:", error);
            throw error;
        }
    }

    static async checkRecipeAvailability(recipeName, group) {
        try {
            const recipe = await Recipe.findOne({ name: recipeName, group });
            if (!recipe) {
                return { code: 712, message: "Không tìm thấy recipe", data: "" };
            }

            const availabilityCheck = [];

            for (const recipeItem of recipe.list_item) {
                // Lấy thông tin đơn vị từ Food collection trước
                const food = await Food.findOne({ 
                    name: recipeItem.foodName,
                    group: group 
                });

                // Tìm các items còn hạn sử dụng
                const items = await Item.find({
                    foodName: recipeItem.foodName,
                    group: group,
                    expireDate: { $gt: new Date() }
                }).sort({ expireDate: 1 });

                // Log để debug
                console.log(`Checking ${recipeItem.foodName}:`);
                console.log('Recipe requires:', recipeItem.amount, recipeItem.unitName || food?.unitName);

                // Chỉ tính tổng các item có cùng đơn vị với recipe/food
                const targetUnit = recipeItem.unitName || food?.unitName;
                const validItems = items.filter(item => item.unitName === targetUnit);
                const totalAvailable = validItems.reduce((sum, item) => sum + item.amount, 0);

                console.log('Available items:', validItems.map(item => ({
                    amount: item.amount,
                    unitName: item.unitName,
                    expireDate: item.expireDate
                })));
                console.log('Total available:', totalAvailable, targetUnit);
                
                availabilityCheck.push({
                    foodName: recipeItem.foodName,
                    requiredAmount: recipeItem.amount,
                    requiredUnit: targetUnit,  // Sử dụng đơn vị từ recipe hoặc food
                    availableAmount: totalAvailable,
                    availableUnit: targetUnit,
                    isAvailable: totalAvailable >= recipeItem.amount,
                    defaultUnit: food?.unitName,  // Thêm đơn vị mặc định từ Food
                    items: validItems.map(item => ({
                        itemId: item._id,
                        amount: item.amount,
                        unitName: item.unitName,
                        expireDate: item.expireDate
                    }))
                });
            }

            const isAllAvailable = availabilityCheck.every(item => item.isAvailable);

            return { 
                code: 715, 
                message: isAllAvailable ? 
                    "Có thể sử dụng recipe này" : 
                    "Không đủ nguyên liệu để thực hiện recipe này",
                data: {
                    recipeName: recipe.name,
                    canUse: isAllAvailable,
                    ingredients: availabilityCheck
                }
            };
        } catch (error) {
            console.error("Lỗi khi kiểm tra recipe:", error);
            throw error;
        }
    }
}

export default RecipeService;
