import { User } from "../models/schema.js";
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import nodemailer from 'nodemailer';
import crypto from 'crypto';
class AuthService{
   static async login(email,password){
       const user=await User.findOne({email:email});
       if(!user){
         return  "invalid email or password";
       }
       const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return  'Invalid email or password';
        }
        const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '10h' });
        return {status:true,token:token}

   }
   static async register(email, password, name, language, timezone, deviceId){
      try {
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return  'Email already in use' 
        }
        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = new User({
            email,
            password: hashedPassword, 
            name,
            language,
            timezone,
            deviceId
        });

        await newUser.save();

        return {message:'User registered successfully',user:newUser};
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
   static async sendVerificationCode(email){
    try {
      const verificationCode = crypto.randomInt(100000, 999999).toString();
      console.log(verificationCode)
      const user = await User.findOne({ email });
      console.log(user)
      if (!user) {
          return { status: false, message: 'User not found' };
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
}
export default AuthService;