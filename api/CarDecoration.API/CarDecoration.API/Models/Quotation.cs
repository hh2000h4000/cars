namespace CarDecoration.API.Models;

public enum QuotationStatus { Pending, Accepted, Rejected, Withdrawn }

public class Quotation : BaseEntity
{
    public Guid RequestId { get; set; }
    public Guid ShopId { get; set; }
    public string ServiceDetails { get; set; } = string.Empty;
    public string Parts { get; set; } = string.Empty;
    public string? Warranty { get; set; }
    public decimal VisitFee { get; set; }
    public string Duration { get; set; } = string.Empty;
    public decimal FinalPrice { get; set; }
    public QuotationStatus Status { get; set; } = QuotationStatus.Pending;

    public Request Request { get; set; } = null!;
    public Shop Shop { get; set; } = null!;
}