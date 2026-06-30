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

### جلسة 2026-06-28 ✅

- [x] **ShopResubmitScreen — Full-Screen Integration:** استبدال `_ResubmitSheetContent` (bottom sheet ~350 سطر) بـ `ShopResubmitScreen` كاملة. `_openResubmitSheet()` تستخدم `Navigator.push` بدلاً من `showModalBottomSheet`. النتيجة المُرجَعة `ShopProfile` تُحدَّث المتجر مباشرةً.

- [x] **SignalR — Real-Time Shop Status (Backend):** `ShopService.cs` يُرسل `ShopStatusChanged` event عبر `IHubContext<ChatHub>` بعد كل تغيير في الحالة:
  - `ApproveShopAsync` → `{ status: "Approved", reason: null }`
  - `RejectShopAsync` → `{ status: "Rejected", reason: shop.RejectionReason }`
  - `SuspendShopAsync` → `{ status: "Suspended", reason: null }`
  - `RestoreShopAsync` → `{ status: "Approved", reason: null }`

- [x] **SignalR — Real-Time Shop Status (Flutter):** `SignalRService` يستمع لـ `ShopStatusChanged`. `ShopShell` يستقبل الحدث، يعرض `Dialog` مخصص لكل حالة (4 حالات بألوان مختلفة)، ينتقل لتبويب "متجري" عند Rejected/Suspended/DocsRequested. `AppLifecycle.resumed` كطبقة احتياطية تُعيد الاتصال.

- [x] **Bug Fix — Excessive API Calls on App Resume:** كان `WidgetsBindingObserver` مُضافاً في Shell + Dashboard + MyStore معاً → 5 استدعاءات متزامنة عند كل `AppLifecycle.resumed`. الحل: حذف `WidgetsBindingObserver` من `ShopDashboardScreen` و`ShopMyStoreScreen` تماماً. Shell وحده يتولى reconnect و badge refresh.

- [x] **ShopOwnerProvider — Single Source of Truth:** provider مركزي لبيانات `/api/shops/my`:
  - `ShopProfile.copyWith()` مُضاف بنمط sentinel للحقول nullable
  - `ShopOwnerProvider` (ChangeNotifier): `load()` / `applyStatusChange()` / `applyProfileUpdate()` / `clear()`
  - مسجَّل في `main.dart` عبر `MultiProvider`
  - `ShopShell` يستدعي `load()` مرة واحدة عند الإقلاع وعند resume
  - SignalR event → `applyStatusChange()` مباشرةً — صفر API calls إضافية
  - `ShopDashboardScreen`: حُذف استدعاء `/api/shops/my` المباشر، يقرأ من `context.watch<ShopOwnerProvider>()`
  - `ShopMyStoreScreen`: حُذفت `_shopStatusSub`، يقرأ من provider، `applyProfileUpdate()` بعد edit/resubmit

### أولوية عالية 🔴
- [x] **JWT Refresh Token** — Access Token 15 دقيقة + Refresh Token 30 يوم مخزن في DB. Dio interceptor يجدد تلقائياً عند 401. Token rotation عند كل تجديد. تم: 2026-06-26
- [x] **Pagination** — Offset/Page (`?page=1&pageSize=20`, max 50). `PagedResult<T>` DTO. Endpoints: Shops، Requests (customer + shop). AppProvider يدعم `loadMoreRequests/loadMoreShops`. الشاشات: زر "تحميل المزيد" في RequestsScreen، ShopRequestsScreen، ShopSelectScreen. تم: 2026-06-26
- [x] **Workflow Audit & Fix (2026-06-26)** — RequestDetailScreen يحمّل العروض من API (لا mock). QuotationDetailScreen يستقبل Quotation object كاملاً. قبول العرض يستدعي API الحقيقي ويُرجع chatRoomId. الباكند يُنشئ ChatRoom تلقائياً عند قبول العرض إن لم تكن موجودة. status enum نُظِّف (حُذف draft/offers/shopSelected/scheduled/disputed). AppProvider نُظِّف من الكود الوهمي. تم: 2026-06-26
- [x] **Request Lifecycle Redesign (2026-06-27)** — إعادة تصميم دورة حياة الطلب بالكامل:
- [x] **Shop Registration System Overhaul (2026-06-27)** — نظام تسجيل المتاجر المحترف:
  - **Backend:** إضافة حقول `IdNumber`, `CrDocumentUrl`, `IdDocumentUrl` على نموذج `Shop`. تحقق من رقم الجوال السعودي (05XXXXXXXX) ورقم السجل التجاري (10 أرقام). Migration `20260627000002_AddShopDocumentFields` + Designer.cs.
  - **Flutter:** تحديث `ShopRegisterScreen` بـ `file_picker` — يفتح الملفات، يرفعها عبر `/api/upload/document` (anonymous)، ويخزّن URL في نموذج التسجيل. حقول: صورة الهوية الوطنية + السجل التجاري إلزامية.
  - **Backend Upload:** Endpoint جديد `POST /api/upload/document` بدون مصادقة (لأن المتجر لم يُسجَّل بعد).
