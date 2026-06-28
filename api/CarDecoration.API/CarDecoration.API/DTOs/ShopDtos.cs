namespace CarDecoration.API.DTOs;

public record ShopResponse(
    Guid Id,
    string Name,
    string City,
    string Phone,
    string? LogoUrl,
    float Rating,
    int TotalJobs,
    int ReviewCount,
    string Status
);

public record PendingShopResponse(
    Guid Id,
    string Name,
    string OwnerName,
    string OwnerPhone,
    string City,
    string Phone,
    string CrNumber,
    string? IdNumber,
    string? LogoUrl,
    string? CrDocumentUrl,
    string? IdDocumentUrl,
    string Status,
    DateTime CreatedAt,
    string? RejectionReason
);

public record RejectShopRequest(string Reason);

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
    string Phone,
    string? LogoUrl,
    string Status,
    string CrNumber,
    string? IdNumber,
    float Rating,
    int TotalJobs,
    string? RejectionReason
);

public record UpdateMyShopRequest(
    string Name,
    string Phone,
    string City,
    string? LogoUrl
);

public record ResubmitMyShopRequest(
    string Name,
    string Phone,
    string City,
    string CrNumber,
    string? IdNumber,
    string? LogoUrl,
    string? CrDocumentUrl,
    string? IdDocumentUrl
);

public record ReviewResponse(
    int QualityRating,
    int CommunicationRating,
    int CommitmentRating,
    int GeneralRating,
    string? Comment,
    DateTime CreatedAt
);