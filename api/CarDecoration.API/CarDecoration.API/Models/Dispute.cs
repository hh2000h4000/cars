namespace CarDecoration.API.Models;

public enum DisputeReason { ServiceQuality, Pricing, Delay, Other }
public enum DisputeStatus { UnderReview, WaitingShop, Resolved }

public class Dispute : BaseEntity
{
    public Guid RequestId { get; set; }
    public Guid UserId { get; set; }
    public DisputeReason Reason { get; set; }
    public string Details { get; set; } = string.Empty;
    public List<string> Evidence { get; set; } = [];
    public DisputeStatus Status { get; set; } = DisputeStatus.UnderReview;

    public Request Request { get; set; } = null!;
    public User User { get; set; } = null!;
}