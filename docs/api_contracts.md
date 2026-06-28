# API Contracts

Base URL:
- **Web (Chrome):** `http://localhost:5053`
- **Physical device:** `http://192.168.8.11:5053` (update IP if network changes)
- **HTTPS:** `https://localhost:7209` (not used in dev — causes 307 auth strip)

Auth: `Authorization: Bearer <JWT>` header on all protected routes (🔒)
Error format: `{ "message": "Arabic error string" }`

---

## Auth — `/api/auth`

### POST `/api/auth/register`
No auth required.
```json
Request:
{
  "fullName": "string",
  "phone": "string",
  "email": "string",
  "password": "string"
}

Response 200:
{
  "token": "string",
  "fullName": "string",
  "email": "string",
  "role": "Customer"
}
```

### POST `/api/auth/login`
No auth required.
```json
Request:
{
  "email": "string",
  "password": "string"
}

Response 200:
{
  "token": "string",
  "fullName": "string",
  "email": "string",
  "role": "Customer|ShopOwner|Admin"
}
```

### POST `/api/auth/shop/register`
No auth required.
```json
Request:
{
  "fullName": "string",
  "phone": "string",           // Saudi format: 05XXXXXXXX
  "email": "string",
  "password": "string",
  "shopName": "string",
  "crNumber": "string",        // 10-digit commercial registration number
  "city": "string",
  "shopPhone": "string",
  "idNumber": "string|null",
  "crDocumentUrl": "string|null",   // URL from POST /api/upload/document
  "idDocumentUrl": "string|null"    // URL from POST /api/upload/document
}

Response 200: AuthResponse (same as register)
Note: Shop created with Status=Pending, requires admin approval
```

---

## Vehicles — `/api/vehicles` 🔒

### GET `/api/vehicles`
Returns current user's vehicles.
```json
Response 200:
[
  {
    "id": "uuid",
    "brand": "string",
    "model": "string",
    "year": 2020,
    "color": "string|null",
    "plateNumber": "string|null",
    "imageUrls": ["string"],
    "createdAt": "ISO8601"
  }
]
```

### POST `/api/vehicles`
```json
Request:
{
  "brand": "string",
  "model": "string",
  "year": 2020,
  "color": "string|null",
  "plateNumber": "string|null",
  "imageUrls": ["string"] | null
}

Response 200: VehicleResponse (same shape as GET item)
```

### PUT `/api/vehicles/{id}`
```json
Request: same shape as POST
Response 200: VehicleResponse
```

### DELETE `/api/vehicles/{id}`
```json
Response 200: { "message": "تم حذف المركبة" }
```

---

## Shops — `/api/shops`

### GET `/api/shops`
Public — no auth required.
```json
Response 200:
[
  {
    "id": "uuid",
    "name": "string",
    "city": "string",
    "phone": "string",
    "logoUrl": "string|null",
    "rating": 4.5,
    "totalJobs": 12,
    "status": "Approved"
  }
]
Note: Only Approved shops returned, ordered by rating DESC
```

### GET `/api/shops/{id}`
```json
Response 200:
{
  "id": "uuid",
  "name": "string",
  "city": "string",
  "phone": "string",
  "logoUrl": "string|null",
  "rating": 4.5,
  "totalJobs": 12,
  "status": "Approved",
  "reviews": [
    {
      "qualityRating": 5,
      "communicationRating": 4,
      "commitmentRating": 5,
      "generalRating": 5,
      "comment": "string|null",
      "createdAt": "ISO8601"
    }
  ]
}
```

### GET `/api/shops/my` 🔒 (ShopOwner)
Returns the authenticated shop owner's shop info.
```json
Response 200:
{
  "id": "uuid",
  "name": "string",
  "city": "string",
  "phone": "string",
  "logoUrl": "string|null",
  "status": "Pending|Approved|Rejected|DocsRequested|Suspended",
  "crNumber": "string",
  "rating": 4.5,
  "totalJobs": 12,
  "rejectionReason": "string|null"
}
```

