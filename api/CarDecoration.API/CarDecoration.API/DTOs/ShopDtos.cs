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

public record PendingShopResponse(
    Guid Id,
    string Name,
    string OwnerName,
    string City,
    string Phone,
    string CrNumber,
    string? LogoUrl,
    string Status,
    DateTime CreatedAt
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

public record MyShopResponse(
    Guid Id,
    string Name,
    string City,
    float Rating,
    int TotalJobs
);

public record ReviewResponse(
    int QualityRating,
    int CommunicationRating,
    int CommitmentRating,
    int GeneralRating,
    string? Comment,
    DateTime CreatedAt
);