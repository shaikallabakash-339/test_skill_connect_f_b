# Docker Setup - Complete Implementation

## Files Modified/Created

### Deleted Files (Cleanup)
- ✅ All root level .md files except README.md
- ✅ All backend/ .md files except backend/README.md  
- ✅ backend/Dockerfile.frontend
- ✅ backend/docker-compose.yml
- ✅ backend/docker-compose.prod.yml

### Fixed Dockerfiles
- ✅ `/backend/Dockerfile` - Uses correct base image and runs npm install
- ✅ `/frontend/Dockerfile` - Uses alpine image for smaller size

### Fixed Docker Compose
- ✅ `/docker-compose.yml` - Removed version attribute (was "3.9")
- ✅ Backend service: `dockerfile: Dockerfile` (was `../Dockerfile`)
- ✅ Frontend service: `dockerfile: Dockerfile` (was `../Dockerfile.frontend`)
- ✅ Correct service names for Docker network communication

### Environment Variables
- ✅ `/backend/.env` - Updated for Docker (postgres, minio, mailpit as service names)
- ✅ `/frontend/.env` - Updated with `REACT_APP_API_URL=http://backend:5000`

### Frontend API Fixes (Environment Variables)
- ✅ `/frontend/src/pages/Signup.js` - Uses `process.env.REACT_APP_API_URL`
- ✅ `/frontend/src/pages/Login.js` - Already using env variable
- ✅ `/frontend/src/pages/UserDashboard.js` - All 8 axios calls use env variable
- ✅ `/frontend/src/pages/AdminDashboard.js` - All 8 axios calls use env variable

### Documentation Created
- ✅ `/README.md` - Complete project guide
- ✅ `/DEPLOYMENT.md` - Docker deployment instructions

## Docker Compose Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Docker Network                         │
│              (skill_connect_network)                     │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │  PostgreSQL  │  │    MinIO     │  │   Mailpit    │   │
│  │   (5432)     │  │ (9000,9001)  │  │(1025, 8025)  │   │
│  │   Service    │  │   Service    │  │   Service    │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
│         ↑                 ↑                    ↑          │
│         └─────────────────┼────────────────────┘          │
│                           │                              │
│                 ┌─────────▼──────────┐                   │
│                 │  Backend (5000)    │                   │
│                 │  Node.js API       │                   │
│                 └─────────▲──────────┘                   │
│                           │                              │
│                 ┌─────────▼──────────┐                   │
│                 │  Frontend (3000)   │                   │
│                 │  React SPA         │                   │
│                 └────────────────────┘                   │
│                                                           │
└─────────────────────────────────────────────────────────┘
         (Bridge Network: --net=bridge)
```

## Service Communication

### Frontend → Backend
- URL: `http://backend:5000` (inside Docker)
- Outside: `http://localhost:5000`

### Backend → Database
- Host: `postgres` (service name)
- Port: 5432
- Connection: `postgresql://admin:admin123@postgres:5432/skill_connect_db`

### Backend → MinIO
- Host: `minio` (service name)
- Port: 9000
- API URL: `http://minio:9000`

### Backend → Email
- Host: `mailpit` (service name)
- Port: 1025
- For testing only (use SendPulse for production)

## Quick Start Commands

### Build and Start
```bash
docker-compose up --build
```

### View Logs
```bash
docker-compose logs -f
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Stop Services
```bash
docker-compose down
```

### Clean Everything
```bash
docker-compose down -v
docker system prune -a
docker-compose up --build
```

### Access Services

```bash
# Frontend
http://localhost:3000

# Backend API
http://localhost:5000/api/users

# MinIO Console
http://localhost:9001
(minioadmin / minioadmin123)

# Mailpit
http://localhost:8025

# Database
docker exec -it skill_connect_postgres psql -U admin -d skill_connect_db
```

## Database Schema

Tables created automatically via init script:
- `users` - User accounts
- `resumes` - Resume uploads
- `messages` - User messages
- `donations` - Donation records
- `subscriptions` - Premium subscriptions

## Testing Workflow

### 1. Register User (Signup)
```bash
# Open frontend at http://localhost:3000
# Fill signup form
# Check database
docker exec skill_connect_postgres psql -U admin -d skill_connect_db \
  -c "SELECT email, fullname FROM users;"
```

### 2. Login User
```bash
# Enter credentials in login form
# Should redirect to user dashboard
# Check localStorage has user data
```

### 3. Upload Resume
```bash
# Go to user dashboard
# Upload PDF file
# Check MinIO console at http://localhost:9001
```

### 4. Test Admin
```bash
# Access admin login
# View user statistics
# Send message to users
# Check email in Mailpit
```

## Known Issues and Solutions

### Issue: "version" attribute is obsolete
**Solution**: Already fixed - removed version attribute from docker-compose.yml

### Issue: Dockerfile not found
**Solution**: Already fixed - corrected paths in docker-compose.yml services

### Issue: Frontend can't connect to backend
**Cause**: Wrong API URL  
**Solution**: Ensure `/frontend/.env` has `REACT_APP_API_URL=http://backend:5000`

### Issue: Database tables not created
**Cause**: init script not running  
**Solution**: Check init-db.sql exists in backend/scripts/

### Issue: Port conflicts
**Solution**: 
```bash
lsof -i :5000  # Check what's using port
kill -9 <PID>
```

## Volume Management

```yaml
# Data persistence
volumes:
  pgdata:      # PostgreSQL data
  minio_data:  # MinIO storage

# Mount paths
- ./backend:/app               # Backend code
- ./frontend/src:/app/src      # Frontend code  
- /app/node_modules            # Don't overwrite node_modules
```

## Network Isolation

Services communicate via Docker internal DNS:
- Container name = hostname inside network
- External port mapping for access outside Docker

Example:
- Inside Docker: `http://backend:5000`
- Outside Docker: `http://localhost:5000`

## Resource Limits (Optional)

Can be added to docker-compose.yml:
```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
```

## Monitoring

### Check all services running
```bash
docker-compose ps
```

### Check service health
```bash
docker-compose ps | grep healthy
```

### Check resource usage
```bash
docker stats
```

## Cleanup Procedures

### Remove stopped containers
```bash
docker container prune
```

### Remove unused images
```bash
docker image prune -a
```

### Remove unused volumes
```bash
docker volume prune
```

### Full reset
```bash
docker-compose down -v
rm -rf backend/node_modules frontend/node_modules
docker-compose up --build
```

## Security Notes

- Change JWT_SECRET before production
- Don't commit .env files with real credentials
- Use environment-specific .env files
- Enable HTTPS in production
- Set up authentication for MinIO
- Configure backup strategy

## Next Steps

1. Run `docker-compose up --build`
2. Test signup at http://localhost:3000
3. Verify database has user
4. Test login
5. Upload resume
6. Test admin functions
7. Deploy to production

## Success Checklist

- ✅ All containers running: `docker-compose ps`
- ✅ Frontend loads: `http://localhost:3000`
- ✅ Can signup: Form submits successfully
- ✅ Database created: User visible in psql
- ✅ Password hashed: Starts with `$2a$10$`
- ✅ Can login: Redirects to dashboard
- ✅ Admin works: Can send messages
- ✅ Emails work: Check Mailpit at 8025

Everything is ready for Docker deployment!
