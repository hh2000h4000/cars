using CarDecoration.API.DTOs;
using Microsoft.EntityFrameworkCore;

namespace CarDecoration.API.Helpers;

public static class QueryableExtensions
{
    public static async Task<PagedResult<T>> ToPagedAsync<T>(
        this IQueryable<T> query,
        PaginationRequest pagination)
    {
        var total = await query.CountAsync();
        var items = await query
            .Skip((pagination.Page - 1) * pagination.PageSize)
            .Take(pagination.PageSize)
            .ToListAsync();
        return PagedResult<T>.Create(items, total, pagination.Page, pagination.PageSize);
    }
}
