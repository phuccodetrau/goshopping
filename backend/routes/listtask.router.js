import { Router } from 'express';
import listtaskController from '../controller/listtask.controller.js';

const router = Router();

router.post("/createListTask", listtaskController.createListTask);
router.post("/getAllListTasksByGroup/", listtaskController.getAllListTasksByGroup);
router.post("/getListTasksByNameAndGroup", listtaskController.getListTasksByNameAndGroup);
router.post("/createItemFromListTask", listtaskController.createItemFromListTask);
router.post("/updateListTaskById", listtaskController.updateListTaskById);
router.post("/deleteListTaskById", listtaskController.deleteListTaskById);
router.post("/getTaskStats", listtaskController.getTaskStats);
router.post("/getTaskStatsByFood", listtaskController.getTaskStatsByFood);
router.post("/getTaskStatsByDate", listtaskController.getTaskStatsByDate);

export default router;