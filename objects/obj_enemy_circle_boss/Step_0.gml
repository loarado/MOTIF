if (ds_grid_get_max(enemy_hp_grid, 0, 0, enemy_grid_width - 1, enemy_grid_height - 1) <= 0) {
    if (instance_exists(Player)) {
        global.combat_active = false;
        Player.is_dragging = false;
        global.target_enemy = noone;
    }
    ds_grid_destroy(enemy_hp_grid);
    instance_destroy();
    exit;
}

if (!global.combat_active) {
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
            phase_timer = irandom_range(180, 240);
            movement_mode = "orbit";
        } else {
            var _move_dir = point_direction(x, y, target_x, target_y);
            x += lengthdir_x(move_speed, _move_dir);
            y += lengthdir_y(move_speed, _move_dir);
        }
    }

    // Fire twelve fast projectiles in two opposite fans; rotate the fans each burst.
    shoot_timer--;
    if (shoot_timer <= 0) {
        shoot_timer = 35;
        for (var i = 0; i < 12; i++) {
            var _projectile = instance_create_layer(x, y, layer, obj_projectile);
            var _fan = floor(i / 6);
            var _fan_step = i mod 6;
            _projectile.move_dir = spiral_angle + (_fan * 180) + (_fan_step * 12) - 30;
            _projectile.move_spd = 5.5;
            _projectile.damage_shape = attack_shape;
        }
        spiral_angle = (spiral_angle + 22) mod 360;
    }
}
