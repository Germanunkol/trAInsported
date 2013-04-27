-- Language file for trAInsported. Make a copy of this to translate into your own language.
-- Please don't change the order of the entries in this file.

FONT_BUTTON = love.graphics.newFont( "UbuntuFont/Ubuntu-B.ttf", 16 )
FONT_BUTTON_SMALL = love.graphics.newFont( "UbuntuFont/Ubuntu-B.ttf", 15 )

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
LNG.menu_live = [[Live!]]
LNG.menu_live_tooltip = [[Прямая трансляция текущего матча!]]
LNG.menu_tutorial = [[Обучение]]
LNG.menu_tutorial_tooltip = [[Познакомиться с игрой!]]
LNG.menu_challenge = [[Испытания]]
LNG.menu_challenge_tooltip = [[Пройди все испытания! (Дополнительные карты на оффициальном веб-сайте).]]
LNG.menu_compete = [[Соревнования]]
LNG.menu_compete_tooltip = [[Организуй соревнования для своих ИИ!]]
LNG.menu_random = [[Случайный матч]]
LNG.menu_random_tooltip = [[Начать матч на случайной карте со случайно выбранными ИИ.]]
LNG.menu_settings = [[Настройки]]
LNG.menu_settings_tooltip = [[Смена языка, разрешения экрана и т.д.]]
LNG.menu_exit = [[Выход]]

LNG.menu_return = [[Назад]]
LNG.menu_return_to_main_menu_tooltip = [[Вернуться к основному меню.]]

LNG.menu_choose_ai = [[Выберите участников:]]
LNG.menu_choose_ai_tooltip = [[Выбрать этот ИИ для участия в соревновании.]]

LNG.menu_choose_dimensions = [[Размер карты:]]
LNG.menu_choose_dimensions_tooltip1 = [[Выберите ширину]]
LNG.menu_choose_dimensions_tooltip2 = [[Выберите высоту]]

