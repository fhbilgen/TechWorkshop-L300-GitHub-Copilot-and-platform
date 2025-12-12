using Microsoft.AspNetCore.Mvc;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

namespace ZavaStorefront.Controllers
{
    public class ChatController : Controller
    {
        private readonly ILogger<ChatController> _logger;
        private readonly IConfiguration _configuration;
        private readonly HttpClient _httpClient;

        public ChatController(ILogger<ChatController> logger, IConfiguration configuration, IHttpClientFactory httpClientFactory)
        {
            _logger = logger;
            _configuration = configuration;
            _httpClient = httpClientFactory.CreateClient();
        }

        public IActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> SendMessage([FromBody] ChatRequest request)
        {
            try
            {
                var endpoint = _configuration["AzureAI:Endpoint"];
                var deploymentName = _configuration["AzureAI:Phi4DeploymentName"];
                
                var requestBody = new
                {
                    messages = new[]
                    {
                        new { role = "system", content = "You are a helpful assistant for Zava Storefront. Help customers with product information and pricing." },
                        new { role = "user", content = request.Message }
                    },
                    max_tokens = 800,
                    temperature = 0.7
                };

                var jsonContent = JsonSerializer.Serialize(requestBody);
                var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");

                var response = await _httpClient.PostAsync($"{endpoint}/openai/deployments/{deploymentName}/chat/completions?api-version=2024-02-15-preview", content);
                
                if (response.IsSuccessStatusCode)
                {
                    var responseContent = await response.Content.ReadAsStringAsync();
                    var jsonResponse = JsonSerializer.Deserialize<JsonElement>(responseContent);
                    var assistantMessage = jsonResponse.GetProperty("choices")[0].GetProperty("message").GetProperty("content").GetString();
                    
                    return Json(new { success = true, message = assistantMessage });
                }
                else
                {
                    _logger.LogError($"Failed to get response from AI: {response.StatusCode}");
                    return Json(new { success = false, message = "Failed to get response from AI service." });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing chat request");
                return Json(new { success = false, message = "An error occurred while processing your request." });
            }
        }
    }

    public class ChatRequest
    {
        public string Message { get; set; } = string.Empty;
    }
}
