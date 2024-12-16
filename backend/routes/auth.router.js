import { Router } from "express";
import auth from '../controller/auth.controller.js'
import authMiddleware from '../middleware/auth.js'
import multer from 'multer'

const router=Router();
const upload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: 5 * 1024 * 1024
    }
});

router.post("/user/login",auth.login);
router.post("/user/check_login",auth.check_login);
router.post("/user",auth.register);
router.post('/user/logout', auth.logout);
router.post('/user/refresh-token', auth.refreshToken);
router.post('/user/sendverification-code', auth.sendVerificationCode);
router.post('/user/checkverification-code', auth.checkVerificationCode);
router.get('/user/get-user-name', authMiddleware, auth.getUserNameByEmail);
router.put('/user/update', authMiddleware, auth.updateUser);
router.get('/user/info', authMiddleware, auth.getUserInfo);
router.post("/user/upload-avatar", authMiddleware, upload.single('avatar'), auth.uploadAvatar);
router.get("/user/get-avatar/:email", auth.getAvatar);
export default router;