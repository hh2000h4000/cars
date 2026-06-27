# Tasks

## Done ✅

### Backend (جلسة 2026-06-26)
- [x] `ShopRequestResponse` enriched with `ShopStatus` + `ChatRoomId` fields (DTOs/RequestDtos.cs)
- [x] `GetShopRequestsAsync()` returns all statuses (not just Pending) + includes ChatRoom navigation
- [x] `MyShopResponse` DTO added (Id, Name, City, Rating, TotalJobs)
- [x] `GET /api/shops/my` endpoint — returns the authenticated shop owner's shop info
- [x] `senderRole` already present in `MessageResponse` — used by Flutter for isMe detection

### Backend
- [x] ASP.NET Core 8 project setup with PostgreSQL + EF Core
- [x] User auth: register (customer), register (shop), login — JWT tokens
- [x] Vehicles CRUD (create, read, update, soft delete)
- [x] Vehicle images (ordered list, stored as VehicleImage rows)
- [x] Shops: public listing (approved only, rated), admin approve/reject
- [x] Requests: create (multi-shop targeting), list (customer), list (shop), update, cancel
- [x] Request images
- [x] Shop acceptance of request → auto-creates ChatRoom
- [x] Quotations: shop sends, customer views, customer accepts (auto-rejects others)
- [x] Chat: send message, get chat room, get all chat rooms
- [x] Disputes: customer creates, admin views, admin updates status
- [x] Reviews: customer submits, shop rating auto-updated, public view
- [x] File upload (single + multiple, stored locally at /uploads)
- [x] Serilog logging (console + daily rolling file)
- [x] CORS AllowAll policy (OPTIONS preflight working correctly)
- [x] Soft delete with global query filters
- [x] `[HttpGet("my")]` route on RequestsController (fixes 405 bug)
- [x] `Color` field added to Vehicle model, VehicleService, migration
- [x] `MapInboundClaims = false` in JWT config (required for .NET 8 claim name mapping)
- [x] `CurrentUserService` tries multiple claim names: `NameIdentifier` → `sub` → `nameid`
- [x] HTTPS redirect disabled in Development (prevents 307 stripping Authorization header)
- [x] HTTP port 5053 added to `appsettings.json` Urls field
- [x] Migration `20260625000001_AddColorToVehicles` created and applied

### Flutter App (جلسة 2026-06-26)
- [x] `ShopRequest` model — full model with `ShopRequestShopStatus` enum, computed props: `mono`, `vehicleInfo`, `timeAgo`, `appointmentLabel`
- [x] `ShopRequestService` — `getShopRequests()` + `acceptRequest()` (returns chatRoomId)
- [x] `ShopRequestsScreen` rewritten — StatefulWidget, 3 tabs (جديدة / بانتظار العميل / قيد التنفيذ), refresh, error state
- [x] `ShopRequestDetailScreen` rewritten — accepts `ShopRequest` object, accept button calls API, chat button appears when chatRoomId available
- [x] `ShopChatsScreen` rewritten — loads from `ChatService.getChatRooms()`, shows customerName/mono
- [x] `ShopDashboardScreen` rewritten — real stats from `GET /api/shops/my` + `ShopRequestService`, real shop name
- [x] `SendQuoteScreen` rewritten — TextEditingControllers, warranty picker, parts list, calls `QuotationService.sendQuote()` via real API ✅
- [x] App routes updated: `/shop/request-detail` + `/shop/send-quote` now pass `ShopRequest` object
- [x] `ChatMessage.fromJson` updated — accepts `currentRole` param, uses `senderRole` for isMe detection (more reliable than GUID comparison)
- [x] `ChatService` updated — passes `currentRole` to `ChatMessage.fromJson` in both `getRoomDetail()` and `sendMessage()`
- [x] `ChatRoom` model updated — extracts `lastMessage`, `lastMessageTime`, `lastMessageAt`, `lastSenderRole` from embedded messages array
- [x] `ChatScreen` rewritten — `FocusNode` keeps cursor in field after send, 5s polling timer, WhatsApp-style `_MessageBubble` (my messages right/dark, other left/white), `textInputAction: TextInputAction.send`
- [x] `ChatsScreen` updated — unread badge (gold dot + bold) when other party sent after last visit; reloads on back-navigate from chat
- [x] `ShopChatsScreen` updated — same unread badge logic as ChatsScreen
- [x] `ApiClient` — added `writeData()` / `readData()` for generic SecureStorage access (used for chat lastReadAt tracking)

