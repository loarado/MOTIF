if (!variable_global_exists("hard_mode")) global.hard_mode = false;
image_speed = 0;
image_index = 0;
sprite_index = global.hard_mode ? hard_button_enabled : hard_button_disabled;
player_was_on_button = false;
