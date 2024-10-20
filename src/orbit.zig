const std = @import("std");
const rl = @import("raylib");
const dprint = @import("utils.zig").dprint;

pub const OrbitalEntity = struct {
    pos: rl.Vector3,
    vel: rl.Vector3,
    mass: f32,
    name: []const u8,

    pub fn init(name: []const u8, pos: rl.Vector3, vel: rl.Vector3, mass: f32) OrbitalEntity {
        return OrbitalEntity{
            .pos = pos,
            .vel = vel,
            .mass = mass,
            .name = name,
        };
    }

    pub fn prt(self: OrbitalEntity) void {
        std.debug.print("\n{s}:\n", .{self.name});
        std.debug.print("position:", .{});
        prtVector3(self.pos);
        std.debug.print("velocity:", .{});
        prtVector3(self.vel);
        std.debug.print("mass: {}\n", .{self.mass});
    }
};

pub fn integrate(entities: []OrbitalEntity, t_end: i32) void {

    // time unit is minutes and steps are descrete
    var t: i32 = 0;
    const dt: i32 = 1; // 86400; // one day in seconds
    const BIG_G: f32 = 6.67E-11;

    while (t < t_end) {
        for (entities) |*e1| {
            // accumulated gravitational acceleration;
            var a_g = rl.Vector3.zero();

            for (entities) |*e2| {
                if (e1.name[0] != e2.name[0]) {
                    // distance between points
                    const r_vec = rl.Vector3.init(e1.pos.x - e2.pos.x, e1.pos.y - e2.pos.y, e1.pos.z - e2.pos.z);
                    const r_mag: f32 = std.math.sqrt(r_vec.x * r_vec.x + r_vec.y * r_vec.y + r_vec.z * r_vec.z);

                    const acceleration: f32 = -1.0 * BIG_G * e2.mass / (r_mag * r_mag);

                    const r_unit_vec = rl.Vector3.init(r_vec.x / r_mag, r_vec.y / r_mag, r_vec.z / r_mag);
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
        }

        //        dprint("\nend of time tick\n\n", .{});
        t += dt;
    }
}

pub fn Orbitalmain() anyerror!void {
    std.debug.print("Hello Orbit!\n", .{});

    const earth = OrbitalEntity.init("Earth", rl.Vector3.init(0, 0, 0), rl.Vector3.init(0, 0, 0), 5.972e24);
    const moon = OrbitalEntity.init("Moon", rl.Vector3.init(0, 384.4e6, 0), rl.Vector3.init(1e3, 0, 0), 7.38e22);

    moon.prt();

    earth.prt();

    var entities = [_]OrbitalEntity{ earth, moon };
    const endTime: i64 = 2628000; // one month in seconds
    integrate(&entities, endTime);

    entities[0].prt();
    entities[1].prt();
}

fn prtVector3(vec: rl.Vector3) void {
    std.debug.print("({}, {}, {})\n", vec);
}
