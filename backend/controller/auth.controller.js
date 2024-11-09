import AuthService from "../services/auth.service.js";
import 'dotenv/config'
import jwt from 'jsonwebtoken';

const login=async(req,res,next)=>{
    try {
        const{email,password}=req.body;
        if(!email ||!password){
            return res.status(400).json({ status:false,message: 'Email and password are required' });
        }else{
            const result=await AuthService.login(email,password);
            console.log(result);
            if(result.user){
                const token = jwt.sign(
                    { userId: result.user._id, email: result.user.email },
                    process.env.JWT_SECRET_KEY, 
                    { expiresIn: '1h' } 
                );
                res.setHeader('Authorization', `Bearer ${token}`);
                res.cookie('auth_token', token, {
                    httpOnly: true,  
                    secure: process.env.NODE_ENV === 'production', 
                    maxAge: 180, 
                    sameSite: 'Strict', 
                });
                return  res.status(201).json({ status: true, message: 'User logined successfully',user:result.user,token:token });

            }else{
                return res.status(401).json({status:false, message: 'Invalid email or password' });
            }
        }
    } catch (error) {
        return res.status(500).json({ status:false,message: error.message });
    }
}
const register=async(req,res,next)=>{
    try {
        const { email, password} = req.body;

        if (!email || !password) {
            return res.status(400).json({status:false, message: 'All fields are required' });
        }
        const result=await AuthService.register(email, password);
        if(result.user){
            const token = jwt.sign(
                { userId: result.user._id, email: result.user.email },
                process.env.JWT_SECRET_KEY, 
                { expiresIn: '1h' } 
            );
            res.setHeader('Authorization', `Bearer ${token}`);
            res.cookie('auth_token', token, {
                httpOnly: true,  
                secure: process.env.NODE_ENV === 'production', 
                maxAge: 180, 
                sameSite: 'Strict', 
            });
            return  res.status(201).json({ status: true, message: 'User registered successfully',user:result.user,token:token });
        }else{
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

export default {login,register,logout,refreshToken,sendVerificationCode,check_login,checkVerificationCode};