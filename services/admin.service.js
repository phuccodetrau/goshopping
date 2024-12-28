import { User,Admin, Group} from "../models/schema.js";
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import nodemailer from 'nodemailer';
import crypto from 'crypto';
import mongoose from "mongoose";
class AdminService{
    static async login(email,password){
         const admin=await Admin.findOne({email:email});
               if(!admin){
                 return {message: "invalid email or password"};
               }
               const isMatch = await bcrypt.compare(password, admin.password);
                if (!isMatch) {
                    return  {message:'Invalid email or password'};
                }
                const return_admin={
                    email:admin.email,
                    _id:admin._id,
                }
                return {message:'User logined successfully',admin:return_admin}
        
    }
    static async register(email, password){
          try {
            const existingAdmin=await Admin.findOne({ email });
            if (existingAdmin) {
                return  {message:'Email already in use' }
            }
            const hashedPassword = await bcrypt.hash(password, 10);
            const newAdmin = new Admin({
                email,
                password: hashedPassword, 
            
            });
    
            await newAdmin.save();
            const return_admin={
                email:newAdmin.email,
                _id:newAdmin._id,
            }
            return {message:' registered successfully',admin:return_admin};
          } catch (error) {
            return  {message: error.message};
          }
       }
    static async getAllGroup(){
        const groups = await Group.find({});
        let return_groups=[]
        var len_groups=groups.length;
        for(var i=0;i<len_groups;i++){
            return_groups.push({
                "Group Id": groups[i]['_id'],
                "Group Name":groups[i]['name'],
                "Number User": groups[i]["listUser"].length,
                "Number Food": groups[i]['refrigerator'].length
            })
        }
        return {message:'get all user successfully',groups:return_groups}
    }
    static async getOneGroup(groupID){
        const group = await Group.findOne({_id:groupID});
        var listUser=[];
        var number_user=group['listUser'].length
        for(var i=0;i<number_user;i++){
            var user=await User.findOne({email:group["listUser"][i]['email']})
            listUser.push({
                "User ID":user._id,
                "User Name":group["listUser"][i]['name'],
                "User Email":group["listUser"][i]['email'],
                "User Role":group["listUser"][i]['role'],
            })
        } 
        var refrigerator=[];
        var number_refrigerator=group['refrigerator'].length
        for(var i=0;i<number_refrigerator;i++){
            var date = new Date(group["refrigerator"][i]['expireDate'],);

            
            var day = date.getDate().toString().padStart(2, '0'); 
            var month = (date.getMonth() + 1).toString().padStart(2, '0'); // Lấy tháng (2 chữ số, tháng bắt đầu từ 0)
            var year = date.getFullYear();

           
            var formattedDate = `${day}-${month}-${year}`;
            refrigerator.push({
                "Food Name":group["refrigerator"][i]['foodName'],
                "Expire Date":formattedDate,
                "Amount":group["refrigerator"][i]['amount'],
                "Unit Name":group["refrigerator"][i]['unitName'],
                "Note": group['refrigerator'][i]['note']
        
            })
        }
        
        return {message:'get all user successfully',group:{
            user: listUser,
            refrigerator: refrigerator,
            name:group.name
        }}
    }
    static async getAllUser(){
        const users = await User.find({});
        let return_users=[]
        var len_users=users.length;
        for(var i=0;i<len_users;i++){
            return_users.push({
                "User Id": users[i]['_id'],
                "User Name":users[i]['name'],
                "User Email": users[i]["email"],
                
            })
        }
        return {message:'get all user successfully',users:return_users}
    }
    static async getOneUser(userID){
        const email=await User.findOne({_id:userID})
        var email1=email.email
        const groups=await Group.find({})
        var len=groups.length;
        var return_group=[]
        for(var i=0;i<len;i++){
            var listUser=groups[i]['listUser']
           
            var user_len=listUser.length
            for(var j=0;j<user_len;j++){
              
                if(listUser[j]["email"]===email1){
                    return_group.push({
                        "Group ID":groups[i]["_id"],
                        "Group Name":groups[i]["name"],
                        "Number Member":user_len,
                        "Role":listUser[j]['role']
                    })
                }
            }
        }
        return {message:'get user info successfully',user_info:{
            group:return_group,
            name: email.name
        }}
    }
 
