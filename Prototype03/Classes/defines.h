//
//  defines.h
//  Prototype03
//
//  Created by Cody Sandel on 3/20/11.
//  Copyright 2011 Cody Sandel. All rights reserved.
//

//
// version info
//
#define VERSION_STRING @"v1.0 "

//
// resources defines
//
#define FONT_DEFAULT @"LetterGothicStd.otf"
#define FONT_LETTER_GOTHIC @"LetterGothicStd.otf"
#define FONT_COLOR_DEFAULT ccc3(253, 255, 221)
#define FONT_COLOR_HIGHLIGHT ccc3(2, 0, 34)
#define FONT_COLOR_HIGHLIGHT_BACKGROUND ccc3(253, 255, 221)

//
// sounds
//
#define SFX_MENU_CLICK @"sfx_menu_click.wav.enc"
#define SFX_REVERSE_POLARITY @"sfx_reverse_polarity.wav.enc"
#define SFX_TOWER_HIT @"sfx_tower_hit.wav.enc"
#define SFX_TOWER_SPUTTER @"sfx_tower_sputter.wav.enc"
#define SFX_TOWER_EXPLODE @"sfx_tower_explode.wav.enc"
#define SFX_POWERUP @"sfx_powerup.wav.enc"
#define SFX_SOLDIER_DEATH @"sfx_soldier_death.wav.enc"
#define SFX_FACTORY_DEATH @"sfx_factory_death.wav.enc"
#define SFX_BARRIER_DEATH @"sfx_barrier_death.wav.enc"
#define SFX_TIMER_WARNING @"sfx_time_warning.wav.enc"

#define SFX_MENU_CLICK_GAIN 0.8f
#define SFX_REVERSE_POLARITY_GAIN 0.2f
#define SFX_TOWER_HIT_GAIN 0.2f
#define SFX_TOWER_SPUTTER_GAIN 0.075f
#define SFX_TOWER_EXPLODE_GAIN 0.05f
#define SFX_POWERUP_GAIN 0.1f
#define SFX_SOLDIER_DEATH_GAIN 0.3f
#define SFX_FACTORY_DEATH_GAIN 0.3f
#define SFX_BARRIER_DEATH_GAIN 0.075f
#define SFX_TIMER_WARNING_GAIN 0.4f

//
// group defines
#define GROUP_INVISIBLE_WALL    1
#define GROUP_ENEMY_DROP        2

// players are in the range of 100-199
#define GROUP_PLAYERS           100

// soldiers are in the range 200-299
#define GROUP_SOLDIERS          200

// laser towers are in the range 300-399
#define GROUP_LASER_TOWERS      300

// soldier factories are in the range 400-499
#define GROUP_SOLDIER_FACTORIES 400

// laser emitter id's are in the range 500-599
#define GROUP_LASER_EMITTERS    500

//
// collision types
//
#define COLLISION_TYPE_LASER                    1
#define COLLISION_TYPE_INVISIBLE_WALL           2
#define COLLISION_TYPE_ENEMY_DROP               3

// player collision types are 100-199
#define COLLISION_TYPE_PLAYER                   100

// soldier collision types are 200 - 299
#define COLLISION_TYPE_SOLDIER                  200
#define COLLISION_TYPE_SOLDIER_SPAWN_SENSOR     201

// laser collision types are 300-399
#define COLLISION_TYPE_LASER_TOWER              300

// soldier factory collision types are 400-499
#define COLLISION_TYPE_SOLDIER_FACTORY          400
#define COLLISION_TYPE_WALL_FILL                401
#define COLLISION_TYPE_WALL_END                 402
#define COLLISION_TYPE_BARRIER                  403

