namespace CarDecoration.API.Models;

public abstract class BaseEntity
{
    public Guid Id { get; set; } = Guid.NewGuid();

    // متى؟
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }

    // من؟
    public Guid? CreatedBy { get; set; }
    public Guid? UpdatedBy { get; set; }

    // حذف ناعم
    public bool IsDeleted { get; set; } = false;
    public DateTime? DeletedAt { get; set; }
    public Guid? DeletedBy { get; set; }
}