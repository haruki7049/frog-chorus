const lightmix = @import("lightmix");
const Wave = lightmix.Wave;
const settings = @import("./settings.zig");

pub fn generate_guitar(frequency: f32) !Wave {
    const data: [44100]f32 = generate_guitar_data(frequency);
    const guitar: Wave = try Wave.init(data[0..], allocator, .{
        .sample_rate = settings.sample_rate,
        .channels = settings.channels,
        .bits = settings.bits,
    });

    return guitar;
}

fn generate_guitar_data(frequency: f32) [44100]f32 {
    const sample_rate: f32 = @floatFromInt(settings.sample_rate);
    const decay: f32 = 0.996;

    var result: [44100]f32 = undefined;

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
        const avg = (buffer[idx] + buffer[next_idx]) * 0.5 * decay;
        buffer[idx] = avg;
        result[i] = avg;
        idx = next_idx;
    }

    return result;
}
