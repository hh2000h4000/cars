namespace CarDecoration.API.DTOs;

public record SendMessageRequest(
    Guid ChatRoomId,
    string? Text,
    List<string>? Attachments
);

public record MessageResponse(
    Guid Id,
    Guid SenderId,
    string SenderName,
    string SenderRole,
    string? Text,
    List<string> Attachments,
    DateTime SentAt
);

// Lightweight summary returned by GET /api/chats — no messages array
public record ChatRoomSummaryResponse(
    Guid Id,
    Guid RequestId,
    string ShopName,
    string CustomerName,
    string? LastMessageText,
    DateTime? LastMessageAt,
    int UnreadCount
);

// Full detail returned by GET /api/chats/{id} — includes all messages
public record ChatRoomResponse(
    Guid Id,
    Guid RequestId,
    string ShopName,
    string CustomerName,
    List<MessageResponse> Messages
);