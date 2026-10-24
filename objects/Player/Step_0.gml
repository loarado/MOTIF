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

if (damage_indicator_timer > 0) damage_indicator_timer--;
if (dungeon_title_timer > 0) dungeon_title_timer--;
if (invincibility_timer > 0) {
    invincibility_timer--;
    image_alpha = ((invincibility_timer div 4) mod 2 == 0) ? 0.35 : 1;
} else {
    image_alpha = 1;
}

if (attack_upgrade_active) {
    // Center the existing pattern in the upgrade screen and place the new tile beside it.
    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();
    var _min_x = my_attack_pattern[0][0];
    var _max_x = my_attack_pattern[0][0];
    var _min_y = my_attack_pattern[0][1];
    var _max_y = my_attack_pattern[0][1];
    for (var i = 1; i < array_length(my_attack_pattern); i++) {
        _min_x = min(_min_x, my_attack_pattern[i][0]);
        _max_x = max(_max_x, my_attack_pattern[i][0]);
        _min_y = min(_min_y, my_attack_pattern[i][1]);
        _max_y = max(_max_y, my_attack_pattern[i][1]);
    }
    var _origin_x = (_gui_width / 2) - (((_min_x + _max_x + 1) * cell_size) / 2);
    var _origin_y = (_gui_height / 2) - (((_min_y + _max_y + 1) * cell_size) / 2);
    var _source_x = _origin_x + ((_max_x + 2) * cell_size);
    var _source_y = _origin_y + (_min_y * cell_size);
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    if (mouse_check_button_pressed(mb_left)
        && point_in_rectangle(_mx, _my, _source_x, _source_y, _source_x + cell_size, _source_y + cell_size)) {
        attack_upgrade_dragging = true;
        attack_upgrade_drag_offset_x = _mx - _source_x;
        attack_upgrade_drag_offset_y = _my - _source_y;
    }

    attack_upgrade_has_target = false;
    if (attack_upgrade_dragging) {
        var _candidate_x = floor((_mx - _origin_x) / cell_size);
        var _candidate_y = floor((_my - _origin_y) / cell_size);
        var _occupied = false;
        var _adjacent = false;

        for (var i = 0; i < array_length(my_attack_pattern); i++) {
            var _shape_x = my_attack_pattern[i][0];
            var _shape_y = my_attack_pattern[i][1];
            if (_candidate_x == _shape_x && _candidate_y == _shape_y) _occupied = true;
            if ((_candidate_x == _shape_x + 1 && _candidate_y == _shape_y)
                || (_candidate_x == _shape_x - 1 && _candidate_y == _shape_y)
                || (_candidate_x == _shape_x && _candidate_y == _shape_y + 1)
                || (_candidate_x == _shape_x && _candidate_y == _shape_y - 1)) {
                _adjacent = true;
            }
        }

        attack_upgrade_has_target = _adjacent && !_occupied;
        if (attack_upgrade_has_target) {
            attack_upgrade_target_x = _candidate_x;
            attack_upgrade_target_y = _candidate_y;
        }

        if (mouse_check_button_released(mb_left)) {
            attack_upgrade_dragging = false;
            if (attack_upgrade_has_target) {
                array_push(my_attack_pattern, [attack_upgrade_target_x, attack_upgrade_target_y]);
                attack_upgrade_active = false;
                attack_upgrade_has_target = false;
                global.combat_active = false;
            }
        }
    }
}
// ==========================================
// 1. REAL-TIME DODGE & MOVEMENT PHASE
// ==========================================
else if (!global.combat_active) {
    var _right = keyboard_check(ord("D"));
    var _left = keyboard_check(ord("A"));
    var _down = keyboard_check(ord("S"));
    var _up = keyboard_check(ord("W"));

    var _hspd = (_right - _left) * move_speed;
    var _vspd = (_down - _up) * move_speed;

    // Horizontal Collision
    if (_hspd != 0 && (place_meeting(x + _hspd, y, obj_wall) || place_meeting(x + _hspd, y, obj_enemy_dot) || place_meeting(x + _hspd, y, obj_enemy_triangle) || place_meeting(x + _hspd, y, obj_enemy_square) || place_meeting(x + _hspd, y, obj_enemy_circle))) {
        while (!place_meeting(x + sign(_hspd), y, obj_wall) && !place_meeting(x + sign(_hspd), y, obj_enemy_dot) && !place_meeting(x + sign(_hspd), y, obj_enemy_triangle) && !place_meeting(x + sign(_hspd), y, obj_enemy_square) && !place_meeting(x + sign(_hspd), y, obj_enemy_circle)) {
            x += sign(_hspd);
        }
        _hspd = 0;
    }
    x += _hspd;

    // Vertical Collision
    if (_vspd != 0 && (place_meeting(x, y + _vspd, obj_wall) || place_meeting(x, y + _vspd, obj_enemy_dot) || place_meeting(x, y + _vspd, obj_enemy_triangle) || place_meeting(x, y + _vspd, obj_enemy_square) || place_meeting(x, y + _vspd, obj_enemy_circle))) {
        while (!place_meeting(x, y + sign(_vspd), obj_wall) && !place_meeting(x, y + sign(_vspd), obj_enemy_dot) && !place_meeting(x, y + sign(_vspd), obj_enemy_triangle) && !place_meeting(x, y + sign(_vspd), obj_enemy_square) && !place_meeting(x, y + sign(_vspd), obj_enemy_circle)) {
            y += sign(_vspd);
        }
        _vspd = 0;
    }
    y += _vspd;

    // Cooldown and mouse-aimed sword attack
    if (attack_cooldown > 0) attack_cooldown--;

    if (attack_cooldown <= 0 && mouse_check_button_pressed(mb_left)) {
        var _player_center_x = x + (sprite_get_width(sprite_index) / 2);
        var _player_center_y = y + (sprite_get_height(sprite_index) / 2);
        var _attack_direction = point_direction(_player_center_x, _player_center_y, mouse_x, mouse_y);
        var _initial_hilt_distance = 50;
        var _sword_x = _player_center_x + lengthdir_x(_initial_hilt_distance, _attack_direction) - 10;
        var _sword_y = _player_center_y + lengthdir_y(_initial_hilt_distance, _attack_direction) - 10;
        var _sword = instance_create_layer(_sword_x, _sword_y, layer, obj_sword);
        _sword.owner_id = id;
        _sword.attack_direction = _attack_direction;
        attack_cooldown = attack_miss_cooldown;
    }
} 
// ==========================================
// 2. PAUSED COMBAT DRAG-AND-DROP PHASE
// ==========================================
else {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _base_x = display_get_gui_width() / 2;
    var _base_y = display_get_gui_height() - 96;
    
    // Pick up the shape
    if (mouse_check_button_pressed(mb_left)) {
        for (var i = 0; i < array_length(my_attack_pattern); i++) {
            var _cell_x = _base_x + (my_attack_pattern[i][0] * cell_size);
            var _cell_y = _base_y + (my_attack_pattern[i][1] * cell_size);
            if (point_in_rectangle(_mx, _my, _cell_x, _cell_y, _cell_x + cell_size, _cell_y + cell_size)) {
                is_dragging = true;
                drag_offset_x = _mx - _base_x;
                drag_offset_y = _my - _base_y;
                break;
            }
        }
    }

    // Rotate the attack shape 90 degrees clockwise while it is being dragged.
    if (is_dragging && keyboard_check_pressed(ord("R"))) {
        var _rotated_pattern = [];
        for (var i = 0; i < array_length(my_attack_pattern); i++) {
            array_push(_rotated_pattern, [-my_attack_pattern[i][1], my_attack_pattern[i][0]]);
        }
        my_attack_pattern = _rotated_pattern;
    }
    
    // Drop the shape onto the enemy grid
    if (mouse_check_button_released(mb_left) && is_dragging) {
        is_dragging = false;
        var _enemy = global.target_enemy;
        if (!instance_exists(_enemy)) {
            var _enemy_types = [obj_enemy_dot, obj_enemy_triangle, obj_enemy_square, obj_enemy_circle];
            var _nearest_distance = 1000000000;
            for (var _enemy_index = 0; _enemy_index < array_length(_enemy_types); _enemy_index++) {
                var _candidate_enemy = instance_nearest(x, y, _enemy_types[_enemy_index]);
                if (instance_exists(_candidate_enemy)) {
                    var _candidate_distance = point_distance(x, y, _candidate_enemy.x, _candidate_enemy.y);
                    if (_candidate_distance < _nearest_distance) {
                        _nearest_distance = _candidate_distance;
                        _enemy = _candidate_enemy;
                    }
                }
            }
        }
        
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

    // Do not time out the combat pause while the attack shape is being dragged.
    if (global.combat_active && !is_dragging) {
        combat_timer--;
        if (combat_timer <= 0) global.combat_active = false;
    }
}
