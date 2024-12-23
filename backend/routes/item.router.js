import { Router } from 'express';
import itemController from '../controller/item.controller.js';
import authMiddleware from '../middleware/auth.js';

const router = Router();

router.post("/createItem", authMiddleware, itemController.createItem);
router.post('/getAllItem', authMiddleware, itemController.getAllItem);
router.post("/getSpecificItem", authMiddleware, itemController.getSpecificItem);
router.post("/deleteItem", authMiddleware, itemController.deleteItem);
router.post("/updateItem", authMiddleware, itemController.updateItem);
router.post("/getItemDetail", authMiddleware, itemController.getItemDetail);

export default router;