    static async getAdminInfo() {
        const groups = await Group.find({});
        const users = await User.find({});
        const len_groups = groups.length;
        const len_users = users.length;
    
        // Tính số người dùng trong mỗi nhóm
        var number_user_in_group = 0;
        for (var i = 0; i < len_groups; i++) {
            var listUser = groups[i]['listUser'];
            number_user_in_group += listUser.length;
        }
        number_user_in_group /= len_groups;
        number_user_in_group=number_user_in_group.toFixed(2);
        // Tính số thực phẩm trong mỗi nhóm
        var number_food_in_group = 0;
        for (var i = 0; i < len_groups; i++) {
            var refrigerator = groups[i]['refrigerator'];
            number_food_in_group += refrigerator.length;
        }
        number_food_in_group /= len_groups;
        number_food_in_group=number_food_in_group.toFixed(2);
        // Lấy số người dùng mới trong 7 ngày qua theo từng ngày
        const today = new Date();
        const sevenDaysAgo = new Date(today);
        sevenDaysAgo.setDate(today.getDate() - 7);  // Tính thời gian cách đây 7 ngày
    
        // Khởi tạo mảng để lưu số người dùng mới mỗi ngày
        let newUsersPerDay = [];
    
        // Duyệt qua 7 ngày (từ ngày hôm nay đến 7 ngày trước)
        for (let i = 6; i >= 0; i--) {  
            const startOfDay = new Date(today);
            startOfDay.setDate(today.getDate() - i);  // Tính ngày bắt đầu
            startOfDay.setUTCHours(0, 0, 0, 0); // Đặt thời gian là 00:00 của ngày theo giờ UTC
            startOfDay.setHours(startOfDay.getHours() + 7); // Điều chỉnh múi giờ thành UTC+7
    
            const endOfDay = new Date(today);
            endOfDay.setDate(today.getDate() - i); // Tính ngày kết thúc
            endOfDay.setUTCHours(23, 59, 59, 999); // Đặt thời gian là 23:59:59 của ngày theo giờ UTC
            endOfDay.setHours(endOfDay.getHours() + 7); // Điều chỉnh múi giờ thành UTC+7
    
            // Convert startOfDay và endOfDay thành ObjectId
            const startObjectId = new mongoose.Types.ObjectId(Math.floor(startOfDay.getTime() / 1000).toString(16) + "0000000000000000");
            const endObjectId = new mongoose.Types.ObjectId(Math.floor(endOfDay.getTime() / 1000).toString(16) + "0000000000000000");
    
            // Tìm người dùng được tạo trong ngày bằng cách dùng _id
            const usersForDay = await User.find({
                _id: { 
                    $gte: startObjectId, 
                    $lte: endObjectId
                }
            });
    
            // Thêm số lượng người dùng vào mảng
            newUsersPerDay.push({
                date: startOfDay.toISOString().split('T')[0],  // Ngày theo định dạng YYYY-MM-DD
                count: usersForDay.length
            });
        }
    
        // Lấy số nhóm mới trong 7 ngày qua theo từng ngày
        let newGroupsPerDay = [];
        for (let i = 6; i >= 0; i--) {
            const startOfDay = new Date(today);
            startOfDay.setDate(today.getDate() - i);
            startOfDay.setUTCHours(0, 0, 0, 0); // Đặt thời gian là 00:00 của ngày theo giờ UTC
            startOfDay.setHours(startOfDay.getHours() + 7); // Điều chỉnh múi giờ thành UTC+7
    
            const endOfDay = new Date(today);
            endOfDay.setDate(today.getDate() - i);
            endOfDay.setUTCHours(23, 59, 59, 999); // Đặt thời gian là 23:59:59 của ngày theo giờ UTC
            endOfDay.setHours(endOfDay.getHours() + 7); // Điều chỉnh múi giờ thành UTC+7
    
            // Convert startOfDay và endOfDay thành ObjectId
            const startObjectId = new mongoose.Types.ObjectId(Math.floor(startOfDay.getTime() / 1000).toString(16) + "0000000000000000");
            const endObjectId = new mongoose.Types.ObjectId(Math.floor(endOfDay.getTime() / 1000).toString(16) + "0000000000000000");
    
            // Tìm nhóm được tạo trong ngày bằng cách dùng _id
            const groupsForDay = await Group.find({
                _id: { 
                    $gte: startObjectId,
                    $lte: endObjectId
                }
            });
    
            // Thêm số lượng nhóm vào mảng
            newGroupsPerDay.push({
                date: startOfDay.toISOString().split('T')[0],  // Ngày theo định dạng YYYY-MM-DD
                count: groupsForDay.length
            });
        }
    
        return {
            message: 'get admin info successfully',
            info: {
                number_user: len_users,
                number_group: len_groups,
                number_member_in_group: number_user_in_group,
                number_food_in_group: number_food_in_group,
                new_users_per_day: newUsersPerDay, 
                new_groups_per_day: newGroupsPerDay 
            }
        };
    }
}
export default AdminService