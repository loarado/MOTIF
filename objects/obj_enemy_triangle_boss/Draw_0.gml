draw_self();
if (boss_phase == "telegraph") {
    var _cx = x;
    var _cy = y;
    var _r = sprite_get_width(sprite_index) * image_xscale / 2;
    draw_set_color(c_red);
    draw_set_alpha(0.4 + 0.6 * (1 - boss_warning_timer / boss_warning_max));
    for (var _side = 0; _side < 3; _side++) {
        var _a = -90 + image_angle + _side * 120;
        var _x1 = _cx + lengthdir_x(_r, _a); var _y1 = _cy + lengthdir_y(_r, _a);
        var _x2 = _cx + lengthdir_x(_r, _a + 120); var _y2 = _cy + lengthdir_y(_r, _a + 120);
        draw_line_width(_x1, _y1, _x2, _y2, 10);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
}
