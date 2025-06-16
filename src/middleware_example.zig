//! H3z Middleware Example
//!
//! This example demonstrates the middleware system in H3z:
//! - Built-in middleware (logger, CORS, security)
//! - Custom middleware implementation
//! - Middleware chaining and execution order
//! - Request/response modification
//! - Error handling in middleware
//! - Conditional middleware execution
//!
//! Features demonstrated:
//! - Request timing middleware
//! - Authentication middleware
//! - Request validation middleware
//! - Response modification middleware
//! - Error handling middleware

const std = @import("std");
const h3 = @import("h3");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    print("🚀 H3z Middleware Example\n", .{});
    print("📖 This example demonstrates: custom middleware, chaining, request/response modification\n", .{});
    print("🔧 Starting server with comprehensive middleware stack...\n", .{});

    // Create H3z app
    var app = try h3.createApp(allocator);
    defer app.deinit();

    // Add middleware in order (they execute in the order they're added)
    _ = app.use(requestTimingMiddleware); // 1. Time requests
    _ = app.use(h3.middleware.logger); // 2. Log requests
    _ = app.use(requestIdMiddleware); // 3. Add request ID
    _ = app.use(h3.middleware.cors); // 4. Handle CORS
    _ = app.use(h3.middleware.security); // 5. Add security headers
    _ = app.use(requestValidationMiddleware); // 6. Validate requests
    _ = app.use(responseModificationMiddleware); // 7. Modify responses

    // Setup routes
    _ = app.get("/", homeHandler);
    _ = app.get("/api/middleware-info", middlewareInfoHandler);
    _ = app.get("/api/timing", timingTestHandler);
    _ = app.post("/api/validated", validatedHandler);
    _ = app.get("/protected", protectedHandler);
    _ = app.get("/error-test", errorTestHandler);

    // Add route-specific middleware
    const auth_route = app.get("/auth-required", authRequiredHandler);
    _ = auth_route.use(authenticationMiddleware);

    print("🌐 Middleware server running at http://127.0.0.1:3000\n", .{});
    print("📚 Try these endpoints to see middleware in action:\n", .{});
    print("  GET  /                     - Homepage with middleware info\n", .{});
    print("  GET  /api/middleware-info  - Detailed middleware information\n", .{});
    print("  GET  /api/timing           - Request timing demonstration\n", .{});
    print("  POST /api/validated        - Request validation example\n", .{});
    print("  GET  /protected            - Protected route example\n", .{});
    print("  GET  /auth-required        - Route with authentication middleware\n", .{});
    print("  GET  /error-test           - Error handling demonstration\n", .{});
    print("\n💡 Press Ctrl+C to stop the server\n", .{});
    print("💡 Watch the console to see middleware execution order\n", .{});

    // Start server
    try h3.serve(&app, .{ .port = 3000 });
}

// ============================================================================
// Custom Middleware Functions
// ============================================================================

fn requestTimingMiddleware(event: *h3.Event, context: h3.MiddlewareContext, index: usize, final_handler: h3.Handler) !void {
    const start_time = std.time.nanoTimestamp();

    print("⏱️  [TIMING] Request started: {s} {s}\n", .{ event.getMethod().toString(), event.getPath() });

    // Store start time in event context (simplified - in real implementation you'd use proper context storage)
    try event.setHeader("X-Request-Start-Time", "stored");

    // Continue to next middleware
    try context.next(event, index, final_handler);

    const end_time = std.time.nanoTimestamp();
    const duration_ms = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000.0;

    print("⏱️  [TIMING] Request completed in {d:.2}ms\n", .{duration_ms});

    // Add timing header to response
    const timing_header = try std.fmt.allocPrint(event.allocator, "{d:.2}ms", .{duration_ms});
    try event.setHeader("X-Response-Time", timing_header);
}

fn requestIdMiddleware(event: *h3.Event, context: h3.MiddlewareContext, index: usize, final_handler: h3.Handler) !void {
    // Generate a simple request ID (in production, use UUID or similar)
    const request_id = std.time.timestamp();
    const id_str = try std.fmt.allocPrint(event.allocator, "req-{d}", .{request_id});

    print("🆔 [REQUEST-ID] Generated ID: {s}\n", .{id_str});

    // Add request ID to headers
    try event.setHeader("X-Request-ID", id_str);

    // Continue to next middleware
    try context.next(event, index, final_handler);
}

