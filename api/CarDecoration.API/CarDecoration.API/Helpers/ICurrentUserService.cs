namespace CarDecoration.API.Helpers;

public interface ICurrentUserService
{
    Guid? UserId { get; }
    string? UserRole { get; }
}