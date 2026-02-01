# Skill Connect - Testing Checklist

## Database Connection Tests

### Test 1: Verify PostgreSQL Connection
```bash
# From backend directory
node -e "const { testConnection } = require('./config/database'); testConnection();"
```
**Expected Output**: "Database connection test successful"

### Test 2: Verify Tables Created
```bash
psql -U admin -d skill_connect_db -c "\dt"
```
**Expected Output**: List of all tables (users, resumes, messages, etc.)

---

## API Endpoint Tests

Use Postman or curl to test these endpoints:

### 1. SIGNUP TEST - Should Store Data in PostgreSQL
**Endpoint**: `POST http://localhost:5000/api/signup`

**Request Body**:
```json
{
  "email": "test@example.com",
  "fullName": "John Doe",
  "password": "securePassword123",
  "status": "employed",
  "company": "Tech Corp",
  "phone": "+1234567890",
  "city": "New York",
  "state": "NY",
  "country": "USA",
  "dob": "1990-01-01",
  "qualification": "B.Tech",
  "branch": "Computer Science",
  "passoutYear": "2012"
}
```

**Expected Response**:
```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "id": "uuid-here",
    "email": "test@example.com",
    "fullName": "John Doe",
    "status": "employed",
    "createdAt": "timestamp"
  }
}
```

**Database Verification**:
```bash
psql -U admin -d skill_connect_db -c "SELECT email, fullname, status FROM users WHERE email='test@example.com';"
```

---

### 2. LOGIN TEST - Should Retrieve Data from PostgreSQL
**Endpoint**: `POST http://localhost:5000/api/login`

**Request Body**:
```json
{
  "email": "test@example.com",
  "password": "securePassword123"
}
```

**Expected Response**:
```json
{
  "success": true,
  "message": "Login successful",
  "user": {
    "id": "uuid-here",
    "email": "test@example.com",
    "fullName": "John Doe",
    "status": "employed",
    "isPremium": false
  }
}
```

**Note**: Password should be compared using bcrypt (not plaintext)

---

### 3. GET USER PROFILE - Should Retrieve from Database
**Endpoint**: `GET http://localhost:5000/api/user/test@example.com`

**Expected Response**:
```json
{
  "success": true,
  "user": {
    "id": "uuid",
    "email": "test@example.com",
    "fullname": "John Doe",
    "company": "Tech Corp",
    "phone": "+1234567890",
    "city": "New York",
    "state": "NY",
    "country": "USA",
    "status": "employed",
    "created_at": "timestamp",
    "updated_at": "timestamp"
  }
}
```

---

### 4. UPDATE USER PROFILE - Should Persist to Database
**Endpoint**: `PUT http://localhost:5000/api/user/test@example.com`

**Request Body**:
```json
{
  "fullname": "John Doe Updated",
  "bio": "I am a software engineer",
  "city": "San Francisco"
}
```

**Database Verification**:
```bash
psql -U admin -d skill_connect_db -c "SELECT fullname, bio, city FROM users WHERE email='test@example.com';"
```

---

### 5. PASSWORD HASHING TEST - Should Use bcrypt
**Test in Node REPL**:
```bash
cd backend
node
> const { hashPassword, comparePassword } = require('./utils/password');
> const hash = await hashPassword('testPassword123');
> console.log('Hashed:', hash);
> const match = await comparePassword('testPassword123', hash);
> console.log('Match:', match); // Should be true
```

**Expected**: Hash should NOT be plaintext, should start with $2a$ or $2b$

---

### 6. UPLOAD RESUME - Should Store in PostgreSQL
**Endpoint**: `POST http://localhost:5000/api/upload-resume`

**Form Data**:
- `email`: test@example.com
- `name`: John Doe
- `resume`: <PDF file>

**Expected Response**:
```json
{
  "success": true,
  "message": "Resume uploaded successfully",
  "resume": {
    "id": "uuid",
    "email": "test@example.com",
    "name": "John Doe",
    "file_size": 12345,
    "created_at": "timestamp"
  }
}
```

**Database Verification**:
```bash
psql -U admin -d skill_connect_db -c "SELECT email, name, resume_filename FROM resumes WHERE email='test@example.com';"
```

---

### 7. GET RESUME - Should Retrieve from Database
**Endpoint**: `GET http://localhost:5000/api/user-resume?email=test@example.com`

**Expected Response**:
```json
{
  "success": true,
  "resume": {
    "id": "uuid",
    "email": "test@example.com",
    "name": "John Doe",
    "resume_data": "extracted text from PDF...",
    "resume_filename": "resume.pdf",
    "created_at": "timestamp"
  }
}
```

---

### 8. HEALTH CHECK - Backend Running
**Endpoint**: `GET http://localhost:5000/health`

**Expected Response**:
```json
{
  "status": "OK"
}
```

---

### 9. GET ALL USERS - Should List from Database
**Endpoint**: `GET http://localhost:5000/api/users`

**Expected Response**:
```json
{
  "success": true,
  "users": [
    {
      "id": "uuid",
      "email": "test@example.com",
      "fullname": "John Doe",
      "status": "employed",
      "created_at": "timestamp"
    }
  ]
}
```

