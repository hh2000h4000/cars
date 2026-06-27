using CarDecoration.API.Data;
using CarDecoration.API.DTOs;
using CarDecoration.API.Helpers;
using CarDecoration.API.Models;
using Microsoft.EntityFrameworkCore;

namespace CarDecoration.API.Services;

public class UserService
{
    private readonly AppDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public UserService(AppDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<UserProfileResponse> GetProfileAsync()
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("المستخدم غير موجود");

        var user = await _db.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == userId)
            ?? throw new Exception("المستخدم غير موجود");

        var vehicleCount = await _db.Vehicles
            .CountAsync(v => v.OwnerId == userId);

        var activeStatuses = new[] { RequestStatus.Open, RequestStatus.ShopSelected, RequestStatus.InProgress };
        var activeRequestCount = await _db.Requests
            .CountAsync(r => r.CustomerId == userId && activeStatuses.Contains(r.Status));

        var reviewCount = await _db.Reviews
            .CountAsync(r => r.Request.CustomerId == userId);

        return new UserProfileResponse(
            user.FullName,
            user.Phone,
            user.Email,
            vehicleCount,
            activeRequestCount,
            reviewCount
        );
    }

    public async Task<UserProfileResponse> UpdateProfileAsync(UpdateProfileRequest req)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("المستخدم غير موجود");

        var user = await _db.Users.FirstOrDefaultAsync(u => u.Id == userId)
            ?? throw new Exception("المستخدم غير موجود");

        var trimmedName = req.FullName?.Trim() ?? "";
        var trimmedPhone = req.Phone?.Trim() ?? "";

        if (trimmedName.Length < 2)
            throw new Exception("الاسم يجب أن يكون حرفين على الأقل");

        if (!string.IsNullOrEmpty(trimmedPhone) && trimmedPhone != user.Phone)
        {
            if (await _db.Users.AnyAsync(u => u.Phone == trimmedPhone && u.Id != userId))
                throw new Exception("رقم الجوال مستخدم من حساب آخر");
            user.Phone = trimmedPhone;
        }

        user.FullName = trimmedName;
        await _db.SaveChangesAsync();

        return await GetProfileAsync();
    }
}
