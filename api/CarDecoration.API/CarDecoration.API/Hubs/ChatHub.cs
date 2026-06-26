using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace CarDecoration.API.Hubs;

[Authorize]
public class ChatHub : Hub
{
    // Client calls this to subscribe to a specific chat room's messages
    public async Task JoinRoom(string roomId)
        => await Groups.AddToGroupAsync(Context.ConnectionId, $"room_{roomId}");

    // Client calls this when leaving a chat room
    public async Task LeaveRoom(string roomId)
        => await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"room_{roomId}");
}
