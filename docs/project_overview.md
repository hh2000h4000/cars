# Project Overview — Zina Cars (زينة كارز)

## What Is This?

A mobile + web platform connecting **car decoration/detailing shop owners** with **customers** who want their vehicles serviced. Customers post service requests, shops respond with quotations, and both parties chat to finalize the job.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile/Web App | Flutter (Dart) |
| Backend API | ASP.NET Core 8 (C#) |
| Database | PostgreSQL (via EF Core + Npgsql) |
| Auth | JWT Bearer tokens (BCrypt passwords) |
| Logging | Serilog (console + daily rolling file) |
| Error Tracking | Sentry Flutter |
| File Storage | Local disk (`/uploads` folder, served as static files) |

## User Types

### Customer
- Registers a personal account
- Adds vehicles to their profile
- Creates service requests targeting one or more shops
- Reviews quotations and accepts one
- Chats with the selected shop
- Leaves a review after job completion
- Can raise disputes

### Shop Owner
- Registers a shop account (requires admin approval)
- Receives incoming service requests
- Sends quotations to customers
- Chats with customers after being accepted
- Manages their store profile

### Admin
- Approves or rejects new shop registrations
- Views and manages all disputes
- Has access to admin dashboard

## Core User Flow

```
Customer creates request → selects shops → shops receive request
→ shops send quotations → customer accepts one quotation
→ ChatRoom opens automatically → job is completed
→ customer leaves review → shop rating updated
```

## Project Structure

```
repo/
├── api/                    # ASP.NET Core backend
│   └── CarDecoration.API/
│       └── CarDecoration.API/
│           ├── Controllers/
│           ├── Services/
│           ├── Models/
│           ├── DTOs/
│           ├── Data/
│           ├── Helpers/
│           ├── Migrations/
│           └── Program.cs
├── car_decoration_app/     # Flutter frontend
│   └── lib/
│       ├── screens/        # UI screens by role
│       ├── models/         # Dart data models
│       ├── services/       # API service layer
│       ├── providers/      # AppProvider (state)
│       ├── theme.dart      # Colors & theme
│       └── main.dart
├── project/                # HTML/CSS design prototypes
├── chats/                  # Design chat transcripts
└── docs/                   # This documentation
```

## Current Status (آخر تحديث: 2026-06-25)

| Feature | Status |
|---------|--------|
| Backend API | ✅ Running on PostgreSQL |
| Auth (register/login/JWT) | ✅ Working |
| Vehicles CRUD | ✅ Working — loads in Flutter app |
| Shops (listing/approval) | ✅ Working — loads in Flutter app |
| Requests CRUD | ✅ Working — loads in Flutter app |
| Quotations | ✅ Implemented |
| Chat | ✅ Implemented |
| Disputes | ✅ Implemented |
| Reviews | ✅ Implemented |
| File Upload | ✅ Local disk storage |
| Serilog Logging | ✅ Active |
| Sentry Error Tracking | ✅ Configured in Flutter |
| Flutter Web (Chrome) | ✅ Working |
| Flutter Mobile | ✅ Working |

## Language

- UI text: Arabic (RTL)
- Code/identifiers: English
- API error messages: Arabic strings
- Font: Tajawal (Google Fonts, Arabic-optimized, bundled locally)

## Running the Project

### Backend
```bash
cd api/CarDecoration.API/CarDecoration.API
dotnet run
# Listens on http://0.0.0.0:5053 and https://0.0.0.0:7209
```

### Flutter (Web)
```bash
cd car_decoration_app
flutter run -d chrome
# Connects to http://localhost:5053
```

### Flutter (Physical Device)
```bash
flutter run -d <device>
# Connects to http://192.168.8.11:5053
# Update ApiClient.baseUrl if IP changes
```

### Database Migrations
```bash
cd api/CarDecoration.API/CarDecoration.API
dotnet ef database update
```
