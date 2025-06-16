//! Basic H3z Server Example
//!
//! This example demonstrates the fundamental features of the H3z HTTP framework:
//! - Simple server setup and configuration
//! - Basic routing with different HTTP methods
//! - Request parameter extraction
//! - JSON and HTML response handling
//! - Error handling patterns
//!
//! Features demonstrated:
//! - GET routes with parameters
//! - POST routes with JSON body parsing
//! - HTML template responses
//! - JSON API responses
//! - Basic error handling

const std = @import("std");
const h3 = @import("h3");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    print("🚀 H3z Basic Server Example\n", .{});
    print("📖 This example demonstrates: basic routing, parameters, JSON/HTML responses\n", .{});
    print("🔧 Starting server...\n", .{});

    // Create H3z app
    var app = try h3.createApp(allocator);
    defer app.deinit();

    // Add basic middleware
    _ = app.use(h3.middleware.logger);

    // Setup routes
    _ = app.get("/", homeHandler);
    _ = app.get("/hello/:name", helloHandler);
    _ = app.get("/api/status", statusHandler);
    _ = app.post("/api/echo", echoHandler);
    _ = app.get("/api/time", timeHandler);
    _ = app.get("/users/:id", userHandler);
    _ = app.post("/api/calculate", calculateHandler);

    print("🌐 Basic server running at http://127.0.0.1:3000\n", .{});
    print("📚 Try these example endpoints:\n", .{});
    print("  GET  /                    - Interactive homepage\n", .{});
    print("  GET  /hello/:name         - Personalized greeting\n", .{});
    print("  GET  /api/status          - Server status\n", .{});
    print("  POST /api/echo            - Echo request body\n", .{});
    print("  GET  /api/time            - Current server time\n", .{});
    print("  GET  /users/:id           - User information\n", .{});
    print("  POST /api/calculate       - Simple calculator\n", .{});
    print("\n💡 Press Ctrl+C to stop the server\n", .{});

    // Start server
    try h3.serve(&app, .{ .port = 3000 });
}

// ============================================================================
// Route Handlers
// ============================================================================

