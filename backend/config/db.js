import mongoose from 'mongoose';

// Nếu bạn muốn bật chế độ debug
// mongoose.set('debug', true);

const connection = mongoose.connect(
    "mongodb+srv://phucnh0703:hoangphuc0703@cluster0.8tjiz.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
).then(() => {
    console.log("Thành công");
}).catch(() => {
    console.log("Thất bại");
});

export default connection;
