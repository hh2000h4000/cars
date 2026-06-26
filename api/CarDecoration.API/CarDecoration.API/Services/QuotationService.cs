using CarDecoration.API.Data;
using CarDecoration.API.DTOs;
using CarDecoration.API.Helpers;
using CarDecoration.API.Models;
using Microsoft.EntityFrameworkCore;

namespace CarDecoration.API.Services;

public class QuotationService
{
    private readonly AppDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public QuotationService(AppDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    // المتجر يرسل عرض سعر
    public async Task<QuotationResponse> CreateAsync(CreateQuotationRequest req)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var shop = await _db.Shops
            .FirstOrDefaultAsync(s => s.OwnerId == userId && s.Status == ShopStatus.Approved)
            ?? throw new Exception("المتجر غير موجود أو غير معتمد");

        var request = await _db.Requests
            .FirstOrDefaultAsync(r => r.Id == req.RequestId && r.Status == RequestStatus.Pending)
            ?? throw new Exception("الطلب غير موجود");

        // تأكد أن المتجر لم يرسل عرض مسبقاً
        var exists = await _db.Quotations
            .AnyAsync(q => q.RequestId == req.RequestId && q.ShopId == shop.Id);
        if (exists)
            throw new Exception("لقد أرسلت عرض سعر لهذا الطلب مسبقاً");

        var quotation = new Quotation
        {
            RequestId = req.RequestId,
            ShopId = shop.Id,
            ServiceDetails = req.ServiceDetails,
            Parts = req.Parts,
            Warranty = req.Warranty,
            VisitFee = req.VisitFee,
            Duration = req.Duration,
            FinalPrice = req.FinalPrice,
            Status = QuotationStatus.Pending
        };

        _db.Quotations.Add(quotation);
        await _db.SaveChangesAsync();

        return new QuotationResponse(
            quotation.Id, quotation.RequestId, shop.Id, shop.Name,
            quotation.ServiceDetails, quotation.Parts, quotation.Warranty,
            quotation.VisitFee, quotation.Duration, quotation.FinalPrice,
            quotation.Status.ToString(), quotation.CreatedAt, null);
    }

    // العميل يعرض عروض الأسعار لطلبه
    public async Task<List<QuotationResponse>> GetRequestQuotationsAsync(Guid requestId)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        // تأكد أن الطلب يخص العميل
        var request = await _db.Requests
            .FirstOrDefaultAsync(r => r.Id == requestId && r.CustomerId == userId)
            ?? throw new Exception("الطلب غير موجود");

        return await _db.Quotations
            .Where(q => q.RequestId == requestId)
            .OrderByDescending(q => q.CreatedAt)
            .Select(q => new QuotationResponse(
                q.Id, q.RequestId, q.ShopId, q.Shop.Name,
                q.ServiceDetails, q.Parts, q.Warranty,
                q.VisitFee, q.Duration, q.FinalPrice,
                q.Status.ToString(), q.CreatedAt,
                q.Request.ChatRoom != null ? q.Request.ChatRoom.Id : (Guid?)null))
            .ToListAsync();
    }

    // العميل يقبل عرض سعر — يُرجع chatRoomId للانتقال الفوري للمحادثة
    public async Task<Guid> AcceptAsync(Guid quotationId)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var quotation = await _db.Quotations
            .Include(q => q.Request)
            .FirstOrDefaultAsync(q => q.Id == quotationId)
            ?? throw new Exception("العرض غير موجود");

        if (quotation.Request.CustomerId != userId)
            throw new Exception("غير مصرح");

        if (quotation.Request.Status != RequestStatus.Pending)
            throw new Exception("لا يمكن قبول عرض لطلب غير معلق");

        quotation.Status = QuotationStatus.Accepted;

        var otherQuotations = await _db.Quotations
            .Where(q => q.RequestId == quotation.RequestId && q.Id != quotationId)
            .ToListAsync();
        otherQuotations.ForEach(q => q.Status = QuotationStatus.Rejected);

        quotation.Request.Status = RequestStatus.Active;
        quotation.Request.SelectedShopId = quotation.ShopId;

        await _db.SaveChangesAsync();

        // إيجاد المحادثة أو إنشاؤها إذا لم تكن موجودة بعد
        var chatRoom = await _db.ChatRooms
            .FirstOrDefaultAsync(c => c.RequestId == quotation.RequestId && c.ShopId == quotation.ShopId);

        if (chatRoom == null)
        {
            chatRoom = new ChatRoom { RequestId = quotation.RequestId, ShopId = quotation.ShopId };
            _db.ChatRooms.Add(chatRoom);
            await _db.SaveChangesAsync();
        }

        return chatRoom.Id;
    }
}