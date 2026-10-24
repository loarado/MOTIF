enemy_grid_width = 3;
enemy_grid_height = 3;
cell_size = 32;
enemy_hp_grid = ds_grid_create(enemy_grid_width, enemy_grid_height);
ds_grid_clear(enemy_hp_grid, 1);

image_blend = c_orange;
is_boss = false;

// Regular square-route movement settings.
square_radius = irandom_range(55, 80);
square_angle = random(360);
var _center_x = clamp(x, 96 + square_radius, room_width - 96 - square_radius);
var _center_y = clamp(y, 96 + square_radius, room_height - 96 - square_radius);
square_vertices = [];
for (var i = 0; i < 4; i++) {
    array_push(square_vertices, [
        _center_x + lengthdir_x(square_radius, square_angle + (i * 90)),
        _center_y + lengthdir_y(square_radius, square_angle + (i * 90))
    ]);
}
move_target_index = 0;
move_speed = 1.8;
rotate_speed = 2;
image_angle = square_angle;

// The Square fires four projectiles and damages a 2x2 area.
shoot_timer = 65;
spiral_angle = 0;
move_angle = 0;
move_radius = 48;
orbit_speed = 2;
anchor_x = x;
anchor_y = y;
attack_shape = [[0, 0], [1, 0], [0, 1], [1, 1]];
