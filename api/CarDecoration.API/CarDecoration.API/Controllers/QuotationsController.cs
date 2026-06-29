using CarDecoration.API.DTOs;
using CarDecoration.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CarDecoration.API.Controllers;

[ApiController]
[Route("api/quotations")]
[Authorize]
public class QuotationsController : ControllerBase
{
    private readonly QuotationService _service;

    public QuotationsController(QuotationService service)
    {
        _service = service;
    }

    [HttpPost]
    public async Task<IActionResult> Create(CreateQuotationRequest req)
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

    [HttpGet("request/{requestId}")]
    public async Task<IActionResult> GetRequestQuotations(Guid requestId)
    {
        try
        {
            var result = await _service.GetRequestQuotationsAsync(requestId);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id}/accept")]
    public async Task<IActionResult> Accept(Guid id)
    {
        try
        {
            var chatRoomId = await _service.AcceptAsync(id);
            return Ok(new { chatRoomId });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, UpdateQuotationRequest req)
    {
        try
        {
            var result = await _service.UpdateAsync(id, req);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("my/{requestId}")]
    public async Task<IActionResult> GetMyQuotation(Guid requestId)
    {
        try
        {
            var result = await _service.GetMyQuotationAsync(requestId);
            if (result == null) return NoContent();
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}