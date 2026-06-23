namespace CarDecoration.API.Models;

public enum RequestStatus { Pending, Active, Completed, Cancelled }

public class Request : BaseEntity
{
    public Guid CustomerId { get; set; }
    public Guid VehicleId { get; set; }
    public string Description { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public DateTime? AppointmentDate { get; set; }
    public RequestStatus Status { get; set; } = RequestStatus.Pending;
    public Guid? SelectedShopId { get; set; }

    public User Customer { get; set; } = null!;
    public Vehicle Vehicle { get; set; } = null!;
    public Shop? SelectedShop { get; set; }
    public List<RequestShop> RequestShops { get; set; } = [];
    public List<Quotation> Quotations { get; set; } = [];
    public ChatRoom? ChatRoom { get; set; }
    public Dispute? Dispute { get; set; }
    public Review? Review { get; set; }
    public List<RequestImage> RequestImages { get; set; } = [];
    public string? Notes { get; set; }
    public int RequestNumber { get; set; }
}