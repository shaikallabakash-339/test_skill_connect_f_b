# Skill Connect - Quick Reference Card

## 📋 Files You Need to Know

### Critical Fixes (Read First)
```
/backend/config/database.js         ← Database connection (MAIN FIX)
/backend/utils/password.js          ← Password hashing
/backend/routes/auth.js             ← Fixed signup/login
```

### Configuration (Set First)
```
/backend/.env                       ← Backend settings
/frontend/.env                      ← Frontend settings
```

### Documentation (Read Second)
```
QUICKSTART.md                       ← Start here (5 min)
SETUP_GUIDE.md                      ← Full setup (30 min)
TEST_CHECKLIST.md                   ← How to test (45 min)
FIXES_SUMMARY.md                    ← What changed (20 min)
COMPLETION_REPORT.md                ← Final report
```

---

## 🚀 Quick Commands

### Start Backend
```bash
cd backend
npm install    # First time only
npm start      # Runs on http://localhost:5000
```

### Start Frontend
```bash
cd frontend
npm install    # First time only
npm start      # Opens http://localhost:3000
```

### Create Database
```bash
createdb skill_connect_db
```

### Verify Data (After Signup)
```bash
psql -U admin -d skill_connect_db -c "SELECT email, fullname FROM users;"
```

### Check Password Hash
```bash
psql -U admin -d skill_connect_db -c "SELECT password FROM users LIMIT 1;"
```

### View All Tables
```bash
psql -U admin -d skill_connect_db -c "\dt"
```

---

## ⚙️ Environment Variables

### Backend (.env)
```
NODE_ENV=development
PORT=5000
DB_USER=admin
DB_PASSWORD=admin123
DB_HOST=localhost
DB_PORT=5432
DB_NAME=skill_connect_db
```

### Frontend (.env)
```
REACT_APP_API_URL=http://localhost:5000
REACT_APP_ENV=development
```

---

## 🔑 Key Features Fixed

| Feature | Status | Location |
|---------|--------|----------|
| Signup stores data | ✅ FIXED | /backend/routes/auth.js |
| Password hashing | ✅ FIXED | /backend/utils/password.js |
| Login retrieves data | ✅ FIXED | /backend/routes/auth.js |
| DB connection | ✅ FIXED | /backend/config/database.js |
| Input validation | ✅ FIXED | /backend/utils/validation.js |
| API configuration | ✅ FIXED | /frontend/src/services/api.js |
| Error handling | ✅ FIXED | All routes |

---

## 🧪 Quick Tests

### Test 1: Database Connection
```bash
psql -U admin -d skill_connect_db -c "SELECT 1;"
# Expected: 1
```

### Test 2: Signup → Check Database
```bash
# 1. Go to http://localhost:3000/signup
# 2. Fill form and submit
# 3. Run:
psql -U admin -d skill_connect_db -c "SELECT * FROM users ORDER BY created_at DESC LIMIT 1;"
# Expected: Your user data
```

### Test 3: Check Password Hash
```bash
psql -U admin -d skill_connect_db -c "SELECT password FROM users WHERE email='your-email' LIMIT 1;"
# Expected: $2a$10$... (NOT plaintext!)
```

### Test 4: Login Test
```bash
# 1. Go to http://localhost:3000/login
# 2. Enter credentials
# Expected: Dashboard with your profile
```

---

## 🔒 Security

### Passwords
- ✅ Hashed with bcryptjs (10 rounds)
- ✅ Never stored as plaintext
- ✅ Compared using bcrypt.compare()

### Inputs
- ✅ Validated (email, phone, etc.)
- ✅ Sanitized (escaped)
- ✅ Parameterized queries (no SQL injection)

### Database
- ✅ Connection pooling
- ✅ Proper constraints
- ✅ Foreign keys enforced

---

## 🐛 Troubleshooting

### Backend won't start?
```bash
# Check if port 5000 is in use
lsof -i :5000

# If in use, kill or change port
kill -9 <PID>
```

### Database connection error?
```bash
# Verify PostgreSQL running
psql -U admin -c "SELECT 1;"

# If fails, start PostgreSQL
brew services start postgresql  # MacOS
```

### Frontend can't reach backend?
```bash
# Check REACT_APP_API_URL
cat frontend/.env | grep REACT_APP_API_URL

# Should be: http://localhost:5000
# If different, update and restart frontend
```

### Data not persisting?
```bash
# Check backend logs for [v0] messages
# Verify database exists
createdb skill_connect_db

# Restart backend (will auto-create tables)
```

---

## 📊 API Endpoints

### Authentication
| Endpoint | Method | Purpose |
|----------|--------|---------|
| /api/signup | POST | Create user account |
| /api/login | POST | Login user |
| /api/forgot-password | POST | Reset password |

