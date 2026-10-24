// Right-triangle health grid: 3 along the bottom, then 2, then the top-right tile.
enemy_grid_width = 3;
enemy_grid_height = 3;
cell_size = 32;
enemy_hp_grid = ds_grid_create(enemy_grid_width, enemy_grid_height);
ds_grid_clear(enemy_hp_grid, 0);
ds_grid_set(enemy_hp_grid, 2, 0, 1);
ds_grid_set(enemy_hp_grid, 1, 1, 1);
ds_grid_set(enemy_hp_grid, 2, 1, 1);
ds_grid_set(enemy_hp_grid, 0, 2, 1);
ds_grid_set(enemy_hp_grid, 1, 2, 1);
ds_grid_set(enemy_hp_grid, 2, 2, 1);

image_blend = c_yellow;
move_vertices = [
    [irandom_range(96, room_width - 96), irandom_range(96, room_height - 96)],
    [irandom_range(96, room_width - 96), irandom_range(96, room_height - 96)],
    [irandom_range(96, room_width - 96), irandom_range(96, room_height - 96)]
];
move_target_index = 0;
move_speed = 1.5;
rotate_speed = 0.35;
shoot_timer = 100;
spiral_angle = 0;

// L-shaped damage pattern.
attack_shape = [[0, 0], [0, 1], [1, 1]];
if (global.hard_mode) {
    for (var _x = 0; _x < enemy_grid_width; _x++) for (var _y = 0; _y < enemy_grid_height; _y++) {
        if (ds_grid_get(enemy_hp_grid, _x, _y) > 0) ds_grid_set(enemy_hp_grid, _x, _y, 2);
    }
    move_speed = 2.25;
    rotate_speed = 0.6;
    shoot_timer = 60;
    attack_shape = [[0, 0], [0, 1], [1, 1], [2, 1]];
}
