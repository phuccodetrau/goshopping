import { Router } from 'express';
import GroupController from '../controller/group.controller.js';

const router = Router();

router.post("/createGroup", GroupController.createGroup);
router.get("/getGroups", GroupController.getGroups);
router.put("/updateGroup", GroupController.updateGroup);
router.delete("/deleteGroup", GroupController.deleteGroup);
router.post("/addUserToGroup", GroupController.addUserToGroup);
router.delete("/removeUserFromGroup", GroupController.removeUserFromGroup);

export default router;