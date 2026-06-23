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

    public AuthService(AppDbContext db, JwtTokenGenerator jwt)
    {
        _db = db;
        _jwt = jwt;
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

        return new AuthResponse(_jwt.Generate(user), user.FullName, user.Email, user.Role.ToString());
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest req)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == req.Email.ToLower().Trim())
            ?? throw new Exception("البريد الإلكتروني أو كلمة المرور غير صحيحة");

        if (user.Status == UserStatus.Suspended)
            throw new Exception("الحساب موقوف، تواصل مع الدعم");

        if (!BCrypt.Net.BCrypt.Verify(req.Password, user.PasswordHash))
            throw new Exception("البريد الإلكتروني أو كلمة المرور غير صحيحة");

        return new AuthResponse(_jwt.Generate(user), user.FullName, user.Email, user.Role.ToString());
    }

    public async Task<AuthResponse> RegisterShopAsync(ShopRegisterRequest req)
    {
        if (await _db.Users.AnyAsync(u => u.Email == req.Email))
            throw new Exception("البريد الإلكتروني مستخدم مسبقاً");

        if (await _db.Shops.AnyAsync(s => s.CrNumber == req.CrNumber))
            throw new Exception("السجل التجاري مستخدم مسبقاً");

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

        return new AuthResponse(_jwt.Generate(user), user.FullName, user.Email, user.Role.ToString());
    }
}