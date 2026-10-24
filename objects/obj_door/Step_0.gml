// 1. Lock the door if an enemy or uncollected treasure is in the room
if (instance_exists(obj_enemy_dot) || instance_exists(obj_enemy_triangle) || instance_exists(obj_enemy_square) || instance_exists(obj_enemy_circle) || instance_exists(obj_treasure)) {
    locked = true;
} else {
    locked = false;
}

// 2. Advance to the next room when Player touches an unlocked door
if (!locked && place_meeting(x, y, Player)) {
    
    // Clear any stray projectiles left in the air
    with (obj_projectile) instance_destroy();
    
    // Advance the trial counter
    Player.trial_step++;
    if (Player.current_room_type == "start") Player.dungeon_title_timer = 180;
    
    // After the boss, advance to the next dungeon and start its first room.
    if (Player.trial_step > array_length(Player.trial_deck)) {
        Player.trial_step = 1;
        Player.dungeon_index = (Player.dungeon_index + 1) mod array_length(Player.trial_decks);
        Player.trial_deck = Player.trial_decks[Player.dungeon_index];
        Player.dungeon_title_timer = 180;
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
    
    if (_room_type == "dot") {
        instance_create_layer(_cx, _cy, layer, obj_enemy_dot);
    }
    else if (_room_type == "triangle") {
        instance_create_layer(_cx, _cy, layer, obj_enemy_triangle);
    }
    else if (_room_type == "square") {
        instance_create_layer(_cx, _cy, layer, obj_enemy_square);
    }
    else if (_room_type == "circle") {
        instance_create_layer(_cx, _cy, layer, obj_enemy_circle);
    } 
    else if (_room_type == "treasure") {
        var _pool = [
            ["armor", "ARMOR + HEAL"],
            ["attack_add", "ADD ATTACK SQUARE"],
            ["faster_attack", "FASTER ATTACK COOLDOWN"]
        ];
        if (Player.grid_width < 5) array_push(_pool, ["expand_grid", "GRID SIZE +1"]);
        _pool = array_shuffle(_pool);
        
        // Spawn Left Choice
        var _t1 = instance_create_layer(_cx - 96, _cy, layer, obj_treasure);
        _t1.upgrade_type = _pool[0][0];
        _t1.upgrade_name = _pool[0][1];
        
        // Spawn Right Choice
        var _t2 = instance_create_layer(_cx + 96, _cy, layer, obj_treasure);
        _t2.upgrade_type = _pool[1][0];
        _t2.upgrade_name = _pool[1][1];
    }
    else if (_room_type == "boss") {
        var _boss = instance_create_layer(_cx, _cy, layer, obj_enemy_square);
        
        // Upgrade the Boss to a 5x5 health grid and larger sprite!
        with (_boss) {
            ds_grid_destroy(enemy_hp_grid);
            enemy_grid_width = 5;
            enemy_grid_height = 5;
            enemy_hp_grid = ds_grid_create(5, 5);
            ds_grid_clear(enemy_hp_grid, 1);
            image_xscale = 2;
            image_yscale = 2;
            image_angle = 0;
            image_blend = c_white;
            is_boss = true;
            shoot_timer = 45;
            attack_shape = [[0, 0], [0, 1], [1, 1]];
        }
    }
	
}