//
// layer mask
//
#define LAYER_MASK_GENERAL                          0x00000001 // general play area
#define LAYER_MASK_LASER_TOWER_BOTTOM_LEFT          0x00000002 // layer for laser towers
#define LAYER_MASK_LASER_TOWER_BOTTOM_RIGHT         0x00000004
#define LAYER_MASK_LASER_TOWER_TOP_LEFT             0x00000008
#define LAYER_MASK_LASER_TOWER_TOP_RIGHT            0x00000010
#define LAYER_MASK_LASER_TOWER_LEFT_BOTTOM          0x00000020
#define LAYER_MASK_LASER_TOWER_LEFT_TOP             0x00000040
#define LAYER_MASK_LASER_TOWER_RIGHT_BOTTOM         0x00000080
#define LAYER_MASK_LASER_TOWER_RIGHT_TOP            0x00000100
#define LAYER_MASK_INSIDE_INVISIBLE_WALL_BOTTOM     0x00000200 // inside invisible walls
#define LAYER_MASK_INSIDE_INVISIBLE_WALL_LEFT       0x00000400
#define LAYER_MASK_INSIDE_INVISIBLE_WALL_TOP        0x00000800
#define LAYER_MASK_INSIDE_INVISIBLE_WALL_RIGHT      0x00001000
#define LAYER_MASK_OUTSIDE_INVISIBLE_WALL_BOTTOM    0x00002000 // outside invisible walls
#define LAYER_MASK_OUTSIDE_INVISIBLE_WALL_LEFT      0x00004000
#define LAYER_MASK_OUTSIDE_INVISIBLE_WALL_TOP       0x00008000
#define LAYER_MASK_OUTSIDE_INVISIBLE_WALL_RIGHT     0x00010000
#define LAYER_MASK_SOLDIERS                         0x00020000 // soldiers collision layer
#define LAYER_MASK_ENEMY_DROPS                      0x00040000 // enemy drop collision layer
#define LAYER_MASK_PLAYER_LASER_COLLIDERS           0x00080000 // laser colliders associated with player ships

// layer mask groups
#define LAYER_MASK_ALL               0xFFFFFFFF // all of the layers
#define LAYER_MASK_INSIDE_INVISIBLE_WALLS (LAYER_MASK_INSIDE_INVISIBLE_WALL_BOTTOM | \
                                           LAYER_MASK_INSIDE_INVISIBLE_WALL_LEFT   | \
                                           LAYER_MASK_INSIDE_INVISIBLE_WALL_TOP    | \
                                           LAYER_MASK_INSIDE_INVISIBLE_WALL_RIGHT)

#define LAYER_MASK_OUTSIDE_INVISIBLE_WALLS (LAYER_MASK_OUTSIDE_INVISIBLE_WALL_BOTTOM | \
                                            LAYER_MASK_OUTSIDE_INVISIBLE_WALL_LEFT   | \
                                            LAYER_MASK_OUTSIDE_INVISIBLE_WALL_TOP    | \
                                            LAYER_MASK_OUTSIDE_INVISIBLE_WALL_RIGHT)

#define LAYER_MASK_LASER_TOWERS (LAYER_MASK_LASER_TOWER_BOTTOM_LEFT  | \
                                 LAYER_MASK_LASER_TOWER_BOTTOM_RIGHT | \
                                 LAYER_MASK_LASER_TOWER_TOP_LEFT     | \
                                 LAYER_MASK_LASER_TOWER_TOP_RIGHT    | \
                                 LAYER_MASK_LASER_TOWER_LEFT_BOTTOM  | \
                                 LAYER_MASK_LASER_TOWER_LEFT_TOP     | \
                                 LAYER_MASK_LASER_TOWER_RIGHT_BOTTOM | \
                                 LAYER_MASK_LASER_TOWER_RIGHT_TOP)


//
// sprite sheet indicies for sprites
//

// spriteSheet00 batch nodes
#define SPRITEBATCHNODE_INDEX_SPAWN                 0
#define SPRITEBATCHNODE_INDEX_PLAYFIELD_02          1
#define SPRITEBATCHNODE_INDEX_PLAYFIELD_03          2
#define SPRITEBATCHNODE_INDEX_PLAYFIELD_04          3
#define SPRITEBATCHNODE00_COUNT                     4

