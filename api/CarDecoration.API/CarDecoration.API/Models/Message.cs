namespace CarDecoration.API.Models;

public class Message : BaseEntity
{
    public Guid ChatRoomId { get; set; }
    public Guid SenderId { get; set; }
    public string? Text { get; set; }
    public List<string> Attachments { get; set; } = [];

    public ChatRoom ChatRoom { get; set; } = null!;
    public User Sender { get; set; } = null!;
}