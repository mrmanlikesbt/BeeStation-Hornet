#define GET_AI_BEHAVIOR(behavior_type) SSai_behaviors.ai_behaviors[behavior_type]
#define HAS_AI_CONTROLLER_TYPE(thing, type) istype(thing?.ai_controller, type)

#define AI_STATUS_ON 1
#define AI_STATUS_OFF 2

///For JPS pathing, the maximum length of a path we'll try to generate. Should be modularized depending on what we're doing later on
#define AI_MAX_PATH_LENGTH 30 // 30 is possibly overkill since by default we lose interest after 14 tiles of distance, but this gives wiggle room for weaving around obstacles

///Cooldown on planning if planning failed last time

#define AI_FAILED_PLANNING_COOLDOWN 1.5 SECONDS

///Flags for ai_behavior new()
#define AI_CONTROLLER_INCOMPATIBLE (1<<0)

///Does this task require movement from the AI before it can be performed?
#define AI_BEHAVIOR_REQUIRE_MOVEMENT (1<<0)
///Does this require the current_movement_target to be adjacent and in reach?
#define AI_BEHAVIOR_REQUIRE_REACH (1<<1)
///Does this task let you perform the action while you move closer? (Things like moving and shooting)
#define AI_BEHAVIOR_MOVE_AND_PERFORM (1<<2)
///Does finishing this task not null the current movement target?
#define AI_BEHAVIOR_KEEP_MOVE_TARGET_ON_FINISH (1<<3)
///Does finishing this task make the AI stop moving towards the target?
#define AI_BEHAVIOR_KEEP_MOVING_TOWARDS_TARGET_ON_FINISH (1<<4)
///Does this behavior NOT block planning?
#define AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION (1<<5)

///AI flags
/// Don't move if being pulled
#define STOP_MOVING_WHEN_PULLED (1<<0)
/// Continue processing even if dead
#define CAN_ACT_WHILE_DEAD (1<<1)

//Base Subtree defines

///This subtree should cancel any further planning, (Including from other subtrees)
#define SUBTREE_RETURN_FINISH_PLANNING 1

//Generic subtree defines

/// probability that the pawn should try resisting out of restraints
#define RESIST_SUBTREE_PROB 50
///macro for whether it's appropriate to resist right now, used by resist subtree
#define SHOULD_RESIST(source) (source.on_fire || source.buckled || HAS_TRAIT(source, TRAIT_RESTRAINED) || (source.pulledby && source.pulledby.grab_state > GRAB_PASSIVE))
///macro for whether the pawn can act, used generally to prevent some horrifying ai disasters
#define IS_DEAD_OR_INCAP(source) (source.incapacitated() || source.stat)

//Generic BB keys
#define BB_CURRENT_MIN_MOVE_DISTANCE "min_move_distance"
///time until we should next eat, set by the generic hunger subtree
#define BB_NEXT_HUNGRY "BB_NEXT_HUNGRY"
///what we're going to eat next
#define BB_FOOD_TARGET "bb_food_target"

//for songs

///song instrument blackboard, set by instrument subtrees
#define BB_SONG_INSTRUMENT "BB_SONG_INSTRUMENT"
///song lines blackboard, set by default on controllers
#define BB_SONG_LINES "song_lines"

// Monkey AI controller blackboard keys

#define BB_MONKEY_AGGRESSIVE "BB_monkey_aggressive"
#define BB_MONKEY_GUN_NEURONS_ACTIVATED "BB_monkey_gun_aware"
#define BB_MONKEY_GUN_WORKED "BB_monkey_gun_worked"
#define BB_MONKEY_BEST_FORCE_FOUND "BB_monkey_bestforcefound"
#define BB_MONKEY_ENEMIES "BB_monkey_enemies"
#define BB_MONKEY_BLACKLISTITEMS "BB_monkey_blacklistitems"
#define BB_MONKEY_PICKUPTARGET "BB_monkey_pickuptarget"
#define BB_MONKEY_PICKPOCKETING "BB_monkey_pickpocketing"
#define BB_MONKEY_CURRENT_ATTACK_TARGET "BB_monkey_current_attack_target"
#define BB_MONKEY_CURRENT_PRESS_TARGET "BB_monkey_current_press_target"
#define BB_MONKEY_CURRENT_GIVE_TARGET "BB_monkey_current_give_target"
#define BB_MONKEY_TARGET_DISPOSAL "BB_monkey_target_disposal"
#define BB_MONKEY_TARGET_MONKEYS "BB_monkey_target_monkeys"
#define BB_MONKEY_DISPOSING "BB_monkey_disposing"
#define BB_MONKEY_RECRUIT_COOLDOWN "BB_monkey_recruit_cooldown"


///Haunted item controller defines

///Chance for haunted item to haunt someone
#define HAUNTED_ITEM_ATTACK_HAUNT_CHANCE 10
///Chance for haunted item to try to get itself let go.
#define HAUNTED_ITEM_ESCAPE_GRASP_CHANCE 20
///Amount of aggro you get when picking up a haunted item
#define HAUNTED_ITEM_AGGRO_ADDITION 2

