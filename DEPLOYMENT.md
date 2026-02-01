# Docker Deployment Guide - Skill Connect

## Pre-deployment Checklist

- [x] All MD files removed (except README.md)
- [x] Docker Compose version attribute removed
- [x] Backend Dockerfile fixed
- [x] Frontend Dockerfile fixed  
- [x] Backend .env configured for Docker
- [x] Frontend .env configured for Docker
- [x] All hardcoded API URLs replaced with environment variables
- [x] Database initialization scripts ready

## Project Structure Verification

```
skill-connect/
├── backend/
│   ├── Dockerfile (only one)
│   ├── .env
│   └── ... code files
├── frontend/
│   ├── Dockerfile (only one)
│   ├── .env
│   └── ... code files
├── docker-compose.yml (root level only)
└── README.md
```

## Getting Started - Docker

### Step 1: Verify Structure

Ensure you only have:
- `/backend/Dockerfile`
- `/frontend/Dockerfile`  
- `/docker-compose.yml` (root level)

### Step 2: Start Services

```bash
docker-compose up --build
```

Wait for all services to be healthy (3-5 minutes):
- PostgreSQL on :5432
- MinIO on :9000 and :9001
- Mailpit on :1025 and :8025
- Backend on :5000
- Frontend on :3000

### Step 3: Access Application

- Frontend: http://localhost:3000
- Backend: http://localhost:5000/api/users
- MinIO: http://localhost:9001
- Mailpit: http://localhost:8025

## Verification Steps

### 1. Test Signup

```bash
curl -X POST http://localhost:5000/api/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "fullName": "Test User",
    "password": "TestPassword123!",
    "status": "employed",
    "dob": "1990-01-01",
    "phone": "+1234567890"
  }'
```

Expected Response:
```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "email": "test@example.com",
    "fullName": "Test User"
  }
}
```

### 2. Check Database

```bash
docker exec skill_connect_postgres psql -U admin -d skill_connect_db \
  -c "SELECT email, fullname, status FROM users;"
```

### 3. Verify Password Hashing

```bash
docker exec skill_connect_postgres psql -U admin -d skill_connect_db \
  -c "SELECT email, password FROM users LIMIT 1;"
```

Password should start with `$2a$10$` (bcrypt hash)

### 4. Test Login

```bash
curl -X POST http://localhost:5000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPassword123!"
  }'
```

### 5. Frontend Test

1. Navigate to http://localhost:3000
2. Sign up with test credentials
3. Login
4. Check user dashboard
5. Upload a resume (PDF)

## Environment Variables

### Backend (.env)

```
NODE_ENV=development
PORT=5000
DB_HOST=postgres
DB_PORT=5432
DB_NAME=skill_connect_db
DB_USER=admin
DB_PASSWORD=admin123
MINIO_ENDPOINT=minio
MAILPIT_HOST=mailpit
JWT_SECRET=your_secret_key
```

### Frontend (.env)

```
REACT_APP_API_URL=http://backend:5000
REACT_APP_ENV=development
REACT_APP_DEBUG=true
```

## Troubleshooting

### Container won't start

```bash
# View logs
docker-compose logs backend
docker-compose logs frontend
docker-compose logs postgres

# Rebuild
docker-compose down -v
docker-compose up --build
```

### Database connection error

```bash
# Check PostgreSQL is running
docker ps | grep postgres

# Check logs
docker-compose logs postgres

# Reset database
docker-compose down -v
docker volume prune -a
docker-compose up --build
```

### Frontend can't connect to backend

1. Check frontend .env has `REACT_APP_API_URL=http://backend:5000`
2. Check backend is running: `docker ps`
3. Check Docker network: `docker network ls`
4. Clear browser cache: Ctrl+Shift+Delete
5. Restart frontend: `docker-compose restart frontend`

### Port already in use

```bash
# Kill process using port 5000
lsof -i :5000
kill -9 <PID>

# Or change port in docker-compose.yml
# Change "5000:5000" to "5001:5000"
```

## Production Deployment

### Before Going Live

1. Change JWT_SECRET in backend .env
2. Use production email service (SendPulse)
3. Configure HTTPS/SSL
4. Set up proper database backups
5. Configure MinIO for production storage
6. Update REACT_APP_API_URL to production domain

### Production Environment Variables

```bash
# Backend .env.production
NODE_ENV=production
SENDPULSE_USER=your_email@sendpulse.com
SENDPULSE_PASS=your_password
SENDPULSE_HOST=smtp.sendpulse.com
```

## Health Checks

All services have health checks configured:

- PostgreSQL: `pg_isready`
- MinIO: HTTP endpoint check
- Backend: Running (no explicit health endpoint yet)
- Frontend: Running

## Database Backups

```bash
# Backup database
docker exec skill_connect_postgres pg_dump -U admin \
  -d skill_connect_db > backup.sql

# Restore database
docker exec -i skill_connect_postgres psql -U admin \
  -d skill_connect_db < backup.sql
```

## Logs Monitoring

```bash
# View all logs
docker-compose logs -f

# View specific service
docker-compose logs -f backend

# View last 50 lines
docker-compose logs --tail=50
```

## System Requirements

- Docker 20.10+
- Docker Compose 1.29+
- 2GB RAM minimum
- 10GB disk space

## Success Indicators

- All 5 containers running: `docker ps`
- Frontend loads: http://localhost:3000
- Backend responds: `curl http://localhost:5000/api/users`
- Database has tables: `docker exec skill_connect_postgres psql -U admin -d skill_connect_db -c "\dt"`
- Can signup and login

## Next Steps

1. Test all features in user dashboard
2. Test admin dashboard
3. Upload test resumes
4. Send test messages
5. Configure backups
6. Set up monitoring
7. Plan scaling strategy

For support, check logs and refer to README.md for architecture details.
