var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _fps = max(1, game_get_speed(gamespeed_fps));
var _two_frame = floor(intro_timer * 5 / _fps);

// Fade the complete title room to black after the Start challenge is defeated.
if (intro_state == "fade_black") {
    draw_set_alpha(fade_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    exit;
}

if (intro_state == "skip_game_fade") {
    draw_set_alpha(fade_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    exit;
}

if (intro_state == "blink_open") {
    draw_sprite_ext(_1_blank_paper, 0, 0, 0, 1, 1, 0, c_white, 1);
    draw_sprite_ext(blink_animation, blink_frame, 0, 0, 1, 1, 0, c_white, 1);
    exit;
}
if (intro_state == "paper_wait") {
    draw_sprite_ext(_1_blank_paper, 0, 0, 0, 1, 1, 0, c_white, 1);
    exit;
}
if (intro_state == "scene2_fade" || intro_state == "scene2_wait") {
    draw_sprite_ext(_1_blank_paper, 0, 0, 0, 1, 1, 0, c_white, 1);
    var _door_frame = _two_frame mod sprite_get_number(_2_blank_door);
    var _door_alpha = (intro_state == "scene2_fade") ? fade_alpha : 1;
    draw_sprite_ext(_2_blank_door, _door_frame, 0, 0, 1, 1, 0, c_white, _door_alpha);
    exit;
}
if (intro_state == "scene3_fade_in" || intro_state == "scene3_wait" || intro_state == "scene3_fade_out") {
    draw_sprite_ext(_1_blank_paper, 0, 0, 0, 1, 1, 0, c_white, 1);
    var _door_frame = _two_frame mod sprite_get_number(_2_blank_door);
    draw_sprite_ext(_2_blank_door, _door_frame, 0, 0, 1, 1, 0, c_white, 1);
    var _question_frame = _two_frame mod sprite_get_number(_3_what_happened);
    var _question_alpha = 1;
    if (intro_state == "scene3_fade_in") _question_alpha = fade_alpha;
    if (intro_state == "scene3_fade_out") _question_alpha = 1 - fade_alpha;
    draw_sprite_ext(_3_what_happened, _question_frame, 0, 0, 1, 1, 0, c_white, _question_alpha);
    exit;
}
if (intro_state == "scene_fade_in" || intro_state == "scene_wait") {
    draw_sprite_ext(_1_blank_paper, 0, 0, 0, 1, 1, 0, c_white, 1);
    var _door_frame = _two_frame mod sprite_get_number(_2_blank_door);
    draw_sprite_ext(_2_blank_door, _door_frame, 0, 0, 1, 1, 0, c_white, 1);

    var _scene_sprites = [_4_Tessa, _5_Tessa_Talkin, _6_Tessa_startled, _7_Tessa_Remembers];
    if (previous_scene >= 4) {
        var _previous_sprite = _scene_sprites[previous_scene - 4];
        var _previous_frame = _two_frame mod sprite_get_number(_previous_sprite);
        draw_sprite_ext(_previous_sprite, _previous_frame, 0, 0, 1, 1, 0, c_white, 1);
    }
    if (intro_state == "scene_fade_in") {
        var _current_sprite = _scene_sprites[cutscene_index - 4];
        var _current_frame = _two_frame mod sprite_get_number(_current_sprite);
        draw_sprite_ext(_current_sprite, _current_frame, 0, 0, 1, 1, 0, c_white, fade_alpha);
    }
    exit;
}
if (intro_state == "zoom_sequence" || intro_state == "zoom_wait") {
    var _zoom_sprites = [_8_zoom_initial, _9_zoom, _10_zoom, _11_zoom, _12_zoom, _13_zoom, _14_finalzoom];
    var _zoom_sprite = _zoom_sprites[zoom_index - 8];
    var _zoom_frame = _two_frame mod sprite_get_number(_zoom_sprite);
    draw_sprite_ext(_zoom_sprite, _zoom_frame, 0, 0, 1, 1, 0, c_white, 1);
    exit;
}
if (intro_state == "scene15_wait") {
    var _last_scene_frame = _two_frame mod sprite_get_number(_15_volcano_quip);
    draw_sprite_ext(_15_volcano_quip, _last_scene_frame, 0, 0, 1, 1, 0, c_white, 1);
    exit;
}
if (intro_state == "blink_close") {
    var _last_scene_frame = _two_frame mod sprite_get_number(_15_volcano_quip);
    draw_sprite_ext(_15_volcano_quip, _last_scene_frame, 0, 0, 1, 1, 0, c_white, 1);
    draw_sprite_ext(blink_animation, blink_frame, 0, 0, 1, 1, 0, c_white, 1);
    exit;
}
if (intro_state == "final_card" || intro_state == "fade_game") {
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    var _card_alpha = min(1, intro_timer / (_fps * 0.35));
    draw_set_alpha(_card_alpha);
    draw_text_transformed(_gui_w / 2, _gui_h / 2, "YOUR PATTERN IS THE KEY FORWARD", 2, 2, 0);
    draw_set_alpha(1);
    if (intro_state == "fade_game") {
        draw_set_alpha(fade_alpha);
        draw_set_color(c_black);
        draw_rectangle(0, 0, _gui_w, _gui_h, false);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
