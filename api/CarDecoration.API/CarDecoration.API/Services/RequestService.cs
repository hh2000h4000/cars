using CarDecoration.API.Data;
using CarDecoration.API.DTOs;
using CarDecoration.API.Helpers;
using CarDecoration.API.Models;
using Microsoft.EntityFrameworkCore;

namespace CarDecoration.API.Services;

public class RequestService
{
    private readonly AppDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public RequestService(AppDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<RequestResponse> CreateAsync(CreateRequestRequest req)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        if (req.ShopIds == null || req.ShopIds.Count == 0)
            throw new Exception("يجب اختيار متجر واحد على الأقل");

        var vehicle = await _db.Vehicles
            .FirstOrDefaultAsync(v => v.Id == req.VehicleId && v.OwnerId == userId)
            ?? throw new Exception("المركبة غير موجودة");

        var shops = await _db.Shops
            .Where(s => req.ShopIds.Contains(s.Id) && s.Status == ShopStatus.Approved)
            .ToListAsync();

        if (shops.Count != req.ShopIds.Count)
            throw new Exception("بعض المتاجر المختارة غير موجودة أو غير معتمدة");

        var requestNumber = await _db.Requests
            .CountAsync(r => r.CustomerId == userId && !r.IsDeleted) + 1;

        var request = new Request
        {
            CustomerId = userId,
            VehicleId = req.VehicleId,
            Description = req.Description,
            Location = req.Location,
            AppointmentDate = req.PreferredDate,
            Notes = req.Notes,
            RequestNumber = requestNumber,
            Status = RequestStatus.Open
        };

        _db.Requests.Add(request);
        await _db.SaveChangesAsync();

        foreach (var shop in shops)
        {
            _db.RequestShops.Add(new RequestShop
            {
                RequestId = request.Id,
                ShopId = shop.Id,
                Status = RequestShopStatus.Pending
            });
        }

        await _db.SaveChangesAsync();

        if (req.ImageUrls != null && req.ImageUrls.Count > 0)
        {
            for (int i = 0; i < req.ImageUrls.Count; i++)
                _db.RequestImages.Add(new RequestImage { RequestId = request.Id, Url = req.ImageUrls[i], Order = i });
            await _db.SaveChangesAsync();
        }

        return new RequestResponse(
            request.Id, request.RequestNumber, vehicle.Id,
            vehicle.Brand, vehicle.Model, vehicle.Year, vehicle.Color,
            request.Description, request.Location,
            request.AppointmentDate, request.Notes,
            request.Status.ToString(),
            shops.Select(s => s.Name).ToList(),
            req.ImageUrls ?? [],
            request.CreatedAt,
            []);
    }

    public Task<PagedResult<RequestResponse>> GetMyRequestsAsync(PaginationRequest pagination)
    {
        var userId = _currentUser.UserId ?? throw new Exception("غير مصرح");

        return _db.Requests
            .Where(r => r.CustomerId == userId && !r.IsDeleted)
            .OrderByDescending(r => r.CreatedAt)
            .Select(r => new RequestResponse(
                r.Id, r.RequestNumber, r.Vehicle.Id,
                r.Vehicle.Brand, r.Vehicle.Model, r.Vehicle.Year, r.Vehicle.Color,
                r.Description, r.Location,
                r.AppointmentDate, r.Notes,
                r.Status.ToString(),
                r.RequestShops.Select(rs => rs.Shop.Name).ToList(),
                r.RequestImages.OrderBy(i => i.Order).Select(i => i.Url).ToList(),
                r.CreatedAt,
                r.RequestShops
                    .Where(rs => rs.Status == RequestShopStatus.Accepted)
                    .Select(rs => new AcceptedShopSummary(
                        rs.Shop.Name,
                        rs.ShopId.ToString(),
                        r.ChatRooms
                            .Where(c => c.ShopId == rs.ShopId)
                            .Select(c => (Guid?)c.Id)
                            .FirstOrDefault()))
                    .ToList()))
            .ToPagedAsync(pagination);
    }

    public async Task<PagedResult<ShopRequestResponse>> GetShopRequestsAsync(PaginationRequest pagination)
    {
        var userId = _currentUser.UserId ?? throw new Exception("غير مصرح");

        var shop = await _db.Shops
            .FirstOrDefaultAsync(s => s.OwnerId == userId)
            ?? throw new Exception("المتجر غير موجود");

        if (shop.Status != ShopStatus.Approved)
            return PagedResult<ShopRequestResponse>.Create([], 0, pagination.Page, pagination.PageSize);

        return await _db.RequestShops
            .Where(rs => rs.ShopId == shop.Id)
            .OrderByDescending(rs => rs.CreatedAt)
            .Select(rs => new ShopRequestResponse(
                rs.Request.Id,
                rs.Request.CustomerId,
                rs.Request.Customer.FullName,
                rs.Request.Vehicle.Brand,
                rs.Request.Vehicle.Model,
                rs.Request.Vehicle.Year,
                rs.Request.Description,
                rs.Request.Location,
                rs.Request.AppointmentDate,
                rs.Request.Status.ToString(),
                rs.Status.ToString(),
                rs.Request.ChatRooms
                    .Where(c => c.ShopId == shop.Id)
                    .Select(c => (Guid?)c.Id)
                    .FirstOrDefault(),
                rs.Request.CreatedAt))
            .ToPagedAsync(pagination);
    }

    // المتجر يقبل الطلب ← تُنشأ المحادثة تلقائياً
    public async Task<Guid> AcceptRequestAsync(Guid requestId)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var shop = await _db.Shops
            .FirstOrDefaultAsync(s => s.OwnerId == userId && s.Status == ShopStatus.Approved)
            ?? throw new Exception("المتجر غير موجود");

