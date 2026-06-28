# Decisions

Technical decisions made during development, with rationale.

---

## Architecture

### Single AppProvider for all state (customer/admin only)
**Decision:** One `ChangeNotifier` class (`AppProvider`) holds all state for customer and admin roles. Shop owner data is handled separately in `ShopOwnerProvider`.
**Why:** Simple to implement for a project of this scale. Avoids setting up Riverpod/Bloc infrastructure.
**Trade-off:** Provider grows large. Separating into VehicleProvider, RequestProvider, etc. would be cleaner at scale but is premature here.

### ShopOwnerProvider — Single Source of Truth for shop profile (2026-06-28)
**Decision:** بيانات `/api/shops/my` مُركَّزة في `ShopOwnerProvider` (ChangeNotifier منفصل). الشاشات تقرأ منه عبر `context.watch<>()`. `ShopShell` هو المسؤول الوحيد عن استدعاء `load()`.
**Why:**
- كانت `ShopDashboardScreen` و`ShopMyStoreScreen` كل منهما تستدعي `/api/shops/my` باستقلالية → استدعاءان متزامنان عند كل إقلاع
- عند `AppLifecycle.resumed` مع وجود `WidgetsBindingObserver` في الشاشتين → 5 استدعاءات متزامنة
- الـ SignalR event كان يستدعي `_load()` في كلتا الشاشتين → استدعاءان إضافيان عند كل تغيير حالة
**Result:** استدعاء واحد فقط عند الإقلاع، صفر استدعاءات عند SignalR event.
**Scope constraint:** Provider يخزّن بيانات الملف الشخصي فقط — لا طلبات، لا تقييمات، لا محادثات. هذه تُحمَّل بشكل مستقل في كل شاشة تحتاجها.

### ShopProfile.copyWith() بنمط sentinel للحقول nullable (2026-06-28)
**Decision:** استخدام `const Object _sentinel = Object()` كقيمة افتراضية لمعاملات `copyWith()` الخاصة بالحقول nullable.
**Why:** الأسلوب المعتاد `String? field` لا يميّز بين "المستخدم لم يمرر القيمة" و"المستخدم مرر null". مع sentinel:
```dart
// لم يُمرَّر → يبقى القديم
_shop!.copyWith(status: 'Approved')
// مُمرَّر بشكل صريح null → يُصفَّر
_shop!.copyWith(status: 'Approved', rejectionReason: null)
```
**Context:** مطلوب في `applyStatusChange()` لأن حالة `Approved` يجب أن تصفّر `rejectionReason`.

### SignalR push بدلاً من polling لتحديث حالة المتجر (2026-06-28)
**Decision:** Backend يرسل `ShopStatusChanged` event عبر SignalR عند كل تغيير حالة. Flutter تحدّث الـ Provider مباشرةً من payload الحدث — بدون API call.
**Why:** Polling يعني:
- تأخير في الإشعار (بين دورات الـ timer)
- استنزاف البطارية والشبكة
- ضغط على الـ backend (N مستخدم × X ثانية = M طلب/ثانية)
SignalR push: فوري، صفر overhead على التطبيق بين الأحداث.
**Payload sufficiency:** الـ event يحمل `{ status, reason }` — هذا كافٍ لتحديث الواجهة الكاملة بدون API call إضافي.
**Fallback:** `AppLifecycle.resumed` يستدعي `provider.load()` كطبقة احتياطية إذا فُقد الاتصال.

### WidgetsBindingObserver في Shell فقط — لا في الشاشات الفردية (2026-06-28)
**Decision:** `WidgetsBindingObserver` مُسجَّل في `ShopShell` فقط. الشاشات الفردية (Dashboard، MyStore) لا تسجّله.
**Why:** `IndexedStack` يُبقي جميع الشاشات حيّةً دائماً (لا `dispose`). إذا سجّلت كل شاشة `WidgetsBindingObserver`، فكل شاشة ستتلقى `didChangeAppLifecycleState` بشكل مستقل → استدعاءات API متزامنة.
**Pattern:** Shell = lifecycle owner → delegates to Provider. Screens = passive consumers.

### ShopResubmitScreen — Full-Screen بدلاً من Bottom Sheet (2026-06-28)
**Decision:** استبدال `_ResubmitSheetContent` (Bottom Sheet) بـ `ShopResubmitScreen` (شاشة كاملة عبر `Navigator.push`).
**Why:** نموذج إعادة التقديم طويل (8+ حقول + رفع مستندات + map picker). Bottom Sheet محدود الارتفاع ويتعارض مع keyboard على الأجهزة الصغيرة. Full-screen يُتيح UX أفضل وscroll طبيعي.
**Data flow:** الشاشة تُرجع `ShopProfile` محدثاً عبر `Navigator.pop(updated)`. المتصل يستدعي `ShopOwnerProvider.applyProfileUpdate(updated)`.

