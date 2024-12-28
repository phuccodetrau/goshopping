import app from './app.js';
import mongoose from 'mongoose';

const port = 3000;

mongoose.connect(
    "mongodb+srv://phucnh0703:hoangphuc0703@cluster0.8tjiz.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
).then(() => {
    console.log("Thành công");
    app.listen(port, '0.0.0.0',() => {
        console.log(`Server Listening on Port http://localhost:${port}`);
    });
}).catch(() => {
    console.log("Thất bại");
});

