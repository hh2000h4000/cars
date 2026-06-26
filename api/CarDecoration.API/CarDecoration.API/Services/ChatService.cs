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

        // Mark as read for the sender immediately
        if (isCustomer)
            chatRoom.LastReadCustomerAt = message.CreatedAt;
        else
            chatRoom.LastReadShopOwnerAt = message.CreatedAt;

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

        // Push to everyone in the room group (real-time delivery)
        await _hub.Clients
            .Group($"room_{req.ChatRoomId}")
            .SendAsync("ReceiveMessage", response);

        // Notify the other party so their badge updates instantly
        var recipientId = isCustomer ? chatRoom.Shop.OwnerId : chatRoom.Request.CustomerId;
        await _hub.Clients
            .User(recipientId.ToString())
            .SendAsync("NewMessageNotification", req.ChatRoomId.ToString());

        return response;
    }

    // تحديد المحادثة كمقروءة
    public async Task MarkAsReadAsync(Guid chatRoomId)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var chatRoom = await _db.ChatRooms
            .Include(c => c.Request)
            .Include(c => c.Shop)
            .FirstOrDefaultAsync(c => c.Id == chatRoomId)
            ?? throw new Exception("المحادثة غير موجودة");

        var isCustomer = chatRoom.Request.CustomerId == userId;
        var isShopOwner = chatRoom.Shop.OwnerId == userId;

        if (!isCustomer && !isShopOwner)
            throw new Exception("غير مصرح");

        if (isCustomer)
            chatRoom.LastReadCustomerAt = DateTime.UtcNow;
        else
            chatRoom.LastReadShopOwnerAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();
    }

    // قائمة المحادثات — خفيفة، بدون تحميل كل الرسائل
    public async Task<List<ChatRoomSummaryResponse>> GetMyChatRoomsAsync()
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var role = _currentUser.UserRole;
        var isCustomer = role == "Customer";

        if (role != "Customer" && role != "ShopOwner")
            throw new Exception("غير مصرح");

        var rooms = await _db.ChatRooms
            .Where(c => isCustomer
                ? c.Request.CustomerId == userId
                : c.Shop.OwnerId == userId)
            .Select(c => new {
                c.Id,
                c.RequestId,
                ShopName = c.Shop.Name,
                CustomerName = c.Request.Customer.FullName,
                LastMessageText = c.Messages
                    .OrderByDescending(m => m.CreatedAt)
                    .Select(m => m.Text)
                    .FirstOrDefault(),
                LastMessageAt = c.Messages
                    .OrderByDescending(m => m.CreatedAt)
                    .Select(m => (DateTime?)m.CreatedAt)
                    .FirstOrDefault(),
                // Compute both sides — pick the right one in memory
                UnreadAsCustomer = c.Messages.Count(m =>
                    m.SenderId != userId &&
                    (c.LastReadCustomerAt == null || m.CreatedAt > c.LastReadCustomerAt)),
                UnreadAsShopOwner = c.Messages.Count(m =>
                    m.SenderId != userId &&
                    (c.LastReadShopOwnerAt == null || m.CreatedAt > c.LastReadShopOwnerAt)),
            })
            .OrderByDescending(c => c.LastMessageAt ?? DateTime.MinValue)
            .ToListAsync();

        return rooms.Select(c => new ChatRoomSummaryResponse(
            c.Id,
            c.RequestId,
            c.ShopName,
            c.CustomerName,
            c.LastMessageText,
            c.LastMessageAt,
            isCustomer ? c.UnreadAsCustomer : c.UnreadAsShopOwner
        )).ToList();
    }

    // تفاصيل المحادثة — كل الرسائل لشاشة الدردشة
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
}
