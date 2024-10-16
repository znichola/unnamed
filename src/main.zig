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
    const satelite = OrbitalEntity.init("satelite", Vec3.init(0, 300.4e6, 0), Vec3.init(1e3, 0, 0), 1e3);
    const s2 = OrbitalEntity.init("satelite", Vec3.init(0, 250.4e6, 0), Vec3.init(1e3, 0, 1e3), 1e3);
    const s3 = OrbitalEntity.init("satelite", Vec3.init(0, 200.4e6, 0), Vec3.init(1e3, 1e2, 0), 1e3);
    const s4 = OrbitalEntity.init("satelite", Vec3.init(0, 230.4e6, 0), Vec3.init(1e3, 0, 1e3), 1e3);
    const s5 = OrbitalEntity.init("satelite", Vec3.init(0, 150.4e6, 0), Vec3.init(1e3, 1e2, 0), 1e3);
    moon.prt();
    earth.prt();

    var entities = [_]OrbitalEntity{ earth, moon, satelite, s2, s3, s4, s5 };
    const secondsToRun: i32 = 1 * 60 * 60;
    //  endTime: i64 = 2628000; // one month in seconds

    integrate(&entities, secondsToRun);

    entities[0].prt();
    entities[1].prt();

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
        rl.drawText("moon:", 190, 240, 20, rl.Color.red);
        rl.drawFPS(10, 10);

        // text -----------

        {
            camera.begin();
            defer camera.end();
            rl.drawSphere(map(entities[0].pos.rlVec()), 1, rl.Color.blue);
            rl.drawSphere(map(entities[1].pos.rlVec()), 0.5, rl.Color.red);
            rl.drawSphere(map(entities[2].pos.rlVec()), 0.5, rl.Color.purple);
            rl.drawSphere(map(entities[3].pos.rlVec()), 0.5, rl.Color.pink);
            rl.drawSphere(map(entities[4].pos.rlVec()), 0.5, rl.Color.yellow);
            rl.drawSphere(map(entities[5].pos.rlVec()), 0.5, rl.Color.green);
            rl.drawSphere(map(entities[6].pos.rlVec()), 0.5, rl.Color.dark_purple);
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
