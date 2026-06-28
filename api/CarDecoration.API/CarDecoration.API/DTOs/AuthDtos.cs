namespace CarDecoration.API.DTOs;

public record RegisterRequest(
    string FullName,
    string Phone,
    string Email,
    string Password
);

public record LoginRequest(
    string Email,
    string Password
);

public record AuthResponse(
    string Token,
    string RefreshToken,
    string FullName,
    string Phone,
    string Email,
    string Role
);

public record RefreshRequest(string RefreshToken);

public record ShopRegisterRequest(
    string FullName,
    string Phone,
    string Email,
    string Password,
    string ShopName,
    string CrNumber,
    string City,
    string Street,
    string District,
    string PostalCode,
    string? BuildingNumber,
    string? AdditionalNumber,
    double? Latitude,
    double? Longitude,
    string ShopPhone,
    string IdNumber,
    string CrDocumentUrl,
    string IdDocumentUrl,
    string? LogoUrl
);