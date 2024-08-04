const std = @import("std");
const dprint = std.debug.print;
const Vec3 = struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn init(x: f64, y: f64, z: f64) Vec3 {
        return Vec3{ .x = x, .y = y, .z = z };
    }

    pub fn initZero() Vec3 {
        return Vec3{ .x = 0, .y = 0, .z = 0 };
    }

    pub fn prt(self: Vec3) void {
        std.debug.print("({}, {}, {})\n", .{ self.x, self.y, self.z });
    }
};

const Point = struct {
    x: i32,
};

// call a function to initialize an array
var more_points = [_]Point{makePoint(3)} ** 10;
fn makePoint(x: i32) Point {
    return Point{
        .x = x,
        .y = x * 2,
    };
}

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

pub fn integrate(entities: []OrbitalEntity, t_end: f64) void {

    // time unit is minutes and steps are descrete
    var t: f64 = 0;
    const dt: f64 = 1; // 86400; // one day in seconds
    const BIG_G: f64 = 6.67E-11;

    while (t < t_end) {
        for (entities) |*e1| {
            // dprint("Entity {s} time: {}\n", .{ e1.name, t });
            var a_g = Vec3.initZero(); // accumulated gravitational acceleration;

            for (entities) |*e2| {
                if (e1.name[0] != e2.name[0]) {
                    // dprint("{s} with {s} at time: {}\n", .{ e1.name, e2.name, t });

                    // distance between points
                    const r_vec = Vec3.init(e1.pos.x - e2.pos.x, e1.pos.y - e2.pos.y, e1.pos.z - e2.pos.z);
                    const r_mag: f64 = std.math.sqrt(r_vec.x * r_vec.x + r_vec.y * r_vec.y + r_vec.z * r_vec.z);

                    const acceleration: f64 = -1.0 * BIG_G * e2.mass / (r_mag * r_mag);

                    const r_unit_vec = Vec3.init(r_vec.x / r_mag, r_vec.y / r_mag, r_vec.z / r_mag);
                    a_g.x += acceleration * r_unit_vec.x;
                    a_g.y += acceleration * r_unit_vec.y;
                    a_g.z += acceleration * r_unit_vec.z;
                }
            }
            e1.vel.x += a_g.x * dt;
            e1.vel.y += a_g.y * dt;
            e1.vel.z += a_g.z * dt;
        }

        // after calculating everyones velocity, then we move so the simulation is gucci

        for (entities) |*e| {
            e.pos.x += e.vel.x;
            e.pos.y += e.vel.y;
            e.pos.z += e.vel.z;

            //            dprint("\n", .{});
            //            e.prt();
            //            dprint("\n", .{});
        }

        //        dprint("\nend of time tick\n\n", .{});
        t += dt;
    }
}

pub fn main() anyerror!void {
    std.debug.print("Hello Orbit!\n", .{});

    const earth = OrbitalEntity.init("Earth", Vec3.init(0, 0, 0), Vec3.init(0, 0, 0), 5.972e24);
    const moon = OrbitalEntity.init("Moon", Vec3.init(0, 384.4e6, 0), Vec3.init(1e3, 0, 0), 7.38e22);
    // const m2 = OrbitalEntity.init("M2", Vec3.init(0, 384.4e6, 0), Vec3.init(0, 0, 0), 7.38e22);
    // const m3 = OrbitalEntity.init("M3", Vec3.init(0, 384.4e6, 0), Vec3.init(0, 0, 0), 7.38e22);

    moon.prt();
    earth.prt();

    var entities = [_]OrbitalEntity{ earth, moon };
    const endTime: i64 = 2628000; // one month in seconds
    integrate(&entities, endTime);

    entities[0].prt();
    entities[1].prt();
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
