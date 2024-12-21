import AdminService from "../services/admin.service.js";
import 'dotenv/config'
import jwt from 'jsonwebtoken';
import { Admin } from "../models/schema.js";

const login = async(req,res,next)=>{
    try {
        const{email,password}=req.body;
        if(!email ||!password){
            return res.status(400).json({ status:false,message: 'Email and password are required' });
        }else{
            const result=await AdminService.login(email,password);
            console.log(result);
            if(result.admin){
                const token = jwt.sign(
                    { adminId: result.admin._id, email: result.admin.email },
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
                return  res.status(201).json({ status: true, message: 'User logined successfully',admin:result.admin,token:token });

            }else{
                return res.status(401).json({status:false, message: 'Invalid email or password' });
            }
        }
    } catch (error) {
        return res.status(500).json({ status:false,message: error.message });
    }
}
const register = async(req,res,next)=>{
 
    try {
        const { email, password} = req.body;

        if (!email || !password) {
            return res.status(400).json({status:false, message: 'All fields are required' });
        }
        const result=await AdminService.register(email, password);
        if(result.admin){
            const token = jwt.sign(
                { adminId: result.admin._id, email: result.admin.email },
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
            return  res.status(201).json({ status: true, message: 'User registered successfully',admin:result.admin,token:token });
        }else{
            return res.status(500).json({status:false, message: result.message });
        }

    } catch (error) {
        return res.status(500).json({status:false, message: error.message });
    }
}
const getAllUser= async (req,res,next)=>{
    try {
            const result=await AdminService.getAllUser();
            if(result.users){
                return  res.status(201).json({ status: true, message: 'get all user successfully',users:result.users });
            }else{
                return res.status(401).json({status:false, message: 'get all user failed.' });
            }
        }
    catch (error) {
        return res.status(500).json({ status:false,message: error.message });
    }
}
const getAllGroup= async (req,res,next)=>{
    try {
            const result=await AdminService.getAllGroup();
            if(result.groups){
                return  res.status(201).json({ status: true, message: 'get all group successfully',groups:result.groups });
            }else{
                return res.status(401).json({status:false, message: 'get all group failed.' });
            }
        }
    catch (error) {
        return res.status(500).json({ status:false,message: error.message });
    }
}
const getOneGroup= async (req,res,next)=>{
    try {
            const{groupID}=req.body;
            const result=await AdminService.getOneGroup(groupID);
            if(result.group){
                return  res.status(201).json({ status: true, message: 'get all group successfully',group:result.group });
            }else{
                return res.status(401).json({status:false, message: 'get all group failed.' });
            }
        }
    catch (error) {
        return res.status(500).json({ status:false,message: error.message });
    }
}
const getOneUser= async(req,res,next)=>{
    try {
        const{userID}=req.body;
        const result=await AdminService.getOneUser(userID);
        if(result.user_info){
            return  res.status(201).json({ status: true, message: 'get user info successfully',user_info:result.user_info});
        }else{
            return res.status(401).json({status:false, message: 'get user info failed.' });
        }
    }
catch (error) {
    return res.status(500).json({ status:false,message: error.message });
}
}
const getAdminInfo= async(req,res,next)=>{
    try {
      
        const result=await AdminService.getAdminInfo();
        if(result.info){
            return  res.status(201).json({ status: true, message: 'get  info successfully',info:result.info});
        }else{
            return res.status(401).json({status:false, message: 'get info failed.' });
        }
    }
catch (error) {
    return res.status(500).json({ status:false,message: error.message });
}
}
export default {getAllUser,getAllGroup,getOneGroup,login,register,getOneUser,getAdminInfo}