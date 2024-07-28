const std = @import("std");

const Vec3 = struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn init(x: f64, y: f64, z: f64) Vec3 {
        return Vec3{ .x = x, .y = y, .z = z };
    }

    pub fn prt(self: Vec3) void {
        std.debug.print("({}, {}, {})\n", .{ self.x, self.y, self.z });
    }
};

const OrbitalEntity = struct {
    pos: Vec3,
    vel: Vec3,
    mass: f64,
    name: []const u8,

    pub fn init(name: []const u8, pos: Vec3, vel: Vec3, mass: f64) OrbitalEntity {
        return OrbitalEntity{ .pos = pos, .vel = vel, .mass = mass, .name = name };
    }

    pub fn prt(self: OrbitalEntity) void {
        std.debug.print("\n{s}:\n", .{self.name});
        std.debug.print("position:", .{});
        self.pos.prt();
        std.debug.print("velocity:", .{});
        self.vel.prt();
        std.debug.print("mass: {}\n", .{self.mass});
    }
};

pub fn main() anyerror!void {
    std.debug.print("Hello Orbit!\n", .{});

    const earth = OrbitalEntity.init("Earth", Vec3.init(0, 0, 0), Vec3.init(0, 0, 0), 5.972e24);
    const moon = OrbitalEntity.init("Moon", Vec3.init(0, 384.4e6, 0), Vec3.init(0, 0, 0), 7.38e22);

    moon.prt();
    earth.prt();
}

// const rl = @import("raylib");
//
// pub fn main() anyerror!void {
//     // Initialization
//     //--------------------------------------------------------------------------------------
//     const screenWidth = 800;
//     const screenHeight = 450;
//
//     rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
//     defer rl.closeWindow(); // Close window and OpenGL context
//
//     rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
//     //--------------------------------------------------------------------------------------
//
//     // Main game loop
//     while (!rl.windowShouldClose()) { // Detect window close button or ESC key
//         // Update
//         //----------------------------------------------------------------------------------
//         // TODO: Update your variables here
//         //----------------------------------------------------------------------------------
//
//         // Draw
//         //----------------------------------------------------------------------------------
//         rl.beginDrawing();
//         defer rl.endDrawing();
//
//         rl.clearBackground(rl.Color.white);
//
//         rl.drawText("Congrats! You created your first window!", 190, 200, 20, rl.Color.light_gray);
//         //----------------------------------------------------------------------------------
//     }
// }
