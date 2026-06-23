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

    public async Task<List<VehicleResponse>> GetMyVehiclesAsync()
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        return await _db.Vehicles
            .Where(v => v.OwnerId == userId)
            .OrderByDescending(v => v.CreatedAt)
            .Select(v => new VehicleResponse(
                v.Id, v.Brand, v.Model, v.Year, v.PlateNumber, v.Images, v.CreatedAt))
            .ToListAsync();
    }

    public async Task<VehicleResponse> AddVehicleAsync(CreateVehicleRequest req)
    {
        var userId = _currentUser.UserId
            ?? throw new Exception("غير مصرح");

        var vehicle = new Vehicle
        {
            OwnerId = userId,
            Brand = req.Brand,
            Model = req.Model,
            Year = req.Year,
            PlateNumber = req.PlateNumber
        };

        _db.Vehicles.Add(vehicle);
        await _db.SaveChangesAsync();

        return new VehicleResponse(
            vehicle.Id, vehicle.Brand, vehicle.Model,
            vehicle.Year, vehicle.PlateNumber, vehicle.Images, vehicle.CreatedAt);
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