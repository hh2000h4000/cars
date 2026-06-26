using CarDecoration.API.DTOs;
using CarDecoration.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CarDecoration.API.Controllers;

[ApiController]
[Route("api/vehicles")]
[Authorize]
public class VehiclesController : ControllerBase
{
    private readonly VehicleService _service;
    private readonly ILogger<VehiclesController> _logger;

    public VehiclesController(VehicleService service, ILogger<VehiclesController> logger)
    {
        _service = service;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetMyVehicles([FromQuery] PaginationRequest pagination)
    {
        try
        {
            var result = await _service.GetMyVehiclesAsync(pagination);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "GetMyVehicles failed");
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> AddVehicle(CreateVehicleRequest req)
    {
        try
        {
            var result = await _service.AddVehicleAsync(req);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "AddVehicle failed");
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateVehicle(Guid id, UpdateVehicleRequest req)
    {
        try
        {
            var result = await _service.UpdateVehicleAsync(id, req);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "UpdateVehicle failed for {VehicleId}", id);
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteVehicle(Guid id)
    {
        try
        {
            await _service.DeleteVehicleAsync(id);
            return Ok(new { message = "تم حذف المركبة" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "DeleteVehicle failed for {VehicleId}", id);
            return BadRequest(new { message = ex.Message });
        }
    }
}
