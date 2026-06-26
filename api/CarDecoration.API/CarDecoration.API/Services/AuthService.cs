using System.Security.Cryptography;
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
        return new AuthResponse(_jwt.Generate(user), raw, user.FullName, user.Email, user.Role.ToString());
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
        if (await _db.Users.AnyAsync(u => u.Email == req.Email))
            throw new Exception("البريد الإلكتروني مستخدم مسبقاً");

        if (await _db.Users.AnyAsync(u => u.Phone == req.Phone))
            throw new Exception("رقم الجوال مستخدم مسبقاً");

        if (await _db.Shops.AnyAsync(s => s.CrNumber == req.CrNumber))
            throw new Exception("رقم السجل التجاري مستخدم مسبقاً");

        await using var tx = await _db.Database.BeginTransactionAsync();

        var user = new User
        {
            FullName = req.FullName,
            Phone = req.Phone,
            Email = req.Email.ToLower().Trim(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.Password),
            Role = UserRole.ShopOwner
        };

        _db.Users.Add(user);
        await _db.SaveChangesAsync();

        var shop = new Shop
        {
            OwnerId = user.Id,
            Name = req.ShopName,
            CrNumber = req.CrNumber,
            City = req.City,
            Phone = req.ShopPhone,
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
