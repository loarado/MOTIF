var _perpendicular = attack_direction + 90;
var _half_width = blade_width / 2;
var _tip_x = x + lengthdir_x(blade_length, attack_direction);
var _tip_y = y + lengthdir_y(blade_length, attack_direction);
var _side_x = lengthdir_x(_half_width, _perpendicular);
var _side_y = lengthdir_y(_half_width, _perpendicular);

var _base_left_x = x + _side_x;
var _base_left_y = y + _side_y;
var _base_right_x = x - _side_x;
var _base_right_y = y - _side_y;
var _tip_left_x = _tip_x + _side_x;
var _tip_left_y = _tip_y + _side_y;
var _tip_right_x = _tip_x - _side_x;
var _tip_right_y = _tip_y - _side_y;

draw_set_color(c_aqua);
draw_primitive_begin(pr_trianglefan);
draw_vertex(_base_left_x, _base_left_y);
draw_vertex(_base_right_x, _base_right_y);
draw_vertex(_tip_right_x, _tip_right_y);
draw_vertex(_tip_left_x, _tip_left_y);
draw_primitive_end();

draw_set_color(c_white);
