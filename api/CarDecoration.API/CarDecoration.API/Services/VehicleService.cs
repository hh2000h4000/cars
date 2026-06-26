using CarDecoration.API.Data;
using CarDecoration.API.DTOs;
using CarDecoration.API.Helpers;
using CarDecoration.API.Models;
using Microsoft.EntityFrameworkCore;

namespace CarDecoration.API.Services;

public class VehicleService
{
    private readonly AppDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public VehicleService(AppDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public Task<PagedResult<VehicleResponse>> GetMyVehiclesAsync(PaginationRequest pagination)
    {
        var userId = _currentUser.UserId ?? throw new Exception("غير مصرح");

        return _db.Vehicles
            .Where(v => v.OwnerId == userId)
            .OrderByDescending(v => v.CreatedAt)
            .Select(v => new VehicleResponse(
                v.Id, v.Brand, v.Model, v.Year, v.Color, v.PlateNumber,
                v.VehicleImages.OrderBy(i => i.Order).Select(i => i.Url).ToList(),
                v.CreatedAt))
            .ToPagedAsync(pagination);
    }

    public async Task<VehicleResponse> AddVehicleAsync(CreateVehicleRequest req)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var vehicle = new Vehicle
        {
            OwnerId     = userId,
            Brand       = req.Brand,
            Model       = req.Model,
            Year        = req.Year,
            Color       = req.Color,
            PlateNumber = req.PlateNumber
        };

        _db.Vehicles.Add(vehicle);
        await _db.SaveChangesAsync();

        if (req.ImageUrls != null && req.ImageUrls.Count > 0)
        {
            for (int i = 0; i < req.ImageUrls.Count; i++)
                _db.VehicleImages.Add(new VehicleImage { VehicleId = vehicle.Id, Url = req.ImageUrls[i], Order = i });
            await _db.SaveChangesAsync();
        }

        return new VehicleResponse(
            vehicle.Id, vehicle.Brand, vehicle.Model,
            vehicle.Year, vehicle.Color, vehicle.PlateNumber,
            req.ImageUrls ?? [],
            vehicle.CreatedAt);
    }

    public async Task<VehicleResponse> UpdateVehicleAsync(Guid id, UpdateVehicleRequest req)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var vehicle = await _db.Vehicles
            .Include(v => v.VehicleImages)
            .FirstOrDefaultAsync(v => v.Id == id && v.OwnerId == userId)
            ?? throw new Exception("المركبة غير موجودة");

        vehicle.Brand       = req.Brand;
        vehicle.Model       = req.Model;
        vehicle.Year        = req.Year;
        vehicle.Color       = req.Color;
        vehicle.PlateNumber = req.PlateNumber;

        _db.VehicleImages.RemoveRange(vehicle.VehicleImages);
        await _db.SaveChangesAsync();

        if (req.ImageUrls != null && req.ImageUrls.Count > 0)
        {
            for (int i = 0; i < req.ImageUrls.Count; i++)
                _db.VehicleImages.Add(new VehicleImage { VehicleId = vehicle.Id, Url = req.ImageUrls[i], Order = i });
            await _db.SaveChangesAsync();
        }

        return new VehicleResponse(
            vehicle.Id, vehicle.Brand, vehicle.Model,
            vehicle.Year, vehicle.Color, vehicle.PlateNumber,
            req.ImageUrls ?? [],
            vehicle.CreatedAt);
    }

    public async Task DeleteVehicleAsync(Guid id)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var vehicle = await _db.Vehicles
            .FirstOrDefaultAsync(v => v.Id == id && v.OwnerId == userId)
            ?? throw new Exception("المركبة غير موجودة");

        vehicle.IsDeleted = true;
        vehicle.DeletedAt = DateTime.UtcNow;
        vehicle.DeletedBy = userId;

        await _db.SaveChangesAsync();
    }
}
