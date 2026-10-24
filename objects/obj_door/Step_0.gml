// 1. Lock the door if an enemy or uncollected treasure is in the room
if (global.game_beaten) {
    locked = true;
    exit;
}

if (instance_exists(obj_enemy_dot) || instance_exists(obj_enemy_triangle) || instance_exists(obj_enemy_square) || instance_exists(obj_enemy_circle) || instance_exists(obj_enemy_triangle_boss) || instance_exists(obj_enemy_square_boss) || instance_exists(obj_enemy_circle_boss) || instance_exists(obj_treasure)) {
    locked = true;
} else {
    locked = false;
}

// 2. Advance to the next room when Player touches an unlocked door
if (!locked && place_meeting(x, y, Player)) {

    // The hub door enters the trial room; its first encounter spawns on arrival.
    if (room == Starting_Room) {
        global.start_trial_on_enter = true;
        room_goto(Game_Test);
        exit;
    }
    
    // Clear any stray projectiles left in the air
    with (obj_projectile) instance_destroy();
    
    // Advance the trial counter
    Player.trial_step++;
    if (Player.current_room_type == "start") Player.dungeon_title_timer = 180;
    
    // After the boss, advance to the next dungeon and start its first room.
    var _changed_dungeon = false;
    if (Player.trial_step > array_length(Player.trial_deck)) {
        Player.trial_step = 1;
        Player.dungeon_index = (Player.dungeon_index + 1) mod array_length(Player.trial_decks);
        Player.trial_deck = Player.trial_decks[Player.dungeon_index];
        Player.dungeon_title_timer = 180;
        _changed_dungeon = true;
    }
    if (_changed_dungeon) {
        for (var _gx = 0; _gx < Player.grid_width; _gx++) {
            for (var _gy = 0; _gy < Player.grid_height; _gy++) {
                // Restore lost health without granting the armor values in hp_max_grid.
                if (Player.hp_grid[_gx][_gy] <= 0) Player.hp_grid[_gx][_gy] = 1;
            }
        }
    }
    
    // Get the current room scenario (enemy type, treasure, or boss).
    var _room_type = Player.trial_deck[Player.trial_step - 1];
    Player.current_room_type = _room_type;
    
    // Determine which side the player entered from before moving the door.
    var _entered_dir = 0; // 0=Top, 1=Right, 2=Bottom, 3=Left
    var _closest_edge = abs(y);
    var _edge_distance = abs(room_width - x);
    if (_edge_distance < _closest_edge) {
        _closest_edge = _edge_distance;
        _entered_dir = 1;
    }
    _edge_distance = abs(room_height - y);
    if (_edge_distance < _closest_edge) {
        _closest_edge = _edge_distance;
        _entered_dir = 2;
    }
    _edge_distance = abs(x);
    if (_edge_distance < _closest_edge) _entered_dir = 3;

    // The new room entrance is opposite the door just crossed; don't put its exit there.
    var _entrance_dir = (_entered_dir + 2) mod 4;
    exit_dir = irandom(2);
    if (exit_dir >= _entrance_dir) exit_dir++;
    var _margin = 64;      // Distance from edge of room (adjust if your walls are thicker)
    var _player_width = sprite_get_width(Player.sprite_index) * abs(Player.image_xscale);
    var _player_height = sprite_get_height(Player.sprite_index) * abs(Player.image_yscale);
    
    if (exit_dir == 0) { // Exit Top -> Player enters Bottom
        x = room_width / 2;
        y = _margin;
    } else if (exit_dir == 1) { // Exit Right -> Player enters Left
        x = room_width - _margin;
        y = room_height / 2;
    } else if (exit_dir == 2) { // Exit Bottom -> Player enters Top
        x = room_width / 2;
        y = room_height - _margin;
    } else if (exit_dir == 3) { // Exit Left -> Player enters Right
        x = _margin;
        y = room_height / 2;
    }

    // Place Player opposite the door they actually entered, accounting for sprite size.
    if (_entered_dir == 0) {
        Player.x = room_width / 2 - (_player_width / 2);
        Player.y = room_height - _margin - _player_height;
    } else if (_entered_dir == 1) {
        Player.x = _margin + 48;
        Player.y = room_height / 2 - (_player_height / 2);
    } else if (_entered_dir == 2) {
        Player.x = room_width / 2 - (_player_width / 2);
        Player.y = _margin;
    } else {
        Player.x = room_width - _margin - _player_width;
        Player.y = room_height / 2 - (_player_height / 2);
    }
    
    // 4. Spawn the room contents in the center of the room
    var _cx = room_width / 2;
    var _cy = room_height / 2;
    
    var _enemy_object = noone;
    if (_room_type == "dot") _enemy_object = obj_enemy_dot;
    else if (_room_type == "triangle") _enemy_object = obj_enemy_triangle;
    else if (_room_type == "square") _enemy_object = obj_enemy_square;
    else if (_room_type == "circle") _enemy_object = obj_enemy_circle;
    if (_enemy_object != noone) {
        var _enemy_count = global.hard_mode ? ((Player.dungeon_index == 1) ? 2 : ((Player.dungeon_index == 2) ? 3 : 1)) : 1;
        for (var _i = 0; _i < _enemy_count; _i++) {
            var _spawn_x = _cx;
            var _spawn_y = _cy;
            if (_enemy_count == 2) _spawn_x += (_i == 0) ? -128 : 128;
            else if (_enemy_count == 3) {
                _spawn_x += (_i == 0) ? 0 : ((_i == 1) ? -128 : 128);
                _spawn_y += (_i == 0) ? -96 : 80;
            }
            instance_create_layer(_spawn_x, _spawn_y, layer, _enemy_object);
        }
    }
    else if (_room_type == "treasure") {
        var _pool = [
            ["armor", "ARMOR + HEAL"],
            ["attack_add", "ADD ATTACK SQUARE"],
            ["faster_attack", "FASTER ATTACK COOLDOWN"]
        ];
        if (Player.grid_width < 5) array_push(_pool, ["expand_grid", "GRID SIZE +1"]);
        _pool = array_shuffle(_pool);
        
        var _choice_count = (global.hard_mode || Player.dungeon_index == 2) ? 3 : 2;
        var _choice_spacing = (_choice_count == 3) ? 160 : 96;
        var _t1 = instance_create_layer(_cx - _choice_spacing, _cy, layer, obj_treasure);
        _t1.upgrade_type = _pool[0][0];
        _t1.upgrade_name = _pool[0][1];
        
        var _t2_x = (_choice_count == 3) ? _cx : _cx + _choice_spacing;
        var _t2 = instance_create_layer(_t2_x, _cy, layer, obj_treasure);
        _t2.upgrade_type = _pool[1][0];
        _t2.upgrade_name = _pool[1][1];
        if (_choice_count == 3) {
            var _t3 = instance_create_layer(_cx + _choice_spacing, _cy, layer, obj_treasure);
            _t3.upgrade_type = _pool[2][0];
            _t3.upgrade_name = _pool[2][1];
        }
    }
    else if (_room_type == "boss") {
        if (Player.dungeon_index == 0) instance_create_layer(_cx, _cy, layer, obj_enemy_triangle_boss);
        else if (Player.dungeon_index == 1) instance_create_layer(_cx, _cy, layer, obj_enemy_square_boss);
        else instance_create_layer(_cx, _cy, layer, obj_enemy_circle_boss);
    }
	
}
