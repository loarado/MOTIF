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
    if (is_boss) {
        // Preserve the existing boss's circular movement and four-way attack.
        move_angle = (move_angle + orbit_speed) mod 360;
        x = anchor_x + lengthdir_x(move_radius, move_angle);
        y = anchor_y + lengthdir_y(move_radius, move_angle);
    } else {
        // Travel the four corners of a random square, then choose a new square.
        if (move_target_index >= 4) {
            square_radius = irandom_range(55, 80);
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

    // Both the Square and the existing boss fire four projectiles.
    shoot_timer--;
    if (shoot_timer <= 0) {
        shoot_timer = 65;
        for (var i = 0; i < 4; i++) {
            var _projectile = instance_create_layer(x, y, layer, obj_projectile);
            _projectile.move_dir = spiral_angle + (i * 90);
            _projectile.move_spd = 3;
            _projectile.damage_shape = attack_shape;
        }
        spiral_angle = (spiral_angle + 20) mod 360;
    }
}
