# ARTA Survey App - Setup Guide

## MongoDB Integration Setup

The Flutter app now sends survey data to MongoDB via the Node.js backend API.

### Prerequisites

1. **Node.js** (v14 or higher)
2. **MongoDB** (local or MongoDB Atlas)
3. **Flutter** (v3.9.2 or higher)

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment variables:**
   - Copy `.env.example` to `.env`
   - Update the MongoDB connection string:
     ```
     MONGODB_URI=mongodb://localhost:27017/arta_survey
     # OR for MongoDB Atlas:
     # MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/arta_survey
     ```

4. **Initialize the database (optional):**
   ```bash
   node scripts/init-db.js
   ```

5. **Start the backend server:**
   ```bash
   npm start
   ```
   
   The server will run on `http://localhost:3000`

### Flutter App Setup

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure API URL:**
   - Open `lib/services/api_service.dart`
   - Update the `baseUrl` constant:
     ```dart
     static const String baseUrl = 'http://localhost:3000';
     ```
   
   **Important:** 
   - For Android emulator, use: `http://10.0.2.2:3000`
   - For iOS simulator, use: `http://localhost:3000`
   - For physical device, use your computer's IP: `http://192.168.x.x:3000`

3. **Run the app:**
   ```bash
   flutter run
   ```

### How It Works

1. **Survey Submission:**
   - When a user submits a survey, the app attempts to send data to MongoDB via the backend API
   - If successful, data is saved to MongoDB and locally (as backup)
   - If the backend is unavailable, data is saved locally only
   - User receives feedback about the submission status

2. **Offline Capability:**
   - All surveys are saved locally using SharedPreferences
   - This ensures data is never lost even if the backend is down
   - Admin dashboard can view locally stored data

3. **Data Flow:**
   ```
   Flutter App → HTTP POST → Backend API → MongoDB
        ↓
   SharedPreferences (Local Backup)
   ```

### Testing the Integration

1. **Start the backend server** (see Backend Setup above)

2. **Check backend health:**
   - Open browser: `http://localhost:3000`
   - You should see: `{"message": "ARTA Customer Satisfaction Survey API", ...}`

3. **Submit a test survey:**
   - Run the Flutter app
   - Complete and submit a survey
   - Check for success message: "Survey submitted to database successfully!"

4. **Verify in MongoDB:**
   - Using MongoDB Compass or CLI:
     ```bash
     mongo
     use arta_survey
     db.surveys.find().pretty()
     ```

### Troubleshooting

**Problem:** "Error connecting to server"
- **Solution:** Ensure backend server is running on port 3000
- Check if MongoDB is running
- Verify the API URL in `api_service.dart` matches your setup

**Problem:** "Request timeout"
- **Solution:** Check your internet connection
- Increase timeout duration in `api_service.dart` if needed

**Problem:** Android emulator can't connect to localhost
- **Solution:** Use `http://10.0.2.2:3000` instead of `http://localhost:3000`

**Problem:** Physical device can't connect
- **Solution:** 
  - Ensure device and computer are on the same network
  - Use your computer's local IP address (e.g., `http://192.168.1.100:3000`)
  - Find your IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)

### API Endpoints

- `POST /api/surveys` - Submit a new survey
- `GET /api/surveys` - Get all surveys (with pagination)
- `GET /api/surveys/:id` - Get single survey
- `DELETE /api/surveys/:id` - Delete a survey
- `GET /api/analytics/summary` - Get analytics summary

### Production Deployment

1. **Deploy backend to a cloud service** (Heroku, AWS, DigitalOcean, etc.)
2. **Update API URL** in `lib/services/api_service.dart` to your production URL
3. **Enable HTTPS** for secure communication
4. **Update CORS settings** in backend to allow your Flutter app domain
5. **Set up MongoDB Atlas** for production database

### Security Notes

- Never commit `.env` file with real credentials
- Use environment variables for sensitive data
- Implement authentication for admin endpoints in production
- Enable HTTPS for all API communications
- Validate and sanitize all user inputs
