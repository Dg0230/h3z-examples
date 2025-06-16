//! Advanced Routing H3z Example
//!
//! This example demonstrates advanced routing features in H3z:
//! - Parameter extraction and validation
//! - Wildcard routes and path matching
//! - File upload handling
//! - Authentication and authorization
//! - Route-specific middleware
//! - Query parameter processing
//! - Content type handling
//!
//! Features demonstrated:
//! - Dynamic route parameters
//! - File upload with validation
//! - Basic authentication
//! - Route groups and organization
//! - Error handling patterns

const std = @import("std");
const h3 = @import("h3");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    print("🚀 H3z Advanced Routing Example\n", .{});
    print("📖 This example demonstrates: parameters, wildcards, file upload, authentication\n", .{});
    print("🔧 Starting server with advanced routing features...\n", .{});

    // Create H3z app
    var app = try h3.createApp(allocator);
    defer app.deinit();

    // Add global middleware
    _ = app.use(h3.middleware.logger);
    _ = app.use(h3.middleware.cors);

    // Basic routes
    _ = app.get("/", homeHandler);
    _ = app.get("/api/info", infoHandler);

    // Parameter routes
    _ = app.get("/users/:id", userHandler);
    _ = app.get("/users/:id/posts/:post_id", userPostHandler);
    _ = app.get("/categories/:category/items/:item", categoryItemHandler);

    // Query parameter routes
    _ = app.get("/search", searchHandler);
    _ = app.get("/api/paginated", paginatedHandler);

    // Wildcard routes
    _ = app.get("/static/*", staticFileHandler);
    _ = app.get("/docs/*", documentationHandler);

    // File upload routes
    _ = app.post("/upload", uploadHandler);
    _ = app.post("/upload/image", imageUploadHandler);
    _ = app.post("/upload/document", documentUploadHandler);

    // Authentication routes
    _ = app.post("/auth/login", loginHandler);
    _ = app.post("/auth/register", registerHandler);

    // Protected routes with authentication middleware
    const protected_route = app.get("/protected", protectedHandler);
    _ = protected_route.use(authMiddleware);

    const admin_route = app.get("/admin", adminHandler);
    _ = admin_route.use(authMiddleware);
    _ = admin_route.use(adminMiddleware);

    // API versioning
    _ = app.get("/api/v1/status", apiV1StatusHandler);
    _ = app.get("/api/v2/status", apiV2StatusHandler);

    // Content type specific routes
    _ = app.post("/api/json", jsonHandler);
    _ = app.post("/api/form", formHandler);
    _ = app.post("/api/xml", xmlHandler);

    print("🌐 Advanced routing server running at http://127.0.0.1:3000\n", .{});
    print("📚 Try these advanced routing examples:\n", .{});
    print("  GET  /users/123                    - Parameter extraction\n", .{});
    print("  GET  /users/123/posts/456          - Multiple parameters\n", .{});
    print("  GET  /search?q=test&page=1         - Query parameters\n", .{});
    print("  GET  /static/css/style.css         - Wildcard routes\n", .{});
    print("  POST /upload                       - File upload\n", .{});
    print("  POST /auth/login                   - Authentication\n", .{});
    print("  GET  /protected                    - Protected route (requires auth)\n", .{});
    print("  GET  /admin                        - Admin route (requires admin auth)\n", .{});
    print("\n💡 Press Ctrl+C to stop the server\n", .{});

    // Start server
    try h3.serve(&app, .{ .port = 3000 });
}

// ============================================================================
// Middleware Functions
// ============================================================================

fn authMiddleware(event: *h3.Event, context: h3.MiddlewareContext, index: usize, final_handler: h3.Handler) !void {
    print("🔐 [AUTH] Checking authentication\n", .{});

    const auth_header = event.getHeader("authorization");
    if (auth_header == null) {
        try h3.utils.response.unauthorized(event, "Authentication required");
        return;
    }

    // Simple token validation (in production, validate JWT or session)
    if (!std.mem.startsWith(u8, auth_header.?, "Bearer ")) {
        try h3.utils.response.unauthorized(event, "Invalid authorization format");
        return;
    }

    const token = auth_header.?[7..]; // Remove "Bearer "
    if (!std.mem.eql(u8, token, "valid-token-123")) {
        try h3.utils.response.unauthorized(event, "Invalid token");
        return;
    }

    // Store user info in context (simplified)
    try event.setHeader("X-User-ID", "123");
    try event.setHeader("X-User-Role", "user");

    try context.next(event, index, final_handler);
}

