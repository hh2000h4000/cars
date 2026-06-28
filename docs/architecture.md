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
- JWT issued on login/register with claims: `sub` (UserId), `email`, `role`, `fullName`
- `MapInboundClaims = false` **must be set** in `AddJwtBearer` — without it, .NET 8 remaps `sub` to the long `ClaimTypes.NameIdentifier` URI which breaks claim lookup
- `ICurrentUserService` tries three claim names in order: `ClaimTypes.NameIdentifier` → `"sub"` → `"nameid"`
- Role-based access: `[Authorize]` on all protected routes; admin checks done in service layer

```csharp
// CurrentUserService.cs — resilient claim extraction
var idClaim = user?.FindFirstValue(ClaimTypes.NameIdentifier)
           ?? user?.FindFirstValue("sub")
           ?? user?.FindFirstValue("nameid");
```

### File Uploads

- Files stored at `uploads/` folder relative to app root (NOT `wwwroot`)
- Served as static files at `/uploads/**` via `UseStaticFiles` with `PhysicalFileProvider`
- Upload endpoint returns URL strings that are stored in DB

### Middleware Pipeline (Order Matters)

```csharp
UseSerilogRequestLogging()          // logs every HTTP request
UseRouting()                        // must be BEFORE UseCors
UseCors("AllowAll")                 // wide open: any origin, method, header
if (!IsDevelopment) UseHttpsRedirection()  // disabled in dev to avoid 307 stripping auth header
UseStaticFiles()                    // serves /uploads
// Swagger (dev only)
UseAuthentication()
UseAuthorization()
MapControllers()
```

> **Critical:** `UseRouting()` must be explicit and before `UseCors()`. Without it, CORS preflight (OPTIONS) returns 405 on web browsers.

> **Critical:** `UseHttpsRedirection()` must be wrapped in `if (!IsDevelopment())`. In dev, a 307 redirect from HTTP → HTTPS causes the browser to drop the `Authorization` header, resulting in 401 on all authenticated endpoints.

### CORS

Policy `"AllowAll"`:
```csharp
AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()
```
No credentials/cookies — stateless JWT only.

### Logging

Serilog configured at startup:
- Console: `[HH:mm:ss LVL] Message`
- File: `logs/api-YYYYMMDD.log` (daily rolling, 30-day retention)
- HTTP request logging via `UseSerilogRequestLogging()`
- Each controller has `ILogger<T>` injected for error logging

### Database

- PostgreSQL via `Npgsql.EntityFrameworkCore.PostgreSQL`
- `AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true)` — required for `DateTime` (non-UTC) compatibility; must be set **before** `WebApplication.CreateBuilder()`
- Connection string key: `"Default"` in `appsettings.json`
- API listens on: `http://0.0.0.0:5053` and `https://0.0.0.0:7209`
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

Two `ChangeNotifier` providers registered via `MultiProvider` in `main.dart`:

#### AppProvider (`providers/app_provider.dart`)
بيانات العميل — vehicles, shops, requests, reviews, complaints.

Initialized on login via `AppProvider.initFromApi()`:
```dart
Future.wait([
  VehicleService.getMyVehicles() → vehicles
  ShopService.getShops()         → shops
  RequestService.getMyRequests() → requests
])
```

#### ShopOwnerProvider (`providers/shop_owner_provider.dart`)
**Single Source of Truth** لبيانات ملف المتجر (`/api/shops/my`). المسؤولية: بيانات الملف الشخصي الأساسية فقط — لا طلبات، لا تقييمات، لا محادثات.

```dart
// Public API
load()                              // يستدعيها ShopShell فقط (مرة واحدة)
applyStatusChange(status, reason)  // تحديث من SignalR — صفر API calls
applyProfileUpdate(ShopProfile)    // بعد edit/resubmit ناجح
clear()                             // عند logout
```

