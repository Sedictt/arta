# ARTA Customer Satisfaction Survey - User Manual

## Table of Contents
1. [Getting Started](#getting-started)
2. [For Survey Respondents](#for-survey-respondents)
3. [For Administrators](#for-administrators)
4. [QR Code Access](#qr-code-access)
5. [Troubleshooting](#troubleshooting)

---

## Getting Started

### System Requirements
- **Web Browser**: Chrome, Firefox, Safari, or Edge (latest version)
- **Mobile**: iOS 12+ or Android 6.0+
- **Desktop**: Windows 10+, macOS 10.14+, or Linux

### Accessing the Survey
1. Open your web browser
2. Navigate to the survey URL
3. You'll see the welcome page with three options:
   - **Start Survey**: Begin the survey
   - **QR Code**: Generate QR code for mobile access
   - **Admin**: Access the admin dashboard

---

## For Survey Respondents

### Step 1: Welcome Page
- Read the introduction about the survey
- Review the privacy notice
- Click **"Start Survey"** to begin

### Step 2: Instructions
- Read the survey instructions carefully
- Review the rating scale:
  - 😠 = 1 (Strongly Disagree)
  - 😕 = 2 (Disagree)
  - 😐 = 3 (Neither Agree nor Disagree)
  - 🙂 = 4 (Agree)
  - 😄 = 5 (Strongly Agree)
- Click **"Next"** to continue

### Step 3: Personal Information
Fill in your details:
- **Date**: Select the date of your transaction
- **Client Type**: Choose Citizen, Business, or Government
- **Sex**: Select Male or Female
- **Age**: Enter your age
- **Region of Residence**: Enter your region

Click **"Next"** when complete.

### Step 4: Citizen's Charter Awareness
Answer the CC questions:
- **CC1**: Select your awareness level of the Citizen's Charter
- **CC2**: (Appears if you're aware) Rate visibility of the CC
- **CC3**: (Appears if you're aware) Rate how helpful the CC was

Click **"Next"** to continue.

### Step 5: Service Quality
Rate your experience on 9 aspects:
- Click the emoji that best represents your satisfaction
- Selected emojis will be highlighted in gold
- All questions use the same 1-5 scale

Click **"Next"** when done.

### Step 6: Suggestions
- Enter any suggestions for improvement (optional)
- Review the privacy notice
- Click **"Submit Survey"**

### Completion
- You'll see a success message
- Your feedback has been recorded
- Thank you for your participation!

---

## For Administrators

### Logging In
1. Click **"Admin"** on the welcome page
2. Enter the admin password
   - Default password: `admin123`
   - ⚠️ Change this after first login!
3. Click **"Login"**

### Dashboard Overview
The admin dashboard shows:

#### Statistics Cards
- **Total Responses**: Number of completed surveys
- **Avg Satisfaction**: Overall satisfaction score (1-5)

#### Satisfaction Distribution Chart
- Pie chart showing breakdown of satisfaction levels
- Color-coded by satisfaction level
- Shows count for each category

#### Average SQD Scores Chart
- Bar chart showing average score for each SQD question
- Helps identify areas of strength and improvement
- Scale from 0-5

#### Recent Responses List
- Last 10 survey submissions
- Shows client type, region, and satisfaction score
- Timestamp of submission

### Exporting Data

#### CSV Export
1. Click the **download icon** in the top-right
2. Data will be prepared in CSV format
3. In production, this will download a file
4. Currently shows in console for development

#### CSV Contains:
- All demographic information
- CC answers
- SQD scores
- Average scores
- Satisfaction levels
- Suggestions
- Timestamps

### Refreshing Data
- Click the **refresh icon** to reload dashboard
- Data updates automatically when new surveys are submitted

### Changing Admin Password
Currently requires code modification. In production:
1. Go to Settings
2. Enter current password
3. Enter new password
4. Confirm new password

---

## QR Code Access

### Generating QR Code
1. Click **"QR Code"** on welcome page
2. QR code will be displayed
3. Share this screen for public access

### Using QR Code
**For Respondents:**
1. Open camera app on mobile device
2. Point at QR code
3. Tap notification to open survey
4. Complete survey on mobile device

**For Kiosk Mode:**
1. Display QR code on tablet/screen
2. Click **"Enable Kiosk Mode"**
3. Survey will run in full-screen mode
4. Ideal for public locations

### QR Code Features
- Works offline once loaded
- No app installation required
- Direct link to survey
- Shareable URL displayed

---

## Troubleshooting

### Survey Not Submitting
**Problem**: Submit button doesn't work
**Solution**:
- Ensure all required fields are filled
- Check for validation errors (red text)
- Make sure date is selected
- Verify age is a valid number

### Data Not Showing in Dashboard
**Problem**: Dashboard shows 0 responses
**Solution**:
- Click refresh icon
- Verify surveys were actually submitted
- Check browser console for errors
- Clear browser cache and reload

### Admin Login Failed
**Problem**: Password not accepted
**Solution**:
- Default password is `admin123`
- Check for typos
- Ensure caps lock is off
- Contact system administrator if password was changed

### QR Code Not Scanning
**Problem**: Mobile device won't scan QR code
**Solution**:
- Ensure good lighting
- Hold device steady
- Try different camera app
- Use the URL link instead

### Offline Mode Issues
**Problem**: Survey won't work offline
**Solution**:
- Load the page once while online
- Browser will cache the app
- Data saves locally
- Will sync when back online (in production)

---

## Best Practices

### For Survey Respondents
- ✅ Answer honestly for best results
- ✅ Take your time reading questions
- ✅ Use the full rating scale
- ✅ Provide detailed suggestions
- ❌ Don't rush through questions
- ❌ Don't skip required fields

### For Administrators
- ✅ Review dashboard regularly
- ✅ Export data for backup
- ✅ Change default password
- ✅ Monitor response trends
- ✅ Act on feedback received
- ❌ Don't share admin credentials
- ❌ Don't ignore low satisfaction scores

### For Kiosk Setup
- ✅ Place in accessible location
- ✅ Ensure stable internet (or offline mode)
- ✅ Test before deployment
- ✅ Provide clear instructions
- ✅ Monitor regularly
- ❌ Don't leave unattended without testing
- ❌ Don't block QR code visibility

---

## Data Privacy

### What We Collect
- Demographic information (age, sex, region)
- Service experience ratings
- Suggestions for improvement
- Submission timestamp

### How We Use It
- Improve government services
- Identify areas needing attention
- Track satisfaction trends
- Generate reports for stakeholders

### Your Rights
- ✅ Participation is voluntary
- ✅ Data is kept confidential
- ✅ You can skip optional questions
- ✅ No personally identifiable information required

---

## Contact & Support

### For Technical Issues
- Check this manual first
- Review troubleshooting section
- Contact IT support

### For Survey Content Questions
- Refer to instructions page
- Contact CGOV office
- Review Citizen's Charter

### For Data Access
- Admin login required
- Contact system administrator
- Follow data privacy protocols

---

## Quick Reference

### Survey Flow
1. Welcome → 2. Instructions → 3. Personal Info → 4. CC Awareness → 5. Service Quality → 6. Suggestions → Submit

### Rating Scale
- 1 = Strongly Disagree 😠
- 2 = Disagree 😕
- 3 = Neither Agree nor Disagree 😐
- 4 = Agree 🙂
- 5 = Strongly Agree 😄

### Admin Access
- Default Password: `admin123`
- Change after first login
- Keep credentials secure

### Time Estimate
- Survey completion: 3-5 minutes
- Dashboard review: 2-3 minutes
- Data export: 1 minute

---

**Version**: 1.0  
**Last Updated**: October 2025  
**Developed for**: City Government of Valenzuela