// spriteSheet01 batch nodes
#define SPRITEBATCHNODE_INDEX_PATHING               4
#define SPRITEBATCHNODE_INDEX_PLAYFIELD_01          5
#define SPRITEBATCHNODE_INDEX_HUD_LOW               6
#define SPRITEBATCHNODE_INDEX_HUD_HIGH              7
#define SPRITEBATCHNODE_INDEX_TERMINAL_MAIN_MENU    8
#define SPRITEBATCHNODE01_COUNT                     5

//
// z ordering
//

// layer break down
#define ZORDER_STAGE_LAYER          0
#define ZORDER_MENU_LAYER           1

// menu layer break down
#define ZORDER_SPRITEBATCHNODE_TERMINAL_MAIN_MENU   0
#define ZORDER_MENU_SLIDER_BAR                      1
#define ZORDER_MENU_SLIDER_KNOB                     2

// stage layer break down
#define ZORDER_BACKGROUND                           0
#define ZORDER_SPRITEBATCHNODE_PATHING              1
#define ZORDER_SPRITEBATCHNODE_SPAWN                2
#define ZORDER_SPRITEBATCHNODE_PLAYFIELD_01         3
#define ZORDER_SOLDIER_SPAWN_HEALTH_BAR             4
#define ZORDER_SF_SPAWN_HEALTH_BAR                  5
#define ZORDER_TRIANGLE_STRIP_PARTICLE_BATCH_NODE   6
#define ZORDER_SPRITEBATCHNODE_PLAYFIELD_02         7
#define ZORDER_SOLDIER_HEALTH_BAR                   8
#define ZORDER_SPRITEBATCHNODE_PLAYFIELD_03         9
#define ZORDER_SF_HEALTH_BAR                        10
#define ZORDER_SPRITEBATCHNODE_PLAYFIELD_04         11
#define ZORDER_GEAR_SWITCH_BASE                     12
#define ZORDER_SPRITEBATCHNODE_HUD_LOW              14
#define ZORDER_SCORE_TEXT                           15
#define ZORDER_WAVE_TIMER_PROGRESS                  16
#define ZORDER_SPRITEBATCHNODE_HUD_HIGH             17

// sprite batch node break down
#define ZORDER_PATH_SPRITE_PARTICLE     0       // path sprite stuff
#define ZORDER_PATH_SPRITE_LOW          1
#define ZORDER_PATH_SPRITE_HIGH         2
#define ZORDER_PATH_SPRITE_END          3
#define ZORDER_WAYPOINT                 4
#define ZORDER_SF_ATTACK_STREAM         5       // soldier factory attack stuff
#define ZORDER_SF_ATTACK_CENTER         6

#define ZORDER_MASTER_CONTROL_SWITCH    7       // master control switches that sit on the edges

#define ZORDER_LASER_START_PARTICLE     100     // laser stuff
#define ZORDER_LASER_END_SPARK          101
#define ZORDER_LASER_END                102
#define ZORDER_LASER_SWITCH_PARTICLE    103

#define ZORDER_SOLDIER                  200     // soldier stuff
#define ZORDER_SOLDIER_EXPLOSION        201

#define ZORDER_WALL_END                 300     // soldier factory stuff
#define ZORDER_WALL_FILL                301
#define ZORDER_BARRIER                  302
#define ZORDER_SF_BASE                  303
#define ZORDER_SF_CENTER                304
#define ZORDER_SF_GEAR_SHADOW           305
#define ZORDER_SF_GEAR                  306
#define ZORDER_SF_EXPLOSION             307
#define ZORDER_SF_ATTACK_BASE           308

#define ZORDER_LASER_TOWER              400     // laser tower stuff
#define ZORDER_LASER_HEALTH_ICON        401