fn adminMiddleware(event: *h3.Event, context: h3.MiddlewareContext, index: usize, final_handler: h3.Handler) !void {
    print("👑 [ADMIN] Checking admin privileges\n", .{});

    const user_role = event.getHeader("X-User-Role");
    if (user_role == null or !std.mem.eql(u8, user_role.?, "admin")) {
        // For demo, we'll accept "user" role as well
        if (user_role == null or !std.mem.eql(u8, user_role.?, "user")) {
            try h3.utils.response.forbidden(event, "Admin access required");
            return;
        }
    }

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
        \\    <title>H3z Advanced Routing Example</title>
        \\    <style>
        \\        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
        \\               max-width: 1000px; margin: 0 auto; padding: 20px; line-height: 1.6; }
        \\        .section { margin: 30px 0; padding: 20px; background: #f8f9fa; border-radius: 8px; }
        \\        .endpoint { background: #fff; padding: 12px; margin: 8px 0; border-radius: 4px; border-left: 4px solid #007acc; }
        \\        .method { font-weight: bold; color: #007acc; }
        \\        .path { font-family: monospace; background: #e9ecef; padding: 2px 6px; border-radius: 3px; }
        \\        .example { margin-top: 8px; font-size: 0.9em; color: #666; }
        \\        .auth-note { background: #fff3cd; padding: 10px; border-radius: 4px; margin-top: 10px; }
        \\    </style>
        \\</head>
        \\<body>
        \\    <h1>🚀 H3z Advanced Routing Example</h1>
        \\    <p>Explore advanced routing features including parameters, wildcards, file uploads, and authentication</p>
        \\
        \\    <div class="section">
        \\        <h3>📍 Parameter Routes</h3>
        \\        <div class="endpoint">
        \\            <span class="method">GET</span> <span class="path">/users/:id</span>
        \\            <div class="example">Try: <a href="/users/123">/users/123</a></div>
        \\        </div>
        \\        <div class="endpoint">
        \\            <span class="method">GET</span> <span class="path">/users/:id/posts/:post_id</span>
        \\            <div class="example">Try: <a href="/users/123/posts/456">/users/123/posts/456</a></div>
        \\        </div>
        \\        <div class="endpoint">
        \\            <span class="method">GET</span> <span class="path">/categories/:category/items/:item</span>
        \\            <div class="example">Try: <a href="/categories/electronics/items/laptop">/categories/electronics/items/laptop</a></div>
        \\        </div>
        \\    </div>
        \\
        \\    <div class="section">
        \\        <h3>🔍 Query Parameters</h3>
        \\        <div class="endpoint">
        \\            <span class="method">GET</span> <span class="path">/search</span>
        \\            <div class="example">Try: <a href="/search?q=test&category=all">/search?q=test&category=all</a></div>
        \\        </div>
        \\        <div class="endpoint">
        \\            <span class="method">GET</span> <span class="path">/api/paginated</span>
        \\            <div class="example">Try: <a href="/api/paginated?page=2&limit=10">/api/paginated?page=2&limit=10</a></div>
        \\        </div>
        \\    </div>
        \\
        \\    <div class="section">
        \\        <h3>🌟 Wildcard Routes</h3>
        \\        <div class="endpoint">
        \\            <span class="method">GET</span> <span class="path">/static/*</span>
        \\            <div class="example">Try: <a href="/static/css/style.css">/static/css/style.css</a></div>
        \\        </div>
        \\        <div class="endpoint">
        \\            <span class="method">GET</span> <span class="path">/docs/*</span>
        \\            <div class="example">Try: <a href="/docs/api/reference">/docs/api/reference</a></div>
        \\        </div>
        \\    </div>
        \\
        \\    <div class="section">
        \\        <h3>📤 File Upload</h3>
        \\        <div class="endpoint">
        \\            <span class="method">POST</span> <span class="path">/upload</span>
        \\            <div class="example">curl -X POST -F "file=@example.txt" http://localhost:3000/upload</div>
        \\        </div>
        \\        <div class="endpoint">
        \\            <span class="method">POST</span> <span class="path">/upload/image</span>
        \\            <div class="example">curl -X POST -F "image=@photo.jpg" http://localhost:3000/upload/image</div>
        \\        </div>
        \\    </div>
        \\
        \\    <div class="section">
        \\        <h3>🔐 Authentication</h3>
        \\        <div class="endpoint">
        \\            <span class="method">POST</span> <span class="path">/auth/login</span>
        \\            <div class="example">curl -X POST -H "Content-Type: application/json" -d '{"username":"user","password":"pass"}' http://localhost:3000/auth/login</div>
        \\        </div>
        \\        <div class="endpoint">
        \\            <span class="method">GET</span> <span class="path">/protected</span>
        \\            <div class="example">curl -H "Authorization: Bearer valid-token-123" http://localhost:3000/protected</div>
        \\            <div class="auth-note">⚠️ Requires authentication token</div>
        \\        </div>
        \\        <div class="endpoint">
        \\            <span class="method">GET</span> <span class="path">/admin</span>
        \\            <div class="example">curl -H "Authorization: Bearer valid-token-123" http://localhost:3000/admin</div>
        \\            <div class="auth-note">⚠️ Requires admin privileges</div>
        \\        </div>
        \\    </div>
        \\
        \\    <div class="section">
        \\        <h3>🔄 API Versioning</h3>
        \\        <div class="endpoint">
        \\            <span class="method">GET</span> <span class="path">/api/v1/status</span>
        \\            <div class="example">Try: <a href="/api/v1/status">/api/v1/status</a></div>
        \\        </div>
        \\        <div class="endpoint">
        \\            <span class="method">GET</span> <span class="path">/api/v2/status</span>
        \\            <div class="example">Try: <a href="/api/v2/status">/api/v2/status</a></div>
        \\        </div>
        \\    </div>
        \\</body>
        \\</html>
    ;

    try h3.sendHtml(event, html);
}

fn infoHandler(event: *h3.Event) !void {
    const info = .{
        .server = "H3z Advanced Routing Example",
        .features = .{
            .parameter_routes = true,
            .wildcard_routes = true,
            .query_parameters = true,
            .file_upload = true,
            .authentication = true,
            .middleware_chaining = true,
            .api_versioning = true,
        },
        .route_count = 20,
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, info);
}

// Parameter route handlers
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
        .profile = .{
            .bio = "Sample user profile",
            .location = "Zig Land",
            .joined = "2024-01-01",
        },
        .route_info = .{
            .pattern = "/users/:id",
            .parameter_extracted = user_id,
        },
    };

    try h3.sendJson(event, user);
}

fn userPostHandler(event: *h3.Event) !void {
    const user_id = h3.getParam(event, "id") orelse "unknown";
    const post_id = h3.getParam(event, "post_id") orelse "unknown";

    const title = try std.fmt.allocPrint(event.allocator, "Post {s} by User {s}", .{ post_id, user_id });
    defer event.allocator.free(title);

    const post = .{
        .id = post_id,
        .user_id = user_id,
        .title = title,
        .content = "This is a sample post content",
        .created_at = "2024-01-01T00:00:00Z",
        .route_info = .{
            .pattern = "/users/:id/posts/:post_id",
            .parameters = .{
                .user_id = user_id,
                .post_id = post_id,
            },
        },
    };

    try h3.sendJson(event, post);
}

fn categoryItemHandler(event: *h3.Event) !void {
    const category = h3.getParam(event, "category") orelse "unknown";
    const item = h3.getParam(event, "item") orelse "unknown";

    const name = try std.fmt.allocPrint(event.allocator, "{s} in {s}", .{ item, category });
    defer event.allocator.free(name);

    const item_data = .{
        .category = category,
        .item = item,
        .name = name,
        .description = "Sample item description",
        .price = 99.99,
        .route_info = .{
            .pattern = "/categories/:category/items/:item",
            .parameters = .{
                .category = category,
                .item = item,
            },
        },
    };

    try h3.sendJson(event, item_data);
}

// Query parameter handlers
fn searchHandler(event: *h3.Event) !void {
    const query = h3.getQuery(event, "q") orelse "";
    const category = h3.getQuery(event, "category") orelse "all";
    const page = h3.getQuery(event, "page") orelse "1";

    const search_results = .{
        .query = query,
        .category = category,
        .page = page,
        .results = .{
            .total = 42,
            .items = .{
                .{ .id = 1, .title = "Result 1", .relevance = 0.95 },
                .{ .id = 2, .title = "Result 2", .relevance = 0.87 },
                .{ .id = 3, .title = "Result 3", .relevance = 0.76 },
            },
        },
        .route_info = .{
            .pattern = "/search",
            .query_parameters = .{
                .q = query,
                .category = category,
                .page = page,
            },
        },
    };

    try h3.sendJson(event, search_results);
}

fn paginatedHandler(event: *h3.Event) !void {
    const page_str = h3.getQuery(event, "page") orelse "1";
    const limit_str = h3.getQuery(event, "limit") orelse "10";

    const page = std.fmt.parseInt(u32, page_str, 10) catch 1;
    const limit = std.fmt.parseInt(u32, limit_str, 10) catch 10;

    const paginated_data = .{
        .page = page,
        .limit = limit,
        .total_pages = 10,
        .total_items = 100,
        .data = .{
            .items = "Sample paginated items would be here",
            .start_index = (page - 1) * limit + 1,
            .end_index = page * limit,
        },
        .route_info = .{
            .pattern = "/api/paginated",
            .pagination = .{
                .page = page,
                .limit = limit,
            },
        },
    };

    try h3.sendJson(event, paginated_data);
}

// Wildcard route handlers
fn staticFileHandler(event: *h3.Event) !void {
    const path = event.getPath();
    const file_path = path[8..]; // Remove "/static/" prefix

    const static_response = .{
        .message = "Static file request",
        .requested_path = path,
        .file_path = file_path,
        .note = "In a real app, this would serve actual static files",
        .route_info = .{
            .pattern = "/static/*",
            .wildcard_match = file_path,
        },
        .mime_type = if (std.mem.endsWith(u8, file_path, ".css")) "text/css" else if (std.mem.endsWith(u8, file_path, ".js")) "application/javascript" else if (std.mem.endsWith(u8, file_path, ".html")) "text/html" else "application/octet-stream",
    };

    try h3.sendJson(event, static_response);
}

fn documentationHandler(event: *h3.Event) !void {
    const path = event.getPath();
    const doc_path = path[6..]; // Remove "/docs/" prefix

    const content = try std.fmt.allocPrint(event.allocator, "This would contain documentation content for: {s}", .{doc_path});
    defer event.allocator.free(content);

    const doc_response = .{
        .message = "Documentation request",
        .requested_path = path,
        .doc_path = doc_path,
        .content = content,
        .route_info = .{
            .pattern = "/docs/*",
            .wildcard_match = doc_path,
        },
    };

    try h3.sendJson(event, doc_response);
}

// File upload handlers
fn uploadHandler(event: *h3.Event) !void {
    const body = h3.readBody(event) orelse "";
    const content_type = event.getHeader("content-type") orelse "unknown";

    const upload_response = .{
        .message = "File upload received",
        .size = body.len,
        .content_type = content_type,
        .timestamp = std.time.timestamp(),
        .note = "In a real app, this would save the file to disk or cloud storage",
        .route_info = .{
            .pattern = "/upload",
            .upload_type = "general",
        },
    };

    try h3.sendJson(event, upload_response);
}

fn imageUploadHandler(event: *h3.Event) !void {
    const body = h3.readBody(event) orelse "";
    const content_type = event.getHeader("content-type") orelse "unknown";

    // Simple image validation
    const is_image = std.mem.indexOf(u8, content_type, "image/") != null;

    if (!is_image and body.len > 0) {
        try h3.utils.response.badRequest(event, "Only image files are allowed");
        return;
    }

    const image_response = .{
        .message = "Image upload received",
        .size = body.len,
        .content_type = content_type,
        .validation = .{
            .is_image = is_image,
            .max_size = "5MB",
            .allowed_types = .{ "image/jpeg", "image/png", "image/gif", "image/webp" },
        },
        .route_info = .{
            .pattern = "/upload/image",
            .upload_type = "image",
        },
    };

    try h3.sendJson(event, image_response);
}

fn documentUploadHandler(event: *h3.Event) !void {
    const body = h3.readBody(event) orelse "";
    const content_type = event.getHeader("content-type") orelse "unknown";

    const doc_response = .{
        .message = "Document upload received",
        .size = body.len,
        .content_type = content_type,
        .validation = .{
            .max_size = "10MB",
            .allowed_types = .{ "application/pdf", "text/plain", "application/msword" },
        },
        .route_info = .{
            .pattern = "/upload/document",
            .upload_type = "document",
        },
    };

    try h3.sendJson(event, doc_response);
}

// Authentication handlers
fn loginHandler(event: *h3.Event) !void {
    const body = h3.readBody(event) orelse "";

    // Simple login simulation
    const login_response = .{
        .message = "Login successful",
        .token = "valid-token-123",
        .expires_in = 3600,
        .user = .{
            .id = 123,
            .username = "demo_user",
            .role = "user",
        },
        .note = "Use this token in Authorization header: Bearer valid-token-123",
        .received_data = body,
    };

    try h3.sendJson(event, login_response);
}

fn registerHandler(event: *h3.Event) !void {
    const body = h3.readBody(event) orelse "";

    const register_response = .{
        .message = "Registration successful",
        .user_id = 124,
        .username = "new_user",
        .status = "active",
        .created_at = std.time.timestamp(),
        .received_data = body,
    };

    event.setStatus(.created);
    try h3.sendJson(event, register_response);
}

// Protected route handlers
fn protectedHandler(event: *h3.Event) !void {
    const user_id = event.getHeader("X-User-ID") orelse "unknown";
    const user_role = event.getHeader("X-User-Role") orelse "unknown";

    const protected_data = .{
        .message = "Access granted to protected resource",
        .user_id = user_id,
        .user_role = user_role,
        .timestamp = std.time.timestamp(),
        .protected_data = .{
            .secret = "This is protected information",
            .level = "user",
        },
        .middleware_applied = .{"auth"},
    };

    try h3.sendJson(event, protected_data);
}

fn adminHandler(event: *h3.Event) !void {
    const user_id = event.getHeader("X-User-ID") orelse "unknown";
    const user_role = event.getHeader("X-User-Role") orelse "unknown";

    const admin_data = .{
        .message = "Admin access granted",
        .user_id = user_id,
        .user_role = user_role,
        .timestamp = std.time.timestamp(),
        .admin_data = .{
            .system_stats = .{
                .uptime = "24h",
                .memory_usage = "45%",
                .active_connections = 12,
            },
            .permissions = .{ "read", "write", "delete", "admin" },
        },
        .middleware_applied = .{ "auth", "admin" },
    };

    try h3.sendJson(event, admin_data);
}

// API versioning handlers
fn apiV1StatusHandler(event: *h3.Event) !void {
    const v1_status = .{
        .api_version = "1.0",
        .status = "deprecated",
        .message = "API v1 is deprecated, please use v2",
        .endpoints = 15,
        .deprecation_date = "2024-12-31",
        .migration_guide = "/docs/api/v1-to-v2-migration",
    };

    try h3.sendJson(event, v1_status);
}

fn apiV2StatusHandler(event: *h3.Event) !void {
    const v2_status = .{
        .api_version = "2.0",
        .status = "active",
        .message = "API v2 is the current stable version",
        .endpoints = 25,
        .features = .{
            .enhanced_security = true,
            .better_performance = true,
            .improved_error_handling = true,
        },
        .documentation = "/docs/api/v2",
    };

    try h3.sendJson(event, v2_status);
}

// Content type specific handlers
fn jsonHandler(event: *h3.Event) !void {
    const body = h3.readBody(event) orelse "";
    const content_type = event.getHeader("content-type") orelse "";

    if (!std.mem.startsWith(u8, content_type, "application/json")) {
        try h3.utils.response.badRequest(event, "Expected JSON content type");
        return;
    }

    const json_response = .{
        .message = "JSON data received",
        .content_type = content_type,
        .body_length = body.len,
        .parsed_data = "JSON parsing would happen here",
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, json_response);
}

fn formHandler(event: *h3.Event) !void {
    const body = h3.readBody(event) orelse "";
    const content_type = event.getHeader("content-type") orelse "";

    const form_response = .{
        .message = "Form data received",
        .content_type = content_type,
        .body_length = body.len,
        .note = "Form parsing would happen here",
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, form_response);
}

fn xmlHandler(event: *h3.Event) !void {
    const body = h3.readBody(event) orelse "";
    const content_type = event.getHeader("content-type") orelse "";

    if (!std.mem.startsWith(u8, content_type, "application/xml") and
        !std.mem.startsWith(u8, content_type, "text/xml"))
    {
        try h3.utils.response.badRequest(event, "Expected XML content type");
        return;
    }

    const xml_response = .{
        .message = "XML data received",
        .content_type = content_type,
        .body_length = body.len,
        .parsed_data = "XML parsing would happen here",
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, xml_response);
}
