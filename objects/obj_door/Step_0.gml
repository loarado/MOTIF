// 1. Lock the door if an enemy or uncollected treasure is in the room
if (instance_exists(obj_enemy) || instance_exists(obj_treasure)) {
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
    
    // If the player just beat the Boss at the end of the deck, start a new harder trial!
    if (Player.trial_step > array_length(Player.trial_deck)) {
        Player.trial_step = 1;
        Player.trial_deck = array_shuffle(["enemy", "enemy", "enemy", "treasure", "treasure"]);
        array_push(Player.trial_deck, "boss");
    }
    
    // Get the current room scenario ("enemy", "treasure", or "boss")
    var _room_type = Player.trial_deck[Player.trial_step - 1];
    Player.current_room_type = _room_type;
    
    // 3. Pick a random wall for the new Exit Door, and put Player at the opposite Entrance
    exit_dir = irandom(3); // 0=Top, 1=Right, 2=Bottom, 3=Left
    var _margin = 64;      // Distance from edge of room (adjust if your walls are thicker)
    
    if (exit_dir == 0) { // Exit Top -> Player enters Bottom
        x = room_width / 2;
        y = _margin;
        Player.x = room_width / 2;
        Player.y = room_height - _margin - 48;
    } else if (exit_dir == 1) { // Exit Right -> Player enters Left
        x = room_width - _margin;
        y = room_height / 2;
        Player.x = _margin + 48;
        Player.y = room_height / 2;
    } else if (exit_dir == 2) { // Exit Bottom -> Player enters Top
        x = room_width / 2;
        y = room_height - _margin;
        Player.x = room_width / 2;
        Player.y = _margin + 48;
    } else if (exit_dir == 3) { // Exit Left -> Player enters Right
        x = _margin;
        y = room_height / 2;
        Player.x = room_width - _margin - 48;
        Player.y = room_height / 2;
    }
    
    // 4. Spawn the room contents in the center of the room
    var _cx = room_width / 2;
    var _cy = room_height / 2;
    
    if (_room_type == "enemy") {
        // If you make obj_enemy_2 later, use: choose(obj_enemy, obj_enemy_2)
        instance_create_layer(_cx, _cy, layer, obj_enemy);
    } 
    else if (_room_type == "treasure") {
        var _pool = [
            ["armor", "ARMOR + HEAL"],
            ["expand_grid", "GRID SIZE +1"],
            ["attack_L", "L-SHAPE ATK"],
            ["attack_cross", "CROSS ATK"]
        ];
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
        var _boss = instance_create_layer(_cx, _cy, layer, obj_enemy);
        
        // Upgrade the Boss to a 5x5 health grid and larger sprite!
        with (_boss) {
            ds_grid_destroy(enemy_hp_grid);
            enemy_grid_width = 5;
            enemy_grid_height = 5;
            enemy_hp_grid = ds_grid_create(5, 5);
            ds_grid_clear(enemy_hp_grid, 1);
            image_xscale = 2;
            image_yscale = 2;
        }
    }
	
}