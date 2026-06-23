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
    int QualityRating,
    int CommunicationRating,
    int CommitmentRating,
    int GeneralRating,
    double AverageRating,
    string? Comment,
    DateTime CreatedAt
);