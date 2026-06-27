namespace CarDecoration.API.Models;

public enum RequestShopStatus { Pending, Accepted, Rejected, Withdrawn }

public class RequestShop : BaseEntity
{
    public Guid RequestId { get; set; }
    public Guid ShopId { get; set; }
    public RequestShopStatus Status { get; set; } = RequestShopStatus.Pending;
    public DateTime? ViewedAt { get; set; }
    public DateTime? RespondedAt { get; set; }
    public DateTime? RejectedAt { get; set; }

    public Request Request { get; set; } = null!;
    public Shop Shop { get; set; } = null!;
}