### GET `/api/shops/admin/all` 🔒 (Admin)
Returns all shops with optional status filter and search. Replaces the old `/api/shops/pending`.
```
Query params:
  status  = Pending|Approved|Rejected|DocsRequested|Suspended  (optional — omit for all)
  search  = string  (searches name, owner name, CR number)
  page    = int (default 1)
  pageSize = int (default 20, max 200)

Response 200: PagedResult<PendingShopResponse>
{
  "items": [
    {
      "id": "uuid",
      "name": "string",
      "ownerName": "string",
      "ownerPhone": "string",
      "city": "string",
      "phone": "string",
      "crNumber": "string",
      "idNumber": "string|null",
      "logoUrl": "string|null",
      "crDocumentUrl": "string|null",
      "idDocumentUrl": "string|null",
      "status": "string",
      "createdAt": "ISO8601",
      "rejectionReason": "string|null"
    }
  ],
  "total": 42,
  "page": 1,
  "pageSize": 200
}
```

### PUT `/api/shops/{id}/approve` 🔒 (Admin)
```json
Response 200: { "message": "تم اعتماد المتجر" }
Note: Also clears any previous rejectionReason
```

### PUT `/api/shops/{id}/reject` 🔒 (Admin)
```json
Request: { "reason": "string" }   // mandatory, cannot be empty
Response 200: { "message": "تم رفض المتجر" }
```

### PUT `/api/shops/{id}/suspend` 🔒 (Admin)
```json
Response 200: { "message": "تم تعليق المتجر" }
```

---

## Requests — `/api/requests` 🔒

### POST `/api/requests`
Customer creates a request targeting one or more shops.
```json
Request:
{
  "vehicleId": "uuid",
  "description": "string",
  "location": "string",
  "preferredDate": "ISO8601|null",
  "notes": "string|null",
  "shopIds": ["uuid"],
  "imageUrls": ["string"] | null
}

Response 200:
{
  "id": "uuid",
  "requestNumber": 1,
  "vehicleId": "uuid",
  "vehicleBrand": "string",
  "vehicleModel": "string",
  "vehicleYear": 2020,
  "vehicleColor": "string|null",
  "description": "string",
  "location": "string",
  "appointmentDate": "ISO8601|null",
  "notes": "string|null",
  "status": "Open|ShopSelected|InProgress|Completed|Cancelled|Expired",
  "shopNames": ["string"],
  "imageUrls": ["string"],
  "createdAt": "ISO8601"
}
```

### GET `/api/requests/my`
Returns current customer's requests.
```json
Response 200: [RequestResponse]
Note: Route must be declared BEFORE GET /api/requests/{id} in controller to avoid 405
```

### GET `/api/requests/shop`
Returns requests sent to the current user's shop.
```json
Response 200:
[
  {
    "id": "uuid",
    "customerId": "uuid",
    "customerName": "string",
    "vehicleBrand": "string",
    "vehicleModel": "string",
    "vehicleYear": 2020,
    "description": "string",
    "location": "string",
    "appointmentDate": "ISO8601|null",
    "status": "Pending",
    "createdAt": "ISO8601"
  }
]
```

### PUT `/api/requests/{id}/accept` 🔒 (ShopOwner)
Shop accepts a request → ChatRoom is auto-created.
```json
Response 200: { "message": "تم قبول الطلب وفتح المحادثة", "chatRoomId": "uuid" }
```

### PUT `/api/requests/{id}` 🔒 (Customer)
Customer edits request (only allowed when Status=Pending).
```json
Request:
{
  "description": "string",
  "location": "string",
  "preferredDate": "ISO8601|null",
  "notes": "string|null",
  "imageUrls": ["string"] | null
}

Response 200: RequestResponse
```

### DELETE `/api/requests/{id}` 🔒 (Customer)
Customer cancels request.
```json
Response 200: { "message": "تم إلغاء الطلب" }
```

---

## Quotations — `/api/quotations` 🔒

