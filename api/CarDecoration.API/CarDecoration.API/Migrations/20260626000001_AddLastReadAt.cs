using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarDecoration.API.Migrations
{
    /// <inheritdoc />
    public partial class AddLastReadAt : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "LastReadCustomerAt",
                table: "ChatRooms",
                type: "timestamp without time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "LastReadShopOwnerAt",
                table: "ChatRooms",
                type: "timestamp without time zone",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "LastReadCustomerAt",
                table: "ChatRooms");

            migrationBuilder.DropColumn(
                name: "LastReadShopOwnerAt",
                table: "ChatRooms");
        }
    }
}
