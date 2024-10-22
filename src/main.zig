const std = @import("std");
const builtin = @import("builtin");
const rl = @import("raylib");

const OrbitalEntity = @import("orbit.zig").OrbitalEntity;
const orbit = @import("orbit.zig");
const ui = @import("ui.zig");

const dprint = @import("utils.zig").dprint;

pub fn main() anyerror!void {
    // Program Initialization
    //--------------------------------------------------------------------------------------

    // only the c_allocator seems to be compatible with emscripten
    // Must add this to the emcc.zig flags for emscripten
    // "-sUSE_OFFSET_CONVERTER",

    var allocator = std.heap.c_allocator;

    const bytes = try allocator.alloc(i32, 100);
    defer allocator.free(bytes);

    for (bytes, 0..) |*value, i| {
        value.* = @intCast(i);
    }

    std.debug.print("printing stuff, {d}", .{bytes});

    var ui_options = ui.Options.init();

    // Raylib Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow(); // Close window and OpenGL context

    // rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second

    var camera = rl.Camera3D{
        .position = rl.Vector3.init(0, 0, 20),
        .target = rl.Vector3.init(0, 0, 0),
        .up = rl.Vector3.init(0, 1, 0),
        .fovy = 80,
        .projection = rl.CameraProjection.camera_perspective,
    };

    // Orbital initialisation
    //--------------------------------------------------------------------------------------

    std.debug.print("Hello Orbit!\n", .{});

    const earth = OrbitalEntity.init("Earth", rl.Vector3.init(0, 0, 0), rl.Vector3.init(0, 0, 0), 5.972e24);
    const moon = OrbitalEntity.init("Moon", rl.Vector3.init(0, 384.4e6, 0), rl.Vector3.init(1e3, 0, 0), 7.38e22);

    moon.prt();
    earth.prt();

    const num_sat = 200;
    var entities: [num_sat + 2]OrbitalEntity = undefined;
    entities[0] = earth;
    entities[1] = moon;

    var total_time: i32 = 0;

    const mpos = rl.Vector3.init(0, 384.4e6, 0);
    const mvec = rl.Vector3.init(1e3, 0, 0);

    for (entities[2..], 1..) |*ent, index| {
        const fac = rl.math.remap(to(f32, index), 0, to(f32, entities[2..].len), 0.5, 1.2);
        const r = mpos.scale(fac).rotateByAxisAngle(rl.Vector3.init(1.0, 0, 0), fac);
        ent.* = OrbitalEntity.init("s", rl.Vector3.init(r.x, r.y, r.z), mvec, 1e9);
    }

    const secondIncraments = [_]i32{ 1, 60, 15 * 60, 60 * 60, 6 * 60 * 60, 1 * 24 * 60 * 60, 15 * 24 * 60 * 68 };
    var incramentIndex: usize = 3;

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        camera.update(rl.CameraMode.camera_third_person);

        if (rl.isKeyPressed(rl.KeyboardKey.key_up) and incramentIndex < secondIncraments.len) {
            incramentIndex += 1;
        }
        if (rl.isKeyPressed(rl.KeyboardKey.key_down) and incramentIndex > 0) {
            incramentIndex -= 1;
        }

        ui_options.show_fps = ui_options.show_fps != rl.isKeyPressed(rl.KeyboardKey.key_f);
        ui_options.show_orbital_stats = ui_options.show_orbital_stats != rl.isKeyPressed(rl.KeyboardKey.key_i);
        ui_options.show_sim = ui_options.show_sim != rl.isKeyPressed(rl.KeyboardKey.key_o);

        orbit.integrate(&entities, secondIncraments[incramentIndex]);

        total_time += secondIncraments[incramentIndex];

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        // text ----------------
        rl.clearBackground(rl.Color.black);

        if (ui_options.show_fps) rl.drawFPS(10, 10);

        if (ui_options.show_orbital_stats) ui.orbitalStatsWriter(
            &entities,
            secondIncraments[incramentIndex],
            total_time,
            10,
            35,
            20,
        );

        // 3D obects -----------
        if (ui_options.show_sim) {
            camera.begin();
            defer camera.end();
            for (entities, 0..) |ent, index| {
                var color: rl.Color = undefined;
                var radius: f32 = undefined;
                if (index == 0) {
                    color = rl.Color.blue;
                    radius = 2;
                } else if (index == 1) {
                    color = rl.Color.gray;
                    radius = 0.6;
                } else {
                    const hue = to(f32, index + 1) / to(f32, entities.len) * 360;
                    color = rl.Color.fromHSV(hue, 0.5, 0.7);
                    radius = 0.3;
                }
                rl.drawSphere(map(ent.pos), radius, color);
            }
        }
        //----------------------------------------------------------------------------------
    }
}

// map input coord to screenspace scale
fn map(input: rl.Vector3) rl.Vector3 {
    const dist_unit = 384.4e6;
    return input.scale(10.0 / dist_unit);
}

// int to float conversion util
fn to(T: type, n: anytype) T {
    return @as(T, @floatFromInt(n));
}
