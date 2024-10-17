const std = @import("std");
const rl = @import("raylib");
const OrbitalEntity = @import("orbit.zig").OrbitalEntity;
const Vec3 = @import("orbit.zig").Vec3;
const integrate = @import("orbit.zig").integrate;

const dprint = @import("utils.zig").dprint;

pub fn main() anyerror!void {
    // Program Initialization
    //--------------------------------------------------------------------------------------
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const parsed_args = try parseArgs(allocator);
    std.debug.print("parsed args: {}\n", parsed_args);

    // if (try foo()) {
    //     return;
    // }

    // Raylib Initialization
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
        const fac = rl.math.remap(to(f32, index), 0, to(f32, entities[2..].len), 0.5, 1.2);
        const r = mpos.rlVec().scale(fac).rotateByAxisAngle(rl.Vector3.init(1.0, 0, 0), fac);
        ent.* = OrbitalEntity.init("s", Vec3.init(r.x, r.y, r.z), mvec, 1e9);
    }

    const secondsToRun: i32 = 1 * 60 * 60;
    //  endTime: i64 = 2628000; // one month in seconds

    var chem_trails: [num_sat + 2]Trail = undefined;
    for (&chem_trails) |*t| {
        t.* = Trail.init();
        t.post_init();
    }

    var moon_trail = Trail.init();
    moon_trail.post_init();

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        camera.update(rl.CameraMode.camera_third_person);

        integrate(&entities, secondsToRun);

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        // text ----------------
        rl.clearBackground(rl.Color.black);

        rl.drawText("Congrats! You created your first window!", 190, 200, 20, rl.Color.light_gray);
        rl.drawText(rl.textFormat("Earth: %2.05f %2.05f %2.05f", .{ entities[0].pos.x, entities[0].pos.y, entities[0].pos.z }), 190, 240, 20, rl.Color.red);
        rl.drawFPS(10, 10);
        rl.drawLine3D(rl.Vector3.init(2.0, 0, 0), rl.Vector3.init(4.0, 0, 0), rl.Color.red);

        // 3D obects -----------
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

                    chem_trails[index].append(ent.pos.rlVec());
                    var old_e: rl.Vector3 = chem_trails[index].list.items[0];
                    for (chem_trails[index].list.items) |e| {
                        rl.drawLine3D(map(old_e), map(e), rl.Color.gray);
                        old_e = e;
                    }
                } else {
                    const hue = to(f32, index + 1) / to(f32, entities.len) * 360;
                    color = rl.Color.fromHSV(hue, 0.5, 0.7);
                    radius = 0.3;

                    chem_trails[index].append(ent.pos.rlVec());
                    var old_e: rl.Vector3 = chem_trails[index].list.items[0];
                    for (chem_trails[index].list.items) |e| {
                        rl.drawLine3D(map(old_e), map(e), color.brightness(rl.math.remap(to(f32, index), 0, 1000, -0.5, 1)));
                        old_e = e;
                    }
                }
                rl.drawSphere(map(ent.pos.rlVec()), radius, color);
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

const Args = struct {
    num_satellites: i32,
};

fn parseArgs(allocator: std.mem.Allocator) !Args {
    // pars args into string array, uses allocator for windows compatibility
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    return Args{ .num_satellites = std.fmt.parseInt(i32, args[1], 10) catch 20 };
}

fn foo() !bool {
    std.debug.print("testing foo\n", .{});

    var buff: [10_000]u8 = undefined;
    var fixedBuffAllocator = std.heap.FixedBufferAllocator.init(&buff);
    var trails = std.ArrayList(rl.Vector3).init(fixedBuffAllocator.allocator());
    defer trails.deinit();
    try trails.append(rl.Vector3.one());
    try trails.append(rl.Vector3.zero());
    try trails.append(rl.Vector3.zero());
    try trails.append(rl.Vector3.one());
    try trails.append(rl.Vector3.zero());
    _ = trails.pop();

    for (trails.items) |trail| {
        std.debug.print("TEST: {}\n", .{trail});
    }

    var puet = Trail.init();
    puet.post_init();
    defer puet.list.deinit();

    puet.append(rl.Vector3.one());
    puet.append(rl.Vector3.one());
    puet.append(rl.Vector3.zero());
    puet.append(rl.Vector3.one());
    puet.append(rl.Vector3.zero());
    puet.append(rl.Vector3.zero());

    for (puet.list.items) |p| {
        std.debug.print("PUET: {}\n", .{p});
    }
    return true;
}

const Trail = struct {
    buff: [10_000]u8,
    fba: std.heap.FixedBufferAllocator,
    list: std.ArrayList(rl.Vector3),

    pub fn init() Trail {
        return Trail{ .buff = undefined, .list = undefined, .fba = undefined };
    }

    pub fn post_init(self: *Trail) void {
        self.fba = std.heap.FixedBufferAllocator.init(&self.buff);
        self.list = std.ArrayList(rl.Vector3).init(self.fba.allocator());
    }

    pub fn append(self: *Trail, item: rl.Vector3) void {
        self.list.append(item) catch {
            _ = self.list.orderedRemove(0);
            self.list.append(item) catch |err| {
                std.debug.print("no memory, nothing added :( {}\n", .{err});
            };
        };
    }
};

// fn drawLine(ent: OrbitalEntity) void {
//     rl.drawLine3D(startPos: Vector3, endPos: Vector3, color: Color)
// }
