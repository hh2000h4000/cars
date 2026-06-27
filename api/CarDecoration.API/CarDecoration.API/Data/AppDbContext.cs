using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using CarDecoration.API.Models;
using CarDecoration.API.Helpers;
using System.Text.Json;

namespace CarDecoration.API.Data;

public class AppDbContext : DbContext
{
    private readonly ICurrentUserService _currentUser;

    public AppDbContext(DbContextOptions<AppDbContext> options, ICurrentUserService currentUser)
        : base(options)
    {
        _currentUser = currentUser;
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<Shop> Shops => Set<Shop>();
    public DbSet<Vehicle> Vehicles => Set<Vehicle>();
    public DbSet<VehicleImage> VehicleImages => Set<VehicleImage>();
    public DbSet<Request> Requests => Set<Request>();
    public DbSet<RequestImage> RequestImages => Set<RequestImage>();
    public DbSet<RequestShop> RequestShops => Set<RequestShop>();
    public DbSet<Quotation> Quotations => Set<Quotation>();
    public DbSet<ChatRoom> ChatRooms => Set<ChatRoom>();
    public DbSet<Message> Messages => Set<Message>();
    public DbSet<Dispute> Disputes => Set<Dispute>();
    public DbSet<Review> Reviews => Set<Review>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

    protected override void OnModelCreating(ModelBuilder b)
    {
        var listComparer = new ValueComparer<List<string>>(
            (c1, c2) => c1!.SequenceEqual(c2!),
            c => c.Aggregate(0, (a, v) => HashCode.Combine(a, v.GetHashCode())),
            c => c.ToList()
        );

        // ── Global Filters ──
        b.Entity<User>().HasQueryFilter(e => !e.IsDeleted);
        b.Entity<Shop>().HasQueryFilter(e => !e.IsDeleted);
        b.Entity<Vehicle>().HasQueryFilter(e => !e.IsDeleted);
        b.Entity<VehicleImage>().HasQueryFilter(e => !e.IsDeleted);
        b.Entity<Request>().HasQueryFilter(e => !e.IsDeleted);
        b.Entity<RequestImage>().HasQueryFilter(e => !e.IsDeleted);
        b.Entity<RequestShop>().HasQueryFilter(e => !e.IsDeleted);
        b.Entity<Quotation>().HasQueryFilter(e => !e.IsDeleted);
        b.Entity<ChatRoom>().HasQueryFilter(e => !e.IsDeleted);
        b.Entity<Message>().HasQueryFilter(e => !e.IsDeleted);
        b.Entity<Dispute>().HasQueryFilter(e => !e.IsDeleted);
        b.Entity<Review>().HasQueryFilter(e => !e.IsDeleted);

        // ── User ──
        b.Entity<User>(e => {
            e.HasIndex(u => u.Email).IsUnique();
            e.HasIndex(u => u.Phone).IsUnique();
            e.Property(u => u.Role).HasConversion<string>();
            e.Property(u => u.Status).HasConversion<string>();
        });

        // ── Shop ──
        b.Entity<Shop>(e => {
            e.HasIndex(s => s.CrNumber).IsUnique();
            e.Property(s => s.Status).HasConversion<string>();
            e.HasOne(s => s.Owner)
             .WithOne(u => u.Shop)
             .HasForeignKey<Shop>(s => s.OwnerId)
             .OnDelete(DeleteBehavior.Restrict);
        });

        // ── Vehicle ──
        b.Entity<Vehicle>(e => {
            e.HasOne(v => v.Owner)
             .WithMany(u => u.Vehicles)
             .HasForeignKey(v => v.OwnerId)
             .OnDelete(DeleteBehavior.Restrict);
            e.HasMany(v => v.VehicleImages)
             .WithOne(i => i.Vehicle)
             .HasForeignKey(i => i.VehicleId)
             .OnDelete(DeleteBehavior.Cascade);
        });

        // ── VehicleImage ──
        b.Entity<VehicleImage>(e => {
            e.HasIndex(i => i.VehicleId);
        });

        // ── Request ──
        b.Entity<Request>(e => {
            e.Property(r => r.Status).HasConversion<string>();
            e.HasOne(r => r.Customer)
             .WithMany(u => u.Requests)
             .HasForeignKey(r => r.CustomerId)
             .OnDelete(DeleteBehavior.Restrict);
            e.HasOne(r => r.Vehicle)
             .WithMany(v => v.Requests)
             .HasForeignKey(r => r.VehicleId)
             .OnDelete(DeleteBehavior.Restrict);
            e.HasOne(r => r.SelectedShop)
             .WithMany()
             .HasForeignKey(r => r.SelectedShopId)
             .OnDelete(DeleteBehavior.Restrict);
            e.HasMany(r => r.RequestImages)
             .WithOne(i => i.Request)
             .HasForeignKey(i => i.RequestId)
             .OnDelete(DeleteBehavior.Cascade);
        });

        // ── RequestImage ──
        b.Entity<RequestImage>(e => {
            e.HasIndex(i => i.RequestId);
        });

        // ── RequestShop ──
        b.Entity<RequestShop>(e => {
            e.HasIndex(rs => new { rs.RequestId, rs.ShopId }).IsUnique();
            e.Property(rs => rs.Status).HasConversion<string>();
        });

        // ── ChatRoom ──
        b.Entity<ChatRoom>(e => {
            e.HasIndex(c => new { c.RequestId, c.ShopId }).IsUnique();
        });

        // ── Quotation ──
        b.Entity<Quotation>(e => {
            e.Property(q => q.Status).HasConversion<string>();
            e.Property(q => q.VisitFee).HasPrecision(10, 2);
            e.Property(q => q.FinalPrice).HasPrecision(10, 2);
        });

        // ── Message ──
        b.Entity<Message>(e => {
            var prop = e.Property(m => m.Attachments)
             .HasConversion(
                 v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                 v => JsonSerializer.Deserialize<List<string>>(v, (JsonSerializerOptions?)null) ?? new List<string>()
             );
            prop.Metadata.SetValueComparer(listComparer);
            e.HasOne(m => m.Sender)
             .WithMany()
             .HasForeignKey(m => m.SenderId)
             .OnDelete(DeleteBehavior.Restrict);
        });

        // ── Dispute ──
        b.Entity<Dispute>(e => {
            e.Property(d => d.Reason).HasConversion<string>();
            e.Property(d => d.Status).HasConversion<string>();
            var prop = e.Property(d => d.Evidence)
             .HasConversion(
                 v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                 v => JsonSerializer.Deserialize<List<string>>(v, (JsonSerializerOptions?)null) ?? new List<string>()
             );
            prop.Metadata.SetValueComparer(listComparer);
            e.HasOne(d => d.Request)
             .WithOne(r => r.Dispute)
             .HasForeignKey<Dispute>(d => d.RequestId)
             .OnDelete(DeleteBehavior.Restrict);
        });

        // ── Review ──
        b.Entity<Review>(e => {
            e.HasOne(r => r.Request)
             .WithOne(req => req.Review)
             .HasForeignKey<Review>(r => r.RequestId)
             .OnDelete(DeleteBehavior.Restrict);
        });

        // ── RefreshToken ──
        b.Entity<RefreshToken>(e => {
            e.HasIndex(r => r.Token).IsUnique();
            e.HasOne(r => r.User)
             .WithMany()
             .HasForeignKey(r => r.UserId)
             .OnDelete(DeleteBehavior.Cascade);
        });
    }

    public override async Task<int> SaveChangesAsync(CancellationToken ct = default)
    {
        var now = DateTime.UtcNow;
        var userId = _currentUser.UserId;

        foreach (var entry in ChangeTracker.Entries<BaseEntity>())
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.CreatedAt = now;
                    entry.Entity.CreatedBy = userId;
                    break;

                case EntityState.Modified:
                    entry.Entity.UpdatedAt = now;
                    entry.Entity.UpdatedBy = userId;
                    entry.Property(e => e.CreatedAt).IsModified = false;
                    entry.Property(e => e.CreatedBy).IsModified = false;
                    break;
            }
        }

        return await base.SaveChangesAsync(ct);
    }

    public override int SaveChanges()
        => SaveChangesAsync().GetAwaiter().GetResult();
}