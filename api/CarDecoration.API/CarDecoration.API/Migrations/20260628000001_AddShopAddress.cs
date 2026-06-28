using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarDecoration.API.Migrations
{
    /// <inheritdoc />
    public partial class AddShopAddress : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Street",
                table: "Shops",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "District",
                table: "Shops",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "BuildingNumber",
                table: "Shops",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PostalCode",
                table: "Shops",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "AdditionalNumber",
                table: "Shops",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<double>(
                name: "Latitude",
                table: "Shops",
                type: "double precision",
                nullable: true);

            migrationBuilder.AddColumn<double>(
                name: "Longitude",
                table: "Shops",
                type: "double precision",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(name: "Street", table: "Shops");
            migrationBuilder.DropColumn(name: "District", table: "Shops");
            migrationBuilder.DropColumn(name: "BuildingNumber", table: "Shops");
            migrationBuilder.DropColumn(name: "PostalCode", table: "Shops");
            migrationBuilder.DropColumn(name: "AdditionalNumber", table: "Shops");
            migrationBuilder.DropColumn(name: "Latitude", table: "Shops");
            migrationBuilder.DropColumn(name: "Longitude", table: "Shops");
        }
    }
}