        var requestShop = await _db.RequestShops
            .Include(rs => rs.Request)
            .FirstOrDefaultAsync(rs => rs.RequestId == requestId && rs.ShopId == shop.Id)
            ?? throw new Exception("الطلب غير موجود");

        if (requestShop.Status != RequestShopStatus.Pending)
            throw new Exception("تم معالجة هذا الطلب مسبقاً");

        if (requestShop.Request.Status != RequestStatus.Open)
            throw new Exception("هذا الطلب لم يعد مفتوحاً");

        requestShop.Status = RequestShopStatus.Accepted;
        requestShop.RespondedAt = DateTime.UtcNow;

        var chatRoom = new ChatRoom
        {
            RequestId = requestId,
            ShopId = shop.Id
        };

        _db.ChatRooms.Add(chatRoom);
        await _db.SaveChangesAsync();

        return chatRoom.Id;
    }

    public async Task<RequestResponse> UpdateRequestAsync(Guid id, UpdateRequestRequest req)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var request = await _db.Requests
            .Include(r => r.Vehicle)
            .Include(r => r.RequestShops).ThenInclude(rs => rs.Shop)
            .Include(r => r.RequestImages)
            .FirstOrDefaultAsync(r => r.Id == id && r.CustomerId == userId && !r.IsDeleted)
            ?? throw new Exception("الطلب غير موجود");

        if (request.Status != RequestStatus.Open)
            throw new Exception("لا يمكن تعديل الطلب في هذه المرحلة");

        request.Description = req.Description;
        request.Location = req.Location;
        request.AppointmentDate = req.PreferredDate;
        request.Notes = req.Notes;

        _db.RequestImages.RemoveRange(request.RequestImages);
        await _db.SaveChangesAsync();

        if (req.ImageUrls != null && req.ImageUrls.Count > 0)
        {
            for (int i = 0; i < req.ImageUrls.Count; i++)
                _db.RequestImages.Add(new RequestImage { RequestId = request.Id, Url = req.ImageUrls[i], Order = i });
            await _db.SaveChangesAsync();
        }

        var shopNames = request.RequestShops.Select(rs => rs.Shop.Name).ToList();

        return new RequestResponse(
            request.Id, request.RequestNumber, request.VehicleId,
            request.Vehicle.Brand, request.Vehicle.Model, request.Vehicle.Year, request.Vehicle.Color,
            request.Description, request.Location,
            request.AppointmentDate, request.Notes,
            request.Status.ToString(),
            shopNames,
            req.ImageUrls ?? [],
            request.CreatedAt,
            []);
    }

    // المتجر يبدأ العمل فعلياً
    public async Task StartWorkAsync(Guid requestId)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var shop = await _db.Shops
            .FirstOrDefaultAsync(s => s.OwnerId == userId && s.Status == ShopStatus.Approved)
            ?? throw new Exception("المتجر غير موجود");

        var request = await _db.Requests
            .FirstOrDefaultAsync(r => r.Id == requestId && r.SelectedShopId == shop.Id && !r.IsDeleted)
            ?? throw new Exception("الطلب غير موجود أو غير مرتبط بمتجرك");

        if (request.Status != RequestStatus.ShopSelected)
            throw new Exception("لا يمكن بدء العمل في هذه المرحلة");

        request.Status = RequestStatus.InProgress;
        await _db.SaveChangesAsync();
    }

    // المتجر يُنهي الطلب بعد اكتمال العمل
    public async Task CompleteAsync(Guid requestId)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var shop = await _db.Shops
            .FirstOrDefaultAsync(s => s.OwnerId == userId && s.Status == ShopStatus.Approved)
            ?? throw new Exception("المتجر غير موجود");

        var request = await _db.Requests
            .FirstOrDefaultAsync(r => r.Id == requestId && r.SelectedShopId == shop.Id && !r.IsDeleted)
            ?? throw new Exception("الطلب غير موجود أو غير مرتبط بمتجرك");

        if (request.Status != RequestStatus.InProgress)
            throw new Exception("لا يمكن إنهاء الطلب قبل بدء العمل");

        request.Status = RequestStatus.Completed;
        await _db.SaveChangesAsync();
    }

    // إلغاء الاتفاق مع المتجر وإعادة الطلب لاستقبال عروض جديدة
    public async Task ReopenAsync(Guid id)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var request = await _db.Requests
            .Include(r => r.Quotations)
            .FirstOrDefaultAsync(r => r.Id == id && r.CustomerId == userId)
            ?? throw new Exception("الطلب غير موجود");

        if (request.Status != RequestStatus.ShopSelected)
            throw new Exception("لا يمكن إلغاء الاتفاق — الطلب ليس في حالة اختيار متجر");

        var acceptedQuotation = request.Quotations
            .FirstOrDefault(q => q.Status == QuotationStatus.Accepted);
        if (acceptedQuotation != null)
            acceptedQuotation.Status = QuotationStatus.Rejected;

        request.Status = RequestStatus.Open;
        request.SelectedShopId = null;

        await _db.SaveChangesAsync();
    }

    // إلغاء الطلب نهائياً — لا يمكن الرجوع
    public async Task CancelAsync(Guid id)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var request = await _db.Requests
            .FirstOrDefaultAsync(r => r.Id == id && r.CustomerId == userId)
            ?? throw new Exception("الطلب غير موجود");

        if (request.Status == RequestStatus.Completed)
            throw new Exception("لا يمكن إلغاء طلب مكتمل");

        if (request.Status == RequestStatus.InProgress)
            throw new Exception("لا يمكن إلغاء طلب قيد التنفيذ — تواصل مع المتجر أولاً");

        request.Status = RequestStatus.Cancelled;
        await _db.SaveChangesAsync();
    }
}
