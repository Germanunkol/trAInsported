
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
LNG.menu_live = [[Vie]]
LNG.menu_live_tooltip = [[Regardez les matchs directement en ligne !]]
LNG.menu_tutorial = [[Tutoriels]]
LNG.menu_tutorial_tooltip = [[Apprenez à connaître le jeu !]]
LNG.menu_challenge = [[Défis]]
LNG.menu_challenge_tooltip = [[Battre les cartes de défi! Obtenez plus de cartes en ligne sur le site du jeu.]]
LNG.menu_compete = [[Rivaliser]]
LNG.menu_compete_tooltip = [[Mettre en place un test match pour votre IA]]
LNG.menu_random = [[Aléatoire]]
LNG.menu_random_tooltip = [[Commencer un match aléatoire sur une carte aléatoire en utilisant aléatoire AIs de votre dossier AI]]
LNG.menu_settings = [[Paramètres]]
LNG.menu_settings_tooltip = [[Change le language, la résolution etc.]]
LNG.menu_exit = [[Quitter]]

LNG.menu_return = [[Retour]]
LNG.menu_return_to_main_menu_tooltip = [[Retourner au menu principal]]

LNG.menu_choose_ai = [[Choisissez IA pour Match:]]
LNG.menu_choose_ai_tooltip = [[Choisissez cette IA pour le match ?]]

LNG.menu_choose_dimensions = [[Largeur et Hauteur:]]
LNG.menu_choose_dimensions_tooltip1 = [[Sélectionnez la Largeur]]
LNG.menu_choose_dimensions_tooltip2 = [[Sélectionnez la Hauteur]]

LNG.menu_choose_timemode = [[Heure et Mode:]]
LNG.menu_time_name[1] = [[Jour]]
LNG.menu_time_name[2] = [[Heure de pointe]]
LNG.menu_time_tooltip[1] = [[Configuration normale, le montant moyen des passagers]]
LNG.menu_time_tooltip[2] = [[Plus de VIPs!]]
LNG.menu_mode_name[1] = [[Limite de temps]]
LNG.menu_mode_name[2] = [[Passagers]]
LNG.menu_mode_tooltip[1] = [[Transporter les la plupart des passagers dans un laps de temps.]]
LNG.menu_mode_tooltip[2] = [[Montant fixe des passagers. Vous devez essayer de transporter plus que tout autre IA.]]

LNG.menu_choose_region = [[Région:]]
LNG.menu_region_name[1] = [[Rural]]
LNG.menu_region_name[2] = [[Urbain]]
LNG.menu_region_tooltip[1] = [[village paisible.]]
LNG.menu_region_tooltip[2] = [[Deux fois plus de passagers que milieu rural a.]]

LNG.menu_start = [[Démarrer]]
LNG.menu_start_tooltip = [[Démarrer le match avec ces paramètres]]

LNG.menu_main_server = [[Serveur principal]]
LNG.menu_main_server_tooltip = [[Se connecter au serveur principal. Doit être connecté à Internet !]]
LNG.menu_local_server = [[Localhost]]
LNG.menu_local_server_tooltip = [[Se connecter à un serveur fonctionnant sur cette machine.]]

