const std = @import("std");
const lightmix = @import("lightmix");
const frog_chorus = @import("frog_chorus");

const allocator = std.heap.page_allocator;
const Wave = lightmix.Wave;
const Melodies = frog_chorus.Melodies;

pub fn main() !void {
    const melody: Wave = try Melodies.melody(allocator, .{
        .amplitude = 0.5,
    });
    defer melody.deinit();

    var file = try std.fs.cwd().createFile("result.wav", .{});
    defer file.close();

    try melody.write(file);
}
