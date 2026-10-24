if (!instance_exists(owner_id)) {
    instance_destroy();
    exit;
}

var _progress = age / duration;
var _hilt_distance = 4 + (travel_distance * _progress);
x = owner_id.x + lengthdir_x(_hilt_distance, attack_direction);
y = owner_id.y + lengthdir_y(_hilt_distance, attack_direction);

var _hit_enemy = noone;
for (var _line = 0; _line <= 4; _line++) {
    var _side_offset = ((_line / 4) * 2 - 1) * (blade_width / 2);
    var _perpendicular = attack_direction + 90;
    var _line_x = lengthdir_x(_side_offset, _perpendicular);
    var _line_y = lengthdir_y(_side_offset, _perpendicular);
    _hit_enemy = collision_line(
        x + _line_x,
        y + _line_y,
        x + lengthdir_x(blade_length, attack_direction) + _line_x,
        y + lengthdir_y(blade_length, attack_direction) + _line_y,
        obj_enemy,
        false,
        true
    );
    if (_hit_enemy != noone) break;
}

if (_hit_enemy != noone) {
    global.combat_active = true;
    global.target_enemy = _hit_enemy;
    owner_id.attack_cooldown = owner_id.attack_hit_cooldown;
    owner_id.combat_timer = 300;
    owner_id.is_dragging = false;
    instance_destroy();
    exit;
}

age++;
if (age >= duration) instance_destroy();
