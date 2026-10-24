// player's health grid
grid_width = 3;
grid_height = 3;



// 2D array
// 1 = healthy cell, 0 = empty slot, -1 = damaged cell
for (var _x = 0; _x < grid_width; _x++) {
    for (var _y = 0; _y < grid_height; _y++) {
        hp_grid[_x][_y] = 1; 
    }
}

// Set drawing variables for later
cell_size = 32; // Size of each grid square in pixels

move_speed = 4;

global.combat_active = false;
global.target_enemy = noone;
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
    ["dot", "treasure", "dot", "treasure", "triangle", "boss"],
    ["triangle", "treasure", "square", "treasure", "square", "boss"],
    ["square", "treasure", "circle", "treasure", "circle", "boss"]
];
trial_deck = trial_decks[dungeon_index];
dungeon_title_timer = 0;

current_room_type = "start";
