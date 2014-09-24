
-- Language file for trAInsported. Make a copy of this to translate into your own language.
-- Please don't change the order of the entries in this file.
FONT_BUTTON = love.graphics.newFont( "UbuntuFont/Ubuntu-B.ttf", 17 )
FONT_BUTTON_SMALL = love.graphics.newFont( "UbuntuFont/Ubuntu-B.ttf", 16 )

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
LNG.menu_live_tooltip = [[Beobachte die hochgeladenen KIs in Online-Spielen!]]
LNG.menu_tutorial = [[Anleitung]]
LNG.menu_tutorial_tooltip = [[Lerne das Spiel und die Programmiersprache]]
LNG.menu_challenge = [[Herausforderung]]
LNG.menu_challenge_tooltip = [[Karten mit speziellen Zielen]]
LNG.menu_compete = [[Wettstreit]]
LNG.menu_compete_tooltip = [[Wähle KIs und eine Karte aus und lasse sie gegeneinander antreten!]]
LNG.menu_random = [[Zufällig]]
LNG.menu_random_tooltip = [[Zufällige Karte mit einer zufälligen Auswahl von KIs aus dem 'AI' Ordner.]]
LNG.menu_settings = [[Optionen]]
LNG.menu_settings_tooltip = [[Sprachauswahl, Bildschirmgröße etc]]
LNG.menu_exit = [[Schließen]]

LNG.menu_return = [[Zurück]]
LNG.menu_return_to_main_menu_tooltip = [[Zurück ins Hauptmenü]]

LNG.menu_choose_ai = [[Wähle KIs für die Runde:]]
LNG.menu_choose_ai_tooltip = [[Soll diese Künstliche Intelligenz teilnehmen?]]

LNG.menu_choose_dimensions = [[Kartendimensionen:]]
LNG.menu_choose_dimensions_tooltip1 = [[Breite]]
LNG.menu_choose_dimensions_tooltip2 = [[Höhe]]

LNG.menu_choose_timemode = [[Spielzeit und Modus:]]
LNG.menu_time_name[1] = [[Tagsüber]]
LNG.menu_time_name[2] = [[Rushhour]]
LNG.menu_time_tooltip[1] = [[Durchschnittlich viele Passagiere]]
LNG.menu_time_tooltip[2] = [[Viele VIPs!]]
LNG.menu_mode_name[1] = [[Zeitlimit]]
LNG.menu_mode_name[2] = [[Passagiere]]
LNG.menu_mode_tooltip[1] = [[Transportiere die Passagiere bevor die Zeit vorbei ist.]]
LNG.menu_mode_tooltip[2] = [[Vorberechnete maximale Anzahl von Passagieren.]]

LNG.menu_choose_region = [[Region:]]
LNG.menu_region_name[1] = [[Ländlich]]
LNG.menu_region_name[2] = [[Stadt]]
LNG.menu_region_tooltip[1] = [[Ruhige Landschaft.]]
LNG.menu_region_tooltip[2] = [[Doppelte Anzahl von Passagieren.]]

LNG.menu_start = [[Starten]]
LNG.menu_start_tooltip = [[Generiere die Karte mit den ausgewählten Optionen.]]

LNG.menu_main_server = [[Haupt-Server]]
LNG.menu_main_server_tooltip = [[Mit dem offiziellen Spielserver verbinden. Benötigt Internetverbindung!]]
LNG.menu_local_server = [[Localhost]]
LNG.menu_local_server_tooltip = [[Mit lokalem Server verbinden.]]

-- Settings menu:
LNG.menu_settings_resolution = [[Auflösung:]]
LNG.menu_resolution_tooltip = [[Auflösung ändern]]
LNG.menu_settings_options = [[Optionen:]]
LNG.menu_clouds_on = [[Wolken: An]]
LNG.menu_clouds_off = [[Wolken: Aus]]
LNG.menu_clouds_on_tooltip = [[Wolken anschalten.]]
LNG.menu_clouds_off_tooltip = [[Wolken ausschalten.]]
LNG.menu_fullscreen_on = [[Vollbild: An]]
LNG.menu_fullscreen_off = [[Vollbild: Aus]]
LNG.menu_fullscreen_on_tooltip = [[Vollbild einschalten]]
LNG.menu_fullscreen_off_tooltip = [[Vollbild ausschalten]]
LNG.menu_settings_language = [[Sprache:]]
LNG.menu_settings_language_tooltip1 = [[Sprache zu]]	-- before lang name
LNG.menu_settings_language_tooltip2 = [[ändern]]	-- after lang name

