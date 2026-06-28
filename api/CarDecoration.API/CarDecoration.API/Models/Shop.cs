namespace CarDecoration.API.Models;

public enum ShopStatus { Pending, Approved, Rejected, DocsRequested, Suspended }

public class Shop : BaseEntity
{
    public Guid OwnerId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string CrNumber { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string Street { get; set; } = string.Empty;
    public string District { get; set; } = string.Empty;
    public string? BuildingNumber { get; set; }
    public string PostalCode { get; set; } = string.Empty;
    public string? AdditionalNumber { get; set; }
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public string Phone { get; set; } = string.Empty;
    public string? LogoUrl { get; set; }
    public string? IdNumber { get; set; }
    public string? CrDocumentUrl { get; set; }
    public string? IdDocumentUrl { get; set; }
    public string? RejectionReason { get; set; }
    public ShopStatus Status { get; set; } = ShopStatus.Pending;
    public float Rating { get; set; } = 0;
    public int TotalJobs { get; set; } = 0;

    public User Owner { get; set; } = null!;
    public List<RequestShop> RequestShops { get; set; } = [];
    public List<Quotation> Quotations { get; set; } = [];
    public List<ChatRoom> ChatRooms { get; set; } = [];
    public List<Review> Reviews { get; set; } = [];
}