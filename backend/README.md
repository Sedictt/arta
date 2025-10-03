# ARTA Survey Backend API

Node.js + Express + MongoDB backend for the ARTA Customer Satisfaction Survey System.

## 🚀 Quick Start

### Prerequisites
- Node.js 16+ installed
- MongoDB installed and running locally, or MongoDB Atlas account

### Installation

1. **Install dependencies**
```bash
cd backend
npm install
```

2. **Configure environment**
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. **Start MongoDB** (if running locally)
```bash
mongod
```

4. **Initialize database with default admin**
```bash
node scripts/init-db.js
```

5. **Start the server**
```bash
# Development mode with auto-reload
npm run dev

# Production mode
npm start
```

Server will run on `http://localhost:3000`

---

## 📡 API Endpoints

### Survey Endpoints

#### Submit Survey
```http
POST /api/surveys
Content-Type: application/json

{
  "clientType": "Citizen",
  "sex": "Male",
  "age": 30,
  "region": "NCR",
  "cc1Answer": "I know what a CC is and I saw this office's CC",
  "cc2Answer": "Easy to see",
  "cc3Answer": "Helped very much",
  "sqdAnswers": {
    "SQD0": 5,
    "SQD1": 4,
    "SQD2": 5,
    "SQD3": 4,
    "SQD4": 5,
    "SQD5": 4,
    "SQD6": 5,
    "SQD7": 5,
    "SQD8": 4
  },
  "suggestions": "Great service!"
}
```

#### Get All Surveys
```http
GET /api/surveys?page=1&limit=10&clientType=Citizen&region=NCR
```

#### Get Single Survey
```http
GET /api/surveys/:id
```

#### Delete Survey
```http
DELETE /api/surveys/:id
```

### Admin Endpoints

#### Login
```http
POST /api/admin/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}
```

#### Register New Admin
```http
POST /api/admin/register
Content-Type: application/json

{
  "username": "newadmin",
  "password": "password123",
  "role": "admin"
}
```

#### Change Password
```http
POST /api/admin/change-password
Content-Type: application/json

{
  "username": "admin",
  "currentPassword": "admin123",
  "newPassword": "newpassword123"
}
```

### Analytics Endpoints

#### Get Summary
```http
GET /api/analytics/summary
```

#### Get Satisfaction Distribution
```http
GET /api/analytics/satisfaction-distribution
```

#### Get SQD Averages
```http
GET /api/analytics/sqd-averages
```

#### Get Stats by Client Type
```http
GET /api/analytics/by-client-type
```

#### Get Stats by Region
```http
GET /api/analytics/by-region
```

#### Get Trends
```http
GET /api/analytics/trends?days=30
```

#### Export Data
```http
GET /api/analytics/export
```

---

## 🗄️ Database Schema

### Survey Collection
```javascript
{
  date: Date,
  clientType: String (Citizen|Business|Government),
  sex: String (Male|Female),
  age: Number,
  region: String,
  cc1Answer: String,
  cc2Answer: String,
  cc3Answer: String,
  sqdAnswers: {
    SQD0-SQD8: Number (1-5)
  },
  suggestions: String,
  submittedAt: Date,
  ipAddress: String,
  userAgent: String
}
```

### Admin Collection
```javascript
{
  username: String (unique),
  password: String (hashed),
  role: String (admin|superadmin),
  lastLogin: Date,
  isActive: Boolean
}
```

---

## 🔒 Security Features

- **Helmet**: Security headers
- **CORS**: Cross-origin resource sharing
- **Rate Limiting**: Prevent abuse
- **Password Hashing**: bcrypt
- **JWT**: Token-based authentication
- **Input Validation**: express-validator
- **MongoDB Injection Protection**: Mongoose

---

## 🛠️ Development

### Project Structure
```
backend/
├── models/
│   ├── Survey.model.js
│   └── Admin.model.js
├── routes/
│   ├── survey.routes.js
│   ├── admin.routes.js
│   └── analytics.routes.js
├── scripts/
│   └── init-db.js
├── .env.example
├── server.js
├── package.json
└── README.md
```

### Environment Variables
```env
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/arta_survey
JWT_SECRET=your-secret-key
ADMIN_DEFAULT_PASSWORD=admin123
CORS_ORIGIN=http://localhost:8080
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

---

## 📊 Testing with Postman

1. Import the API endpoints
2. Set base URL: `http://localhost:3000`
3. Test survey submission
4. Test admin login
5. Test analytics endpoints

---

## 🚀 Deployment

### Deploy to Heroku
```bash
heroku create arta-survey-api
heroku addons:create mongolab
git push heroku main
```

### Deploy to Railway
```bash
railway init
railway add mongodb
railway up
```

### Deploy to DigitalOcean
- Use App Platform
- Connect GitHub repository
- Add MongoDB database
- Set environment variables

---

## 📝 API Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "error": "Detailed error"
}
```

---

## 🔧 Maintenance

### Backup Database
```bash
mongodump --db arta_survey --out ./backup
```

### Restore Database
```bash
mongorestore --db arta_survey ./backup/arta_survey
```

### View Logs
```bash
# Development
npm run dev

# Production with PM2
pm2 logs arta-survey
```

---

## 📞 Support

For issues or questions:
- Check the logs
- Review environment variables
- Ensure MongoDB is running
- Check network connectivity

---

**Version**: 1.0.0  
**Tech Stack**: Node.js, Express, MongoDB, JWT  
**Status**: ✅ Production Ready