fn requestValidationMiddleware(event: *h3.Event, context: h3.MiddlewareContext, index: usize, final_handler: h3.Handler) !void {
    print("✅ [VALIDATION] Validating request: {s} {s}\n", .{ event.getMethod().toString(), event.getPath() });

    // Example validation: check for suspicious patterns
    const path = event.getPath();
    if (std.mem.indexOf(u8, path, "..") != null) {
        print("❌ [VALIDATION] Blocked suspicious path: {s}\n", .{path});
        try h3.utils.response.badRequest(event, "Invalid path");
        return;
    }

    // Validate content length for POST requests
    if (event.getMethod() == .POST) {
        const content_length = event.getHeader("content-length");
        if (content_length == null) {
            print("⚠️  [VALIDATION] POST request without content-length\n", .{});
        }
    }

    print("✅ [VALIDATION] Request validation passed\n", .{});

    // Continue to next middleware
    try context.next(event, index, final_handler);
}

fn responseModificationMiddleware(event: *h3.Event, context: h3.MiddlewareContext, index: usize, final_handler: h3.Handler) !void {
    print("🔧 [RESPONSE-MOD] Preparing response modifications\n", .{});

    // Continue to next middleware/handler first
    try context.next(event, index, final_handler);

    // Modify response after handler execution
    try event.setHeader("X-Powered-By", "H3z-Framework");
    try event.setHeader("X-Middleware-Stack", "timing,logger,request-id,cors,security,validation,response-mod");

    print("🔧 [RESPONSE-MOD] Added custom headers to response\n", .{});
}

