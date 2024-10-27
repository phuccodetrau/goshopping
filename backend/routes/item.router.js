import { Router } from 'express';
import itemController from '../controller/item.controller.js';

const router = Router();

router.post("/createItem", itemController.createItem);
router.post('/getAllItem', itemController.getAllItem);
router.post("/getSpecificItem", itemController.getSpecificItem);
router.post("/deleteItem", itemController.deleteItem);
router.post("/updateItem", itemController.updateItem);

export default router;
