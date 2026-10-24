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
    // Travel between three random points, then choose a new triangle route.
    if (move_target_index >= 3) {
        move_vertices = [
            [irandom_range(96, room_width - 96), irandom_range(96, room_height - 96)],
            [irandom_range(96, room_width - 96), irandom_range(96, room_height - 96)],
            [irandom_range(96, room_width - 96), irandom_range(96, room_height - 96)]
        ];
        move_target_index = 0;
    }

    var _target_x = move_vertices[move_target_index][0];
    var _target_y = move_vertices[move_target_index][1];
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

    // Fire three projectiles in a rotating triangular spread.
    shoot_timer--;
    if (shoot_timer <= 0) {
        shoot_timer = 100;
        for (var i = 0; i < 3; i++) {
            var _projectile = instance_create_layer(x, y, layer, obj_projectile);
            _projectile.move_dir = spiral_angle + (i * 120);
            _projectile.move_spd = 2.2;
            _projectile.damage_shape = attack_shape;
        }
        spiral_angle = (spiral_angle + 15) mod 360;
    }
}
