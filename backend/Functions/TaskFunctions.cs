using System.Net;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using TaskApi.Data;
using TaskApi.Models;

namespace TaskApi.Functions;

public class TaskFunctions
{
    private readonly ILogger<TaskFunctions> _logger;
    private readonly TaskDbContext _context;

    public TaskFunctions(ILogger<TaskFunctions> logger, TaskDbContext context)
    {
        _logger = logger;
        _context = context;
    }

    private async Task EnsureDatabaseInitializedAsync()
    {
        try
        {
            // Solo crear la base de datos si no existe
            await _context.Database.EnsureCreatedAsync();
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Could not initialize database, continuing with existing database");
            // No lanzar excepción, solo registrar el warning
        }
    }

    [Function("GetTasks")]
    public async Task<HttpResponseData> GetTasks(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "tasks")] HttpRequestData req)
    {
        _logger.LogInformation("Getting all tasks");

        try
        {
            // Asegurar que la base de datos esté inicializada
            await EnsureDatabaseInitializedAsync();

            var tasks = await _context.Tasks
                .OrderByDescending(t => t.CreatedAt)
                .ToListAsync();

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");
            response.Headers.Add("Access-Control-Allow-Origin", "*");
            response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
            response.Headers.Add("Access-Control-Allow-Headers", "Content-Type, Authorization");

            await response.WriteStringAsync(JsonSerializer.Serialize(tasks));
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting tasks");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync(JsonSerializer.Serialize(new { error = "Internal server error" }));
            return errorResponse;
        }
    }

    [Function("GetTask")]
    public async Task<HttpResponseData> GetTask(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "tasks/{id:int}")] HttpRequestData req,
        int id)
    {
        _logger.LogInformation($"Getting task with ID: {id}");

        try
        {
            var task = await _context.Tasks.FindAsync(id);

            var response = req.CreateResponse();
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");
            response.Headers.Add("Access-Control-Allow-Origin", "*");

            if (task == null)
            {
                response.StatusCode = HttpStatusCode.NotFound;
                await response.WriteStringAsync(JsonSerializer.Serialize(new { error = "Task not found" }));
                return response;
            }

            response.StatusCode = HttpStatusCode.OK;
            await response.WriteStringAsync(JsonSerializer.Serialize(task));
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error getting task with ID: {id}");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync(JsonSerializer.Serialize(new { error = "Internal server error" }));
            return errorResponse;
        }
    }

    [Function("CreateTask")]
    public async Task<HttpResponseData> CreateTask(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "tasks")] HttpRequestData req)
    {
        _logger.LogInformation("Creating new task");

        try
        {
            var requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            var createRequest = JsonSerializer.Deserialize<CreateTaskRequest>(requestBody, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });

            if (createRequest == null || string.IsNullOrWhiteSpace(createRequest.Title))
            {
                var badResponse = req.CreateResponse(HttpStatusCode.BadRequest);
                await badResponse.WriteStringAsync(JsonSerializer.Serialize(new { error = "Title is required" }));
                return badResponse;
            }

            var task = new TaskItem
            {
                Title = createRequest.Title.Trim(),
                Description = createRequest.Description?.Trim() ?? string.Empty,
                IsCompleted = false,
                CreatedAt = DateTime.UtcNow
            };

            _context.Tasks.Add(task);
            await _context.SaveChangesAsync();

            var response = req.CreateResponse(HttpStatusCode.Created);
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");
            response.Headers.Add("Access-Control-Allow-Origin", "*");
            await response.WriteStringAsync(JsonSerializer.Serialize(task));
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating task");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync(JsonSerializer.Serialize(new { error = "Internal server error" }));
            return errorResponse;
        }
    }

    [Function("UpdateTask")]
    public async Task<HttpResponseData> UpdateTask(
        [HttpTrigger(AuthorizationLevel.Anonymous, "put", Route = "tasks/{id:int}")] HttpRequestData req,
        int id)
    {
        _logger.LogInformation($"Updating task with ID: {id}");

        try
        {
            var task = await _context.Tasks.FindAsync(id);
            if (task == null)
            {
                var notFoundResponse = req.CreateResponse(HttpStatusCode.NotFound);
                await notFoundResponse.WriteStringAsync(JsonSerializer.Serialize(new { error = "Task not found" }));
                return notFoundResponse;
            }

            var requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            var updateRequest = JsonSerializer.Deserialize<UpdateTaskRequest>(requestBody, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });

            if (updateRequest == null || string.IsNullOrWhiteSpace(updateRequest.Title))
            {
                var badResponse = req.CreateResponse(HttpStatusCode.BadRequest);
                await badResponse.WriteStringAsync(JsonSerializer.Serialize(new { error = "Title is required" }));
                return badResponse;
            }

            task.Title = updateRequest.Title.Trim();
            task.Description = updateRequest.Description?.Trim() ?? string.Empty;
            task.IsCompleted = updateRequest.IsCompleted;
            task.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");
            response.Headers.Add("Access-Control-Allow-Origin", "*");
            await response.WriteStringAsync(JsonSerializer.Serialize(task));
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error updating task with ID: {id}");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync(JsonSerializer.Serialize(new { error = "Internal server error" }));
            return errorResponse;
        }
    }

    [Function("DeleteTask")]
    public async Task<HttpResponseData> DeleteTask(
        [HttpTrigger(AuthorizationLevel.Anonymous, "delete", Route = "tasks/{id:int}")] HttpRequestData req,
        int id)
    {
        _logger.LogInformation($"Deleting task with ID: {id}");

        try
        {
            var task = await _context.Tasks.FindAsync(id);
            if (task == null)
            {
                var notFoundResponse = req.CreateResponse(HttpStatusCode.NotFound);
                await notFoundResponse.WriteStringAsync(JsonSerializer.Serialize(new { error = "Task not found" }));
                return notFoundResponse;
            }

            _context.Tasks.Remove(task);
            await _context.SaveChangesAsync();

            var response = req.CreateResponse(HttpStatusCode.NoContent);
            response.Headers.Add("Access-Control-Allow-Origin", "*");
            return response;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error deleting task with ID: {id}");
            var errorResponse = req.CreateResponse(HttpStatusCode.InternalServerError);
            await errorResponse.WriteStringAsync(JsonSerializer.Serialize(new { error = "Internal server error" }));
            return errorResponse;
        }
    }

    [Function("OptionsHandler")]
    public HttpResponseData OptionsHandler(
        [HttpTrigger(AuthorizationLevel.Anonymous, "options", Route = "tasks")] HttpRequestData req)
    {
        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Access-Control-Allow-Origin", "*");
        response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        response.Headers.Add("Access-Control-Allow-Headers", "Content-Type, Authorization");
        response.Headers.Add("Access-Control-Max-Age", "86400");
        return response;
    }

    [Function("OptionsHandlerWithId")]
    public HttpResponseData OptionsHandlerWithId(
        [HttpTrigger(AuthorizationLevel.Anonymous, "options", Route = "tasks/{id:int}")] HttpRequestData req,
        int id)
    {
        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Access-Control-Allow-Origin", "*");
        response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        response.Headers.Add("Access-Control-Allow-Headers", "Content-Type, Authorization");
        response.Headers.Add("Access-Control-Max-Age", "86400");
        return response;
    }
}
