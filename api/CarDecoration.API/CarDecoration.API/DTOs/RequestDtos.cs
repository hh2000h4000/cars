namespace CarDecoration.API.DTOs;

public record CreateRequestRequest(
    Guid VehicleId,
    string Description,
    string Location,
    DateTime? PreferredDate,
    string? Notes,
    List<Guid> ShopIds,
    List<string>? ImageUrls
);

public record UpdateRequestRequest(
    string Description,
    string Location,
    DateTime? PreferredDate,
    string? Notes,
    List<string>? ImageUrls
);

public record RequestResponse(
    Guid Id,
    int RequestNumber,
    Guid VehicleId,
    string VehicleBrand,
    string VehicleModel,
    int VehicleYear,
    string? VehicleColor,
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
    string ShopStatus,
    Guid? ChatRoomId,
    DateTime CreatedAt
);