LNG.menu_choose_timemode = [[Настройки режима:]]
LNG.menu_time_name[1] = [[День]]
LNG.menu_time_name[2] = [[Час пик]]
LNG.menu_time_tooltip[1] = [[Стандартный вариант - среднее количество пассажиров]]
LNG.menu_time_tooltip[2] = [[Больше VIP'ов!]]
LNG.menu_mode_name[1] = [[На время]]
LNG.menu_mode_name[2] = [[Пассажиры]]
LNG.menu_mode_tooltip[1] = [[Перевезите как можно боьше пассажиров за отведенное время.]]
LNG.menu_mode_tooltip[2] = [[Количество пассажиров на карте ограничено. Опереди соперников!]]

LNG.menu_choose_region = [[Ландшафт:]]
LNG.menu_region_name[1] = [[Сельский]]
LNG.menu_region_name[2] = [[Городской]]
LNG.menu_region_tooltip[1] = [[Спокойный сельский расклад.]]
LNG.menu_region_tooltip[2] = [[В два раза больше пассажиров на карте.]]

LNG.menu_start = [[Старт]]
LNG.menu_start_tooltip = [[Начать матч с этими настройками.]]

LNG.menu_main_server = [[Главный сервер]]
LNG.menu_main_server_tooltip = [[Подключиться к главному серверу. Требуется подключение к интернету!]]
LNG.menu_local_server = [[Свой сервер]]
LNG.menu_local_server_tooltip = [[Подключиться к серверу, запущеному на этом компьютере.]]

-- Settings menu:
LNG.menu_settings_resolution = [[Разрешение:]]
LNG.menu_resolution_tooltip = [[Установить новое разрешение экрана]]
LNG.menu_settings_options = [[Опции:]]
LNG.menu_clouds_on = [[Облака]]
LNG.menu_clouds_off = [[Без облаков]]
LNG.menu_clouds_on_tooltip = [[Нажмите, чтоб включить отображение облаков.]]
LNG.menu_clouds_off_tooltip = [[Нажмите, чтоб отключить отображение облаков.]]
LNG.menu_settings_language = [[Язык игры:]]
LNG.menu_settings_language_tooltip1 = [[Нажмите, чтоб сменить язык на ]]  -- before lang name
LNG.menu_settings_language_tooltip2 = [[]]	-- after lang name

-- Menu errors:
LNG.menu_err_min_ai = [[Необходимо выбрать хотя бы один ИИ!]]
LNG.menu_err_dimensions = [[Некорректный размер карты!]]
LNG.menu_err_mode = [[Некорректный режим игры!]]
LNG.menu_err_time = [[Некорректное время игры!]]
LNG.menu_err_resolution = [[Ошибка при смене разрешения!]]


-------------------------------------------------
-- INGAME:
-------------------------------------------------
-- Fast forward message:
LNG.fast_forward = [[ДОГОНЯЕМ СЕРВЕР]]
LNG.confirm_leave = [[Прервать текущий матч и выйти в главное меню?]]

LNG.open_folder = [[Открыть папку]]
LNG.open_folder_tooltip = [[Открыть папку: AI_FOLDER_DIRECTORY]]

LNG.reload = [[Рестарт]]
LNG.reload_confirm = [[Начать раунд заново?]]
LNG.reload_tooltip = [[Перезагрузка ИИ и начало нового раунда.]]
LNG.disconnect = [[Отключиться]]
LNG.end_match = [[Прервать матч]]

LNG.speed_up = [[Увеличить скорость игры]]
LNG.slow_down = [[Уменьшить скорость игры]]
LNG.pause = [[Пауза]]

LNG.by = [[автор]]
LNG.transported = [[Перевезено]]
-- the following three strings are for the string "X of Y passengers"
LNG.transported1 = [[]]    -- before X
LNG.transported2 = [[ из ]]		-- between X and Y
LNG.transported3 = [[ пассажиров]]		-- after Y

LNG.round_ends = [[Конец раунда через ]]		-- after Y
LNG.seconds = [[сек]]		-- after Y
LNG.minutes = [[мин]]		-- after Y
LNG.hours = [[ч]]		-- after Y
LNG.days = [[дней]]		-- after Y
LNG.end_of_match = [[Матч закончен!]]		-- after Y

LNG.live_match = [[ПРЯМАЯ ТРАНСЛЯЦИЯ]]
LNG.lost_connection = [[СОЕДИНЕНИЕ ПОТЕРЯНО]]

-------------------------------------------------
-- LOADING SCREEN:
-------------------------------------------------
LNG.load_new_map = [[Новая Карта]]
LNG.load_map_size = [[Размер: ]]
LNG.load_map_time = [[Время: ]]
LNG.load_map_mode_time = [[Режим: время ]]
LNG.load_map_mode_passengers = [[Режим: Пассажиры]]
LNG.load_generating_map = [[Генерация карты]]
LNG.load_rendering_map = [[Отрисовка карты]]
LNG.load_connecting = [[Соединение]]
LNG.load_failed = [[Ошибка!]]
-- leave ["rails"] etc, just translate the right part of the equal sign:
LNG.load_generation["rails"] = [[Пути]]
LNG.load_generation["houses"] = [[Дома]]
LNG.load_generation["hotspots"] = [[Ключевые точки]]

-------------------------------------------------
-- ROUND END STATISTICS:
-------------------------------------------------
-- The round statistics here are placed together using these strings as base. Some have versions in plural and in singular forms. If there's no difference in your language, please just copy the one version into both strings - do NOT delete the singular form!
-- In these strings, _AINAME_ and _NUMBER_ will be replaced by the appropriate values, so make sure to include them!
LNG.stat_most_picked_up_title = [[Гостеприимство]]
LNG.stat_most_picked_up = [[ИИ _AINAME_ взял на борт _NUMBER_ пассажиров.]]
LNG.stat_most_picked_up_sing = [[ИИ _AINAME_ взял на борт _NUMBER_ пассажира.]]

LNG.stat_most_trains_title = [[Флотус Максимус]]
LNG.stat_most_trains = [[ИИ _AINAME_ купил _NUMBER_ поездов.]]
LNG.stat_most_trains_sing = [[ИИ _AINAME_ купил _NUMBER_ поезд]]

LNG.stat_most_transported_title = [[Честно заработанные]]
LNG.stat_most_transported = [[ИИ _AINAME_ отвёз _NUMBER_ пассажиров до места назначения.]]
LNG.stat_most_transported_sing = [[ИИ _AINAME_ отвёз _NUMBER_ пассажира до места назначения.]]

LNG.stat_most_normal_transported_title = [[Социалист]]
LNG.stat_most_normal_transported = [[ИИ _AINAME_ отвёз _NUMBER_ не-VIP пассажиров до места назначения.]]
LNG.stat_most_normal_transported_sing = [[ИИ _AINAME_ отвёз _NUMBER_ не-VIP пассажира до места назначения.]]

LNG.stat_dropped_title = [[Я заблудился...]]
LNG.stat_dropped = [[ИИ _AINAME_ высадил _NUMBER_ пассажиров не в том месте.]]
LNG.stat_dropped_sing = [[ИИ _AINAME_ высадил _NUMBER_ пассажира не в том месте.]]

LNG.stat_most_money_title = [[Капиталист]]
LNG.stat_most_money = [[ИИ _AINAME_ заработал _NUMBER_ кредитов.]]

-- Some of the following can take up to three arguments: _NUMBER_, _AINAME_ and _TRAINNAME_:
LNG.stat_tr_most_picked_up_title = [[Трудился, как пчёлка!]]
LNG.stat_tr_most_picked_up = [[_TRAINNAME_ [_AINAME_] взял на борт больше всех пассажиров.]]

LNG.stat_tr_most_transported_title = [[Милый дом]]
LNG.stat_tr_most_transported = [[_TRAINNAME_ [_AINAME_] перевез больше всех пассажиров.]]

LNG.stat_tr_dropped_title = [[Почему бы вам не прогуляться?]]
LNG.stat_tr_dropped = [[_TRAINNAME_ [_AINAME_] высадил _NUMBER_ пассажиров неизвестно где!]]
LNG.stat_tr_dropped_sing = [[_TRAINNAME_ [_AINAME_] высадил _NUMBER_ пассажира неизвестно где!]]

LNG.stat_tr_blocked_title = [[Линия занята...]]
LNG.stat_tr_blocked = [[_TRAINNAME_ [_AINAME_] был заблокирован _NUMBER_ секунд.]]

-------------------------------------------------
-- MESSAGE BOX:
-------------------------------------------------
LNG.exit_confirm = [[Вы уверены, что хотите покинуть игру?]]
LNG.confirm_resolution = [[Оставить новое разрешение?]]
LNG.agree = [[Да]]
LNG.disagree = [[Нет]]
LNG.cancel = [[Отмена]]

-------------------------------------------------
-- ERRORS:
-------------------------------------------------
LNG.err_already_generating_map = [[Карта уже генерируется! Дождитесь окончания процесса...]]
LNG.err_wait_for_rendering = [[Дождитесь окончания отрисовки карты...]]
LNG.err_rendering = [[Что-то пошло не так во время инициализации карты. Попробуйте еще раз.]]
LNG.err_already_connecting = [[Соединение уже устанавливается.]]
