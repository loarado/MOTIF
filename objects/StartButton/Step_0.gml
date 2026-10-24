var _fps = max(1, game_get_speed(gamespeed_fps));

// Fade the rumble during the clip's final 2.5 seconds.
if (rumble_fade_timer > 0) {
    rumble_fade_timer--;
    if (rumble_fade_timer <= 0 && !rumble_fade_started) {
        if (rumble_sound_handle != -1 && audio_is_playing(rumble_sound_handle)) {
            audio_sound_gain(rumble_sound_handle, 0, 2500);
        }
        rumble_fade_started = true;
    }
}

if (shake_timer > 0) {
    shake_timer--;
    shake_time++;
    x = base_x + irandom_range(-8, 8);
    y = base_y + irandom_range(-6, 6);
} else {
    x = base_x;
    y = base_y;
}

// Press 7 three times during the intro to skip directly to gameplay.
if (intro_state != "title" && intro_state != "challenge"
    && intro_state != "fade_game" && intro_state != "skip_game_fade") {
    if (skip_777_timer > 0) {
        skip_777_timer--;
        if (skip_777_timer <= 0) skip_777_count = 0;
    }
    if (keyboard_check_pressed(ord("7")) || keyboard_check_pressed(vk_numpad7)) {
        skip_777_count++;
        skip_777_timer = _fps * 2;
        if (skip_777_count >= 3) {
            intro_state = "skip_game_fade";
            intro_timer = 0;
            fade_alpha = 0;
            if (global.gameplay_music_handle != -1 && audio_is_playing(global.gameplay_music_handle)) {
                audio_sound_gain(global.gameplay_music_handle, 1, 800);
            }
            if (global.intro_hum_handle != -1 && audio_is_playing(global.intro_hum_handle)) {
                audio_sound_gain(global.intro_hum_handle, 0, 800);
            }
            skip_777_count = 0;
            skip_777_timer = 0;
        }
    }
}

if (intro_state == "skip_game_fade") {
    intro_timer++;
    fade_alpha = min(1, intro_timer / (_fps * 0.5));
    if (fade_alpha >= 1) {
        global.intro_game_fade = 1;
        room_goto(Starting_Room);
    }
    exit;
}

if (intro_state == "fade_black") {
    fade_alpha = min(1, fade_alpha + 1 / (_fps * 0.5));
    if (fade_alpha >= 1) {
        intro_state = "blink_open";
        intro_timer = 0;
        blink_frame = 0;
        if (global.gameplay_music_handle == -1 || !audio_is_playing(global.gameplay_music_handle)) {
            global.gameplay_music_handle = audio_play_sound(play_in_intro_sequences_1_2_3_4_5_then_15_and_throughout_gameplay, 0, true);
        }
        global.intro_hum_handle = audio_play_sound(Background_electrical_hum_for_all_of_intro, 0, true);
        audio_play_sound(play_when_eye_open_sequence_happens, 1, false);
    }
    exit;
}
if (intro_state == "blink_open") {
    intro_timer++;
    blink_frame = min(14, floor(intro_timer * 5 / _fps));
    if (intro_timer >= _fps * 3) { intro_state = "paper_wait"; intro_timer = 0; blink_frame = 14; }
    exit;
}
if (intro_state == "paper_wait") {
    intro_timer++;
    if (intro_timer >= _fps * 2) { intro_state = "scene2_fade"; intro_timer = 0; fade_alpha = 0; }
    exit;
}
if (intro_state == "scene2_fade") {
    intro_timer++;
    fade_alpha = min(1, intro_timer / (_fps * 0.4));
    if (fade_alpha >= 1) { intro_state = "scene2_wait"; intro_timer = 0; }
    exit;
}
if (intro_state == "scene2_wait") {
    intro_timer++;
    if (intro_timer >= _fps) { intro_state = "scene3_fade_in"; intro_timer = 0; fade_alpha = 0; }
    exit;
}
if (intro_state == "scene3_fade_in") {
    intro_timer++;
    fade_alpha = min(1, intro_timer / (_fps * 0.4));
    if (fade_alpha >= 1) { intro_state = "scene3_wait"; intro_timer = 0; }
    exit;
}
if (intro_state == "scene3_wait") {
    intro_timer++;
    if (keyboard_check_pressed(vk_enter)) { intro_state = "scene3_fade_out"; intro_timer = 0; fade_alpha = 0; }
    exit;
}
if (intro_state == "scene3_fade_out") {
    intro_timer++;
    fade_alpha = min(1, intro_timer / (_fps * 0.35));
    if (fade_alpha >= 1) { intro_state = "scene_fade_in"; cutscene_index = 4; previous_scene = 2; intro_timer = 0; fade_alpha = 0; }
    exit;
}
if (intro_state == "scene_fade_in") {
    intro_timer++;
    fade_alpha = min(1, intro_timer / (_fps * 0.4));
    if (fade_alpha >= 1) { intro_state = "scene_wait"; previous_scene = cutscene_index; intro_timer = 0; }
    exit;
}
if (intro_state == "scene_wait") {
    intro_timer++;
    if (keyboard_check_pressed(vk_enter)) {
        if (cutscene_index < 7) {
            if (cutscene_index == 5) audio_play_sound(play_after_5_in_intro, 1, false);
            previous_scene = cutscene_index;
            cutscene_index++;
            intro_state = "scene_fade_in";
            intro_timer = 0;
            fade_alpha = 0;
        } else {
            intro_state = "zoom_sequence";
            zoom_index = 8;
            intro_timer = 0;
        }
    }
    exit;
}
if (intro_state == "zoom_sequence") {
    intro_timer++;
    if (intro_timer >= _fps) {
        intro_timer = 0;
        zoom_index++;
        if (zoom_index >= 14) { zoom_index = 14; intro_state = "zoom_wait"; }
    }
    exit;
}
if (intro_state == "zoom_wait") {
    intro_timer++;
    if (keyboard_check_pressed(vk_enter)) { intro_state = "scene15_wait"; intro_timer = 0; }
    exit;
}
if (intro_state == "scene15_wait") {
    intro_timer++;
    if (keyboard_check_pressed(vk_enter)) { intro_state = "blink_close"; intro_timer = 0; blink_frame = 14; }
    exit;
}
if (intro_state == "blink_close") {
    intro_timer++;
    blink_frame = max(0, 14 - floor(intro_timer * 5 / _fps));
    if (intro_timer >= _fps * 3) {
        intro_state = "final_card";
        intro_timer = 0;
        blink_frame = 0;
        if (global.gameplay_music_handle != -1 && audio_is_playing(global.gameplay_music_handle)) {
            audio_sound_gain(global.gameplay_music_handle, 0, 800);
        }
    }
    exit;
}
if (intro_state == "final_card") {
    intro_timer++;
    if (intro_timer >= _fps * 3) {
        intro_state = "fade_game";
        intro_timer = 0;
        fade_alpha = 0;
        if (global.gameplay_music_handle != -1 && audio_is_playing(global.gameplay_music_handle)) {
            audio_sound_gain(global.gameplay_music_handle, 1, 800);
        }
        if (global.intro_hum_handle != -1 && audio_is_playing(global.intro_hum_handle)) {
            audio_sound_gain(global.intro_hum_handle, 0, 800);
        }
    }
    exit;
}
if (intro_state == "fade_game") {
    intro_timer++;
    fade_alpha = min(1, intro_timer / (_fps * 0.5));
    if (fade_alpha >= 1) {
        global.intro_game_fade = 1;
        room_goto(Starting_Room);
    }
    exit;
}
if (intro_state != "challenge" || challenge_complete) exit;

