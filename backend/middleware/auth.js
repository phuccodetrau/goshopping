import jwt from 'jsonwebtoken';

const authMiddleware = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ status: false, message: 'Access token is missing' });
  }

  jwt.verify(token, process.env.JWT_SECRET_KEY, (err, user) => {
    if (err) {
      return res.status(403).json({ status: false, message: 'Invalid token' });
    }
    req.user = user; // Attach user info to request
    console.log('User email.........:', user.email); 
    next();
  });
};

export default authMiddleware;
