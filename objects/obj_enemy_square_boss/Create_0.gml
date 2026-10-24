enemy_grid_width = 5;
enemy_grid_height = 5;
cell_size = 32;
enemy_hp_grid = ds_grid_create(enemy_grid_width, enemy_grid_height);
ds_grid_clear(enemy_hp_grid, 1);
if (global.hard_mode) ds_grid_set_region(enemy_hp_grid, 0, 0, enemy_grid_width - 1, enemy_grid_height - 1, 2);
image_blend = c_aqua;
image_xscale = 1.5;
image_yscale = 1.5;
x = room_width / 2;
y = room_height / 2;
boss_phase = "idle";
boss_timer = global.hard_mode ? 105 : 150;
boss_warning_timer = global.hard_mode ? 75 : 100;
boss_warning_max = global.hard_mode ? 75 : 100;
boss_corner = irandom(3); // TL, TR, BL, BR
shoot_timer = global.hard_mode ? 38 : 55;
attack_shape = global.hard_mode
    ? [[0,0],[1,0],[2,0],[0,1],[1,1],[2,1],[0,2],[1,2],[2,2]]
    : [[0,0],[1,0],[0,1],[1,1]];
