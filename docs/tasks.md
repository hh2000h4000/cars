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

## Pending / Not Started ❌

### Backend
- [ ] Pagination on all list endpoints (currently returns all rows)
- [ ] Push notifications (no real-time, no WebSockets, no SignalR)
- [ ] Admin endpoint: list all users
- [ ] Admin endpoint: suspend/activate user
- [ ] Shop owner: edit their own shop profile
- [ ] Password reset / forgot password flow
- [ ] Email verification
- [ ] Cloud file storage (currently local disk — files lost on server restart/redeploy)
- [ ] Rate limiting / throttling
- [ ] Input validation (no FluentValidation or DataAnnotations currently)

### Flutter App
- [ ] ShopMyStoreScreen — currently a placeholder ("قريباً")
- [ ] AdminDashboardScreen — stats/metrics (currently placeholder)
- [ ] Real-time chat (حالياً polling كل 5 ثوانٍ — يمكن ترقيته لـ SignalR/WebSocket لاحقاً)
- [ ] Push notifications (no FCM integration)
- [ ] Profile/account settings screen
- [ ] Logout button visible in UI
- [ ] Password change screen
- [ ] Image upload progress indicator
- [ ] Offline mode / error retry UI
- [ ] Quotation detail from shop side (shop can see their sent quotations)
- [ ] SendQuoteScreen — ✅ تم ربطه بالـ API في جلسة 2026-06-26

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
| 2 | No pagination — large datasets will be slow | Known, deferred |
| 3 | ~~SendQuoteScreen doesn't call API~~ | ✅ Fixed 2026-06-26 |
| 4 | Files served from `/uploads` are lost if server is restarted or redeployed | Known, deferred (needs cloud storage) |
