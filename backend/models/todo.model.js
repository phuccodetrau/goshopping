import mongoose from 'mongoose';
import UserModel from './user.model.js';

const { Schema } = mongoose;

const toDoSchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: UserModel.modelName
    },
    title: {
        type: String,
        required: true
    },
    description: {
        type: String,
        required: true
    }
}, { timestamps: true });

const ToDoModel = mongoose.model('todo', toDoSchema);

export default ToDoModel;