### POST `/api/quotations` (ShopOwner)
Shop sends quotation for a request.
```json
Request:
{
  "requestId": "uuid",
  "serviceDetails": "string",
  "parts": "string",
  "warranty": "string|null",
  "visitFee": 50.00,
  "duration": "string",
  "finalPrice": 500.00
}

Response 200:
{
  "id": "uuid",
  "requestId": "uuid",
  "shopId": "uuid",
  "shopName": "string",
  "serviceDetails": "string",
  "parts": "string",
  "warranty": "string|null",
  "visitFee": 50.00,
  "duration": "string",
  "finalPrice": 500.00,
  "status": "Pending",
  "createdAt": "ISO8601"
}
```

### GET `/api/quotations/request/{requestId}` (Customer)
Customer views all quotations for their request.
```json
Response 200: [QuotationResponse]
```

### PUT `/api/quotations/{id}/accept` (Customer)
Customer accepts a quotation. All other quotations for that request are auto-rejected. Request.Status → Active.
```json
Response 200: { "message": "تم قبول العرض" }
```

---

## Chats — `/api/chats` 🔒

### GET `/api/chats`
Returns all chat rooms for the current user (both customer and shop).
```json
Response 200:
[
  {
    "id": "uuid",
    "requestId": "uuid",
    "shopName": "string",
    "customerName": "string",
    "messages": [MessageResponse]
  }
]
```

### GET `/api/chats/{id}`
Returns a single chat room with all messages.
```json
Response 200: ChatRoomResponse (same shape as list item)
```

### POST `/api/chats/send`
```json
Request:
{
  "chatRoomId": "uuid",
  "text": "string|null",
  "attachments": ["string"] | null
}

Response 200:
{
  "id": "uuid",
  "senderId": "uuid",
  "senderName": "string",
  "senderRole": "Customer|ShopOwner",
  "text": "string|null",
  "attachments": ["string"],
  "sentAt": "ISO8601"
}
```

---

## Disputes — `/api/disputes` 🔒

### POST `/api/disputes` (Customer)
Customer raises a dispute.
```json
Request:
{
  "requestId": "uuid",
  "reason": "ServiceQuality|Pricing|Delay|Other",
  "details": "string",
  "evidence": ["string"] | null
}

Response 200:
{
  "id": "uuid",
  "requestId": "uuid",
  "customerName": "string",
  "shopName": "string",
  "reason": "string",
  "details": "string",
  "evidence": ["string"],
  "status": "UnderReview",
  "createdAt": "ISO8601"
}
```

### GET `/api/disputes/my` (Customer)
Customer's own disputes.
```json
Response 200: [DisputeResponse]
```

### GET `/api/disputes` 🔒 (Admin)
Admin views all disputes.
```json
Response 200: [DisputeResponse]
```

### PUT `/api/disputes/{id}/status` 🔒 (Admin)
Admin updates dispute status.
```json
Request: { "status": "UnderReview|WaitingShop|Resolved" }
Response 200: { "message": "تم تحديث حالة الشكوى" }
```

---

## Reviews — `/api/reviews` 🔒

### POST `/api/reviews` (Customer)
Customer submits review after job completion.
```json
Request:
{
  "requestId": "uuid",
  "qualityRating": 5,
  "communicationRating": 4,
  "commitmentRating": 5,
  "generalRating": 5,
  "comment": "string|null"
}

Response 200:
{
  "id": "uuid",
  "requestId": "uuid",
  "shopName": "string",
  "qualityRating": 5,
  "communicationRating": 4,
  "commitmentRating": 5,
  "generalRating": 5,
  "averageRating": 4.75,
  "comment": "string|null",
  "createdAt": "ISO8601"
}
```

### GET `/api/reviews/shop/{shopId}`
Public — no auth required.
```json
Response 200: [ReviewResponse]
```

---

## Upload — `/api/upload` 🔒

### POST `/api/upload`
Single file upload (multipart/form-data).
```
Form field: "file" (IFormFile)
Response 200: { "url": "/uploads/filename.ext" }
```

### POST `/api/upload/multiple`
Multiple file upload.
```
Form field: "files" (multiple IFormFile)
Response 200: { "urls": ["/uploads/file1.ext", "/uploads/file2.ext"] }
```

### POST `/api/upload/document`
**No auth required** — used during shop registration before the account is created.
```
Form field: "file" (IFormFile)
Response 200: { "url": "/uploads/filename.ext" }
```
