if (ds_grid_get_max(enemy_hp_grid, 0, 0, enemy_grid_width - 1, enemy_grid_height - 1) <= 0) {
    if (instance_exists(Player)) {
        Player.points += 200;
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
if (global.combat_active) exit;

image_angle = (image_angle + (global.hard_mode ? 0.35 : 0.2)) mod 360;
x = room_width / 2;
y = room_height / 2;

if (boss_phase == "idle") {
    boss_timer--;
    if (boss_timer <= 0 && instance_exists(Player)) {
        boss_warning_timer = boss_warning_max;
        boss_phase = "telegraph";
    }
} else if (boss_phase == "telegraph") {
    boss_warning_timer--;
    if (boss_warning_timer <= 0) {
        boss_phase = "barrage";
        boss_barrage_waves = global.hard_mode ? 5 : 3;
        boss_wave_timer = 0;
    }
} else if (boss_phase == "barrage") {
    boss_wave_timer--;
    if (boss_wave_timer <= 0 && instance_exists(Player)) {
        var _center_x = x;
        var _center_y = y;
        var _radius = sprite_get_width(sprite_index) * image_xscale / 2;

        // Fire a three-shot row outward from each of the triangle's three rotating sides.
        for (var _side = 0; _side < 3; _side++) {
            var _edge_angle = -90 + image_angle + (_side * 120);
            var _vx1 = _center_x + lengthdir_x(_radius, _edge_angle);
            var _vy1 = _center_y + lengthdir_y(_radius, _edge_angle);
            var _vx2 = _center_x + lengthdir_x(_radius, _edge_angle + 120);
            var _vy2 = _center_y + lengthdir_y(_radius, _edge_angle + 120);
            var _edge_dx = _vx2 - _vx1;
            var _edge_dy = _vy2 - _vy1;
            var _normal_x = -_edge_dy;
            var _normal_y = _edge_dx;
            var _mid_x = (_vx1 + _vx2) / 2;
            var _mid_y = (_vy1 + _vy2) / 2;
            if (_normal_x * (_mid_x - _center_x) + _normal_y * (_mid_y - _center_y) < 0) {
                _normal_x = -_normal_x;
                _normal_y = -_normal_y;
            }
            var _outward_dir = point_direction(0, 0, _normal_x, _normal_y);

            var _shot_count = global.hard_mode ? 4 : 3;
            for (var _shot = 0; _shot < _shot_count; _shot++) {
                var _t = _shot / (_shot_count - 1);
                var _spawn_x = lerp(_vx1, _vx2, _t) - sprite_get_width(spr_projectile) / 2;
                var _spawn_y = lerp(_vy1, _vy2, _t) - sprite_get_height(spr_projectile) / 2;
                var _projectile = instance_create_layer(_spawn_x, _spawn_y, layer, obj_projectile);
                _projectile.move_dir = _outward_dir + ((_shot - ((_shot_count - 1) / 2)) * (global.hard_mode ? 10 : 8));
                _projectile.move_spd = global.hard_mode ? 5.8 : 4.5;
                _projectile.damage_shape = attack_shape;
            }
        }

        boss_barrage_waves--;
        boss_wave_timer = global.hard_mode ? 7 : 10;
        if (boss_barrage_waves <= 0) {
            boss_phase = "idle";
            boss_timer = global.hard_mode ? 95 : 135;
        }
    }
}
