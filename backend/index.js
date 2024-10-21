import app from './app.js';
// import UserModel from './models/user.model.js';
import db from './config/db.js';

const port = 3000;

app.get('/', (req, res) => {
    res.send("Hello World");
});

app.listen(port, () => {
    console.log(`Server Listening on Port http://localhost:${port}`);
});
