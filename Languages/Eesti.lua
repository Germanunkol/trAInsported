
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
LNG.menu_live = [[Otseülekanne]]
LNG.menu_live_tooltip = [[Saab näha võistluste otseülekandeid!]]
LNG.menu_tutorial = [[Sissejuhatus]]
LNG.menu_tutorial_tooltip = [[Õpetab kuidas mängida!]]
LNG.menu_challenge = [[Ülesanded]]
LNG.menu_challenge_tooltip = [[Saab lahendada ülesandeid! Mängu koduleheküljelt saab ülesandeid lisaks.]]
LNG.menu_compete = [[Võistlus]]
LNG.menu_compete_tooltip = [[Saab panna võistlusesse oma tehisintellekti.]]
LNG.menu_random = [[Juhuslik]]
LNG.menu_random_tooltip = [[Alustab juhusliku võistluse juhuslikul kaardil juhuslike tehisintellektidega.]]
LNG.menu_settings = [[Seaded]]
LNG.menu_settings_tooltip = [[Saab muuta keelt, ekraani suurust jne.]]
LNG.menu_exit = [[Sulge mäng]]

LNG.menu_return = [[Tagasi]]
LNG.menu_return_to_main_menu_tooltip = [[Läheb tagasi peamenüüsse.]]

LNG.menu_choose_ai = [[Vali tehisintellekt:]]
LNG.menu_choose_ai_tooltip = [[Kas soovid võistlusesse panna seda tehisintellekti?]]

LNG.menu_choose_dimensions = [[Kaardi mõõtmed:]]
LNG.menu_choose_dimensions_tooltip1 = [[Vali mitu ühikut laiust!]]
LNG.menu_choose_dimensions_tooltip2 = [[Vali mitu ühikut pikkust!]]

LNG.menu_choose_timemode = [[Toimumisaeg ja tüüp:]]
LNG.menu_time_name[1] = [[Päeval]]
LNG.menu_time_name[2] = [[Tipptunnil]]
LNG.menu_time_tooltip[1] = [[Keskmine arv reisijaid.]]
LNG.menu_time_tooltip[2] = [[Rohkem tähtsaid isikuid!]]
LNG.menu_mode_name[1] = [[Piiratud aeg]]
LNG.menu_mode_name[2] = [[Reisijate arv]]
LNG.menu_mode_tooltip[1] = [[Transpordi võimalikult palju reisijaid piiratud aja sees.]]
LNG.menu_mode_tooltip[2] = [[Reisijate arv piiratud. Võidab tehisintellekt, mis transpordib teistest rohkem reisijaid.]]

LNG.menu_choose_region = [[Piirkond:]]
LNG.menu_region_name[1] = [[Maal]]
LNG.menu_region_name[2] = [[Linnas]]
LNG.menu_region_tooltip[1] = [[Rahulik küla piirkond.]]
LNG.menu_region_tooltip[2] = [[Palju rohkem reisijaid kui küla piirkonnas.]]

LNG.menu_start = [[Alusta]]
LNG.menu_start_tooltip = [[Alustab võistlust nende seadetega!]]

LNG.menu_main_server = [[Mänguserver]]
LNG.menu_main_server_tooltip = [[Ühendub ametliku mänguserveriga. Internetiühenduse olemasolu on vajalik!]]
LNG.menu_local_server = [[Kohalik server]]
LNG.menu_local_server_tooltip = [[Ühendub kohaliku serveriga, mis jookseb sama masina peal.]]

-- Settings menu:
LNG.menu_settings_resolution = [[Ekraani suurus:]]
LNG.menu_resolution_tooltip = [[Vali uus ekraani suurus!]]
LNG.menu_settings_options = [[Muud valikud:]]
LNG.menu_clouds_on = [[Pilvine]]
LNG.menu_clouds_off = [[Pilvitu]]
LNG.menu_clouds_on_tooltip = [[Lülita pilved sisse.]]
LNG.menu_clouds_off_tooltip = [[Lülita pilved välja.]]
LNG.menu_settings_language = [[Keel:]]
LNG.menu_settings_language_tooltip1 = [[Vaheta kasutajaliidese keel]]	-- before lang name
LNG.menu_settings_language_tooltip2 = [[vastu]]	-- after lang name