### Static service classes
**Decision:** All Flutter services (`VehicleService`, `RequestService`, etc.) are classes with static methods — no instances, no dependency injection.
**Why:** Simple. No need for `get_it` or similar at this stage.
**Trade-off:** Hard to mock for unit tests. Acceptable given no test suite exists.

### Named routes with `onGenerateRoute` (not go_router)
**Decision:** `MaterialApp.onGenerateRoute` is used for navigation even though `go_router` is in pubspec.
**Why:** go_router was added but not adopted. The named route pattern is sufficient.
**Trade-off:** go_router offers deep linking and web URL support. Can migrate later.

---

## Backend

### Pagination: Offset/Page بدلاً من Cursor-based (2026-06-26)
**القرار:** `?page=1&pageSize=20` مع response يحتوي `items`, `totalCount`, `totalPages`, `hasNextPage`.
**لماذا Offset وليس Cursor:** البيانات ليست بمليارات السجلات. Cursor أفضل أداءً مع OFFSET كبير جداً، لكن التعقيد الزائد لا يستحق في هذه المرحلة.
**متى نتحول لـ Cursor:** عند تجاوز مليون سجل في جدول أو ظهور بطء واضح في الصفحات المتأخرة.
**Endpoints المطبق عليها:** `GET /api/shops`, `GET /api/requests`, `GET /api/requests/shop`, `GET /api/disputes`
**Flutter:** زر "تحميل المزيد" (Load More) — لا infinite scroll لتجنب تعقيد إدارة الـ state.

### Soft delete everywhere
**Decision:** No `DELETE` SQL — all entities have `IsDeleted` flag. EF Core global query filters hide deleted records.
**Why:** Preserves data integrity, allows recovery, audit trail via `DeletedAt`/`DeletedBy`.
**Trade-off:** Queries slightly heavier; must remember to call `IgnoreQueryFilters()` when admin needs to see deleted records.

### Services own all business logic, controllers just route
**Decision:** Controllers only parse HTTP input, call one service method, and return a result. No business logic in controllers.
**Why:** Testable, readable, standard ASP.NET pattern.

### RequestShop join table (M:M with status)
**Decision:** A `RequestShop` entity (not a simple EF join) tracks the status of each shop's response to a request.
**Why:** A request can be sent to multiple shops simultaneously, and each shop independently accepts or rejects. A simple M:M wouldn't track per-shop status.

### Auto-create ChatRoom on shop acceptance
**Decision:** When shop calls `PUT /api/requests/{id}/accept`, a `ChatRoom` is automatically created.
**Why:** Reduces client complexity. The shop's acceptance is the trigger for communication — no separate "create chat" step needed.

### Auto-reject competing quotations on acceptance
**Decision:** When customer calls `PUT /api/quotations/{id}/accept`, all other quotations for that request are automatically rejected.
**Why:** Business rule — a customer can only work with one shop per request. Automating this prevents inconsistent states.

### Local file storage for uploads
**Decision:** Uploaded files stored at `uploads/` on the server's disk (not `wwwroot/`), served via `PhysicalFileProvider`.
**Why:** Fastest to implement. No external service dependency for development.
**Trade-off:** Files lost if server is redeployed or disk is wiped. Must migrate to S3/cloud before production.

### CORS AllowAll policy
**Decision:** `AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()` for all endpoints.
**Why:** Simplest solution during development. Flutter web (Chrome) requires CORS headers.
**Trade-off:** Not suitable for production — should restrict to actual domain.

### `UseRouting()` explicit before `UseCors()`
**Decision:** `app.UseRouting()` is explicitly called before `app.UseCors("AllowAll")`.
**Why:** Without explicit `UseRouting()`, ASP.NET Core routes OPTIONS preflight requests to a 405 handler before CORS middleware can respond. This was causing 405 errors on all Flutter web API calls.

