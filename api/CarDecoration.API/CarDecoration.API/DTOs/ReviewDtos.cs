namespace CarDecoration.API.DTOs;

public record CreateReviewRequest(
    Guid RequestId,
    int QualityRating,
    int CommunicationRating,
    int CommitmentRating,
    int GeneralRating,
    string? Comment
);

public record ReviewResponse2(
    Guid Id,
    Guid RequestId,
    string ShopName,
    string CustomerName,
    int QualityRating,
    int CommunicationRating,
    int CommitmentRating,
    int GeneralRating,
    double AverageRating,
    string? Comment,
    DateTime CreatedAt
);

public record HasReviewedResponse(bool HasReviewed);