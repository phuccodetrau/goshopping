import { Router } from 'express';
import listtaskController from '../controller/listtask.controller.js';

const router = Router();

router.post("/createListTask", listtaskController.createListTask);

export default router;