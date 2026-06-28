# Database Schema

Database: **PostgreSQL**
ORM: **Entity Framework Core 8** (Npgsql provider)
Soft delete: all tables filtered by `IsDeleted = false` globally

---

## Enums

```csharp
UserRole          : Customer, ShopOwner, Admin
UserStatus        : Active, Suspended
ShopStatus        : Pending, Approved, Rejected, DocsRequested, Suspended   // stored as text — new values need no migration
RequestStatus     : Open, ShopSelected, InProgress, Completed, Cancelled, Expired
RequestShopStatus : Pending, Accepted, Rejected, Withdrawn
QuotationStatus   : Pending, Accepted, Rejected, Withdrawn
DisputeReason     : ServiceQuality, Pricing, Delay, Other
DisputeStatus     : UnderReview, WaitingShop, Resolved
```

---

## Tables

### Users
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| FullName | text | |
| Phone | text | UNIQUE |
| Email | text | UNIQUE, stored lowercase |
| PasswordHash | text | BCrypt |
| Role | text | UserRole enum |
| Status | text | UserStatus enum |
| CreatedAt | timestamp | |
| UpdatedAt | timestamp? | |
| IsDeleted | bool | default false |
| DeletedAt | timestamp? | |
| CreatedBy / UpdatedBy / DeletedBy | uuid? | audit |

### Shops
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| OwnerId | uuid FK → Users | UNIQUE (one shop per user) |
| Name | text | |
| CrNumber | text | UNIQUE (commercial registration, 10 digits) |
| City | text | |
| Phone | text | Saudi format: 05XXXXXXXX |
| LogoUrl | text? | |
| IdNumber | text? | National ID number of shop owner |
| CrDocumentUrl | text? | URL to uploaded CR document scan |
| IdDocumentUrl | text? | URL to uploaded ID document scan |
| RejectionReason | text? | Filled by admin when rejecting (added in migration 20260627000003) |
| Status | text | ShopStatus enum |
| Rating | float | default 0, auto-updated after review |
| TotalJobs | int | default 0, auto-updated after review |
| + BaseEntity columns | | |

### Vehicles
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| OwnerId | uuid FK → Users | |
| Brand | text | |
| Model | text | |
| Year | int | |
| Color | text? | nullable |
| PlateNumber | text? | nullable |
| + BaseEntity columns | | |

### VehicleImages
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| VehicleId | uuid FK → Vehicles | CASCADE DELETE |
| Url | text | |
| Order | int | display order |

### Requests
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| CustomerId | uuid FK → Users | |
| VehicleId | uuid FK → Vehicles | |
| Description | text | the service description |
| Location | text | |
| AppointmentDate | timestamp? | |
| Status | text | RequestStatus enum |
| SelectedShopId | uuid? FK → Shops | set after shop acceptance |
| Notes | text? | |
| RequestNumber | int | sequential per customer (1, 2, 3...) |
| + BaseEntity columns | | |

### RequestImages
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| RequestId | uuid FK → Requests | CASCADE DELETE |
| Url | text | |
| Order | int | |

### RequestShops (M:M join with status)
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| RequestId | uuid FK → Requests | UNIQUE together with ShopId |
| ShopId | uuid FK → Shops | UNIQUE together with RequestId |
| Status | text | RequestShopStatus enum |
| ViewedAt | timestamp? | when shop first viewed the request |
| RespondedAt | timestamp? | when shop accepted or rejected |
| RejectedAt | timestamp? | when shop explicitly rejected |
| + BaseEntity columns | | |

### Quotations
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| RequestId | uuid FK → Requests | |
| ShopId | uuid FK → Shops | |
| ServiceDetails | text | description of service |
| Parts | text | required parts |
| Warranty | text? | |
| VisitFee | decimal(10,2) | inspection fee |
| Duration | text | e.g. "3 أيام" |
| FinalPrice | decimal(10,2) | total price |
| Status | text | QuotationStatus enum |
| + BaseEntity columns | | |

### ChatRooms
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| RequestId | uuid FK → Requests | UNIQUE together with ShopId (one chat per request-shop pair) |
| ShopId | uuid FK → Shops | |
| LastReadCustomerAt | timestamp? | Customer's last read timestamp (for unread tracking) |
| LastReadShopOwnerAt | timestamp? | Shop owner's last read timestamp |
| + BaseEntity columns | | |

### Messages
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| ChatRoomId | uuid FK → ChatRooms | CASCADE DELETE |
| SenderId | uuid FK → Users | |
| Text | text? | nullable (message may be image-only) |
| Attachments | text | JSON array of URLs (serialized List\<string\>) |
| + BaseEntity columns | | |

### Disputes
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| RequestId | uuid FK → Requests | 1:1 |
| UserId | uuid FK → Users | who raised it |
| Reason | text | DisputeReason enum |
| Details | text | |
| Evidence | text | JSON array of URLs |
| Status | text | DisputeStatus enum |
| + BaseEntity columns | | |

### Reviews
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| RequestId | uuid FK → Requests | 1:1 |
| ShopId | uuid FK → Shops | |
| QualityRating | int | 1–5 |
| CommunicationRating | int | 1–5 |
| CommitmentRating | int | 1–5 |
| GeneralRating | int | 1–5 |
| Comment | text? | |
| + BaseEntity columns | | |

---

## Key Relationships

```
User (1) ──── (many) Vehicle
User (1) ──── (many) Request  (as Customer)
User (1) ──── (0..1) Shop     (as ShopOwner)

Request (1) ── (many) RequestShop ── (many) Shop   [M:M with status]
Request (1) ── (many) RequestImage
Request (1) ── (many) Quotation
Request (1) ── (many) ChatRoom   [one per request-shop pair, UNIQUE on RequestId+ShopId]
Request (1) ── (0..1) Dispute
Request (1) ── (0..1) Review

Vehicle (1) ── (many) VehicleImage   [cascade delete]

ChatRoom (1) ── (many) Message
```

---

## Migrations

| Migration | Description |
|-----------|-------------|
| `20260622070949_InitialCreate` | Full initial schema |
| `20260623103329_AddNotesAndRequestNumber` | Added `Notes` and `RequestNumber` to Requests; converted timestamps to `timestamp without time zone` |
| `20260625000001_AddColorToVehicles` | Added `Color` column to Vehicles (was missing from initial migration despite being in model) |
| `20260627000001_RequestLifecycleRedesign` | RequestStatus redesign (6 states), ChatRoom UNIQUE index changed to (RequestId+ShopId), added ViewedAt/RespondedAt/RejectedAt to RequestShop, LastReadCustomerAt/LastReadShopOwnerAt to ChatRoom, QuotationStatus.Withdrawn, data migration (Pending→Open, Active→ShopSelected) |
| `20260627000002_AddShopDocumentFields` | Added `IdNumber`, `CrDocumentUrl`, `IdDocumentUrl` to Shops (also created missing `.Designer.cs` file) |
| `20260627000003_AddShopRejectionReason` | Added `RejectionReason` (nullable text) to Shops |

Apply: `dotnet ef database update`