### User Profile
| Endpoint | Method | Purpose |
|----------|--------|---------|
| /api/user/:email | GET | Get user profile |
| /api/user/:email | PUT | Update profile |
| /api/users | GET | Get all users |
| /api/user-stats | GET | Get statistics |

### Resume
| Endpoint | Method | Purpose |
|----------|--------|---------|
| /api/upload-resume | POST | Upload PDF resume |
| /api/user-resume | GET | Get user resume |
| /api/delete-resume | DELETE | Delete resume |

---

## 📈 Performance Metrics

- ✅ Database connections pooled (max 20)
- ✅ Queries optimized (proper indexes)
- ✅ Response timeout: 30 seconds
- ✅ Connection timeout: 2 seconds
- ✅ File upload limit: 2MB

---

## 🔄 Data Flow

### Signup Flow
```
User Form
    ↓
Validation (frontend)
    ↓
POST /api/signup
    ↓
Server Validation
    ↓
Hash Password (bcrypt)
    ↓
Insert into PostgreSQL
    ↓
Return Success
    ↓
Redirect to Login
```

### Login Flow
```
User Credentials
    ↓
POST /api/login
    ↓
Query PostgreSQL
    ↓
Compare Hashed Password
    ↓
Return User Data
    ↓
Redirect to Dashboard
```

---

## 📁 Directory Structure (Important Parts)

```
backend/
├── config/
│   ├── database.js          (NEW - DB connection)
│   └── db.js                (OLD - reference only)
├── utils/
│   ├── password.js          (NEW - Hashing)
│   └── validation.js        (NEW - Validation)
├── routes/
│   ├── auth.js              (UPDATED)
│   └── users.js             (UPDATED)
├── .env                     (NEW)
└── package.json             (UPDATED)

frontend/
├── src/
│   └── services/
│       └── api.js           (UPDATED)
└── .env                     (UPDATED)
```

---

## ✅ Pre-Deployment Checklist

- [ ] PostgreSQL running
- [ ] Database created
- [ ] Backend dependencies installed
- [ ] Frontend dependencies installed
- [ ] Both .env files configured
- [ ] Signup works and stores data
- [ ] Login works and retrieves data
- [ ] Passwords are hashed (not plaintext)
- [ ] API endpoints respond correctly
- [ ] Frontend can reach backend
- [ ] No errors in browser console
- [ ] No errors in backend logs

---

## 🚢 Deployment Options

### Development (Local)
```bash
npm install
npm start
```

### Staging (Similar to Production)
See SETUP_GUIDE.md

### Production
See SETUP_GUIDE.md "Production Deployment" section

---

## 🆘 Getting Help

1. **Quick Start**: QUICKSTART.md
2. **Setup Issues**: SETUP_GUIDE.md → Troubleshooting
3. **Testing**: TEST_CHECKLIST.md
4. **Understanding Changes**: FIXES_SUMMARY.md
5. **Final Report**: COMPLETION_REPORT.md

---

## 💡 Pro Tips

### Tip 1: Check Backend Health
```bash
curl http://localhost:5000/health
# Should return: {"status":"OK"}
```

### Tip 2: View Backend Logs
Backend logs have `[v0]` prefix for easy filtering:
```bash
npm start 2>&1 | grep "\[v0\]"
```

### Tip 3: Clear Cache During Development
```bash
npm cache clean --force
# Then: npm install
```

### Tip 4: Reset Database
```bash
# Delete and recreate
dropdb skill_connect_db
createdb skill_connect_db

# Restart backend (auto-creates tables)
```

### Tip 5: Check Network in Browser
Press F12 → Network tab → Try login
- Watch for API calls
- Check response status
- View response data

---

## 📞 Support Priority

1. **Critical**: Database connection, data not persisting → SETUP_GUIDE.md
2. **High**: Password hashing, login fails → FIXES_SUMMARY.md
3. **Medium**: API testing → TEST_CHECKLIST.md
4. **Low**: UI customization → Use frontend documentation

---

## ⚡ Most Important Commands

```bash
# Start everything
cd backend && npm start          # Terminal 1
cd frontend && npm start         # Terminal 2

# Verify database
psql -U admin -d skill_connect_db -c "SELECT * FROM users;"

# Check health
curl http://localhost:5000/health

# Test signup (store data)
# 1. Go to http://localhost:3000/signup
# 2. Fill and submit
# 3. Run above SELECT command to verify

# Done!
```

---

## 🎯 Success Criteria

You'll know it's working when:
1. ✅ Signup creates user in database
2. ✅ Login retrieves that user
3. ✅ Password is hashed (not plaintext)
4. ✅ Dashboard shows user profile
5. ✅ No errors in browser console
6. ✅ No errors in backend logs
7. ✅ Can upload and retrieve resumes

---

**All fixes are in place. You're ready to go! 🚀**

Start with QUICKSTART.md for the fastest path to success.
