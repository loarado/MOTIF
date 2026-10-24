// Pause/settings menu input. Opening it freezes gameplay objects until it is closed.
if (!global.game_beaten) {
    var _pause_gui_w = display_get_gui_width();
    var _pause_gui_h = display_get_gui_height();
    var _pause_mx = device_mouse_x_to_gui(0);
    var _pause_my = device_mouse_y_to_gui(0);
    var _gear_left = _pause_gui_w - 68;
    var _gear_top = 12;
    var _gear_right = _pause_gui_w - 12;
    var _gear_bottom = 68;
    if (mouse_check_button_pressed(mb_left)) {
        if (point_in_rectangle(_pause_mx, _pause_my, _gear_left, _gear_top, _gear_right, _gear_bottom)) {
            global.pause_menu_open = !global.pause_menu_open;
        } else if (global.pause_menu_open) {
            var _panel_left = _pause_gui_w - 252;
            var _panel_top = 68;
            if (point_in_rectangle(_pause_mx, _pause_my, _panel_left + 16, _panel_top + 48, _panel_left + 236, _panel_top + 92)) {
                global.sound_effects_enabled = !global.sound_effects_enabled;
                audio_group_set_gain(audiogroup_sfx, global.sound_effects_enabled ? 1 : 0, 120);
            } else if (point_in_rectangle(_pause_mx, _pause_my, _panel_left + 16, _panel_top + 104, _panel_left + 236, _panel_top + 148)) {
                global.music_enabled = !global.music_enabled;
                audio_group_set_gain(audiogroup_default, global.music_enabled ? 1 : 0, 180);
            } else if (!point_in_rectangle(_pause_mx, _pause_my, _panel_left, _panel_top, _panel_left + 252, _panel_top + 168)) {
                global.pause_menu_open = false;
            }
        }
    }
}
if (global.pause_menu_open) exit;

// Test shortcut: 777 advances one dungeon; in the Circle Dungeon, 777 enables god mode.
if (room == Game_Test && trial_step > 0 && !global.game_beaten) {
    var _fps_777 = max(1, game_get_speed(gamespeed_fps));
    if (global.trial_777_timer > 0) {
        global.trial_777_timer--;
        if (global.trial_777_timer <= 0) global.trial_777_count = 0;
    }
    if (keyboard_check_pressed(ord("7")) || keyboard_check_pressed(vk_numpad7)) {
        global.trial_777_count++;
        global.trial_777_timer = _fps_777 * 2;
        if (global.trial_777_count >= 3) {
            global.trial_777_count = 0;
            global.trial_777_timer = 0;
            if (dungeon_index < 2) {
                with (obj_enemy_dot) { ds_grid_destroy(enemy_hp_grid); instance_destroy(); }
                with (obj_enemy_triangle) { ds_grid_destroy(enemy_hp_grid); instance_destroy(); }
                with (obj_enemy_square) { ds_grid_destroy(enemy_hp_grid); instance_destroy(); }
                with (obj_enemy_circle) { ds_grid_destroy(enemy_hp_grid); instance_destroy(); }
                with (obj_enemy_triangle_boss) { ds_grid_destroy(enemy_hp_grid); instance_destroy(); }
                with (obj_enemy_square_boss) { ds_grid_destroy(enemy_hp_grid); instance_destroy(); }
                with (obj_enemy_circle_boss) { ds_grid_destroy(enemy_hp_grid); instance_destroy(); }
                with (obj_treasure) instance_destroy();
                with (obj_projectile) instance_destroy();
                dungeon_index++;
                trial_deck = trial_decks[dungeon_index];
                trial_step = 1;
                current_room_type = trial_deck[0];
                dungeon_title_timer = 180;
                global.combat_active = false;
                global.target_enemy = noone;
                global.first_enemy_attack_done = true;
                is_dragging = false;
                x = 96;
                y = room_height / 2 - sprite_get_height(sprite_index) * abs(image_yscale) / 2;
                for (var _gx = 0; _gx < grid_width; _gx++) for (var _gy = 0; _gy < grid_height; _gy++) {
                    if (hp_grid[_gx][_gy] <= 0) hp_grid[_gx][_gy] = 1;
                }

                var _skip_enemy_object = (current_room_type == "dot") ? obj_enemy_dot
                    : ((current_room_type == "triangle") ? obj_enemy_triangle
                    : ((current_room_type == "square") ? obj_enemy_square : obj_enemy_circle));
                var _skip_enemy_count = global.hard_mode ? ((dungeon_index == 1) ? 2 : 3) : 1;
                var _skip_cx = room_width / 2;
                var _skip_cy = room_height / 2;
                for (var _si = 0; _si < _skip_enemy_count; _si++) {
                    var _skip_x = _skip_cx;
                    var _skip_y = _skip_cy;
                    if (_skip_enemy_count == 2) _skip_x += (_si == 0) ? -128 : 128;
                    else if (_skip_enemy_count == 3) {
                        _skip_x += (_si == 0) ? 0 : ((_si == 1) ? -128 : 128);
                        _skip_y += (_si == 0) ? -96 : 80;
                    }
                    instance_create_layer(_skip_x, _skip_y, layer, _skip_enemy_object);
                }
            } else {
                global.dev_god_mode = true;
                for (var _gx = 0; _gx < grid_width; _gx++) for (var _gy = 0; _gy < grid_height; _gy++) {
                    hp_grid[_gx][_gy] = hp_max_grid[_gx][_gy];
                }
            }
        }
    }
}

