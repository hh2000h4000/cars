using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarDecoration.API.Migrations
{
    /// <inheritdoc />
    public partial class AddColorToVehicles : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Color",
                table: "Vehicles",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Color",
                table: "Vehicles");
        }
    }
}
