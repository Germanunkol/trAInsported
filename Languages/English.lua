
-- Language file for trAInsported. Make a copy of this to translate into your own language.
-- Please don't change the order of the entries in this file.

LNG.menu_mode_name = {}
LNG.menu_mode_tooltip = {}
LNG.menu_time_name = {}
LNG.menu_time_tooltip = {}
LNG.menu_region_name = {}
LNG.menu_region_tooltip = {}
LNG.load_generation = {}

-------------------------------------------------
-- Menu:
-------------------------------------------------
LNG.menu_live = [[Live]]
LNG.menu_live_tooltip = [[Watch the live online matches!]]
LNG.menu_tutorial = [[Tutorials]]
LNG.menu_tutorial_tooltip = [[Get to know the game!]]
LNG.menu_challenge = [[Challenge]]
LNG.menu_challenge_tooltip = [[Beat the challenge maps! Get more maps online on the game's website.]]
LNG.menu_compete = [[Compete]]
LNG.menu_compete_tooltip = [[Set up a test match for your AI]]
LNG.menu_random = [[Random]]
LNG.menu_random_tooltip = [[Start a random match on a random map using random AIs from your 'AI' folder]]
LNG.menu_settings = [[Settings]]
LNG.menu_settings_tooltip = [[Change language, resolution etc.]]
LNG.menu_exit = [[Exit]]

LNG.menu_return = [[Return]]
LNG.menu_return_to_main_menu_tooltip = [[Go back to main menu]]

LNG.menu_choose_ai = [[Choose AIs for Match:]]
LNG.menu_choose_ai_tooltip = [[Choose this AI for the match?]]

LNG.menu_choose_dimensions = [[Width and Height:]]
LNG.menu_choose_dimensions_tooltip1 = [[Select width]]
LNG.menu_choose_dimensions_tooltip2 = [[Select height]]

LNG.menu_choose_timemode = [[Time and Mode:]]
LNG.menu_time_name[1] = [[Day]]
LNG.menu_time_name[2] = [[Rushhour]]
LNG.menu_time_tooltip[1] = [[Normal setup, average amount of passengers]]
LNG.menu_time_tooltip[2] = [[More VIPs!]]
LNG.menu_mode_name[1] = [[Time Limit]]
LNG.menu_mode_name[2] = [[Passengers]]
LNG.menu_mode_tooltip[1] = [[Transport the most passengers in a set amount of time.]]
LNG.menu_mode_tooltip[2] = [[Fixed amount of passengers. You have to try to transport more than any other AI.]]

LNG.menu_choose_region = [[Region:]]
LNG.menu_region_name[1] = [[Rural]]
LNG.menu_region_name[2] = [[Urban]]
LNG.menu_region_tooltip[1] = [[Peaceful village setting.]]
LNG.menu_region_tooltip[2] = [[Twice as many passengers as rural setting has.]]

LNG.menu_start = [[Start]]
LNG.menu_start_tooltip = [[Start the match with these settings]]

LNG.menu_main_server = [[Main server]]
LNG.menu_main_server_tooltip = [[Connect to the main server. Must be connected to the internet!]]
LNG.menu_local_server = [[Localhost]]
LNG.menu_local_server_tooltip = [[Connect to a server running on this machine.]]

-- Settings menu:
LNG.menu_settings_resolution = [[Screen size:]]
LNG.menu_resolution_tooltip = [[Set new screen resolution]]
LNG.menu_settings_options = [[Options:]]
LNG.menu_clouds_on = [[Clouds: On]]
LNG.menu_clouds_off = [[Clouds: Off]]
LNG.menu_clouds_on_tooltip = [[Click to enable cloud rendering.]]
LNG.menu_clouds_off_tooltip = [[Click to disable cloud rendering.]]
LNG.menu_settings_language = [[Language:]]
LNG.menu_settings_language_tooltip1 = [[Click to switch game language to]]	-- before lang name
LNG.menu_settings_language_tooltip2 = [[]]	-- after lang name

-- Menu errors:
LNG.menu_err_min_ai = [[Need to choose at least one AI!]]
LNG.menu_err_dimensions = [[Invalid map dimensions!]]
LNG.menu_err_mode = [[Invalid game mode!]]
LNG.menu_err_time = [[Invalid game time!]]
LNG.menu_err_resolution = [[Failed to set resolution!]]


-------------------------------------------------
-- INGAME:
-------------------------------------------------
-- Fast forward message:
LNG.fast_forward = [[FAST FORWARD TO CATCH UP WITH SERVER]]
LNG.confirm_leave = [[Leave the current match and return to menu?]]

LNG.open_folder = [[Open Folder]]
LNG.open_folder_tooltip = [[Opens the folder: AI_FOLDER_DIRECTORY]] -- AI_FOLDER_DIRECTORY will be replaced by the game with the correct directory.

LNG.reload = [[Reload]]
LNG.reload_confirm = [[Reload the AIs?]]
LNG.reload_tooltip = [[Reloads the AI scripts and restarts the round.]]
LNG.disconnect = [[Disconnect]]
LNG.end_match = [[End Match]]

LNG.speed_up = [[Speeds game up]]
LNG.slow_down = [[Slows game down]]
LNG.pause = [[Pauses game]]

LNG.by = [[by]]
LNG.transported = [[Transported]]
-- the following three strings are for the string "X of Y passengers"
LNG.transported1 = [[]]		-- before X
LNG.transported2 = [[ of ]]		-- between X and Y
LNG.transported3 = [[ passengers]]		-- after Y

LNG.round_ends = [[Round ends in]]
LNG.seconds = [[secs]]
LNG.minutes = [[min]]
LNG.hours = [[h]]
LNG.days = [[days]]
LNG.end_of_match = [[Match is over!]]

LNG.live_match = [[LIVE MATCH]]
LNG.lost_connection = [[LOST CONNECTION]]

-------------------------------------------------
-- LOADING SCREEN:
-------------------------------------------------
LNG.load_new_map = [[New Map]]
LNG.load_map_size = [[Size: ]]
LNG.load_map_time = [[Time: ]]
LNG.load_map_mode_time = [[Mode: Round time: ]]
LNG.load_map_mode_passengers = [[Mode: Transport enough Passengers]]
LNG.load_generating_map = [[Generating Map]]
LNG.load_rendering_map = [[Rendering Map]]
LNG.load_connecting = [[Connecting]]
LNG.load_failed = [[Failed!]]
-- leave ["rails"] etc, just translate the right part of the equal sign:
LNG.load_generation["rails"] = [[Rails]]
LNG.load_generation["houses"] = [[Houses]]
LNG.load_generation["hotspots"] = [[Hotspots]]

-------------------------------------------------
-- ROUND END STATISTICS:
-------------------------------------------------
-- The round statistics here are placed together using these strings as base. Some have versions in plural and in singular forms. If there's no difference in your language, please just copy the one version into both strings - do NOT delete the singular form!
-- In these strings, _AINAME_ and _NUMBER_ will be replaced by the appropriate values, so make sure to include them!
LNG.stat_most_picked_up_title = [[Hospitality]]
LNG.stat_most_picked_up = [[AI _AINAME_ picked up _NUMBER_ passengers.]]
LNG.stat_most_picked_up_sing = [[AI _AINAME_ picked up _NUMBER_ passenger.]]

LNG.stat_most_trains_title = [[Fleetus Maximus]]
LNG.stat_most_trains = [[AI _AINAME_ owned _NUMBER_ trains.]]
LNG.stat_most_trains_sing = [[AI _AINAME_ owned _NUMBER_ trains]]

LNG.stat_most_transported_title = [[Earned Your Pay]]
LNG.stat_most_transported = [[AI _AINAME_ brought _NUMBER_ passengers to their destinations.]]
LNG.stat_most_transported_sing = [[AI _AINAME_ brought _NUMBER_ passenger to her/his destination.]]

LNG.stat_most_normal_transported_title = [[Socialist]]
LNG.stat_most_normal_transported = [[AI _AINAME_ brought _NUMBER_ non-VIP passengers to their destinations.]]
LNG.stat_most_normal_transported_sing = [[AI _AINAME_ brought _NUMBER_ non-VIP passenger to her/his destination.]]

LNG.stat_dropped_title = [[Get lost...]]
LNG.stat_dropped = [[AI _AINAME_ dropped off _NUMBER_ passengers where they didn't want to go.]]
LNG.stat_dropped_sing = [[AI _AINAME_ brought _NUMBER_ passenger where he/she didn't want to go.]]

LNG.stat_most_money_title = [[Capitalist]]
LNG.stat_most_money = [[AI _AINAME_ earned _NUMBER_ credits.]]

-- Some of the following can take up to three arguments: _NUMBER_, _AINAME_ and _TRAINNAME_:
LNG.stat_tr_most_picked_up_title = [[Busy little Bee!]]
LNG.stat_tr_most_picked_up = [[_TRAINNAME_ [_AINAME_] picked up more passengers than any other train.]]

LNG.stat_tr_most_transported_title = [[Home sweet Home]]
LNG.stat_tr_most_transported = [[_TRAINNAME_ [_AINAME_] brought more passengers to their destinations than any other train.]]

LNG.stat_tr_dropped_title = [[Why don't you walk?]]
LNG.stat_tr_dropped = [[_TRAINNAME_ [_AINAME_] left _NUMBER_ passengers in the middle of nowhere!]]
LNG.stat_tr_dropped_sing = [[_TRAINNAME_ [_AINAME_] left _NUMBER_ passenger in the middle of nowhere!]]

LNG.stat_tr_blocked_title = [[Line is busy...]]
LNG.stat_tr_blocked = [[_TRAINNAME_ [_AINAME_] was blocked for a total of _NUMBER_ seconds.]]

-------------------------------------------------
-- MESSAGE BOX:
-------------------------------------------------
LNG.exit_confirm = [[Sure you want to quit?]]
LNG.confirm_resolution = [[Keep this new resolution?]]
LNG.agree = [[Yes]]
LNG.disagree = [[No]]
LNG.cancel = [[Cancel]]

-------------------------------------------------
-- ERRORS:
-------------------------------------------------
LNG.err_already_generating_map = [[Already generating new map! Wait for process to finish...]]
LNG.err_wait_for_rendering = [[Wait for rendering to finish...]]
LNG.err_rendering = [[Something went wrong in a thread while generating the map. Sorry about that, please restart the game and try again.]]
LNG.err_already_connecting = [[Already attempting to start connection.]]

LNG.error_header = [[Oh no, there was an error!]]
LNG.error_steps = [[If you're currently working on your own challenge map, this might have been caused by your challengge. You can get help on the forums:
http://www.indiedb.com/games/trainsported/forum

If this was not caused by your own code, you can report the error on the issues page:
https://github.com/Germanunkol/trAInsported/issues

Press 'c' to copy the error message to your clipboard.
Press 'o' to open the GitHub issues website.
Press 'esc' to close.
]]
LNG.error_copied = [[Copied!]]