- [x] **Admin Shop Approval System (2026-06-27)** — نظام اعتماد المتاجر الكامل:
  - **Backend:** إضافة `Suspended` لـ `ShopStatus` enum (كقيمة نصية في PostgreSQL — لا migration مطلوب). إضافة حقل `RejectionReason` (nullable text) مع migration `20260627000003_AddShopRejectionReason`. إضافة endpoint `GET /api/shops/admin/all` (يدعم `?status=&search=`). تحديث `PUT /{id}/reject` ليقبل body `{ reason }`. إضافة `PUT /{id}/suspend`.
  - **Flutter:** إعادة كتابة `AdminPendingScreen` بالكامل: 5 تبويبات (الكل/بانتظار/معتمد/مرفوض/موقوف) مع عداد حي لكل حالة. شريط بحث مع clear button. Bottom sheet لتحديد سبب الرفض (4 أسباب جاهزة + نص حر). `_ActionBar` widget يتكيف حسب الحالة (اعتماد/رفض/تعليق/استعادة). عرض سبب الرفض في صندوق أحمر.
  - **Flutter Dashboard:** `ShopDashboardScreen` يقرأ `status` و`rejectionReason` من API. `_StatusBadge` widget يعرض 5 حالات مختلفة: Approved (أخضر) / Rejected (أحمر + سبب) / Suspended (بنفسجي) / DocsRequested (أزرق) / Pending (برتقالي). زر الفتح/الإغلاق مخفي إذا لم يكن المتجر Approved.
