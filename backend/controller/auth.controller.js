import AuthService from "../services/auth.service.js";
import 'dotenv/config'
import jwt from 'jsonwebtoken';

const login=async(req,res,next)=>{
    try {
        const { email, password, deviceToken } = req.body;
        
        if (!email || !password) {
            return res.status(400).json({ 
                status: false, 
                message: 'Email and password are required' 
            });
        }

        console.log("Login attempt:", { 
            email, 
            deviceToken: deviceToken ? 'provided' : 'not provided' 
        });

        const result = await AuthService.login(email, password, deviceToken);
        
        if (result.code === 200) {
            res.status(200).json({
                status: true,
                message: result.message,
                data: result.data
            });
        } else {
            res.status(result.code).json({
                status: false,
                message: result.message
            });
        }
    } catch (error) {
        console.error("Login error:", error);
        res.status(500).json({ 
            status: false, 
            message: error.message || 'Internal server error' 
        });
    }
}
const register=async(req,res,next)=>{
    try {
        const { email, password, name, deviceToken } = req.body;

        if (!email || !password) {
            return res.status(400).json({status:false, message: 'All fields are required' });
        }
        const result = await AuthService.register(email, password, name);
        if(result.user){
            const token = jwt.sign(
                { userId: result.user._id, email: result.user.email },
                process.env.JWT_SECRET_KEY, 
                { expiresIn: '10h' } 
            );

            if (deviceToken) {
                try {
                    await AuthService.updateDeviceToken(result.user._id, deviceToken);
                    result.user.deviceToken = deviceToken;
                } catch (error) {
                    console.error('Error updating device token during registration:', error);
                }
            }

            res.setHeader('Authorization', `Bearer ${token}`);
            res.cookie('auth_token', token, {
                httpOnly: true,  
                secure: process.env.NODE_ENV === 'production', 
                maxAge: 180, 
                sameSite: 'Strict', 
            });
            return res.status(201).json({ 
                status: true, 
                message: 'User registered successfully',
                user: result.user,
                token: token 
            });
        } else {
            return res.status(500).json({status:false, message: result.message });
        }

    } catch (error) {
        return res.status(500).json({status:false, message: error.message });
    }
}
const logout = async (req, res) => {
    try {
        return res.status(200).json({ status: true, message: 'Successfully logged out' });
    } catch (err) {
        return res.status(500).json({ status: false, message: 'Logout failed' });
    }
};



const refreshToken = async (req, res) => {
    const { refreshToken } = req.body;
    if (!refreshToken) {
        return res.status(400).json({ status: false, message: 'Refresh token is required' });
    }

    const result=await AuthService.refreshToken(refreshToken);
    return result;
};

const sendVerificationCode = async (req, res) => {
    const { email } = req.body;
    
    if (!email) {
        return res.status(400).json({ status: false, message: 'Email is required' });
    }
    const result=await AuthService.sendVerificationCode(email);
    
    return res.status(200).json(result);
    
};
const checkVerificationCode = async (req, res) => {
    const { email,otp } = req.body;
    console.log(otp)
    if (!email) {
        return res.status(400).json({ status: false, message: 'Email is required' });
    }
    const result=await AuthService.checkVerificationCode(email,otp);
 
    return res.status(200).json(result);
    
};
const check_login=async(req,res)=>{
    const {email}=req.body;
    //TODO
    if (!email) {
        return res.status(400).json({ status: false, message: 'Email is required' });
    }else{
        const result=await AuthService.checkLogin(email);
        if(result.email){
            return res.status(200).json({status:true,message:'User is logged in'})
        }else{
            return res.status(200).json({status:false,message:'User is not exist'})
        }
    }
}

const getUserNameByEmail = async (req, res, next) => {
    try {
        const email = req.query.email || req.user.email;

        if (!email) {
            return res.status(400).json({ status: false, message: 'Email is required' });
        }

        const user = await AuthService.getUserByEmail(email);
        if (user) {
            return res.status(200).json({ status: true, name: user.name });
        } else {
            return res.status(404).json({ status: false, message: 'User not found' });
        }
    } catch (error) {
        return res.status(500).json({ status: false, message: 'Internal server error' });
    }
};

const updateUser = async (req, res, next) => {
    try {
        const { name, phoneNumber, avatar } = req.body;
        const email = req.user.email;

        const updateData = {};
        if (name) updateData.name = name;
        if (phoneNumber) updateData.phoneNumber = phoneNumber;
        if (avatar != "") updateData.avatar = avatar;

        const updatedUser = await AuthService.updateUserByEmail(email, updateData);

        if (updatedUser) {
            res.json({ 
                status: true, 
                message: 'User information updated successfully', 
                user: updatedUser 
            });
        } else {
            res.status(404).json({ 
                status: false, 
                message: 'User not found' 
            });
        }
    } catch (error) {
        next(error);
    }
};

const getUserInfo = async (req, res, next) => {
    try {
        const email = req.query.email;
        
        if (!email) {
            return res.status(400).json({ 
                status: false, 
                message: 'Email is required' 
            });
        }

        const userInfo = await AuthService.getUserInfo(email);
        
        if (!userInfo) {
            return res.status(404).json({ 
                status: false, 
                message: 'User not found' 
            });
        }

        res.status(200).json({
            status: true,
            data: userInfo
        });
    } catch (error) {
        next(error);
    }
};

const uploadAvatar = async (req, res, next) => {
    try {
        if (!req.file) {
            return res.status(400).json({ 
                status: false, 
                message: 'No file uploaded' 
            });
        }

        const email = req.user.email;
        
        const mimeType = req.file.mimetype.toLowerCase();
        const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'application/octet-stream'];
        
        const fileName = req.file.originalname.toLowerCase();
        const isValidExtension = fileName.match(/\.(jpg|jpeg|png|gif)$/);
        
        if (!allowedTypes.includes(mimeType) || !isValidExtension) {
            return res.status(400).json({
                status: false,
                message: 'Invalid file type. Only JPEG, PNG and GIF are allowed'
            });
        }

        let actualMimeType = 'image/jpeg';
        if (fileName.endsWith('.png')) actualMimeType = 'image/png';
        if (fileName.endsWith('.gif')) actualMimeType = 'image/gif';

        const updatedUser = await AuthService.updateUserAvatar(email, {
            data: req.file.buffer,
            contentType: actualMimeType
        });

        if (!updatedUser) {
            return res.status(404).json({
                status: false,
                message: 'User not found'
            });
        }

        const avatarUrl = `/auth/get-avatar/${email}`;

        res.json({
            status: true,
            message: 'Avatar updated successfully',
            data: {
                avatarUrl: avatarUrl
            }
        });
    } catch (error) {
        next(error);
    }
};

const getAvatar = async (req, res, next) => {
    try {
        const email = req.params.email;
        const user = await AuthService.getUserByEmail(email);
        
        if (!user || !user.avatar || !user.avatar.data) {
            return res.status(404).send('Avatar not found');
        }

        res.set('Content-Type', user.avatar.contentType);
        res.send(user.avatar.data);
    } catch (error) {
        next(error);
    }
};

export default {
    login,
    register,
    logout,
    refreshToken,
    sendVerificationCode,
    check_login,
    checkVerificationCode,
    getUserNameByEmail,
    updateUser,
    getUserInfo,
    uploadAvatar,
    getAvatar
};