-- Settings menu:
LNG.menu_settings_resolution = [[Taille de l'écran:]]
LNG.menu_resolution_tooltip = [[Nouvelle résolution d'écran]]
LNG.menu_settings_options = [[Options:]]
LNG.menu_clouds_on = [[Clouds: On]]
LNG.menu_clouds_off = [[Clouds: Off]]
LNG.menu_clouds_on_tooltip = [[Cliquez pour activer le cloud rendu.]]
LNG.menu_clouds_off_tooltip = [[Cliquez pour désactiver le cloud rendu.]]
LNG.menu_fullscreen_on = [[Fullscreen: On]]
LNG.menu_fullscreen_off = [[Fullscreen: Off]]
LNG.menu_fullscreen_on_tooltip = [[Click to enable fullscreen]]
LNG.menu_fullscreen_off_tooltip = [[Click to disable fullscreen]]
LNG.menu_settings_language = [[Language:]]
LNG.menu_settings_language_tooltip1 = [[Click to switch game language to]]	-- before lang name
LNG.menu_settings_language_tooltip2 = [[]]	-- after lang name

-- Menu errors:
LNG.menu_err_min_ai = [[Need to choose at least one AI!]]
LNG.menu_err_dimensions = [[Invalid map dimensions!]]
LNG.menu_err_mode = [[Invalid game mode!]]
LNG.menu_err_time = [[Invalid game time!]]
LNG.menu_err_resolution = [[Impossible de définir la résolution !]]


-------------------------------------------------
-- INGAME:
-------------------------------------------------
-- Fast forward message:
LNG.fast_forward = [[FAST FORWARD TO CATCH UP WITH SERVER]]
LNG.confirm_leave = [[Leave the current match and return to menu?]]

LNG.open_folder = [[Dossier ouvert]]
LNG.open_folder_tooltip = [[Opens the folder: AI_FOLDER_DIRECTORY]] -- AI_FOLDER_DIRECTORY will be replaced by the game with the correct directory.
LNG.open_website = [[WWW]]
LNG.open_website_tooltip = [[Visit us on the web!]] -- AI_FOLDER_DIRECTORY will be replaced by the game with the correct directory.

LNG.reload = [[Recharger]]
LNG.reload_confirm = [[Reload the AIs?]]
LNG.reload_tooltip = [[Reloads the AI scripts and restarts the round.]]
LNG.disconnect = [[Disconnect]]
LNG.end_match = [[End Match]]

LNG.speed_up = [[Speeds game up]]
LNG.slow_down = [[Slows game down]]
LNG.pause = [[Pauses game]]

LNG.by = [[par]]
LNG.transported = [[Transported]]
-- the following three strings are for the string "X of Y passengers"
LNG.transported1 = [[]]		-- before X
LNG.transported2 = [[ of ]]		-- between X and Y
LNG.transported3 = [[ passengers]]		-- after Y

LNG.round_ends = [[Round ends in]]
LNG.seconds = [[secs]]
LNG.minutes = [[min]]
LNG.hours = [[h]]
LNG.days = [[Jours]]
LNG.end_of_match = [[Match is over!]]

LNG.live_match = [[LIVE MATCH]]
LNG.lost_connection = [[LOST CONNECTION]]

-------------------------------------------------
-- LOADING SCREEN:
-------------------------------------------------
LNG.load_new_map = [[Nouvelle Carte]]
LNG.load_map_size = [[Taille: ]]
LNG.load_map_time = [[Temps: ]]
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
LNG.exit_confirm = [[Êtes vous sûr de vouloir quitter ?]]
LNG.confirm_resolution = [[Gardez cette nouvelle résolution ?]]
LNG.agree = [[Oui]]
LNG.disagree = [[Non]]
LNG.cancel = [[Annuler]]

-------------------------------------------------
-- ERRORS:
-------------------------------------------------
LNG.err_already_generating_map = [[Déjà la génération nouvelle carte! Attendez processus se termine ...]]
LNG.err_wait_for_rendering = [[Attendez que le rendu à la fin ...]]
LNG.err_rendering = [[Quelque chose a mal tourné dans un fil tout en générant la carte. Désolé à ce sujet, s'il vous plaît redémarrer le jeu et essayez à nouveau.]]
LNG.err_already_connecting = [[Déjà tenter de démarrer la connexion.]]

LNG.error_header = [[Oh non, il y avait une erreur !]]
LNG.error_steps = [[Si vous êtes en train de travailler sur votre propre carte de défi, cela pourrait avoir été causé par votre défi. Vous pouvez obtenir de l'aide sur les forums:
http://www.indiedb.com/games/trainsported/forum

Si cela n'a pas été causé par votre propre code, vous pouvez signaler l'erreur sur la page des questions:
https://github.com/Germanunkol/trAInsported/issues

Appuyez sur 'c' pour copier le message d'erreur dans votre presse-papiers.
Appuyez sur 'o' pour ouvrir le site GitHub questions.
Appuyez sur 'esc' pour fermer.
]]
LNG.error_copied = [[Copié !]]
