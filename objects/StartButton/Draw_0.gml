draw_self();
if (!challenge_active) exit;

var _grid_left = x + (sprite_get_width(sprite_index) * image_xscale - challenge_cols * challenge_cell) / 2;
var _grid_top = y + (sprite_get_height(sprite_index) * image_yscale - challenge_rows * challenge_cell) / 2;
var _source_y = room_height / 2 - challenge_cell / 2;

// Remaining button tiles.
for (var _x = 0; _x < challenge_cols; _x++) {
    for (var _y = 0; _y < challenge_rows; _y++) {
        if (challenge_hp[_x][_y] > 0) {
            var _cell_left = _grid_left + _x * challenge_cell;
            var _cell_top = _grid_top + _y * challenge_cell;
            draw_set_alpha(0.65); draw_set_color(c_dkgray);
            draw_rectangle(_cell_left, _cell_top, _cell_left + challenge_cell - 2, _cell_top + challenge_cell - 2, true);
            draw_set_alpha(1); draw_set_color(c_white);
            draw_rectangle(_cell_left, _cell_top, _cell_left + challenge_cell - 2, _cell_top + challenge_cell - 2, false);
        }
    }
}

draw_set_alpha(1); draw_set_color(c_white);
draw_text_transformed(x + sprite_get_width(sprite_index) * image_xscale / 2 - 525, y + sprite_get_height(sprite_index) * image_yscale / 2 + 200, "DRAG THE SHAPES INTO THE GRID TO START", 3, 3, 0);

var _grab_grid_x = floor((mouse_x - _grid_left) / challenge_cell);
var _grab_grid_y = floor((mouse_y - _grid_top) / challenge_cell);
for (var _s = 0; _s < array_length(challenge_shapes); _s++) {
    var _source_x = (_s == 0) ? room_width / 2 - 500 : room_width / 2 + 360;
    var _shape_left = _source_x;
    var _shape_top = _source_y;
    if (dragging_shape == _s) {
        _shape_left = _grid_left + (_grab_grid_x - drag_grab_cell_x) * challenge_cell;
        _shape_top = _grid_top + (_grab_grid_y - drag_grab_cell_y) * challenge_cell;
    }

    for (var _i = 0; _i < array_length(challenge_shapes[_s]); _i++) {
        var _tile_x = challenge_shapes[_s][_i][0];
        var _tile_y = challenge_shapes[_s][_i][1];
        var _draw_x = _shape_left + _tile_x * challenge_cell;
        var _draw_y = _shape_top + _tile_y * challenge_cell;

        if (dragging_shape == _s) {
            var _target_x = _grab_grid_x - drag_grab_cell_x + _tile_x;
            var _target_y = _grab_grid_y - drag_grab_cell_y + _tile_y;
            var _valid = _target_x >= 0 && _target_x < challenge_cols && _target_y >= 0 && _target_y < challenge_rows;
            if (_valid) _valid = challenge_hp[_target_x][_target_y] > 0;
            draw_set_alpha(0.45);
            draw_set_color(_valid ? c_white : c_gray);
            draw_rectangle(_draw_x, _draw_y, _draw_x + challenge_cell - 2, _draw_y + challenge_cell - 2, true);
            draw_set_alpha(1);
            draw_rectangle(_draw_x, _draw_y, _draw_x + challenge_cell - 2, _draw_y + challenge_cell - 2, false);
        } else {
            draw_set_color(c_white);
            draw_rectangle(_draw_x, _draw_y, _draw_x + challenge_cell - 2, _draw_y + challenge_cell - 2, false);
            draw_set_color(c_white);
            draw_rectangle(_draw_x, _draw_y, _draw_x + challenge_cell - 2, _draw_y + challenge_cell - 2, true);
        }
    }
}

/*if (dragging_shape >= 0) {
        draw_set_color(c_white);
    draw_text_transformed(x + sprite_get_width(sprite_index) * image_xscale / 2, y + sprite_get_height(sprite_index) * image_yscale / 2 + 130, "DROP SHAPE ON GRID", 2, 2, 0);
}*/
draw_set_alpha(1); draw_set_color(c_white);