### `UseHttpsRedirection()` disabled in Development
**Decision:** `if (!app.Environment.IsDevelopment()) app.UseHttpsRedirection()`
**Why:** In development, the API runs on HTTP port 5053. When HTTPS redirect was always active, a 307 redirect from HTTP → HTTPS caused browsers to strip the `Authorization` header, resulting in 401 on every authenticated endpoint. Disabling it in dev keeps the flow on HTTP throughout.
**Production:** Re-enabled (the condition ensures it's on in staging/production).

### `MapInboundClaims = false` in JWT config
**Decision:** `options.MapInboundClaims = false` is set in `AddJwtBearer`.
**Why:** .NET 8 default behavior remaps the `sub` JWT claim to the long URI `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier`. With `MapInboundClaims = false`, claim names stay as issued (`sub`, `role`, etc.), which is the standard JWT behavior.
**Impact:** `CurrentUserService` must try multiple claim names as a fallback: `ClaimTypes.NameIdentifier` → `"sub"` → `"nameid"`.

---

## Flutter

### `catchError((Object e) {...})` — single parameter
**Decision:** All `.catchError()` calls use a single `Object e` parameter, never `(e, st)`.
**Why:** Flutter web compiles with DDC (Dart Dev Compiler) which has a type system difference — the StackTrace cast `st as StackTrace?` throws a runtime error in web mode. Single-parameter form avoids the cast entirely.

### Sentry DSN baked in as default value
**Decision:** Sentry DSN is set as a `defaultValue` in `String.fromEnvironment('SENTRY_DSN', defaultValue: '...')`.
**Why:** Makes the app work out of the box without requiring `--dart-define`. Can be overridden in CI.
**Trade-off:** DSN is visible in source code. DSNs are not secret (they're client-side), so this is acceptable.

### Tajawal font bundled locally
**Decision:** Tajawal font files are bundled in `assets/fonts/` rather than using `google_fonts` package.
**Why:** Works offline, no network dependency, consistent rendering across platforms.

### ApiClient uses HTTP not HTTPS in dev
**Decision:** `baseUrl = 'http://localhost:5053'` (not HTTPS).
**Why:** Avoids the self-signed certificate issue on web (Chrome blocks self-signed certs). Mobile has the cert bypass workaround but web cannot use it.

---

## Database

### `AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true)`
**Decision:** Legacy timestamp behavior enabled for Npgsql.
**Why:** Npgsql 6+ changed how `DateTime` (non-UTC) values are handled. Without this switch, the app throws `InvalidCastException` when reading timestamps from PostgreSQL. The legacy behavior restores the old behavior that treats all timestamps as unspecified kind.
**Trade-off:** Should eventually migrate to UTC-aware timestamps throughout the app.

### Sequential `RequestNumber` per customer
**Decision:** Each customer's requests are numbered 1, 2, 3... independently.
**Why:** User-friendly display reference (e.g., "طلب #3") instead of exposing UUIDs in the UI.
**Implementation:** `COUNT(requests WHERE customerId == userId) + 1` at creation time.

### Manual migration for Color column
**Decision:** Created migration `20260625000001_AddColorToVehicles` manually rather than via `dotnet ef migrations add`.
**Why:** The `Color` property existed in the EF model and `AppDbContextModelSnapshot` but was never added to the migration files. The database was missing the column, causing `column v.Color does not exist` errors. A manual migration was the safest fix without dropping/recreating the database.

### ShopStatus stored as string — new enum values need no DB migration
**Decision:** EF Core stores `ShopStatus` as a `text` column (via `HasConversion<string>()`). Adding a new enum value (e.g. `Suspended`) requires only a C# code change, not a database migration.
**Why:** PostgreSQL text column accepts any string. If the column were stored as a PostgreSQL `enum` type, ALTER TYPE would be required. This trade-off was intentional.
**Impact:** If storing as int (the EF Core default for enums), adding new values changes existing int mappings — always use string storage for enums with growing value sets.

### Anonymous document upload endpoint
**Decision:** `POST /api/upload/document` is accessible without authentication.
**Why:** During shop registration, the owner must upload CR and ID documents as part of the registration form — but they don't have an account yet, so they have no JWT token. A separate anonymous endpoint solves the chicken-and-egg problem.
**Trade-off:** Anonymous upload endpoints can be abused for storage spam. Mitigations (rate limiting, file size cap, file type validation) should be added before production.

### Admin shop management endpoint redesign
**Decision:** Replaced `GET /api/shops/pending` (returned only Pending/Rejected shops) with `GET /api/shops/admin/all` supporting `?status=` and `?search=` filters.
**Why:** The admin needs to see all shops (Pending, Approved, Rejected, DocsRequested, Suspended) in one place and search by name/owner/CR. The old endpoint only covered the initial approval flow, making it impossible to manage approved shops or search.
**Flutter impact:** `ShopAdminService.getAllShops({String? status, String? search})` replaces `getPendingShops()`. The API response is `PagedResult<T>` — Flutter must read `res.data['items']`, not `res.data as List`.

### Shop registration validation rules
**Decision:** Backend validates Saudi phone format (starts with 05, 10 digits) and CR number (exactly 10 digits). Flutter also validates client-side before submission.
**Why:** Saudi-specific business rules. Without validation, garbage data enters the database and causes issues with admin review (can't verify documents against CRN).
**Future:** Add server-side validation via FluentValidation for all inputs (currently manual string checks).
