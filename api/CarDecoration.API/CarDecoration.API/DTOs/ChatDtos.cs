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

public record ChatRoomResponse(
    Guid Id,
    Guid RequestId,
    string ShopName,
    string CustomerName,
    List<MessageResponse> Messages
);