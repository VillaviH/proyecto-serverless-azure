using Microsoft.EntityFrameworkCore;
using TaskApi.Models;

namespace TaskApi.Data;

public class TaskDbContext : DbContext
{
    public TaskDbContext(DbContextOptions<TaskDbContext> options) : base(options)
    {
    }
    
    public DbSet<TaskItem> Tasks { get; set; }
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        modelBuilder.Entity<TaskItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Title).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Description).HasMaxLength(1000);
            entity.Property(e => e.CreatedAt).IsRequired();
            entity.HasIndex(e => e.CreatedAt);
        });
        
        // Datos de prueba con fechas fijas
        modelBuilder.Entity<TaskItem>().HasData(
            new TaskItem
            {
                Id = 1,
                Title = "Tarea de ejemplo 1",
                Description = "Esta es una tarea de ejemplo para demostrar el CRUD",
                IsCompleted = false,
                CreatedAt = new DateTime(2025, 1, 1, 12, 0, 0, DateTimeKind.Utc)
            },
            new TaskItem
            {
                Id = 2,
                Title = "Tarea completada",
                Description = "Esta tarea ya está marcada como completada",
                IsCompleted = true,
                CreatedAt = new DateTime(2024, 12, 31, 12, 0, 0, DateTimeKind.Utc)
            }
        );
    }
}