///Blackboard keys for haunted items
#define BB_TO_HAUNT_LIST "BB_to_haunt_list"
///Actual mob the item is haunting at the moment
#define BB_HAUNT_TARGET "BB_haunt_target"
///Amount of successful hits in a row this item has had
#define BB_HAUNTED_THROW_ATTEMPT_COUNT "BB_haunted_throw_attempt_count"

///Cursed item controller defines

//defines
///how far a cursed item will still try to chase a target
#define CURSED_VIEW_RANGE 7
//blackboards

///Actual mob the item is haunting at the moment
#define BB_CURSE_TARGET "BB_haunt_target"
///Where the item wants to land on
#define BB_TARGET_SLOT "BB_target_slot"
///Amount of successful hits in a row this item has had
#define BB_CURSED_THROW_ATTEMPT_COUNT "BB_cursed_throw_attempt_count"

///Vending machine AI controller blackboard keys
#define BB_VENDING_CURRENT_TARGET "BB_vending_current_target"
#define BB_VENDING_TILT_COOLDOWN "BB_vending_tilt_cooldown"
#define BB_VENDING_UNTILT_COOLDOWN "BB_vending_untilt_cooldown"
#define BB_VENDING_BUSY_TILTING "BB_vending_busy_tilting"
#define BB_VENDING_LAST_HIT_SUCCESSFUL "BB_vending_last_hit_successful"

///Robot customer AI controller blackboard keys
#define BB_CUSTOMER_CURRENT_ORDER "BB_customer_current_order"
#define BB_CUSTOMER_MY_SEAT "BB_customer_my_seat"
#define BB_CUSTOMER_PATIENCE "BB_customer_patience"
#define BB_CUSTOMER_CUSTOMERINFO "BB_customer_customerinfo"
#define BB_CUSTOMER_EATING "BB_customer_eating"
#define BB_CUSTOMER_ATTENDING_VENUE "BB_customer_attending_avenue"
#define BB_CUSTOMER_LEAVING "BB_customer_leaving"
#define BB_CUSTOMER_CURRENT_TARGET "BB_customer_current_target"
/// Robot customer has said their can't find seat line at least once. Used to rate limit how often they'll complain after the first time.
#define BB_CUSTOMER_SAID_CANT_FIND_SEAT_LINE "BB_customer_said_cant_find_seat_line"


///Hostile AI controller blackboard keys
#define BB_HOSTILE_ORDER_MODE "BB_HOSTILE_ORDER_MODE"
#define BB_HOSTILE_FRIEND "BB_HOSTILE_FRIEND"
#define BB_HOSTILE_ATTACK_WORD "BB_HOSTILE_ATTACK_WORD"
#define BB_FOLLOW_TARGET "BB_FOLLOW_TARGET"
#define BB_ATTACK_TARGET "BB_ATTACK_TARGET"
#define BB_VISION_RANGE "BB_VISION_RANGE"

/// Basically, what is our vision/hearing range.
#define BB_HOSTILE_VISION_RANGE 10
/// After either being given a verbal order or a pointing order, ignore further of each for this duration
#define AI_HOSTILE_COMMAND_COOLDOWN 2 SECONDS

// hostile command modes (what pointing at something/someone does depending on the last order the carp heard)
/// Don't do anything (will still react to stuff around them though)
#define HOSTILE_COMMAND_NONE 0
/// Will attack a target.
#define HOSTILE_COMMAND_ATTACK 1
/// Will follow a target.
#define HOSTILE_COMMAND_FOLLOW 2

///Dog AI controller blackboard keys

#define BB_SIMPLE_CARRY_ITEM "BB_SIMPLE_CARRY_ITEM"
#define BB_FETCH_TARGET "BB_FETCH_TARGET"
#define BB_FETCH_IGNORE_LIST "BB_FETCH_IGNORE_LISTlist"
#define BB_FETCH_DELIVER_TO "BB_FETCH_DELIVER_TO"
#define BB_DOG_FRIENDS "BB_DOG_FRIENDS"
#define BB_DOG_ORDER_MODE "BB_DOG_ORDER_MODE"
#define BB_DOG_PLAYING_DEAD "BB_DOG_PLAYING_DEAD"
#define BB_DOG_HARASS_TARGET "BB_DOG_HARASS_TARGET"
#define BB_DOG_IS_SLOW "BB_DOG_IS_SLOW"

/// Basically, what is our vision/hearing range for picking up on things to fetch/
#define AI_DOG_VISION_RANGE	10
/// What are the odds someone petting us will become our friend?
#define AI_DOG_PET_FRIEND_PROB 15
/// After this long without having fetched something, we clear our ignore list
#define AI_FETCH_IGNORE_DURATION 30 SECONDS
/// After being ordered to heel, we spend this long chilling out
#define AI_DOG_HEEL_DURATION 20 SECONDS
/// After either being given a verbal order or a pointing order, ignore further of each for this duration
#define AI_DOG_COMMAND_COOLDOWN	2 SECONDS

