using CarDecoration.API.Data;
using CarDecoration.API.DTOs;
using CarDecoration.API.Helpers;
using CarDecoration.API.Hubs;
using CarDecoration.API.Models;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace CarDecoration.API.Services;

public class ShopService
{
    private readonly AppDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IHubContext<ChatHub> _hub;

    public ShopService(AppDbContext db, ICurrentUserService currentUser, IHubContext<ChatHub> hub)
    {
        _db = db;
        _currentUser = currentUser;
        _hub = hub;
    }

    public async Task<MyShopResponse> GetMyShopAsync()
    {
        var userId = _currentUser.UserId ?? throw new Exception("غير مصرح");
        var shop = await _db.Shops
            .FirstOrDefaultAsync(s => s.OwnerId == userId)
            ?? throw new Exception("المتجر غير موجود");
        return ToMyShopResponse(shop);
    }

    public async Task<MyShopResponse> UpdateMyShopAsync(UpdateMyShopRequest req)
    {
        var userId = _currentUser.UserId ?? throw new Exception("غير مصرح");
        var shop = await _db.Shops
            .FirstOrDefaultAsync(s => s.OwnerId == userId)
            ?? throw new Exception("المتجر غير موجود");

        shop.Name = req.Name.Trim();
        shop.Phone = req.Phone.Trim();
        shop.City = req.City.Trim();
        shop.Street = req.Street.Trim();
        shop.District = req.District.Trim();
        shop.PostalCode = req.PostalCode.Trim();
        shop.BuildingNumber = req.BuildingNumber?.Trim();
        shop.AdditionalNumber = req.AdditionalNumber?.Trim();
        if (req.Latitude.HasValue) shop.Latitude = req.Latitude;
        if (req.Longitude.HasValue) shop.Longitude = req.Longitude;
        if (req.LogoUrl != null) shop.LogoUrl = req.LogoUrl;

        await _db.SaveChangesAsync();
        return ToMyShopResponse(shop);
    }

