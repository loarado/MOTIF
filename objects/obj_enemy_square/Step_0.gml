if (ds_grid_get_max(enemy_hp_grid, 0, 0, enemy_grid_width - 1, enemy_grid_height - 1) <= 0) {
    if (instance_exists(Player)) {
        Player.points += 30;
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
    if (is_boss) {
        // Preserve the existing boss's circular movement and four-way attack.
        move_angle = (move_angle + orbit_speed) mod 360;
        x = anchor_x + lengthdir_x(move_radius, move_angle);
        y = anchor_y + lengthdir_y(move_radius, move_angle);
    } else {
        // Travel the four corners of a random square, then choose a new square.
        if (move_target_index >= 4) {
            square_radius = global.hard_mode ? irandom_range(75, 105) : irandom_range(55, 80);
            square_angle = random(360);
            var _center_x = irandom_range(96 + square_radius, room_width - 96 - square_radius);
            var _center_y = irandom_range(96 + square_radius, room_height - 96 - square_radius);
            square_vertices = [];
            for (var i = 0; i < 4; i++) {
                array_push(square_vertices, [
                    _center_x + lengthdir_x(square_radius, square_angle + (i * 90)),
                    _center_y + lengthdir_y(square_radius, square_angle + (i * 90))
                ]);
            }
            move_target_index = 0;
        }

        var _target_x = square_vertices[move_target_index][0];
        var _target_y = square_vertices[move_target_index][1];
        var _distance = point_distance(x, y, _target_x, _target_y);
        if (_distance <= move_speed) {
            x = _target_x;
            y = _target_y;
            move_target_index++;
        } else {
            var _move_dir = point_direction(x, y, _target_x, _target_y);
            x += lengthdir_x(move_speed, _move_dir);
            y += lengthdir_y(move_speed, _move_dir);
        }
        image_angle = (image_angle + rotate_speed) mod 360;
    }

    var _proposed_x = x;
    var _proposed_y = y;
    x = _proposed_x; y = _movement_start_y;
    var _wall_hit = place_meeting(x, y, obj_wall);
    if (_wall_hit) x = _movement_start_x;
    y = _proposed_y;
    if (place_meeting(x, y, obj_wall)) { y = _movement_start_y; _wall_hit = true; }
    if (_wall_hit) {
        if (is_boss) move_angle = random(360);
        else move_target_index = 4;
    }

    // Both the Square and the existing boss fire four projectiles.
    shoot_timer--;
    if (shoot_timer <= 0) {
        shoot_timer = global.hard_mode ? 38 : 65;
        var _spawn_x = x - sprite_get_width(spr_projectile) / 2;
        var _spawn_y = y - sprite_get_height(spr_projectile) / 2;
        for (var i = 0; i < 4; i++) {
            var _projectile = instance_create_layer(_spawn_x, _spawn_y, layer, obj_projectile);
            _projectile.move_dir = image_angle + spiral_angle + (i * 90);
            _projectile.move_spd = global.hard_mode ? 4.5 : 3;
            _projectile.damage_shape = attack_shape;
        }
        spiral_angle = (spiral_angle + 20) mod 360;
    }
}
