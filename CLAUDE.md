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
| `docs/project_overview.md` | وصف المشروع، التقنيات، أنواع المستخدمين |
| `docs/architecture.md` | طبقات الباكند والفرونت، middleware pipeline |
| `docs/database_schema.md` | جميع الجداول والعلاقات والـ Enums |
| `docs/api_contracts.md` | كل endpoint مع Request/Response |
| `docs/ui_rules.md` | الألوان، الـ Theme، شاشات التطبيق |
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

## Current Status (آخر تحديث: 2026-06-25)

- Backend: يعمل على PostgreSQL، جميع endpoints مكتملة
- Flutter: يعمل على موبايل وChromeWeb، بيانات حقيقية من API
- Mock data: محذوف بالكامل
- Serilog: مفعّل، CORS: يعمل، Sentry: مضبوط

## Known Issues (راجع docs/tasks.md للتفاصيل)

- ملفات المستخدم المحلية قديمة (RequestsController, VehicleService, Vehicle.cs, RequestDtos.cs) — تم إرسال المحتوى للاستبدال اليدوي
- git pull لا يعمل على جهاز المستخدم المحلي

## Critical Code Notes

**Flutter Web bug fix:** دائماً استخدم `catchError((Object e) {...})` بمعامل واحد — معاملان يسببان crash على web بسبب DDC StackTrace cast.

**CORS fix:** `app.UseRouting()` يجب أن يكون قبل `app.UseCors()` في Program.cs — بدونه كل OPTIONS preflight يرجع 405.

**Npgsql:** `AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true)` مطلوب في Program.cs قبل `builder`.
