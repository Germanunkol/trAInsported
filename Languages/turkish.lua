
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
LNG.menu_live = [[Canlı]]
LNG.menu_live_tooltip = [[Canlı online oyunları izle!]]
LNG.menu_tutorial = [[Rehber]]
LNG.menu_tutorial_tooltip = [[Oyuna alış!]]
LNG.menu_challenge = [[Meydan oku!]]
LNG.menu_challenge_tooltip = [[Meydan okuma haritalarını kazan! Oyunun web sitesinden daha çok harita indirebilirsin.]]
LNG.menu_compete = [[Yarış]]
LNG.menu_compete_tooltip = [[Kendi Yapay Zekan(AI) için bir test maçı oluştur]]
LNG.menu_random = [[Rastgele]]
LNG.menu_random_tooltip = [['AI' klasöründeki AI'larını rastgele bir şekilde rastgele bir haritada kullanarak rastgele bir oyun oluştur.]]
LNG.menu_settings = [[Ayarlar]]
LNG.menu_settings_tooltip = [[Dil değiştir, çözünürlük vb.]]
LNG.menu_exit = [[Çıkış]]

LNG.menu_return = [[Geri dön]]
LNG.menu_return_to_main_menu_tooltip = [[Ana menüye geri dön]]

LNG.menu_choose_ai = [[Bu oyun için AI'ını seç:]]
LNG.menu_choose_ai_tooltip = [[Bu AI'ı seçmek istediğinize emin misiniz?]]

LNG.menu_choose_dimensions = [[Genişlik ve Uzunluk:]]
LNG.menu_choose_dimensions_tooltip1 = [[Genişliği seç]]
LNG.menu_choose_dimensions_tooltip2 = [[Uzunluğu seç]]

LNG.menu_choose_timemode = [[Zaman ve mod:]]
LNG.menu_time_name[1] = [[Gün]]
LNG.menu_time_name[2] = [[Rushhour]]
LNG.menu_time_tooltip[1] = [[Normal kurulum, Ortalama yolcu sayısı]]
LNG.menu_time_tooltip[2] = [[Daha fazla VIP!]]
LNG.menu_mode_name[1] = [[Zaman limiti]]
LNG.menu_mode_name[2] = [[Yolcular]]
LNG.menu_mode_tooltip[1] = [[Belirli bir sürede en fazla yolcuyu taşı.]]
LNG.menu_mode_tooltip[2] = [[Belirli sayıda yolcu. Diğer herhangi bir AI'dan daha fazla taşımaya çalış.]]

LNG.menu_choose_region = [[Bölge:]]
LNG.menu_region_name[1] = [[Rural]]
LNG.menu_region_name[2] = [[Urban]]
LNG.menu_region_tooltip[1] = [[Huzurlu kasaba ayarı.]]
LNG.menu_region_tooltip[2] = [[Rural ayarının iki katı kadar yolcu sayısı.]]

LNG.menu_start = [[Başlat]]
LNG.menu_start_tooltip = [[Oyunu bu ayarlarla başlat]]

LNG.menu_main_server = [[Ana sunucu]]
LNG.menu_main_server_tooltip = [[Ana sunucuya bağlan. İnternet'e bağlı olmanız gerekmektedir!]]
LNG.menu_local_server = [[Yerel sunucu]]
LNG.menu_local_server_tooltip = [[Bu makinede çalışan bir sunucuya bağlan]]

-- Settings menu:
LNG.menu_settings_resolution = [[Ekran boyutu:]]
LNG.menu_resolution_tooltip = [[Yeni ekran çözünürlüğü belirle]]
LNG.menu_settings_options = [[Seçenekler:]]
LNG.menu_clouds_on = [[Bulut: Açık]]
LNG.menu_clouds_off = [[Bulut: Kapalı]]
LNG.menu_clouds_on_tooltip = [[Bulutların işlenmesini etkinleştirmek için tıkla.]]
LNG.menu_clouds_off_tooltip = [[Bulutların işlenmesini devre dışı bırakmak için tıkla.]]
LNG.menu_settings_language = [[Dil:]]
LNG.menu_settings_language_tooltip1 = [[Oyunun dilini]]  -- before lang name
LNG.menu_settings_language_tooltip2 = [['ya çevirmek için tıkla]]	-- after lang name

-- Menu errors:
LNG.menu_err_min_ai = [[En az bir AI seçmelisiniz!]]
LNG.menu_err_dimensions = [[Geçersiz harita boyutları!]]
LNG.menu_err_mode = [[Geçersiz oyun modu!]]
LNG.menu_err_time = [[Geçersiz oyun zamanı!]]
LNG.menu_err_resolution = [[Çözünürlük ayarlanamadı!]]


-------------------------------------------------
-- INGAME:
-------------------------------------------------
-- Fast forward message:
LNG.fast_forward = [[SUNUCUYU YAKALAMAK İÇİN HIZLANDIRILIYOR]]
LNG.confirm_leave = [[Şu anki maçı bırakıp ana menüye dönmek istiyor musunuz?]]

LNG.open_folder = [[Klasörü aç]]
LNG.open_folder_tooltip = [[Şu klasörü açar: AI_FOLDER_DIRECTORY]] -- AI_FOLDER_DIRECTORY will be replaced by the game with the correct directory.

LNG.reload = [[Yeniden yükle]]
LNG.reload_confirm = [[AI'ları yeniden yükle?]]
LNG.reload_tooltip = [[AI'ları yeniden yükleyip raundu yeniden başlatır.]]
LNG.disconnect = [[Bağlantıyı kes]]
LNG.end_match = [[Maçı bitir]]

LNG.speed_up = [[Oyunu hızlandırır]]
LNG.slow_down = [[Oyunu yavaşlatır]]
LNG.pause = [[Oyunu durdurur]]

LNG.by = [[by]]
LNG.transported = [[Transported]]
-- the following three strings are for the string "X of Y passengers"
LNG.transported1 = [[]]		-- before X
LNG.transported2 = [[/]]		-- between X and Y
LNG.transported3 = [[ yolcu]]		-- after Y

LNG.round_ends = [[Raund bitimine]]
LNG.seconds = [[san]]
LNG.minutes = [[dak]]
LNG.hours = [[s]]
LNG.days = [[gün]]
LNG.end_of_match = [[Maç sona erdi!]]

LNG.live_match = [[CANLI KARŞILAŞMA]]
LNG.lost_connection = [[BAĞLANTI KAYBI]]

-------------------------------------------------
-- LOADING SCREEN:
-------------------------------------------------
LNG.load_new_map = [[Yeni Harita]]
LNG.load_map_size = [[Boyut: ]]
LNG.load_map_time = [[Süre: ]]
LNG.load_map_mode_time = [[Mod: Raund süresi: ]]
LNG.load_map_mode_passengers = [[Mod: Yeterince yolcuyu gitmek istenilen yere ulaştır.]]
LNG.load_generating_map = [[Harita oluşturuluyor]]
LNG.load_rendering_map = [[Harita çiziliyor]]
LNG.load_connecting = [[Bağlanıyor]]
LNG.load_failed = [[Yükleme başarısız!]]
-- leave ["rails"] etc, just translate the right part of the equal sign:
LNG.load_generation["rails"] = [[Raylar]]
LNG.load_generation["houses"] = [[Evler]]
LNG.load_generation["hotspots"] = [[Kilit noktalar]]

-------------------------------------------------
-- ROUND END STATISTICS:
-------------------------------------------------
-- The round statistics here are placed together using these strings as base. Some have versions in plural and in singular forms. If there's no difference in your language, please just copy the one version into both strings - do NOT delete the singular form!
-- In these strings, _AINAME_ and _NUMBER_ will be replaced by the appropriate values, so make sure to include them!
LNG.stat_most_picked_up_title = [[Konukseverlik]]
LNG.stat_most_picked_up = [[AI _AINAME_, _NUMBER_ yolcu aldı.]]
LNG.stat_most_picked_up_sing = [[AI _AINAME_, _NUMBER_ yolcu aldı.]]

LNG.stat_most_trains_title = [[Fleetus Maximus]]
LNG.stat_most_trains = [[AI _AINAME_, _NUMBER_'e sahip oldu.]]
LNG.stat_most_trains_sing = [[AI _AINAME_, _NUMBER_'e sahip oldu.]]

LNG.stat_most_transported_title = [[Earned your pay]]
LNG.stat_most_transported = [[AI _AINAME_, _NUMBER_ yolcuyu yerine ulaştırdı.]]
LNG.stat_most_transported_sing = [[AI _AINAME_, _NUMBER_ yolcuyu yerine ulaştırdı.]]

LNG.stat_most_normal_transported_title = [[Socialist]]
LNG.stat_most_normal_transported = [[AI _AINAME_, _NUMBER_ non-VIP yolcuyu yerine ulaştırdı]]
LNG.stat_most_normal_transported_sing = [[AI _AINAME_, _NUMBER_ non-VIP yolcuyu yerine ulaştırdı.]]

LNG.stat_dropped_title = [[Get lost...]]
LNG.stat_dropped = [[AI _AINAME_, _NUMBER_ yolcuyu istenilmeyen yerde indirdi.]]
LNG.stat_dropped_sing = [[AI _AINAME_, _NUMBER_ yolcuyu istenilmeyen yerde indirdi.]]

LNG.stat_most_money_title = [[Capitalist]]
LNG.stat_most_money = [[AI _AINAME_, _NUMBER_ kredi kazandı.]]

-- Some of the following can take up to three arguments: _NUMBER_, _AINAME_ and _TRAINNAME_:
LNG.stat_tr_most_picked_up_title = [[Busy little Bee!]]
LNG.stat_tr_most_picked_up = [[_TRAINNAME_ [_AINAME_] bütün trenlerden daha fazla yolcu aldı.]]

LNG.stat_tr_most_transported_title = [[Home sweet Home]]
LNG.stat_tr_most_transported = [[_TRAINNAME_ [_AINAME_] bütün trenlerden daha fazla yolcuyu yerine ulaştırdı.]]

LNG.stat_tr_dropped_title = [[Why don't you walk?]]
LNG.stat_tr_dropped = [[_TRAINNAME_ [_AINAME_], _NUMBER_ yolcunun kaybolmasına sebep oldu!]]
LNG.stat_tr_dropped_sing = [[_TRAINNAME_ [_AINAME_], _NUMBER_ yolcunun kaybolmasına sebep oldu!]]

LNG.stat_tr_blocked_title = [[Line is busy...]]
LNG.stat_tr_blocked = [[_TRAINNAME_ [_AINAME_], _NUMBER_ saniye engelli kaldı.]]

-------------------------------------------------
-- MESSAGE BOX:
-------------------------------------------------
LNG.exit_confirm = [[Gerçekten çıkmak istiyor musunuz?]]
LNG.confirm_resolution = [[Yeni çözünürlükte kalınsın mı?]]
LNG.agree = [[Evet]]
LNG.disagree = [[Hayır]]
LNG.cancel = [[İptal]]

-------------------------------------------------
-- ERRORS:
-------------------------------------------------
LNG.err_already_generating_map = [[Zaten başka bir harita oluşturulmaya çalışılıyor! İşlemin bitmesini bekleyin...]]
LNG.err_wait_for_rendering = [[Çizimler bekleniyor...]]
LNG.err_rendering = [[Üzgünüz, harita oluşturulurken bir hata oluştu. Lütfen oyunu yeniden başlatıp tekrar deneyin.]]
LNG.err_already_connecting = [[Zaten bağlanılmaya çalışılıyor.]]