#define ZORDER_PLAYER_SHIP              500     // player ship stuff
#define ZORDER_PLAYER_LED_RED           501
#define ZORDER_PLAYER_LED_GREEN         501
#define ZORDER_PLAYER_GEAR_SHADOW       502
#define ZORDER_PLAYER_GEAR              503
#define ZORDER_PLAYER_SHIP_GEAR_SWITCH  504

#define ZORDER_GEAR_EXPLOSION           600     // laser tower explosion, this overlays the player ship

#define ZORDER_ENEMY_DROP               700     // enemy drops
#define ZORDER_ED_ACTIVATED_ANIMATION   701

#define ZORDER_HUD                      1000    // hud stuff
#define ZORDER_TERMINAL                 1001
#define ZORDER_TERMINAL_EDGE_LEFT       1002
#define ZORDER_TERMINAL_EDGE_RIGHT      1003
#define ZORDER_TERMINAL_MIDDLE          1004
#define ZORDER_WAVE_TIMER_BACKING       1003
#define ZORDER_WAVE_TIMER_OVERLAY       1004

//
// tower damage
//
#define LASER_TOWER_MAX_HEALTH      3   
#define LASER_TOWER_DEFAULT_DAMAGE  1 // this is damage taken by enemies, not damage this guy outputs

//
// default color state
//
#define kColorStateDefault  kColorStateUnknown+1

//
// leaderboard categories
//
#define kLeaderBoardCategorySurvial01 @"grp.kLeaderBoardCategorySurvial01"

//
// ColorState
//
typedef enum {
    kColorStateUnknown  = -1,
    kColorStateWhite    =  0,
    kColorStateBlack    =  1,
    kColorStateCount    =  2
} ColorState;

//
// enum SoldierState
//
typedef enum {
    kSoldierStateUnknown    = -1,
    kSoldierStateQueued     =  0,
    kSoldierStateSpawning   =  1,
    kSoldierStateAlive      =  2,
    kSoldierStateRotating   =  3,
    kSoldierStateDead       =  4,
    kSoldierStateCount      =  5
} SoldierState;

//
// enum SoldierSubState
//
typedef enum {
    kSoldierSubStateUnknown     = -1,
    kSoldierSubStateIdle        =  0,
    kSoldierSubStateNormal      =  1,
    kSoldierSubStateRotating    =  2,
    kSoldierSubStateExploding   =  3,
    kSoldierSubStateCount       =  4
} SoldierSubState;

//
// enum SoldierSpawnState
//
typedef enum {
    kSoldierSpawnStateUnknown               = -1,
    kSoldierSpawnStateSpawn                 =  0,
    kSoldierSpawnStateZTransform            =  1,
    kSoldierSpawnStateHealthBar             =  2,
    kSoldierSpawnStateWaitingOnCollision    =  3,
    kSoldierSpawnStateCount                 =  4
} SoldierSpawnState;

//
// enum WallState
//
typedef enum {
    kWallStateUnknown       = -1,
    kWallStateExpanding     =  0,
    kWallStateCompressing   =  1,
    kWallStateCount         =  2
} WallState;

//
// EnemyType
//
typedef enum {
    kEnemyTypeUnknown           = -1,
    kEnemyTypeSoldier           =  0,
    kEnemyTypeSoldierFactory    =  1,
    kEnemyTypeBarrierFactory    =  2,
    kEnemyTypeCount             =  3
} EnemyType;

//
// SFState (SoldierFactoryState)
//
typedef enum {
    kSFStateUnknown     = -1,
    kSFStateQueued      =  0,
    kSFStateSpawning    =  1,
    kSFStateAlive       =  2,
    kSFStateExlpoding   =  3,
    kSFStateDead        =  4,
    kSFStateCount       =  5
} SFState;

