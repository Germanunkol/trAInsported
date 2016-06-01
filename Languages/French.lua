
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
LNG.menu_challenge_tooltip = [[Jouez les cartes défis ! Obtenez plus de cartes en ligne sur le site du jeu.]]
LNG.menu_compete = [[Rivalisez]]
LNG.menu_compete_tooltip = [[Mettre en place un match test pour votre IA]]
LNG.menu_random = [[Aléatoire]]
LNG.menu_random_tooltip = [[Commencez un match aléatoire grâce à votre dossier 'IA']]
LNG.menu_settings = [[Paramètres]]
LNG.menu_settings_tooltip = [[Changez la langue, la résolution etc.]]
LNG.menu_exit = [[Quittez]]

LNG.menu_return = [[Retour]]
LNG.menu_return_to_main_menu_tooltip = [[Retournez au menu principal]]

LNG.menu_choose_ai = [[Choisissez une IA pour un match:]]
LNG.menu_choose_ai_tooltip = [[Choisissez cette IA pour le match ?]]

LNG.menu_choose_dimensions = [[Largeur et Hauteur:]]
LNG.menu_choose_dimensions_tooltip1 = [[Sélectionnez la Largeur]]
LNG.menu_choose_dimensions_tooltip2 = [[Sélectionnez la Hauteur]]

