# Architecture

## Backend (ASP.NET Core 8)

### Layer Breakdown

```
Request → Controller → Service → DbContext → PostgreSQL
                ↑
           ICurrentUserService (extracts UserId from JWT claims)
```

- **Controllers** — HTTP routing, input binding, error wrapping (`try/catch → BadRequest`)
- **Services** — All business logic. Controllers delegate entirely to services.
- **AppDbContext** — EF Core context. All queries live in services, not controllers.
- **DTOs** — C# records used for API input/output. Models never leave the service layer.
- **Models** — EF Core entities. All inherit from `BaseEntity`.

### BaseEntity

Every model inherits:
```
Guid Id (PK)
DateTime CreatedAt
DateTime? UpdatedAt
Guid? CreatedBy / UpdatedBy / DeletedBy
bool IsDeleted
DateTime? DeletedAt
```

Global query filter on all DbSets: `.Where(e => !e.IsDeleted)` — soft delete is automatic.

### Authentication

- Passwords hashed with BCrypt (`BCrypt.Net-Next`)
- JWT issued on login/register with claims: `NameIdentifier` (UserId), `Email`, `Role`, `fullName`
- `ICurrentUserService` injected into all services — reads `UserId` from `IHttpContextAccessor`
- Role-based access: `[Authorize]` on all protected routes, no explicit `[Authorize(Roles="...")]` except admin checks done in service layer

### File Uploads

- Files stored at `wwwroot/uploads/` (or `uploads/` folder relative to app)
- Served as static files at `/uploads/**`
- Upload endpoint returns URL strings that are stored in DB

### Middleware Pipeline (Order Matters)

```csharp
UseSerilogRequestLogging()   // logs every HTTP request
UseRouting()                 // must be BEFORE UseCors
UseCors("AllowAll")          // wide open: any origin, method, header
UseHttpsRedirection()
UseStaticFiles()             // serves /uploads
// Swagger (dev only)
UseAuthentication()
UseAuthorization()
MapControllers()
```

> **Critical:** `UseRouting()` must be explicit and before `UseCors()`. Without it, CORS preflight (OPTIONS) returns 405 on web browsers.

### CORS

Policy `"AllowAll"`:
```csharp
AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()
```
No credentials/cookies — stateless JWT only.

### Logging

Serilog configured at startup:
- Console: `[HH:mm:ss LVL] Message`
- File: `logs/api-YYYYMMDD.log` (daily rolling, 30-day retention, 50MB per file)
- HTTP request logging via `UseSerilogRequestLogging()`
- Each controller has `ILogger<T>` injected for error logging

### Database

- PostgreSQL via `Npgsql.EntityFrameworkCore.PostgreSQL`
- `AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true)` — required for `DateTime` (non-UTC) compatibility
- Connection string key: `"Default"` in `appsettings.json`
- Migrations tracked in `Migrations/` folder

---

## Frontend (Flutter)

### Navigation

Uses `MaterialApp` with `onGenerateRoute` and named routes. Role-based entry point:

```dart
if (!loggedIn)  → /auth/login
if role=="shop" → /shop/dashboard   (ShopShell)
if role=="admin"→ /admin/dashboard  (AdminShell)
else            → /customer/home    (CustomerShell)
```

Each role has a `Shell` widget with a bottom `NavigationBar`.

### State Management

Single `AppProvider` (ChangeNotifier) via `provider` package. Holds all state for all roles.

Initialized on login via `AppProvider.initFromApi()`:
```dart
Future.wait([
  VehicleService.getMyVehicles() → vehicles
  ShopService.getShops()         → shops
  RequestService.getMyRequests() → requests
])
```

All API calls use `catchError((Object e) {...})` — single parameter to avoid Flutter web DDC StackTrace cast bug.

### API Client (`ApiClient`)

```dart
static Dio dio  // singleton

// Interceptors:
onRequest → reads token from FlutterSecureStorage, adds Authorization header
onResponse → logs response status
onError → logs error
```

Token and user info stored in `FlutterSecureStorage` under keys:
- `token`
- `role`
- `fullName`
- `userId`

### Platform Differences

- `flutter_secure_storage` works on both mobile and web
- Image upload uses `image_picker` (mobile) or `html.File` (web) — handled in `AppProvider`
- Sentry DSN injected via `--dart-define=SENTRY_DSN=...` or baked in as default value

### Service Layer Pattern

All services are static classes with static async methods:
```dart
class VehicleService {
  static Future<List<Vehicle>> getMyVehicles() async {
    final res = await ApiClient.dio.get('/api/vehicles');
    return (res.data as List).map((e) => Vehicle.fromJson(e)).toList();
  }
}
```

No repositories, no interfaces — direct Dio calls.

### Error Handling

- API errors: Dio throws `DioException`, caught in UI screens or AppProvider
- Sentry captures all uncaught errors via `FlutterError.onError` and `PlatformDispatcher.onError`
- `AppLogger` wraps Sentry and `debugPrint` calls

---

## Key Business Logic

### Request → Acceptance Flow

1. Customer creates `Request` → `RequestShop` rows created for each selected shop (status: Pending)
2. Shop sees request in `/api/requests/shop`
3. Shop calls `PUT /api/requests/{id}/accept` → `RequestShop.Status = Accepted`, `ChatRoom` auto-created
4. Customer and shop can now chat

### Quotation → Acceptance Flow

1. Shop sends quotation via `POST /api/quotations`
2. Customer views quotations for their request
3. Customer accepts one → all other quotations for that request auto-rejected → `Request.Status = Active`

### Shop Rating

Calculated automatically in `ReviewService.UpdateShopRatingAsync()` after each review:
```
averageRating = AVG(qualityRating + communicationRating + commitmentRating + generalRating) / 4
shop.Rating = averageRating
shop.TotalJobs++
```
