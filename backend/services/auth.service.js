import { User } from "../models/schema.js";
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import nodemailer from 'nodemailer';
import crypto from 'crypto';
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
   static async login(email,password){
       const user=await User.findOne({email:email});
       if(!user){
         return {message: "invalid email or password"};
       }
       const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return  {message:'Invalid email or password'};
        }
        const return_user={
            email:user.email,
            _id:user._id
        }
        return {message:'User logined successfully',user:return_user}

   }
   static async register(email, password){
      try {
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return  {message:'Email already in use' }
        }
        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = new User({
            email,
            password: hashedPassword, 
           
        });

        await newUser.save();
        const return_user={
            email:newUser.email,
            _id:newUser._id
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
          const accessToken = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '15m' });

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
}
export default AuthService;