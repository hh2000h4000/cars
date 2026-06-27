using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CarDecoration.API.Controllers;

[ApiController]
[Route("api/upload")]
[Authorize]
public class UploadController : ControllerBase
{
    private readonly IWebHostEnvironment _env;

    public UploadController(IWebHostEnvironment env)
    {
        _env = env;
    }

    [HttpPost]
    public async Task<IActionResult> Upload(IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest(new { message = "لم يتم اختيار ملف" });

        // التحقق من نوع الملف
        var allowedTypes = new[] { "image/jpeg", "image/png", "image/webp", "image/jpg" };
        if (!allowedTypes.Contains(file.ContentType.ToLower()))
            return BadRequest(new { message = "يسمح فقط بصور JPG و PNG و WebP" });

        // التحقق من حجم الملف (5MB max)
        if (file.Length > 5 * 1024 * 1024)
            return BadRequest(new { message = "حجم الصورة يجب أن يكون أقل من 5MB" });

        // إنشاء اسم فريد للملف
        var extension = Path.GetExtension(file.FileName).ToLower();
        var fileName = $"{Guid.NewGuid()}{extension}";

        // مسار الحفظ
        var uploadsPath = Path.Combine(_env.ContentRootPath, "uploads");
        if (!Directory.Exists(uploadsPath))
            Directory.CreateDirectory(uploadsPath);

        var filePath = Path.Combine(uploadsPath, fileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        // إرجاع الرابط
        var fileUrl = $"{Request.Scheme}://{Request.Host}/uploads/{fileName}";

        return Ok(new { url = fileUrl });
    }

    // ── رفع وثيقة مجهول (للتسجيل قبل إنشاء الحساب) ──────────────────────────
    [HttpPost("document")]
    [AllowAnonymous]
    [RequestSizeLimit(10 * 1024 * 1024)]
    public async Task<IActionResult> UploadDocument(IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest(new { message = "لم يتم اختيار ملف" });

        var allowedTypes = new[]
        {
            "image/jpeg", "image/jpg", "image/png",
            "application/pdf"
        };
        if (!allowedTypes.Contains(file.ContentType.ToLower()))
            return BadRequest(new { message = "يسمح فقط بـ JPG و PNG و PDF" });

        if (file.Length > 10 * 1024 * 1024)
            return BadRequest(new { message = "حجم الملف يجب أن يكون أقل من 10MB" });

        var extension = Path.GetExtension(file.FileName).ToLower();
        var fileName = $"{Guid.NewGuid()}{extension}";

        var uploadsPath = Path.Combine(_env.ContentRootPath, "uploads");
        if (!Directory.Exists(uploadsPath))
            Directory.CreateDirectory(uploadsPath);

        var filePath = Path.Combine(uploadsPath, fileName);
        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        var fileUrl = $"{Request.Scheme}://{Request.Host}/uploads/{fileName}";
        return Ok(new { url = fileUrl });
    }

    [HttpPost("multiple")]
    public async Task<IActionResult> UploadMultiple(List<IFormFile> files)
    {
        if (files == null || files.Count == 0)
            return BadRequest(new { message = "لم يتم اختيار ملفات" });

        if (files.Count > 5)
            return BadRequest(new { message = "الحد الأقصى 5 صور" });

        var allowedTypes = new[] { "image/jpeg", "image/png", "image/webp", "image/jpg" };
        var urls = new List<string>();

        var uploadsPath = Path.Combine(_env.ContentRootPath, "uploads");
        if (!Directory.Exists(uploadsPath))
            Directory.CreateDirectory(uploadsPath);

        foreach (var file in files)
        {
            if (!allowedTypes.Contains(file.ContentType.ToLower()))
                return BadRequest(new { message = $"الملف {file.FileName} غير مدعوم" });

            if (file.Length > 5 * 1024 * 1024)
                return BadRequest(new { message = $"الملف {file.FileName} أكبر من 5MB" });

            var extension = Path.GetExtension(file.FileName).ToLower();
            var fileName = $"{Guid.NewGuid()}{extension}";
            var filePath = Path.Combine(uploadsPath, fileName);

            using var stream = new FileStream(filePath, FileMode.Create);
            await file.CopyToAsync(stream);

            urls.Add($"{Request.Scheme}://{Request.Host}/uploads/{fileName}");
        }

        return Ok(new { urls });
    }
}