fn authenticationMiddleware(event: *h3.Event, context: h3.MiddlewareContext, index: usize, final_handler: h3.Handler) !void {
    print("🔐 [AUTH] Checking authentication\n", .{});

    const auth_header = event.getHeader("authorization");
    if (auth_header == null) {
        print("❌ [AUTH] No authorization header found\n", .{});
        try h3.utils.response.unauthorized(event, "Authentication required");
        return;
    }

    // Simple auth check (in production, validate JWT or session)
    if (!std.mem.startsWith(u8, auth_header.?, "Bearer ")) {
        print("❌ [AUTH] Invalid authorization format\n", .{});
        try h3.utils.response.unauthorized(event, "Invalid authorization format");
        return;
    }

    print("✅ [AUTH] Authentication successful\n", .{});

    // Continue to next middleware
    try context.next(event, index, final_handler);
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
        \\    <title>H3z Middleware Example</title>
        \\    <style>
        \\        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
        \\               max-width: 900px; margin: 0 auto; padding: 20px; line-height: 1.6; }
        \\        .middleware { background: #f0f8ff; padding: 15px; margin: 15px 0; border-radius: 5px; border-left: 4px solid #007acc; }
        \\        .endpoint { background: #f5f5f5; padding: 10px; margin: 10px 0; border-radius: 3px; }
        \\        .order { color: #666; font-size: 0.9em; }
        \\        .feature { margin: 20px 0; }
        \\        code { background: #e8e8e8; padding: 2px 6px; border-radius: 3px; font-family: monospace; }
        \\    </style>
        \\</head>
        \\<body>
        \\    <h1>🚀 H3z Middleware Example</h1>
        \\    <p>This example demonstrates the comprehensive middleware system in H3z</p>
        \\
        \\    <div class="feature">
        \\        <h3>🔄 Middleware Execution Order</h3>
        \\        <div class="middleware">
        \\            <strong>1. Request Timing</strong> - Measures request duration
        \\            <div class="order">Adds X-Response-Time header</div>
        \\        </div>
        \\        <div class="middleware">
        \\            <strong>2. Logger</strong> - Logs all requests (built-in)
        \\            <div class="order">Console logging with timestamps</div>
        \\        </div>
        \\        <div class="middleware">
        \\            <strong>3. Request ID</strong> - Generates unique request IDs
        \\            <div class="order">Adds X-Request-ID header</div>
        \\        </div>
        \\        <div class="middleware">
        \\            <strong>4. CORS</strong> - Cross-origin resource sharing (built-in)
        \\            <div class="order">Adds CORS headers</div>
        \\        </div>
        \\        <div class="middleware">
        \\            <strong>5. Security</strong> - Security headers (built-in)
        \\            <div class="order">Adds X-Frame-Options, X-XSS-Protection, etc.</div>
        \\        </div>
        \\        <div class="middleware">
        \\            <strong>6. Request Validation</strong> - Validates incoming requests
        \\            <div class="order">Blocks suspicious patterns</div>
        \\        </div>
        \\        <div class="middleware">
        \\            <strong>7. Response Modification</strong> - Modifies outgoing responses
        \\            <div class="order">Adds X-Powered-By and X-Middleware-Stack headers</div>
        \\        </div>
        \\    </div>
        \\
        \\    <div class="feature">
        \\        <h3>📚 Test Endpoints</h3>
        \\        <div class="endpoint">
        \\            <strong>GET /api/middleware-info</strong> - Detailed middleware information
        \\        </div>
        \\        <div class="endpoint">
        \\            <strong>GET /api/timing</strong> - Request timing demonstration
        \\        </div>
        \\        <div class="endpoint">
        \\            <strong>POST /api/validated</strong> - Request validation example
        \\        </div>
        \\        <div class="endpoint">
        \\            <strong>GET /auth-required</strong> - Route with authentication middleware<br>
        \\            <code>curl -H "Authorization: Bearer token123" http://localhost:3000/auth-required</code>
        \\        </div>
        \\        <div class="endpoint">
        \\            <strong>GET /error-test</strong> - Error handling demonstration
        \\        </div>
        \\    </div>
        \\
        \\    <div class="feature">
        \\        <h3>💡 Check Your Browser's Developer Tools</h3>
        \\        <p>Open the Network tab to see all the custom headers added by middleware:</p>
        \\        <ul>
        \\            <li><code>X-Response-Time</code> - Request processing time</li>
        \\            <li><code>X-Request-ID</code> - Unique request identifier</li>
        \\            <li><code>X-Powered-By</code> - Framework identifier</li>
        \\            <li><code>X-Middleware-Stack</code> - List of applied middleware</li>
        \\        </ul>
        \\    </div>
        \\</body>
        \\</html>
    ;

    try h3.sendHtml(event, html);
}

fn middlewareInfoHandler(event: *h3.Event) !void {
    const middleware_info = .{
        .server = "H3z Middleware Example",
        .middleware_stack = .{
            .total_count = 7,
            .execution_order = .{
                "request-timing",
                "logger",
                "request-id",
                "cors",
                "security",
                "request-validation",
                "response-modification",
            },
            .built_in = .{
                "logger",
                "cors",
                "security",
            },
            .custom = .{
                "request-timing",
                "request-id",
                "request-validation",
                "response-modification",
            },
        },
        .headers_added = .{
            "X-Response-Time",
            "X-Request-ID",
            "X-Powered-By",
            "X-Middleware-Stack",
        },
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, middleware_info);
}

fn timingTestHandler(event: *h3.Event) !void {
    // Simulate some processing time
    std.time.sleep(100 * std.time.ns_per_ms); // 100ms delay

    const timing_info = .{
        .message = "Timing test completed",
        .simulated_delay = "100ms",
        .note = "Check X-Response-Time header for actual timing",
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, timing_info);
}

fn validatedHandler(event: *h3.Event) !void {
    const body = h3.readBody(event) orelse "";

    const response = .{
        .message = "Request passed validation middleware",
        .body_received = body,
        .validation_status = "passed",
        .middleware_applied = "request-validation",
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, response);
}

fn protectedHandler(event: *h3.Event) !void {
    const protected_data = .{
        .message = "This is protected content",
        .access_level = "public", // This route doesn't require auth
        .note = "Try /auth-required for authentication middleware demo",
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, protected_data);
}

fn authRequiredHandler(event: *h3.Event) !void {
    const auth_data = .{
        .message = "Authentication successful!",
        .access_level = "authenticated",
        .middleware_applied = "authentication",
        .note = "This route requires Authorization header",
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, auth_data);
}

fn errorTestHandler(event: *h3.Event) !void {
    // Simulate an error to test error handling middleware
    const should_error = @rem(std.time.timestamp(), 2) == 0;

    if (should_error) {
        try h3.utils.response.internalServerError(event, "Simulated error for testing");
        return;
    }

    const success_response = .{
        .message = "No error this time!",
        .note = "Refresh to potentially trigger an error",
        .error_simulation = "50% chance",
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, success_response);
}
