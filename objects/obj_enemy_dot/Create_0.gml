enemy_grid_width = 2;
enemy_grid_height = 2;
cell_size = 32;
enemy_hp_grid = ds_grid_create(enemy_grid_width, enemy_grid_height);
ds_grid_clear(enemy_hp_grid, 1);

move_dir = random(360);
move_timer = irandom_range(90, 150);
move_speed = 0.65;
shoot_timer = 100;
attack_shape = [[0, 0]];
if (global.hard_mode) {
    for (var _x = 0; _x < enemy_grid_width; _x++) for (var _y = 0; _y < enemy_grid_height; _y++) ds_grid_set(enemy_hp_grid, _x, _y, 2);
    move_speed = 1.05;
    shoot_timer = 55;
    attack_shape = [[0, 0], [1, 0]];
}
