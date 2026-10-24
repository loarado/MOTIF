// 4x4 core plus two health tiles on each cardinal side (a 6x6 circle-like grid).
enemy_grid_width = 6;
enemy_grid_height = 6;
cell_size = 32;
enemy_hp_grid = ds_grid_create(enemy_grid_width, enemy_grid_height);
ds_grid_clear(enemy_hp_grid, 0);
for (var _x = 1; _x <= 4; _x++) {
    for (var _y = 1; _y <= 4; _y++) {
        ds_grid_set(enemy_hp_grid, _x, _y, 1);
    }
}
ds_grid_set(enemy_hp_grid, 2, 0, 1);
ds_grid_set(enemy_hp_grid, 3, 0, 1);
ds_grid_set(enemy_hp_grid, 2, 5, 1);
ds_grid_set(enemy_hp_grid, 3, 5, 1);
ds_grid_set(enemy_hp_grid, 0, 2, 1);
ds_grid_set(enemy_hp_grid, 0, 3, 1);
ds_grid_set(enemy_hp_grid, 5, 2, 1);
ds_grid_set(enemy_hp_grid, 5, 3, 1);
if (global.hard_mode) {
    for (var _x = 0; _x < enemy_grid_width; _x++) for (var _y = 0; _y < enemy_grid_height; _y++) {
        if (ds_grid_get(enemy_hp_grid, _x, _y) > 0) ds_grid_set(enemy_hp_grid, _x, _y, 2);
    }
}

image_blend = c_fuchsia;
image_xscale = 1.5;
image_yscale = 1.5;
x = room_width / 2 - sprite_get_width(sprite_index) * image_xscale / 2;
y = room_height / 2 - sprite_get_height(sprite_index) * image_yscale / 2;
movement_mode = "orbit";
anchor_x = x;
anchor_y = y;
move_angle = 0;
move_radius = 80;
orbit_speed = global.hard_mode ? 2.0 : 1.4;
phase_timer = global.hard_mode ? irandom_range(135, 180) : irandom_range(180, 240);
move_speed = global.hard_mode ? 2.8 : 2;
target_x = x;
target_y = y;

// The circle fires two rotating fans of projectiles and deals a five-cell diamond.
shoot_timer = global.hard_mode ? 24 : 35;
spiral_angle = 0;
spiral_frames = 0;
spiral_cooldown = global.hard_mode ? 145 : 210;
attack_shape = global.hard_mode
    ? [[0,0],[1,0],[2,0],[0,1],[1,1],[2,1],[0,2],[1,2],[2,2]]
    : [[1, 0], [0, 1], [1, 1], [2, 1], [1, 2]];
