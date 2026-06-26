using CarDecoration.API.DTOs;
using CarDecoration.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CarDecoration.API.Controllers;

[ApiController]
[Route("api/chats")]
[Authorize]
public class ChatsController : ControllerBase
{
    private readonly ChatService _service;

    public ChatsController(ChatService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetMyChatRooms([FromQuery] PaginationRequest pagination)
    {
        try
        {
            var result = await _service.GetMyChatRoomsAsync(pagination);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost("{id:guid}/read")]
    public async Task<IActionResult> MarkAsRead(Guid id)
    {
        try
        {
            await _service.MarkAsReadAsync(id);
            return NoContent();
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetChatRoom(Guid id)
    {
        try
        {
            var result = await _service.GetChatRoomAsync(id);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost("send")]
    public async Task<IActionResult> SendMessage(SendMessageRequest req)
    {
        try
        {
            var result = await _service.SendMessageAsync(req);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
