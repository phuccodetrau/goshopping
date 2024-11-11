import { Router } from 'express';
import groupController from '../controller/group.controller.js';

const router = Router();

router.post('/create-group', groupController.createGroup);
router.delete('/delete-group/:groupId', groupController.deleteGroup);
router.put('/add-member', groupController.addMembers);
router.post('/remove-member', groupController.removeMember);
router.get('/get-groups-by-member-email', groupController.getGroupsByMemberEmail);
router.get('/get-admins-by-group-name', groupController.getAdminsByGroupName);


export default router; 