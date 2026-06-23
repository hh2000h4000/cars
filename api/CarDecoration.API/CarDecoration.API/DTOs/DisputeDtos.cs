namespace CarDecoration.API.DTOs;

public record CreateDisputeRequest(
    Guid RequestId,
    string Reason,
    string Details,
    List<string>? Evidence
);

public record DisputeResponse(
    Guid Id,
    Guid RequestId,
    string CustomerName,
    string ShopName,
    string Reason,
    string Details,
    List<string> Evidence,
    string Status,
    DateTime CreatedAt
);

public record UpdateDisputeStatusRequest(
    string Status
);