const std = @import("std");

fn Vec(
    comptime count: comptime_int,
    comptime T: type,
) type {
    return struct {
        data: [count]T,
        const Self = @This();

        fn abs(self: Self) Self {
            var tmp = Self{ .data = undefined };
            for (self.data, 0..) |elem, i| {
                tmp.data[i] = if (elem < 0)
                    -elem
                else
                    elem;
            }
            return tmp;
        }

        fn init(data: [count]T) Self {
            return Self{ .data = data };
        }
    };
}

// single object history with this buffer
// later will vectorise it, so it's all objects history
pub fn RingBuffer(
    // comptime n_objects: comptime_int,
    comptime capacity: comptime_int,
    comptime T: type,
) type {
    return struct {
        buffer: [capacity]T,
        capacity: usize,
        i: usize,
        len: usize,

        const Self = @This();

        pub fn init() Self {
            return Self{
                .buffer = undefined,
                .capacity = capacity,
                .i = 0, // location of the next free spot
                .len = 0,
            };
        }

        pub fn add(self: *Self, object: T) void {
            if (self.len == self.capacity) {
                // we are overwriting old data
            }

            // put it into the next available space
            self.buffer[self.i] = object;

            // incrament the head to the next free spot
            _ = self.incrament_wrap();

            // incrament len if their is room for it
            if (self.len < self.capacity) self.len += 1;

            // The full data can be found by going from i backwards by len
            // if len == capacity, the full buffer is used, otherwise it's
            // len steps backwards (while looping) from i, the rest is
            // garbage data

            // std.debug.print(
            // "add finished: {s}\nbuff len {}, self i {}, self len {}, self capacity {}\n",
            // .{ self.buffer, self.buffer.len, self.i, self.len, self.capacity },
            // );
        }

        fn incrament_wrap(self: *Self) usize {
            self.i += 1;
            if (self.i >= self.capacity) {
                self.i = self.i - self.capacity;
            }
            return self.i;
        }

        const Op = fn (a: T) T;

        pub fn forEach(self: *Self, op: *const fn (a: T) T) void {
            // there is no wraparoud
            if (self.i >= self.len) {
                for (self.buffer[self.i - self.len .. self.i]) |*v| {
                    v.* = op(v.*);
                }
            }
            // there is wraparound
            else {
                const leftover = self.len - self.i;
                // in positive section
                for (self.buffer[0..self.i]) |*v| {
                    v.* = op(v.*);
                }
                // in negative section
                for (self.buffer[self.capacity - leftover ..]) |*v| {
                    v.* = op(v.*);
                }
            }
        }

        pub fn forEachContext(
            self: *Self,
            comptime Context: type,
            context: Context,
            op: *const fn (c: Context, a: T) T,
        ) void {
            // there is no wraparoud
            if (self.i >= self.len) {
                for (self.buffer[self.i - self.len .. self.i]) |*v| {
                    v.* = op(context, v.*);
                }
            }
            // there is wraparound
            else {
                const leftover = self.len - self.i;
                // in positive section
                for (self.buffer[0..self.i]) |*v| {
                    v.* = op(context, v.*);
                }
                // in negative section
                for (self.buffer[self.capacity - leftover ..]) |*v| {
                    v.* = op(context, v.*);
                }
            }
        }
    };
}

pub fn main() anyerror!void {
    // var b = RingBuffer(4, 10, f32).init();

    // for (&b.buffer, 6..) |*v, i| {
    //     v.* = @as(f32, @floatFromInt(i)) / 2;
    // }

    // std.debug.print("testing: {any}\n{} {}\n", .{ b.buffer, b.n_objects, b.n_steps });

    var b = RingBuffer(5, u8).init();

    std.debug.print("ptr: {*}\n", .{&b.buffer});

    // what the heck is going on here?
    // is the hello being copied to the buffer, is the pointer jut swapped
    // b.buffer = "hello".*;
    // for (b.buffer[0..], "hello") |*c, w| {
    //     c.* = w;
    // }""

    // does this overwrite the original hello, wherever is it in memory?
    // b.buffer[2] = '#';

    for (b.buffer[0..]) |*i| {
        i.* = '#';
    }

    std.debug.print("ptr: {*}\n", .{&b.buffer});

    b.add('1');
    b.add('1');
    b.add('1');
    b.add('1');
    b.add('1');
    b.add('1');

    b.forEach(foo);

    std.debug.print("as {s}\n", .{b.buffer});

    // for (0..12) |i| {
    //     b.add('0' + @as(u8, @intCast(i)));
    //     std.debug.print("i:{} val: {s}\n", .{ i, b.buffer });
    // }

    std.debug.print("object: {}", .{b});
}

fn foo(a: u8) u8 {
    _ = a;
    return '$';
}

fn bar(a: u8) u8 {
    _ = a;
    return '@';
}
