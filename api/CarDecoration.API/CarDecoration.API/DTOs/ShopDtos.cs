namespace CarDecoration.API.DTOs;

public record ShopResponse(
    Guid Id,
    string Name,
    string City,
    string Phone,
    string? LogoUrl,
    float Rating,
    int TotalJobs,
    string Status
);

public record ShopDetailsResponse(
    Guid Id,
    string Name,
    string City,
    string Phone,
    string? LogoUrl,
    float Rating,
    int TotalJobs,
    string Status,
    List<ReviewResponse> Reviews
);

public record ReviewResponse(
    int QualityRating,
    int CommunicationRating,
    int CommitmentRating,
    int GeneralRating,
    string? Comment,
    DateTime CreatedAt
);