# ARTA Survey System - Test Case Design Document

## Project Information
- **Project Name**: ARTA Customer Satisfaction Survey System
- **Version**: 1.0.0
- **Test Date**: October 2025
- **Prepared By**: QA Team
- **Platforms**: Web, Desktop (Windows/Linux/macOS), Mobile (Android/iOS)

---

## Table of Contents
1. [Frontend Modules](#frontend-modules)
2. [Backend Modules](#backend-modules)
3. [Integration Tests](#integration-tests)

---

# FRONTEND MODULES

---

## MODULE 1: SURVEY SUBMISSION MODULE

**MODULE NAME**: Survey Submission Module  
**LOCATION**: `lib/main.dart` (SurveyHomePage)  
**PREREQUISITES**:  
- Flutter app running
- Internet connection (optional for offline mode)

**ENVIRONMENT INFORMATION**:  
- OS: Windows/Linux/Mac/Android/iOS
- Browser: Chrome/Firefox/Edge (for web)

---

### TEST CASE 1.1: Valid Survey Submission - Complete Data

**TEST CASE ID**: TC-SURVEY-001  
**TEST CASE DESCRIPTION**: Verify that a user can successfully submit a complete survey with all valid data.

**TEST SCENARIO**: User completes all 5 pages of the survey with valid information and submits successfully.

**TEST STEPS**:

**Step 1 (TC-SURVEY-001-01)**:
- Navigate to Welcome Page
- Click "Start Survey" button
- **TEST INPUT**: Click action
- **EXPECTED RESULT**: Survey Instructions page loads successfully
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

**Step 2 (TC-SURVEY-001-02)**:
- Click "Next" button on Instructions page
- **TEST INPUT**: Click action
- **EXPECTED RESULT**: Personal Information page loads
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

**Step 3 (TC-SURVEY-001-03)**:
- Select Date: 2025-10-28
- Select Client Type: "Citizen"
- Select Sex: "Male"
- Enter Age: 30
- Select Region: "NCR"
- Click "Next" button
- **TEST INPUT**: Date: 2025-10-28, ClientType: Citizen, Sex: Male, Age: 30, Region: NCR
- **EXPECTED RESULT**: CC Awareness page loads, all data is saved in memory
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

**Step 4 (TC-SURVEY-001-04)**:
- Select CC1 Answer: "I know what a CC is and I saw this office's CC"
- Select CC2 Answer: "Easy to see"
- Select CC3 Answer: "Helped very much"
- Click "Next" button
- **TEST INPUT**: CC1, CC2, CC3 answers selected
- **EXPECTED RESULT**: Service Quality Dimensions page loads
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

**Step 5 (TC-SURVEY-001-05)**:
- Rate all 9 SQD questions (SQD0 through SQD8) with score 5 (Very Satisfied emoji)
- Click "Next" button
- **TEST INPUT**: SQD0-8: All rated 5
- **EXPECTED RESULT**: Suggestions page loads
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

**Step 6 (TC-SURVEY-001-06)**:
- Enter suggestions in text field: "Excellent service!"
- Click "Submit" button
- **TEST INPUT**: Suggestions text: "Excellent service!"
- **EXPECTED RESULT**: Success dialog is shown, survey data is saved to local storage and synced to backend
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

---

### TEST CASE 1.2: Invalid Survey Submission - Missing Required Fields

**TEST CASE ID**: TC-SURVEY-002  
**TEST CASE DESCRIPTION**: Verify that the system prevents submission when required fields are missing.

**TEST SCENARIO**: User attempts to proceed without filling required fields.

**TEST STEPS**:

**Step 1 (TC-SURVEY-002-01)**:
- Start Survey from Welcome Page
- Skip reading Instructions
- Click "Next" without filling Personal Information
- **TEST INPUT**: No data entered
- **EXPECTED RESULT**: Error message is displayed, user cannot proceed to next page
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

**Step 2 (TC-SURVEY-002-02)**:
- Fill only Client Type field with "Citizen"
- Leave Age, Sex, and Region fields empty
- Click "Next" button
- **TEST INPUT**: ClientType: Citizen only, other fields empty
- **EXPECTED RESULT**: Error message "Please fill all required fields" is shown
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

**Step 3 (TC-SURVEY-002-03)**:
- Fill Personal Information completely
- Skip all CC (Citizen's Charter) questions
- Try to proceed to next page
- **TEST INPUT**: Personal data only, CC questions unanswered
- **EXPECTED RESULT**: Cannot proceed or warning message is shown
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

**Step 4 (TC-SURVEY-002-04)**:
- Fill Personal Information and CC questions
- Skip all SQD (Service Quality Dimensions) ratings
- Click "Submit" button
- **TEST INPUT**: Missing SQD ratings
- **EXPECTED RESULT**: Error message "Please rate all questions" is displayed
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

---

### TEST CASE 1.3: Boundary Value Testing - Age Field

**TEST CASE ID**: TC-SURVEY-003  
**TEST CASE DESCRIPTION**: Test age field with boundary values to verify input validation.

**TEST SCENARIO**: Enter minimum, maximum, and out-of-range age values.

**TEST STEPS**:

**Step 1 (TC-SURVEY-003-01)**:
- Enter age value: 0 (below minimum)
- **TEST INPUT**: Age: 0
- **EXPECTED RESULT**: Validation error "Age must be between 1 and 150"
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

**Step 2 (TC-SURVEY-003-02)**:
- Enter minimum valid age: 1
- **TEST INPUT**: Age: 1
- **EXPECTED RESULT**: Input is accepted without errors
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

**Step 3 (TC-SURVEY-003-03)**:
- Enter typical/normal age: 30
- **TEST INPUT**: Age: 30
- **EXPECTED RESULT**: Input is accepted without errors
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

**Step 4 (TC-SURVEY-003-04)**:
- Enter maximum valid age: 150
- **TEST INPUT**: Age: 150
- **EXPECTED RESULT**: Input is accepted without errors
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

**Step 5 (TC-SURVEY-003-05)**:
- Enter age value: 151 (above maximum)
- **TEST INPUT**: Age: 151
- **EXPECTED RESULT**: Validation error "Age must be between 1 and 150"
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

**Step 6 (TC-SURVEY-003-06)**:
- Enter negative age value: -5
- **TEST INPUT**: Age: -5
- **EXPECTED RESULT**: Error message shown or field blocks negative input
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

**Step 7 (TC-SURVEY-003-07)**:
- Enter non-numeric characters: "ABC"
- **TEST INPUT**: Age: "ABC"
- **EXPECTED RESULT**: Validation error "Please enter a valid number"
- **ACTUAL RESULT**: ___________
- **STATUS**: ___________
- **COMMENTS**: ___________

---

### TEST CASE 1.4: Offline Mode Testing

**TEST CASE ID**: TC-SURVEY-004
**TEST CASE DESCRIPTION**: Verify survey submission works in offline mode.

**TEST SCENARIO**: Submit survey without internet connection.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-SURVEY-004-01 | 1. Disconnect internet<br>2. Fill complete survey<br>3. Submit | Complete survey data | Survey saved locally, success message shown | | | |
| TC-SURVEY-004-02 | 1. Check local storage | None | Survey stored in SharedPreferences | | | |
| TC-SURVEY-004-03 | 1. Reconnect internet<br>2. Open app | None | Survey syncs to backend automatically | | | |

---

## MODULE 2: ADMIN LOGIN MODULE

### Module Information
- **MODULE NAME**: Admin Authentication Module
- **LOCATION**: `lib/screens/admin_login.dart`, `lib/services/auth_service.dart`
- **PREREQUISITES**: Default admin initialized (username: admin, password: admin123)

---

### TEST CASE 2.1: Valid Admin Login

**TEST CASE ID**: TC-LOGIN-001
**TEST CASE DESCRIPTION**: Verify successful admin login with correct credentials.

**TEST SCENARIO**: Admin enters correct username and password.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-LOGIN-001-01 | 1. Navigate to Admin page<br>2. Enter username<br>3. Enter password<br>4. Click Login | Username: admin<br>Password: admin123 | Redirect to Admin Dashboard, session created | | | |
| TC-LOGIN-001-02 | Verify session token | None | Session token stored, valid for 8 hours | | | |
| TC-LOGIN-001-03 | Check last login time | None | Last login timestamp updated | | | |

---

### TEST CASE 2.2: Invalid Login Attempts

**TEST CASE ID**: TC-LOGIN-002
**TEST CASE DESCRIPTION**: Verify login fails with incorrect credentials.

**TEST SCENARIO**: Test various invalid login scenarios.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-LOGIN-002-01 | Enter wrong password | Username: admin<br>Password: wrong123 | Error: "Invalid credentials" | | | |
| TC-LOGIN-002-02 | Enter wrong username | Username: wronguser<br>Password: admin123 | Error: "Invalid credentials" | | | |
| TC-LOGIN-002-03 | Enter both wrong | Username: wrong<br>Password: wrong | Error: "Invalid credentials" | | | |
| TC-LOGIN-002-04 | Leave username empty | Username: (empty)<br>Password: admin123 | Error: "Username required" | | | |
| TC-LOGIN-002-05 | Leave password empty | Username: admin<br>Password: (empty) | Error: "Password required" | | | |
| TC-LOGIN-002-06 | Leave both empty | Both fields empty | Error: "Please fill all fields" | | | |

---

### TEST CASE 2.3: Password Security

**TEST CASE ID**: TC-LOGIN-003
**TEST CASE DESCRIPTION**: Verify password is hashed and secure.

**TEST SCENARIO**: Test password hashing and storage.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-LOGIN-003-01 | Check stored password | None | Password stored as SHA-256 hash, not plaintext | | | |
| TC-LOGIN-003-02 | Verify password masking in UI | Password input | Password field shows dots/asterisks | | | |
| TC-LOGIN-003-03 | Test password with special chars | Password: p@ssw0rd!#$ | Accepts and hashes correctly | | | |

---

### TEST CASE 2.4: Session Management

**TEST CASE ID**: TC-LOGIN-004
**TEST CASE DESCRIPTION**: Verify session validity and expiration.

**TEST SCENARIO**: Test session timeout after 8 hours.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-LOGIN-004-01 | Login and wait | Login, then wait | Session valid for 7 hours 59 minutes | | | Manual test |
| TC-LOGIN-004-02 | Check after 8+ hours | Modify session timestamp | Session expired, redirect to login | | | |
| TC-LOGIN-004-03 | Test logout function | Click logout | Session cleared, redirect to login | | | |

---

## MODULE 3: ADMIN DASHBOARD MODULE

### Module Information
- **MODULE NAME**: Admin Dashboard & Analytics Module
- **LOCATION**: `lib/screens/admin_dashboard.dart`
- **PREREQUISITES**: Admin logged in, survey data exists

---

### TEST CASE 3.1: Dashboard Data Display

**TEST CASE ID**: TC-DASHBOARD-001
**TEST CASE DESCRIPTION**: Verify dashboard displays correct analytics.

**TEST SCENARIO**: View dashboard with survey data.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-DASHBOARD-001-01 | View total responses | None | Correct count displayed | | | |
| TC-DASHBOARD-001-02 | View average satisfaction | None | Average calculated correctly (1-5 scale) | | | |
| TC-DASHBOARD-001-03 | View satisfaction distribution chart | None | Pie chart shows correct percentages | | | |
| TC-DASHBOARD-001-04 | View SQD averages chart | None | Bar chart shows all 9 SQD scores | | | |
| TC-DASHBOARD-001-05 | View recent responses list | None | Latest 10 responses shown | | | |

---

### TEST CASE 3.2: Data Filtering

**TEST CASE ID**: TC-DASHBOARD-002
**TEST CASE DESCRIPTION**: Test filtering functionality.

**TEST SCENARIO**: Filter data by various criteria.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-DASHBOARD-002-01 | Filter by client type | ClientType: Citizen | Only citizen responses shown | | | |
| TC-DASHBOARD-002-02 | Filter by region | Region: NCR | Only NCR responses shown | | | |
| TC-DASHBOARD-002-03 | Filter by date range | Start: 2025-10-01<br>End: 2025-10-31 | Only October responses shown | | | |
| TC-DASHBOARD-002-04 | Apply multiple filters | Client: Business<br>Region: Region III | Combined filter applied correctly | | | |
| TC-DASHBOARD-002-05 | Clear filters | Click "Clear" | All data shown again | | | |

---

### TEST CASE 3.3: Data Export

**TEST CASE ID**: TC-DASHBOARD-003
**TEST CASE DESCRIPTION**: Test CSV export functionality.

**TEST SCENARIO**: Export survey data to CSV.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-DASHBOARD-003-01 | Export all data | Click "Export CSV" | CSV file downloads with all records | | | |
| TC-DASHBOARD-003-02 | Verify CSV format | Open CSV file | Headers present, data formatted correctly | | | |
| TC-DASHBOARD-003-03 | Export filtered data | Apply filter, then export | CSV contains only filtered records | | | |
| TC-DASHBOARD-003-04 | Export with no data | Empty database | CSV with headers only or appropriate message | | | |

---

### TEST CASE 3.4: Dashboard Performance

**TEST CASE ID**: TC-DASHBOARD-004
**TEST CASE DESCRIPTION**: Test dashboard with large datasets.

**TEST SCENARIO**: Performance testing with boundary data volumes.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-DASHBOARD-004-01 | Load with 10 surveys | 10 records | Loads instantly (<1 sec) | | | |
| TC-DASHBOARD-004-02 | Load with 100 surveys | 100 records | Loads quickly (<2 sec) | | | |
| TC-DASHBOARD-004-03 | Load with 1000 surveys | 1000 records | Loads within 5 seconds | | | |
| TC-DASHBOARD-004-04 | Load with 10000 surveys | 10000 records | Pagination works, acceptable load time | | | |

---

# BACKEND MODULES

---

## MODULE 4: SURVEY API ENDPOINTS

### Module Information
- **MODULE NAME**: Survey REST API
- **LOCATION**: `backend/routes/survey.routes.js`
- **PREREQUISITES**: MongoDB running, Backend server started on port 3000

---

### TEST CASE 4.1: POST /api/surveys - Valid Survey Submission

**TEST CASE ID**: TC-API-SURVEY-001
**TEST CASE DESCRIPTION**: Test successful survey submission via API.

**TEST SCENARIO**: Submit valid survey data to API endpoint.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-API-SURVEY-001-01 | POST request with valid data | ```json<br>{<br>  "clientType": "Citizen",<br>  "sex": "Male",<br>  "age": 30,<br>  "region": "NCR",<br>  "sqdAnswers": {<br>    "SQD0": 5, "SQD1": 4,<br>    "SQD2": 5, "SQD3": 4,<br>    "SQD4": 5, "SQD5": 4,<br>    "SQD6": 5, "SQD7": 5,<br>    "SQD8": 4<br>  }<br>}``` | Status: 201<br>Response: {"success": true, "message": "Survey submitted successfully"} | | | |
| TC-API-SURVEY-001-02 | Verify data in MongoDB | Query database | Survey record exists with correct data | | | |
| TC-API-SURVEY-001-03 | Check response structure | None | Response includes survey ID and timestamp | | | |

---

### TEST CASE 4.2: POST /api/surveys - Invalid Data Validation

**TEST CASE ID**: TC-API-SURVEY-002
**TEST CASE DESCRIPTION**: Test API validation for invalid survey data.

**TEST SCENARIO**: Submit invalid data to trigger validation errors.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-API-SURVEY-002-01 | Invalid client type | clientType: "InvalidType" | Status: 400<br>Error: "Invalid client type" | | | |
| TC-API-SURVEY-002-02 | Invalid sex value | sex: "Unknown" | Status: 400<br>Error: "Invalid sex" | | | |
| TC-API-SURVEY-002-03 | Age below minimum | age: 0 | Status: 400<br>Error: "Age must be between 1 and 150" | | | |
| TC-API-SURVEY-002-04 | Age above maximum | age: 151 | Status: 400<br>Error: "Age must be between 1 and 150" | | | |
| TC-API-SURVEY-002-05 | Missing required field | region: (omitted) | Status: 400<br>Error: "Region is required" | | | |
| TC-API-SURVEY-002-06 | Suggestions too long | suggestions: (2001 chars) | Status: 400<br>Error: "Suggestions too long" | | | |
| TC-API-SURVEY-002-07 | Malformed JSON | Invalid JSON syntax | Status: 400<br>Error: "Invalid JSON" | | | |

---

### TEST CASE 4.3: GET /api/surveys - Retrieve Surveys with Pagination

**TEST CASE ID**: TC-API-SURVEY-003
**TEST CASE DESCRIPTION**: Test survey retrieval with pagination.

**TEST SCENARIO**: Fetch surveys with different pagination parameters.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-API-SURVEY-003-01 | Get first page | GET /api/surveys?page=1&limit=10 | Status: 200<br>Returns 10 records, pagination info | | | |
| TC-API-SURVEY-003-02 | Get second page | GET /api/surveys?page=2&limit=10 | Status: 200<br>Returns next 10 records | | | |
| TC-API-SURVEY-003-03 | Custom page size | GET /api/surveys?page=1&limit=5 | Status: 200<br>Returns 5 records | | | |
| TC-API-SURVEY-003-04 | Page beyond available data | GET /api/surveys?page=999&limit=10 | Status: 200<br>Returns empty array | | | |
| TC-API-SURVEY-003-05 | Invalid page number | GET /api/surveys?page=-1&limit=10 | Status: 400 or defaults to page 1 | | | |

---

### TEST CASE 4.4: GET /api/surveys - Filtering

**TEST CASE ID**: TC-API-SURVEY-004
**TEST CASE DESCRIPTION**: Test survey filtering parameters.

**TEST SCENARIO**: Filter surveys by various criteria.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-API-SURVEY-004-01 | Filter by client type | GET /api/surveys?clientType=Citizen | Only citizen surveys returned | | | |
| TC-API-SURVEY-004-02 | Filter by region | GET /api/surveys?region=NCR | Only NCR surveys returned | | | |
| TC-API-SURVEY-004-03 | Filter by date range | GET /api/surveys?startDate=2025-10-01&endDate=2025-10-31 | Only October surveys returned | | | |
| TC-API-SURVEY-004-04 | Multiple filters | GET /api/surveys?clientType=Business&region=Region%20III | Combined filters applied | | | |
| TC-API-SURVEY-004-05 | Case-insensitive search | GET /api/surveys?region=ncr | Case-insensitive match works | | | |

---

### TEST CASE 4.5: GET /api/surveys/:id - Get Single Survey

**TEST CASE ID**: TC-API-SURVEY-005
**TEST CASE DESCRIPTION**: Test retrieving a single survey by ID.

**TEST SCENARIO**: Fetch specific survey records.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-API-SURVEY-005-01 | Valid survey ID | GET /api/surveys/{valid_id} | Status: 200<br>Survey data returned | | | |
| TC-API-SURVEY-005-02 | Non-existent ID | GET /api/surveys/507f1f77bcf86cd799439011 | Status: 404<br>Error: "Survey not found" | | | |
| TC-API-SURVEY-005-03 | Invalid ID format | GET /api/surveys/invalid-id | Status: 500 or 400<br>Error message | | | |

---

### TEST CASE 4.6: DELETE /api/surveys/:id - Delete Survey

**TEST CASE ID**: TC-API-SURVEY-006
**TEST CASE DESCRIPTION**: Test survey deletion.

**TEST SCENARIO**: Delete surveys via API.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-API-SURVEY-006-01 | Delete existing survey | DELETE /api/surveys/{valid_id} | Status: 200<br>Success message<br>Record removed from DB | | | |
| TC-API-SURVEY-006-02 | Delete non-existent survey | DELETE /api/surveys/{invalid_id} | Status: 404<br>Error: "Survey not found" | | | |
| TC-API-SURVEY-006-03 | Delete same survey twice | DELETE twice | Second delete returns 404 | | | |

---

## MODULE 5: ADMIN API ENDPOINTS

### Module Information
- **MODULE NAME**: Admin Authentication API
- **LOCATION**: `backend/routes/admin.routes.js`
- **PREREQUISITES**: MongoDB running, default admin created

---

### TEST CASE 5.1: POST /api/admin/login - Valid Login

**TEST CASE ID**: TC-API-ADMIN-001
**TEST CASE DESCRIPTION**: Test successful admin login via API.

**TEST SCENARIO**: Login with correct credentials.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-API-ADMIN-001-01 | POST login request | ```json<br>{<br>  "username": "admin",<br>  "password": "admin123"<br>}``` | Status: 200<br>JWT token returned<br>Admin info returned | | | |
| TC-API-ADMIN-001-02 | Verify JWT token | Decode token | Token contains admin ID and role | | | |
| TC-API-ADMIN-001-03 | Check token expiry | None | Token expires in 24 hours | | | |
| TC-API-ADMIN-001-04 | Verify last login updated | Query database | lastLogin timestamp updated | | | |

---

### TEST CASE 5.2: POST /api/admin/login - Invalid Login

**TEST CASE ID**: TC-API-ADMIN-002
**TEST CASE DESCRIPTION**: Test login failures with invalid credentials.

**TEST SCENARIO**: Various invalid login attempts.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-API-ADMIN-002-01 | Wrong password | username: admin<br>password: wrong | Status: 401<br>Error: "Invalid credentials" | | | |
| TC-API-ADMIN-002-02 | Wrong username | username: wronguser<br>password: admin123 | Status: 401<br>Error: "Invalid credentials" | | | |
| TC-API-ADMIN-002-03 | Empty username | username: ""<br>password: admin123 | Status: 400<br>Error: "Username and password required" | | | |
| TC-API-ADMIN-002-04 | Empty password | username: admin<br>password: "" | Status: 400<br>Error: "Username and password required" | | | |
| TC-API-ADMIN-002-05 | Missing body | No request body | Status: 400<br>Error message | | | |
| TC-API-ADMIN-002-06 | Inactive admin | isActive: false | Status: 401<br>Error: "Invalid credentials" | | | |

---

### TEST CASE 5.3: POST /api/admin/register - User Registration

**TEST CASE ID**: TC-API-ADMIN-003
**TEST CASE DESCRIPTION**: Test admin user registration.

**TEST SCENARIO**: Register new admin users.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-API-ADMIN-003-01 | Register valid user | ```json<br>{<br>  "username": "newadmin",<br>  "password": "password123",<br>  "role": "admin"<br>}``` | Status: 201<br>User created successfully | | | |
| TC-API-ADMIN-003-02 | Duplicate username | username: "admin" (exists) | Status: 400<br>Error: "Username already exists" | | | |
| TC-API-ADMIN-003-03 | Password too short | password: "12345" (5 chars) | Status: 400<br>Error: "Password must be at least 6 characters" | | | |
| TC-API-ADMIN-003-04 | Minimum valid password | password: "123456" (6 chars) | Status: 201<br>User created | | | |
| TC-API-ADMIN-003-05 | Missing username | username: (omitted) | Status: 400<br>Error: "Username required" | | | |
| TC-API-ADMIN-003-06 | Missing password | password: (omitted) | Status: 400<br>Error: "Password required" | | | |

---

### TEST CASE 5.4: POST /api/admin/change-password - Password Change

**TEST CASE ID**: TC-API-ADMIN-004
**TEST CASE DESCRIPTION**: Test password change functionality.

**TEST SCENARIO**: Change admin password.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-API-ADMIN-004-01 | Valid password change | ```json<br>{<br>  "username": "admin",<br>  "currentPassword": "admin123",<br>  "newPassword": "newpass123"<br>}``` | Status: 200<br>Password updated successfully | | | |
| TC-API-ADMIN-004-02 | Verify new password works | Login with new password | Login successful | | | |
| TC-API-ADMIN-004-03 | Wrong current password | currentPassword: "wrong" | Status: 401<br>Error: "Current password incorrect" | | | |
| TC-API-ADMIN-004-04 | New password too short | newPassword: "12345" | Status: 400<br>Error: "New password must be at least 6 characters" | | | |
| TC-API-ADMIN-004-05 | Missing fields | Incomplete request | Status: 400<br>Error: "All fields required" | | | |
| TC-API-ADMIN-004-06 | Non-existent username | username: "nonexistent" | Status: 404<br>Error: "Admin not found" | | | |

---

## MODULE 6: ANALYTICS API ENDPOINTS

### Module Information
- **MODULE NAME**: Analytics & Reporting API
- **LOCATION**: `backend/routes/analytics.routes.js`
- **PREREQUISITES**: Survey data exists in database

---

### TEST CASE 6.1: GET /api/analytics/summary - Overall Summary

**TEST CASE ID**: TC-API-ANALYTICS-001
**TEST CASE DESCRIPTION**: Test analytics summary endpoint.

**TEST SCENARIO**: Retrieve overall statistics.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-API-ANALYTICS-001-01 | Get summary with data | GET /api/analytics/summary | Status: 200<br>Returns: totalSurveys, avgSatisfaction, etc. | | | |
| TC-API-ANALYTICS-001-02 | Verify calculations | Compare with manual calculation | Averages calculated correctly | | | |
| TC-API-ANALYTICS-001-03 | Empty database | No surveys | Returns zeros or appropriate defaults | | | |

---

### TEST CASE 6.2: GET /api/analytics/satisfaction-distribution

**TEST CASE ID**: TC-API-ANALYTICS-002
**TEST CASE DESCRIPTION**: Test satisfaction distribution endpoint.

**TEST SCENARIO**: Get breakdown of satisfaction levels.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-API-ANALYTICS-002-01 | Get distribution | GET /api/analytics/satisfaction-distribution | Status: 200<br>Returns counts for each satisfaction level | | | |
| TC-API-ANALYTICS-002-02 | Verify percentages | Calculate manually | Percentages add up to 100% | | | |

---

### TEST CASE 6.3: GET /api/analytics/export - Data Export

**TEST CASE ID**: TC-API-ANALYTICS-003
**TEST CASE DESCRIPTION**: Test data export functionality.

**TEST SCENARIO**: Export all survey data.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-API-ANALYTICS-003-01 | Export all data | GET /api/analytics/export | Status: 200<br>JSON array of all surveys | | | |
| TC-API-ANALYTICS-003-02 | Verify data completeness | Check response | All fields included for each survey | | | |
| TC-API-ANALYTICS-003-03 | Large dataset | 1000+ surveys | Response within acceptable time (<10 sec) | | | |

---

# INTEGRATION TESTS

---

## MODULE 7: END-TO-END WORKFLOW

### Module Information
- **MODULE NAME**: Complete User Journey Integration
- **PREREQUISITES**: Full system running (Frontend + Backend + Database)

---

### TEST CASE 7.1: Complete Survey Flow (Online)

**TEST CASE ID**: TC-E2E-001
**TEST CASE DESCRIPTION**: Test complete survey submission flow with backend integration.

**TEST SCENARIO**: User submits survey, admin views it in dashboard.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-E2E-001-01 | User completes survey | Complete survey data | Survey submitted to backend | | | |
| TC-E2E-001-02 | Verify in MongoDB | Query database | Survey record exists | | | |
| TC-E2E-001-03 | Admin logs in | Correct credentials | Admin dashboard loads | | | |
| TC-E2E-001-04 | Admin views survey | Check dashboard | New survey appears in recent list | | | |
| TC-E2E-001-05 | Analytics update | Check dashboard stats | Total count increased by 1 | | | |

---

### TEST CASE 7.2: Offline to Online Sync

**TEST CASE ID**: TC-E2E-002
**TEST CASE DESCRIPTION**: Test offline submission and online sync.

**TEST SCENARIO**: Submit offline, then sync when online.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-E2E-002-01 | Disconnect network | None | App still functional | | | |
| TC-E2E-002-02 | Submit survey offline | Complete survey | Saved locally, success message | | | |
| TC-E2E-002-03 | Verify local storage | Check SharedPreferences | Survey stored locally | | | |
| TC-E2E-002-04 | Verify NOT in MongoDB | Query database | Survey not yet in backend | | | |
| TC-E2E-002-05 | Reconnect network | None | Network restored | | | |
| TC-E2E-002-06 | Trigger sync | Open app or manual sync | Survey syncs to backend | | | |
| TC-E2E-002-07 | Verify in MongoDB | Query database | Survey now exists in backend | | | |

---

### TEST CASE 7.3: Multi-Platform Consistency

**TEST CASE ID**: TC-E2E-003
**TEST CASE DESCRIPTION**: Test data consistency across platforms.

**TEST SCENARIO**: Submit from web, view from mobile.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-E2E-003-01 | Submit survey from web | Web browser | Survey submitted successfully | | | |
| TC-E2E-003-02 | Open mobile admin app | Mobile device | Login successful | | | |
| TC-E2E-003-03 | View same survey | Check dashboard | Survey visible on mobile | | | |
| TC-E2E-003-04 | Verify data integrity | Compare data | All fields match exactly | | | |

---

## MODULE 8: SECURITY TESTING

### Module Information
- **MODULE NAME**: Security & Vulnerability Testing
- **PREREQUISITES**: Full system running

---

### TEST CASE 8.1: SQL/NoSQL Injection

**TEST CASE ID**: TC-SEC-001
**TEST CASE DESCRIPTION**: Test for injection vulnerabilities.

**TEST SCENARIO**: Attempt injection attacks.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-SEC-001-01 | SQL injection in survey | suggestions: "'; DROP TABLE--" | Input sanitized, no execution | | | |
| TC-SEC-001-02 | NoSQL injection in login | username: {"$gt": ""} | Request blocked or sanitized | | | |
| TC-SEC-001-03 | Script injection | suggestions: "<script>alert('XSS')</script>" | Script escaped, not executed | | | |

---

### TEST CASE 8.2: Rate Limiting

**TEST CASE ID**: TC-SEC-002
**TEST CASE DESCRIPTION**: Test API rate limiting.

**TEST SCENARIO**: Exceed rate limits.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-SEC-002-01 | Send 100 requests in 1 minute | Automated script | All accepted (within limit) | | | |
| TC-SEC-002-02 | Send 101st request | One more request | Status: 429<br>Error: "Too many requests" | | | |
| TC-SEC-002-03 | Wait 15 minutes | Time delay | Rate limit reset, requests work again | | | |

---

### TEST CASE 8.3: Authentication Security

**TEST CASE ID**: TC-SEC-003
**TEST CASE DESCRIPTION**: Test authentication security measures.

**TEST SCENARIO**: Various authentication attacks.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-SEC-003-01 | Access admin without login | Direct URL to dashboard | Redirect to login page | | | |
| TC-SEC-003-02 | Use expired JWT token | Old token | Status: 401<br>Error: "Token expired" | | | |
| TC-SEC-003-03 | Tamper with JWT token | Modified token | Status: 401<br>Error: "Invalid token" | | | |
| TC-SEC-003-04 | Brute force login | 100 failed attempts | Rate limiting applied, account locked | | | |

---

## MODULE 9: PERFORMANCE TESTING

### Module Information
- **MODULE NAME**: Load & Performance Testing
- **PREREQUISITES**: Full system with test data

---

### TEST CASE 9.1: Load Testing - Concurrent Users

**TEST CASE ID**: TC-PERF-001
**TEST CASE DESCRIPTION**: Test system under concurrent load.

**TEST SCENARIO**: Multiple simultaneous users.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-PERF-001-01 | 10 concurrent surveys | 10 simultaneous submissions | All submitted successfully | | | Use load testing tool |
| TC-PERF-001-02 | 50 concurrent surveys | 50 simultaneous | All processed within 10 seconds | | | |
| TC-PERF-001-03 | 100 concurrent surveys | 100 simultaneous | Acceptable performance (<30 sec) | | | |
| TC-PERF-001-04 | Monitor server resources | During load | CPU < 80%, Memory < 80% | | | |

---

### TEST CASE 9.2: Database Performance

**TEST CASE ID**: TC-PERF-002
**TEST CASE DESCRIPTION**: Test database query performance.

**TEST SCENARIO**: Query large datasets.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-PERF-002-01 | Query 1000 surveys | No filters | Response < 2 seconds | | | |
| TC-PERF-002-02 | Query 10000 surveys | No filters | Response < 5 seconds | | | |
| TC-PERF-002-03 | Complex aggregation | Analytics queries | Response < 10 seconds | | | |
| TC-PERF-002-04 | Verify indexes | Check MongoDB | Indexes on submittedAt, clientType, region | | | |

---

## MODULE 10: COMPATIBILITY TESTING

### Module Information
- **MODULE NAME**: Cross-Platform & Browser Compatibility
- **PREREQUISITES**: App built for multiple platforms

---

### TEST CASE 10.1: Browser Compatibility (Web)

**TEST CASE ID**: TC-COMPAT-001
**TEST CASE DESCRIPTION**: Test web app across browsers.

**TEST SCENARIO**: Run on different browsers.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-COMPAT-001-01 | Test on Chrome | Chrome browser | All features work correctly | | | |
| TC-COMPAT-001-02 | Test on Firefox | Firefox browser | All features work correctly | | | |
| TC-COMPAT-001-03 | Test on Edge | Edge browser | All features work correctly | | | |
| TC-COMPAT-001-04 | Test on Safari | Safari browser | All features work correctly | | | |

---

### TEST CASE 10.2: Mobile Platform Testing

**TEST CASE ID**: TC-COMPAT-002
**TEST CASE DESCRIPTION**: Test mobile apps.

**TEST SCENARIO**: Test on iOS and Android.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-COMPAT-002-01 | Test on Android | Android device | App functions correctly | | | |
| TC-COMPAT-002-02 | Test on iOS | iOS device | App functions correctly | | | |
| TC-COMPAT-002-03 | Test on tablet | Tablet device | Responsive layout works | | | |

---

### TEST CASE 10.3: Desktop Platform Testing

**TEST CASE ID**: TC-COMPAT-003
**TEST CASE DESCRIPTION**: Test desktop applications.

**TEST SCENARIO**: Test on Windows, macOS, Linux.

| TEST CASE ID | TEST STEPS | TEST INPUT | EXPECTED RESULT | ACTUAL RESULT | STATUS | COMMENTS |
|--------------|------------|------------|-----------------|---------------|--------|----------|
| TC-COMPAT-003-01 | Test on Windows | Windows 10/11 | App runs correctly | | | |
| TC-COMPAT-003-02 | Test on macOS | macOS | App runs correctly | | | |
| TC-COMPAT-003-03 | Test on Linux | Ubuntu/Debian | App runs correctly | | | |

---

## TEST EXECUTION SUMMARY

### Test Metrics Template

| Module | Total Test Cases | Passed | Failed | Blocked | Not Executed | Pass Rate |
|--------|-----------------|--------|--------|---------|--------------|-----------|
| Survey Submission | 20 | | | | | |
| Admin Login | 16 | | | | | |
| Admin Dashboard | 18 | | | | | |
| Survey API | 25 | | | | | |
| Admin API | 22 | | | | | |
| Analytics API | 8 | | | | | |
| End-to-End | 15 | | | | | |
| Security | 12 | | | | | |
| Performance | 8 | | | | | |
| Compatibility | 10 | | | | | |
| **TOTAL** | **154** | | | | | |

---

## DEFECT TRACKING TEMPLATE

| Defect ID | Module | Test Case ID | Severity | Description | Status | Assigned To |
|-----------|--------|--------------|----------|-------------|--------|-------------|
| BUG-001 | | | Critical/High/Medium/Low | | Open/In Progress/Resolved/Closed | |

---

## NOTES FOR TESTERS

### Setup Instructions
1. **Backend Setup**: Run `cd backend && npm install && npm run dev`
2. **Frontend Setup**: Run `flutter pub get && flutter run -d chrome`
3. **Database Setup**: Ensure MongoDB is running on localhost:27017
4. **Test Data**: Use `backend/scripts/init-db.js` to initialize test data

### Test Tools Recommended
- **API Testing**: Postman, Thunder Client, curl
- **Load Testing**: Apache JMeter, k6
- **Browser Testing**: Selenium, Playwright
- **Mobile Testing**: Flutter DevTools, Xcode, Android Studio
- **Database**: MongoDB Compass

### Critical Test Paths
1. Survey submission flow (TC-E2E-001)
2. Admin login and dashboard (TC-LOGIN-001, TC-DASHBOARD-001)
3. Data persistence and sync (TC-E2E-002)
4. Security measures (TC-SEC-001, TC-SEC-003)

---

**Document Version**: 1.0  
**Last Updated**: October 2025  
**Status**: Ready for Test Execution
