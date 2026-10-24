if (global.pause_menu_open) exit;
// Remove the Dot when its 2x2 health grid is empty.
if (ds_grid_get_max(enemy_hp_grid, 0, 0, enemy_grid_width - 1, enemy_grid_height - 1) <= 0) {
    if (instance_exists(Player)) {
        Player.points += 10;
        audio_play_sound(sound_for_defeating_enemy_or_boss, 1, false);
        if (global.target_enemy == id) {
            global.combat_active = false;
            Player.is_dragging = false;
            global.target_enemy = noone;
        }
    }
    ds_grid_destroy(enemy_hp_grid);
    instance_destroy();
    exit;
}

if (!global.combat_active) {
    var _movement_start_x = x;
    var _movement_start_y = y;
    // Wander slowly, changing direction every few seconds and turning away from room edges.
    move_timer--;
    if (move_timer <= 0) {
        move_dir = random(360);
        move_timer = irandom_range(90, 150);
    }

    var _half_width = (sprite_get_width(sprite_index) * abs(image_xscale)) / 2;
    var _half_height = (sprite_get_height(sprite_index) * abs(image_yscale)) / 2;
    var _min_x = 32 + _half_width;
    var _max_x = room_width - 32 - _half_width;
    var _min_y = 32 + _half_height;
    var _max_y = room_height - 32 - _half_height;
    var _next_x = x + lengthdir_x(move_speed, move_dir);
    var _next_y = y + lengthdir_y(move_speed, move_dir);
    if (_next_x < _min_x || _next_x > _max_x || _next_y < _min_y || _next_y > _max_y) {
        move_dir = random(360);
        move_timer = irandom_range(90, 150);
    } else {
        x = _next_x;
        y = _next_y;
    }

    // Keep the enemy on its current side of any wall collider.
    var _proposed_x = x;
    var _proposed_y = y;
    x = _proposed_x; y = _movement_start_y;
    var _wall_hit = place_meeting(x, y, obj_wall);
    if (_wall_hit) x = _movement_start_x;
    y = _proposed_y;
    if (place_meeting(x, y, obj_wall)) { y = _movement_start_y; _wall_hit = true; }
    if (_wall_hit) { move_dir = random(360); move_timer = irandom_range(45, 90); }

    // Fire one slow, single-cell projectile at the player.
    shoot_timer--;
    if (shoot_timer <= 0 && instance_exists(Player)) {
        shoot_timer = global.hard_mode ? 55 : 100;
        var _spawn_x = x + sprite_get_width(sprite_index) * abs(image_xscale) / 2 - sprite_get_width(spr_projectile) / 2;
        var _spawn_y = y + sprite_get_height(sprite_index) * abs(image_yscale) / 2 - sprite_get_height(spr_projectile) / 2;
        var _projectile = instance_create_layer(_spawn_x, _spawn_y, layer, obj_projectile);
        _projectile.move_dir = point_direction(x + sprite_get_width(sprite_index) / 2, y + sprite_get_height(sprite_index) / 2, Player.x + sprite_get_width(Player.sprite_index) / 2, Player.y + sprite_get_height(Player.sprite_index) / 2);
        _projectile.move_spd = global.hard_mode ? 2.1 : 1.25;
        _projectile.damage_shape = attack_shape;
    }
}
