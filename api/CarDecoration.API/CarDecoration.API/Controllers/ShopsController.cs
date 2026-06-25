using CarDecoration.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CarDecoration.API.Controllers;

[ApiController]
[Route("api/shops")]
public class ShopsController : ControllerBase
{
    private readonly ShopService _service;

    public ShopsController(ShopService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetShops()
    {
        try
        {
            var result = await _service.GetApprovedShopsAsync();
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetShopDetails(Guid id)
    {
        try
        {
            var result = await _service.GetShopDetailsAsync(id);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("pending")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetPendingShops()
    {
        try
        {
            var result = await _service.GetPendingShopsAsync();
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id}/approve")]
    [Authorize]
    public async Task<IActionResult> Approve(Guid id)
    {
        try
        {
            await _service.ApproveShopAsync(id);
            return Ok(new { message = "تم اعتماد المتجر" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id}/reject")]
    [Authorize]
    public async Task<IActionResult> Reject(Guid id)
    {
        try
        {
            await _service.RejectShopAsync(id);
            return Ok(new { message = "تم رفض المتجر" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}