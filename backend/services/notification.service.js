// Tạo thông báo cho task được giao
static async createTaskNotification(memberEmail, taskName, type = 'task_assigned', taskDetails = {}) {
    try {
        // Tìm user dựa trên email
        const user = await User.findOne({ email: memberEmail });
        if (!user) {
            throw new Error('User not found');
        }

        let title, content;
        const groupName = taskDetails.groupName || '';
        const foodDetails = `${taskDetails.amount || ''} ${taskDetails.unitName || ''} ${taskDetails.foodName || ''}`.trim();
        const dateRange = taskDetails.startDate && taskDetails.endDate ? 
            `từ ${new Date(taskDetails.startDate).toLocaleDateString('vi-VN')} đến ${new Date(taskDetails.endDate).toLocaleDateString('vi-VN')}` : '';

        if (type === 'task_assigned') {
            title = 'Nhiệm vụ mua sắm mới';
            content = `Bạn được giao nhiệm vụ mua ${foodDetails} trong nhóm "${groupName}"${dateRange ? ` (${dateRange})` : ''}${taskDetails.note ? `\nGhi chú: ${taskDetails.note}` : ''}`;
        } else if (type === 'task_updated') {
            title = 'Cập nhật nhiệm vụ mua sắm';
            content = `Nhiệm vụ mua ${foodDetails} trong nhóm "${groupName}" đã được cập nhật${dateRange ? ` (${dateRange})` : ''}${taskDetails.note ? `\nGhi chú: ${taskDetails.note}` : ''}`;
        }

        // Gửi push notification
        await this.sendPushNotification([user._id], title, content);

        // Tạo notification trong database
        return await this.createNotification(user._id, type, content);
    } catch (error) {
        console.error('Error in createTaskNotification:', error);
        throw error;
    }
} 