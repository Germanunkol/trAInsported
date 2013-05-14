
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
LNG.menu_live_tooltip = [[Katso otteluita verkossa]]
LNG.menu_tutorial = [[Harjoittele]]
LNG.menu_tutorial_tooltip = [[Opi perusteet tekoälyn tekemisestä]]
LNG.menu_challenge = [[Haasteet]]
LNG.menu_challenge_tooltip = [[Päihitä haastekartat. Lisää haasteita saat pelin nettisivuilta.]]
LNG.menu_compete = [[Kilpaile]]
LNG.menu_compete_tooltip = [[Laita omat tekoälysi ottelemaan toisiaan vastaan]]
LNG.menu_random = [[Satunnainen]]
LNG.menu_random_tooltip = [[Ottelu omasta AI -kansiosta satunnaisesti valittujen tekoälyjen kesken]]
LNG.menu_settings = [[Asetukset]]
LNG.menu_settings_tooltip = [[Muuta ohjelman asetuksia]]
LNG.menu_exit = [[Lopeta]]

LNG.menu_return = [[Takaisin]]
LNG.menu_return_to_main_menu_tooltip = [[Palaa takaisin päävalikkoon]]

LNG.menu_choose_ai = [[Valitse tekoäly otteluun:]]
LNG.menu_choose_ai_tooltip = [[Valitse tämä tekoäly otteluun]]

LNG.menu_choose_dimensions = [[Leveys ja korkeus:]]
LNG.menu_choose_dimensions_tooltip1 = [[Valitse kartan leveys]]
LNG.menu_choose_dimensions_tooltip2 = [[Valitse kartan korkeus]]

LNG.menu_choose_timemode = [[Aika ja pelityyppi:]]
LNG.menu_time_name[1] = [[Päivä]]
LNG.menu_time_name[2] = [[Ruuhka-aika]]
LNG.menu_time_tooltip[1] = [[Perus asetus, keskiverrosti matkustajia]]
LNG.menu_time_tooltip[2] = [[Enemmän VIP -matkustajia!]]
LNG.menu_mode_name[1] = [[Aikaraja]]
LNG.menu_mode_name[2] = [[Matkustajaraja]]
LNG.menu_mode_tooltip[1] = [[Kuljeta eniten matkustajia annetussa ajassa]]
LNG.menu_mode_tooltip[2] = [[Kiinteä matkustajamäärä. Kuljeta heistä useampi, kuin vastustajasi]]

LNG.menu_choose_region = [[Sijainti:]]
LNG.menu_region_name[1] = [[Kylä]]
LNG.menu_region_name[2] = [[Kaupunki]]
LNG.menu_region_tooltip[1] = [[Rauhallinen maalaiskylä]]
LNG.menu_region_tooltip[2] = [[Kiihkeä kaupunkiympäristö (Kaksinkertainen määrä matkustajia kylään verrattuna)]]

LNG.menu_start = [[Käynnistä]]
LNG.menu_start_tooltip = [[Käynnistä ottelu valituilla asetuksilla]]

LNG.menu_main_server = [[Pääpalvelin]]
LNG.menu_main_server_tooltip = [[Yhdistä pääpalvelimelle (Tarvitsee nettiyhteyden)]]
LNG.menu_local_server = [[Paikallinen palvelin]]
LNG.menu_local_server_tooltip = [[Yhdistä tällä koneella olevalle palvelimelle]]

-- Settings menu:
LNG.menu_settings_resolution = [[Screen size:]]
LNG.menu_resolution_tooltip = [[Set new screen resolution]]
LNG.menu_settings_options = [[Options:]]
LNG.menu_clouds_on = [[Clouds: On]]
LNG.menu_clouds_off = [[Clouds: Off]]
LNG.menu_clouds_on_tooltip = [[Click to enable cloud rendering.]]
LNG.menu_clouds_off_tooltip = [[Click to disable cloud rendering.]]
LNG.menu_settings_language = [[Language:]]
LNG.menu_settings_language_tooltip1 = [[Click to switch game language to]]  -- before lang name
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
