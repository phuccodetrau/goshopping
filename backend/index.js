import app from './app.js';
// import UserModel from './models/user.model.js';
import mongoose from 'mongoose';
import { Group } from './models/schema.js';
import userRoutes from './routes/user.routes.js';
const port = 3000;

const createGroup = async () => {
    try {
      const newGroup = new Group({
        name: 'Family Group',
        listUser: [{ name: 'John', email: 'john@example.com', role: 'admin' }],
        refrigerator: []
      });
      
      const savedGroup = await newGroup.save();
      console.log('Group created:', savedGroup);
      return savedGroup._id;
    } catch (error) {
      console.error('Error creating group:', error);
    }
};

mongoose.connect(
    "mongodb+srv://phucnh0703:hoangphuc0703@cluster0.8tjiz.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
).then(() => {
    console.log("Thành công");
    app.listen(port, () => {
        // createGroup();
        console.log(`Server Listening on Port http://localhost:${port}`);
    });
}).catch(() => {
    console.log("Thất bại");
});

app.use('/user', userRoutes);

app.get('/', (req, res) => {
    res.send("Hello World");
});