    public Task<PagedResult<ShopResponse>> GetApprovedShopsAsync(PaginationRequest pagination)
        => _db.Shops
            .Where(s => s.Status == ShopStatus.Approved)
            .OrderByDescending(s => s.Rating)
            .Select(s => new ShopResponse(
                s.Id, s.Name, s.City, s.District, s.Street, s.Phone,
                s.LogoUrl, s.Rating, s.TotalJobs,
                s.Reviews.Count,
                s.Status.ToString(),
                s.Latitude, s.Longitude))
            .ToPagedAsync(pagination);

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
            shop.Id, shop.Name, shop.City, shop.Street, shop.District,
            shop.PostalCode, shop.BuildingNumber, shop.AdditionalNumber,
            shop.Phone, shop.LogoUrl, shop.Rating, shop.TotalJobs,
            shop.Status.ToString(), shop.Latitude, shop.Longitude, reviews);
    }

    // ── للإدارة: عرض جميع المتاجر مع فلترة اختيارية ──
    public Task<PagedResult<PendingShopResponse>> GetAllShopsAdminAsync(string? status, string? search, PaginationRequest pagination)
    {
        var role = _currentUser.UserRole ?? throw new Exception("غير مصرح");
        if (role != "Admin") throw new Exception("غير مصرح");

        var query = _db.Shops.Include(s => s.Owner).AsQueryable();

        if (!string.IsNullOrWhiteSpace(status) && Enum.TryParse<ShopStatus>(status, out var shopStatus))
            query = query.Where(s => s.Status == shopStatus);

        if (!string.IsNullOrWhiteSpace(search))
            query = query.Where(s => s.Name.Contains(search) || s.Owner.FullName.Contains(search) || s.CrNumber.Contains(search));

        return query
            .OrderByDescending(s => s.CreatedAt)
            .Select(s => new PendingShopResponse(
                s.Id, s.Name, s.Owner.FullName, s.Owner.Phone,
                s.City, s.Street, s.District, s.PostalCode,
                s.BuildingNumber, s.AdditionalNumber, s.Latitude, s.Longitude,
                s.Phone, s.CrNumber, s.IdNumber, s.LogoUrl,
                s.CrDocumentUrl, s.IdDocumentUrl,
                s.Status.ToString(), s.CreatedAt, s.RejectionReason))
            .ToPagedAsync(pagination);
    }

    public async Task<MyShopResponse> ResubmitMyShopAsync(ResubmitMyShopRequest req)
    {
        var userId = _currentUser.UserId ?? throw new Exception("غير مصرح");
        var shop = await _db.Shops
            .FirstOrDefaultAsync(s => s.OwnerId == userId)
            ?? throw new Exception("المتجر غير موجود");

        if (shop.Status != ShopStatus.Rejected && shop.Status != ShopStatus.DocsRequested)
            throw new Exception("لا يمكن إعادة التقديم إلا للمتاجر المرفوضة أو المطلوب منها مستندات");

        shop.Name = req.Name.Trim();
        shop.Phone = req.Phone.Trim();
        shop.City = req.City.Trim();
        shop.Street = req.Street.Trim();
        shop.District = req.District.Trim();
        shop.PostalCode = req.PostalCode.Trim();
        shop.BuildingNumber = req.BuildingNumber?.Trim();
        shop.AdditionalNumber = req.AdditionalNumber?.Trim();
        if (req.Latitude.HasValue) shop.Latitude = req.Latitude;
        if (req.Longitude.HasValue) shop.Longitude = req.Longitude;
        shop.CrNumber = req.CrNumber.Trim();
        if (req.IdNumber != null) shop.IdNumber = req.IdNumber.Trim();
        if (req.LogoUrl != null) shop.LogoUrl = req.LogoUrl;
        if (req.CrDocumentUrl != null) shop.CrDocumentUrl = req.CrDocumentUrl;
        if (req.IdDocumentUrl != null) shop.IdDocumentUrl = req.IdDocumentUrl;
        shop.Status = ShopStatus.Pending;
        shop.RejectionReason = null;

        await _db.SaveChangesAsync();
        return ToMyShopResponse(shop, rejectionReason: null);
    }

    private static MyShopResponse ToMyShopResponse(Shop shop, string? rejectionReason = null)
        => new(shop.Id, shop.Name, shop.City, shop.Street, shop.District,
            shop.PostalCode, shop.BuildingNumber, shop.AdditionalNumber,
            shop.Latitude, shop.Longitude,
            shop.Phone, shop.LogoUrl, shop.Status.ToString(),
            shop.CrNumber, shop.IdNumber, shop.Rating, shop.TotalJobs,
            rejectionReason ?? shop.RejectionReason);

    public async Task ApproveShopAsync(Guid id)
    {
        var role = _currentUser.UserRole ?? throw new Exception("غير مصرح");
        if (role != "Admin") throw new Exception("غير مصرح");

        var shop = await _db.Shops.FindAsync(id) ?? throw new Exception("المتجر غير موجود");
        shop.Status = ShopStatus.Approved;
        shop.RejectionReason = null;
        await _db.SaveChangesAsync();
        await _hub.Clients.User(shop.OwnerId.ToString())
            .SendAsync("ShopStatusChanged", new { status = "Approved", reason = (string?)null });
    }

    public async Task RejectShopAsync(Guid id, string reason)
    {
        var role = _currentUser.UserRole ?? throw new Exception("غير مصرح");
        if (role != "Admin") throw new Exception("غير مصرح");

        if (string.IsNullOrWhiteSpace(reason))
            throw new Exception("يجب إدخال سبب الرفض");

        var shop = await _db.Shops.FindAsync(id) ?? throw new Exception("المتجر غير موجود");
        shop.Status = ShopStatus.Rejected;
        shop.RejectionReason = reason.Trim();
        await _db.SaveChangesAsync();
        await _hub.Clients.User(shop.OwnerId.ToString())
            .SendAsync("ShopStatusChanged", new { status = "Rejected", reason = shop.RejectionReason });
    }

    public async Task SuspendShopAsync(Guid id)
    {
        var role = _currentUser.UserRole ?? throw new Exception("غير مصرح");
        if (role != "Admin") throw new Exception("غير مصرح");

        var shop = await _db.Shops.FindAsync(id) ?? throw new Exception("المتجر غير موجود");
        shop.Status = ShopStatus.Suspended;
        await _db.SaveChangesAsync();
        await _hub.Clients.User(shop.OwnerId.ToString())
            .SendAsync("ShopStatusChanged", new { status = "Suspended", reason = (string?)null });
    }
}