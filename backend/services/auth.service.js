import { User } from "../models/schema.js";
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import nodemailer from 'nodemailer';
import crypto from 'crypto';
import { Group } from "../models/schema.js";

function generateRandomPassword(length) {
    const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()';
    let password = '';
    for (let i = 0; i < length; i++) {
      const randomIndex = crypto.randomInt(0, charset.length); // Lấy một chỉ số ngẫu nhiên trong phạm vi charset
      password += charset[randomIndex]; // Ghép ký tự ngẫu nhiên vào mật khẩu
    }
    return password;
  }

class AuthService{
   static async login(email, password, deviceToken) {
    try {
        const user = await User.findOne({ email });
        if (!user) {
            return { code: 404, message: "Email không tồn tại", data: "" };
        }

        const isValidPassword = await bcrypt.compare(password, user.password);
        if (!isValidPassword) {
            return { code: 401, message: "Mật khẩu không đúng", data: "" };
        }

        // C���p nhật device token
        if (deviceToken && deviceToken !== user.deviceToken) {
            console.log('Updating device token:', {
                userId: user._id,
                oldToken: user.deviceToken,
                newToken: deviceToken
            });
            
            user.deviceToken = deviceToken;
            await user.save();
            
            console.log('Device token updated successfully');
        }

        // Kiểm tra JWT_SECRET__KEY
        if (!process.env.JWT_SECRET_KEY) {
            throw new Error('JWT_SECRET__KEY is not configured');
        }

        const token = jwt.sign(
            { userId: user._id, email: user.email },
            process.env.JWT_SECRET_KEY,
            { expiresIn: '30d' }
        );

        return {
            code: 200,
            message: "Đăng nhập thành công",
            data: {
                token: token || '',
                user: {
                    id: user._id ? user._id.toString() : '',
                    name: user.name || '',
                    email: user.email || '',
                    deviceToken: user.deviceToken || ''
                }
            }
        };
    } catch (error) {
        console.error('Login error:', error);
        throw { 
            code: 500, 
            message: error.message || "Lỗi server", 
            data: "" 
        };
    }
   }

   static async generateAccessToken(user) {
    const payload = { email: user.email, id: user._id };
    return jwt.sign(payload, process.env.JWT_SECRET_KEY, { expiresIn: '7d' });
  }

