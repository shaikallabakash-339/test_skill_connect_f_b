# Skill Connect - Professional Networking Platform

A full-stack application for professional networking, skill sharing, and job connections.

## Project Structure

```
skill-connect/
├── backend/                 # Node.js Express backend API
│   ├── config/             # Database and utility configurations
│   ├── routes/             # API route handlers
│   ├── utils/              # Helper utilities (email, password, validation)
│   ├── middleware/         # Express middleware
│   ├── scripts/            # Database initialization scripts
│   ├── Dockerfile          # Backend Docker configuration
│   ├── package.json        # Backend dependencies
│   └── .env                # Backend environment variables
│
├── frontend/               # React.js frontend application
│   ├── src/
│   │   ├── pages/         # React page components
│   │   ├── components/    # Reusable components
│   │   └── services/      # API client service
│   ├── Dockerfile         # Frontend Docker configuration
│   ├── package.json       # Frontend dependencies
│   └── .env               # Frontend environment variables
│
├── docker-compose.yml     # Docker Compose orchestration
└── README.md              # This file
```

## Prerequisites

- Docker and Docker Compose installed
- Git installed

## Quick Start with Docker

### 1. Clone and Navigate to Project

```bash
cd skill-connect
```

### 2. Start All Services

```bash
docker-compose up --build
```

This will start:
- PostgreSQL database (port 5432)
- MinIO object storage (ports 9000, 9001)
- Mailpit email testing (ports 1025, 8025)
- Backend API (port 5000)
- Frontend React app (port 3000)

### 3. Access the Application

- Frontend: http://localhost:3000
- Backend API: http://localhost:5000
- MinIO Web UI: http://localhost:9001
- Mailpit Web UI: http://localhost:8025

### 4. Test Sign Up

1. Go to http://localhost:3000
2. Sign up with your details
3. Check PostgreSQL for stored data:

```bash
docker exec skill_connect_postgres psql -U admin -d skill_connect_db -c "SELECT email, fullname, status FROM users;"
```

## Services Overview

### PostgreSQL Database
- Container: `skill_connect_postgres`
- Port: 5432
- Database: `skill_connect_db`
- User: `admin`
- Password: `admin123`

### MinIO (S3-Compatible Storage)
- Container: `skill_connect_minio`
- API Port: 9000
- Web UI Port: 9001
- Access Key: `minioadmin`
- Secret Key: `minioadmin123`

### Mailpit (Email Testing)
- Container: `skill_connect_mailpit`
- SMTP Port: 1025
- Web UI Port: 8025

### Backend API
- Container: `skill_connect_backend`
- Port: 5000
- Entry: `node server.js`

### Frontend
- Container: `skill_connect_frontend`
- Port: 3000
- Entry: `npm start`

## Environment Variables

### Backend (.env)
Database, MinIO, Email, and Admin configurations are set in `/backend/.env`

### Frontend (.env)
API URL and app settings are in `/frontend/.env`

## Common Commands

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres
```

### Stop Services
```bash
docker-compose down
```

### Stop and Remove Data
```bash
docker-compose down -v
```

### Rebuild Images
```bash
docker-compose up --build
```

### Access Database
```bash
docker exec -it skill_connect_postgres psql -U admin -d skill_connect_db
```

## Troubleshooting

### Port Already in Use
If port 5000 or 3000 is in use:
```bash
# Find and kill process using port
lsof -i :5000
kill -9 <PID>
```

### Database Connection Failed
```bash
# Check PostgreSQL is running
docker ps | grep postgres

# Check logs
docker-compose logs postgres
```

### Frontend Can't Connect to Backend
- Ensure backend is running: `docker-compose logs backend`
- Check frontend .env has correct API URL
- Verify docker network: `docker network ls`

### Container Build Fails
```bash
# Clean rebuild
docker-compose down
docker system prune -a
docker-compose up --build
```

## API Endpoints

### Authentication
- `POST /signup` - Register new user
- `POST /login` - Login user
- `POST /forgot-password` - Reset password

### Users
- `GET /users` - Get all users
- `GET /user/:email` - Get user profile
- `PUT /user/:email` - Update user profile
- `GET /user-stats` - Get user statistics

### Resumes
- `POST /upload-resume` - Upload resume
- `GET /user-resume` - Get user resume
- `GET /resume-users` - List all resume users
- `DELETE /delete-resume` - Delete resume

## Key Features

- User authentication with password hashing (bcryptjs)
- User profile management
- Resume upload and storage
- Email notifications
- Admin dashboard
- Real-time messaging
- Subscription management

## Security

- Passwords hashed with bcryptjs
- Input validation and sanitization
- Environment variables for secrets
- Docker network isolation
- CORS enabled

## Database Schema

Tables include:
- `users` - User profiles
- `resumes` - Uploaded resumes
- `messages` - Admin messages
- `donations` - User donations
- `subscriptions` - Premium subscriptions

## Support

For issues or questions, check the logs:

```bash
docker-compose logs
```

## License

Copyright (c) 2025 Your Company Name. All rights reserved.