-- Menu errors:
LNG.menu_err_min_ai = [[Mindestens eine KI benötigt!]]
LNG.menu_err_dimensions = [[Falsche Kartengröße!]]
LNG.menu_err_mode = [[Ungültiger Spielmodus!]]
LNG.menu_err_time = [[Ungültige Spielzeit!]]
LNG.menu_err_resolution = [[Konnte die Auflösung nicht einstellen!]]


-------------------------------------------------
-- INGAME:
-------------------------------------------------
-- Fast forward message:
LNG.fast_forward = [[Zeitraffer um mit Server zu synchronisieren]]
LNG.confirm_leave = [[Momentanes Match verlassen?]]

LNG.open_folder = [[Ordner öffnen]]
LNG.open_folder_tooltip = [[Öffnet den Ordner: AI_FOLDER_DIRECTORY]] -- AI_FOLDER_DIRECTORY will be replaced by the game with the correct directory.

LNG.reload = [[Neu Laden]]
LNG.reload_confirm = [[Runde neu starten?]]
LNG.reload_tooltip = [[Lädt die KIs neu und startet dann die Runde neu.]]
LNG.disconnect = [[Trennen]]
LNG.end_match = [[Match beenden]]

LNG.speed_up = [[Beschleunigt Spiel]]
LNG.slow_down = [[Verlangsamt Spiel]]
LNG.pause = [[Pausiert Spiel]]

LNG.by = [[von]]
LNG.transported = [[Bereits transportiert:]]
-- the following three strings are for the string "X of Y passengers"
LNG.transported1 = [[]]	-- before X
LNG.transported2 = [[ von ]]	-- between X and Y
LNG.transported3 = [[ Passagieren]]	-- after Y

LNG.round_ends = [[Runde endet in]]
LNG.seconds = [[Sek]]
LNG.minutes = [[Min]]
LNG.hours = [[h]]
LNG.days = [[Tage]]
LNG.end_of_match = [[Runde ist vorbei!]]

LNG.live_match = [[ONLINE]]
LNG.lost_connection = [[VERBINDUNG UNTERBROCHEN]]

-------------------------------------------------
-- LOADING SCREEN:
-------------------------------------------------
LNG.load_new_map = [[Neue Karte]]
LNG.load_map_size = [[Größe: ]]
LNG.load_map_time = [[Zeit: ]]
LNG.load_map_mode_time = [[Modus: Max. Rundenzeit: ]]
LNG.load_map_mode_passengers = [[Modus: Max. Anzahl Passagiere]]
LNG.load_generating_map = [[Generiere Karte]]
LNG.load_rendering_map = [[Rendere Karte]]
LNG.load_connecting = [[Verbindung]]
LNG.load_failed = [[Fehlgeschlagen!]]
-- leave ["rails"] etc, just translate the right part of the equal sign:
LNG.load_generation["rails"] = [[Schienen]]
LNG.load_generation["houses"] = [[Häuser]]
LNG.load_generation["hotspots"] = [[Hotspots]]

-------------------------------------------------
-- ROUND END STATISTICS:
-------------------------------------------------
-- The round statistics here are placed together using these strings as base. Some have versions in plural and in singular forms. If there's no difference in your language, please just copy the one version into both strings - do NOT delete the singular form!
-- In these strings, _AINAME_ and _NUMBER_ will be replaced by the appropriate values, so make sure to include them!
LNG.stat_most_picked_up_title = [[Gastfreundschaft]]
LNG.stat_most_picked_up = [[KI _AINAME_ hat _NUMBER_ Passagiere aufgenommen.]]
LNG.stat_most_picked_up_sing = [[KI _AINAME_ hat _NUMBER_ Passagier aufgenommen.]]

LNG.stat_most_trains_title = [[Fleetus Maximus]]
LNG.stat_most_trains = [[KI _AINAME_ hat _NUMBER_ Züge gekauft.]]
LNG.stat_most_trains_sing = [[KI _AINAME_ hat _NUMBER_ Zug gekauft.]]

