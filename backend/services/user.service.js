import UserModel from "../models/user.model.js"; // Chắc chắn thêm .js vào cuối
import jwt from "jsonwebtoken"; // Import jwt
import authMiddleware from '../middleware/auth.js';


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
            console.log("Querying for email:", email);
            const user = await UserModel.findOne({ email });
            console.log("User found:", user);
            if (user) {
                return user.name;
            }
            return null;
        } catch (err) {
            console.error("Error fetching user:", err);
            throw err;
        }
    }
    
    

    static async updateUser(userId, updateData) {
        try {
            const updatedUser = await UserModel.findByIdAndUpdate(userId, updateData, { new: true });
            return updatedUser;
        } catch (error) {
            throw error;
        }
    }
}

export default UserServices; // Xuất mặc định
