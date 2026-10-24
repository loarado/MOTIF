if (global.pause_menu_open) exit;
if (!instance_exists(owner_id)) { instance_destroy(); exit; }
if (block_sound_cooldown > 0) block_sound_cooldown--;

var _player_cx = owner_id.x + sprite_get_width(owner_id.sprite_index) * abs(owner_id.image_xscale) / 2;
var _player_cy = owner_id.y + sprite_get_height(owner_id.sprite_index) * abs(owner_id.image_yscale) / 2;
var _forward_distance = 75;
x = _player_cx + lengthdir_x(_forward_distance, attack_direction);
y = _player_cy + lengthdir_y(_forward_distance, attack_direction);
image_angle = attack_direction + 90;
age++;
if (age >= duration) instance_destroy();
