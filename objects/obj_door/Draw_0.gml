if (locked) {
    image_blend = c_red;
} else {
    image_blend = c_lime;
}
draw_self();

// Draw the current Room Counter at the top-left of the screen
if (instance_exists(Player)) {
    draw_set_color(c_black);
    draw_text_transformed(48, 48, Player.dungeon_names[Player.dungeon_index], 2, 2, 0);
    draw_text_transformed(48, 84, "ROOM: " + string(Player.trial_step) + " / " + string(array_length(Player.trial_deck)) + " (" + string_upper(Player.current_room_type) + ")", 2, 2, 0);
    draw_set_color(c_white);
}
