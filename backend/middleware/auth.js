import jwt from 'jsonwebtoken';

const authMiddleware = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  console.log("req.headers",req.headers);

  if (!token) {
    return res.status(401).json({ status: false, message: 'Access token is missing' });
  }

  jwt.verify(token, process.env.JWT_SECRET_KEY, (err, user) => {
    if (err) {
      return res.status(403).json({ status: false, message: 'Invalid token' });
    }
    req.user = user;
    next();
  });
};

export default authMiddleware;
