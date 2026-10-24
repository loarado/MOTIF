enemy_grid_width = 3;
enemy_grid_height = 3;
cell_size = 32;

enemy_hp_grid = ds_grid_create(enemy_grid_width, enemy_grid_height);
ds_grid_clear(enemy_hp_grid, 1);

enemy_grid_width = 3;
enemy_grid_height = 3;
cell_size = 32;

enemy_hp_grid = ds_grid_create(enemy_grid_width, enemy_grid_height);
ds_grid_clear(enemy_hp_grid, 1);

// Circular Movement Pattern Variables
anchor_x = x;
anchor_y = y;
move_angle = 0;
move_radius = 48;
orbit_speed = 2;

// Spiral Attack & Damage Pattern Variables
shoot_timer = 45;
spiral_angle = 0;

// 3-block "L" shape damage pattern
attack_shape = [
    [0, 0],
    [0, 1],
    [1, 1]
];