import { Router } from 'express';
import groupController from '../controller/group.controller.js';
import authMiddleware from '../middleware/auth.js';
const router = Router();

router.post('/create-group', authMiddleware, groupController.createGroup);
router.put('/add-member', groupController.addMembers);
router.get('/get-groups-by-member-email', groupController.getGroupsByMemberEmail);
router.get('/get-admins-by-group-name', groupController.getAdminsByGroupName);
router.get('/get-users-by-group-name', groupController.getUsersByGroupName);

router.delete('/delete-group', groupController.deleteGroup);
router.delete('/remove-member', groupController.removeMember);



export default router; 