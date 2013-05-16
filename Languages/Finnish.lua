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
LNG.menu_live = [[Ottelut verkossa]]
LNG.menu_live_tooltip = [[Katso suoria otteluita verkossa]]
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
LNG.menu_settings_resolution = [[Ruudun resoluutio:]]
LNG.menu_resolution_tooltip = [[Valitse uusi resoluutio]]
LNG.menu_settings_options = [[Asetukset:]]
LNG.menu_clouds_on = [[Pilvet: Kyllä]]
LNG.menu_clouds_off = [[Pilvet: Ei]]
LNG.menu_clouds_on_tooltip = [[Ota pilvet käyttöön]]
LNG.menu_clouds_off_tooltip = [[Ota pilvet pois käytöstä]]
LNG.menu_settings_language = [[Kieli:]]
LNG.menu_settings_language_tooltip1 = [[Valitse kieleksi: ]]  -- before lang name
LNG.menu_settings_language_tooltip2 = [[]]	-- after lang name

-- Menu errors:
LNG.menu_err_min_ai = [[Sinun tulee valita vähintään yksi tekoäly!]]
LNG.menu_err_dimensions = [[Kartan koko virheellinen!]]
LNG.menu_err_mode = [[Pelityyppi virheellinen!]]
LNG.menu_err_time = [[Peliaika virheellinen!]]
LNG.menu_err_resolution = [[Resoluution käyttöönotto epäonnistui!]]


-------------------------------------------------
-- INGAME:
-------------------------------------------------
-- Fast forward message:
LNG.fast_forward = [[Kelataan pelitapahtumia, että päästään samaan tilanteeseen palvelimen kanssa]]
LNG.confirm_leave = [[Poistu nykyisestä ottelusta ja palaa päävalikkoon?]]

LNG.open_folder = [[Avaa kansio]]
LNG.open_folder_tooltip = [[Avaa kansion: AI_FOLDER_DIRECTORY]] -- AI_FOLDER_DIRECTORY will be replaced by the game with the correct directory.

LNG.reload = [[Päivitä]]
LNG.reload_confirm = [[Päivitä tekoälyt?]]
LNG.reload_tooltip = [[Lataa päivitetyt tekoälyt ja aloittaa ottelun alusta.]]
LNG.disconnect = [[Katkaise yhteys]]
LNG.end_match = [[Päätä ottelu]]

LNG.speed_up = [[Nopeuta peliä]]
LNG.slow_down = [[Hidasta peliä]]
LNG.pause = [[Pysäytä peli]]

LNG.by = [[]]   -- by author
LNG.transported = [[Kuljetettu]]
-- the following three strings are for the string "X of Y passengers"
LNG.transported1 = [[]]		-- before X
LNG.transported2 = [[ / ]]		-- between X and Y
LNG.transported3 = [[ matkustajaa]]		-- after Y

LNG.round_ends = [[Ottelua jäljellä]]
LNG.seconds = [[s]]
LNG.minutes = [[min]]
LNG.hours = [[tuntia]]
LNG.days = [[päivää]]
LNG.end_of_match = [[Ottelu on päättynyt!]]

LNG.live_match = [[Suora ottelu]]
LNG.lost_connection = [[Yhteys katkennut]]

-------------------------------------------------
-- LOADING SCREEN:
-------------------------------------------------
LNG.load_new_map = [[Uusi kartta]]
LNG.load_map_size = [[Koko: ]]
LNG.load_map_time = [[Aika: ]]
LNG.load_map_mode_time = [[Pelityyppi: Ottelun ajankohta: ]]
LNG.load_map_mode_passengers = [[Pelityyppi: Kuljeta eniten matkustajia]]
LNG.load_generating_map = [[Luodaan karttaa]]
LNG.load_rendering_map = [[Renderöidään karttaa]]
LNG.load_connecting = [[Yhdistetään]]
LNG.load_failed = [[Epäonnistui!]]
-- leave ["rails"] etc, just translate the right part of the equal sign:
LNG.load_generation["rails"] = [[Radat]]
LNG.load_generation["houses"] = [[Talot]]
LNG.load_generation["hotspots"] = [[Ruuhkapisteet]]

