const std = @import("std");

pub fn build (b: *std.Build)void{
    
    //CPU Architecture Of GBA: ARM7TDMI = thumb, freestanding
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = .{.explicit = &std.Target.arm.cpu.arm7tdmi},
    });

    //Optimize We Set ReleaseSmall On Default
    const optimize = b.standardOptimizeOption(.{.preferred_optimize_mode =.ReleaseSmall });
    
    //Elf
    const elf = b.addExecutable(.{
        .name = "game",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),

    });

    //Reset Handler Assembly
    elf.addAssemblyFile(b.path("src/gba/crt0.s"));

    //Linker 
    elf.setLinkerScript(b.path("linker.ld"));
    elf.entry = .{ .symbol_name = "_start" };

    //Convert ELF to Raw Binary
    const objcopy = b.addObjCopy(elf.getEmittedBin(),.{
        .format = .bin,
        .basename = "game.gba",
    }); 

    const install = b.addInstallBinFile(objcopy.getOutput(),"game.gba");
    
    b.default_step.dependOn(&install.step);

    //Gba Fix Step
    const gba_output = b.getInstallPath(.bin,"game.gba");
    const gbafix = b.addSystemCommand(&.{"gbafix",gba_output});
    gbafix.step.dependOn(&install.step);

    const fix_step = b.step("fix","Build and patch ROM Header with gbafix");
    fix_step.dependOn(&gbafix.step);

    //Run In mGBA
    const mgba = b.addSystemCommand(&.{"mgba-qt",gba_output});
    mgba.step.dependOn(&gbafix.step);

    const run_step = b.step("run","Build,fix header, and launch");
    run_step.dependOn(&mgba.step);
}
