using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CarDecoration.API.Migrations
{
    public partial class AddNotesAndRequestNumberToRequests : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Notes",
                table: "Requests",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "RequestNumber",
                table: "Requests",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(name: "Notes", table: "Requests");
            migrationBuilder.DropColumn(name: "RequestNumber", table: "Requests");
        }
    }
}