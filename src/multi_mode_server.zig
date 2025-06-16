//! Multi-Mode H3z Server Example
//!
//! This example demonstrates how to create a server with multiple operation modes:
//! - Basic Mode: Default configuration for general use
//! - Secure Mode: Production-ready with enhanced security features
//! - Development Mode: CORS enabled, relaxed settings for development
//!
//! Features demonstrated:
//! - Command-line argument parsing
//! - Mode-specific configurations
//! - Conditional middleware loading
//! - Security headers and CORS
//! - Environment-specific endpoints

const std = @import("std");
const h3 = @import("h3");
const print = std.debug.print;

/// 服务器功能配置结构体
const Features = struct {
    logging: bool,
    security_headers: bool,
    cors: bool,
    enhanced_security: bool,
    debug_endpoints: bool,
};

const ServerMode = enum {
    basic,
    secure,
    dev,

    fn fromString(str: []const u8) ?ServerMode {
        if (std.mem.eql(u8, str, "basic")) return .basic;
        if (std.mem.eql(u8, str, "secure")) return .secure;
        if (std.mem.eql(u8, str, "dev")) return .dev;
        return null;
    }

    fn toString(self: ServerMode) []const u8 {
        return switch (self) {
            .basic => "basic",
            .secure => "secure",
            .dev => "dev",
        };
    }

    fn getPort(self: ServerMode) u16 {
        return switch (self) {
            .basic => 3000,
            .secure => 3001,
            .dev => 3002,
        };
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Parse command line arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var mode: ServerMode = .basic;

    // Parse --mode parameter
    for (args[1..]) |arg| {
        if (std.mem.startsWith(u8, arg, "--mode=")) {
            const mode_str = arg[7..];
            mode = ServerMode.fromString(mode_str) orelse {
                std.log.err("Invalid mode: {s}. Valid modes: basic, secure, dev", .{mode_str});
                return;
            };
        }
    }

    print("🚀 H3z Multi-Mode Server Example\n", .{});
    print("📖 This example demonstrates: multiple server modes, security features, CORS\n", .{});
    print("🔧 Starting server in {s} mode...\n", .{mode.toString()});

    // Create H3z app
    var app = try h3.createApp(allocator);
    defer app.deinit();

    // Add mode-specific middleware
    switch (mode) {
        .basic => {
            _ = app.use(h3.middleware.logger);
        },
        .secure => {
            _ = app.use(h3.middleware.logger);
            _ = app.use(h3.middleware.security);
            // Add custom security middleware
            _ = app.use(securityMiddleware);
        },
        .dev => {
            _ = app.use(h3.middleware.logger);
            _ = app.use(h3.middleware.cors);
        },
    }

    // Setup common routes
    _ = app.get("/", indexHandler);
    _ = app.get("/api/status", statusHandler);
    _ = app.post("/api/echo", echoHandler);
    _ = app.get("/users/:id", userHandler);

    // Add mode-specific routes
    switch (mode) {
        .secure => {
            _ = app.get("/health", healthHandler);
            _ = app.get("/config", configHandler);
            _ = app.post("/upload", uploadHandler);
            _ = app.get("/admin", adminHandler);
        },
        .dev => {
            _ = app.get("/debug", debugHandler);
            _ = app.get("/test", testHandler);
        },
        .basic => {
            // Basic mode has only common routes
        },
    }

    const port = mode.getPort();
    print("🌐 Multi-mode server running at http://127.0.0.1:{d}\n", .{port});
    print("📚 Mode: {s}\n", .{mode.toString()});

    printEndpoints(mode);

    print("\n💡 Press Ctrl+C to stop the server\n", .{});
    print("💡 Try different modes: --mode=basic, --mode=secure, --mode=dev\n", .{});

    // Start server
    try h3.serve(&app, .{ .port = port });
}

fn printEndpoints(mode: ServerMode) void {
    print("📚 Available endpoints:\n", .{});
    print("  GET  /                    - Mode-specific homepage\n", .{});
    print("  GET  /api/status          - Server status with mode info\n", .{});
    print("  POST /api/echo            - Echo request body\n", .{});
    print("  GET  /users/:id           - User information\n", .{});

    switch (mode) {
        .secure => {
            print("🔒 Secure mode additional endpoints:\n", .{});
            print("  GET  /health              - Health check\n", .{});
            print("  GET  /config              - Security configuration\n", .{});
            print("  POST /upload              - File upload\n", .{});
            print("  GET  /admin               - Admin panel\n", .{});
        },
        .dev => {
            print("🛠️  Development mode additional endpoints:\n", .{});
            print("  GET  /debug               - Debug information\n", .{});
            print("  GET  /test                - Test endpoint\n", .{});
        },
        .basic => {},
    }
}

// ============================================================================
// Middleware
// ============================================================================

fn securityMiddleware(event: *h3.Event, context: h3.MiddlewareContext, index: usize, final_handler: h3.Handler) !void {
    // Add security headers
    try event.setHeader("X-Frame-Options", "DENY");
    try event.setHeader("X-Content-Type-Options", "nosniff");
    try event.setHeader("X-XSS-Protection", "1; mode=block");
    try event.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains");

    // Continue to next middleware
    try context.next(event, index, final_handler);
}

// ============================================================================
// Route Handlers
// ============================================================================

fn indexHandler(event: *h3.Event) !void {
    // Detect mode based on port (simple heuristic)
    const host_header = event.getHeader("Host") orelse "localhost:3000";
    const mode = if (std.mem.indexOf(u8, host_header, ":3001") != null)
        ServerMode.secure
    else if (std.mem.indexOf(u8, host_header, ":3002") != null)
        ServerMode.dev
    else
        ServerMode.basic;

    const html = switch (mode) {
        .basic => basicModeHtml(),
        .secure => secureModeHtml(),
        .dev => devModeHtml(),
    };

    try h3.sendHtml(event, html);
}

fn basicModeHtml() []const u8 {
    return 
    \\<!DOCTYPE html>
    \\<html><head><title>H3z Multi-Mode Server - Basic Mode</title>
    \\<style>body{font-family:sans-serif;max-width:800px;margin:0 auto;padding:20px;line-height:1.6;}
    \\.mode{background:#e3f2fd;padding:15px;border-radius:5px;margin:20px 0;}
    \\.endpoint{background:#f5f5f5;padding:10px;margin:10px 0;border-radius:3px;}
    \\</style></head><body>
    \\<h1>🚀 H3z Multi-Mode Server - Basic Mode</h1>
    \\<div class="mode">
    \\<h3>📋 Basic Mode Features</h3>
    \\<ul>
    \\<li>✅ Standard logging middleware</li>
    \\<li>✅ Basic routing and handlers</li>
    \\<li>✅ JSON/HTML responses</li>
    \\<li>✅ Parameter extraction</li>
    \\</ul>
    \\</div>
    \\<h3>📚 Available Endpoints</h3>
    \\<div class="endpoint">GET /api/status - Server status</div>
    \\<div class="endpoint">POST /api/echo - Echo request body</div>
    \\<div class="endpoint">GET /users/:id - User information</div>
    \\<p>💡 Try secure mode: <code>--mode=secure</code> or dev mode: <code>--mode=dev</code></p>
    \\</body></html>
    ;
}

fn secureModeHtml() []const u8 {
    return 
    \\<!DOCTYPE html>
    \\<html><head><title>H3z Multi-Mode Server - Secure Mode</title>
    \\<style>body{font-family:sans-serif;max-width:800px;margin:0 auto;padding:20px;line-height:1.6;}
    \\.mode{background:#e8f5e8;padding:15px;border-radius:5px;margin:20px 0;}
    \\.endpoint{background:#f5f5f5;padding:10px;margin:10px 0;border-radius:3px;}
    \\.security{color:#2e7d32;font-weight:bold;}
    \\</style></head><body>
    \\<h1>🔒 H3z Multi-Mode Server - Secure Mode</h1>
    \\<div class="mode">
    \\<h3 class="security">🛡️ Security Features Enabled</h3>
    \\<ul>
    \\<li>✅ Security headers middleware</li>
    \\<li>✅ X-Frame-Options: DENY</li>
    \\<li>✅ X-Content-Type-Options: nosniff</li>
    \\<li>✅ X-XSS-Protection enabled</li>
    \\<li>✅ Strict-Transport-Security</li>
    \\<li>✅ Enhanced logging</li>
    \\</ul>
    \\</div>
    \\<h3>📚 Available Endpoints</h3>
    \\<div class="endpoint">GET /health - Health check</div>
    \\<div class="endpoint">GET /config - Security configuration</div>
    \\<div class="endpoint">POST /upload - File upload</div>
    \\<div class="endpoint">GET /admin - Admin panel</div>
    \\<div class="endpoint">GET /api/status - Server status</div>
    \\<div class="endpoint">POST /api/echo - Echo request body</div>
    \\<div class="endpoint">GET /users/:id - User information</div>
    \\</body></html>
    ;
}

fn devModeHtml() []const u8 {
    return 
    \\<!DOCTYPE html>
    \\<html><head><title>H3z Multi-Mode Server - Development Mode</title>
    \\<style>body{font-family:sans-serif;max-width:800px;margin:0 auto;padding:20px;line-height:1.6;}
    \\.mode{background:#fff3e0;padding:15px;border-radius:5px;margin:20px 0;}
    \\.endpoint{background:#f5f5f5;padding:10px;margin:10px 0;border-radius:3px;}
    \\.dev{color:#f57c00;font-weight:bold;}
    \\</style></head><body>
    \\<h1>🛠️ H3z Multi-Mode Server - Development Mode</h1>
    \\<div class="mode">
    \\<h3 class="dev">🔧 Development Features</h3>
    \\<ul>
    \\<li>✅ CORS middleware enabled</li>
    \\<li>✅ Cross-origin requests allowed</li>
    \\<li>✅ Enhanced debugging</li>
    \\<li>✅ Development-friendly logging</li>
    \\<li>✅ Test endpoints available</li>
    \\</ul>
    \\</div>
    \\<h3>📚 Available Endpoints</h3>
    \\<div class="endpoint">GET /debug - Debug information</div>
    \\<div class="endpoint">GET /test - Test endpoint</div>
    \\<div class="endpoint">GET /api/status - Server status</div>
    \\<div class="endpoint">POST /api/echo - Echo request body</div>
    \\<div class="endpoint">GET /users/:id - User information</div>
    \\</body></html>
    ;
}

fn statusHandler(event: *h3.Event) !void {
    // Detect mode
    const host_header = event.getHeader("Host") orelse "localhost:3000";
    const mode = if (std.mem.indexOf(u8, host_header, ":3001") != null)
        ServerMode.secure
    else if (std.mem.indexOf(u8, host_header, ":3002") != null)
        ServerMode.dev
    else
        ServerMode.basic;

    const status = .{
        .server = "H3z Multi-Mode Server",
        .mode = mode.toString(),
        .port = mode.getPort(),
        .status = "healthy",
        .timestamp = std.time.timestamp(),
        .features = switch (mode) {
            .basic => Features{
                .logging = true,
                .security_headers = false,
                .cors = false,
                .enhanced_security = false,
                .debug_endpoints = false,
            },
            .secure => Features{
                .logging = true,
                .security_headers = true,
                .cors = false,
                .enhanced_security = true,
                .debug_endpoints = false,
            },
            .dev => Features{
                .logging = true,
                .security_headers = false,
                .cors = true,
                .enhanced_security = false,
                .debug_endpoints = true,
            },
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
        .server_mode = "multi-mode",
    };

    try h3.sendJson(event, response);
}

fn userHandler(event: *h3.Event) !void {
    const user_id = h3.getParam(event, "id") orelse "unknown";

    const name = try std.fmt.allocPrint(event.allocator, "User {s}", .{user_id});
    defer event.allocator.free(name);
    const email = try std.fmt.allocPrint(event.allocator, "user{s}@example.com", .{user_id});
    defer event.allocator.free(email);

    const user = .{
        .id = user_id,
        .name = name,
        .email = email,
        .created_at = "2024-01-01T00:00:00Z",
        .server_mode = "multi-mode",
    };

    try h3.sendJson(event, user);
}

// Secure mode handlers
fn healthHandler(event: *h3.Event) !void {
    const health = .{
        .status = "healthy",
        .mode = "secure",
        .timestamp = std.time.timestamp(),
        .security_features = .{
            .headers_enabled = true,
            .xss_protection = true,
            .frame_options = true,
            .content_type_options = true,
        },
    };

    try h3.sendJson(event, health);
}

fn configHandler(event: *h3.Event) !void {
    const config = .{
        .server_mode = "secure",
        .security_headers = .{
            .x_frame_options = "DENY",
            .x_content_type_options = "nosniff",
            .x_xss_protection = "1; mode=block",
            .strict_transport_security = "max-age=31536000; includeSubDomains",
        },
        .features = .{
            .enhanced_logging = true,
            .security_middleware = true,
            .admin_endpoints = true,
        },
    };

    try h3.sendJson(event, config);
}

fn uploadHandler(event: *h3.Event) !void {
    const body = h3.readBody(event) orelse "";

    const upload_response = .{
        .message = "Upload received in secure mode",
        .size = body.len,
        .timestamp = std.time.timestamp(),
        .security_validated = true,
        .mode = "secure",
    };

    try h3.sendJson(event, upload_response);
}

fn adminHandler(event: *h3.Event) !void {
    const admin_info = .{
        .message = "Admin panel - Secure mode",
        .timestamp = std.time.timestamp(),
        .security_level = "high",
        .features = .{
            .user_management = true,
            .system_monitoring = true,
            .security_logs = true,
        },
    };

    try h3.sendJson(event, admin_info);
}

// Development mode handlers
fn debugHandler(event: *h3.Event) !void {
    const debug_info = .{
        .message = "Debug information - Development mode",
        .timestamp = std.time.timestamp(),
        .request_info = .{
            .method = event.getMethod().toString(),
            .path = event.getPath(),
            .headers_count = "available",
        },
        .server_info = .{
            .mode = "development",
            .cors_enabled = true,
            .debug_endpoints = true,
        },
    };

    try h3.sendJson(event, debug_info);
}

fn testHandler(event: *h3.Event) !void {
    const test_response = .{
        .message = "Test endpoint - Development mode",
        .timestamp = std.time.timestamp(),
        .test_data = .{
            .random_number = 42,
            .test_string = "Hello from test endpoint",
            .cors_enabled = true,
        },
        .note = "This endpoint is only available in development mode",
    };

    try h3.sendJson(event, test_response);
}
