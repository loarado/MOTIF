// 1. Draw Transparent Combat Overlay
if (global.combat_active) {
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1.0);
    draw_set_color(c_white);
}

draw_set_color(c_black);
draw_text_transformed(48, 124, "POINTS: " + string(points), 2, 2, 0);
draw_set_color(c_white);



// In multi-enemy rooms, show only the grid of the enemy currently being attacked.
var _disp_enemy = noone;
if (global.combat_active && instance_exists(global.target_enemy)) _disp_enemy = global.target_enemy;

if (_disp_enemy != noone && variable_instance_exists(_disp_enemy, "enemy_hp_grid")) {
    var _start_x = display_get_gui_width() - (_disp_enemy.enemy_grid_width * cell_size) - 48 - 150;
    var _start_y = (display_get_gui_height() - (_disp_enemy.enemy_grid_height * cell_size)) / 2;

    draw_set_color(c_black);
    draw_rectangle(_start_x - 8, _start_y - 32,
        _start_x + (_disp_enemy.enemy_grid_width * cell_size) + 8,
        _start_y + (_disp_enemy.enemy_grid_height * cell_size) + 8, false);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_text(_start_x + (_disp_enemy.enemy_grid_width * cell_size) / 2, _start_y - 18, "Health Grid");
    draw_set_halign(fa_left);

    for (var _x = 0; _x < _disp_enemy.enemy_grid_width; _x++) {
        for (var _y = 0; _y < _disp_enemy.enemy_grid_height; _y++) {
            
            // THESE TWO LINES WERE MISSING
            var _draw_x = _start_x + (_x * cell_size);
            var _draw_y = _start_y + (_y * cell_size);
            
            var _e_hp = ds_grid_get(_disp_enemy.enemy_hp_grid, _x, _y);
            // Zero-valued cells are empty parts of non-square enemy shapes.
            if (_e_hp != 0) {
                if (_e_hp >= 2) {
                    var _armor_gray = clamp(160 - ((_e_hp - 2) * 45), 60, 160);
                    draw_set_color(make_color_rgb(_armor_gray, _armor_gray, _armor_gray));
                } else if (_e_hp == 1) draw_set_color(c_white);
                else draw_set_color(c_black);
            
            // Hover effect
            if (global.combat_active && is_dragging) {
                var _mx = device_mouse_x_to_gui(0);
                var _my = device_mouse_y_to_gui(0);

                for (var i = 0; i < array_length(my_attack_pattern); i++) {
                    var _block_cx = (_mx - drag_offset_x) + (my_attack_pattern[i][0] * cell_size) + (cell_size / 2);
                    var _block_cy = (_my - drag_offset_y) + (my_attack_pattern[i][1] * cell_size) + (cell_size / 2);
                    
                    var _hover_x = floor((_block_cx - _start_x) / cell_size);
                    var _hover_y = floor((_block_cy - _start_y) / cell_size);
                    
                    if (_x == _hover_x && _y == _hover_y && _e_hp > 0) {
                        draw_set_color(make_color_rgb(139, 0, 0)); // Dark red hover
                    }
                }
            }
            
                draw_rectangle(_draw_x, _draw_y, _draw_x + cell_size - 1, _draw_y + cell_size - 1, false);
                draw_set_color((_e_hp < 0) ? c_gray : c_black);
                draw_rectangle(_draw_x, _draw_y, _draw_x + cell_size - 1, _draw_y + cell_size - 1, true);

                // Draw armor number if > 1
                if (_e_hp > 1) {
                    draw_set_color(c_white);
                    draw_text(_draw_x + 10, _draw_y + 6, string(_e_hp));
                }
            }
        }
    }
}

// 3. Draw Player Health Grid
var _player_start_x = 62;
var _player_start_y = display_get_gui_height() - (grid_height * cell_size) - 62;

draw_set_color(c_black);
draw_rectangle(_player_start_x - 8, _player_start_y - 8,
    _player_start_x + (grid_width * cell_size) + 8,
    _player_start_y + (grid_height * cell_size) + 8, false);
