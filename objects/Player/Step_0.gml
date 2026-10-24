// Check if any healthy cells (1) remain in the player's grid
var _player_alive = false;
for (var _x = 0; _x < grid_width; _x++) {
    for (var _y = 0; _y < grid_height; _y++) {
        if (hp_grid[_x][_y] > 0) {
            _player_alive = true;
            break;
        }
    }
    if (_player_alive) break;
}

// Reset the trial if the player has no health left
if (!_player_alive) {
    global.combat_active = false;
    room_restart(); // You can change this to room_goto(rm_title) later
    exit;
}

// ==========================================
// 1. REAL-TIME DODGE & MOVEMENT PHASE
// ==========================================
if (!global.combat_active) {
    var _right = keyboard_check(ord("D"));
    var _left = keyboard_check(ord("A"));
    var _down = keyboard_check(ord("S"));
    var _up = keyboard_check(ord("W"));

    var _hspd = (_right - _left) * move_speed;
    var _vspd = (_down - _up) * move_speed;

    // Horizontal Collision
    if (place_meeting(x + _hspd, y, obj_wall)) {
        while (!place_meeting(x + sign(_hspd), y, obj_wall)) {
            x += sign(_hspd);
        }
        _hspd = 0;
    }
    x += _hspd;

    // Vertical Collision
    if (place_meeting(x, y + _vspd, obj_wall)) {
        while (!place_meeting(x, y + sign(_vspd), obj_wall)) {
            y += sign(_vspd);
        }
        _vspd = 0;
    }
    y += _vspd;

    // Cooldown and Attack Trigger
    if (attack_cooldown > 0) attack_cooldown--;

    if (attack_cooldown <= 0 && keyboard_check_pressed(vk_space)) {
        var _enemy = instance_nearest(x, y, obj_enemy);
        if (_enemy != noone && distance_to_object(_enemy) < 40) {
            global.combat_active = true;
            global.target_enemy = _enemy;
            attack_cooldown = 180;
            combat_timer = 300;
            is_dragging = false;
        }
    }
} 
// ==========================================
// 2. PAUSED COMBAT DRAG-AND-DROP PHASE
// ==========================================
else {
    combat_timer--;
    if (combat_timer <= 0) {
        global.combat_active = false;
        is_dragging = false;
    }
    
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _base_x = display_get_gui_width() / 2;
    var _base_y = display_get_gui_height() - 96;
    
    // Pick up the shape
    if (mouse_check_button_pressed(mb_left)) {
        if (point_in_rectangle(_mx, _my, _base_x, _base_y, _base_x + (2 * cell_size), _base_y + cell_size)) {
            is_dragging = true;
            drag_offset_x = _mx - _base_x;
            drag_offset_y = _my - _base_y;
        }
    }
    
    // Drop the shape onto the enemy grid
    if (mouse_check_button_released(mb_left) && is_dragging) {
        is_dragging = false;
        var _enemy = global.target_enemy;
        if (!instance_exists(_enemy)) _enemy = instance_nearest(x, y, obj_enemy);
        
        if (_enemy != noone) {
            var _enemy_start_x = display_get_gui_width() - (_enemy.enemy_grid_width * cell_size) - 32;
            var _enemy_start_y = display_get_gui_height() - (_enemy.enemy_grid_height * cell_size) - 32;
            var _valid_hit = false;
            
            for (var i = 0; i < array_length(my_attack_pattern); i++) {
                var _block_cx = (_mx - drag_offset_x) + (my_attack_pattern[i][0] * cell_size) + (cell_size / 2);
                var _block_cy = (_my - drag_offset_y) + (my_attack_pattern[i][1] * cell_size) + (cell_size / 2);
                
                var _gx = floor((_block_cx - _enemy_start_x) / cell_size);
                var _gy = floor((_block_cy - _enemy_start_y) / cell_size);
                
                // Check bounds and subtract 1 health/armor from the enemy cell
                if (_gx >= 0 && _gx < _enemy.enemy_grid_width && _gy >= 0 && _gy < _enemy.enemy_grid_height) {
                    var _cell_hp = ds_grid_get(_enemy.enemy_hp_grid, _gx, _gy);
                    if (_cell_hp > 0) {
                        var _new_hp = (_cell_hp == 1) ? -1 : (_cell_hp - 1);
                        ds_grid_set(_enemy.enemy_hp_grid, _gx, _gy, _new_hp);
                        _valid_hit = true;
                    }
                }
            }
            
            if (_valid_hit) {
                global.combat_active = false;
            }
        }
    }
}