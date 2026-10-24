if (!challenge_active && !challenge_complete) {
    challenge_active = true;
    intro_state = "challenge";
    shake_timer = 90;
    rumble_sound_handle = audio_play_sound(rumble_for_when_the_start_button_is_shaking, 1, false);
    rumble_fade_timer = ceil(max(1, game_get_speed(gamespeed_fps)) * 4.412);
    rumble_fade_started = false;
    image_speed = 0;
    image_blend = c_white;
}
