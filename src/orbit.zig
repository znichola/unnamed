const std = @import("std");
const rl = @import("raylib");
const dprint = @import("utils.zig").dprint;

pub const OrbitalEntity = struct {
    pos: rl.Vector3,
    vel: rl.Vector3,
    mass: f32,
    // id: u16,
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
    const dt: i32 = 60; // 86400; // one day in seconds
    const BIG_G: f32 = 6.67E-11;

    while (t < t_end) {
        for (entities) |*e1| {
            // accumulated gravitational acceleration;
            var a_g = rl.Vector3.zero();

            for (entities) |*e2| {
                if (e1.name.ptr != e2.name.ptr) {
                    // distance between points
                    const r_vec = rl.Vector3.init(
                        e1.pos.x - e2.pos.x,
                        e1.pos.y - e2.pos.y,
                        e1.pos.z - e2.pos.z,
                    );
                    //const r_vec = e1.pos.subtract(e2.pos);
                    const r_mag: f32 = std.math.sqrt(r_vec.x * r_vec.x + r_vec.y * r_vec.y + r_vec.z * r_vec.z);
                    //const r_mag = r_vec.length();
                    const acceleration: f32 = -1.0 * BIG_G * e2.mass / (r_mag * r_mag);

                    const r_unit_vec = rl.Vector3.init(
                        r_vec.x / r_mag,
                        r_vec.y / r_mag,
                        r_vec.z / r_mag,
                    );
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
            e.pos.x += e.vel.x * dt;
            e.pos.y += e.vel.y * dt;
            e.pos.z += e.vel.z * dt;
        }

        t += dt;
    }
}

fn prtVector3(vec: rl.Vector3) void {
    std.debug.print("({}, {}, {})\n", vec);
}