// The button is drawn in room coordinates, so input uses room-space mouse positions too.
var _mx = mouse_x;
var _my = mouse_y;
var _grid_left = x + (sprite_get_width(sprite_index) * image_xscale - challenge_cols * challenge_cell) / 2;
var _grid_top = y + (sprite_get_height(sprite_index) * image_yscale - challenge_rows * challenge_cell) / 2;
var _source_y = room_height / 2 - challenge_cell / 2;

// Pick up only an occupied source tile and remember which tile the cursor grabbed.
if (mouse_check_button_pressed(mb_left) && dragging_shape < 0) {
    for (var _s = 0; _s < array_length(challenge_shapes); _s++) {
        var _source_x = (_s == 0) ? room_width / 2 - 500 : room_width / 2 + 360;
        for (var _i = 0; _i < array_length(challenge_shapes[_s]); _i++) {
            var _tile_x = challenge_shapes[_s][_i][0];
            var _tile_y = challenge_shapes[_s][_i][1];
            var _tile_left = _source_x + _tile_x * challenge_cell;
            var _tile_top = _source_y + _tile_y * challenge_cell;
            if (point_in_rectangle(_mx, _my, _tile_left, _tile_top, _tile_left + challenge_cell, _tile_top + challenge_cell)) {
                dragging_shape = _s;
                audio_play_sound(Sound_for_picking_up_a_block, 1, false);
                drag_grab_cell_x = _tile_x;
                drag_grab_cell_y = _tile_y;
                break;
            }
        }
        if (dragging_shape >= 0) break;
    }
}

// Snap the grabbed tile to the cell under the cursor. Preview and drop share this math.
if (dragging_shape >= 0 && mouse_check_button_released(mb_left)) {
    audio_play_sound(Sound_for_placing_down_a_block, 1, false);
    var _grab_grid_x = floor((_mx - _grid_left) / challenge_cell);
    var _grab_grid_y = floor((_my - _grid_top) / challenge_cell);
    var _shape_left = _grab_grid_x - drag_grab_cell_x;
    var _shape_top = _grab_grid_y - drag_grab_cell_y;
    for (var _i = 0; _i < array_length(challenge_shapes[dragging_shape]); _i++) {
        var _gx = _shape_left + challenge_shapes[dragging_shape][_i][0];
        var _gy = _shape_top + challenge_shapes[dragging_shape][_i][1];
        if (_gx >= 0 && _gx < challenge_cols && _gy >= 0 && _gy < challenge_rows && challenge_hp[_gx][_gy] > 0) challenge_hp[_gx][_gy] = 0;
    }

    dragging_shape = -1;
    var _alive = false;
    for (var _x = 0; _x < challenge_cols; _x++) for (var _y = 0; _y < challenge_rows; _y++) if (challenge_hp[_x][_y] > 0) _alive = true;
    if (!_alive) {
        challenge_complete = true;
        challenge_active = false;
        intro_state = "fade_black";
        fade_alpha = 0;
        intro_timer = 0;
    }
}
