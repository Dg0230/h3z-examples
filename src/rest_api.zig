//! REST API H3z Example
//!
//! This example demonstrates a complete REST API implementation using H3z:
//! - Full CRUD operations (Create, Read, Update, Delete)
//! - RESTful resource management
//! - JSON request/response handling
//! - Data validation and error handling
//! - API versioning and documentation
//! - Proper HTTP status codes
//!
//! Features demonstrated:
//! - User management API
//! - Product catalog API
//! - Order processing API
//! - API documentation endpoint
//! - Error handling patterns
//! - Data persistence simulation

const std = @import("std");
const h3 = @import("h3");
const print = std.debug.print;

// Simple in-memory data structures for demo
var users = std.ArrayList(User).init(std.heap.page_allocator);
var products = std.ArrayList(Product).init(std.heap.page_allocator);
var orders = std.ArrayList(Order).init(std.heap.page_allocator);
var next_user_id: u32 = 1;
var next_product_id: u32 = 1;
var next_order_id: u32 = 1;

const User = struct {
    id: u32,
    name: []const u8,
    email: []const u8,
    created_at: i64,
    updated_at: i64,
};

const Product = struct {
    id: u32,
    name: []const u8,
    description: []const u8,
    price: f64,
    stock: u32,
    category: []const u8,
    created_at: i64,
    updated_at: i64,
};

const Order = struct {
    id: u32,
    user_id: u32,
    product_id: u32,
    quantity: u32,
    total_price: f64,
    status: []const u8,
    created_at: i64,
    updated_at: i64,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    print("🚀 H3z REST API Example\n", .{});
    print("📖 This example demonstrates: CRUD operations, RESTful design, JSON APIs\n", .{});
    print("🔧 Starting REST API server...\n", .{});

    // Initialize sample data
    try initializeSampleData();

    // Create H3z app
    var app = try h3.createApp(allocator);
    defer app.deinit();

    // Add middleware
    _ = app.use(h3.middleware.logger);
    _ = app.use(h3.middleware.cors);
    _ = app.use(jsonMiddleware);

    // API documentation
    _ = app.get("/", apiDocumentationHandler);
    _ = app.get("/api", apiInfoHandler);

    // Users API (CRUD)
    _ = app.get("/api/v1/users", getUsersHandler);
    _ = app.get("/api/v1/users/:id", getUserHandler);
    _ = app.post("/api/v1/users", createUserHandler);
    _ = app.put("/api/v1/users/:id", updateUserHandler);
    _ = app.delete("/api/v1/users/:id", deleteUserHandler);

    // Products API (CRUD)
    _ = app.get("/api/v1/products", getProductsHandler);
    _ = app.get("/api/v1/products/:id", getProductHandler);
    _ = app.post("/api/v1/products", createProductHandler);
    _ = app.put("/api/v1/products/:id", updateProductHandler);
    _ = app.delete("/api/v1/products/:id", deleteProductHandler);

    // Orders API (CRUD)
    _ = app.get("/api/v1/orders", getOrdersHandler);
    _ = app.get("/api/v1/orders/:id", getOrderHandler);
    _ = app.post("/api/v1/orders", createOrderHandler);
    _ = app.put("/api/v1/orders/:id", updateOrderHandler);
    _ = app.delete("/api/v1/orders/:id", deleteOrderHandler);

    // Additional API endpoints
    _ = app.get("/api/v1/users/:id/orders", getUserOrdersHandler);
    _ = app.get("/api/v1/products/category/:category", getProductsByCategoryHandler);
    _ = app.get("/api/v1/stats", getStatsHandler);

    print("🌐 REST API server running at http://127.0.0.1:3000\n", .{});
    print("📚 API Documentation available at: http://127.0.0.1:3000\n", .{});
    print("🔗 API Base URL: http://127.0.0.1:3000/api/v1\n", .{});
    print("\n📋 Available Resources:\n", .{});
    print("  Users:    /api/v1/users\n", .{});
    print("  Products: /api/v1/products\n", .{});
    print("  Orders:   /api/v1/orders\n", .{});
    print("  Stats:    /api/v1/stats\n", .{});
    print("\n💡 Press Ctrl+C to stop the server\n", .{});

    // Start server
    try h3.serve(&app, .{ .port = 3000 });
}

