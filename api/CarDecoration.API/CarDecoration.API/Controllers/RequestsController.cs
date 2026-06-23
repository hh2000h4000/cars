using CarDecoration.API.DTOs;
using CarDecoration.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CarDecoration.API.Controllers;

[ApiController]
[Route("api/requests")]
[Authorize]
public class RequestsController : ControllerBase
{
    private readonly RequestService _service;

    public RequestsController(RequestService service)
    {
        _service = service;
    }

    [HttpPost]
    public async Task<IActionResult> Create(CreateRequestRequest req)
    {
        try
        {
            var result = await _service.CreateAsync(req);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMyRequests()
    {
        try
        {
            var result = await _service.GetMyRequestsAsync();
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("shop")]
    public async Task<IActionResult> GetShopRequests()
    {
        try
        {
            var result = await _service.GetShopRequestsAsync();
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id}/accept")]
    public async Task<IActionResult> AcceptRequest(Guid id)
    {
        try
        {
            var chatRoomId = await _service.AcceptRequestAsync(id);
            return Ok(new { message = "تم قبول الطلب وفتح المحادثة", chatRoomId });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Cancel(Guid id)
    {
        try
        {
            await _service.CancelAsync(id);
            return Ok(new { message = "تم إلغاء الطلب" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}