   static async register(email, password,name){
      try {
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return  {message:'Email already in use' }
        }
        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = new User({
            email,
            password: hashedPassword, 
            name:name,
            deviceToken: ''
        });

        await newUser.save();
        const return_user={
            email:newUser.email,
            _id:newUser._id,
            name:newUser.name,
            deviceToken: newUser.deviceToken
        }
        return {message:'User registered successfully',user:return_user};
      } catch (error) {
        return  {message: error.message};
      }
   }
   static async refreshToken(refreshToken){
    try {
      jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET, async (err, decoded) => {
          if (err) {
              return { status: false, message: 'Invalid or expired refresh token' };
          }
          const user = await User.findById(decoded.id);
          if (!user) {
              return{ status: false, message: 'User not found' };
          }
          const accessToken = jwt.sign({ id: user._id }, process.env.JWT_SECRET_KEY, { expiresIn: '15m' });

          return { status: true, accessToken };
      });
  } catch (err) {
      return { status: false, message: 'Could not process refresh token' };
  }
   }
   static async checkLogin(email){
        try {
             const existingUser = await User.findOne({ email });
             if (existingUser) {
                return  {message:'Email already in use', email:existingUser.email }
            }else{
                return {message:"Email not exist"}
            }
        } catch (error) {
            return {message:error.message}
        }
   }
   static async sendVerificationCode(email){
    try {
      const verificationCode = crypto.randomInt(1000, 9999).toString();
      console.log(verificationCode)
      const user = await User.findOne({ email });
      console.log(user)
      if (!user) {
          return { status:false, message: 'User not found' };
      }

      user.verificationCode = verificationCode;
      user.verificationCodeExpires = Date.now() + 10 * 60 * 1000; 
      console.log(user.verificationCode)
      await user.save();
      
      const transporter = nodemailer.createTransport({
          service: 'gmail', 
          auth: {
              user: process.env.EMAIL_USER, 
              pass: process.env.EMAIL_PASS, 
          },
      });

      const mailOptions = {
          from: process.env.EMAIL_USER,
          to: email,
          subject: 'Your Verification Code',
          text: `Your verification code is ${verificationCode}. It will expire in 10 minutes.`,
      };
     
      await transporter.sendMail(mailOptions);
      
      return { status: true, message: 'Verification code sent' };
  } catch (err) {
      console.error('Error sending verification code:', err);
      return { status: false, message: 'Could not send verification code' };
  }
   }
   static async checkVerificationCode(email,code){
    try {
     
     
      const now = new Date();
      console.log(now)
      const user = await User.findOne({
        email: email,
        verificationCodeExpires: { $gte: now } // Kiểm tra nếu OTP đã hết hạn
      });
      if(!user){
        return { status: false, message: 'Verification code has expired' };
      }else if(code===user.verificationCode){
        const newPassword = generateRandomPassword(8);
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        user.password = hashedPassword;
        await user.save();
        const transporter = nodemailer.createTransport({
            service: 'gmail', 
            auth: {
                user: process.env.EMAIL_USER, 
                pass: process.env.EMAIL_PASS, 
            },
        });
  
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: 'Your New Password',
            text: `Your new password is ${newPassword}.`,
        };
       
        await transporter.sendMail(mailOptions);
        return { status: true, message: 'Verification is correct!' };   
      }
      else return { status: false, message: 'Verification code is not correct' };
  } catch (err) {
      console.error('Error sending verification code:', err);
      return { status: false, message: 'Could not check verification code' };
  }
   }

   static async getUserByEmail(email) {
        try {
            const user = await User.findOne({ email });
            return user;
        } catch (error) {
            console.error('Error in getUserByEmail:', error);
            throw error;
        }
    }

    static async updateUser(userId, updateData) {
        try {
            const updatedUser = await User.findByIdAndUpdate(userId, updateData, { new: true });
            return updatedUser;
        } catch (error) {
            throw error;
        }
    }

    static async updateUserByEmail(email, updateData) {
        try {
            // Cập nhật thông tin user
            const updatedUser = await User.findOneAndUpdate(
                { email }, 
                updateData, 
                { new: true }
            ).select('-password');

            // Nếu có cập nhật tên
            if (updateData.name) {
                // Cập nhật tên trong tất cả các nhóm mà user là thành viên
                await Group.updateMany(
                    { "listUser.email": email },
                    { $set: { "listUser.$.name": updateData.name } }
                );
            }

            return updatedUser;
        } catch (error) {
            throw error;
        }
    }

    static async getUserInfo(email) {
        try {
            const user = await User.findOne({ email })
                .select('-password');
            
            if (!user) {
                return null;
            }
            return user;
        } catch (error) {
            throw error;
        }
    }

    static async updateUserAvatar(email, avatarData) {
        try {
            const updatedUser = await User.findOneAndUpdate(
                { email },
                { 
                    avatar: {
                        data: avatarData.data,
                        contentType: avatarData.contentType
                    }
                },
                { 
                    new: true,
                    select: '-password'
                }
            );
            return updatedUser;
        } catch (error) {
            throw error;
        }
    }

    static async updateDeviceToken(userId, deviceToken) {
        try {
            const user = await User.findById(userId);
            if (!user) {
                throw new Error('User not found');
            }

            if (deviceToken && deviceToken !== user.deviceToken) {
                user.deviceToken = deviceToken;
                await user.save();
                console.log('Device token updated successfully for user:', userId);
            }

            return user;
        } catch (error) {
            console.error('Error updating device token:', error);
            throw error;
        }
    }
}
export default AuthService;