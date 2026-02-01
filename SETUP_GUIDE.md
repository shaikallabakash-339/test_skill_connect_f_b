# Skill Connect - Setup & Deployment Guide

## Project Overview
Skill Connect is a professional networking platform built with React frontend and Node.js/Express backend, using PostgreSQL for data persistence.

## Technology Stack
- **Frontend**: React 19, React Router v7, Axios, Framer Motion
- **Backend**: Node.js, Express 4.21, PostgreSQL 12+
- **Storage**: MinIO (S3-compatible object storage)
- **Email**: Nodemailer (with Mailpit for local, SendPulse for production)
- **Security**: bcryptjs for password hashing

## Prerequisites
- Node.js 16+ and npm
- PostgreSQL 12+
- MinIO (for file storage)
- Mailpit (for local email testing)

## Local Development Setup

### 1. Clone the Repository
```bash
git clone https://github.com/shaikallabakash-339/test_skill_connect_f_b.git
cd test_skill_connect_f_b
```

### 2. Install Backend Dependencies
```bash
cd backend
npm install
```

### 3. Install Frontend Dependencies
```bash
cd frontend
npm install
```

### 4. Setup PostgreSQL Database

#### Option A: Using Docker Compose (Recommended)
Create a `docker-compose.yml` in the root:
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: admin123
      POSTGRES_DB: skill_connect_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  minio:
    image: minio/minio
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin123
    ports:
      - "9000:9000"
      - "9001:9001"
    command: server /data --console-address ":9001"
    volumes:
      - minio_data:/data

  mailpit:
    image: axllent/mailpit
    ports:
      - "1025:1025"
      - "8025:8025"

volumes:
  postgres_data:
  minio_data:
```

Run: `docker-compose up -d`

#### Option B: Manual PostgreSQL Setup
```bash
# Create database
createdb skill_connect_db

# Connect to database
psql -U admin -d skill_connect_db

# The backend will auto-create tables on startup
```

### 5. Configure Environment Variables

#### Backend (.env)
```bash
cd backend
cp .env.example .env
```

Edit `/backend/.env`:
```
NODE_ENV=development
PORT=5000

# PostgreSQL
DB_NAME=skill_connect_db
DB_USER=admin
DB_PASSWORD=admin123
DB_HOST=localhost
DB_PORT=5432

# MinIO
MINIO_ENDPOINT=localhost
MINIO_PORT=9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin123
MINIO_BUCKET=skill-connect-bucket

# Email (local testing)
MAILPIT_HOST=localhost
MAILPIT_PORT=1025
EMAIL_USER=test@skillconnect.com
EMAIL_PASS=test

