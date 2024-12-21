import UserModel from "../models/user.model.js"; // Chắc chắn thêm .js vào cuối
import jwt from "jsonwebtoken"; // Import jwt

class UserServices {
    static async registerUser(email, password) {
        try {
            console.log("-----Email --- Password-----", email, password);
            const createUser = new UserModel({ email, password });
            return await createUser.save();
        } catch (err) {
            throw err;
        }
    }

    static async getUserByEmail(email) {
        try {
            return await UserModel.findOne({ email });
        } catch (err) {
            console.log(err);
            throw err;
        }
    }

    static async checkUser(email) {
        try {
            return await UserModel.findOne({ email });
        } catch (error) {
            throw error;
        }
    }

    static async generateAccessToken(tokenData, JWTSecret_Key, JWT_EXPIRE) {
        return jwt.sign(tokenData, JWTSecret_Key, { expiresIn: JWT_EXPIRE });
    }

    static async getUserNameByEmail(email) {
        try {
            console.log("Querying for email:", email); // Log email đang được truy vấn
            const user = await UserModel.findOne({ email }); // Tìm kiếm email
            console.log("User found:", user); // Log thông tin người dùng tìm thấy
            if (user) {
                return user; // Trả về tên nếu tìm thấy
            }
            return null; // Trả về null nếu không tìm thấy
        } catch (err) {
            console.error("Error fetching user:", err);
            throw err;
        }
    }
    static async getAllUser(){
        try {
            
            const user = await UserModel.findOne({ email }); 
            console.log("User found:", user);
            if (user) {
                return user; // Trả về tên nếu tìm thấy
            }
            return null; // Trả về null nếu không tìm thấy
        } catch (err) {
            console.error("Error fetching user:", err);
            throw err;
        }
    }
    
}

export default UserServices; // Xuất mặc định