draw_set_color(c_black);
draw_set_halign(fa_center);
draw_text(_player_start_x + (grid_width * cell_size) / 2, _player_start_y - 68, "Health Grid");
draw_set_halign(fa_left);

for (var _x = 0; _x < grid_width; _x++) {
    for (var _y = 0; _y < grid_height; _y++) {
        
        // THESE TWO LINES WERE MISSING
        var _draw_x = _player_start_x + (_x * cell_size);
        var _draw_y = _player_start_y + (_y * cell_size);
        
        var _p_hp = hp_grid[_x][_y];
        if (_p_hp >= 2) {
            var _armor_gray = clamp(160 - ((_p_hp - 2) * 45), 60, 160);
            draw_set_color(make_color_rgb(_armor_gray, _armor_gray, _armor_gray));
        } else if (_p_hp == 1) draw_set_color(c_white);
        else draw_set_color(c_black);
        
        draw_rectangle(_draw_x, _draw_y, _draw_x + cell_size - 1, _draw_y + cell_size - 1, false);
        draw_set_color((_p_hp <= 0) ? c_gray : c_black);
        draw_rectangle(_draw_x, _draw_y, _draw_x + cell_size - 1, _draw_y + cell_size - 1, true);
        
        if (_p_hp > 1) {
            draw_set_color(c_white);
            draw_text(_draw_x + 10, _draw_y + 6, string(_p_hp));
            draw_set_color(c_white);
        }
    }
}

// Fade the entire incoming shape over the health grid, including cells outside its bounds.
if (damage_indicator_timer > 0 && array_length(damage_indicator_cells) > 0) {
    var _indicator_alpha = 0.75 * (damage_indicator_timer / 45);
    var _indicator_min_x = damage_indicator_cells[0][0];
    var _indicator_max_x = damage_indicator_cells[0][0];
    var _indicator_min_y = damage_indicator_cells[0][1];
    var _indicator_max_y = damage_indicator_cells[0][1];
    for (var i = 1; i < array_length(damage_indicator_cells); i++) {
        _indicator_min_x = min(_indicator_min_x, damage_indicator_cells[i][0]);
        _indicator_max_x = max(_indicator_max_x, damage_indicator_cells[i][0]);
        _indicator_min_y = min(_indicator_min_y, damage_indicator_cells[i][1]);
        _indicator_max_y = max(_indicator_max_y, damage_indicator_cells[i][1]);
    }

    // Shift the indicator only if needed to keep the complete shape on screen.
    var _indicator_shift_x = 0;
    var _indicator_shift_y = 0;
    var _indicator_left = _player_start_x + (_indicator_min_x * cell_size);
    var _indicator_right = _player_start_x + ((_indicator_max_x + 1) * cell_size);
    var _indicator_top = _player_start_y + (_indicator_min_y * cell_size);
    var _indicator_bottom = _player_start_y + ((_indicator_max_y + 1) * cell_size);
    if (_indicator_left < 0) _indicator_shift_x = -_indicator_left;
    else if (_indicator_right > display_get_gui_width()) _indicator_shift_x = display_get_gui_width() - _indicator_right;
    if (_indicator_top < 0) _indicator_shift_y = -_indicator_top;
    else if (_indicator_bottom > display_get_gui_height()) _indicator_shift_y = display_get_gui_height() - _indicator_bottom;

    draw_set_alpha(_indicator_alpha);
    draw_set_color(c_yellow);
    for (var i = 0; i < array_length(damage_indicator_cells); i++) {
        var _indicator_x = _player_start_x + (damage_indicator_cells[i][0] * cell_size) + _indicator_shift_x;
        var _indicator_y = _player_start_y + (damage_indicator_cells[i][1] * cell_size) + _indicator_shift_y;
        draw_rectangle(_indicator_x, _indicator_y, _indicator_x + cell_size - 1, _indicator_y + cell_size - 1, false);
        draw_rectangle(_indicator_x + 3, _indicator_y + 3, _indicator_x + cell_size - 4, _indicator_y + cell_size - 4, false);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// 3.5 Draw Attack Cooldown Indicator above Player Grid
var _bar_width = grid_width * cell_size * 2;
var _bar_height = 14;
var _bar_x = _player_start_x;
var _bar_y = _player_start_y + (grid_height * cell_size) + 12;

// Draw dark background box
draw_set_color(c_dkgray);
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + _bar_height, false);

// Calculate the remaining sword recharge against its current full cooldown.
var _fill_ratio = clamp(1 - (attack_cooldown / attack_hit_cooldown), 0, 1);

if (_fill_ratio >= 1) {
    draw_set_color(c_aqua); // Ready to attack
    draw_text_transformed(_bar_x, _bar_y + _bar_height + 3, "LEFT CLICK: ATTACK READY!", 1.5, 1.5, 0);
} else {
    draw_set_color(c_orange); // Recharging
    draw_text_transformed(_bar_x, _bar_y + _bar_height + 3, "RECHARGING...", 1.5, 1.5, 0);
}

// Draw progress fill and white border
draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_width * _fill_ratio), _bar_y + _bar_height, false);
draw_set_color(c_white);
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width, _bar_y + _bar_height, true);

