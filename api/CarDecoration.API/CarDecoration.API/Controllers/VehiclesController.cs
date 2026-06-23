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

    public VehiclesController(VehicleService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetMyVehicles()
    {
        try
        {
            var result = await _service.GetMyVehiclesAsync();
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost]
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
            return BadRequest(new
            {
                message = ex.Message,
                inner = ex.InnerException?.Message,
                inner2 = ex.InnerException?.InnerException?.Message
            });
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
            return BadRequest(new { message = ex.Message });
        }
    }
}