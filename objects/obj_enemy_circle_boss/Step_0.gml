if (ds_grid_get_max(enemy_hp_grid, 0, 0, enemy_grid_width - 1, enemy_grid_height - 1) <= 0) {
    if (instance_exists(Player)) {
        Player.points += 300;
        audio_play_sound(sound_for_defeating_enemy_or_boss, 1, false);
        if (global.target_enemy == id) { global.combat_active = false; Player.is_dragging = false; global.target_enemy = noone; }
        global.game_beaten = true;
    }
    ds_grid_destroy(enemy_hp_grid); instance_destroy(); exit;
}
if (global.combat_active) exit;
// Stationary, centered boss; fire random projectiles between short spiral bursts.
x = room_width / 2 - sprite_get_width(sprite_index) * image_xscale / 2;
y = room_height / 2 - sprite_get_height(sprite_index) * image_yscale / 2;
if (spiral_frames > 0) {
    var _spiral_count = global.hard_mode ? 16 : 10;
    for (var _i = 0; _i < _spiral_count; _i++) {
        var _p = instance_create_layer(room_width / 2 - sprite_get_width(spr_projectile) / 2, room_height / 2 - sprite_get_height(spr_projectile) / 2, layer, obj_projectile);
        _p.move_dir = spiral_angle + _i * (360 / _spiral_count);
        _p.move_spd = global.hard_mode ? 9.5 : 8; _p.damage_shape = attack_shape;
    }
    spiral_angle = (spiral_angle + (global.hard_mode ? 34 : 27)) mod 360;
    spiral_frames--;
} else {
    spiral_cooldown--;
    if (spiral_cooldown <= 0) { spiral_frames = global.hard_mode ? 8 : 5; spiral_cooldown = global.hard_mode ? 145 : 210; }
    else {
        shoot_timer--;
        if (shoot_timer <= 0 && instance_exists(Player)) {
            shoot_timer = global.hard_mode ? irandom_range(10, 20) : irandom_range(18, 32);
            var _p = instance_create_layer(room_width / 2 - sprite_get_width(spr_projectile) / 2, room_height / 2 - sprite_get_height(spr_projectile) / 2, layer, obj_projectile);
            _p.move_dir = random(360);
            _p.move_spd = global.hard_mode ? random_range(5, 7) : random_range(3.5, 5.5); _p.damage_shape = attack_shape;
        }
    }
}