// God mode constantly restores all health, including cells destroyed by boss attacks.
if (global.dev_god_mode) {
    for (var _gx = 0; _gx < grid_width; _gx++) for (var _gy = 0; _gy < grid_height; _gy++) {
        hp_grid[_gx][_gy] = hp_max_grid[_gx][_gy];
    }
}

// Check if any healthy cells (1) remain in the player's grid
var _player_alive = false;
for (var _x = 0; _x < grid_width; _x++) {
    for (var _y = 0; _y < grid_height; _y++) {
        if (hp_grid[_x][_y] > 0) {
            _player_alive = true;
            break;
        }
    }
    if (_player_alive) break;
}

// Reset the trial if the player has no health left
if (!_player_alive) {
    global.combat_active = false;
    global.target_enemy = noone;
    global.start_trial_on_enter = false;
    room_goto(Starting_Room);
    exit;
}

// Boss music replaces the normal track during a boss fight, then fades back out.
var _boss_present = instance_exists(obj_enemy_triangle_boss)
    || instance_exists(obj_enemy_square_boss)
    || instance_exists(obj_enemy_circle_boss);
var _audio_fps = max(1, game_get_speed(gamespeed_fps));
if (_boss_present) {
    if (global.boss_music_fading) {
        global.boss_music_fading = false;
        global.boss_music_fade_timer = 0;
        if (global.boss_music_handle != -1) audio_sound_gain(global.boss_music_handle, 1, 250);
    }
    if (!global.boss_music_active) {
        if (global.gameplay_music_handle != -1 && audio_is_playing(global.gameplay_music_handle)) {
            audio_sound_gain(global.gameplay_music_handle, 0, 500);
        }
        if (global.boss_music_handle == -1 || !audio_is_playing(global.boss_music_handle)) {
            global.boss_music_handle = audio_play_sound(IntenseMusic, 1, true);
        }
        global.boss_music_active = true;
    }
} else if (global.boss_music_active) {
    global.boss_music_active = false;
    global.boss_music_fading = true;
    global.boss_music_fade_timer = _audio_fps;
    if (global.boss_music_handle != -1 && audio_is_playing(global.boss_music_handle)) {
        audio_sound_gain(global.boss_music_handle, 0, 1000);
    }
    if (global.gameplay_music_handle != -1 && audio_is_playing(global.gameplay_music_handle)) {
        audio_sound_gain(global.gameplay_music_handle, 1, 1000);
    }
}
if (global.boss_music_fading) {
    global.boss_music_fade_timer--;
    if (global.boss_music_fade_timer <= 0) {
        if (global.boss_music_handle != -1) audio_stop_sound(global.boss_music_handle);
        global.boss_music_handle = -1;
        global.boss_music_fading = false;
    }
}

