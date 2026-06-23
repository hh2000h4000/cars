namespace CarDecoration.API.Models;

public enum UserRole { Customer, ShopOwner, Admin }
public enum UserStatus { Active, Suspended }

public class User : BaseEntity
{
    public string FullName { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public UserRole Role { get; set; } = UserRole.Customer;
    public UserStatus Status { get; set; } = UserStatus.Active;

    public Shop? Shop { get; set; }
    public List<Vehicle> Vehicles { get; set; } = [];
    public List<Request> Requests { get; set; } = [];
}