LNG.stat_most_transported_title = [[Hast's dir verdient!]]
LNG.stat_most_transported = [[KI _AINAME_ hat _NUMBER_ Passagiere ans Ziel befördert.]]
LNG.stat_most_transported_sing = [[KI _AINAME_ hat _NUMBER_ Passagier ans Ziel befördert.]]

LNG.stat_most_normal_transported_title = [[Sozialist]]
LNG.stat_most_normal_transported = [[KI _AINAME_ hat _NUMBER_ nicht-VIP Passagiere ans Ziel gebracht.]]
LNG.stat_most_normal_transported_sing = [[KI _AINAME_ hat _NUMBER_ nicht-VIP Passagier ans Ziel gebracht.]]

LNG.stat_dropped_title = [[Raus hier!]]
LNG.stat_dropped = [[KI _AINAME_ hat _NUMBER_ Passagiere zu früh abgesetzt.]]
LNG.stat_dropped_sing = [[KI _AINAME_ hat _NUMBER_ Passagier zu früh abgesetzt.]]

LNG.stat_most_money_title = [[Kapitalist]]
LNG.stat_most_money = [[KI _AINAME_ hat _NUMBER_ Credits verdient.]]

-- Some of the following can take up to three arguments: _NUMBER_, _AINAME_ and _TRAINNAME_:
LNG.stat_tr_most_picked_up_title = [[Einsteigen!]]
LNG.stat_tr_most_picked_up = [[_TRAINNAME_ [_AINAME_] hat mehr Passagiere als alle anderen Züge aufgenommen.]]

LNG.stat_tr_most_transported_title = [[Zu Hause...!]]
LNG.stat_tr_most_transported = [[_TRAINNAME_ [_AINAME_] hat mehr Passagiere an ihr Ziel gebracht als alle anderen Züge.]]

LNG.stat_tr_dropped_title = [[Lauf doch einfach!]]
LNG.stat_tr_dropped = [[_TRAINNAME_ [_AINAME_] hat _NUMBER_ Passagiere ausgesetzt!]]
LNG.stat_tr_dropped_sing = [[_TRAINNAME_ [_AINAME_] hat _NUMBER_ Passagier ausgesetzt!]]

LNG.stat_tr_blocked_title = [[Anstellen Bitte!]]
LNG.stat_tr_blocked = [[_TRAINNAME_ [_AINAME_] war _NUMBER_ Sekunden lang blockiert.]]

-------------------------------------------------
-- MESSAGE BOX:
-------------------------------------------------
LNG.exit_confirm = [[Spiel verlassen?]]
LNG.confirm_resolution = [[Diese neue Auflösung beibehalten?]]
LNG.agree = [[Ja]]
LNG.disagree = [[Nein]]
LNG.cancel = [[Abbrechen]]

-------------------------------------------------
-- ERRORS:
-------------------------------------------------
LNG.err_already_generating_map = [[Es wird bereits eine Karte generiert! Bitte abwarten...]]
LNG.err_wait_for_rendering = [[Es wird schon eine Karte gerendert...]]
LNG.err_rendering = [[Ein Fehler ist beim Rendern der Karte aufgetreten. Das tut mir Leid, bitte Spiel neu starten...]]
LNG.err_already_connecting = [[Es wird bereits eine Verbindung aufgebaut.]]

LNG.error_header = [[Oh nein, ein Fehler!]]
LNG.error_steps = [[Falls du gerade an deiner eigenen Herausforderungs-Karte gearbeitet hast (Challenge), hat der Fehler eventuell mit deinem Code zu tun. Falls du nicht weiter weißt findest du Hilfe unter:
http://www.indiedb.com/games/trainsported/forum

Falls es nicht an deinem Code lag, kannst du den Fehler hier in die Liste einfügen:
https://github.com/Germanunkol/trAInsported/issues

Die Taste 'c' kopiert die Fehlermeldung ins Clipboard.
Mit 'o' kannst du die Issues-Seite auf GitHub im Standardbrowser öffnen.
'Esc' beendet das Spiel.
]]
LNG.error_copied = [[Kopiert!]]
