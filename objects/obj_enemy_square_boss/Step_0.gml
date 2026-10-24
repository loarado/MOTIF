if (global.pause_menu_open) exit;
if (ds_grid_get_max(enemy_hp_grid, 0, 0, enemy_grid_width - 1, enemy_grid_height - 1) <= 0) {
    if (instance_exists(Player)) {
        Player.points += 250;
        audio_play_sound(sound_for_defeating_enemy_or_boss, 1, false);
        if (global.target_enemy == id) { global.combat_active = false; Player.is_dragging = false; global.target_enemy = noone; }
    }
    ds_grid_destroy(enemy_hp_grid); instance_destroy(); exit;
}
if (global.combat_active) exit;
x = room_width / 2;
y = room_height / 2;
if (boss_phase == "idle") {
    boss_timer--;
    if (boss_timer <= 0) { boss_corner = irandom(3); boss_warning_timer = boss_warning_max; boss_phase = "telegraph"; }
} else {
    if (boss_warning_timer > 0) {
        boss_warning_timer--;
    } else {
        var _px = Player.x + sprite_get_width(Player.sprite_index) * abs(Player.image_xscale) / 2;
        var _py = Player.y + sprite_get_height(Player.sprite_index) * abs(Player.image_yscale) / 2;
        var _left = (boss_corner mod 2 == 0);
        var _top = (boss_corner < 2);
        var _in_x = _left ? (_px < room_width / 2) : (_px >= room_width / 2);
        var _in_y = _top ? (_py < room_height / 2) : (_py >= room_height / 2);
        if (_in_x && _in_y) {
            audio_play_sound(damage_sound_effect, 1, false);
            var _x0 = _left ? 0 : floor(Player.grid_width / 2);
            var _x1 = _left ? ceil(Player.grid_width / 2) - 1 : Player.grid_width - 1;
            var _y0 = _top ? 0 : floor(Player.grid_height / 2);
            var _y1 = _top ? ceil(Player.grid_height / 2) - 1 : Player.grid_height - 1;
            for (var _gx = _x0; _gx <= _x1; _gx++) for (var _gy = _y0; _gy <= _y1; _gy++) Player.hp_grid[_gx][_gy] = -1;
        }
        boss_phase = "idle"; boss_timer = global.hard_mode ? 105 : 180;
    }
}
shoot_timer--;
if (shoot_timer <= 0 && instance_exists(Player)) {
    shoot_timer = global.hard_mode ? 38 : 70;
    var _cx = x; var _cy = y;
    var _dir = point_direction(_cx, _cy, Player.x + sprite_get_width(Player.sprite_index) / 2, Player.y + sprite_get_height(Player.sprite_index) / 2);
    var _spread_count = global.hard_mode ? 5 : 3;
    for (var _i = 0; _i < _spread_count; _i++) {
        var _p = instance_create_layer(_cx - sprite_get_width(spr_projectile) / 2, _cy - sprite_get_height(spr_projectile) / 2, layer, obj_projectile);
        _p.move_dir = _dir + (_i - ((_spread_count - 1) / 2)) * (global.hard_mode ? 11 : 12);
        _p.move_spd = global.hard_mode ? 5.3 : 4; _p.damage_shape = attack_shape;
    }
}
