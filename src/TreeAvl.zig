const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const assert = std.debug.assert;
pub fn TreeAvl(comptime T: type, lessThanFn: fn (a: T, b: T) bool, default: T) type {
    return struct {
        const Self = @This();
        const Node = InternalNode(T, default);
        root: ?*Node,
        allocator: Allocator,

        pub fn init(allocator: Allocator) Self {
            return Self{
                .allocator = allocator,
                .root = null,
            };
        }

        pub fn deinit(self: *Self) void {
            // _ = self;
            var deep: i64 = 0;
            delete_node(self, &self.root, &deep);
        }

        fn delete_node(self: *Self, node: *?*Node, deep: *i64) void {
            if (node.* == null) return;
            print("Deep In : {}\n", .{deep.*});

            deep.* += 1;
            delete_node(self, &node.*.?.*.left, deep);
            deep.* -= 1;
            print("Deep Middle : {}\n", .{deep.*});
            deep.* += 1;
            delete_node(self, &node.*.?.*.right, deep);
            deep.* -= 1;
            print("Deep End : {}\n", .{deep.*});

            self.*.allocator.destroy(node.*.?);
            node.* = null;
        }
        /// Insert element into tree
        /// and maintain balance
        /// Return true if the element is add
        /// False if the element is already there and is
        /// updated
        pub fn add(self: *Self, el: *const T) !void {
            _ = try addInternal(self, &(self.root), el);
        }
        fn addInternal(self: *Self, node: *?*Node, el: *const T) !bool {
            if (node.* == null) {
                node.* = (try self.allocator.create(Node)).init();
                // @memset(node.*, 0);
                node.*.?.*.element = el.*;
                return true;
            }
            // print("Node value {?}\n", .{node.*.?.*.element});

            // if (lessThanFn((el.*), node.*.element.?)) {
            const a = node.*;
            // print("type value a : {?}\n", .{@TypeOf(a)});
            // print("Struct value a : {?}\n", .{(a == null)});
            const b = a.?;
            // print("Type OF B is {}\n",.{@TypeOf(b)});
            // print("Value PTR of B is {}\n",.{@intFromPtr(b)});
            // print("Struct value b : {}\n", .{b.element});
            print("Value of B is {}\n",.{b.element});
            // const el2 = b.*;
            // if (lessThanFn(el.*, node.*.?.*.element)) {
            assert(node.* != null);
            if (lessThanFn(el.*, b.element)) {
                const has_height_change = try addInternal(self, &(node.*.?.left), el);
                if (has_height_change) {
                    node.*.?.*.balance += 1;
                }
                if (node.*.?.*.balance == 0) return false;
                if (node.*.?.*.balance == 1) return true;
                assert(node.*.?.*.balance == 2);
                if (node.*.?.*.left.?.*.balance == -1) {
                    assert(node.* != null);
                    rotateRightLeft(&(node.*.?.left));
                }
                rotateLeftRight(node);
                return false;
            } else if (lessThanFn(node.*.?.*.element, el.*)) {
                const has_height_change = try addInternal(self, &node.*.?.right, el);
                if (has_height_change) {
                    node.*.?.*.balance -= 1;
                    if (node.*.?.*.balance == 0) return false;
                    if (node.*.?.*.balance == -1) return true;
                    assert(node.*.?.*.balance == -2);
                    if (node.*.?.*.right.?.balance == 1) {
                        assert(node.* != null);
                        rotateLeftRight(&(node.*.?.*.right));
                    }
                    rotateRightLeft(node);
                }
                return false;
            }

            // el == node.*.?.*.element
            node.*.?.*.element = el.*;
            return false;
        }

        fn rotateLeftRight(leftSubTree: *?*Node) void {
            const temp: *Node = leftSubTree.*.?.left.?;
            const ea = temp.*.balance;
            const eb = leftSubTree.*.?.*.balance;
            const neb = -(if (ea > 0) ea else 0) - 1 + eb;
            const nea = ea + (if (neb < 0) neb else 0) - 1;

            temp.*.balance = nea;
            leftSubTree.*.?.balance = neb;

            leftSubTree.*.?.left = temp.*.right;
            temp.*.right = leftSubTree.*;
            leftSubTree.* = temp;
        }

        fn rotateRightLeft(rightSubTree: *?*Node) void {
            const temp: *Node = rightSubTree.*.?.right.?;
            const ea = temp.*.balance;
            const eb = rightSubTree.*.?.*.balance;
            const neb = -(if (ea > 0) ea else 0) - 1 + eb;
            const nea = ea + (if (neb < 0) neb else 0) - 1;

            temp.*.balance = nea;
            rightSubTree.*.?.balance = neb;

            rightSubTree.*.?.left = temp.*.left;
            temp.*.left = rightSubTree.*;
            rightSubTree.* = temp;
        }
    };
}

fn InternalNode(comptime T: type, default: T) type {
    return struct {
        const Self = @This();
        element: T = default,
        balance: i8 = 0,
        left: ?*Self = null,
        right: ?*Self = null,

        pub fn init(self: *Self) *Self {
            self.element = default;
            self.balance = 0;
            self.left = null;
            self.right = null;

            return self;
        }
    };
}
