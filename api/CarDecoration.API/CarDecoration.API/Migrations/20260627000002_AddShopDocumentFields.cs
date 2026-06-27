using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarDecoration.API.Migrations
{
    /// <inheritdoc />
    public partial class AddShopDocumentFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "CrDocumentUrl",
                table: "Shops",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "IdDocumentUrl",
                table: "Shops",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "IdNumber",
                table: "Shops",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CrDocumentUrl",
                table: "Shops");

            migrationBuilder.DropColumn(
                name: "IdDocumentUrl",
                table: "Shops");

            migrationBuilder.DropColumn(
                name: "IdNumber",
                table: "Shops");
        }
    }
}
