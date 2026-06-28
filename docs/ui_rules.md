# UI Rules

## Language & Direction

- All user-visible text is **Arabic**
- Layout is **RTL** (`textDirection: TextDirection.rtl`)
- Font: **Tajawal** (custom, bundled in `assets/fonts/`)
  - Available weights: 300 (Light), 400 (Regular), 500 (Medium), 700 (Bold), 800 (ExtraBold), 900 (Black)
  - Used via: `TextStyle(fontFamily: 'Tajawal', ...)`

---

## Color Palette (`AppColors`)

### Backgrounds & Surfaces
| Name | Hex | Usage |
|------|-----|-------|
| `surface` | #FAF8F4 | Main scaffold background (light screens) |
| `background` | #E7E5DF | Secondary background |
| `cardBg` | #FFFFFF | Card backgrounds |
| `border` | #ECE8DF | Default borders |
| `borderStrong` | #D9BC6E | Accent borders |
| `dark` | #15140F | Dark header backgrounds, primary text |
| `darkMedium` | #2A2618 | Dark card backgrounds |
| `darkCard` | #23211A | Dark panel backgrounds |
| `darkBorder` | #2F2B20 | Borders on dark backgrounds |

### Gold / Primary Brand Color
| Name | Hex | Usage |
|------|-----|-------|
| `goldLight` | #E4CC7E | Highlights, chips |
| `gold` | #B5923F | Buttons, icons |
| `goldText` | #A07E2E | Text on light bg, seed color |
| `goldMuted` | #C9B98E | Subdued gold accents |
| `goldBg` | #F6EFDD | Gold-tinted backgrounds |

### Text
| Name | Hex | Usage |
|------|-----|-------|
| `textPrimary` | #15140F | Main body text (dark) |
| `textSecondary` | #7A766C | Secondary/caption text |
| `textMuted` | #A8A399 | Placeholder, hint text |
| `adminText` | #FBF7EC | Text on dark admin backgrounds |
| `adminTextMuted` | #9C9277 | Muted text on dark admin backgrounds |

### Status Colors
| Name | Hex | Usage |
|------|-----|-------|
| `green` | #2E7D5B | Success, Completed status, Approved shop |
| `greenLight` | #EAF5EF | Green chip background |
| `greenBorder` | #CDE7DA | Green chip border |
| `red` | #C0432F | Error, Cancelled status, Rejected shop |
| `redLight` | #FBEDEA | Red chip background |
| `redBorder` | #F2D4CE | Red chip border |
| `star` | #E4B53C | Star/rating color |
| *(inline)* | #9C27B0 | Suspended shop status (purple, inline only — not in AppColors) |
| *(inline)* | #0288D1 | DocsRequested shop status (blue, inline only) |
| *(inline)* | #E65100 | Pending shop badge on admin cards (deep orange, inline only) |

---

## Theme Rules