### Flutter App
- [x] Role-based routing (Customer / ShopOwner / Admin)
- [x] Auth screens: login, customer register, shop register, pending screen
- [x] Customer shell with 4 tabs
- [x] Shop shell with 4 tabs
- [x] Admin shell with 3 tabs
- [x] Vehicles screen: list, add, edit — loading from real API ✅
- [x] Requests screen: list, detail, create (multi-step), edit — loading from real API ✅
- [x] Shop browsing and profile screen — loading from real API ✅
- [x] Shop selection for new request
- [x] Quotation detail screen
- [x] Chat screen (customer ↔ shop)
- [x] Review screen
- [x] Complaint/dispute screen
- [x] Location picker screen (map)
- [x] AppProvider with real API calls (no mock data)
- [x] Mock data completely removed
- [x] Sentry error tracking configured
- [x] AppLogger wrapping Sentry + debugPrint
- [x] Dio interceptors: auth header, logging (with try/catch so handler.next() always runs)
- [x] `catchError((Object e) {...})` single-param pattern (fixes Flutter web DDC StackTrace cast bug)
- [x] Image upload via multipart
- [x] QuotationService endpoints corrected: GET `/api/quotations/request/{id}`, PUT `/api/quotations/{id}/accept`
- [x] ChatService endpoints corrected: GET `/api/chats`, GET `/api/chats/{id}`, POST `/api/chats/send`
- [x] Quotation model fields corrected: `finalPrice`, `duration`, `serviceDetails`, `shopName` (flat)
- [x] ChatMessage model field corrected: `text` (was `content`)
- [x] ApiClient baseUrl: HTTP port 5053 (web: `localhost`, device: `192.168.8.11`)

---

## قيد التنفيذ — تحسينات احترافية 🔧

### أولوية عالية 🔴
- [x] **JWT Refresh Token** — Access Token 15 دقيقة + Refresh Token 30 يوم مخزن في DB. Dio interceptor يجدد تلقائياً عند 401. Token rotation عند كل تجديد. تم: 2026-06-26
- [x] **Pagination** — Offset/Page (`?page=1&pageSize=20`, max 50). `PagedResult<T>` DTO. Endpoints: Shops، Requests (customer + shop). AppProvider يدعم `loadMoreRequests/loadMoreShops`. الشاشات: زر "تحميل المزيد" في RequestsScreen، ShopRequestsScreen، ShopSelectScreen. تم: 2026-06-26
- [x] **Workflow Audit & Fix (2026-06-26)** — RequestDetailScreen يحمّل العروض من API (لا mock). QuotationDetailScreen يستقبل Quotation object كاملاً. قبول العرض يستدعي API الحقيقي ويُرجع chatRoomId. الباكند يُنشئ ChatRoom تلقائياً عند قبول العرض إن لم تكن موجودة. status enum نُظِّف (حُذف draft/offers/shopSelected/scheduled/disputed). AppProvider نُظِّف من الكود الوهمي. تم: 2026-06-26
- [x] **Request Lifecycle Redesign (2026-06-27)** — إعادة تصميم دورة حياة الطلب بالكامل:
  - **Backend:** `RequestStatus` أصبح 6 حالات: `Open، ShopSelected، InProgress، Completed، Cancelled، Expired`. `QuotationStatus` أضيف `Withdrawn`. `RequestShopStatus` أضيف `Withdrawn`. إضافة `ViewedAt/RespondedAt/RejectedAt` على `RequestShop`. تغيير `ChatRoom` من 1-to-1 إلى 1-to-many (UNIQUE على `RequestId+ShopId` بدلاً من `RequestId` وحده). إضافة endpoint `PUT /api/requests/{id}/start` و `PUT /api/quotations/{id}/withdraw`. `AcceptRequestAsync` ينشئ ChatRoom مباشرة عند قبول المتجر (لا عند قبول العرض). `StartWorkAsync` → `InProgress`. `CompleteAsync` ← يتطلب `InProgress`.
  - **Flutter:** `RequestStatus` enum نُظِّف (6 حالات، labels عربية). `ShopRequestShopStatus` أضيف `withdrawn`. `Quotation` أضيف `withdrawn` + `Quotation.empty` sentinel. `ShopRequestDetailScreen` أعيد كتابته — state machine كامل للأزرار. `ReviewService` + `review_screen.dart` كُتبا من صفر بـ API حقيقي. `QuotationService.withdrawQuotation()` + `ShopRequestService.startWork/completeRequest()`.
  - **Migration:** `20260627000001_RequestLifecycleRedesign` مع data migration (Pending→Open, Active→ShopSelected) + إضافة الأعمدة الجديدة + تغيير الـ index.
  - **Fix:** إضافة Designer.cs الناقص للـ migration + تحديث AppDbContextModelSnapshot.cs.
  - **Fix:** إضافة حالة `withdrawn` في `_StatusBadge` switch في `ShopRequestsScreen`.

