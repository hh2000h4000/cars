namespace CarDecoration.API.Models;

public class Vehicle : BaseEntity
{
    public Guid OwnerId { get; set; }
    public string Brand { get; set; } = string.Empty;
    public string Model { get; set; } = string.Empty;
    public int Year { get; set; }
    public string? PlateNumber { get; set; }

    public User Owner { get; set; } = null!;
    public List<Request> Requests { get; set; } = [];
    public List<VehicleImage> VehicleImages { get; set; } = [];
}