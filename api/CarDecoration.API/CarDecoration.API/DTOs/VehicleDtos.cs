namespace CarDecoration.API.DTOs;

public record CreateVehicleRequest(
    string Brand,
    string Model,
    int Year,
    string? PlateNumber
);

public record VehicleResponse(
    Guid Id,
    string Brand,
    string Model,
    int Year,
    string? PlateNumber,
    List<string> ImageUrls,
    DateTime CreatedAt
);