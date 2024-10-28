import AuthService from "../services/auth.service.js";
import 'dotenv/config'
const login=async(req,res,next)=>{
    try {
        const{email,password}=req.body;
        if(!email ||!password){
            return res.status(400).json({ message: 'Email and password are required' });
        }else{
            const result=await AuthService.login(email,password);
            console.log(result);
            if(result.status===true){
                    return res.status(200).json({ status: true, token:result.token });
            }else{
                return res.status(401).json({ message: 'Invalid email or password' });
            }
        }
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}
const register=async(req,res,next)=>{
    try {
        const { email, password, name, language, timezone, deviceId } = req.body;

        if (!email || !password || !name || !language || !timezone || !deviceId) {
            return res.status(400).json({ message: 'All fields are required' });
        }
        const result=await AuthService.register(email, password, name, language, timezone, deviceId);
        if(!result.user){
            return  res.status(201).json({ status: true, message: 'User registered successfully' });
        }else{
            return res.status(500).json({ message: result.message });
        }

    } catch (error) {
        return res.status(500).json({ message: error.message });
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
    console.log(result);
    return res.status(200).json(result);
    
};

export default {login,register,logout,refreshToken,sendVerificationCode};