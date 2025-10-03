# arta

# ARTA Customer Satisfaction Survey System

A modern, cross-platform survey application for the City Government of Valenzuela built with Flutter.

![Status](https://img.shields.io/badge/status-production%20ready-success)
![Platform](https://img.shields.io/badge/platform-web%20%7C%20desktop%20%7C%20mobile-blue)
![Flutter](https://img.shields.io/badge/flutter-3.9.2-blue)

---

## 🎯 Overview

This application automates the ARTA Customer Satisfaction Survey for government offices, providing:
- **Multi-platform support** (Web, Desktop, Mobile)
- **Offline capability** for data collection
- **Real-time analytics** dashboard
- **Data privacy compliance**
- **Modern, user-friendly interface**

---

## ✨ Key Features

### For Survey Respondents
- 📱 **Easy Access**: QR code or direct link
- 🎨 **Modern UI**: Beautiful, intuitive interface
- 📊 **Emoji Ratings**: Simple 5-point satisfaction scale
- 🔒 **Privacy First**: Clear privacy notices and consent
- 💾 **Offline Mode**: Complete surveys without internet

### For Administrators
- 📈 **Analytics Dashboard**: Real-time insights and charts
- 📊 **Visual Reports**: Pie charts, bar charts, trends
- 📥 **Data Export**: CSV format for further analysis
- 🔐 **Secure Access**: Password-protected admin panel
- 📱 **Responsive**: Works on any device

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Chrome, Edge, or any modern browser for web
- Android Studio / Xcode for mobile development

### Installation

#### Frontend (Flutter)

1. **Install Flutter dependencies**
```bash
flutter pub get
```

2. **Run the application**

For Web:
```bash
flutter run -d chrome
```

For Desktop:
```bash
flutter run -d windows  # or macos, linux
```

For Mobile:
```bash
flutter run -d <device-id>
```

#### Backend (Node.js + MongoDB)

1. **Navigate to backend folder**
```bash
cd backend
```

2. **Install Node.js dependencies**
```bash
npm install
```

3. **Configure environment**
```bash
cp .env.example .env
# Edit .env with your MongoDB URI and settings
```

4. **Initialize database**
```bash
node scripts/init-db.js
```

5. **Start the backend server**
```bash
# Development mode
npm run dev

# Production mode
npm start
```

Backend API will run on `http://localhost:3000`

See [backend/README.md](backend/README.md) for detailed API documentation.

---

## 📱 Application Structure

### Main Screens
1. **Welcome Page** - Introduction and navigation
2. **Survey Flow** (5 pages)
   - Instructions
   - Personal Information
   - Citizen's Charter Awareness
   - Service Quality Dimensions
   - Suggestions
3. **Admin Login** - Secure authentication
4. **Admin Dashboard** - Analytics and reporting
5. **QR Code Screen** - Survey access QR code

---

## 📚 Documentation

- **[IMPLEMENTATION.md](IMPLEMENTATION.md)** - Complete implementation details
- **[USER_MANUAL.md](USER_MANUAL.md)** - User guide for respondents and admins
- **[FEATURES_SUMMARY.md](FEATURES_SUMMARY.md)** - Comprehensive feature list
- **[instructions.md](instructions.md)** - Original requirements

---

## 🎨 Tech Stack

### Frontend (Flutter)
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **Key Packages**: google_fonts, shared_preferences, fl_chart, qr_flutter, csv, intl

### Backend (Node.js + MongoDB) ✅
- **Node.js** - Server runtime
- **Express** - Web framework
- **MongoDB** - Database
- **Mongoose** - ODM
- **JWT** - Authentication
- **bcrypt** - Password hashing

### Architecture
```
Frontend (Flutter):
lib/
├── main.dart
├── models/
│   └── survey_response.dart
├── services/
│   └── survey_service.dart
└── screens/
    ├── admin_login.dart
    ├── admin_dashboard.dart
    └── qr_code_screen.dart

Backend (Node.js):
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
└── server.js
```

---

## 🔐 Admin Access

**Default Credentials:**
- Password: `admin123`

⚠️ **Important**: Change the default password after first login in production!

---

## 📊 Survey Content

### Sections
1. **Demographics** (5 fields)
   - Date, Client Type, Sex, Age, Region

2. **Citizen's Charter** (3 questions)
   - Awareness, Visibility, Helpfulness

3. **Service Quality** (9 dimensions)
   - Satisfaction, Time, Requirements, Simplicity, Information, Fees, Fairness, Courtesy, Outcome

4. **Suggestions** (Optional)
   - Open feedback

---

## 🎯 Features Checklist

### Survey Features
- [x] Multi-page survey flow
- [x] Form validation
- [x] Progress indicator
- [x] Emoji-based ratings
- [x] Conditional questions
- [x] Offline capability
- [x] Success notifications

### Admin Features
- [x] Secure login
- [x] Analytics dashboard
- [x] Satisfaction distribution chart
- [x] Average scores chart
- [x] Recent responses list
- [x] CSV export
- [x] Data filtering

### Additional Features
- [x] QR code generation
- [x] Kiosk mode support
- [x] Privacy compliance
- [x] Responsive design
- [x] Modern UI/UX

---

## 🎨 Design System

### Color Palette
- **Primary**: Deep Blue (#0D47A1)
- **Secondary**: Amber/Gold (#FFA000)
- **Accent**: Light Blue (#1976D2)
- **Success**: Green (#2E7D32)
- **Background**: Light Gray Blue (#F5F7FA)

### Typography
- **Font Family**: Poppins
- **Weights**: Regular (400), Semi-Bold (600), Bold (700)

---

## 📈 Analytics

### Available Metrics
- Total response count
- Average satisfaction score
- Satisfaction distribution
- Individual SQD averages
- Response trends
- Demographic breakdowns

### Filtering Options
- By date range
- By client type
- By region

---

## 🔒 Security & Privacy

### Implemented
- Admin password authentication
- Input validation
- Privacy notices
- Consent collection
- Secure local storage

### Compliance
- Data Privacy Law compliant
- Role-based access control
- Confidentiality statements
- Optional participation

---

## 🚀 Deployment

### Web Deployment
```bash
flutter build web
# Deploy the build/web folder to your web server
```

### Desktop Deployment
```bash
flutter build windows  # or macos, linux
# Distribute the executable from build folder
```

### Mobile Deployment
```bash
flutter build apk  # Android
flutter build ios  # iOS
```

---

## 📝 Usage

### For Respondents
1. Open the application
2. Click "Start Survey"
3. Follow the 5-page flow
4. Submit completed survey

### For Administrators
1. Click "Admin" on welcome page
2. Enter password (admin123)
3. View analytics dashboard
4. Export data as needed

---

## 🤝 Contributing

This project is owned by the City Government of Valenzuela (CGOV).

### Development Guidelines
- Follow Flutter best practices
- Maintain code documentation
- Test on all platforms
- Ensure data privacy compliance

---

## 📄 License

Owned by City Government of Valenzuela (CGOV)
All rights reserved.

---

## 👥 Credits

**Developed for**: City Government of Valenzuela  
**Purpose**: ARTA Customer Satisfaction Survey Automation  
**Tech Stack**: Flutter, Node.js (ready), MongoDB (ready)

---

## 📞 Support

### For Technical Issues
- Review USER_MANUAL.md
- Check troubleshooting section
- Contact IT support

### For Survey Questions
- Refer to instructions page
- Contact CGOV office

---

## 🎉 Status

✅ **Production Ready**  
✅ **All Requirements Implemented**  
✅ **Documentation Complete**  
✅ **Multi-Platform Tested**

---

**Version**: 1.0.0  
**Last Updated**: October 2025  
**Status**: 🚀 Ready for Deployment
