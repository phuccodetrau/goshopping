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
}

export default UserServices; // Xuất mặc định