- [x] **Bug Fix: Shop Dashboard Status Badge (2026-06-27)** — كان السطر 124 في `shop_dashboard_screen.dart` يعرض نص ثابت "متجر معتمد · متاح للطلبات" لجميع المتاجر بغض النظر عن الحالة الحقيقية. تم الإصلاح بربطه بـ `shopData['status']` من API.
- [x] **Bug Fix: Admin Dashboard Compile Error (2026-06-27)** — `admin_dashboard_screen.dart` كان يستدعي `ShopAdminService.getPendingShops()` بعد إعادة تسمية الدالة. تم الإصلاح إلى `getAllShops(status: 'Pending')`.
- [x] **Migration Fixes (2026-06-27)** — إنشاء `20260627000002_AddShopDocumentFields.Designer.cs` الناقص (كان سبب عدم اكتشاف EF Core للـ migration). إنشاء migration + Designer كاملَين لـ `20260627000003_AddShopRejectionReason`. تحديث `AppDbContextModelSnapshot.cs` بحقل `RejectionReason`.
- [x] **Request Lifecycle Redesign (2026-06-27)** — إعادة تصميم دورة حياة الطلب بالكامل:
  - **Backend:** `RequestStatus` أصبح 6 حالات: `Open، ShopSelected، InProgress، Completed، Cancelled، Expired`. `QuotationStatus` أضيف `Withdrawn`. `RequestShopStatus` أضيف `Withdrawn`. إضافة `ViewedAt/RespondedAt/RejectedAt` على `RequestShop`. تغيير `ChatRoom` من 1-to-1 إلى 1-to-many (UNIQUE على `RequestId+ShopId` بدلاً من `RequestId` وحده). إضافة endpoint `PUT /api/requests/{id}/start` و `PUT /api/quotations/{id}/withdraw`. `AcceptRequestAsync` ينشئ ChatRoom مباشرة عند قبول المتجر (لا عند قبول العرض). `StartWorkAsync` → `InProgress`. `CompleteAsync` ← يتطلب `InProgress`.
  - **Flutter:** `RequestStatus` enum نُظِّف (6 حالات، labels عربية). `ShopRequestShopStatus` أضيف `withdrawn`. `Quotation` أضيف `withdrawn` + `Quotation.empty` sentinel. `ShopRequestDetailScreen` أعيد كتابته — state machine كامل للأزرار. `ReviewService` + `review_screen.dart` كُتبا من صفر بـ API حقيقي. `QuotationService.withdrawQuotation()` + `ShopRequestService.startWork/completeRequest()`.
  - **Migration:** `20260627000001_RequestLifecycleRedesign` مع data migration (Pending→Open, Active→ShopSelected) + إضافة الأعمدة الجديدة + تغيير الـ index.
  - **Fix:** إضافة Designer.cs الناقص للـ migration + تحديث AppDbContextModelSnapshot.cs.
  - **Fix:** إضافة حالة `withdrawn` في `_StatusBadge` switch في `ShopRequestsScreen`.

### أولوية متوسطة 🟡
- [ ] **FCM Push Notifications** — الإشعارات لا تصل عند إغلاق التطبيق. الحل: Firebase Cloud Messaging
  - **الأحداث التي يجب أن تُطلق إشعاراً:**
    | الحدث | المُستَلِم | نص الإشعار (مقترح) |
    |-------|-----------|-------------------|
    | وصول طلب جديد لمتجر | ShopOwner | "طلب جديد من [اسم العميل] — اضغط للمراجعة" |
    | وصول عرض سعر جديد للعميل | Customer | "عرض سعر من [اسم المتجر] — [المبلغ] ريال" |
    | قبول العميل لعرض المتجر | ShopOwner | "قبل العميل عرضك — ابدأ التنسيق معه" |
    | إلغاء العميل للطلب | ShopOwner | "تم إلغاء الطلب من قِبَل العميل" |
    | إلغاء الاتفاق وإعادة فتح الطلب | ShopOwner | "ألغى العميل الاتفاق — الطلب مفتوح مجدداً" |
    | رسالة جديدة في المحادثة | الطرف الآخر | "رسالة من [الاسم]: [أول 50 حرف]" |
    | تغيير حالة المتجر (Admin) | ShopOwner | حسب الحالة — موجود عبر SignalR، يُضاف FCM احتياطياً |
  - **Backend:** يحتاج تخزين FCM Token لكل جهاز في DB + إرسال عبر Firebase Admin SDK
  - **Flutter:** `firebase_messaging` package + طلب إذن + تحديث Token عند login
- [ ] **Rate Limiting** — لا حماية من الـ brute force على `/auth/login`. الحل: ASP.NET Rate Limiting middleware

### أولوية لاحقة 🟠
- [ ] **Cloud Storage** — الصور على Local Disk تضيع عند إعادة النشر. الحل: Azure Blob / AWS S3
- [ ] **FluentValidation** — الـ validation متفرق يدوياً. الحل: FluentValidation مركزي

---

## Pending / Not Started ❌

### Backend
- [ ] Admin endpoint: list all users
- [ ] Admin endpoint: suspend/activate user
- [ ] Password reset / forgot password flow
- [ ] Email verification
- [ ] Input validation (no FluentValidation or DataAnnotations currently)