### أولوية متوسطة 🟡
- [ ] **FCM Push Notifications** — الإشعارات لا تصل عند إغلاق التطبيق. الحل: Firebase Cloud Messaging
- [ ] **Rate Limiting** — لا حماية من الـ brute force على `/auth/login`. الحل: ASP.NET Rate Limiting middleware

### أولوية لاحقة 🟠
- [ ] **Cloud Storage** — الصور على Local Disk تضيع عند إعادة النشر. الحل: Azure Blob / AWS S3
- [ ] **FluentValidation** — الـ validation متفرق يدوياً. الحل: FluentValidation مركزي

---

## Pending / Not Started ❌

### Backend
- [ ] Admin endpoint: list all users
- [ ] Admin endpoint: suspend/activate user
- [ ] Shop owner: edit their own shop profile
- [ ] Password reset / forgot password flow
- [ ] Email verification
- [ ] Input validation (no FluentValidation or DataAnnotations currently)

### Flutter App
- [ ] ShopMyStoreScreen — currently a placeholder ("قريباً")
- [ ] AdminDashboardScreen — stats/metrics (currently placeholder)
- [ ] Push notifications (no FCM integration)
- [ ] Profile/account settings screen
- [ ] Logout button visible in UI
- [ ] Password change screen
- [ ] Image upload progress indicator
- [ ] Offline mode / error retry UI
- [ ] Quotation detail from shop side (shop can see their sent quotations)

### Infrastructure
- [ ] Cloud deployment (server, domain, SSL)
- [ ] Cloud file storage (S3 or similar) to replace local `/uploads`
- [ ] CI/CD pipeline
- [ ] Database backups
- [ ] Production secrets management (not hardcoded JWT key)
- [ ] Restrict CORS to production domain (currently AllowAll)

---

## Known Bugs / Issues

| # | Description | Status |
|---|-------------|--------|
| 1 | ShopMyStoreScreen is placeholder | Known, deferred |
| 2 | ~~No pagination~~ | ✅ Fixed 2026-06-26 |
| 3 | ~~SendQuoteScreen doesn't call API~~ | ✅ Fixed 2026-06-26 |
| 4 | Files served from `/uploads` are lost if server is restarted or redeployed | Known, deferred (needs cloud storage) |
| 5 | ~~Quotation acceptance called local-only AppProvider method (hardcoded request ID '1042')~~ | ✅ Fixed 2026-06-26 |
| 6 | ~~Chat navigation after acceptance used hardcoded chatRoomId 'sh1'~~ | ✅ Fixed 2026-06-26 |
| 7 | ~~RequestDetailScreen loaded quotations from mock data only (hardcoded requestId '1042')~~ | ✅ Fixed 2026-06-26 |