-- Menu errors:
LNG.menu_err_min_ai = [[Vali vähemalt üks tehisintellekt!]]
LNG.menu_err_dimensions = [[Vali kaardi mõõtmed!]]
LNG.menu_err_mode = [[Vali võistluse tüüp!]]
LNG.menu_err_time = [[Viga võistluse toimumisaeg!]]
LNG.menu_err_resolution = [[Esines viga ekraani suuruse muutmisel!]]


-------------------------------------------------
-- INGAME:
-------------------------------------------------
-- Fast forward message:
LNG.fast_forward = [[MÄNG KIIRENDATUD, ET JÕUDA JÄRGI SERVERILE]]
LNG.confirm_leave = [[Kas soovid minna tagasi menüüsse?]]

LNG.open_folder = [[Ava kataloog]]
LNG.open_folder_tooltip = [[Avab kataloogi: AI_FOLDER_DIRECTORY]] -- AI_FOLDER_DIRECTORY will be replaced by the game with the correct directory.

LNG.reload = [[Lae uuesti]]
LNG.reload_confirm = [[Kas soovid taaskäivitada tehisintellektid?]]
LNG.reload_tooltip = [[Laeb uuesti tehisintellekti koodi ja taaskäivitab võistluse.]]
LNG.disconnect = [[Lõpeta mäng]]
LNG.end_match = [[Lõpeta mäng]]

LNG.speed_up = [[Kiirendab mängu.]]
LNG.slow_down = [[Aeglustab mängu.]]
LNG.pause = [[Peatab mängu hetkeks.]]

LNG.by = [[]]
LNG.transported = [[Transporditud:]]
-- the following three strings are for the string "X of Y passengers"
LNG.transported1 = [[]]		-- before X
LNG.transported2 = [[ / ]]		-- between X and Y
LNG.transported3 = [[ reisijast]]		-- after Y

LNG.round_ends = [[Võistluse lõpuni:]]
LNG.seconds = [[s]]
LNG.minutes = [[m]]
LNG.hours = [[t]]
LNG.days = [[p]]
LNG.end_of_match = [[Võistlus on läbi!]]

LNG.live_match = [[OTSEÜLEKANNE]]
LNG.lost_connection = [[ÜHENDUS KATKES]]

-------------------------------------------------
-- LOADING SCREEN:
-------------------------------------------------
LNG.load_new_map = [[Uus kaart]]
LNG.load_map_size = [[Mõõtmed: ]]
LNG.load_map_time = [[Toimumisaeg: ]]
LNG.load_map_mode_time = [[Tüüp: Piiratud aeg: ]]
LNG.load_map_mode_passengers = [[Tüüp: Reisijate arv]]
LNG.load_generating_map = [[Genereerib kaarti]]
LNG.load_rendering_map = [[Renderdab kaarti]]
LNG.load_connecting = [[Loob ühendust]]
LNG.load_failed = [[Ebaõnnestus!]]
-- leave ["rails"] etc, just translate the right part of the equal sign:
LNG.load_generation["rails"] = [[Rööpad]]
LNG.load_generation["houses"] = [[Majad]]
LNG.load_generation["hotspots"] = [[Huvipunktid]]

-------------------------------------------------
-- ROUND END STATISTICS:
-------------------------------------------------
-- The round statistics here are placed together using these strings as base. Some have versions in plural and in singular forms. If there's no difference in your language, please just copy the one version into both strings - do NOT delete the singular form!
-- In these strings, _AINAME_ and _NUMBER_ will be replaced by the appropriate values, so make sure to include them!
LNG.stat_most_picked_up_title = [[Külalislahke]]
LNG.stat_most_picked_up = [[Tehisintellekt _AINAME_ võttis peale _NUMBER_ reisijat.]]
LNG.stat_most_picked_up_sing = [[Tehisintellekt _AINAME_ võttis peale _NUMBER_ reisija.]]

LNG.stat_most_trains_title = [[Kollektsionäär]]
LNG.stat_most_trains = [[Tehisintellekt _AINAME_ ostis _NUMBER_ rongi.]]
LNG.stat_most_trains_sing = [[Tehisintellekt _AINAME_ ostis _NUMBER_ rongi.]]