fn initializeSampleData() !void {
    // Sample users
    try users.append(User{
        .id = next_user_id,
        .name = "John Doe",
        .email = "john@example.com",
        .created_at = std.time.timestamp(),
        .updated_at = std.time.timestamp(),
    });
    next_user_id += 1;

    try users.append(User{
        .id = next_user_id,
        .name = "Jane Smith",
        .email = "jane@example.com",
        .created_at = std.time.timestamp(),
        .updated_at = std.time.timestamp(),
    });
    next_user_id += 1;

    // Sample products
    try products.append(Product{
        .id = next_product_id,
        .name = "Laptop",
        .description = "High-performance laptop",
        .price = 999.99,
        .stock = 10,
        .category = "electronics",
        .created_at = std.time.timestamp(),
        .updated_at = std.time.timestamp(),
    });
    next_product_id += 1;

    try products.append(Product{
        .id = next_product_id,
        .name = "Coffee Mug",
        .description = "Ceramic coffee mug",
        .price = 12.99,
        .stock = 50,
        .category = "home",
        .created_at = std.time.timestamp(),
        .updated_at = std.time.timestamp(),
    });
    next_product_id += 1;

    // Sample order
    try orders.append(Order{
        .id = next_order_id,
        .user_id = 1,
        .product_id = 1,
        .quantity = 1,
        .total_price = 999.99,
        .status = "pending",
        .created_at = std.time.timestamp(),
        .updated_at = std.time.timestamp(),
    });
    next_order_id += 1;
}

// ============================================================================
// Middleware
// ============================================================================

fn jsonMiddleware(event: *h3.Event, context: h3.MiddlewareContext, index: usize, final_handler: h3.Handler) !void {
    // Set JSON content type for API responses
    if (std.mem.startsWith(u8, event.getPath(), "/api/")) {
        try event.setHeader("Content-Type", "application/json");
    }

    try context.next(event, index, final_handler);
}

// ============================================================================
// Documentation Handlers
// ============================================================================

