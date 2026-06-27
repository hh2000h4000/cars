namespace CarDecoration.API.DTOs;

public record UserProfileResponse(
    string FullName,
    string Phone,
    string Email,
    int VehicleCount,
    int ActiveRequestCount,
    int ReviewCount
);

public record UpdateProfileRequest(
    string FullName,
    string Phone
);
