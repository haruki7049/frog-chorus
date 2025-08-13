const std = @import("std");
const lightmix = @import("lightmix");
const Wave = lightmix.Wave;

const settings = @import("./settings.zig");

pub fn generate_organ(frequency: f32, allocator: std.mem.Allocator) !Wave {
    const amplitude: f32 = 0.5;

    const data: []const f32 = try generate_organ_data(frequency, amplitude, allocator);
    defer allocator.free(data);

    const organ: Wave = try Wave.init(data[0..], allocator, .{
        .sample_rate = settings.sample_rate,
        .channels = settings.channels,
        .bits = settings.bits,
    });

    return organ;
}

fn generate_organ_data(frequency: f32, amplitude: f32, allocator: std.mem.Allocator) ![]const f32 {
    var result = std.ArrayList(f32).init(allocator);
    const amp = amplitude * 0.25;

    const sine1: []const f32 = generate_sine_data(frequency, amp, settings.samples_per_beat, allocator);
    const sine2: []const f32 = generate_sine_data(frequency * 2.0, amp * 0.6, settings.samples_per_beat, allocator);
    const sine3: []const f32 = generate_sine_data(frequency * 3.0, amp * 0.4, settings.samples_per_beat, allocator);
    const sine4: []const f32 = generate_sine_data(frequency * 4.0, amp * 0.8, settings.samples_per_beat, allocator);
    const sine5: []const f32 = generate_sine_data(frequency * 5.0, amp * 0.6, settings.samples_per_beat, allocator);
    const sine6: []const f32 = generate_sine_data(frequency * 6.0, amp * 0.75, settings.samples_per_beat, allocator);

    defer {
        allocator.free(sine1);
        allocator.free(sine2);
        allocator.free(sine3);
        allocator.free(sine4);
        allocator.free(sine5);
        allocator.free(sine6);
    }

    for (sine1, sine2, sine3, sine4, sine5, sine6) |s1, s2, s3, s4, s5, s6| {
        try result.append(s1 + s2 + s3 + s4 + s5 + s6);
    }

    return try result.toOwnedSlice();
}

fn generate_sine_data(frequency: f32, amplitude: f32, length: usize, allocator: std.mem.Allocator) []const f32 {
    const sample_rate: f32 = @floatFromInt(settings.sample_rate);
    const radins_per_sec: f32 = frequency * 2.0 * std.math.pi;

    var result: []f32 = allocator.alloc(f32, length) catch |err| {
        std.debug.print("{any}\n", .{err});
        @panic("PANIC");
    };
    var i: usize = 0;

    while (i < result.len) : (i += 1) {
        result[i] = std.math.sin(@as(f32, @floatFromInt(i)) * radins_per_sec / sample_rate) * amplitude;
    }

    return result;
}

pub fn generate_guitar(frequency: f32, allocator: std.mem.Allocator) !Wave {
    const data: [settings.samples_per_beat]f32 = generate_guitar_data(frequency);
    const guitar: Wave = try Wave.init(data[0..], allocator, .{
        .sample_rate = settings.sample_rate,
        .channels = settings.channels,
        .bits = settings.bits,
    });

    return guitar;
}

fn generate_guitar_data(frequency: f32) [settings.samples_per_beat]f32 {
    const sample_rate: f32 = @floatFromInt(settings.sample_rate);
    var result: [settings.samples_per_beat]f32 = undefined;

    const period = @as(usize, @intFromFloat(sample_rate / frequency));
    var buffer: [2000]f32 = undefined;
    var prng = std.Random.DefaultPrng.init(0);
    const rand = prng.random();

    for (buffer[0..period]) |*val| {
        val.* = rand.float(f32) * 2.0 - 1.0;
    }

    // Karplus–Strong loop
    var idx: usize = 0;
    var i: usize = 0;
    while (i < result.len) : (i += 1) {
        const next_idx = (idx + 1) % period;
        const avg = (buffer[idx] + buffer[next_idx]) * 0.5;
        buffer[idx] = avg;
        result[i] = avg;
        idx = next_idx;
    }

    return result;
}

pub fn generate_soundless(allocator: std.mem.Allocator) !Wave {
    const generators = Wave.Generators.init(allocator);
    const data: []const f32 = try generators.soundless(settings.samples_per_beat);
    defer generators.free(data);

    const result: Wave = try Wave.init(data, allocator, .{
        .sample_rate = settings.sample_rate,
        .channels = settings.channels,
        .bits = settings.bits,
    });

    return result;
}
