namespace CarDecoration.API.Models;

public class Review : BaseEntity
{
    public Guid RequestId { get; set; }
    public Guid ShopId { get; set; }
    public int QualityRating { get; set; }
    public int CommunicationRating { get; set; }
    public int CommitmentRating { get; set; }
    public int GeneralRating { get; set; }
    public string? Comment { get; set; }

    public Request Request { get; set; } = null!;
    public Shop Shop { get; set; } = null!;
}