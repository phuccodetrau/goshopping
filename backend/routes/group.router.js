import { Router } from 'express';
import groupController from '../controller/group.controller.js';

const router = Router();

router.post('/create-group', groupController.createGroup);
router.put('/add-member', groupController.addMembers);
router.get('/get-groups-by-member-email', groupController.getGroupsByMemberEmail);
router.get('/get-admins-by-group-name', groupController.getAdminsByGroupName);
router.delete('/delete-group', groupController.deleteGroup);
router.delete('/remove-member', groupController.removeMember);



export default router; 