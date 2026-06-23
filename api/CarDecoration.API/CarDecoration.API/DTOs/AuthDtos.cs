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
    string FullName,
    string Email,
    string Role
);

public record ShopRegisterRequest(
    string FullName,
    string Phone,
    string Email,
    string Password,
    string ShopName,
    string CrNumber,
    string City,
    string ShopPhone
);