- **Card radius**: 20px
- **Input radius**: 14px
- **Card elevation**: 0 (flat cards with border)
- **Input fill**: white
- **Input border on focus**: gold (`goldText`)
- **App bar**: `surface` background, dark icons, no elevation
- **Scaffold background**: `surface` (#FAF8F4)

---

## Navigation Structure

### Customer Shell (4 tabs)
| Tab | Icon | Screen |
|-----|------|--------|
| الرئيسية (Home) | home | HomeScreen |
| طلباتي (Requests) | receipt_long | RequestsScreen |
| سياراتي (Vehicles) | directions_car | VehiclesScreen |
| حسابي (Profile) | person | ProfileScreen |

### Shop Shell (4 tabs)
| Tab | Icon | Screen |
|-----|------|--------|
| لوحة التحكم (Dashboard) | dashboard | ShopDashboardScreen |
| الطلبات (Requests) | inbox | ShopRequestsScreen |
| المحادثات (Chats) | chat | ShopChatsScreen |
| متجري (My Store) | store | ShopMyStoreScreen ⚠️ placeholder |

### Admin Shell (3 tabs)
| Tab | Icon | Screen |
|-----|------|--------|
| الرئيسية (Dashboard) | dashboard | AdminDashboardScreen |
| المتاجر (Shops) | store | AdminPendingScreen |
| الشكاوى (Disputes) | gavel | AdminDisputesScreen |

---

## Screen Inventory

### Auth
| Route | Screen | Purpose |
|-------|--------|---------|
| `/auth/login` | LoginScreen | Email + password login |
| `/auth/customer-register` | CustomerRegisterScreen | Customer signup |
| `/auth/shop-register` | ShopRegisterScreen | Shop owner signup |
| `/auth/shop-pending` | ShopPendingScreen | Waiting for admin approval |
| `/onboarding` | OnboardingScreen | Splash/intro |

### Customer
| Route | Screen | Status |
|-------|--------|--------|
| `/customer/home` | HomeScreen | ✅ Loads shops from API |
| `/customer/requests` | RequestsScreen | ✅ Loads requests from API |
| `/customer/vehicles` | VehiclesScreen | ✅ Loads vehicles from API |
| `/customer/requests/new` | NewRequestScreen | ✅ Multi-step creation |
| `/customer/requests/shop-select` | ShopSelectScreen | ✅ Pick shops for request |
| `/customer/request-detail` | RequestDetailScreen | ✅ Shows quotations |
| `/customer/quotation-detail` | QuotationDetailScreen | ✅ Single quotation view |
| `/customer/shop` | ShopProfileScreen | ✅ Shop details + reviews |
| `/customer/vehicles/add` | AddVehicleScreen | ✅ Add new vehicle |
| `/customer/requests/edit` | EditRequestScreen | ✅ Edit pending request |
| `/customer/chat` | ChatScreen | ✅ Chat with a shop |
| `/customer/review` | ReviewScreen | ✅ Submit review |
| `/customer/complaint` | ComplaintScreen | ✅ Raise dispute |
| `/customer/location-picker` | LocationPickerScreen | ✅ Map-based location |

### Shop
| Route | Screen | Status |
|-------|--------|--------|
| `/shop/dashboard` | ShopDashboardScreen | ✅ Stats + live status badge (Approved/Rejected/Suspended/DocsRequested/Pending) |
| `/shop/request-detail` | ShopRequestDetailScreen | ✅ Full state machine (accept→start work→complete) |
| `/shop/send-quote` | SendQuoteScreen | ✅ Form + API call wired |
| Chats tab | ShopChatsScreen | ✅ Chat rooms list with unread badge |
| My Store tab | ShopMyStoreScreen | ❌ Placeholder "قريباً" |

### Admin
| Route | Screen | Status |
|-------|--------|--------|
| `/admin/dashboard` | AdminDashboardScreen | ⚠️ Some stats live (pending count, dispute count), totals still hardcoded |
| `/admin/pending` | AdminPendingScreen | ✅ Full shop management: 5-tab filter, search, approve/reject/suspend/restore |
| `/admin/disputes` | AdminDisputesScreen | ✅ View/resolve disputes |

---

## Request Status Display

| API Status | Flutter Enum | Arabic Label | Color |
|-----------|-------------|-------------|-------|
| `Open` | `open` | مفتوح | gold |
| `ShopSelected` | `shopSelected` | بانتظار التأكيد | gold |
| `InProgress` | `inProgress` | جارٍ | green |
| `Completed` | `completed` | مكتمل | green |
| `Cancelled` | `cancelled` | ملغى | red |
| `Expired` | `expired` | منتهي | grey |

## Shop Status Display (Dashboard Badge)

| API Status | Arabic Label | Icon | Color |
|-----------|-------------|------|-------|
| `Approved` | متجر معتمد | verified | green |
| `Rejected` | مرفوض + سبب الرفض | cancel | red |
| `Suspended` | المتجر موقوف من الإدارة | block | #9C27B0 (purple) |
| `DocsRequested` | مطلوب مستندات إضافية | folder_open | #0288D1 (blue) |
| `Pending` | قيد المراجعة | hourglass_empty | orange |

---

## Design Patterns

### Dark Header + Light Body
Many screens use a dark gradient header (`#1B1A14 → #2E2917`) with diagonal gold lines (`_LinesPainter`) followed by a light `surface`-colored content area.

### Mono Avatar
When no profile image is available, a circle/rounded-rect shows the first letter of the name:
```dart
final mono = name.isNotEmpty ? name[0] : '؟';
```

### Gold Accent
Primary brand interactions (buttons, active states, borders) use `gold` (#B5923F) or `goldText` (#A07E2E).

### Status Chips
Small rounded pill badges showing request/quotation status with colored background + border:
- Green: completed/accepted
- Red: cancelled/rejected
- Gold: pending/in-progress
