var _center_x = x + lengthdir_x(blade_length / 2, attack_direction);
var _center_y = y + lengthdir_y(blade_length / 2, attack_direction);
var _scale_x = blade_width / sprite_get_width(spr_sword);
var _scale_y = blade_length / sprite_get_height(spr_sword);
draw_sprite_ext(spr_sword, image_index, _center_x, _center_y,
    _scale_x, _scale_y, attack_direction + 90, c_white, 1);