LNG.stat_most_transported_title = [[Usaldusväärne]]
LNG.stat_most_transported = [[Tehisintellekt _AINAME_ transportis _NUMBER_ reisijat nende sihtkohta.]]
LNG.stat_most_transported_sing = [[Tehisintellekt _AINAME_ transportis _NUMBER_ reisija tema sihtkohta.]]

LNG.stat_most_normal_transported_title = [[Sotsialist]]
LNG.stat_most_normal_transported = [[Tehisintellekt _AINAME_ transportis _NUMBER_ reisijat olenemata nende staatusest.]]
LNG.stat_most_normal_transported_sing = [[Tehisintellekt _AINAME_ transportis _NUMBER_ reisija olenemata tema staatusest.]]

LNG.stat_dropped_title = [[Väljaviskaja]]
LNG.stat_dropped = [[Tehisintellekt _AINAME_ transportis _NUMBER_ sinna kuhu nad ei soovinud tegelikult minna.]]
LNG.stat_dropped_sing = [[Tehisintellekt _AINAME_ transportis _NUMBER_ sinna kuhu ta ei soovinud tegelikult minna.]]

LNG.stat_most_money_title = [[Kapitalist]]
LNG.stat_most_money = [[Tehisintellekt _AINAME_ teenis kokku _NUMBER_.]]

-- Some of the following can take up to three arguments: _NUMBER_, _AINAME_ and _TRAINNAME_:
LNG.stat_tr_most_picked_up_title = [[Töökas ja kiire]]
LNG.stat_tr_most_picked_up = [[_TRAINNAME_ (tehisintellektiga _AINAME_) võttis peale rohkem reisijaid kui teised.]]

LNG.stat_tr_most_transported_title = [[Tubli kaardilugeja]]
LNG.stat_tr_most_transported = [[_TRAINNAME_ (tehisintellektiga _AINAME_) transportis teistest rohkem reisjiaid nende sihtkohta.]]

LNG.stat_tr_dropped_title = [[Käi jala!]]
LNG.stat_tr_dropped = [[_TRAINNAME_ (tehisintellektiga _AINAME_) jättis _NUMBER_ reisijat maha.]]
LNG.stat_tr_dropped_sing = [[_TRAINNAME_ (tehisintellektiga _AINAME_) jättis _NUMBER_ reisija maha.]]

LNG.stat_tr_blocked_title = [[Ummikus]]
LNG.stat_tr_blocked = [[_TRAINNAME_ (tehisintellektiga _AINAME_) oli blokeeritud _NUMBER_ sekundit.]]

-------------------------------------------------
-- MESSAGE BOX:
-------------------------------------------------
LNG.exit_confirm = [[Kas oled kindel?]]
LNG.confirm_resolution = [[Kas jätab selle uue ekraani suuruse?]]
LNG.agree = [[Jah]]
LNG.disagree = [[Ei]]
LNG.cancel = [[Katkesta]]

-------------------------------------------------
-- ERRORS:
-------------------------------------------------
LNG.err_already_generating_map = [[Juba tegeleb kaardiga. Palun oota...]]
LNG.err_wait_for_rendering = [[Palun oota...]]
LNG.err_rendering = [[Midagi läks nihu. Vabandust, palun sulge mäng ja käivita uuesti.]]
LNG.err_already_connecting = [[Juba üritan luua ühendust.]]

LNG.error_header = [[Oi ei, esines viga!]]
LNG.error_steps = [[Kui see viga tekkis oma kaardi loomisega, siis tõenäoliselt on probleem sinu koodis. Abi saab foorumist:
http://www.indiedb.com/games/trainsported/forum

Kui see ei ole sinu kood tõttu, siis sul on võimalik postitada see veateade sinna:
https://github.com/Germanunkol/trAInsported/issues

Vajuta 'c', et kopeerida veateade.
Vajuta 'o', et avada veateadete postitamise leht.
Sulgemiseks vajuta 'esc'.
]]
LNG.error_copied = [[Veateade kopeeritud!]]