fn apiDocumentationHandler(event: *h3.Event) !void {
    const html =
        \\<!DOCTYPE html>
        \\<html lang="en">
        \\<head>
        \\    <meta charset="UTF-8">
        \\    <meta name="viewport" content="width=device-width, initial-scale=1.0">
        \\    <title>H3z REST API Documentation</title>
        \\    <style>
        \\        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
        \\               max-width: 1200px; margin: 0 auto; padding: 20px; line-height: 1.6; }
        \\        .resource { margin: 30px 0; padding: 20px; background: #f8f9fa; border-radius: 8px; }
        \\        .endpoint { background: #fff; padding: 15px; margin: 10px 0; border-radius: 5px; border-left: 4px solid #007acc; }
        \\        .method { font-weight: bold; padding: 4px 8px; border-radius: 3px; color: white; margin-right: 10px; }
        \\        .get { background: #28a745; }
        \\        .post { background: #007bff; }
        \\        .put { background: #ffc107; color: black; }
        \\        .delete { background: #dc3545; }
        \\        .path { font-family: monospace; background: #e9ecef; padding: 2px 6px; border-radius: 3px; }
        \\        .example { margin-top: 10px; padding: 10px; background: #f1f3f4; border-radius: 3px; font-family: monospace; font-size: 0.9em; }
        \\    </style>
        \\</head>
        \\<body>
        \\    <h1>🚀 H3z REST API Documentation</h1>
        \\    <p>Complete REST API example with CRUD operations for Users, Products, and Orders</p>
        \\
        \\    <div class="resource">
        \\        <h2>👥 Users API</h2>
        \\        <div class="endpoint">
        \\            <span class="method get">GET</span> <span class="path">/api/v1/users</span>
        \\            <p>Get all users</p>
        \\            <div class="example">curl http://localhost:3000/api/v1/users</div>
        \\        </div>
        \\        <div class="endpoint">
        \\            <span class="method get">GET</span> <span class="path">/api/v1/users/:id</span>
        \\            <p>Get user by ID</p>
        \\            <div class="example">curl http://localhost:3000/api/v1/users/1</div>
        \\        </div>
        \\        <div class="endpoint">
        \\            <span class="method post">POST</span> <span class="path">/api/v1/users</span>
        \\            <p>Create new user</p>
        \\            <div class="example">curl -X POST -H "Content-Type: application/json" -d '{"name":"John","email":"john@example.com"}' http://localhost:3000/api/v1/users</div>
        \\        </div>
        \\        <div class="endpoint">
        \\            <span class="method put">PUT</span> <span class="path">/api/v1/users/:id</span>
        \\            <p>Update user</p>
        \\            <div class="example">curl -X PUT -H "Content-Type: application/json" -d '{"name":"John Updated"}' http://localhost:3000/api/v1/users/1</div>
        \\        </div>
        \\        <div class="endpoint">
        \\            <span class="method delete">DELETE</span> <span class="path">/api/v1/users/:id</span>
        \\            <p>Delete user</p>
        \\            <div class="example">curl -X DELETE http://localhost:3000/api/v1/users/1</div>
        \\        </div>
        \\    </div>
        \\
        \\    <div class="resource">
        \\        <h2>📦 Products API</h2>
        \\        <div class="endpoint">
        \\            <span class="method get">GET</span> <span class="path">/api/v1/products</span>
        \\            <p>Get all products</p>
        \\        </div>
        \\        <div class="endpoint">
        \\            <span class="method post">POST</span> <span class="path">/api/v1/products</span>
        \\            <p>Create new product</p>
        \\            <div class="example">curl -X POST -H "Content-Type: application/json" -d '{"name":"Widget","description":"A useful widget","price":29.99,"stock":100,"category":"tools"}' http://localhost:3000/api/v1/products</div>
        \\        </div>
        \\        <div class="endpoint">
        \\            <span class="method get">GET</span> <span class="path">/api/v1/products/category/:category</span>
        \\            <p>Get products by category</p>
        \\            <div class="example">curl http://localhost:3000/api/v1/products/category/electronics</div>
        \\        </div>
        \\    </div>
        \\
        \\    <div class="resource">
        \\        <h2>🛒 Orders API</h2>
        \\        <div class="endpoint">
        \\            <span class="method get">GET</span> <span class="path">/api/v1/orders</span>
        \\            <p>Get all orders</p>
        \\        </div>
        \\        <div class="endpoint">
        \\            <span class="method post">POST</span> <span class="path">/api/v1/orders</span>
        \\            <p>Create new order</p>
        \\            <div class="example">curl -X POST -H "Content-Type: application/json" -d '{"user_id":1,"product_id":1,"quantity":2}' http://localhost:3000/api/v1/orders</div>
        \\        </div>
        \\        <div class="endpoint">
        \\            <span class="method get">GET</span> <span class="path">/api/v1/users/:id/orders</span>
        \\            <p>Get orders for a specific user</p>
        \\            <div class="example">curl http://localhost:3000/api/v1/users/1/orders</div>
        \\        </div>
        \\    </div>
        \\
        \\    <div class="resource">
        \\        <h2>📊 Statistics</h2>
        \\        <div class="endpoint">
        \\            <span class="method get">GET</span> <span class="path">/api/v1/stats</span>
        \\            <p>Get API statistics</p>
        \\            <div class="example">curl http://localhost:3000/api/v1/stats</div>
        \\        </div>
        \\    </div>
        \\</body>
        \\</html>
    ;

    try h3.sendHtml(event, html);
}

fn apiInfoHandler(event: *h3.Event) !void {
    const api_info = .{
        .name = "H3z REST API Example",
        .version = "1.0.0",
        .description = "Complete REST API demonstration with CRUD operations",
        .base_url = "http://localhost:3000/api/v1",
        .resources = .{
            .users = "/api/v1/users",
            .products = "/api/v1/products",
            .orders = "/api/v1/orders",
        },
        .features = .{
            .crud_operations = true,
            .json_api = true,
            .error_handling = true,
            .data_validation = true,
        },
        .statistics = .{
            .total_users = users.items.len,
            .total_products = products.items.len,
            .total_orders = orders.items.len,
        },
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, api_info);
}

// ============================================================================
// Users API Handlers
// ============================================================================

fn getUsersHandler(event: *h3.Event) !void {
    const response = .{
        .users = users.items,
        .total = users.items.len,
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, response);
}

fn getUserHandler(event: *h3.Event) !void {
    const id_str = h3.getParam(event, "id") orelse {
        try h3.utils.response.badRequest(event, "User ID is required");
        return;
    };

    const id = std.fmt.parseInt(u32, id_str, 10) catch {
        try h3.utils.response.badRequest(event, "Invalid user ID format");
        return;
    };

    for (users.items) |user| {
        if (user.id == id) {
            try h3.sendJson(event, user);
            return;
        }
    }

    try h3.utils.response.notFound(event, "User not found");
}

fn createUserHandler(event: *h3.Event) !void {
    const body = h3.readBody(event) orelse {
        try h3.utils.response.badRequest(event, "Request body is required");
        return;
    };

    // Simple JSON parsing simulation (in real app, use proper JSON parser)
    if (body.len == 0) {
        try h3.utils.response.badRequest(event, "Empty request body");
        return;
    }

    const new_user = User{
        .id = next_user_id,
        .name = "New User", // In real app, parse from JSON
        .email = "new@example.com", // In real app, parse from JSON
        .created_at = std.time.timestamp(),
        .updated_at = std.time.timestamp(),
    };

    try users.append(new_user);
    next_user_id += 1;

    event.setStatus(.created);
    try h3.sendJson(event, .{
        .message = "User created successfully",
        .user = new_user,
        .received_data = body,
    });
}

fn updateUserHandler(event: *h3.Event) !void {
    const id_str = h3.getParam(event, "id") orelse {
        try h3.utils.response.badRequest(event, "User ID is required");
        return;
    };

    const id = std.fmt.parseInt(u32, id_str, 10) catch {
        try h3.utils.response.badRequest(event, "Invalid user ID format");
        return;
    };

    const body = h3.readBody(event) orelse {
        try h3.utils.response.badRequest(event, "Request body is required");
        return;
    };

    for (users.items) |*user| {
        if (user.id == id) {
            user.updated_at = std.time.timestamp();
            // In real app, update fields from JSON body

            try h3.sendJson(event, .{
                .message = "User updated successfully",
                .user = user.*,
                .received_data = body,
            });
            return;
        }
    }

    try h3.utils.response.notFound(event, "User not found");
}

fn deleteUserHandler(event: *h3.Event) !void {
    const id_str = h3.getParam(event, "id") orelse {
        try h3.utils.response.badRequest(event, "User ID is required");
        return;
    };

    const id = std.fmt.parseInt(u32, id_str, 10) catch {
        try h3.utils.response.badRequest(event, "Invalid user ID format");
        return;
    };

    for (users.items, 0..) |user, i| {
        if (user.id == id) {
            _ = users.orderedRemove(i);

            event.setStatus(.no_content);
            try h3.sendJson(event, .{
                .message = "User deleted successfully",
                .deleted_id = id,
            });
            return;
        }
    }

    try h3.utils.response.notFound(event, "User not found");
}

// ============================================================================
// Products API Handlers
// ============================================================================

fn getProductsHandler(event: *h3.Event) !void {
    const response = .{
        .products = products.items,
        .total = products.items.len,
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, response);
}

fn getProductHandler(event: *h3.Event) !void {
    const id_str = h3.getParam(event, "id") orelse {
        try h3.utils.response.badRequest(event, "Product ID is required");
        return;
    };

    const id = std.fmt.parseInt(u32, id_str, 10) catch {
        try h3.utils.response.badRequest(event, "Invalid product ID format");
        return;
    };

    for (products.items) |product| {
        if (product.id == id) {
            try h3.sendJson(event, product);
            return;
        }
    }

    try h3.utils.response.notFound(event, "Product not found");
}

fn createProductHandler(event: *h3.Event) !void {
    const body = h3.readBody(event) orelse {
        try h3.utils.response.badRequest(event, "Request body is required");
        return;
    };

    const new_product = Product{
        .id = next_product_id,
        .name = "New Product", // In real app, parse from JSON
        .description = "Product description", // In real app, parse from JSON
        .price = 19.99, // In real app, parse from JSON
        .stock = 10, // In real app, parse from JSON
        .category = "general", // In real app, parse from JSON
        .created_at = std.time.timestamp(),
        .updated_at = std.time.timestamp(),
    };

    try products.append(new_product);
    next_product_id += 1;

    event.setStatus(.created);
    try h3.sendJson(event, .{
        .message = "Product created successfully",
        .product = new_product,
        .received_data = body,
    });
}

fn updateProductHandler(event: *h3.Event) !void {
    const id_str = h3.getParam(event, "id") orelse {
        try h3.utils.response.badRequest(event, "Product ID is required");
        return;
    };

    const id = std.fmt.parseInt(u32, id_str, 10) catch {
        try h3.utils.response.badRequest(event, "Invalid product ID format");
        return;
    };

    const body = h3.readBody(event) orelse {
        try h3.utils.response.badRequest(event, "Request body is required");
        return;
    };

    for (products.items) |*product| {
        if (product.id == id) {
            product.updated_at = std.time.timestamp();

            try h3.sendJson(event, .{
                .message = "Product updated successfully",
                .product = product.*,
                .received_data = body,
            });
            return;
        }
    }

    try h3.utils.response.notFound(event, "Product not found");
}

fn deleteProductHandler(event: *h3.Event) !void {
    const id_str = h3.getParam(event, "id") orelse {
        try h3.utils.response.badRequest(event, "Product ID is required");
        return;
    };

    const id = std.fmt.parseInt(u32, id_str, 10) catch {
        try h3.utils.response.badRequest(event, "Invalid product ID format");
        return;
    };

    for (products.items, 0..) |product, i| {
        if (product.id == id) {
            _ = products.orderedRemove(i);

            event.setStatus(.no_content);
            try h3.sendJson(event, .{
                .message = "Product deleted successfully",
                .deleted_id = id,
            });
            return;
        }
    }

    try h3.utils.response.notFound(event, "Product not found");
}

fn getProductsByCategoryHandler(event: *h3.Event) !void {
    const category = h3.getParam(event, "category") orelse {
        try h3.utils.response.badRequest(event, "Category is required");
        return;
    };

    var category_products = std.ArrayList(Product).init(std.heap.page_allocator);
    defer category_products.deinit();

    for (products.items) |product| {
        if (std.mem.eql(u8, product.category, category)) {
            try category_products.append(product);
        }
    }

    const response = .{
        .category = category,
        .products = category_products.items,
        .total = category_products.items.len,
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, response);
}

// ============================================================================
// Orders API Handlers
// ============================================================================

fn getOrdersHandler(event: *h3.Event) !void {
    const response = .{
        .orders = orders.items,
        .total = orders.items.len,
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, response);
}

fn getOrderHandler(event: *h3.Event) !void {
    const id_str = h3.getParam(event, "id") orelse {
        try h3.utils.response.badRequest(event, "Order ID is required");
        return;
    };

    const id = std.fmt.parseInt(u32, id_str, 10) catch {
        try h3.utils.response.badRequest(event, "Invalid order ID format");
        return;
    };

    for (orders.items) |order| {
        if (order.id == id) {
            try h3.sendJson(event, order);
            return;
        }
    }

    try h3.utils.response.notFound(event, "Order not found");
}

fn createOrderHandler(event: *h3.Event) !void {
    const body = h3.readBody(event) orelse {
        try h3.utils.response.badRequest(event, "Request body is required");
        return;
    };

    // In a real app, you would parse JSON and validate user_id and product_id exist
    const new_order = Order{
        .id = next_order_id,
        .user_id = 1, // In real app, parse from JSON
        .product_id = 1, // In real app, parse from JSON
        .quantity = 1, // In real app, parse from JSON
        .total_price = 19.99, // In real app, calculate from product price * quantity
        .status = "pending",
        .created_at = std.time.timestamp(),
        .updated_at = std.time.timestamp(),
    };

    try orders.append(new_order);
    next_order_id += 1;

    event.setStatus(.created);
    try h3.sendJson(event, .{
        .message = "Order created successfully",
        .order = new_order,
        .received_data = body,
    });
}

fn updateOrderHandler(event: *h3.Event) !void {
    const id_str = h3.getParam(event, "id") orelse {
        try h3.utils.response.badRequest(event, "Order ID is required");
        return;
    };

    const id = std.fmt.parseInt(u32, id_str, 10) catch {
        try h3.utils.response.badRequest(event, "Invalid order ID format");
        return;
    };

    const body = h3.readBody(event) orelse {
        try h3.utils.response.badRequest(event, "Request body is required");
        return;
    };

    for (orders.items) |*order| {
        if (order.id == id) {
            order.updated_at = std.time.timestamp();
            // In real app, update status or other fields from JSON

            try h3.sendJson(event, .{
                .message = "Order updated successfully",
                .order = order.*,
                .received_data = body,
            });
            return;
        }
    }

    try h3.utils.response.notFound(event, "Order not found");
}

fn deleteOrderHandler(event: *h3.Event) !void {
    const id_str = h3.getParam(event, "id") orelse {
        try h3.utils.response.badRequest(event, "Order ID is required");
        return;
    };

    const id = std.fmt.parseInt(u32, id_str, 10) catch {
        try h3.utils.response.badRequest(event, "Invalid order ID format");
        return;
    };

    for (orders.items, 0..) |order, i| {
        if (order.id == id) {
            _ = orders.orderedRemove(i);

            event.setStatus(.no_content);
            try h3.sendJson(event, .{
                .message = "Order deleted successfully",
                .deleted_id = id,
            });
            return;
        }
    }

    try h3.utils.response.notFound(event, "Order not found");
}

fn getUserOrdersHandler(event: *h3.Event) !void {
    const user_id_str = h3.getParam(event, "id") orelse {
        try h3.utils.response.badRequest(event, "User ID is required");
        return;
    };

    const user_id = std.fmt.parseInt(u32, user_id_str, 10) catch {
        try h3.utils.response.badRequest(event, "Invalid user ID format");
        return;
    };

    var user_orders = std.ArrayList(Order).init(std.heap.page_allocator);
    defer user_orders.deinit();

    for (orders.items) |order| {
        if (order.user_id == user_id) {
            try user_orders.append(order);
        }
    }

    const response = .{
        .user_id = user_id,
        .orders = user_orders.items,
        .total = user_orders.items.len,
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, response);
}

fn getStatsHandler(event: *h3.Event) !void {
    // Calculate some basic statistics
    var total_revenue: f64 = 0;
    var pending_orders: u32 = 0;
    var completed_orders: u32 = 0;

    for (orders.items) |order| {
        total_revenue += order.total_price;
        if (std.mem.eql(u8, order.status, "pending")) {
            pending_orders += 1;
        } else if (std.mem.eql(u8, order.status, "completed")) {
            completed_orders += 1;
        }
    }

    var total_stock: u32 = 0;
    for (products.items) |product| {
        total_stock += product.stock;
    }

    const stats = .{
        .overview = .{
            .total_users = users.items.len,
            .total_products = products.items.len,
            .total_orders = orders.items.len,
            .total_revenue = total_revenue,
        },
        .orders = .{
            .pending = pending_orders,
            .completed = completed_orders,
            .total = orders.items.len,
        },
        .inventory = .{
            .total_stock = total_stock,
            .products_count = products.items.len,
        },
        .api_info = .{
            .version = "1.0.0",
            .endpoints_count = 20,
            .last_updated = std.time.timestamp(),
        },
        .timestamp = std.time.timestamp(),
    };

    try h3.sendJson(event, stats);
}