### Flutter App
- [x] ~~ShopMyStoreScreen — currently a placeholder~~ — مكتملة بالكامل: معلومات المتجر، تعديل الملف، إعادة التقديم، التقييمات، تسجيل الخروج ✅
- [ ] Quotation withdrawal UI — زر "سحب العرض" في واجهة المتجر (الـ service `withdrawQuotation()` موجود لكن UI غير مكتمل)
- [ ] Badge عدد الرسائل غير المقروءة على تاب المحادثات في bottom nav (مؤجل)
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

## Sprint Plan (متفق عليه 2026-06-30)

### Sprint 1 — 🔴 فوري
| # | المهمة | الملف |
|---|--------|-------|
| B1 | Crash: `provider.requests.first` على قائمة فارغة | `request_detail_screen.dart` |
| B2 | خطأ 400: UUID vs requestNumber في مسارات Navigation | بحث شامل في كل routes |
| B7 | API calls تتكرر بلا توقف — تحديد المصدر أولاً | ShopShell / CustomerShell |
| B6 | Badge المحادثات لا يختفي → إضافة `markAsRead` endpoint | Backend + ChatScreen |
| B8 | قائمة المتجر لا تتحدث بعد قبول الطلب → navigator result | ShopRequestsScreen |

### Sprint 2 — 🟠 مهم
| # | المهمة |
|---|--------|
| B4 | حذف زر مكرر من بطاقة طلب المتجر (إبقاء "عرض التفاصيل" فقط) |
| B5 | قائمة المحادثات لا تظهر الجديدة → On-Enter Fetch |

### Sprint 3 — 🟡 مستقبل (SignalR)
| # | الحدث | المُرسِل | المستقبل |
|---|-------|---------|---------|
| S1 | `RequestAccepted` | RequestService | CustomerShell → يُحدّث acceptedShops |
| S2 | `JobStarted` | RequestService | CustomerShell → يُحدّث request status |
| S3 | `JobCompleted` | RequestService | CustomerShell → يُحدّث request status |

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
| 8 | ~~Shop dashboard showed "متجر معتمد" badge for ALL shops regardless of actual status~~ | ✅ Fixed 2026-06-27 |
| 9 | ~~EF Core couldn't discover migration 20260627000002 (missing .Designer.cs file)~~ | ✅ Fixed 2026-06-27 |
| 10 | ~~admin_dashboard_screen.dart compile error: `getPendingShops` renamed to `getAllShops`~~ | ✅ Fixed 2026-06-27 |
| 11 | ~~Crash: `provider.requests.first` throws when list empty~~ | ✅ Fixed 2026-06-30 — null check + loading state |
| 12 | ~~`GET /api/reviews/request/1042` 400 error — app.dart fallback was `'1042'` not UUID~~ | ✅ Fixed 2026-06-30 — changed to `''` |
| 13 | API calls `/api/shops/my` + `/api/chats` on screen wake — expected behavior: `ShopShell.didChangeAppLifecycleState(resumed)` | ✅ Not a bug — documented in decisions.md |
| 14 | ~~Chat list doesn't show new chat after shop accepts~~ | ✅ Fixed 2026-06-30 — GlobalKey + `reload()` on tab tap |
| 15 | ~~Unread badge: `markAsRead` already implemented (ChatScreen._markAsRead → POST /api/chats/{id}/read)~~ | ✅ Already working — verified 2026-06-30 |
| 16 | ~~Shop request list doesn't update after accept~~ | ✅ Fixed 2026-06-30 — `.then((_) => _load())` in ShopRequestsScreen + ShopDashboardScreen |
| 17 | ~~Shop request card has 2 identical buttons~~ | ✅ Fixed 2026-06-30 — kept "عرض التفاصيل" + "فتح المحادثة" (when chatRoomId exists) |
| 18 | Shop acceptance not shown instantly to customer — needs SignalR `RequestAccepted` event | Sprint 3 |
| 19 | Job status changes (InProgress/Completed) not shown instantly to customer — customer sees update after navigating back | Sprint 3 — interim: `.then((_) => reloadRequests())` added |
