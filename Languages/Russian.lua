
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