// dog command modes (what pointing at something/someone does depending on the last order the dog heard)
/// Don't do anything (will still react to stuff around them though)
#define DOG_COMMAND_NONE 0
/// Will try to pick up and bring back whatever you point to
#define DOG_COMMAND_FETCH 1
/// Will get within a few tiles of whatever you point at and continually growl/bark. If the target is a living mob who gets too close, the dog will attack them with bites
#define DOG_COMMAND_ATTACK 2

//enumerators for parsing command speech
#define COMMAND_HEEL "Heel"
#define COMMAND_FETCH "Fetch"
#define COMMAND_FOLLOW "Follow"
#define COMMAND_STOP "Stop"
#define COMMAND_ATTACK "Attack"
#define COMMAND_DIE "Play Dead"

///bane ai
#define BB_BANE_BATMAN "BB_bane_batman"
//yep thats it


//Hunting defines
#define SUCCESSFUL_HUNT_COOLDOWN 5 SECONDS

///Hunting BB keys
#define BB_CURRENT_HUNTING_TARGET "BB_current_hunting_target"
#define BB_LOW_PRIORITY_HUNTING_TARGET "BB_low_priority_hunting_target"
#define BB_HUNTING_COOLDOWN "BB_HUNTING_COOLDOWN"

///Basic Mob Keys

///Targetting subtrees
#define BB_BASIC_MOB_CURRENT_TARGET "BB_basic_current_target"
#define BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION "BB_basic_current_target_hiding_location"
#define BB_TARGETTING_DATUM "targetting_datum"

///Baby-making blackboard
///Types of animal we can make babies with.
#define BB_BABIES_PARTNER_TYPES "BB_babies_partner"
///Types of animal that we make as a baby.
#define BB_BABIES_CHILD_TYPES "BB_babies_child"
///Current partner target
#define BB_BABIES_TARGET "BB_babies_target"

///Targetting keys for something to run away from, if you need to store this separately from current target
#define BB_BASIC_MOB_FLEE_TARGET "BB_basic_flee_target"
#define BB_BASIC_MOB_FLEE_TARGET_HIDING_LOCATION "BB_basic_flee_target_hiding_location"
#define BB_FLEE_TARGETTING_DATUM "flee_targetting_datum"

///List of mobs who have damaged us
#define BB_BASIC_MOB_RETALIATE_LIST "BB_basic_mob_shitlist"

/// Flag to set on or off if you want your mob to prioritise running away
#define BB_BASIC_MOB_FLEEING "BB_basic_fleeing"

// AI laws
#define LAW_VALENTINES "valentines"
#define LAW_ZEROTH "zeroth"
#define LAW_INHERENT "inherent"
#define LAW_SUPPLIED "supplied"
#define LAW_ION "ion"
#define LAW_HACKED "hacked"

GLOBAL_LIST_INIT(all_radial_directions, list(
	"NORTH" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH),
	"NORTHEAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTHEAST),
	"EAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = EAST),
	"SOUTHEAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTHEAST),
	"SOUTH" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH),
	"SOUTHWEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTHWEST),
	"WEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = WEST),
	"NORTHWEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTHWEST)
))

///Tipped blackboards
///Bool that means a basic mob will start reacting to being tipped in its planning
#define BB_BASIC_MOB_TIP_REACTING "BB_basic_tip_reacting"
///the motherfucker who tipped us
#define BB_BASIC_MOB_TIPPER "BB_basic_tip_tipper"

///list of foods this mob likes
#define BB_BASIC_FOODS "BB_basic_foods"

//cat AI keys
/// key that holds the target we will battle over our turf
#define BB_TRESSPASSER_TARGET "tresspasser_target"
/// key that holds angry meows
#define BB_HOSTILE_MEOWS "hostile_meows"
/// key that holds the mouse target
#define BB_MOUSE_TARGET "mouse_target"
/// key that holds our dinner target
#define BB_CAT_FOOD_TARGET "cat_food_target"
/// key that holds the food we must deliver
#define BB_FOOD_TO_DELIVER "food_to_deliver"
/// key that holds things we can hunt
#define BB_HUNTABLE_PREY "huntable_prey"
/// key that holds target kitten to feed
#define BB_KITTEN_TO_FEED "kitten_to_feed"
/// key that holds our hungry meows
#define BB_HUNGRY_MEOW "hungry_meows"
/// key that holds maximum distance food is to us so we can pursue it
#define BB_MAX_DISTANCE_TO_FOOD "max_distance_to_food"
/// key that holds the stove we must turn off
#define BB_STOVE_TARGET "stove_target"
/// key that holds the donut we will decorate
#define BB_DONUT_TARGET "donut_target"
/// key that holds our home...
#define BB_CAT_HOME "cat_home"
/// key that holds the human we will beg
#define BB_HUMAN_BEG_TARGET "human_beg_target"
