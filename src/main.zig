const std = @import("std");
const rl = @import("raylib");
const OrbitalEntity = @import("orbit.zig").OrbitalEntity;
const Vec3 = @import("orbit.zig").Vec3;
const integrate = @import("orbit.zig").integrate;

const dprint = @import("utils.zig").dprint;

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow(); // Close window and OpenGL context

    // rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

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

    const earth = OrbitalEntity.init("Earth", Vec3.init(0, 0, 0), Vec3.init(0, 0, 0), 5.972e24);
    const moon = OrbitalEntity.init("Moon", Vec3.init(0, 384.4e6, 0), Vec3.init(1e3, 0, 0), 7.38e22);

    moon.prt();
    earth.prt();

    const num_sat = 20;
    var entities: [num_sat + 2]OrbitalEntity = undefined;
    entities[0] = earth;
    entities[1] = moon;

    const mpos = Vec3.init(0, 384.4e6, 0);
    const mvec = Vec3.init(1e3, 0, 0);

    for (entities[2..], 1..) |*ent, index| {
        std.debug.print("\nDEBUG: ent {}\n", .{index});
        // const fac: f32 = @as(f32, @floatFromInt(index)) / (@as(f32, @floatFromInt(num_sat)) * 1.2);
        const fac = rl.math.remap(@as(f32, @floatFromInt(index)), 1.0, @as(f32, @floatFromInt(entities[2..].len)), 0.5, 1.2);
        std.debug.print("fac: {}i\n", .{fac});
        const r = mpos.rlVec().scale(fac).rotateByAxisAngle(rl.Vector3.init(1.0, 0, 0), fac);
        std.debug.print("pos: {}, {}, {}\n", r);
        ent.* = OrbitalEntity.init("s", Vec3.init(r.x, r.y, r.z), mvec, 1e9);
    }

    const secondsToRun: i32 = 1 * 60 * 60;
    //  endTime: i64 = 2628000; // one month in seconds

    integrate(&entities, secondsToRun);

    for (entities) |ent| {
        ent.prt();
    }

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        camera.update(rl.CameraMode.camera_third_person);

        integrate(&entities, secondsToRun);

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        rl.drawText("Congrats! You created your first window!", 190, 200, 20, rl.Color.light_gray);
        rl.drawText("earth: {}", 190, 240, 20, rl.Color.red);
        rl.drawFPS(10, 10);

        // text -----------

        {
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
                rl.drawSphere(map(ent.pos.rlVec()), radius, color);
            }
            // rl.drawSphere(entities[0].pos.rlVec(), 10, rl.Color.blue);
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
