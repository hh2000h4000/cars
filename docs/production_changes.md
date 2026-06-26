# Production Changes — ما يجب تغييره عند النشر على الكلاود

> هذا الملف يوثّق كل الأشياء التي تعمل بطريقة مؤقتة للتطوير المحلي
> ويجب تغييرها قبل النشر على بيئة الإنتاج (Cloud/Production).

---

## 1. URLs والـ Base URL

| الآن (محلي) | المطلوب (كلاود) | الملف |
|---|---|---|
| `http://localhost:5053` (web) | `https://api.yourdomian.com` | `lib/services/api_client.dart` |
| `http://192.168.8.11:5053` (موبايل) | `https://api.yourdomain.com` | `lib/services/api_client.dart` |
| `http://0.0.0.0:5053` | يُعوَّض بـ reverse proxy (nginx) | `appsettings.json` → Urls |

```dart
// api_client.dart — غيّر هذا السطر:
static final String baseUrl = kIsWeb
    ? 'http://localhost:5053'          // ← dev only
    : 'http://192.168.8.11:5053';     // ← dev only

// إلى:
static const String baseUrl = 'https://api.yourdomain.com';
```

---

## 2. تخزين الملفات (صور السيارات والطلبات)

| الآن | المطلوب | الملاحظة |
|---|---|---|
| Local disk `/uploads` | Cloud Storage (S3 / Azure Blob / Cloudinary) | الملفات تُحذف عند إعادة تشغيل السيرفر |

**Backend — الملفات المتأثرة:**
- `Controllers/FilesController.cs` — `IFormFile` يُحفظ محلياً حالياً
- يجب استبداله بـ SDK السحابة المختارة

**الخيارات الموصى بها:**
- Cloudinary — الأسهل للصور (مجاني للحجم الصغير)
- AWS S3 — الأكثر شيوعاً
- Azure Blob Storage — إذا كان الـ backend على Azure

---

## 3. Push Notifications

| الآن | المطلوب |
|---|---|
| Polling كل 5 ثوانٍ داخل الدردشة | FCM (Firebase Cloud Messaging) |
| Badge يُحدَّث كل 30 ثانية في الـ shell | إشعار فوري يصل حتى لو التطبيق مغلق |

**ما يجب إضافته:**

### Backend:
1. تثبيت `FirebaseAdmin` NuGet package
2. إضافة جدول `DeviceTokens` — `(UserId, Token, Platform, CreatedAt)`
3. Endpoint `POST /api/notifications/register-token` — يحفظ FCM token عند تسجيل الدخول
4. داخل `ChatService.SendMessageAsync()` — إرسال push notification لصاحب الغرفة الآخر

### Flutter:
1. إضافة `firebase_messaging: ^15.x` في `pubspec.yaml`
2. إضافة `firebase_options.dart` (عبر `flutterfire configure`)
3. في `main.dart`: تهيئة Firebase + طلب صلاحية الإشعارات
4. إرسال الـ FCM token للـ backend عند تسجيل الدخول
5. معالجة الإشعارات في الخلفية والمقدمة

**ملاحظة:** يجب تسجيل التطبيق في Firebase Console وتنزيل:
- `google-services.json` للأندرويد
- `GoogleService-Info.plist` للـ iOS

---

## 4. CORS

| الآن | المطلوب | الملف |
|---|---|---|
| `AllowAnyOrigin()` — يسمح لأي موقع | تحديد النطاق الحقيقي فقط | `Program.cs` |

```csharp
// Program.cs — غيّر:
builder.Services.AddCors(options => options.AddPolicy("AllowAll",
    p => p.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()));

// إلى:
builder.Services.AddCors(options => options.AddPolicy("AllowAll",
    p => p.WithOrigins("https://yourdomain.com", "https://www.yourdomain.com")
          .AllowAnyMethod().AllowAnyHeader()));
```

---

## 5. JWT Secret Key

| الآن | المطلوب | الملف |
|---|---|---|
| مكتوب في `appsettings.json` | متغير بيئة أو Azure Key Vault | `appsettings.json` → Jwt:Key |

```json
// appsettings.json — لا تضع المفتاح هنا في الإنتاج:
"Jwt": {
  "Key": "SuperSecretKey..."   // ← خطر في production
}
```

```csharp
// Program.cs — استخدم بدلاً عن ذلك:
var jwtKey = Environment.GetEnvironmentVariable("JWT_SECRET_KEY")
    ?? builder.Configuration["Jwt:Key"];
```

---

## 6. قاعدة البيانات

| الآن | المطلوب |
|---|---|
| PostgreSQL محلي | Cloud PostgreSQL (Supabase / Railway / AWS RDS / Azure Database) |
| Connection string في `appsettings.json` | متغير بيئة `DATABASE_URL` |

```json
// appsettings.json — لا تضع كلمة المرور هنا في الإنتاج:
"ConnectionStrings": {
  "DefaultConnection": "Host=localhost;Database=...;Password=..."
}
```

---

## 7. HTTPS

| الآن | المطلوب |
|---|---|
| HTTPS معطل في Development (يمنع 307 redirect) | شهادة SSL حقيقية على السيرفر (Let's Encrypt) |
| HTTP فقط على port 5053 | HTTPS على port 443 عبر nginx/reverse proxy |

```csharp
// Program.cs — هذا الشرط صحيح، لا يحتاج تغيير:
if (!app.Environment.IsDevelopment())
    app.UseHttpsRedirection();
```

---

## 8. إعدادات Sentry

| الآن | المطلوب |
|---|---|
| DSN مكتوب مباشرة في الكود | متغير بيئة |
| يلتقط أخطاء Development | يجب تصفية بيئة Dev من الإرسال |

```dart
// main.dart:
await SentryFlutter.init((options) {
  options.dsn = const String.fromEnvironment('SENTRY_DSN',
      defaultValue: ''); // فارغ في Dev = لا إرسال
  options.environment = const String.fromEnvironment('ENV',
      defaultValue: 'development');
});
```

---

## 9. Npgsql Legacy Timestamp

```csharp
// Program.cs — هذا السطر ضروري في كل البيئات، لا تحذفه:
AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);
```

---

## 10. ملخص الأولويات للنشر

| الأولوية | التغيير | الصعوبة |
|---|---|---|
| 🔴 ضروري | تغيير Base URL للـ Flutter | سهل |
| 🔴 ضروري | متغير بيئة للـ JWT Key | سهل |
| 🔴 ضروري | Cloud PostgreSQL | متوسط |
| 🔴 ضروري | CORS محدود بالنطاق | سهل |
| 🟡 مهم | Cloud Storage للملفات | متوسط |
| 🟡 مهم | SSL / HTTPS عبر nginx | متوسط |
| 🟢 مستقبلي | Push Notifications (FCM) | صعب |
| 🟢 مستقبلي | Rate Limiting | متوسط |
