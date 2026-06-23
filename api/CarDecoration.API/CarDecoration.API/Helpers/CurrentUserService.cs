using System.Security.Claims;
using CarDecoration.API.Helpers;

namespace CarDecoration.API.Helpers;

public class CurrentUserService : ICurrentUserService
{
    public Guid? UserId { get; }
    public string? UserRole { get; }

    public CurrentUserService(IHttpContextAccessor accessor)
    {
        var user = accessor.HttpContext?.User;
        var idClaim = user?.FindFirstValue(ClaimTypes.NameIdentifier);
        if (Guid.TryParse(idClaim, out var id))
            UserId = id;
        UserRole = user?.FindFirstValue(ClaimTypes.Role);
    }
}