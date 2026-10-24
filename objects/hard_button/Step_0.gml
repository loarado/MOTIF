if (!variable_global_exists("hard_mode")) global.hard_mode = false;

var _player_on_button = place_meeting(x, y, Player);
if (_player_on_button && !player_was_on_button) {
    global.hard_mode = !global.hard_mode;
    sprite_index = global.hard_mode ? hard_button_enabled : hard_button_disabled;
    image_index = 0;
}
player_was_on_button = _player_on_button;