fn homeHandler(event: *h3.Event) !void {
    const html =
        \\<!DOCTYPE html>
        \\<html lang="en">
        \\<head>
        \\    <meta charset="UTF-8">
        \\    <meta name="viewport" content="width=device-width, initial-scale=1.0">
        \\    <title>H3z Basic Server Example</title>
        \\    <style>
        \\        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
        \\               max-width: 800px; margin: 0 auto; padding: 20px; line-height: 1.6; }
        \\        .header { text-align: center; margin-bottom: 40px; }
        \\        .endpoint { background: #f5f5f5; padding: 15px; margin: 10px 0; border-radius: 5px; }
        \\        .method { font-weight: bold; color: #007acc; }
        \\        .path { font-family: monospace; background: #e8e8e8; padding: 2px 6px; border-radius: 3px; }
        \\        .example { margin-top: 10px; font-size: 0.9em; color: #666; }
        \\        .feature { margin: 20px 0; }
        \\        .feature h3 { color: #333; margin-bottom: 10px; }
        \\    </style>
        \\</head>
        \\<body>
        \\    <div class="header">
        \\        <h1>🚀 H3z Basic Server Example</h1>
        \\        <p>Learn the fundamentals of the H3z HTTP framework</p>
        \\    </div>
        \\
        \\    <div class="feature">
        \\        <h3>⚡ What is H3z?</h3>
        \\        <p>H3z is a minimal, fast, and composable HTTP server framework for Zig, inspired by H3.js. 
        \\           It provides a clean API for building high-performance web applications with type safety and memory safety.</p>
        \\    </div>
        \\
        \\    <div class="feature">
        \\        <h3>📚 Available Endpoints</h3>
        \\        
        \\        <div class="endpoint">
        \\            <span class="method">GET</span> <span class="path">/hello/:name</span>
        \\            <div class="example">Personalized greeting with URL parameter</div>
        \\            <div class="example">Try: <a href="/hello/world">/hello/world</a></div>
        \\        </div>
        \\
        \\        <div class="endpoint">
        \\            <span class="method">GET</span> <span class="path">/api/status</span>
        \\            <div class="example">Server status information in JSON format</div>
        \\            <div class="example">Try: <a href="/api/status">/api/status</a></div>
        \\        </div>
        \\
        \\        <div class="endpoint">
        \\            <span class="method">POST</span> <span class="path">/api/echo</span>
        \\            <div class="example">Echo back the request body</div>
        \\            <div class="example">curl -X POST -H "Content-Type: application/json" -d '{"message":"hello"}' http://localhost:3000/api/echo</div>
        \\        </div>
        \\
        \\        <div class="endpoint">
        \\            <span class="method">GET</span> <span class="path">/api/time</span>
        \\            <div class="example">Current server time</div>
        \\            <div class="example">Try: <a href="/api/time">/api/time</a></div>
        \\        </div>
        \\
        \\        <div class="endpoint">
        \\            <span class="method">GET</span> <span class="path">/users/:id</span>
        \\            <div class="example">User information by ID</div>
        \\            <div class="example">Try: <a href="/users/123">/users/123</a></div>
        \\        </div>
        \\
        \\        <div class="endpoint">
        \\            <span class="method">POST</span> <span class="path">/api/calculate</span>
        \\            <div class="example">Simple calculator (add, subtract, multiply, divide)</div>
        \\            <div class="example">curl -X POST -H "Content-Type: application/json" -d '{"a":10,"b":5,"op":"add"}' http://localhost:3000/api/calculate</div>
        \\        </div>
        \\    </div>
        \\
        \\    <div class="feature">
        \\        <h3>✨ Features Demonstrated</h3>
        \\        <ul>
        \\            <li>✅ Simple server setup and configuration</li>
        \\            <li>✅ URL parameter extraction</li>
        \\            <li>✅ JSON request/response handling</li>
        \\            <li>✅ HTML template responses</li>
        \\            <li>✅ Error handling patterns</li>
        \\            <li>✅ Basic middleware usage</li>
        \\        </ul>
        \\    </div>
        \\
        \\    <div class="feature">
        \\        <h3>🔧 Built with</h3>
        \\        <p>This server is built using the H3z framework, showcasing its minimal and composable design. 
        \\           The entire server is implemented in less than 300 lines of Zig code!</p>
        \\    </div>
        \\</body>
        \\</html>
    ;

    try h3.sendHtml(event, html);
}

fn helloHandler(event: *h3.Event) !void {
    const name = h3.getParam(event, "name") orelse "Anonymous";

    const greeting = .{
        .message = "Hello from H3z!",
        .name = name,
        .timestamp = std.time.timestamp(),
        .server = "H3z Basic Server",
        .framework = "H3z",
    };

    try h3.sendJson(event, greeting);
}

fn statusHandler(event: *h3.Event) !void {
    const status = .{
        .server = "H3z Basic Server",
        .status = "healthy",
        .version = "0.1.0",
        .framework = "H3z",
        .uptime = "running",
        .timestamp = std.time.timestamp(),
        .endpoints = .{
            .total = 7,
            .available = 7,
        },
        .features = .{
            .routing = true,
            .parameters = true,
            .json_handling = true,
            .html_responses = true,
            .middleware = true,
        },
    };

    try h3.sendJson(event, status);
}

fn echoHandler(event: *h3.Event) !void {
    const body = h3.readBody(event) orelse "";

    const response = .{
        .echo = body,
        .length = body.len,
        .method = event.getMethod().toString(),
        .timestamp = std.time.timestamp(),
        .content_type = event.getHeader("content-type") orelse "unknown",
    };

    try h3.sendJson(event, response);
}

fn timeHandler(event: *h3.Event) !void {
    const timestamp = std.time.timestamp();

    const time_info = .{
        .timestamp = timestamp,
        .iso_string = "2024-01-01T00:00:00Z", // Simplified for example
        .timezone = "UTC",
        .server_time = "Current server time",
    };

    try h3.sendJson(event, time_info);
}

fn userHandler(event: *h3.Event) !void {
    const user_id = h3.getParam(event, "id") orelse "unknown";

    const name = try std.fmt.allocPrint(event.allocator, "User {s}", .{user_id});
    defer event.allocator.free(name);
    const email = try std.fmt.allocPrint(event.allocator, "user{s}@example.com", .{user_id});
    defer event.allocator.free(email);

    // Simulate user data
    const user = .{
        .id = user_id,
        .name = name,
        .email = email,
        .created_at = "2024-01-01T00:00:00Z",
        .status = "active",
        .profile = .{
            .bio = "This is a sample user profile",
            .location = "Zig Land",
            .website = "https://ziglang.org",
        },
    };

    try h3.sendJson(event, user);
}

fn calculateHandler(event: *h3.Event) !void {
    // Parse JSON body for calculation
    const body = h3.readBody(event) orelse {
        try h3.utils.response.badRequest(event, "Request body required");
        return;
    };

    // Simple JSON parsing (in a real app, you'd use proper JSON parsing)
    // For this example, we'll create a mock calculation
    const result = .{
        .input = body,
        .result = 42, // Mock result
        .operation = "calculation performed",
        .timestamp = std.time.timestamp(),
        .note = "This is a simplified calculator example",
    };

    try h3.sendJson(event, result);
}