if (global.game_beaten) {
    var _ending_fps = max(1, game_get_speed(gamespeed_fps));
    if (global.ending_state == "none") {
        global.ending_state = "blink_reverse";
        global.ending_timer = 0;
        global.ending_blink_frame = 14;
        if (global.gameplay_music_handle != -1 && audio_is_playing(global.gameplay_music_handle)) audio_sound_gain(global.gameplay_music_handle, 0, 1000);
        if (global.boss_music_handle != -1 && audio_is_playing(global.boss_music_handle)) audio_sound_gain(global.boss_music_handle, 0, 1000);
        global.intro_hum_handle = audio_play_sound(Background_electrical_hum_for_all_of_intro, 1, true);
    }

    global.ending_timer++;
    switch (global.ending_state) {
        case "blink_reverse":
            global.ending_blink_frame = max(0, 14 - floor(global.ending_timer * 5 / _ending_fps));
            if (global.ending_timer >= _ending_fps * 3) {
                global.ending_state = "fade_to_black";
                global.ending_timer = 0;
                global.ending_alpha = 0;
                if (global.intro_hum_handle != -1 && audio_is_playing(global.intro_hum_handle)) audio_sound_gain(global.intro_hum_handle, 0, 800);
            }
            break;
        case "fade_to_black":
            global.ending_alpha = min(1, global.ending_timer / (_ending_fps * 0.8));
            if (global.ending_alpha >= 1) { global.ending_state = "black_wait"; global.ending_timer = 0; }
            break;
        case "black_wait":
            if (global.ending_timer >= _ending_fps * 2) { global.ending_state = "text_fade"; global.ending_timer = 0; global.ending_alpha = 0; }
            break;
        case "text_fade":
            global.ending_alpha = min(1, global.ending_timer / _ending_fps);
            if (global.ending_alpha >= 1) { global.ending_state = "text_hold"; global.ending_timer = 0; }
            break;
        case "text_hold":
            if (global.ending_timer >= _ending_fps) { global.ending_state = "lovely_fade"; global.ending_timer = 0; global.ending_alpha = 0; }
            break;
        case "lovely_fade":
            global.ending_alpha = min(1, global.ending_timer / _ending_fps);
            if (global.ending_alpha >= 1) {
                global.ending_state = "fanfare";
                global.ending_timer = 0;
                global.ending_fanfare_handle = audio_play_sound(fanfare_audio, 1, false);
            }
            break;
        case "fanfare":
            if (global.ending_timer >= _ending_fps * 11) { global.ending_state = "final_fade"; global.ending_timer = 0; global.ending_alpha = 0; }
            break;
        case "final_fade":
            global.ending_alpha = min(1, global.ending_timer / _ending_fps);
            if (global.ending_alpha >= 1) {
                global.ending_state = "done";
                if (global.ending_fanfare_handle != -1) audio_stop_sound(global.ending_fanfare_handle);
                if (global.intro_hum_handle != -1) audio_stop_sound(global.intro_hum_handle);
            }
            break;
    }
    exit;
}

// Fade into gameplay after the title cutscene and briefly keep controls paused.
if (global.intro_game_fade > 0) {
    global.intro_game_fade = max(0, global.intro_game_fade - 1 / (max(1, game_get_speed(gamespeed_fps)) * 0.5));
    if (global.intro_game_fade > 0) exit;
}

player_walking = false;
if (damage_indicator_timer > 0) damage_indicator_timer--;
if (dungeon_title_timer > 0) dungeon_title_timer--;
if (boss_telegraph_timer > 0) boss_telegraph_timer--;
if (invincibility_timer > 0) {
    invincibility_timer--;
    image_alpha = ((invincibility_timer div 4) mod 2 == 0) ? 0.35 : 1;
} else {
    image_alpha = 1;
}

