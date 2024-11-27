import UserServices from '../services/user.service.js';
import authMiddleware from '../middleware/auth.js';


const register = async (req, res, next) => {
    try {
        console.log("---req body---", req.body);
        const { email, password } = req.body;
        const duplicate = await UserServices.getUserByEmail(email);
        if (duplicate) {
            throw new Error(`UserName ${email}, Already Registered`);
        }
        await UserServices.registerUser(email, password);

        res.json({ status: true, success: 'User registered successfully' });
    } catch (err) {
        console.log("---> err -->", err);
        next(err);
    }
};

const login = async (req, res, next) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            throw new Error('Parameters are not correct');
        }
        let user = await UserServices.checkUser(email);
        if (!user) {
            throw new Error('User does not exist');
        }

        const isPasswordCorrect = await user.comparePassword(password);

        if (!isPasswordCorrect) {
            throw new Error(`Username or Password does not match`);
        }

        // Creating Token
        let tokenData = { _id: user._id, email: user.email };
        const token = await UserServices.generateAccessToken(
            tokenData,
            process.env.JWT_SECRET_KEY,
            process.env.JWT_EXPIRE
        );


        res.status(200).json({ status: true, success: "sendData", token: token });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
};

const getUserNameByEmail = async (req, res, next) => {
    try {
        // Ưu tiên lấy email từ query parameter
        const email = req.query.email || req.user.email;

        if (!email) {
            return res.status(400).json({ status: false, message: 'Email is required' });
        }

        console.log("Email passed to service:", email);

        const userName = await UserServices.getUserNameByEmail(email);

        if (userName !== null) {
            console.log("Found user:", userName);
            return res.status(200).json({ status: true, name: userName });
        } else {
            console.log("User not found for email:", email);
            return res.status(404).json({ status: false, message: 'User not found' });
        }
    } catch (error) {
        console.error("Error in getUserNameByEmail controller:", error);
        return res.status(500).json({ status: false, message: 'Internal server error' });
    }
};




const updateUser = async (req, res, next) => {
    try {
        const { email, name, phoneNumber } = req.body; // Chỉ chấp nhận các trường này
        const userId = req.user._id; // Lấy user ID từ middleware

        // Kiểm tra và giới hạn dữ liệu cập nhật
        const updateData = {};
        if (email) updateData.email = email;
        if (name) updateData.name = name;
        if (phoneNumber) updateData.phoneNumber = phoneNumber;

        const updatedUser = await UserServices.updateUser(userId, updateData);

        if (updatedUser) {
            res.json({ status: true, message: 'User information updated successfully', user: updatedUser });
        } else {
            res.status(404).json({ status: false, message: 'User not found' });
        }
    } catch (error) {
        console.error("Error updating user:", error);
        next(error);
    }
};

export default { register, login, getUserNameByEmail, updateUser };