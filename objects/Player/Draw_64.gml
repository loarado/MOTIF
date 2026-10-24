// 1. Draw Transparent Combat Overlay
if (global.combat_active) {
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1.0);
    draw_set_color(c_white);
}

// 2. Draw Enemy Grid (Always visible if enemy exists)
var _disp_enemy = instance_exists(global.target_enemy) ? global.target_enemy : instance_nearest(x, y, obj_enemy);

if (_disp_enemy != noone && variable_instance_exists(_disp_enemy, "enemy_hp_grid")) {
    var _start_x = display_get_gui_width() - (_disp_enemy.enemy_grid_width * cell_size) - 32;
    var _start_y = display_get_gui_height() - (_disp_enemy.enemy_grid_height * cell_size) - 32;

    for (var _x = 0; _x < _disp_enemy.enemy_grid_width; _x++) {
        for (var _y = 0; _y < _disp_enemy.enemy_grid_height; _y++) {
            
            // THESE TWO LINES WERE MISSING
            var _draw_x = _start_x + (_x * cell_size);
            var _draw_y = _start_y + (_y * cell_size);
            
            var _e_hp = ds_grid_get(_disp_enemy.enemy_hp_grid, _x, _y);
            if (_e_hp >= 2) draw_set_color(c_purple);      // Armored Enemy Cell
            else if (_e_hp == 1) draw_set_color(c_red);    // Normal Enemy Cell
            else draw_set_color(c_black);                  // Destroyed Cell
            
            // Hover effect
            if (global.combat_active && is_dragging) {
                var _mx = device_mouse_x_to_gui(0);
                var _my = device_mouse_y_to_gui(0);
                
                for (var i = 0; i < array_length(my_attack_pattern); i++) {
                    var _block_cx = (_mx - drag_offset_x) + (my_attack_pattern[i][0] * cell_size) + (cell_size / 2);
                    var _block_cy = (_my - drag_offset_y) + (my_attack_pattern[i][1] * cell_size) + (cell_size / 2);
                    
                    var _hover_x = floor((_block_cx - _start_x) / cell_size);
                    var _hover_y = floor((_block_cy - _start_y) / cell_size);
                    
                    if (_x == _hover_x && _y == _hover_y && _e_hp > 0) {
                        draw_set_color(make_color_rgb(139, 0, 0)); // Dark red hover
                    }
                }
            }
            
            draw_rectangle(_draw_x, _draw_y, _draw_x + cell_size - 1, _draw_y + cell_size - 1, false);
            draw_set_color(c_white);
            draw_rectangle(_draw_x, _draw_y, _draw_x + cell_size - 1, _draw_y + cell_size - 1, true);
            
            // Draw armor number if > 1
            if (_e_hp > 1) draw_text(_draw_x + 10, _draw_y + 6, string(_e_hp));
        }
    }
}

// 3. Draw Player Health Grid
var _player_start_x = 32;
var _player_start_y = display_get_gui_height() - (grid_height * cell_size) - 32;

for (var _x = 0; _x < grid_width; _x++) {
    for (var _y = 0; _y < grid_height; _y++) {
        
        // THESE TWO LINES WERE MISSING
        var _draw_x = _player_start_x + (_x * cell_size);
        var _draw_y = _player_start_y + (_y * cell_size);
        
        var _p_hp = hp_grid[_x][_y];
        if (_p_hp >= 2) draw_set_color(c_aqua);        // Armored Player Cell (2+ hits)
        else if (_p_hp == 1) draw_set_color(c_lime);   // Healthy Player Cell (1 hit)
        else if (_p_hp <= -1) draw_set_color(c_red);   // Damaged Player Cell
        else draw_set_color(c_dkgray);                 // Empty Slot
        
        draw_rectangle(_draw_x, _draw_y, _draw_x + cell_size - 1, _draw_y + cell_size - 1, false);
        draw_set_color(c_white);
        draw_rectangle(_draw_x, _draw_y, _draw_x + cell_size - 1, _draw_y + cell_size - 1, true);
        
        if (_p_hp > 1) {
            draw_set_color(c_black);
            draw_text(_draw_x + 10, _draw_y + 6, string(_p_hp));
            draw_set_color(c_white);
        }
    }
}

// 3.5 Draw Attack Cooldown Indicator above Player Grid
var _bar_width = grid_width * cell_size;
var _bar_height = 14;
var _bar_x = _player_start_x;
var _bar_y = _player_start_y - 26;

// Draw dark background box
draw_set_color(c_dkgray);
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + _bar_height, false);

// Calculate fill percentage (180 is your max cooldown from the Step Event)
var _fill_ratio = clamp(1 - (attack_cooldown / 180), 0, 1);

if (_fill_ratio >= 1) {
    draw_set_color(c_aqua); // Ready to attack
    draw_text(_bar_x, _bar_y - 20, "SPACE: ATTACK READY!");
} else {
    draw_set_color(c_orange); // Recharging
    draw_text(_bar_x, _bar_y - 20, "RECHARGING...");
}

// Draw progress fill and white border
draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_width * _fill_ratio), _bar_y + _bar_height, false);
draw_set_color(c_white);
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + _bar_height, true);

// 4. Draw Timer and Attack Shape
if (global.combat_active) {
    var _seconds_left = ceil(combat_timer / 60);
    draw_set_color(c_yellow);
    draw_text_transformed(display_get_gui_width() / 2 - 80, 32, "TIME: " + string(_seconds_left), 2, 2, 0);
    draw_set_color(c_white);
    
    var _shape_x = display_get_gui_width() / 2;
    var _shape_y = display_get_gui_height() - 96;
    if (is_dragging) {
        _shape_x = device_mouse_x_to_gui(0) - drag_offset_x;
        _shape_y = device_mouse_y_to_gui(0) - drag_offset_y;
    }
    
    for (var i = 0; i < array_length(my_attack_pattern); i++) {
        var _px = _shape_x + (my_attack_pattern[i][0] * cell_size);
        var _py = _shape_y + (my_attack_pattern[i][1] * cell_size);
        
        draw_set_color(c_aqua);
        draw_rectangle(_px, _py, _px + cell_size - 1, _py + cell_size - 1, false);
        draw_set_color(c_white);
        draw_rectangle(_px, _py, _px + cell_size - 1, _py + cell_size - 1, true);
    }
}