if (attack_upgrade_active) {
    // Center the existing pattern in the upgrade screen and place the new tile beside it.
    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();
    var _min_x = my_attack_pattern[0][0];
    var _max_x = my_attack_pattern[0][0];
    var _min_y = my_attack_pattern[0][1];
    var _max_y = my_attack_pattern[0][1];
    for (var i = 1; i < array_length(my_attack_pattern); i++) {
        _min_x = min(_min_x, my_attack_pattern[i][0]);
        _max_x = max(_max_x, my_attack_pattern[i][0]);
        _min_y = min(_min_y, my_attack_pattern[i][1]);
        _max_y = max(_max_y, my_attack_pattern[i][1]);
    }
    var _origin_x = (_gui_width / 2) - (((_min_x + _max_x + 1) * cell_size) / 2);
    var _origin_y = (_gui_height / 2) - (((_min_y + _max_y + 1) * cell_size) / 2);
    var _source_x = _origin_x + ((_max_x + 2) * cell_size);
    var _source_y = _origin_y + (_min_y * cell_size);
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    if (mouse_check_button_pressed(mb_left)
        && point_in_rectangle(_mx, _my, _source_x, _source_y, _source_x + cell_size, _source_y + cell_size)) {
        attack_upgrade_dragging = true;
        audio_play_sound(Sound_for_picking_up_a_block, 1, false);
        attack_upgrade_drag_offset_x = _mx - _source_x;
        attack_upgrade_drag_offset_y = _my - _source_y;
    }

    attack_upgrade_has_target = false;
    if (attack_upgrade_dragging) {
        var _candidate_x = floor((_mx - _origin_x) / cell_size);
        var _candidate_y = floor((_my - _origin_y) / cell_size);
        var _occupied = false;
        var _adjacent = false;

        for (var i = 0; i < array_length(my_attack_pattern); i++) {
            var _shape_x = my_attack_pattern[i][0];
            var _shape_y = my_attack_pattern[i][1];
            if (_candidate_x == _shape_x && _candidate_y == _shape_y) _occupied = true;
            if ((_candidate_x == _shape_x + 1 && _candidate_y == _shape_y)
                || (_candidate_x == _shape_x - 1 && _candidate_y == _shape_y)
                || (_candidate_x == _shape_x && _candidate_y == _shape_y + 1)
                || (_candidate_x == _shape_x && _candidate_y == _shape_y - 1)) {
                _adjacent = true;
            }
        }

        attack_upgrade_has_target = _adjacent && !_occupied;
        if (attack_upgrade_has_target) {
            attack_upgrade_target_x = _candidate_x;
            attack_upgrade_target_y = _candidate_y;
        }

        if (mouse_check_button_released(mb_left)) {
            attack_upgrade_dragging = false;
            audio_play_sound(Sound_for_placing_down_a_block, 1, false);
            if (attack_upgrade_has_target) {
                array_push(my_attack_pattern, [attack_upgrade_target_x, attack_upgrade_target_y]);
                attack_upgrade_active = false;
                attack_upgrade_has_target = false;
                global.combat_active = false;
            }
        }
    }
}
// ==========================================
// 1. REAL-TIME DODGE & MOVEMENT PHASE
// ==========================================
else if (!global.combat_active) {
    var _right = keyboard_check(ord("D"));
    var _left = keyboard_check(ord("A"));
    var _down = keyboard_check(ord("S"));
    var _up = keyboard_check(ord("W"));

    var _hspd = (_right - _left) * move_speed;
    var _vspd = (_down - _up) * move_speed;

    // Horizontal Collision
    if (_hspd != 0 && place_meeting(x + _hspd, y, obj_wall)) {
        while (!place_meeting(x + sign(_hspd), y, obj_wall)) {
            x += sign(_hspd);
        }
        _hspd = 0;
    }
    x += _hspd;

    // Vertical Collision
    if (_vspd != 0 && place_meeting(x, y + _vspd, obj_wall)) {
        while (!place_meeting(x, y + sign(_vspd), obj_wall)) {
            y += sign(_vspd);
        }
        _vspd = 0;
    }
    y += _vspd;

    player_walking = (_hspd != 0 || _vspd != 0);
    if (player_walking) {
        if (abs(_hspd) > abs(_vspd)) player_facing = (_hspd < 0) ? "left" : "right";
        else player_facing = (_vspd < 0) ? "back" : "front";
    }

    // Nudge regular enemies away after movement so they cannot pin the player in place.
    var _foe_types = [obj_enemy_dot, obj_enemy_triangle, obj_enemy_square, obj_enemy_circle];
    for (var _fi = 0; _fi < array_length(_foe_types); _fi++) {
        var _foe = instance_place(x, y, _foe_types[_fi]);
        if (_foe != noone) {
            if (global.dev_god_mode) {
                ds_grid_clear(_foe.enemy_hp_grid, 0);
                if (global.target_enemy == _foe) { global.target_enemy = noone; global.combat_active = false; is_dragging = false; }
                continue;
            }
            var _pcx = x + sprite_get_width(sprite_index) * abs(image_xscale) / 2;
            var _pcy = y + sprite_get_height(sprite_index) * abs(image_yscale) / 2;
            var _centered_foe = (_foe.object_index == obj_enemy_triangle || _foe.object_index == obj_enemy_square);
            var _fcx = _centered_foe ? _foe.x : _foe.x + sprite_get_width(_foe.sprite_index) * abs(_foe.image_xscale) / 2;
            var _fcy = _centered_foe ? _foe.y : _foe.y + sprite_get_height(_foe.sprite_index) * abs(_foe.image_yscale) / 2;
            var _push_dir = point_distance(_pcx, _pcy, _fcx, _fcy) < 1 ? random(360) : point_direction(_pcx, _pcy, _fcx, _fcy);
            repeat (40) {
                if (!place_meeting(x, y, _foe_types[_fi])) break;
                var _foe_scale_x = abs(_foe.image_xscale);
                var _foe_scale_y = abs(_foe.image_yscale);
                var _next_x = clamp(_foe.x + lengthdir_x(2, _push_dir), 0, room_width - sprite_get_width(_foe.sprite_index) * _foe_scale_x);
                var _next_y = clamp(_foe.y + lengthdir_y(2, _push_dir), 0, room_height - sprite_get_height(_foe.sprite_index) * _foe_scale_y);
                var _bbox_left_offset = _foe.bbox_left - _foe.x;
                var _bbox_right_offset = _foe.bbox_right - _foe.x;
                var _bbox_top_offset = _foe.bbox_top - _foe.y;
                var _bbox_bottom_offset = _foe.bbox_bottom - _foe.y;
                var _foe_moved = false;
                if (!collision_rectangle(_next_x + _bbox_left_offset, _foe.y + _bbox_top_offset,
                    _next_x + _bbox_right_offset, _foe.y + _bbox_bottom_offset, obj_wall, true, true)) {
                    _foe.x = _next_x;
                    _foe_moved = true;
                }
                if (!collision_rectangle(_foe.x + _bbox_left_offset, _next_y + _bbox_top_offset,
                    _foe.x + _bbox_right_offset, _next_y + _bbox_bottom_offset, obj_wall, true, true)) {
                    _foe.y = _next_y;
                    _foe_moved = true;
                }
                if (!_foe_moved) break;
            }
        }
    }

    // Bosses stay anchored; when touched, move the player clear with wall-aware steps.
    var _boss_types = [obj_enemy_triangle_boss, obj_enemy_square_boss, obj_enemy_circle_boss];
    for (var _bi = 0; _bi < array_length(_boss_types); _bi++) {
        var _boss = instance_place(x, y, _boss_types[_bi]);
        if (_boss != noone) {
            if (global.dev_god_mode) {
                ds_grid_clear(_boss.enemy_hp_grid, 0);
                if (global.target_enemy == _boss) { global.target_enemy = noone; global.combat_active = false; is_dragging = false; }
                continue;
            }
            var _player_center_x = x + sprite_get_width(sprite_index) * abs(image_xscale) / 2;
            var _player_center_y = y + sprite_get_height(sprite_index) * abs(image_yscale) / 2;
            var _centered_boss = (_boss.object_index == obj_enemy_triangle_boss || _boss.object_index == obj_enemy_square_boss);
            var _boss_center_x = _centered_boss ? _boss.x : _boss.x + sprite_get_width(_boss.sprite_index) * abs(_boss.image_xscale) / 2;
            var _boss_center_y = _centered_boss ? _boss.y : _boss.y + sprite_get_height(_boss.sprite_index) * abs(_boss.image_yscale) / 2;
            var _push_dir = point_distance(_player_center_x, _player_center_y, _boss_center_x, _boss_center_y) < 1
                ? random(360) : point_direction(_boss_center_x, _boss_center_y, _player_center_x, _player_center_y);
            repeat (48) {
                if (!place_meeting(x, y, _boss_types[_bi])) break;
                var _moved = false;
                for (var _turn = 0; _turn < 4; _turn++) {
                    var _try_dir = _push_dir + (_turn * 90);
                    var _next_x = x + lengthdir_x(2, _try_dir);
                    var _next_y = y + lengthdir_y(2, _try_dir);
                    if (!place_meeting(_next_x, _next_y, obj_wall)) {
                        x = _next_x; y = _next_y; _moved = true; break;
                    }
                }
                if (!_moved) break;
            }
        }
    }

    // The sword and shield have independent cooldowns but cannot activate together.
    if (attack_cooldown > 0) attack_cooldown--;

    var _left_pressed = mouse_check_button_pressed(mb_left);
    var _right_pressed = mouse_check_button_pressed(mb_right);
    if (_left_pressed && !_right_pressed && !mouse_check_button(mb_right) && attack_cooldown <= 0 && !instance_exists(obj_shield)) {
        var _player_center_x = x + (sprite_get_width(sprite_index) / 2);
        var _player_center_y = y + (sprite_get_height(sprite_index) / 2);
        var _attack_direction = point_direction(_player_center_x, _player_center_y, mouse_x, mouse_y);
        var _initial_hilt_distance = 50;
        var _sword_x = _player_center_x + lengthdir_x(_initial_hilt_distance, _attack_direction) - 10;
        var _sword_y = _player_center_y + lengthdir_y(_initial_hilt_distance, _attack_direction) - 10;
        var _sword = instance_create_layer(_sword_x, _sword_y, layer, obj_sword);
        audio_play_sound(Sound_of_sword_swinging_for_attack, 1, false);
        _sword.owner_id = id;
        _sword.attack_direction = _attack_direction;
        attack_cooldown = attack_miss_cooldown;
    } else if (_right_pressed && !_left_pressed && !mouse_check_button(mb_left) && !instance_exists(obj_sword)) {
        var _shield = instance_create_layer(x, y, layer, obj_shield);
        _shield.owner_id = id;
        _shield.attack_direction = point_direction(x + sprite_get_width(sprite_index) / 2, y + sprite_get_height(sprite_index) / 2, mouse_x, mouse_y);
        _shield.x = x + sprite_get_width(sprite_index) / 2 + lengthdir_x(65, _shield.attack_direction);
        _shield.y = y + sprite_get_height(sprite_index) / 2 + lengthdir_y(65, _shield.attack_direction);
        _shield.image_angle = _shield.attack_direction + 90;
        var _shield_stamina_cost = global.hard_mode ? 0.20 : 0.25;
        attack_cooldown = min(attack_hit_cooldown, attack_cooldown + ceil(attack_hit_cooldown * _shield_stamina_cost));
    }
} 
// ==========================================
// 2. PAUSED COMBAT DRAG-AND-DROP PHASE
// ==========================================
else {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
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
    var _base_x = display_get_gui_width() / 2;
    var _base_y = display_get_gui_height() - 96;
    if (instance_exists(global.target_enemy)) {
        var _enemy_grid_x = display_get_gui_width() - (global.target_enemy.enemy_grid_width * cell_size) - 48 - 150;
        var _enemy_grid_y = (display_get_gui_height() - (global.target_enemy.enemy_grid_height * cell_size)) / 2;
        var _pattern_w = (_shape_max_x - _shape_min_x + 1) * cell_size;
        var _pattern_h = (_shape_max_y - _shape_min_y + 1) * cell_size;
        _base_x = _enemy_grid_x + ((global.target_enemy.enemy_grid_width * cell_size - _pattern_w) / 2) - (_shape_min_x * cell_size);
        _base_y = _enemy_grid_y + (global.target_enemy.enemy_grid_height * cell_size) + 38 - (_shape_min_y * cell_size);
    }
    
    // Pick up the shape
    if (mouse_check_button_pressed(mb_left)) {
        for (var i = 0; i < array_length(my_attack_pattern); i++) {
            var _cell_x = _base_x + (my_attack_pattern[i][0] * cell_size);
            var _cell_y = _base_y + (my_attack_pattern[i][1] * cell_size);
            if (point_in_rectangle(_mx, _my, _cell_x, _cell_y, _cell_x + cell_size, _cell_y + cell_size)) {
                is_dragging = true;
                audio_play_sound(Sound_for_picking_up_a_block, 1, false);
                drag_offset_x = _mx - _base_x;
                drag_offset_y = _my - _base_y;
                break;
            }
        }
    }

    // Rotate the attack shape 90 degrees clockwise while it is being dragged.
    if (is_dragging && keyboard_check_pressed(ord("R"))) {
        var _rotated_pattern = [];
        for (var i = 0; i < array_length(my_attack_pattern); i++) {
            array_push(_rotated_pattern, [-my_attack_pattern[i][1], my_attack_pattern[i][0]]);
        }
        my_attack_pattern = _rotated_pattern;
    }
    
    // Drop the shape onto the enemy grid
    if (mouse_check_button_released(mb_left) && is_dragging) {
        is_dragging = false;
        audio_play_sound(Sound_for_placing_down_a_block, 1, false);
        var _enemy = global.target_enemy;
        if (!instance_exists(_enemy)) {
            var _enemy_types = [obj_enemy_dot, obj_enemy_triangle, obj_enemy_square, obj_enemy_circle, obj_enemy_triangle_boss, obj_enemy_square_boss, obj_enemy_circle_boss];
            var _nearest_distance = 1000000000;
            for (var _enemy_index = 0; _enemy_index < array_length(_enemy_types); _enemy_index++) {
                var _candidate_enemy = instance_nearest(x, y, _enemy_types[_enemy_index]);
                if (instance_exists(_candidate_enemy)) {
                    var _candidate_distance = point_distance(x, y, _candidate_enemy.x, _candidate_enemy.y);
                    if (_candidate_distance < _nearest_distance) {
                        _nearest_distance = _candidate_distance;
                        _enemy = _candidate_enemy;
                    }
                }
            }
        }
        
        if (_enemy != noone) {
            var _enemy_start_x = display_get_gui_width() - (_enemy.enemy_grid_width * cell_size) - 48 - 150;
            var _enemy_start_y = (display_get_gui_height() - (_enemy.enemy_grid_height * cell_size)) / 2;
            var _valid_hit = false;
            
            for (var i = 0; i < array_length(my_attack_pattern); i++) {
                var _block_cx = (_mx - drag_offset_x) + (my_attack_pattern[i][0] * cell_size) + (cell_size / 2);
                var _block_cy = (_my - drag_offset_y) + (my_attack_pattern[i][1] * cell_size) + (cell_size / 2);
                
                var _gx = floor((_block_cx - _enemy_start_x) / cell_size);
                var _gy = floor((_block_cy - _enemy_start_y) / cell_size);
                
                // Check bounds and subtract 1 health/armor from the enemy cell
                if (_gx >= 0 && _gx < _enemy.enemy_grid_width && _gy >= 0 && _gy < _enemy.enemy_grid_height) {
                    var _cell_hp = ds_grid_get(_enemy.enemy_hp_grid, _gx, _gy);
                    if (_cell_hp > 0) {
                        var _new_hp = (_cell_hp == 1) ? -1 : (_cell_hp - 1);
                        ds_grid_set(_enemy.enemy_hp_grid, _gx, _gy, _new_hp);
                        _valid_hit = true;
                    }
                }
            }
            
            if (_valid_hit) {
                global.combat_active = false;
                first_attack_hint_active = false;
            }
        }
    }

    // The attack window continues counting down while the shape is held.
    if (global.combat_active && !attack_upgrade_active) {
        combat_timer--;
        if (combat_timer <= 0) {
            global.combat_active = false;
            is_dragging = false;
            first_attack_hint_active = false;
        }
    }
}

// Use directional idle art when stopped and the matching two-frame walk cycle while moving.
var _desired_player_sprite;
if (player_walking) {
    switch (player_facing) {
        case "back":  _desired_player_sprite = back_walk_player; break;
        case "left":  _desired_player_sprite = left_walk_player; break;
        case "right": _desired_player_sprite = right_walk_player; break;
        default:       _desired_player_sprite = front_walk_player; break;
    }
} else {
    switch (player_facing) {
        case "back":  _desired_player_sprite = back_idle_player; break;
        case "left":  _desired_player_sprite = left_idle_player; break;
        case "right": _desired_player_sprite = right_idle_player; break;
        default:       _desired_player_sprite = front_idle_player; break;
    }
}
if (sprite_index != _desired_player_sprite) {
    sprite_index = _desired_player_sprite;
    image_index = 0;
}
image_speed = player_walking ? 1 : 0;
