namespace CarDecoration.API.DTOs;

public record CreateVehicleRequest(
    string Brand,
    string Model,
    int Year,
    string? Color,
    string? PlateNumber,
    List<string>? ImageUrls
);

public record UpdateVehicleRequest(
    string Brand,
    string Model,
    int Year,
    string? Color,
    string? PlateNumber,
    List<string>? ImageUrls
);

public record VehicleResponse(
    Guid Id,
    string Brand,
    string Model,
    int Year,
    string? Color,
    string? PlateNumber,
    List<string> ImageUrls,
    DateTime CreatedAt
);