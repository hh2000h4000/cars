# CLAUDE.md — Zina Cars (زينة كارز)

> هذا الملف يُقرأ تلقائياً في بداية كل محادثة.
> في نهاية كل جلسة عمل: حدّث `docs/tasks.md` بما تم إنجازه وما تبقى.

---

## Project in One Line

منصة Flutter + ASP.NET Core تربط عملاء السيارات بمتاجر الديكور/التلميع. العميل ينشر طلباً، المتاجر ترد بعروض أسعار، يختار العميل عرضاً ويفتح محادثة.

## Tech Stack

| | |
|--|--|
| App | Flutter (Dart) — mobile + web |
| API | ASP.NET Core 8 (C#) |
| DB | PostgreSQL + EF Core |
| Auth | JWT Bearer / BCrypt |
| Logs | Serilog (console + daily file) |
| Errors | Sentry Flutter |

## Repo Structure

```
repo/
├── api/CarDecoration.API/CarDecoration.API/   ← Backend
│   ├── Controllers/
│   ├── Services/
│   ├── Models/
│   ├── DTOs/
│   ├── Data/AppDbContext.cs
│   ├── Helpers/CurrentUserService.cs
│   ├── Migrations/
│   └── Program.cs
├── car_decoration_app/lib/                    ← Flutter App
│   ├── screens/   (customer/ shop/ admin/ auth/)
│   ├── models/
│   ├── services/
│   ├── providers/app_provider.dart
│   ├── theme.dart
│   └── main.dart
└── docs/                                      ← التوثيق التفصيلي
```

## Documentation Files

| الملف | المحتوى |
|-------|---------|
| `docs/project_overview.md` | وصف المشروع، التقنيات، أنواع المستخدمين، كيفية التشغيل |
| `docs/architecture.md` | طبقات الباكند والفرونت، middleware pipeline، JWT |
| `docs/database_schema.md` | جميع الجداول والعلاقات والـ Enums والـ Migrations |
| `docs/api_contracts.md` | كل endpoint مع Request/Response |
| `docs/ui_rules.md` | الألوان، الـ Theme، شاشات التطبيق وحالتها |
| `docs/tasks.md` | ✅ ما تم / ❌ ما تبقى / 🐛 الأخطاء |
| `docs/decisions.md` | قرارات تقنية مع السبب والبدائل |

## User Roles

- **Customer** — يضيف سيارات، ينشئ طلبات، يختار عروض، يدردش، يقيّم
- **ShopOwner** — يستقبل طلبات، يرسل عروض، يدردش (يحتاج موافقة Admin أولاً)
- **Admin** — يوافق/يرفض متاجر، يدير الشكاوى

## Core Flow

```
Customer → Request (multi-shop) → Shop accepts → ChatRoom opens
→ Shop sends Quotation → Customer accepts → Request = Active
→ Job done → Customer reviews → Shop rating updated
```

## Current Status (آخر تحديث: 2026-06-26)

- Backend: يعمل على PostgreSQL، جميع endpoints مكتملة ✅
- Flutter: يعمل على موبايل وChromeWeb، بيانات حقيقية من API ✅
- شاشات التاجر كاملة ومربوطة بـ API: Dashboard، Requests، Chats، SendQuote ✅
- شاشة الدردشة: رسائلي يمين (داكن)، رسائل الطرف الثاني يسار (أبيض) — مثل واتساب ✅
- اشعارات الرسائل غير المقروءة: gold badge في قائمة المحادثات ✅
- التركيز يبقى على حقل النص بعد الإرسال ✅
- Mock data: محذوف بالكامل
- Serilog: مفعّل، CORS: يعمل، Sentry: مضبوط

## Ports & URLs

| | |
|--|--|
| HTTP (dev) | `http://0.0.0.0:5053` |
| HTTPS | `https://0.0.0.0:7209` |
| Flutter Web baseUrl | `http://localhost:5053` |
| Flutter Mobile baseUrl | `http://192.168.8.11:5053` |

## Critical Code Notes

**Flutter Web bug:** دائماً استخدم `catchError((Object e) {...})` بمعامل واحد — معاملان يسببان crash على web بسبب DDC StackTrace cast.

**CORS fix:** `app.UseRouting()` يجب أن يكون قبل `app.UseCors()` في Program.cs — بدونه كل OPTIONS preflight يرجع 405.

**HTTPS redirect:** `if (!app.Environment.IsDevelopment()) app.UseHttpsRedirection()` — بدون هذا الشرط، 307 redirect يحذف Authorization header ويسبب 401.

**JWT claims:** `options.MapInboundClaims = false` مطلوب في .NET 8 — بدونه `sub` يُعاد تسميته تلقائياً. `CurrentUserService` يجرّب: `ClaimTypes.NameIdentifier` → `"sub"` → `"nameid"`.

**Npgsql:** `AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true)` مطلوب في Program.cs قبل `builder`.

**Migrations:** بعد أي تغيير على Models → `dotnet ef database update` على جهاز المستخدم.

## What's Left (الأهم)

- `ShopMyStoreScreen` لا تزال placeholder ("قريباً")
- Badge عدد الرسائل غير المقروءة على تاب المحادثات في bottom nav (مؤجل)
- Push Notifications عبر FCM (يحتاج Firebase + backend integration)
- لا يوجد pagination على أي endpoint
- Cloud storage للملفات المرفوعة (حالياً local disk)
