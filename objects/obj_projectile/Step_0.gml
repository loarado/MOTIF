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

// Check collision with Player
if (place_meeting(x, y, Player)) {
    var _p = instance_find(Player, 0);
    var _shape_len = array_length(damage_shape);
    var _valid_spots = [];
    var _fallback_spots = [];
    
    // Scan every possible grid offset on the player's health bar
    for (var _gx = 0; _gx < _p.grid_width; _gx++) {
        for (var _gy = 0; _gy < _p.grid_height; _gy++) {
            var _hits = 0;
            for (var i = 0; i < _shape_len; i++) {
                var _tx = _gx + damage_shape[i][0];
                var _ty = _gy + damage_shape[i][1];
                
                // FOOLPROOF BOUNDS CHECK
                if (_tx >= 0 && _tx < array_length(_p.hp_grid) && _ty >= 0 && _ty < array_length(_p.hp_grid[0])) {
                    if (_p.hp_grid[_tx][_ty] > 0) _hits++;
                }
            }
            
            if (_hits / _shape_len >= 0.7) {
                array_push(_valid_spots, [_gx, _gy]);
            } else if (_hits > 0) {
                array_push(_fallback_spots, [_gx, _gy]);
            }
        }
    }
    
    // Choose a random spot from the valid list
    var _chosen = [-1, -1];
    if (array_length(_valid_spots) > 0) {
        _chosen = _valid_spots[irandom(array_length(_valid_spots) - 1)];
    } else if (array_length(_fallback_spots) > 0) {
        _chosen = _fallback_spots[irandom(array_length(_fallback_spots) - 1)];
    }
    
    // Apply pattern damage to the Player's hp_grid
    if (_chosen[0] != -1) {
        for (var i = 0; i < _shape_len; i++) {
            var _tx = _chosen[0] + damage_shape[i][0];
            var _ty = _chosen[1] + damage_shape[i][1];
            
            // FOOLPROOF BOUNDS CHECK
            if (_tx >= 0 && _tx < array_length(_p.hp_grid) && _ty >= 0 && _ty < array_length(_p.hp_grid[0])) {
                if (_p.hp_grid[_tx][_ty] > 0) {
                    _p.hp_grid[_tx][_ty] -= 1;
                    if (_p.hp_grid[_tx][_ty] == 0) _p.hp_grid[_tx][_ty] = -1; // Flip 0 to -1 (damaged)
                }
            }
        }
    }
    
    instance_destroy();
}