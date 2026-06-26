using CarDecoration.API.Data;
using CarDecoration.API.DTOs;
using CarDecoration.API.Helpers;
using CarDecoration.API.Hubs;
using CarDecoration.API.Models;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace CarDecoration.API.Services;

public class ChatService
{
    private readonly AppDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IHubContext<ChatHub> _hub;

    public ChatService(AppDbContext db, ICurrentUserService currentUser, IHubContext<ChatHub> hub)
    {
        _db = db;
        _currentUser = currentUser;
        _hub = hub;
    }

    // إرسال رسالة
    public async Task<MessageResponse> SendMessageAsync(SendMessageRequest req)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        // تأكد أن المستخدم طرف في هذه المحادثة
        var chatRoom = await _db.ChatRooms
            .Include(c => c.Request)
            .Include(c => c.Shop)
            .FirstOrDefaultAsync(c => c.Id == req.ChatRoomId)
            ?? throw new Exception("المحادثة غير موجودة");

        var isCustomer = chatRoom.Request.CustomerId == userId;
        var isShopOwner = chatRoom.Shop.OwnerId == userId;

        if (!isCustomer && !isShopOwner)
            throw new Exception("غير مصرح");

        if (string.IsNullOrWhiteSpace(req.Text) && (req.Attachments == null || req.Attachments.Count == 0))
            throw new Exception("يجب إرسال نص أو مرفق");

        var message = new Message
        {
            ChatRoomId = req.ChatRoomId,
            SenderId = userId,
            Text = req.Text,
            Attachments = req.Attachments ?? []
        };

        _db.Messages.Add(message);
        await _db.SaveChangesAsync();

        var sender = await _db.Users.FindAsync(userId);

        var response = new MessageResponse(
            message.Id,
            userId,
            sender!.FullName,
            sender.Role.ToString(),
            message.Text,
            message.Attachments,
            message.CreatedAt);

        // Push message to everyone in the room group (real-time delivery)
        await _hub.Clients
            .Group($"room_{req.ChatRoomId}")
            .SendAsync("ReceiveMessage", response);

        // Notify the OTHER party so their badge/shell updates instantly
        var recipientId = isCustomer ? chatRoom.Shop.OwnerId : chatRoom.Request.CustomerId;
        await _hub.Clients
            .User(recipientId.ToString())
            .SendAsync("NewMessageNotification", req.ChatRoomId.ToString());

        return response;
    }

    // عرض المحادثة
    public async Task<ChatRoomResponse> GetChatRoomAsync(Guid chatRoomId)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var chatRoom = await _db.ChatRooms
            .Include(c => c.Request).ThenInclude(r => r.Customer)
            .Include(c => c.Shop)
            .Include(c => c.Messages).ThenInclude(m => m.Sender)
            .FirstOrDefaultAsync(c => c.Id == chatRoomId)
            ?? throw new Exception("المحادثة غير موجودة");

        var isCustomer = chatRoom.Request.CustomerId == userId;
        var isShopOwner = chatRoom.Shop.OwnerId == userId;

        if (!isCustomer && !isShopOwner)
            throw new Exception("غير مصرح");

        var messages = chatRoom.Messages
            .OrderBy(m => m.CreatedAt)
            .Select(m => new MessageResponse(
                m.Id,
                m.SenderId,
                m.Sender.FullName,
                m.Sender.Role.ToString(),
                m.Text,
                m.Attachments,
                m.CreatedAt))
            .ToList();

        return new ChatRoomResponse(
            chatRoom.Id,
            chatRoom.RequestId,
            chatRoom.Shop.Name,
            chatRoom.Request.Customer.FullName,
            messages);
    }

    // عرض كل محادثات العميل
    public async Task<List<ChatRoomResponse>> GetMyChatRoomsAsync()
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var role = _currentUser.UserRole;

        IQueryable<ChatRoom> query = _db.ChatRooms
            .Include(c => c.Request).ThenInclude(r => r.Customer)
            .Include(c => c.Shop)
            .Include(c => c.Messages).ThenInclude(m => m.Sender);

        if (role == "Customer")
            query = query.Where(c => c.Request.CustomerId == userId);
        else if (role == "ShopOwner")
            query = query.Where(c => c.Shop.OwnerId == userId);
        else
            throw new Exception("غير مصرح");

        var chatRooms = await query
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();

        return chatRooms.Select(c => new ChatRoomResponse(
            c.Id,
            c.RequestId,
            c.Shop.Name,
            c.Request.Customer.FullName,
            c.Messages.OrderBy(m => m.CreatedAt).Select(m => new MessageResponse(
                m.Id, m.SenderId, m.Sender.FullName, m.Sender.Role.ToString(),
                m.Text, m.Attachments, m.CreatedAt)).ToList()))
        .ToList();
    }
}