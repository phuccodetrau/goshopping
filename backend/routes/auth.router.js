import { Router } from "express";
import auth from '../controller/auth.controller.js'
const router=Router();
router.post("/user/login",auth.login);
router.post("/user/check_login",auth.check_login);
router.post("/user",auth.register);
router.post('/user/logout', auth.logout);
router.post('/user/refresh-token', auth.refreshToken);
router.post('/user/sendverification-code', auth.sendVerificationCode);
router.post('/user/checkverification-code', auth.checkVerificationCode);
export default router;