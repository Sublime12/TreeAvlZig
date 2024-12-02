//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const tree_avl = @import("TreeAvl.zig");
const TreeAvl = tree_avl.TreeAvl;
const Check = std.heap.Check;
const print = std.debug.print;
const panic = std.debug.panic;

fn cmpFun(a: usize, b: usize) bool {
    return a > b;
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    var gpa1 = std.heap.GeneralPurposeAllocator(.{}){};
    defer  {
        const check = gpa1.deinit();
        if (check == Check.leak) {
            panic("There is a leak", .{});
        } else
            print("No leak detected", .{});
    }
    const gpa = gpa1.allocator();
    // const allocator = std.heap.c_allocator;

    var tree = TreeAvl(usize, cmpFun, 0).init(gpa);
    defer tree.deinit();

    // const two = @as(i32, 2);
    // const three = @as(i32, 3);
    // const four = @as(i32, 4);
    // try tree.add(&two);
    // try tree.add(&three);
    // try tree.add(&four);

    for (0..500000) |i| {
        try tree.add(&i);
    }

    print("Bonjour\n", .{});
    // print(tree.)
    // _ = tree;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const global = struct {
        fn testOne(input: []const u8) anyerror!void {
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(global.testOne, .{});
}
