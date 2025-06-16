const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Add h3z dependency
    const h3z = b.dependency("h3z", .{
        .target = target,
        .optimize = optimize,
    });

    // Basic server example
    const basic_server = b.addExecutable(.{
        .name = "basic_server",
        .root_source_file = b.path("src/basic_server.zig"),
        .target = target,
        .optimize = optimize,
    });
    basic_server.root_module.addImport("h3", h3z.module("h3"));
    b.installArtifact(basic_server);

    // Multi-mode server example
    const multi_mode_server = b.addExecutable(.{
        .name = "multi_mode_server",
        .root_source_file = b.path("src/multi_mode_server.zig"),
        .target = target,
        .optimize = optimize,
    });
    multi_mode_server.root_module.addImport("h3", h3z.module("h3"));
    b.installArtifact(multi_mode_server);

    // Middleware example
    const middleware_example = b.addExecutable(.{
        .name = "middleware_example",
        .root_source_file = b.path("src/middleware_example.zig"),
        .target = target,
        .optimize = optimize,
    });
    middleware_example.root_module.addImport("h3", h3z.module("h3"));
    b.installArtifact(middleware_example);

    // Advanced routing example
    const advanced_routing = b.addExecutable(.{
        .name = "advanced_routing",
        .root_source_file = b.path("src/advanced_routing.zig"),
        .target = target,
        .optimize = optimize,
    });
    advanced_routing.root_module.addImport("h3", h3z.module("h3"));
    b.installArtifact(advanced_routing);

    // REST API example
    const rest_api = b.addExecutable(.{
        .name = "rest_api",
        .root_source_file = b.path("src/rest_api.zig"),
        .target = target,
        .optimize = optimize,
    });
    rest_api.root_module.addImport("h3", h3z.module("h3"));
    b.installArtifact(rest_api);

    // Run commands
    const run_basic = b.addRunArtifact(basic_server);
    const run_multi_mode = b.addRunArtifact(multi_mode_server);
    const run_middleware = b.addRunArtifact(middleware_example);
    const run_advanced = b.addRunArtifact(advanced_routing);
    const run_api = b.addRunArtifact(rest_api);

    if (b.args) |args| {
        run_basic.addArgs(args);
        run_multi_mode.addArgs(args);
        run_middleware.addArgs(args);
        run_advanced.addArgs(args);
        run_api.addArgs(args);
    }

    // Run steps
    const run_basic_step = b.step("basic", "Run basic server example");
    run_basic_step.dependOn(&run_basic.step);

    const run_multi_step = b.step("multi", "Run multi-mode server example");
    run_multi_step.dependOn(&run_multi_mode.step);

    const run_middleware_step = b.step("middleware", "Run middleware example");
    run_middleware_step.dependOn(&run_middleware.step);

    const run_advanced_step = b.step("advanced", "Run advanced routing example");
    run_advanced_step.dependOn(&run_advanced.step);

    const run_api_step = b.step("api", "Run REST API example");
    run_api_step.dependOn(&run_api.step);

    // Default run step (basic server)
    const run_step = b.step("run", "Run the basic server example");
    run_step.dependOn(&run_basic.step);

    // Tests
    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    unit_tests.root_module.addImport("h3", h3z.module("h3"));

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
