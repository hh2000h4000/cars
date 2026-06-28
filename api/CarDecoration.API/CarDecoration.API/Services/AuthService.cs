using System.Security.Cryptography;
using System.Text.RegularExpressions;
using CarDecoration.API.Data;
using CarDecoration.API.DTOs;
using CarDecoration.API.Helpers;
using CarDecoration.API.Models;
using Microsoft.EntityFrameworkCore;

namespace CarDecoration.API.Services;

public class AuthService
{
    private readonly AppDbContext _db;
    private readonly JwtTokenGenerator _jwt;
    private readonly JwtSettings _settings;

    public AuthService(AppDbContext db, JwtTokenGenerator jwt, JwtSettings settings)
    {
        _db = db;
        _jwt = jwt;
        _settings = settings;
    }

    private static string CreateRefreshToken()
        => Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));

    private async Task<AuthResponse> BuildResponseAsync(User user)
    {
        var raw = CreateRefreshToken();
        _db.RefreshTokens.Add(new RefreshToken
        {
            UserId = user.Id,
            Token = raw,
            ExpiresAt = DateTime.UtcNow.AddDays(_settings.RefreshTokenExpiryDays),
        });
        await _db.SaveChangesAsync();
        return new AuthResponse(_jwt.Generate(user), raw, user.FullName, user.Phone, user.Email, user.Role.ToString());
    }

    public async Task<AuthResponse> RegisterAsync(RegisterRequest req)
    {
        if (await _db.Users.AnyAsync(u => u.Email == req.Email))
            throw new Exception("البريد الإلكتروني مستخدم مسبقاً");

        if (await _db.Users.AnyAsync(u => u.Phone == req.Phone))
            throw new Exception("رقم الجوال مستخدم مسبقاً");

        var user = new User
        {
            FullName = req.FullName,
            Phone = req.Phone,
            Email = req.Email.ToLower().Trim(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.Password),
            Role = UserRole.Customer
        };

        _db.Users.Add(user);
        await _db.SaveChangesAsync();
        return await BuildResponseAsync(user);
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest req)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == req.Email.ToLower().Trim())
            ?? throw new Exception("البريد الإلكتروني أو كلمة المرور غير صحيحة");

        if (user.Status == UserStatus.Suspended)
            throw new Exception("الحساب موقوف، تواصل مع الدعم");

        if (!BCrypt.Net.BCrypt.Verify(req.Password, user.PasswordHash))
            throw new Exception("البريد الإلكتروني أو كلمة المرور غير صحيحة");

        return await BuildResponseAsync(user);
    }

    public async Task<AuthResponse> RegisterShopAsync(ShopRegisterRequest req)
    {
        // ── Format validation ────────────────────────────────────────────────
        if (!Regex.IsMatch(req.Phone.Trim(), @"^0[15]\d{8}$"))
            throw new Exception("رقم جوال المالك يجب أن يبدأ بـ 05 أو 01 ويتكون من 10 أرقام إنجليزية");

        if (!Regex.IsMatch(req.ShopPhone.Trim(), @"^0[15]\d{8}$"))
            throw new Exception("رقم جوال المتجر يجب أن يبدأ بـ 05 أو 01 ويتكون من 10 أرقام إنجليزية");

        try { _ = new System.Net.Mail.MailAddress(req.Email); }
        catch { throw new Exception("صيغة البريد الإلكتروني غير صحيحة"); }

        if (!Regex.IsMatch(req.CrNumber.Trim(), @"^\d{10}$"))
            throw new Exception("رقم السجل التجاري يجب أن يتكون من 10 أرقام");

        if (string.IsNullOrWhiteSpace(req.IdNumber))
            throw new Exception("يرجى إدخال رقم الهوية");

        if (string.IsNullOrWhiteSpace(req.CrDocumentUrl))
            throw new Exception("يرجى رفع صورة السجل التجاري");

        if (string.IsNullOrWhiteSpace(req.IdDocumentUrl))
            throw new Exception("يرجى رفع صورة الهوية");

        if (string.IsNullOrWhiteSpace(req.Street))
            throw new Exception("يرجى إدخال اسم الشارع");

        if (string.IsNullOrWhiteSpace(req.District))
            throw new Exception("يرجى إدخال اسم الحي");

        if (string.IsNullOrWhiteSpace(req.PostalCode))
            throw new Exception("يرجى إدخال الرمز البريدي");

        // ── Uniqueness checks ────────────────────────────────────────────────
        if (await _db.Users.AnyAsync(u => u.Email == req.Email.ToLower().Trim()))
            throw new Exception("البريد الإلكتروني مستخدم مسبقاً");

        if (await _db.Users.AnyAsync(u => u.Phone == req.Phone.Trim()))
            throw new Exception("رقم الجوال مستخدم مسبقاً");

        if (await _db.Shops.AnyAsync(s => s.CrNumber == req.CrNumber.Trim()))
            throw new Exception("رقم السجل التجاري مستخدم مسبقاً");

        await using var tx = await _db.Database.BeginTransactionAsync();

        var user = new User
        {
            FullName = req.FullName.Trim(),
            Phone = req.Phone.Trim(),
            Email = req.Email.ToLower().Trim(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.Password),
            Role = UserRole.ShopOwner
        };

        _db.Users.Add(user);
        await _db.SaveChangesAsync();

        var shop = new Shop
        {
            OwnerId = user.Id,
            Name = req.ShopName.Trim(),
            CrNumber = req.CrNumber.Trim(),
            City = req.City.Trim(),
            Street = req.Street.Trim(),
            District = req.District.Trim(),
            PostalCode = req.PostalCode.Trim(),
            BuildingNumber = req.BuildingNumber?.Trim(),
            AdditionalNumber = req.AdditionalNumber?.Trim(),
            Latitude = req.Latitude,
            Longitude = req.Longitude,
            Phone = req.ShopPhone.Trim(),
            LogoUrl = req.LogoUrl,
            IdNumber = req.IdNumber.Trim(),
            CrDocumentUrl = req.CrDocumentUrl,
            IdDocumentUrl = req.IdDocumentUrl,
            Status = ShopStatus.Pending
        };

        _db.Shops.Add(shop);
        await _db.SaveChangesAsync();
        await tx.CommitAsync();

        return await BuildResponseAsync(user);
    }

    public async Task<AuthResponse> RefreshAsync(string token)
    {
        var stored = await _db.RefreshTokens
            .Include(r => r.User)
            .FirstOrDefaultAsync(r => r.Token == token)
            ?? throw new Exception("رمز التحديث غير صالح");

        if (stored.IsRevoked)
            throw new Exception("رمز التحديث ملغى");

        if (stored.ExpiresAt < DateTime.UtcNow)
            throw new Exception("رمز التحديث منتهي الصلاحية");

        if (stored.User.Status == UserStatus.Suspended)
            throw new Exception("الحساب موقوف");

        // Token rotation: revoke old, issue new pair
        stored.IsRevoked = true;
        await _db.SaveChangesAsync();

        return await BuildResponseAsync(stored.User);
    }

    public async Task LogoutAsync(string token)
    {
        var stored = await _db.RefreshTokens.FirstOrDefaultAsync(r => r.Token == token);
        if (stored != null)
        {
            stored.IsRevoked = true;
            await _db.SaveChangesAsync();
        }
    }
}
