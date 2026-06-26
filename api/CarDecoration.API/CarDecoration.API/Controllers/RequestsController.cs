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
    private readonly ILogger<RequestsController> _logger;

    public RequestsController(RequestService service, ILogger<RequestsController> logger)
    {
        _service = service;
        _logger = logger;
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
            _logger.LogError(ex, "Create request failed");
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMyRequests([FromQuery] PaginationRequest pagination)
    {
        try
        {
            var result = await _service.GetMyRequestsAsync(pagination);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "GetMyRequests failed");
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("shop")]
    public async Task<IActionResult> GetShopRequests([FromQuery] PaginationRequest pagination)
    {
        try
        {
            var result = await _service.GetShopRequestsAsync(pagination);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "GetShopRequests failed");
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
            _logger.LogError(ex, "AcceptRequest failed for {RequestId}", id);
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, UpdateRequestRequest req)
    {
        try
        {
            var result = await _service.UpdateRequestAsync(id, req);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Update request failed for {RequestId}", id);
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id}/complete")]
    public async Task<IActionResult> Complete(Guid id)
    {
        try
        {
            await _service.CompleteAsync(id);
            return Ok(new { message = "تم إنهاء الطلب بنجاح" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Complete request failed for {RequestId}", id);
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
            _logger.LogError(ex, "Cancel request failed for {RequestId}", id);
            return BadRequest(new { message = ex.Message });
        }
    }
}