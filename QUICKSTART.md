# Skill Connect - Quick Start Guide

## Get Running in 5 Minutes

### Prerequisites
- PostgreSQL installed (`psql` command available)
- Node.js 16+
- npm

### Step 1: Start PostgreSQL (if not running)
```bash
# MacOS with Homebrew
brew services start postgresql

# Or manually
psql postgres

# Windows/Linux - adjust based on your installation
```

### Step 2: Create Database
```bash
# Create the database
createdb skill_connect_db

# Verify it exists
psql -l | grep skill_connect_db
```

### Step 3: Install and Start Backend
```bash
cd backend
npm install
npm start
```

**Expected output**:
```
[v0] Starting Skill Connect Backend Server...
[v0] Server running on port 5000
[v0] Successfully connected to PostgreSQL
[v0] Database initialization completed successfully!
```

### Step 4: In Another Terminal, Start Frontend
```bash
cd frontend
npm install
npm start
```

**Expected output**: Browser opens to http://localhost:3000

### Step 5: Test the Application

#### Test Signup (Data Stored in PostgreSQL)
1. Click "Sign Up" button
2. Fill form:
   - Email: `test@example.com`
   - Full Name: `Test User`
   - Password: `Password123`
   - Status: `employed`
   - Date of Birth: Any date
3. Click "Create Account"
4. Should redirect to login page

#### Verify Data Stored in Database
```bash
psql -U admin -d skill_connect_db -c "SELECT email, fullname, status FROM users;"
```

**Output should show your user**:
```
      email      | fullname  |  status
-----------------+-----------+---------
 test@example.com | Test User | employed
```

#### Test Login
1. Go back to http://localhost:3000
2. Enter `test@example.com` and `Password123`
3. Click "Sign In"
4. Should show user dashboard with your profile data
5. **This data came from PostgreSQL database!**

---

## Common Issues & Quick Fixes

### PostgreSQL connection refused?
```bash
# Check if PostgreSQL is running
psql -U admin -d skill_connect_db -c "SELECT 1;"

# If fails, start PostgreSQL:
brew services start postgresql  # MacOS
sudo service postgresql start   # Linux
```

### Port 5000 already in use?
```bash
# Kill process on port 5000
lsof -i :5000
kill -9 <PID>

# Or change port in backend/.env
PORT=5001
```

### Frontend can't reach backend?
```bash
# Check REACT_APP_API_URL in frontend/.env
cat frontend/.env | grep REACT_APP_API_URL

# Should show: http://localhost:5000
# If different, edit and restart frontend
```

### Data not persisting?
```bash
# Check backend logs for errors
# Look for lines starting with [v0]

# Verify database connection
psql -U admin -d skill_connect_db -c "SELECT * FROM users;"

# If table doesn't exist, restart backend
# Backend auto-creates tables on startup
```

### Password hashing not working?
```bash
# Check password in database - should be a hash like: $2a$10$...
psql -U admin -d skill_connect_db -c "SELECT email, password FROM users LIMIT 1;"

# If it's plaintext, restart backend and signup again
# Make sure bcryptjs was installed:
cd backend
npm list bcryptjs
```

---

## Verify Everything Works

### 1. Backend Health Check
```bash
curl http://localhost:5000/health
# Should return: {"status":"OK"}
```

### 2. Frontend Loading
- Go to http://localhost:3000 in browser
- Should see Skill Connect login page

### 3. Database Connection
```bash
psql -U admin -d skill_connect_db -c "\dt"
# Should list all tables: users, resumes, messages, etc.
```

### 4. Full Flow Test
1. Signup with new email
2. Check database: `SELECT * FROM users WHERE email='...';`
3. Login with that email
4. Update profile (add bio, change city)
5. Verify changes in database

---

## What's Fixed

| Issue | Solution |
|-------|----------|
| Signup data not storing | Fixed database connection, proper SQL queries |
| Login not retrieving data | Fixed database config, proper password comparison |
| Passwords in plaintext | Added bcryptjs hashing |
| Frontend API hardcoded | Using environment variables now |
| No error handling | Added validation, error messages |
| Database connection pooling | Added proper pool configuration |

---

## Next Steps

1. **Test All Features**: Follow TEST_CHECKLIST.md for comprehensive testing
2. **Read Full Setup Guide**: See SETUP_GUIDE.md for detailed instructions
3. **Deploy to Production**: See SETUP_GUIDE.md section "Production Deployment"
4. **Customize**: Modify frontend styles, backend logic as needed

---

## File Structure

```
project/
├── backend/
│   ├── config/
│   │   ├── database.js (NEW - fixed connection)
│   │   └── db.js (old - for reference)
│   ├── utils/
│   │   ├── password.js (NEW - bcrypt hashing)
│   │   └── validation.js (NEW - input validation)
│   ├── routes/
│   │   ├── auth.js (UPDATED - hashing, validation)
│   │   ├── users.js (UPDATED - new DB config)
│   │   └── messages.js (UPDATED - new DB config)
│   ├── .env (NEW - development config)
│   ├── .env.example (UPDATED - template)
│   ├── package.json (UPDATED - bcryptjs, validator)
│   └── server.js (UPDATED - new DB config)
├── frontend/
│   ├── src/
│   │   ├── services/
│   │   │   └── api.js (UPDATED - env vars)
│   │   └── pages/
│   │       ├── Signup.js (UPDATED - logging)
│   │       └── Login.js (UPDATED - logging)
│   └── .env (UPDATED - API URL)
├── SETUP_GUIDE.md (NEW)
├── TEST_CHECKLIST.md (NEW)
├── FIXES_SUMMARY.md (NEW)
└── QUICKSTART.md (THIS FILE)
```

---

## Key Files to Know About

- **`/backend/config/database.js`** - Database connection (the main fix!)
- **`/backend/utils/password.js`** - Password hashing
- **`/backend/routes/auth.js`** - Authentication endpoints
- **`/frontend/.env`** - Frontend configuration
- **`/backend/.env`** - Backend configuration

---

## Useful Commands

### View all users
```bash
psql -U admin -d skill_connect_db -c "SELECT email, fullname, status, created_at FROM users;"
```

### View specific user
```bash
psql -U admin -d skill_connect_db -c "SELECT * FROM users WHERE email='test@example.com';"
```

### View resumes
```bash
psql -U admin -d skill_connect_db -c "SELECT email, name, file_size FROM resumes;"
```

### Clear all data (for fresh start)
```bash
psql -U admin -d skill_connect_db -c "TRUNCATE users CASCADE;"
```

### Check database size
```bash
psql -U admin -d skill_connect_db -c "SELECT pg_size_pretty(pg_database_size('skill_connect_db'));"
```

---

## Browser Console Tips

1. Open DevTools: F12
2. Go to Network tab
3. Try signup/login
4. Click on `signup` or `login` request
5. Check Response to see API response
6. Check Console for `[v0]` debug logs

---

## That's It!

Your Skill Connect application is now working with:
✅ Data storing in PostgreSQL
✅ Secure password hashing  
✅ Proper error handling
✅ Environment configuration

For more details, read the other guides:
- **SETUP_GUIDE.md** - Full setup and deployment
- **TEST_CHECKLIST.md** - Complete testing procedures
- **FIXES_SUMMARY.md** - Detailed explanation of all fixes
