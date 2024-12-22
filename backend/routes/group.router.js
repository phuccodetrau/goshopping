import { Router } from 'express';
import groupController from '../controller/group.controller.js';
import authMiddleware from '../middleware/auth.js';
const router = Router();

router.post('/create-group', authMiddleware, groupController.createGroup);
router.post('/update-group-image', authMiddleware, groupController.updateGroupImage);
router.put('/add-member', authMiddleware, groupController.addMembers);
router.get('/get-groups-by-member-email', authMiddleware, groupController.getGroupsByMemberEmail);
router.get('/get-users-by-group-name', authMiddleware, groupController.getUsersByGroupName);
router.delete('/delete-group', authMiddleware, groupController.deleteGroup);
router.get('/get-users-by-group-id/:groupId', authMiddleware,groupController.getUsersByGroupId);
router.post('/addItemToRefrigerator', authMiddleware,groupController.addItemToRefrigerator);
router.post('/filterItemsWithPagination/', authMiddleware,groupController.filterItemsWithPagination);
router.get('/get-admins-by-group-id', authMiddleware, groupController.getAdminsByGroupId);
router.get('/get-admins-by-group-id/:groupId', authMiddleware, groupController.getAdminsByGroupId);
router.delete('/leave-group/:groupId', authMiddleware, groupController.leaveGroup);
router.get('/get-emails-by-group-id/:groupId', authMiddleware, groupController.getEmailsByGroupId);
router.delete('/remove-member', authMiddleware, groupController.removeMember);



export default router; 