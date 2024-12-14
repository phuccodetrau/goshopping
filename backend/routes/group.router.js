import { Router } from 'express';
import groupController from '../controller/group.controller.js';
import authMiddleware from '../middleware/auth.js';
const router = Router();

router.post('/create-group', authMiddleware, groupController.createGroup);
router.put('/add-member', authMiddleware, groupController.addMembers);
router.get('/get-groups-by-member-email', authMiddleware, groupController.getGroupsByMemberEmail);
router.get('/get-users-by-group-name', authMiddleware, groupController.getUsersByGroupName);

router.delete('/delete-group', authMiddleware, groupController.deleteGroup);
router.get('/get-users-by-group-id/:groupId', groupController.getUsersByGroupId);
router.post('/addItemToRefrigerator', groupController.addItemToRefrigerator);
router.get('/getAvailableItems/:groupId', groupController.getAvailableItems);
router.post('/searchItemsInRefrigerator/', groupController.searchItemsInRefrigerator);
router.get('/get-admins-by-group-id/:groupId', authMiddleware, groupController.getAdminsByGroupId);
router.delete('/leave-group', authMiddleware, groupController.leaveGroup);



export default router; 