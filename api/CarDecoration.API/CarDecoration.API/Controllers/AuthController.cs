using CarDecoration.API.DTOs;
using CarDecoration.API.Services;
using Microsoft.AspNetCore.Mvc;

namespace CarDecoration.API.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly AuthService _auth;

    public AuthController(AuthService auth)
    {
        _auth = auth;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterRequest req)
    {
        try
        {
            var result = await _auth.RegisterAsync(req);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginRequest req)
    {
        try
        {
            var result = await _auth.LoginAsync(req);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost("shop/register")]
    public async Task<IActionResult> RegisterShop(ShopRegisterRequest req)
    {
        try
        {
            var result = await _auth.RegisterShopAsync(req);
            return Ok(result);
        }
        catch (Exception ex)
        {
            // Return inner exception so DB constraint errors are visible
            return BadRequest(new { message = ex.InnerException?.Message ?? ex.Message });
        }
    }
}