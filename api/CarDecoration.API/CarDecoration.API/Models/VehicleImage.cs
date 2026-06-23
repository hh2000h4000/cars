namespace CarDecoration.API.Models;

public class VehicleImage : BaseEntity
{
    public Guid VehicleId { get; set; }
    public string Url { get; set; } = string.Empty;
    public int Order { get; set; }

    public Vehicle Vehicle { get; set; } = null!;
}
