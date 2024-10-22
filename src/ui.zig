const std = @import("std");
const rl = @import("raylib");
const orbit = @import("orbit.zig");

pub fn orbitalStatsWriter(
    entities: []orbit.OrbitalEntity,
    tick_time: i32,
    total_time: i32,
    x: i32,
    y: i32,
    font_size: i32,
) void {
    var tc = TextColum.init(font_size, 5, x, y);

    const kenetic_energy = orbit.calculate_kenetic_energy(entities);
    const gravitiationl_energy = orbit.calculate_potential_energy(entities);

    tc.drawTextFormat("Time / frame   : %s", .{reableTime(tick_time)});
    tc.drawTextFormat("Simulation time: %s", .{reableTime(total_time)});
    tc.drawTextFormat("Kinetic  energy: %.1e", .{kenetic_energy});
    tc.drawTextFormat("Grav.    energy: %.1e", .{gravitiationl_energy});
    tc.drawTextFormat("Total    energy: %.1e", .{kenetic_energy + gravitiationl_energy});
}

const TextColum = struct {
    top_left_pos_x: i32,
    font_size: i32,
    gap: i32,
    current_vertical_offset: i32,

    pub fn init(font_size: i32, gap: i32, x: i32, y: i32) TextColum {
        return TextColum{
            .font_size = font_size,
            .gap = gap,
            .current_vertical_offset = y,
            .top_left_pos_x = x,
        };
    }

    pub fn drawTextFormat(self: *TextColum, text: [*:0]const u8, args: anytype) void {
        rl.drawText(
            rl.textFormat(text, args),
            self.top_left_pos_x,
            self.current_vertical_offset,
            self.font_size,
            rl.Color.white,
        );
        self.current_vertical_offset += self.gap + self.font_size;
    }
};

pub const Options = struct {
    show_orbital_stats: bool,
    show_fps: bool,
    show_sim: bool,

    pub fn init() Options {
        return Options{
            .show_fps = true,
            .show_orbital_stats = false,
            .show_sim = true,
        };
    }
};

fn reableTime(seconds: i32) [*:0]const u8 {
    if (seconds < 60) {
        return rl.textFormat("%d seconds", .{seconds});
    } else if (seconds < 60 * 60) {
        return rl.textFormat("%d minutes", .{@divTrunc(seconds, 60)});
    } else if (seconds < 60 * 60 * 24) {
        return rl.textFormat("%d hours", .{@divTrunc(seconds, 60 * 60)});
    } else if (seconds < 60 * 60 * 24 * 365) {
        return rl.textFormat("%d days", .{@divTrunc(seconds, 60 * 60 * 24)});
    } else {
        return rl.textFormat("%.1f years", .{@as(f32, @floatFromInt(seconds)) / (60 * 60 * 24 * 365)});
    }
}
