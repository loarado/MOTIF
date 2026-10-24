draw_self();
if (boss_phase == "telegraph") {
    var _left = (boss_corner mod 2 == 0); var _top = (boss_corner < 2);
    var _x1 = _left ? 0 : room_width / 2; var _x2 = _left ? room_width / 2 : room_width;
    var _y1 = _top ? 0 : room_height / 2; var _y2 = _top ? room_height / 2 : room_height;
    var _telegraph_progress = 1 - boss_warning_timer / max(1, boss_warning_max);
    draw_set_color(c_red); draw_set_alpha(0.08 + 0.16 * _telegraph_progress);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    draw_set_alpha(0.28); draw_set_color(c_red); draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_alpha(1); draw_set_color(c_white);
}