-------------------------------------------------
-- ROUND END STATISTICS:
-------------------------------------------------
-- The round statistics here are placed together using these strings as base. Some have versions in plural and in singular forms. If there's no difference in your language, please just copy the one version into both strings - do NOT delete the singular form!
-- In these strings, _AINAME_ and _NUMBER_ will be replaced by the appropriate values, so make sure to include them!
LNG.stat_most_picked_up_title = [[Vieraanvaraisuus]]
LNG.stat_most_picked_up = [[Tekoäly _AINAME_ poimi kyytiin _NUMBER_ matkustajaa.]]
LNG.stat_most_picked_up_sing = [[Tekoäly _AINAME_ poimi kyytiin _NUMBER_ matkustajan.]]

LNG.stat_most_trains_title = [[Junanrakentaja]]
LNG.stat_most_trains = [[Tekoäly _AINAME_ hankki _NUMBER_ junaa.]]
LNG.stat_most_trains_sing = [[Tekoäly _AINAME_ hankki _NUMBER_ junan.]]

LNG.stat_most_transported_title = [[Ansainnut palkkansa]]
LNG.stat_most_transported = [[Tekoäly _AINAME_ kuljetti _NUMBER_ matkustajaa heidän päämääräänsä.]]
LNG.stat_most_transported_sing = [[Tekoäly _AINAME_ kuljetti _NUMBER_ matkustajan hänen päämääräänsä.]]

LNG.stat_most_normal_transported_title = [[Sosialisti]]
LNG.stat_most_normal_transported = [[Tekoäly _AINAME_ kuljetti _NUMBER_  ei VIP matkustajaa heidän päämääräänsä.]]
LNG.stat_most_normal_transported_sing = [[Tekoäly _AINAME_ kuljetti _NUMBER_ ei VIP matkustajan hänen päämääräänsä.]]

LNG.stat_dropped_title = [[Häivy!]]
LNG.stat_dropped = [[Tekoäly _AINAME_ jätti _NUMBER_ matkustajaa radanvarteen.]]
LNG.stat_dropped_sing = [[Tekoäly _AINAME_ jätti _NUMBER_ matkustajan radanvarteen.]]

LNG.stat_most_money_title = [[Kapitalisti]]
LNG.stat_most_money = [[Tekoäly _AINAME_ ansaitsi _NUMBER_ krediittiä.]]

-- Some of the following can take up to three arguments: _NUMBER_, _AINAME_ and _TRAINNAME_:
LNG.stat_tr_most_picked_up_title = [[Ahkera pikku mehiläinen]]
LNG.stat_tr_most_picked_up = [[Juna _TRAINNAME_ [_AINAME_] poimi kyytiin eniten matkustajia.]]

LNG.stat_tr_most_transported_title = [[Oma koti kullan kallis]]
LNG.stat_tr_most_transported = [[Juna _TRAINNAME_ [_AINAME_] kuljetti perille eniten matkustajia.]]

LNG.stat_tr_dropped_title = [[Entä jos kävelisit?]]
LNG.stat_tr_dropped = [[Juna _TRAINNAME_ [_AINAME_] jätti _NUMBER_ matkustajaa radanvarteen.]]
LNG.stat_tr_dropped_sing = [[Juna _TRAINNAME_ [_AINAME_] jätti _NUMBER_ matkustajan radanvarteen.]]

LNG.stat_tr_blocked_title = [[Raide varattu...]]
LNG.stat_tr_blocked = [[Juna _TRAINNAME_ [_AINAME_] oli juuttuneena ruuhkaan yhteensä _NUMBER_ sekuntia.]]

-------------------------------------------------
-- MESSAGE BOX:
-------------------------------------------------
LNG.exit_confirm = [[Haluatko varmasti lopettaa?]]
LNG.confirm_resolution = [[Pidä uusi resoluutio?]]
LNG.agree = [[Kyllä]]
LNG.disagree = [[Ei]]
LNG.cancel = [[Peruuta]]

-------------------------------------------------
-- ERRORS:
-------------------------------------------------
LNG.err_already_generating_map = [[Luodaan uutta karttaa. Odota että prosessi valmistuu...]]
LNG.err_wait_for_rendering = [[Odota että renderöinti valmistuu...]]
LNG.err_rendering = [[Kartan luonti epäonnistui. Pahoittelut, käynnistä peli uudelleen ja yritä uudestaan.]]
LNG.err_already_connecting = [[Yhteyden muodostaminen menossa]]