//
// SFAliveState (SoldierFactoryAliveState)
// 
// desc: these are substates for kSFStateActive
//
typedef enum {
    kSFAliveStateUnknown           = -1,
    kSFAliveStateResting           =  0, // factory is resting doing nada
    kSFAliveStateSoldierSpawning   =  1, // factory is spawning soldiers
    kSFAliveStateCount             =  2
} SFAliveState;

//
// WaveTimerState
//
typedef enum {
    kWaveTimerStateUnknown  = -1,
    kWaveTimerStateDrain    =  0,
    kWaveTimerStateFill     =  1,
    kWaveTimerStateActive   =  2,
    kWaveTimerStateCount    =  3
} WaveTimerState;

//
// LaserTowerState
//
typedef enum {
    kLaserTowerStateUnknown     = -1,
    kLaserTowerStateActive      =  0,
    kLaserTowerStateExploding   =  1,
    kLaserTowerStateCount       =  2
} LaserTowerState;

//
// PathSpriteState
//
typedef enum {
    kPathSpriteStateUnknown     = -1,
    kPathSpriteStateWait        =  0,
    kPathSpriteStateGrowing     =  1,
    kPathSpriteStateActive      =  2,
    kPathSpriteStateShrinking   =  3,
    kPathSpriteStateCount       =  4
} PathSpriteState;

//
// TerminalWindowState
//
typedef enum {
    kTerminalWindowStateUnknown     = -1,
    kTerminalWindowStateAlive       =  0,
	kTerminalWindowStateResizing	=  1,
	kTerminalWindowStateHiding		=  2,
    kTerminalWindowStateCount       =  5
} TerminalWindowState;

//
// Corner
//
typedef enum {
    kCornerUnknown      = -1,
    kCornerRightTop     =  0,
    kCornerRightBottom  =  1,
    kCornerLeftBottom   =  2,
    kCornerLeftTop      =  3,
    kCornerCount        =  4
} Corner;

//
// GameMode
//
typedef enum {
    kGameModeUnknown                = -1,
    kGameModeBaseTowerTutorial      =  0,
    kGameModeMobileTowerTutorial    =  1,
    kGameModeSurvival               =  2,
    kGameModeResume                 =  3,
    kGameModeCount                  =  4
} GameMode;

//
// MenuScreen
//
typedef enum {
    kMenuScreenUnknown                  = -1,
    kMenuScreenMain                     =  0,
    kMenuScreenTutorial                 =  1,
    kMenuScreenOptions                  =  2,
    kMenuScreenPause                    =  3,
    kMenuScreenSurvivalOutOfTime        =  4,
    kMenuScreenSurvivalTowersDestroyed  =  5,
    kMenuScreenSurvivalCompleted        =  6,
    kMenuScreenCredits                  =  8,
    kMenuScreenCount                    =  9
} MenuScreen;

//
// OscillateType
//
typedef enum {
    kOscillateTypeUnknown   = -1,
    kOscillateTypeNormal    =  0,
    kOscillateTypeSlow      =  1,
    kOscillateTypeFast      =  2,
    kOscillateTypeCount     =  3
} OscillateType;

//
// EnemyDropType
//
typedef enum {
    kEnemyDroptypeUnknown   = -1,
    kEnemyDropTypeNone      =  0,
    kEnemyDropTypeHealth    =  1,
    kEnemyDropType500Pts    =  2,
    kEnemyDropType1000Pts   =  3,
    kEnemyDropType1500Pts   =  4,
    kEnemyDropType2000Pts   =  5,
    kEnemyDropType2500Pts   =  6,
    kEnemyDropTypeCount     =  7
} EnemyDropType;

//
// characters
//
typedef enum {
    kCharacterTypeUnknown   = -1,
    kCharacterTypeBangoBlue =  0,
    kCharacterTypeSpinLock  =  1,
    kCharacterTypeCoco      =  2,
    kCharacterTypeCount     =  3
} CharacterType;