using CarDecoration.API.Data;
using CarDecoration.API.DTOs;
using CarDecoration.API.Helpers;
using CarDecoration.API.Models;
using Microsoft.EntityFrameworkCore;

namespace CarDecoration.API.Services;

public class ShopService
{
    private readonly AppDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public ShopService(AppDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<MyShopResponse> GetMyShopAsync()
    {
        var userId = _currentUser.UserId ?? throw new Exception("غير مصرح");
        var shop = await _db.Shops
            .FirstOrDefaultAsync(s => s.OwnerId == userId && s.Status == ShopStatus.Approved)
            ?? throw new Exception("المتجر غير موجود أو غير معتمد");
        return new MyShopResponse(shop.Id, shop.Name, shop.City, shop.Rating, shop.TotalJobs);
    }

    public async Task<PagedResult<ShopResponse>> GetApprovedShopsAsync(int page, int pageSize)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 50);

        var query = _db.Shops
            .Where(s => s.Status == ShopStatus.Approved)
            .OrderByDescending(s => s.Rating);

        var total = await query.CountAsync();
        var items = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(s => new ShopResponse(
                s.Id, s.Name, s.City, s.Phone,
                s.LogoUrl, s.Rating, s.TotalJobs, s.Status.ToString()))
            .ToListAsync();

        return PagedResult<ShopResponse>.Create(items, total, page, pageSize);
    }

    public async Task<ShopDetailsResponse> GetShopDetailsAsync(Guid id)
    {
        var shop = await _db.Shops
            .Include(s => s.Reviews)
            .FirstOrDefaultAsync(s => s.Id == id && s.Status == ShopStatus.Approved)
            ?? throw new Exception("المتجر غير موجود");

        var reviews = shop.Reviews.Select(r => new ReviewResponse(
            r.QualityRating, r.CommunicationRating,
            r.CommitmentRating, r.GeneralRating,
            r.Comment, r.CreatedAt)).ToList();

        return new ShopDetailsResponse(
            shop.Id, shop.Name, shop.City, shop.Phone,
            shop.LogoUrl, shop.Rating, shop.TotalJobs,
            shop.Status.ToString(), reviews);
    }

    // ── للإدارة: عرض المتاجر بانتظار الاعتماد ──
    public async Task<List<PendingShopResponse>> GetPendingShopsAsync()
    {
        var role = _currentUser.UserRole
            ?? throw new Exception("غير مصرح");

        if (role != "Admin")
            throw new Exception("غير مصرح");

        return await _db.Shops
            .Include(s => s.Owner)
            .Where(s => s.Status == ShopStatus.Pending || s.Status == ShopStatus.Rejected || s.Status == ShopStatus.DocsRequested)
            .OrderByDescending(s => s.CreatedAt)
            .Select(s => new PendingShopResponse(
                s.Id, s.Name, s.Owner.FullName, s.City, s.Phone,
                s.CrNumber, s.LogoUrl, s.Status.ToString(), s.CreatedAt))
            .ToListAsync();
    }

    public async Task ApproveShopAsync(Guid id)
    {
        var role = _currentUser.UserRole
            ?? throw new Exception("غير مصرح");

        if (role != "Admin")
            throw new Exception("غير مصرح");

        var shop = await _db.Shops.FindAsync(id)
            ?? throw new Exception("المتجر غير موجود");

        shop.Status = ShopStatus.Approved;
        await _db.SaveChangesAsync();
    }

    public async Task RejectShopAsync(Guid id)
    {
        var role = _currentUser.UserRole
            ?? throw new Exception("غير مصرح");

        if (role != "Admin")
            throw new Exception("غير مصرح");

        var shop = await _db.Shops.FindAsync(id)
            ?? throw new Exception("المتجر غير موجود");

        shop.Status = ShopStatus.Rejected;
        await _db.SaveChangesAsync();
    }
}