---

### 10. GET USER STATISTICS - Should Calculate from Database
**Endpoint**: `GET http://localhost:5000/api/user-stats`

**Expected Response**:
```json
{
  "success": true,
  "totalUsers": 5,
  "statusCount": {
    "employed": 2,
    "graduated": 2,
    "pursuing": 1
  },
  "cityCount": {
    "New York": 2,
    "San Francisco": 3
  }
}
```

---

## Frontend Tests

### Test 1: Signup Page
1. Navigate to `http://localhost:3000/signup`
2. Fill in all required fields
3. Click "Create Account"
4. **Verify**: 
   - No errors in browser console
   - API call succeeds (Network tab)
   - Data stored in PostgreSQL
   - Redirected to login page

### Test 2: Login Page
1. Navigate to `http://localhost:3000/login`
2. Enter credentials from signup test
3. Click "Sign In"
4. **Verify**:
   - User data loaded from database
   - Redirected to user dashboard
   - User info displayed correctly

### Test 3: User Dashboard
1. Log in successfully
2. View profile information
3. Click "Edit Profile"
4. Update bio or other fields
5. Save changes
6. **Verify**:
   - Changes persisted in database
   - Profile reflects updates after refresh

---

## Error Handling Tests

### Test 1: Duplicate Email Signup
**Input**: Email that already exists in database
**Expected**: 409 Conflict error: "Email already exists"

### Test 2: Invalid Credentials Login
**Input**: Wrong password
**Expected**: 401 Unauthorized: "Invalid credentials"

### Test 3: Invalid Email Format
**Input**: Signup with invalid email
**Expected**: 400 Bad Request: "Valid email is required"

### Test 4: Weak Password
**Input**: Password less than 6 characters
**Expected**: 400 Bad Request: "Password must be at least 6 characters"

### Test 5: Database Connection Error
**Action**: Stop PostgreSQL, try to signup
**Expected**: 500 error with appropriate message

---

## Performance Tests

### Test 1: Bulk User Creation
Create 100 users and verify:
- Database performance remains acceptable
- No connection pool errors
- Tables have proper indexes

### Test 2: Large Resume Upload
Upload a 2MB resume and verify:
- File size validated
- Upload completes successfully
- Text extraction works

---

## Security Tests

### Test 1: Password Storage
```bash
psql -U admin -d skill_connect_db -c "SELECT password FROM users LIMIT 1;"
```
**Expected**: Password should be bcrypt hash (not plaintext)

### Test 2: Input Sanitization
Try SQL injection: `test' OR '1'='1`
**Expected**: Should be safely escaped, no SQL injection

### Test 3: CORS Headers
Check API response headers in browser
**Expected**: `Access-Control-Allow-Origin: http://localhost:3000`

---

## Environment Variables Verification

### Backend
```bash
cd backend
grep -E "REACT_APP|DB_|MINIO_|EMAIL_" .env | sort
```

Ensure these are set:
- NODE_ENV
- PORT
- DB_NAME, DB_USER, DB_PASSWORD, DB_HOST, DB_PORT
- MINIO_ENDPOINT, MINIO_ACCESS_KEY, MINIO_SECRET_KEY
- EMAIL_USER, EMAIL_PASS

### Frontend
```bash
cd frontend
cat .env | grep REACT_APP
```

Ensure these are set:
- REACT_APP_API_URL (must match backend)
- REACT_APP_ENV

---

## Final Verification Checklist

- [ ] PostgreSQL running and accessible
- [ ] Backend starts without errors
- [ ] Frontend builds and runs without errors
- [ ] Signup endpoint works and stores data in PostgreSQL
- [ ] Login endpoint works and retrieves data from PostgreSQL
- [ ] Password is hashed with bcryptjs
- [ ] API errors return appropriate HTTP status codes
- [ ] CORS is properly configured
- [ ] Environment variables are correctly set
- [ ] Database initialization script runs successfully
- [ ] All tables exist and have proper relationships
- [ ] Indexes are created for performance
- [ ] Frontend API client uses correct base URL
- [ ] Token/session management works (if implemented)
- [ ] Resume upload works and stores in database
- [ ] User profile updates persist to database

---

## Troubleshooting During Testing

**If signup fails:**
1. Check backend logs: `NODE_ENV=development npm start`
2. Verify PostgreSQL is running: `psql -U admin -d skill_connect_db -c "SELECT 1"`
3. Check database URL: `echo $DATABASE_URL`
4. Look for bcryptjs errors in npm logs

**If login fails:**
1. Verify user exists in database
2. Check password hashing is working
3. Confirm email is lowercase in comparison

**If frontend can't reach backend:**
1. Verify REACT_APP_API_URL is correct
2. Check backend is running on correct port
3. Check browser console for CORS errors
4. Verify no firewall blocking port 5000

---

## Production Testing

Before deploying to production:
1. Run all tests with NODE_ENV=production
2. Test with production database (replicated data)
3. Verify SSL/TLS configuration
4. Test email service with production SMTP
5. Load test with multiple concurrent users
6. Backup and restore database
