using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;

namespace CarDecoration.API.Helpers;

// Maps SignalR connections to user IDs using the JWT "sub" claim
public class JwtUserIdProvider : IUserIdProvider
{
    public string? GetUserId(HubConnectionContext connection)
        => connection.User?.FindFirst("sub")?.Value
           ?? connection.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
}