# Frontend
FRONTEND_URL=http://localhost:3000
```

#### Frontend (.env)
Edit `/frontend/.env`:
```
REACT_APP_API_URL=http://localhost:5000
REACT_APP_ENV=development
REACT_APP_DEBUG=true
```

### 6. Start Development Servers

**Terminal 1 - Backend:**
```bash
cd backend
npm start
# Server runs on http://localhost:5000
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm start
# App runs on http://localhost:3000
```

### 7. Verify Setup
- Frontend: http://localhost:3000
- Backend API: http://localhost:5000/health
- MinIO Dashboard: http://localhost:9001
- Mailpit: http://localhost:8025

## Key Features & How to Test

### 1. User Signup (Stores in PostgreSQL)
- Navigate to `/signup`
- Fill in required fields
- Password is hashed with bcryptjs before storage
- Data persisted to PostgreSQL `users` table

### 2. User Login (Retrieves from PostgreSQL)
- Navigate to `/login`
- Uses hashed password comparison
- Session stored in localStorage
- Fetches user profile from database

### 3. User Dashboard
- View profile data from PostgreSQL
- Update profile (data persists to database)
- Upload resume (stored in resumes table)

### 4. Resume Upload
- Uses express-fileupload middleware
- Stores metadata in PostgreSQL `resumes` table
- PDF text extraction with pdf-parse

## Database Schema

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  fullname TEXT NOT NULL,
  password TEXT NOT NULL (bcrypt hashed),
  company TEXT,
  dob TEXT,
  city, state, country TEXT,
  phone TEXT,
  status TEXT (employed/graduated/pursuing),
  qualification TEXT,
  branch TEXT,
  passoutyear TEXT,
  profile_image_url TEXT,
  bio TEXT,
  is_premium BOOLEAN,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

### Resumes Table
```sql
CREATE TABLE resumes (
  id UUID PRIMARY KEY,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  resume_url TEXT,
  resume_filename TEXT,
  file_type TEXT,
  file_size INT,
  resume_data TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

## API Endpoints

### Authentication
- `POST /api/signup` - Create new user
- `POST /api/login` - User login
- `POST /api/forgot-password` - Reset password
- `GET /api/user/:email` - Get user profile
- `PUT /api/user/:email` - Update user profile

### Users
- `GET /api/users` - Get all users
- `GET /api/user-stats` - Get user statistics
- `POST /api/upload-resume` - Upload resume
- `GET /api/user-resume?email=...` - Get user's resume
- `GET /api/resume-users` - Get all users with resumes
- `DELETE /api/delete-resume` - Delete resume

## Common Issues & Solutions

### Issue: Signup data not storing in database
**Solution:**
1. Check PostgreSQL is running: `psql -U admin -d skill_connect_db -c "SELECT 1"`
2. Check backend logs for database errors
3. Verify DATABASE_URL or individual DB credentials in .env
4. Ensure tables were created (backend logs will show initialization)

### Issue: Frontend can't reach backend
**Solution:**
1. Verify `REACT_APP_API_URL` matches backend URL in frontend/.env
2. Check backend is running on correct port: `lsof -i :5000`
3. Check CORS is enabled in server.js
4. Look for network errors in browser console (F12 → Network tab)

### Issue: Password not hashing
**Solution:**
1. Ensure bcryptjs is installed: `npm list bcryptjs` in backend
2. Check password utility is being imported in routes
3. Verify error logs for hashing failures

### Issue: Email not sending
**Solution:**
1. For local dev: Verify Mailpit is running on port 1025
2. Check email configuration in backend/.env
3. View Mailpit UI at http://localhost:8025
4. For production: Configure SendPulse credentials in .env

## Production Deployment

### Environment Variables for Production
```env
NODE_ENV=production
DATABASE_URL=postgresql://user:password@host:5432/skill_connect_db
FRONTEND_URL=https://yourdomain.com
JWT_SECRET=use_a_strong_random_string
```

### Database Setup for Production
1. Use managed PostgreSQL (AWS RDS, Heroku Postgres, etc.)
2. Run database initialization (backend auto-creates tables)
3. Enable SSL connections (DATABASE_URL should use sslmode=require)

### Backend Deployment (Vercel, Heroku, Railway, etc.)
```bash
# Example: Vercel
npm install -g vercel
vercel --prod
```

### Frontend Deployment
```bash
# Build production bundle
npm run build

# Deploy to Vercel, Netlify, or static hosting
vercel deploy
```

## Security Checklist

- [x] Passwords hashed with bcryptjs
- [ ] Enable HTTPS in production
- [ ] Set JWT_SECRET to strong random value
- [ ] Configure CORS properly for production domain
- [ ] Use environment variables for all secrets
- [ ] Enable PostgreSQL SSL connections
- [ ] Regular database backups
- [ ] Input validation and sanitization (implemented)

## Debugging

Enable debug logging by setting in backend/.env:
```
DEBUG=* npm start
```

Or in frontend:
```
REACT_APP_DEBUG=true
```

## Support & Troubleshooting

1. **Check Logs**: Look at backend server logs and browser console (F12)
2. **Database**: Verify connection with `psql` command
3. **Network**: Use browser DevTools → Network tab to inspect API calls
4. **Clear Cache**: Run `npm cache clean --force` and clear browser cache

## Next Steps

1. Customize frontend branding and styling
2. Add authentication tokens (JWT recommended)
3. Setup admin dashboard features
4. Configure production email service
5. Setup continuous integration/deployment
