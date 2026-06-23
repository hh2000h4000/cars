using CarDecoration.API.DTOs;
using CarDecoration.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CarDecoration.API.Controllers;

[ApiController]
[Route("api/reviews")]
[Authorize]
public class ReviewsController : ControllerBase
{
    private readonly ReviewService _service;

    public ReviewsController(ReviewService service)
    {
        _service = service;
    }

    [HttpPost]
    public async Task<IActionResult> Create(CreateReviewRequest req)
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

    [HttpGet("shop/{shopId}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetShopReviews(Guid shopId)
    {
        try
        {
            var result = await _service.GetShopReviewsAsync(shopId);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}