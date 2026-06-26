using CarDecoration.API.Data;
using CarDecoration.API.DTOs;
using CarDecoration.API.Helpers;
using CarDecoration.API.Models;
using Microsoft.EntityFrameworkCore;

namespace CarDecoration.API.Services;

public class ReviewService
{
    private readonly AppDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public ReviewService(AppDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<ReviewResponse2> CreateAsync(CreateReviewRequest req)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        // التحقق من صحة التقييمات
        var ratings = new[] { req.QualityRating, req.CommunicationRating, req.CommitmentRating, req.GeneralRating };
        if (ratings.Any(r => r < 1 || r > 5))
            throw new Exception("التقييم يجب أن يكون بين 1 و 5");

        var request = await _db.Requests
            .Include(r => r.SelectedShop)
            .FirstOrDefaultAsync(r => r.Id == req.RequestId && r.CustomerId == userId)
            ?? throw new Exception("الطلب غير موجود");

        if (request.Status != RequestStatus.Completed)
            throw new Exception("لا يمكن تقييم طلب غير مكتمل");

        if (request.SelectedShopId == null)
            throw new Exception("لا يوجد متجر مرتبط بهذا الطلب");

        var exists = await _db.Reviews.AnyAsync(r => r.RequestId == req.RequestId);
        if (exists)
            throw new Exception("لقد قيّمت هذا الطلب مسبقاً");

        var review = new Review
        {
            RequestId = req.RequestId,
            ShopId = request.SelectedShopId.Value,
            QualityRating = req.QualityRating,
            CommunicationRating = req.CommunicationRating,
            CommitmentRating = req.CommitmentRating,
            GeneralRating = req.GeneralRating,
            Comment = req.Comment
        };

        _db.Reviews.Add(review);

        // تحديث تقييم المتجر تلقائياً
        await UpdateShopRatingAsync(request.SelectedShopId.Value);

        await _db.SaveChangesAsync();

        var avg = ratings.Average();

        return new ReviewResponse2(
            review.Id, review.RequestId, request.SelectedShop!.Name,
            review.QualityRating, review.CommunicationRating,
            review.CommitmentRating, review.GeneralRating,
            avg, review.Comment, review.CreatedAt);
    }

    private async Task UpdateShopRatingAsync(Guid shopId)
    {
        var reviews = await _db.Reviews
            .Where(r => r.ShopId == shopId)
            .ToListAsync();

        if (reviews.Count == 0) return;

        var shop = await _db.Shops.FindAsync(shopId);
        if (shop == null) return;

        shop.Rating = (float)reviews.Average(r =>
            (r.QualityRating + r.CommunicationRating +
             r.CommitmentRating + r.GeneralRating) / 4.0);

        shop.TotalJobs = await _db.Requests
            .CountAsync(r => r.SelectedShopId == shopId &&
                             r.Status == RequestStatus.Completed);
    }

    public Task<PagedResult<ReviewResponse2>> GetShopReviewsAsync(Guid shopId, PaginationRequest pagination)
        => _db.Reviews
            .Where(r => r.ShopId == shopId)
            .OrderByDescending(r => r.CreatedAt)
            .Select(r => new ReviewResponse2(
                r.Id, r.RequestId, r.Request.SelectedShop!.Name,
                r.QualityRating, r.CommunicationRating,
                r.CommitmentRating, r.GeneralRating,
                (r.QualityRating + r.CommunicationRating +
                 r.CommitmentRating + r.GeneralRating) / 4.0,
                r.Comment, r.CreatedAt))
            .ToPagedAsync(pagination);
}