namespace CarDecoration.API.Models;

public class RequestImage : BaseEntity
{
    public Guid RequestId { get; set; }
    public string Url { get; set; } = string.Empty;
    public int Order { get; set; }

    public Request Request { get; set; } = null!;
}