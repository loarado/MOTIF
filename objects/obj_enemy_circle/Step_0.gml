if (ds_grid_get_max(enemy_hp_grid, 0, 0, enemy_grid_width - 1, enemy_grid_height - 1) <= 0) {
    if (instance_exists(Player)) {
        Player.points += 40;
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
    if (movement_mode == "orbit") {
        // Orbit the current anchor, then travel to a new safe point in the field.
        move_angle = (move_angle + orbit_speed) mod 360;
        x = anchor_x + lengthdir_x(move_radius, move_angle);
        y = anchor_y + lengthdir_y(move_radius, move_angle);
        phase_timer--;
        if (phase_timer <= 0) {
            movement_mode = "travel";
            var _safe_margin_x = 32 + (2 * move_radius) + (sprite_get_width(sprite_index) / 2) + 32;
            var _safe_margin_y = 32 + (2 * move_radius) + (sprite_get_height(sprite_index) / 2) + 32;
            target_x = irandom_range(ceil(_safe_margin_x), floor(room_width - _safe_margin_x));
            target_y = irandom_range(ceil(_safe_margin_y), floor(room_height - _safe_margin_y));
        }
    } else {
        var _distance = point_distance(x, y, target_x, target_y);
        if (_distance <= move_speed) {
            x = target_x;
            y = target_y;
            move_angle = random(360);
            // Align the new orbit to the arrival point so the next frame cannot jump.
            anchor_x = x - lengthdir_x(move_radius, move_angle);
            anchor_y = y - lengthdir_y(move_radius, move_angle);
            phase_timer = global.hard_mode ? irandom_range(120, 170) : irandom_range(180, 240);
            movement_mode = "orbit";
        } else {
            var _move_dir = point_direction(x, y, target_x, target_y);
            x += lengthdir_x(move_speed, _move_dir);
            y += lengthdir_y(move_speed, _move_dir);
        }
    }

    var _proposed_x = x;
    var _proposed_y = y;
    x = _proposed_x; y = _movement_start_y;
    var _wall_hit = place_meeting(x, y, obj_wall);
    if (_wall_hit) x = _movement_start_x;
    y = _proposed_y;
    if (place_meeting(x, y, obj_wall)) { y = _movement_start_y; _wall_hit = true; }
    if (_wall_hit) {
        movement_mode = "travel";
        var _wall_safe_margin_x = 32 + (2 * move_radius) + (sprite_get_width(sprite_index) / 2) + 32;
        var _wall_safe_margin_y = 32 + (2 * move_radius) + (sprite_get_height(sprite_index) / 2) + 32;
        target_x = irandom_range(ceil(_wall_safe_margin_x), floor(room_width - _wall_safe_margin_x));
        target_y = irandom_range(ceil(_wall_safe_margin_y), floor(room_height - _wall_safe_margin_y));
    }

    // Fire twelve fast projectiles in two opposite fans; rotate the fans each burst.
    shoot_timer--;
    if (shoot_timer <= 0) {
        shoot_timer = global.hard_mode ? 23 : 35;
        var _shot_count = global.hard_mode ? 16 : 12;
        for (var i = 0; i < _shot_count; i++) {
            var _spawn_x = x + sprite_get_width(sprite_index) * abs(image_xscale) / 2 - sprite_get_width(spr_projectile) / 2;
            var _spawn_y = y + sprite_get_height(sprite_index) * abs(image_yscale) / 2 - sprite_get_height(spr_projectile) / 2;
            var _projectile = instance_create_layer(_spawn_x, _spawn_y, layer, obj_projectile);
            var _fan_size = _shot_count / 2;
            var _fan = floor(i / _fan_size);
            var _fan_step = i mod _fan_size;
            var _fan_angle_step = global.hard_mode ? 9 : 12;
            _projectile.move_dir = spiral_angle + (_fan * 180) + (_fan_step * _fan_angle_step) - ((_fan_size - 1) * _fan_angle_step / 2);
            _projectile.move_spd = global.hard_mode ? 6.5 : 5.5;
            _projectile.damage_shape = attack_shape;
        }
        spiral_angle = (spiral_angle + 22) mod 360;
    }
}