// 4. Draw the attack upgrade screen or the normal combat drag screen.
if (attack_upgrade_active) {
    var _upgrade_gui_width = display_get_gui_width();
    var _upgrade_gui_height = display_get_gui_height();
    var _upgrade_min_x = my_attack_pattern[0][0];
    var _upgrade_max_x = my_attack_pattern[0][0];
    var _upgrade_min_y = my_attack_pattern[0][1];
    var _upgrade_max_y = my_attack_pattern[0][1];
    for (var i = 1; i < array_length(my_attack_pattern); i++) {
        _upgrade_min_x = min(_upgrade_min_x, my_attack_pattern[i][0]);
        _upgrade_max_x = max(_upgrade_max_x, my_attack_pattern[i][0]);
        _upgrade_min_y = min(_upgrade_min_y, my_attack_pattern[i][1]);
        _upgrade_max_y = max(_upgrade_max_y, my_attack_pattern[i][1]);
    }
    var _upgrade_origin_x = (_upgrade_gui_width / 2) - (((_upgrade_min_x + _upgrade_max_x + 1) * cell_size) / 2);
    var _upgrade_origin_y = (_upgrade_gui_height / 2) - (((_upgrade_min_y + _upgrade_max_y + 1) * cell_size) / 2);
    var _upgrade_source_x = _upgrade_origin_x + ((_upgrade_max_x + 2) * cell_size);
    var _upgrade_source_y = _upgrade_origin_y + (_upgrade_min_y * cell_size);

    draw_set_color(c_yellow);
    draw_text(_upgrade_gui_width / 2 - 150, 32, "DRAG THE SQUARE TO AN OUTLINED SIDE");

    // Outline every empty side where the new square can be attached.
    draw_set_alpha(0.35);
    draw_set_color(c_lime);
    for (var i = 0; i < array_length(my_attack_pattern); i++) {
        var _shape_x = my_attack_pattern[i][0];
        var _shape_y = my_attack_pattern[i][1];
        var _side_x = [_shape_x + 1, _shape_x - 1, _shape_x, _shape_x];
        var _side_y = [_shape_y, _shape_y, _shape_y + 1, _shape_y - 1];
        for (var j = 0; j < 4; j++) {
            var _occupied = false;
            for (var k = 0; k < array_length(my_attack_pattern); k++) {
                if (my_attack_pattern[k][0] == _side_x[j] && my_attack_pattern[k][1] == _side_y[j]) {
                    _occupied = true;
                    break;
                }
            }
            if (!_occupied) {
                var _side_draw_x = _upgrade_origin_x + (_side_x[j] * cell_size);
                var _side_draw_y = _upgrade_origin_y + (_side_y[j] * cell_size);
                draw_rectangle(_side_draw_x, _side_draw_y, _side_draw_x + cell_size - 1, _side_draw_y + cell_size - 1, false);
            }
        }
    }
    draw_set_alpha(1);

    if (attack_upgrade_has_target) {
        draw_set_color(c_lime);
        var _target_draw_x = _upgrade_origin_x + (attack_upgrade_target_x * cell_size);
        var _target_draw_y = _upgrade_origin_y + (attack_upgrade_target_y * cell_size);
        draw_rectangle(_target_draw_x, _target_draw_y, _target_draw_x + cell_size - 1, _target_draw_y + cell_size - 1, false);
    }

    for (var i = 0; i < array_length(my_attack_pattern); i++) {
        var _pattern_x = _upgrade_origin_x + (my_attack_pattern[i][0] * cell_size);
        var _pattern_y = _upgrade_origin_y + (my_attack_pattern[i][1] * cell_size);
        draw_set_color(c_aqua);
        draw_rectangle(_pattern_x, _pattern_y, _pattern_x + cell_size - 1, _pattern_y + cell_size - 1, false);
        draw_set_color(c_white);
        draw_rectangle(_pattern_x, _pattern_y, _pattern_x + cell_size - 1, _pattern_y + cell_size - 1, true);
    }

    if (attack_upgrade_dragging) {
        _upgrade_source_x = device_mouse_x_to_gui(0) - attack_upgrade_drag_offset_x;
        _upgrade_source_y = device_mouse_y_to_gui(0) - attack_upgrade_drag_offset_y;
    }
    draw_set_color(c_yellow);
    draw_rectangle(_upgrade_source_x, _upgrade_source_y, _upgrade_source_x + cell_size - 1, _upgrade_source_y + cell_size - 1, false);
    draw_set_color(c_white);
    draw_rectangle(_upgrade_source_x, _upgrade_source_y, _upgrade_source_x + cell_size - 1, _upgrade_source_y + cell_size - 1, true);
} else if (global.combat_active) {
    var _seconds_left = ceil(combat_timer / max(1, game_get_speed(gamespeed_fps)));
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text_transformed(display_get_gui_width() / 2, display_get_gui_height() / 2, "TIME: " + string(_seconds_left), 3, 3, 0);
    if (first_attack_hint_active) {
        var _hint_x = display_get_gui_width() / 2;
        var _hint_y = display_get_gui_height() / 2 + 58;
        draw_set_color(c_black);
        draw_rectangle(_hint_x - 390, _hint_y - 36, _hint_x + 390, _hint_y + 36, false);
        draw_set_color(c_white);
        draw_text(_hint_x, _hint_y - 12, "Drag the blue attack block to the enemy's health grid");
        draw_text(_hint_x, _hint_y + 12, "PRESS R TO ROTATE");
    }
    draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
    
    var _shape_min_x = my_attack_pattern[0][0];
    var _shape_max_x = my_attack_pattern[0][0];
    var _shape_min_y = my_attack_pattern[0][1];
    var _shape_max_y = my_attack_pattern[0][1];
    for (var i = 1; i < array_length(my_attack_pattern); i++) {
        _shape_min_x = min(_shape_min_x, my_attack_pattern[i][0]);
        _shape_max_x = max(_shape_max_x, my_attack_pattern[i][0]);
        _shape_min_y = min(_shape_min_y, my_attack_pattern[i][1]);
        _shape_max_y = max(_shape_max_y, my_attack_pattern[i][1]);
    }
    var _shape_x = display_get_gui_width() / 2;
    var _shape_y = display_get_gui_height() - 96;
    if (instance_exists(global.target_enemy)) {
        var _enemy_grid_x = display_get_gui_width() - (global.target_enemy.enemy_grid_width * cell_size) - 48 - 150;
        var _enemy_grid_y = (display_get_gui_height() - (global.target_enemy.enemy_grid_height * cell_size)) / 2;
        var _pattern_w = (_shape_max_x - _shape_min_x + 1) * cell_size;
        var _pattern_h = (_shape_max_y - _shape_min_y + 1) * cell_size;
        _shape_x = _enemy_grid_x + ((global.target_enemy.enemy_grid_width * cell_size - _pattern_w) / 2) - (_shape_min_x * cell_size);
        _shape_y = _enemy_grid_y + (global.target_enemy.enemy_grid_height * cell_size) + 38 - (_shape_min_y * cell_size);
        if (first_attack_hint_active) {
            var _arrow_x = _enemy_grid_x + (global.target_enemy.enemy_grid_width * cell_size) / 2;
            var _arrow_y = _enemy_grid_y + (global.target_enemy.enemy_grid_height * cell_size) + 18;
            draw_sprite_ext(arrow_to_right, 0, _arrow_x + 16, _arrow_y - 16, 1, 1, 90, c_white, 1);
        }
    }
    if (is_dragging) {
        _shape_x = device_mouse_x_to_gui(0) - drag_offset_x;
        _shape_y = device_mouse_y_to_gui(0) - drag_offset_y;
    }
    
    for (var i = 0; i < array_length(my_attack_pattern); i++) {
        var _px = _shape_x + (my_attack_pattern[i][0] * cell_size);
        var _py = _shape_y + (my_attack_pattern[i][1] * cell_size);
        
        draw_set_color(c_aqua);
        draw_rectangle(_px, _py, _px + cell_size - 1, _py + cell_size - 1, false);
        draw_set_color(c_white);
        draw_rectangle(_px, _py, _px + cell_size - 1, _py + cell_size - 1, true);
    }
}