LNG.menu_choose_timemode = [[Heure et Mode:]]
LNG.menu_time_name[1] = [[Jour]]
LNG.menu_time_name[2] = [[Heure]]
LNG.menu_time_tooltip[1] = [[Configuration normale, la moyenne du nombre des passagers]]
LNG.menu_time_tooltip[2] = [[Plus de VIPs !]]
LNG.menu_mode_name[1] = [[Limite de temps]]
LNG.menu_mode_name[2] = [[Passagers]]
LNG.menu_mode_tooltip[1] = [[Transportez la plupart des passagers dans un laps de temps.]]
LNG.menu_mode_tooltip[2] = [[Nombre fixe des passagers. Vous devez essayez d'en transportez le plus possible avant les autres IA.]]

LNG.menu_choose_region = [[Région:]]
LNG.menu_region_name[1] = [[Rural]]
LNG.menu_region_name[2] = [[Urbain]]
LNG.menu_region_tooltip[1] = [[Reglage village paisible.]]
LNG.menu_region_tooltip[2] = [[Deux fois plus de passagers quand milieu rural.]]

LNG.menu_start = [[Démarrez]]
LNG.menu_start_tooltip = [[Démarrez le match avec ces paramètres]]

LNG.menu_main_server = [[Serveur principal]]
LNG.menu_main_server_tooltip = [[Se connectez au serveur principal. Doit être connecté à Internet !]]
LNG.menu_local_server = [[Localhost]]
LNG.menu_local_server_tooltip = [[Se connectez à un serveur fonctionnant sur cette machine.]]

-- Settings menu:
LNG.menu_settings_resolution = [[Taille de l'écran:]]
LNG.menu_resolution_tooltip = [[Nouvelle résolution d'écran]]
LNG.menu_settings_options = [[Options:]]
LNG.menu_clouds_on = [[Nuages: Activez]]
LNG.menu_clouds_off = [[Nuages: Désactivez]]
LNG.menu_clouds_on_tooltip = [[Cliquez pour activez le rendu des nuages.]]
LNG.menu_clouds_off_tooltip = [[Cliquez pour désactivez le rendu des nuages.]]
LNG.menu_fullscreen_on = [[Plein écran: Activez]]
LNG.menu_fullscreen_off = [[Plein écran: Désactivez]]
LNG.menu_fullscreen_on_tooltip = [[Cliquez pour activez le plein écran]]
LNG.menu_fullscreen_off_tooltip = [[Cliquez pour désactivez le plein écran]]
LNG.menu_settings_language = [[La langue:]]
LNG.menu_settings_language_tooltip1 = [[Cliquez pour changez la langue du jeu]]	-- before lang name
LNG.menu_settings_language_tooltip2 = [[]]	-- after lang name

-- Menu errors:
LNG.menu_err_min_ai = [[Vous devez choisir au moins une IA !]]
LNG.menu_err_dimensions = [[Dimension de la carte non valide !]]
LNG.menu_err_mode = [[Mode de jeu non valide !]]
LNG.menu_err_time = [[Temps de jeu non valide !]]
LNG.menu_err_resolution = [[Impossible de définir la résolution !]]


-------------------------------------------------
-- INGAME:
-------------------------------------------------
-- Fast forward message:
LNG.fast_forward = [[AVANCE RAPIDE pour rattrapez SERVEUR]]
LNG.confirm_leave = [[Laissez le match en cours et revenir au menu ?]]

LNG.open_folder = [[Dossier ouvert]]
LNG.open_folder_tooltip = [[Ouvre le dossier: AI_FOLDER_DIRECTORY]] -- AI_FOLDER_DIRECTORY will be replaced by the game with the correct directory.
LNG.open_website = [[WWW]]
LNG.open_website_tooltip = [[Visitez-nous sur le web !]] -- AI_FOLDER_DIRECTORY will be replaced by the game with the correct directory.

LNG.reload = [[Rechargez]]
LNG.reload_confirm = [[Rechargez les IA ?]]
LNG.reload_tooltip = [[Recharge les scripts d'IA et redémarre le tour.]]
LNG.disconnect = [[Déconnectez]]
LNG.end_match = [[Fin du match]]

LNG.speed_up = [[Accelerez]]
LNG.slow_down = [[Ralentissez]]
LNG.pause = [[Jeu en pause]]

LNG.by = [[par]]
LNG.transported = [[Transportés]]
-- the following three strings are for the string "X of Y passengers"
LNG.transported1 = [[]]		-- before X
LNG.transported2 = [[ de ]]		-- between X and Y
LNG.transported3 = [[ passagers]]		-- after Y

LNG.round_ends = [[Tour prend fin dans]]
LNG.seconds = [[secs]]
LNG.minutes = [[min]]
LNG.hours = [[h]]
LNG.days = [[jours]]
LNG.end_of_match = [[Le match est terminée !]]

LNG.live_match = [[MATCH EN DIRECT]]
LNG.lost_connection = [[CONNEXION PERDUE]]

-------------------------------------------------
-- LOADING SCREEN:
-------------------------------------------------
LNG.load_new_map = [[Nouvelle Carte]]
LNG.load_map_size = [[Taille: ]]
LNG.load_map_time = [[Temps: ]]
LNG.load_map_mode_time = [[Mode: Le temps par tours: ]]
LNG.load_map_mode_passengers = [[Mode: Transportez assez de passagers]]
LNG.load_generating_map = [[Générez une carte]]
LNG.load_rendering_map = [[Rendu de la carte]]
LNG.load_connecting = [[Connexion]]
LNG.load_failed = [[Échoué !]]
-- leave ["rails"] etc, just translate the right part of the equal sign:
LNG.load_generation["rails"] = [[Rails]]
LNG.load_generation["houses"] = [[Maisons]]
LNG.load_generation["hotspots"] = [[Point chaud]]

-------------------------------------------------
-- ROUND END STATISTICS:
-------------------------------------------------
-- The round statistics here are placed together using these strings as base. Some have versions in plural and in singular forms. If there's no difference in your language, please just copy the one version into both strings - do NOT delete the singular form!
-- In these strings, _AINAME_ and _NUMBER_ will be replaced by the appropriate values, so make sure to include them!
LNG.stat_most_picked_up_title = [[Hospitalité]]
LNG.stat_most_picked_up = [[IA _AINAME_ ramassé _NUMBER_ passagers.]]
LNG.stat_most_picked_up_sing = [[IA _AINAME_ ramassé _NUMBER_ passagers.]]

LNG.stat_most_trains_title = [[Fleetus Maximus]]
LNG.stat_most_trains = [[IA _AINAME_ en propriété _NUMBER_ trains.]]
LNG.stat_most_trains_sing = [[IA _AINAME_ en propriété _NUMBER_ trains]]

LNG.stat_most_transported_title = [[Gagné votre salaire]]
LNG.stat_most_transported = [[IA _AINAME_ apporté _NUMBER_ les passagers à leurs destinations.]]
LNG.stat_most_transported_sing = [[IA _AINAME_ apporté _NUMBER_ le passager à son/sa destination.]]

LNG.stat_most_normal_transported_title = [[Socialiste]]
LNG.stat_most_normal_transported = [[IA _AINAME_ apporté _NUMBER_ les passagers non-VIP à leurs destinations.]]
LNG.stat_most_normal_transported_sing = [[IA _AINAME_ apporté _NUMBER_ le non-VIP passager à son/sa destination.]]

LNG.stat_dropped_title = [[Se perdre...]]
LNG.stat_dropped = [[IA _AINAME_ déposé _NUMBER_ les passagers étaient ils ne veulent pas aller.]]
LNG.stat_dropped_sing = [[IA _AINAME_ apporté _NUMBER_ le passagers où il/elle ne voulait pas y aller.]]

LNG.stat_most_money_title = [[Capitaliste]]
LNG.stat_most_money = [[IA _AINAME_ gagné _NUMBER_ crédits.]]

-- Some of the following can take up to three arguments: _NUMBER_, _AINAME_ and _TRAINNAME_:
LNG.stat_tr_most_picked_up_title = [[Occupé petite abeille !]]
LNG.stat_tr_most_picked_up = [[_TRAINNAME_ [_AINAME_] ramassé le plus de passagers que tout les autres trains.]]

LNG.stat_tr_most_transported_title = [[La douceur du foyer]]
LNG.stat_tr_most_transported = [[_TRAINNAME_ [_AINAME_] Apportez le plus de passagers à leurs destinations avant les autres trains.]]

LNG.stat_tr_dropped_title = [[Pourquoi ne marchez-vous pas ?]]
LNG.stat_tr_dropped = [[_TRAINNAME_ [_AINAME_] à gauche _NUMBER_ passagers au milieu de nulle part !]]
LNG.stat_tr_dropped_sing = [[_TRAINNAME_ [_AINAME_] à gauche _NUMBER_ passager dans le milieu de nulle part !]]

LNG.stat_tr_blocked_title = [[La ligne est occupée...]]
LNG.stat_tr_blocked = [[_TRAINNAME_ [_AINAME_] a été bloqué pour un total de _NUMBER_ secondes.]]

-------------------------------------------------
-- MESSAGE BOX:
-------------------------------------------------
LNG.exit_confirm = [[Êtes vous sûr de vouloir quittez ?]]
LNG.confirm_resolution = [[Gardez cette nouvelle résolution ?]]
LNG.agree = [[Oui]]
LNG.disagree = [[Non]]
LNG.cancel = [[Annuler]]

-------------------------------------------------
-- ERRORS:
-------------------------------------------------
LNG.err_already_generating_map = [[Commence la génération d'une nouvelle carte ! Attendez que le processus se termine ...]]
LNG.err_wait_for_rendering = [[Attendez que le rendu prenne fin ...]]
LNG.err_rendering = [[Quelque chose a mal tourné dans un fil tout en générant la carte. Désolé à ce sujet, s'il vous plaît redémarrer le jeu et essayez à nouveau.]]
LNG.err_already_connecting = [[Déjà tentez de démarrez la connexion.]]

LNG.error_header = [[Oh non, il y avait une erreur !]]
LNG.error_steps = [[Si vous êtes en train de travaillez sur votre propre carte de défi, cela pourrait avoir été causé par votre défi. Vous pouvez obtenir de l'aide sur les forums:
http://www.indiedb.com/games/trainsported/forum

Si cela n'a pas été causé par votre propre code, vous pouvez signaler l'erreur sur la page des questions:
https://github.com/Germanunkol/trAInsported/issues

Appuyez sur 'c' pour copiez le message d'erreur dans votre presse-papiers.
Appuyez sur 'o' pour ouvrir le site GitHub questions.
Appuyez sur 'esc' pour fermer.
]]
LNG.error_copied = [[Copié !]]
