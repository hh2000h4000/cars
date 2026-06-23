namespace CarDecoration.API.DTOs;

public record CreateRequestRequest(
    Guid VehicleId,
    string Description,
    string Location,
    DateTime? PreferredDate,
    string? Notes,
    List<Guid> ShopIds
);

public record RequestResponse(
    Guid Id,
    int RequestNumber,
    Guid VehicleId,
    string VehicleBrand,
    string VehicleModel,
    int VehicleYear,
    string Description,
    string Location,
    DateTime? AppointmentDate,
    string? Notes,
    string Status,
    List<string> ShopNames,
    List<string> ImageUrls,
    DateTime CreatedAt
);

public record ShopRequestResponse(
    Guid Id,
    Guid CustomerId,
    string CustomerName,
    string VehicleBrand,
    string VehicleModel,
    int VehicleYear,
    string Description,
    string Location,
    DateTime? AppointmentDate,
    string Status,
    DateTime CreatedAt
);