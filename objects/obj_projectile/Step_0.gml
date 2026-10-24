// Debug god mode clears projectiles before they can hit the player.
if (variable_global_exists("dev_god_mode") && global.dev_god_mode) { instance_destroy(); exit; }

// Pause projectile movement while the player is dragging an attack
if (global.combat_active) exit;

// Move projectile
x += lengthdir_x(move_spd, move_dir);
y += lengthdir_y(move_spd, move_dir);

// Destroy if it hits a wall or leaves the room
if (place_meeting(x, y, obj_wall) || x < 0 || x > room_width || y < 0 || y > room_height) {
    instance_destroy();
    exit;
}

// A shield blocks projectiles in a wide, short zone directly in front of its owner.
var _blocked_by_shield = false;
for (var _si = 0; _si < instance_number(obj_shield); _si++) {
    var _shield = instance_find(obj_shield, _si);
    if (instance_exists(_shield)) {
        var _dx = x - _shield.x; var _dy = y - _shield.y;
        var _forward = _dx * lengthdir_x(1, _shield.attack_direction) + _dy * lengthdir_y(1, _shield.attack_direction);
        var _side = _dx * lengthdir_x(1, _shield.attack_direction + 90) + _dy * lengthdir_y(1, _shield.attack_direction + 90);
        if (abs(_forward) <= (_shield.shield_depth / 2) + 8 && abs(_side) <= (_shield.shield_width / 2) + 8) {
            _blocked_by_shield = true;
            if (_shield.block_sound_cooldown <= 0) {
                audio_play_sound(Sound_for_shield_blocking_something, 1, false);
                _shield.block_sound_cooldown = 8;
            }
            break;
        }
    }
}
if (_blocked_by_shield) { instance_destroy(); exit; }

// Check collision with Player
if (place_meeting(x, y, Player)) {
    var _p = instance_find(Player, 0);
    if (_p.invincibility_timer > 0) {
        instance_destroy();
        exit;
    }

    var _shape_len = array_length(damage_shape);
    var _best_spots = [];
    var _best_hits = 0;
    var _min_dx = damage_shape[0][0]; var _max_dx = damage_shape[0][0];
    var _min_dy = damage_shape[0][1]; var _max_dy = damage_shape[0][1];
    for (var i = 1; i < _shape_len; i++) {
        _min_dx = min(_min_dx, damage_shape[i][0]); _max_dx = max(_max_dx, damage_shape[i][0]);
        _min_dy = min(_min_dy, damage_shape[i][1]); _max_dy = max(_max_dy, damage_shape[i][1]);
    }

    // Permit negative pattern origins so even the health grid's outer corner cells can be hit.
    for (var _gx = -_max_dx; _gx <= _p.grid_width - 1 - _min_dx; _gx++) {
        for (var _gy = -_max_dy; _gy <= _p.grid_height - 1 - _min_dy; _gy++) {
            var _hits = 0;
            for (var i = 0; i < _shape_len; i++) {
                var _tx = _gx + damage_shape[i][0];
                var _ty = _gy + damage_shape[i][1];
                if (_tx >= 0 && _tx < array_length(_p.hp_grid) && _ty >= 0 && _ty < array_length(_p.hp_grid[0])) {
                    if (_p.hp_grid[_tx][_ty] > 0) _hits++;
                }
            }
            if (_hits > _best_hits) { _best_hits = _hits; _best_spots = []; }
            if (_hits > 0 && _hits == _best_hits) {
                array_push(_best_spots, [_gx, _gy]);
            }
        }
    }
    
    // Choose among placements that actually reach the most remaining health cells.
    var _chosen = [-1, -1];
    if (array_length(_best_spots) > 0) {
        _chosen = _best_spots[irandom(array_length(_best_spots) - 1)];
    }
    
    // Apply pattern damage to the Player's hp_grid
    var _indicator_cells = [];
    var _did_damage = false;
    if (_chosen[0] != -1) {
        for (var i = 0; i < _shape_len; i++) {
            var _tx = _chosen[0] + damage_shape[i][0];
            var _ty = _chosen[1] + damage_shape[i][1];
            // Keep every cell in the indicator, even when it falls beyond the health grid.
            array_push(_indicator_cells, [_tx, _ty]);
            
            // FOOLPROOF BOUNDS CHECK
            if (_tx >= 0 && _tx < array_length(_p.hp_grid) && _ty >= 0 && _ty < array_length(_p.hp_grid[0])) {
                if (_p.hp_grid[_tx][_ty] > 0) {
                    _p.hp_grid[_tx][_ty] -= 1;
                    if (_p.hp_grid[_tx][_ty] == 0) _p.hp_grid[_tx][_ty] = -1; // Flip 0 to -1 (damaged)
                    _did_damage = true;
                }
            }
        }
    }

    if (array_length(_indicator_cells) > 0) {
        _p.damage_indicator_cells = _indicator_cells;
        _p.damage_indicator_timer = 45;
    }
    if (_did_damage) {
        _p.invincibility_timer = _p.invincibility_duration;
        audio_play_sound(damage_sound_effect, 1, false);
    }
    
    instance_destroy();
}
