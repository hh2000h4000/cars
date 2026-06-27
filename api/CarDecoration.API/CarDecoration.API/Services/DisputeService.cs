using CarDecoration.API.Data;
using CarDecoration.API.DTOs;
using CarDecoration.API.Helpers;
using CarDecoration.API.Models;
using Microsoft.EntityFrameworkCore;

namespace CarDecoration.API.Services;

public class DisputeService
{
    private readonly AppDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public DisputeService(AppDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    // العميل يرفع نزاع
    public async Task<DisputeResponse> CreateAsync(CreateDisputeRequest req)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var request = await _db.Requests
            .Include(r => r.Customer)
            .Include(r => r.SelectedShop)
            .FirstOrDefaultAsync(r => r.Id == req.RequestId && r.CustomerId == userId)
            ?? throw new Exception("الطلب غير موجود");

        if (request.Status != RequestStatus.ShopSelected &&
            request.Status != RequestStatus.InProgress &&
            request.Status != RequestStatus.Completed)
            throw new Exception("لا يمكن رفع نزاع لهذا الطلب");

        if (request.SelectedShopId == null)
            throw new Exception("لا يوجد متجر مرتبط بهذا الطلب");

        var existingDispute = await _db.Disputes
            .AnyAsync(d => d.RequestId == req.RequestId);
        if (existingDispute)
            throw new Exception("يوجد نزاع مسبق لهذا الطلب");

        if (!Enum.TryParse<DisputeReason>(req.Reason, out var reason))
            throw new Exception("سبب النزاع غير صحيح");

        var dispute = new Dispute
        {
            RequestId = req.RequestId,
            UserId = userId,
            Reason = reason,
            Details = req.Details,
            Evidence = req.Evidence ?? [],
            Status = DisputeStatus.UnderReview
        };

        _db.Disputes.Add(dispute);
        await _db.SaveChangesAsync();

        return new DisputeResponse(
            dispute.Id,
            dispute.RequestId,
            request.Customer.FullName,
            request.SelectedShop!.Name,
            dispute.Reason.ToString(),
            dispute.Details,
            dispute.Evidence,
            dispute.Status.ToString(),
            dispute.CreatedAt);
    }

    // العميل يعرض نزاعاته
    public Task<PagedResult<DisputeResponse>> GetMyDisputesAsync(PaginationRequest pagination)
    {
        var userId = _currentUser.UserId ?? throw new Exception("غير مصرح");

        return _db.Disputes
            .Where(d => d.UserId == userId)
            .OrderByDescending(d => d.CreatedAt)
            .Select(d => new DisputeResponse(
                d.Id,
                d.RequestId,
                d.Request.Customer.FullName,
                d.Request.SelectedShop!.Name,
                d.Reason.ToString(),
                d.Details,
                d.Evidence,
                d.Status.ToString(),
                d.CreatedAt))
            .ToPagedAsync(pagination);
    }

    // الإدارة تعرض كل النزاعات
    public Task<PagedResult<DisputeResponse>> GetAllDisputesAsync(PaginationRequest pagination)
    {
        var role = _currentUser.UserRole ?? throw new Exception("غير مصرح");
        if (role != "Admin") throw new Exception("غير مصرح");

        return _db.Disputes
            .OrderByDescending(d => d.CreatedAt)
            .Select(d => new DisputeResponse(
                d.Id,
                d.RequestId,
                d.Request.Customer.FullName,
                d.Request.SelectedShop!.Name,
                d.Reason.ToString(),
                d.Details,
                d.Evidence,
                d.Status.ToString(),
                d.CreatedAt))
            .ToPagedAsync(pagination);
    }

    // الإدارة تغير حالة النزاع
    public async Task UpdateStatusAsync(Guid id, UpdateDisputeStatusRequest req)
    {
        var role = _currentUser.UserRole
            ?? throw new Exception("غير مصرح");

        if (role != "Admin")
            throw new Exception("غير مصرح");

        var dispute = await _db.Disputes.FindAsync(id)
            ?? throw new Exception("النزاع غير موجود");

        if (!Enum.TryParse<DisputeStatus>(req.Status, out var status))
            throw new Exception("الحالة غير صحيحة");

        dispute.Status = status;
        await _db.SaveChangesAsync();
    }
}