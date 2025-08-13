const std = @import("std");

const lightmix = @import("lightmix");
const Wave = lightmix.Wave;
const Composer = lightmix.Composer;

const settings = @import("./settings.zig");
const synths = @import("./synths.zig");
const generate_guitar = synths.generate_guitar;
const generate_soundless = synths.generate_soundless;

const frequencies = struct {
    const c_4: f32 = 261.626;
    const d_4: f32 = 293.665;
    const e_4: f32 = 329.628;
    const f_4: f32 = 349.228;
    const g_4: f32 = 391.995;
    const a_4: f32 = 440.000;
};

pub fn melody(allocator: std.mem.Allocator) !Wave {
    const composer = try Composer.init(allocator, .{
        .sample_rate = settings.sample_rate,
        .channels = settings.channels,
        .bits = settings.bits,
    });
    defer composer.deinit();

    const first_m: Wave = try first_melody(allocator);
    defer first_m.deinit();

    const second_m: Wave = try second_melody(allocator);
    defer second_m.deinit();

    const third_m: Wave = try third_melody(allocator);
    defer third_m.deinit();

    const fourth_m: Wave = try fourth_melody(allocator);
    defer fourth_m.deinit();

    const appended_composer = try composer.appendSlice(&[_]Wave{
        first_m,
        second_m,
        third_m,
        fourth_m,
    });
    defer appended_composer.deinit();

    const result: Wave = try appended_composer.finalize();

    return result;
}

fn first_melody(allocator: std.mem.Allocator) !Wave {
    const composer = try Composer.init(allocator, .{
        .sample_rate = settings.sample_rate,
        .channels = settings.channels,
        .bits = settings.bits,
    });
    defer composer.deinit();

    const c_4: Wave = try generate_guitar(frequencies.c_4, allocator);
    defer c_4.deinit();

    const d_4: Wave = try generate_guitar(frequencies.d_4, allocator);
    defer d_4.deinit();

    const e_4: Wave = try generate_guitar(frequencies.e_4, allocator);
    defer e_4.deinit();

    const f_4: Wave = try generate_guitar(frequencies.f_4, allocator);
    defer f_4.deinit();

    const soundless: Wave = try generate_soundless(allocator);
    defer soundless.deinit();

    const appended_composer = try composer.appendSlice(&[_]Wave{
        c_4,
        d_4,
        e_4,
        f_4,
        e_4,
        d_4,
        c_4,
        soundless,
    });
    defer appended_composer.deinit();

    const result: Wave = try appended_composer.finalize();

    return result;
}

fn second_melody(allocator: std.mem.Allocator) !Wave {
    const composer = try Composer.init(allocator, .{
        .sample_rate = settings.sample_rate,
        .channels = settings.channels,
        .bits = settings.bits,
    });
    defer composer.deinit();

    const e_4: Wave = try generate_guitar(frequencies.e_4, allocator);
    defer e_4.deinit();

    const f_4: Wave = try generate_guitar(frequencies.f_4, allocator);
    defer f_4.deinit();

    const g_4: Wave = try generate_guitar(frequencies.g_4, allocator);
    defer g_4.deinit();

    const a_4: Wave = try generate_guitar(frequencies.a_4, allocator);
    defer a_4.deinit();

    const soundless: Wave = try generate_soundless(allocator);
    defer soundless.deinit();

    const appended_composer = try composer.appendSlice(&[_]Wave{
        e_4,
        f_4,
        g_4,
        a_4,
        g_4,
        f_4,
        e_4,
        soundless,
    });
    defer appended_composer.deinit();

    const result: Wave = try appended_composer.finalize();

    return result;
}

fn third_melody(allocator: std.mem.Allocator) !Wave {
    const composer = try Composer.init(allocator, .{
        .sample_rate = settings.sample_rate,
        .channels = settings.channels,
        .bits = settings.bits,
    });
    defer composer.deinit();

    const c_4: Wave = try generate_guitar(frequencies.c_4, allocator);
    defer c_4.deinit();

    const soundless: Wave = try generate_soundless(allocator);
    defer soundless.deinit();

    const appended_composer = try composer.appendSlice(&[_]Wave{
        c_4,
        soundless,
        c_4,
        soundless,
        c_4,
        soundless,
        c_4,
        soundless,
    });
    defer appended_composer.deinit();

    const result: Wave = try appended_composer.finalize();

    return result;
}

fn fourth_melody(allocator: std.mem.Allocator) !Wave {
    const composer = try Composer.init(allocator, .{
        .sample_rate = settings.sample_rate,
        .channels = settings.channels,
        .bits = settings.bits,
    });
    defer composer.deinit();

    const c_4: Wave = try generate_guitar(frequencies.c_4, allocator);
    defer c_4.deinit();

    const c_4_half: Wave = c_4.filter(to_half_length);
    defer c_4_half.deinit();

    const d_4: Wave = try generate_guitar(frequencies.d_4, allocator);
    defer d_4.deinit();

    const d_4_half: Wave = d_4.filter(to_half_length);
    defer d_4_half.deinit();

    const e_4: Wave = try generate_guitar(frequencies.e_4, allocator);
    defer e_4.deinit();

    const e_4_half: Wave = e_4.filter(to_half_length);
    defer e_4_half.deinit();

    const f_4: Wave = try generate_guitar(frequencies.f_4, allocator);
    defer f_4.deinit();

    const f_4_half: Wave = f_4.filter(to_half_length);
    defer f_4_half.deinit();

    const soundless: Wave = try generate_soundless(allocator);
    defer soundless.deinit();

    const appended_composer = try composer.appendSlice(&[_]Wave{
        c_4_half,
        c_4_half,
        d_4_half,
        d_4_half,
        e_4_half,
        e_4_half,
        f_4_half,
        f_4_half,

        e_4,
        d_4,
        c_4,
        soundless,
    });
    defer appended_composer.deinit();

    const result: Wave = try appended_composer.finalize();

    return result;
}

fn to_half_length(original_wave: Wave) !Wave {
    var result = std.ArrayList(f32).init(original_wave.allocator);

    for (original_wave.data, 0..) |data, i| {
        try result.append(data);

        if (i == original_wave.data.len / 2)
            break;
    }

    return Wave{
        .data = try result.toOwnedSlice(),
        .allocator = original_wave.allocator,

        .sample_rate = settings.sample_rate,
        .channels = settings.channels,
        .bits = settings.bits,
    };
}