// Draw last so the incoming room fades in over all gameplay UI and sprites.
if (global.intro_game_fade > 0) {
    draw_set_alpha(global.intro_game_fade);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// End sequence: reverse the eye close, hold on black, then show the thank-you card.
if (global.game_beaten && global.ending_state != "none") {
    var _end_gui_w = display_get_gui_width();
    var _end_gui_h = display_get_gui_height();

    if (global.ending_state == "blink_reverse") {
        draw_sprite_ext(blink_animation, global.ending_blink_frame, 0, 0, 1, 1, 0, c_white, 1);
    } else if (global.ending_state == "fade_to_black") {
        draw_sprite_ext(blink_animation, 0, 0, 0, 1, 1, 0, c_white, 1);
        draw_set_alpha(global.ending_alpha);
        draw_set_color(c_black);
        draw_rectangle(0, 0, _end_gui_w, _end_gui_h, false);
        draw_set_alpha(1);
    } else {
        draw_set_color(c_black);
        draw_rectangle(0, 0, _end_gui_w, _end_gui_h, false);

        if (global.ending_state == "text_fade" || global.ending_state == "text_hold"
            || global.ending_state == "lovely_fade" || global.ending_state == "fanfare"
            || global.ending_state == "final_fade") {
            draw_set_halign(fa_center);
            draw_set_valign(fa_top);
            draw_set_color(c_white);
            draw_set_alpha(global.ending_state == "text_fade" ? global.ending_alpha : 1);
            draw_text_transformed(_end_gui_w / 2, 92,
                "you escaped the tessellection trials!!\nthanks for playing through my submission for the\nIGDA fall gamejam 2026.\n-braulio gomez",
                2, 2, 0);
            draw_set_alpha(1);
        }

        if (global.ending_state == "lovely_fade" || global.ending_state == "fanfare" || global.ending_state == "final_fade") {
            var _lovely_alpha = (global.ending_state == "lovely_fade") ? global.ending_alpha : 1;
            var _lovely_scale = 4;
            draw_sprite_ext(lovely, 0,
                (_end_gui_w / 2) - (sprite_get_width(lovely) * _lovely_scale / 2),
                (_end_gui_h * 0.66) - (sprite_get_height(lovely) * _lovely_scale / 2),
                _lovely_scale, _lovely_scale, 0, c_white, _lovely_alpha);
        }

        if (global.ending_state == "final_fade") {
            draw_set_alpha(global.ending_alpha);
            draw_set_color(c_black);
            draw_rectangle(0, 0, _end_gui_w, _end_gui_h, false);
            draw_set_alpha(1);
        }
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
