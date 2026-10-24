// A large 5-row right triangle: 1 + 2 + 3 + 4 + 5 health cells.
enemy_grid_width = 5;
enemy_grid_height = 5;
cell_size = 32;
enemy_hp_grid = ds_grid_create(enemy_grid_width, enemy_grid_height);
ds_grid_clear(enemy_hp_grid, 0);
for (var _y = 0; _y < 5; _y++) {
    for (var _x = 4 - _y; _x < 5; _x++) {
        ds_grid_set(enemy_hp_grid, _x, _y, 1);
    }
}
if (global.hard_mode) {
    for (var _x = 0; _x < enemy_grid_width; _x++) for (var _y = 0; _y < enemy_grid_height; _y++) {
        if (ds_grid_get(enemy_hp_grid, _x, _y) > 0) ds_grid_set(enemy_hp_grid, _x, _y, 2);
    }
}

image_blend = c_yellow;
image_angle = 0;
image_xscale = 1.5;
image_yscale = 1.5;
x = room_width / 2;
y = room_height / 2;

boss_phase = "idle";
boss_timer = global.hard_mode ? 95 : 135;
boss_warning_timer = global.hard_mode ? 65 : 80;
boss_warning_max = global.hard_mode ? 65 : 80;
boss_side = 0;
boss_barrage_waves = 0;
boss_wave_timer = 0;
attack_shape = [[0, 0], [0, 1], [1, 1]];
if (global.hard_mode) attack_shape = [[0, 0], [0, 1], [1, 1], [2, 1], [2, 2]];
