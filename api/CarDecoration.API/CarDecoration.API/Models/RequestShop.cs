namespace CarDecoration.API.Models;

public enum RequestShopStatus { Pending, Accepted, Rejected }

public class RequestShop : BaseEntity
{
    public Guid RequestId { get; set; }
    public Guid ShopId { get; set; }
    public RequestShopStatus Status { get; set; } = RequestShopStatus.Pending;

    public Request Request { get; set; } = null!;
    public Shop Shop { get; set; } = null!;
}