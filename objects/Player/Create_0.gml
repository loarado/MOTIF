// player's health grid
if (!variable_global_exists("intro_game_fade")) global.intro_game_fade = 0;
if (!variable_global_exists("hard_mode")) global.hard_mode = false;
if (!variable_global_exists("start_trial_on_enter")) global.start_trial_on_enter = false;
if (!variable_global_exists("first_enemy_attack_done")) global.first_enemy_attack_done = false;
if (!variable_global_exists("gameplay_music_handle")) global.gameplay_music_handle = -1;
if (!variable_global_exists("intro_hum_handle")) global.intro_hum_handle = -1;
if (!variable_global_exists("boss_music_handle")) global.boss_music_handle = -1;
if (!variable_global_exists("boss_music_active")) global.boss_music_active = false;
if (!variable_global_exists("boss_music_fading")) global.boss_music_fading = false;
if (!variable_global_exists("boss_music_fade_timer")) global.boss_music_fade_timer = 0;
if (!variable_global_exists("dev_god_mode")) global.dev_god_mode = false;
if (!variable_global_exists("trial_777_count")) global.trial_777_count = 0;
if (!variable_global_exists("trial_777_timer")) global.trial_777_timer = 0;
if (!variable_global_exists("ending_state")) global.ending_state = "none";
if (!variable_global_exists("ending_timer")) global.ending_timer = 0;
if (!variable_global_exists("ending_alpha")) global.ending_alpha = 0;
if (!variable_global_exists("ending_blink_frame")) global.ending_blink_frame = 14;
if (!variable_global_exists("ending_fanfare_handle")) global.ending_fanfare_handle = -1;
if (global.gameplay_music_handle == -1 || !audio_is_playing(global.gameplay_music_handle)) {
    global.gameplay_music_handle = audio_play_sound(play_in_intro_sequences_1_2_3_4_5_then_15_and_throughout_gameplay, 0, true);
}
grid_width = 3;
grid_height = 3;



// 2D array
// 1 = healthy cell, 0 = empty slot, -1 = damaged cell
for (var _x = 0; _x < grid_width; _x++) {
    for (var _y = 0; _y < grid_height; _y++) {
        hp_grid[_x][_y] = 1; 
        hp_max_grid[_x][_y] = 1;
    }
}

// Set drawing variables for later
cell_size = 32; // Size of each grid square in pixels

move_speed = 4;

// Keep the existing collision footprint while using the directional character sprites.
mask_index = playerTestSprite;
player_facing = "front";
player_walking = false;
sprite_index = front_idle_player;
image_index = 0;
image_speed = 0;

global.combat_active = false;
global.target_enemy = noone;
global.game_beaten = false;
points = 0;
attack_cooldown = 0;
attack_miss_cooldown = 12;
attack_hit_cooldown = 180;
combat_timer = 0;
invincibility_timer = 0;
invincibility_duration = 60;

// Define a 2-block horizontal attack pattern
my_attack_pattern = [
    [0, 0],
    [1, 0]
];

// Dragging state variables
is_dragging = false;
drag_offset_x = 0;
drag_offset_y = 0;
damage_indicator_cells = [];
damage_indicator_timer = 0;
boss_telegraph_cells = [];
boss_telegraph_timer = 0;
boss_telegraph_max_timer = 0;
boss_telegraph_kind = "";
first_attack_hint_active = false;
attack_upgrade_active = false;
attack_upgrade_dragging = false;
attack_upgrade_drag_offset_x = 0;
attack_upgrade_drag_offset_y = 0;
attack_upgrade_target_x = 0;
attack_upgrade_target_y = 0;
attack_upgrade_has_target = false;

// ==========================================
// TRIAL SEQUENCE & DECK GENERATION
// ==========================================
trial_step = 0; // 0 = Starting Room / Tutorial Dummy
dungeon_index = 0;
dungeon_names = ["TRIANGLE DUNGEON", "SQUARE DUNGEON", "CIRCLE DUNGEON"];
trial_decks = [
    ["dot", "treasure", "dot", "triangle", "treasure", "dot", "triangle", "treasure", "boss"],
    ["triangle", "treasure", "square", "triangle", "treasure", "square", "treasure", "square", "boss"],
    ["square", "treasure", "circle", "square", "treasure", "circle", "treasure", "circle", "boss"]
];
trial_deck = trial_decks[dungeon_index];
dungeon_title_timer = 0;

current_room_type = "start";

// Entering Game_Test from the hub automatically starts its first encounter.
if (global.start_trial_on_enter && room == Game_Test) {
    global.start_trial_on_enter = false;
    trial_step = 1;
    current_room_type = trial_deck[0];
    var _cx = room_width / 2;
    var _cy = room_height / 2;
    var _initial_enemy_object = noone;
    if (current_room_type == "dot") _initial_enemy_object = obj_enemy_dot;
    else if (current_room_type == "triangle") _initial_enemy_object = obj_enemy_triangle;
    else if (current_room_type == "square") _initial_enemy_object = obj_enemy_square;
    else if (current_room_type == "circle") _initial_enemy_object = obj_enemy_circle;
    if (_initial_enemy_object != noone) {
        var _enemy_count = global.hard_mode ? ((dungeon_index == 1) ? 2 : ((dungeon_index == 2) ? 3 : 1)) : 1;
        for (var _i = 0; _i < _enemy_count; _i++) {
            var _spawn_x = _cx;
            var _spawn_y = _cy;
            if (_enemy_count == 2) _spawn_x += (_i == 0) ? -128 : 128;
            else if (_enemy_count == 3) {
                _spawn_x += (_i == 0) ? 0 : ((_i == 1) ? -128 : 128);
                _spawn_y += (_i == 0) ? -96 : 80;
            }
            instance_create_layer(_spawn_x, _spawn_y, layer, _initial_enemy_object);
        }
    }
}
