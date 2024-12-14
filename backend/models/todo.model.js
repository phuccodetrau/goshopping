import mongoose from 'mongoose';

const { Schema } = mongoose;

const toDoSchema = new Schema({
    userId: {
        type: Schema.Types.ObjectId,
        ref: 'User'
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
