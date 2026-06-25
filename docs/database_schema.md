# Database Schema

Database: **PostgreSQL**
ORM: **Entity Framework Core 8** (Npgsql provider)
Soft delete: all tables filtered by `IsDeleted = false` globally

---

## Enums

```csharp
UserRole        : Customer, ShopOwner, Admin
UserStatus      : Active, Suspended
ShopStatus      : Pending, Approved, Rejected, DocsRequested
RequestStatus   : Pending, Active, Completed, Cancelled
RequestShopStatus : Pending, Accepted, Rejected
QuotationStatus : Pending, Accepted, Rejected
DisputeReason   : ServiceQuality, Pricing, Delay, Other
DisputeStatus   : UnderReview, WaitingShop, Resolved
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
| Role | int | UserRole enum |
| Status | int | UserStatus enum |
| CreatedAt | timestamp | |
| UpdatedAt | timestamp? | |
| IsDeleted | bool | default false |
| DeletedAt | timestamp? | |
| CreatedBy / UpdatedBy / DeletedBy | uuid? | audit |

### Shops
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| OwnerId | uuid FK → Users | |
| Name | text | |
| CrNumber | text | UNIQUE (commercial registration) |
| City | text | |
| Phone | text | |
| LogoUrl | text? | |
| Status | int | ShopStatus enum |
| Rating | float | default 0, auto-updated |
| TotalJobs | int | default 0, auto-updated |
| + BaseEntity columns | | |

### Vehicles
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| OwnerId | uuid FK → Users | |
| Brand | text | |
| Model | text | |
| Year | int | |
| Color | text? | |
| PlateNumber | text? | |
| + BaseEntity columns | | |

### VehicleImages
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| VehicleId | uuid FK → Vehicles | CASCADE DELETE |
| Url | text | |
| Order | int | display order |
| + BaseEntity columns | | |

### Requests
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| CustomerId | uuid FK → Users | |
| VehicleId | uuid FK → Vehicles | |
| Description | text | the service description |
| Location | text | |
| AppointmentDate | timestamp? | |
| Status | int | RequestStatus enum |
| SelectedShopId | uuid? FK → Shops | set after acceptance |
| Notes | text? | |
| RequestNumber | int | sequential per customer |
| + BaseEntity columns | | |

### RequestImages
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| RequestId | uuid FK → Requests | CASCADE DELETE |
| Url | text | |
| Order | int | |
| + BaseEntity columns | | |

### RequestShops (M:M join with status)
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| RequestId | uuid FK → Requests | UNIQUE together with ShopId |
| ShopId | uuid FK → Shops | UNIQUE together with RequestId |
| Status | int | RequestShopStatus enum |
| + BaseEntity columns | | |

### Quotations
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| RequestId | uuid FK → Requests | |
| ShopId | uuid FK → Shops | |
| ServiceDetails | text | |
| Parts | text | |
| Warranty | text? | |
| VisitFee | decimal(10,2) | |
| Duration | text | |
| FinalPrice | decimal(10,2) | |
| Status | int | QuotationStatus enum |
| + BaseEntity columns | | |

### ChatRooms
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| RequestId | uuid FK → Requests | |
| ShopId | uuid FK → Shops | |
| + BaseEntity columns | | |

### Messages
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| ChatRoomId | uuid FK → ChatRooms | |
| SenderId | uuid FK → Users | |
| Text | text? | |
| Attachments | jsonb | List\<string\> of URLs |
| + BaseEntity columns | | |

### Disputes
| Column | Type | Notes |
|--------|------|-------|
| Id | uuid PK | |
| RequestId | uuid FK → Requests | 1:1 |
| UserId | uuid FK → Users | who raised it |
| Reason | int | DisputeReason enum |
| Details | text | |
| Evidence | jsonb | List\<string\> of URLs |
| Status | int | DisputeStatus enum |
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
Request (1) ── (0..1) ChatRoom
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
| `20260623103329_AddNotesAndRequestNumber` | Added `Notes` and `RequestNumber` to Requests |

Run migrations: `dotnet ef database update`
