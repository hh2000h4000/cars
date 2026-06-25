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

## Current Status

- Backend API: functional, running on PostgreSQL
- Flutter app: functional on mobile and Chrome web
- Auth: working (register, login, JWT)
- Vehicles: CRUD working
- Shops: listing and approval working
- Requests: CRUD working (405 bug was fixed by adding `[HttpGet("my")]`)
- Quotations: implemented
- Chat: implemented
- Disputes: implemented
- Reviews: implemented
- Upload: implemented (local disk storage)
- Serilog logging: active
- Sentry error tracking: configured in Flutter

## Language

- UI text: Arabic (RTL)
- Code/identifiers: English
- API error messages: Arabic strings
- Font: Tajawal (Google Fonts, Arabic-optimized)
