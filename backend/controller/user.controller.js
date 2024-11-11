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
        const token = await UserServices.generateAccessToken(tokenData, "secret", "1h");

        res.status(200).json({ status: true, success: "sendData", token: token });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
};

const getUserNameByEmail = async (req, res, next) => {
    try {
      const email = req.user.email; // Extract email from token
      console.log("Authenticated email:", email);
  
      const userName = await UserServices.getUserNameByEmail(email);
      
      if (userName !== null) {
        console.log("User found, name:", userName);
        res.json({ status: true, name: userName });
      } else {
        console.log("User not found with email:", email);
        res.json({ status: false, message: 'User not found' });
      }
    } catch (error) {
      console.error("Error in getUserNameByEmail:", error);
      next(error);
    }
  };



export default { register, login, getUserNameByEmail };