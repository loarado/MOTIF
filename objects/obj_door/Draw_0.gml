if (locked) {
    image_blend = c_red;
} else {
    image_blend = c_lime;
}
draw_self();

// Draw the current Room Counter at the top-left of the screen
if (instance_exists(Player)) {
    draw_set_color(c_white);
    draw_text(48, 48, "ROOM: " + string(Player.trial_step) + " / " + string(array_length(Player.trial_deck)) + " (" + string_upper(Player.current_room_type) + ")");
}