**قواعد الاستخدام:**
- `ShopShell` يستدعي `load()` في `initState` (عبر `addPostFrameCallback`) وعند `AppLifecycle.resumed`
- SignalR event `ShopStatusChanged` → `applyStatusChange()` مباشرة، بدون API call
- `ShopDashboardScreen` و`ShopMyStoreScreen` يقرآن عبر `context.watch<ShopOwnerProvider>()`
- بعد تعديل الملف: `applyProfileUpdate(updated)` من نتيجة API — لا reload

All API calls use `catchError((Object e) {...})` — single parameter to avoid Flutter web DDC StackTrace cast bug.

### API Client (`ApiClient`)

```dart
static final String baseUrl = kIsWeb
    ? 'http://localhost:5053'        // Chrome on same machine
    : 'http://192.168.8.11:5053';   // physical device on LAN

// Interceptors:
onRequest → reads token from FlutterSecureStorage, adds Authorization header
onResponse → logs response status
onError → logs error with response body
```

Token and user info stored in `FlutterSecureStorage` under keys:
- `token`
- `role`
- `fullName`
- `email`

User ID is extracted by decoding the JWT payload directly (not stored separately):
```dart
static Future<String?> getUserId() async {
  // decodes token.split('.')[1] → base64url → JSON → map['sub']
}
```

### Platform Differences

- `flutter_secure_storage` works on both mobile and web (uses localStorage on web)
- Image upload uses `image_picker` (mobile) or `html.File` (web) — handled in `AppProvider`
- HTTPS certificate bypass (self-signed cert) applied on mobile/desktop only via `if (!kIsWeb) platform.setHttpClientAdapter(dio)`
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
2. Shop sees request in `GET /api/requests/shop`
3. Shop calls `PUT /api/requests/{id}/accept` → `RequestShop.Status = Accepted`, `ChatRoom` auto-created
4. Customer and shop can now chat

### Quotation → Acceptance Flow

1. Shop sends quotation via `POST /api/quotations`
2. Customer views quotations via `GET /api/quotations/request/{requestId}`
3. Customer accepts one via `PUT /api/quotations/{id}/accept` → all other quotations for that request auto-rejected → `Request.Status = Active`

### Shop Rating

Calculated automatically in `ReviewService.UpdateShopRatingAsync()` after each review:
```
averageRating = AVG(qualityRating + communicationRating + commitmentRating + generalRating) / 4
shop.Rating = averageRating
shop.TotalJobs++
```

### Real-Time Shop Status via SignalR

عند تغيير الـ Admin لحالة المتجر:

```
Admin → PUT /api/shops/{id}/approve|reject|suspend
      ↓
ShopService → SaveChangesAsync()
      ↓
IHubContext<ChatHub>.Clients.User(ownerId).SendAsync("ShopStatusChanged", { status, reason })
      ↓
Flutter SignalRService.onShopStatusChanged stream
      ↓
ShopShell._onShopStatusChanged()
  ├─ ShopOwnerProvider.applyStatusChange(status, reason)  → Dashboard + MyStore تُعاد البناء
  ├─ setState(_index = 3)  إذا كانت الحالة حرجة (Rejected/Suspended/DocsRequested)
  └─ _showStatusDialog()  → Dialog مناسب للحالة
```

**مبدأ مهم:** الـ event يحمل `{ status, reason }` — بيانات كافية للتحديث. لا يوجد API call إضافي.

### SignalR Connection Management

- `SignalRService` singleton — `withAutomaticReconnect()` مفعّل
- `ShopShell` هو **المسؤول الوحيد** عن:
  - استدعاء `connect()` عند الإقلاع
  - استدعاء `connect()` عند `AppLifecycle.resumed`
  - الاستماع لـ `onShopStatusChanged`
  - الاستماع لـ `onNotification` (badge الرسائل)
- الشاشات الفردية (Dashboard، MyStore) **لا تتصل بـ SignalR مباشرةً**
