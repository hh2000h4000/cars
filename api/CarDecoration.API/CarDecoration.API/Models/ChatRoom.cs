namespace CarDecoration.API.Models;

public class ChatRoom : BaseEntity
{
    public Guid RequestId { get; set; }
    public Guid ShopId { get; set; }

    public Request Request { get; set; } = null!;
    public Shop Shop { get; set; } = null!;
    public List<Message> Messages { get; set; } = [];
}