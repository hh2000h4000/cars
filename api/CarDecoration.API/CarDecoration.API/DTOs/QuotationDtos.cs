namespace CarDecoration.API.DTOs;

public record CreateQuotationRequest(
    Guid RequestId,
    string ServiceDetails,
    string Parts,
    string? Warranty,
    decimal VisitFee,
    string Duration,
    decimal FinalPrice
);

public record UpdateQuotationRequest(
    string ServiceDetails,
    string Parts,
    string? Warranty,
    decimal VisitFee,
    string Duration,
    decimal FinalPrice
);

public record QuotationResponse(
    Guid Id,
    Guid RequestId,
    Guid ShopId,
    string ShopName,
    string ServiceDetails,
    string Parts,
    string? Warranty,
    decimal VisitFee,
    string Duration,
    decimal FinalPrice,
    string Status,
    DateTime CreatedAt,
    Guid? ChatRoomId
);