using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarDecoration.API.Migrations
{
    public partial class RequestLifecycleRedesign : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // ── 1. Migrate RequestStatus string values ──
            migrationBuilder.Sql(@"UPDATE ""Requests"" SET ""Status"" = 'Open' WHERE ""Status"" = 'Pending'");
            migrationBuilder.Sql(@"UPDATE ""Requests"" SET ""Status"" = 'ShopSelected' WHERE ""Status"" = 'Active'");

            // ── 2. Add new RequestShop timestamp columns ──
            migrationBuilder.AddColumn<DateTime>(
                name: "ViewedAt",
                table: "RequestShops",
                type: "timestamp without time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "RespondedAt",
                table: "RequestShops",
                type: "timestamp without time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "RejectedAt",
                table: "RequestShops",
                type: "timestamp without time zone",
                nullable: true);

            // ── 3. Fix ChatRoom unique constraint ──
            // Drop the old unique index on RequestId alone (created by EF Core 1-to-1 inference)
            migrationBuilder.Sql(@"
                DO $$
                BEGIN
                    IF EXISTS (
                        SELECT 1 FROM pg_indexes
                        WHERE tablename = 'ChatRooms'
                        AND indexname = 'IX_ChatRooms_RequestId'
                    ) THEN
                        DROP INDEX ""IX_ChatRooms_RequestId"";
                    END IF;
                END $$;
            ");

            // Add composite unique index (RequestId, ShopId)
            migrationBuilder.CreateIndex(
                name: "IX_ChatRooms_RequestId_ShopId",
                table: "ChatRooms",
                columns: new[] { "RequestId", "ShopId" },
                unique: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"UPDATE ""Requests"" SET ""Status"" = 'Pending' WHERE ""Status"" = 'Open'");
            migrationBuilder.Sql(@"UPDATE ""Requests"" SET ""Status"" = 'Active' WHERE ""Status"" = 'ShopSelected'");
            migrationBuilder.Sql(@"UPDATE ""Requests"" SET ""Status"" = 'Active' WHERE ""Status"" = 'InProgress'");

            migrationBuilder.DropIndex(name: "IX_ChatRooms_RequestId_ShopId", table: "ChatRooms");

            migrationBuilder.DropColumn(name: "ViewedAt", table: "RequestShops");
            migrationBuilder.DropColumn(name: "RespondedAt", table: "RequestShops");
            migrationBuilder.DropColumn(name: "RejectedAt", table: "RequestShops");
        }
    }
}
