if (global.pause_menu_open) exit;
if (!instance_exists(owner_id)) {
    instance_destroy();
    exit;
}

var _progress = age / duration;
var _hilt_distance = 50 + (travel_distance * _progress);
var _player_center_x = owner_id.x + (sprite_get_width(owner_id.sprite_index) / 2) - 10;
var _player_center_y = owner_id.y + (sprite_get_height(owner_id.sprite_index) / 2) - 10;
x = _player_center_x + lengthdir_x(_hilt_distance, attack_direction);
y = _player_center_y + lengthdir_y(_hilt_distance, attack_direction);

var _hit_enemy = noone;
var _enemy_types = [obj_enemy_dot, obj_enemy_triangle, obj_enemy_square, obj_enemy_circle, obj_enemy_triangle_boss, obj_enemy_square_boss, obj_enemy_circle_boss];
for (var _line = 0; _line <= 4; _line++) {
    var _side_offset = ((_line / 4) * 2 - 1) * (blade_width / 2);
    var _perpendicular = attack_direction + 90;
    var _line_x = lengthdir_x(_side_offset, _perpendicular);
    var _line_y = lengthdir_y(_side_offset, _perpendicular);
    for (var _enemy_index = 0; _enemy_index < array_length(_enemy_types); _enemy_index++) {
        _hit_enemy = collision_line(
            x + _line_x,
            y + _line_y,
            x + lengthdir_x(blade_length, attack_direction) + _line_x,
            y + lengthdir_y(blade_length, attack_direction) + _line_y,
            _enemy_types[_enemy_index],
            false,
            true
        );
        if (_hit_enemy != noone) break;
    }
    if (_hit_enemy != noone) break;
}

if (_hit_enemy != noone) {
    global.combat_active = true;
    global.target_enemy = _hit_enemy;
    owner_id.attack_cooldown = owner_id.attack_hit_cooldown;
    var _first_attack = !global.first_enemy_attack_done;
    owner_id.first_attack_hint_active = _first_attack;
    var _drag_seconds = (owner_id.dungeon_index == 2) ? 3 : (_first_attack ? 30 : 6);
    owner_id.combat_timer = max(1, game_get_speed(gamespeed_fps)) * _drag_seconds;
    global.first_enemy_attack_done = true;
    owner_id.is_dragging = false;
    audio_play_sound(play_when_player_successfully_attacks, 1, false);
    instance_destroy();
    exit;
}

age++;
if (age >= duration) instance_destroy();
