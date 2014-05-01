
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
LNG.menu_live = [[Ao vivo]]
LNG.menu_live_tooltip = [[Assista partidas online ao vivo!]]
LNG.menu_tutorial = [[Tutoriais]]
LNG.menu_tutorial_tooltip = [[Conheça o jogo!]]
LNG.menu_challenge = [[Desafios]]
LNG.menu_challenge_tooltip = [[Complete os mapas de desafio! Obtenha mais mapas online no website do jogo.]]
LNG.menu_compete = [[Competir]]
LNG.menu_compete_tooltip = [[Configure um jogo de teste para seu AI]]
LNG.menu_random = [[Aleatório]]
LNG.menu_random_tooltip = [[Inicie um jogo aleatório em um mapa aleatório usando AIs aleatórias de sua pasta 'AI']]
LNG.menu_settings = [[Configurações]]
LNG.menu_settings_tooltip = [[Mudar o idioma, resolução etc.]]
LNG.menu_exit = [[Sair]]

LNG.menu_return = [[Voltar]]
LNG.menu_return_to_main_menu_tooltip = [[Volte ao menu principal]]

LNG.menu_choose_ai = [[Escolhas as AIs para a partida:]]
LNG.menu_choose_ai_tooltip = [[Selcionar esta AI para a partida?]]

LNG.menu_choose_dimensions = [[Largura e Altura:]]
LNG.menu_choose_dimensions_tooltip1 = [[Selecionar largura]]
LNG.menu_choose_dimensions_tooltip2 = [[Selecionar altura]]

LNG.menu_choose_timemode = [[Tempo e modo:]]
LNG.menu_time_name[1] = [[Dia]]
LNG.menu_time_name[2] = [[Hora do rush]]
LNG.menu_time_tooltip[1] = [[Configuração normal, qunatidade média de passageiros]]
LNG.menu_time_tooltip[2] = [[Mais VIPs!]]
LNG.menu_mode_name[1] = [[Limite de Tempo]]
LNG.menu_mode_name[2] = [[Passageiros]]
LNG.menu_mode_tooltip[1] = [[Transporte a maior quantidade de passageiros em um determinado período de tempo.]]
LNG.menu_mode_tooltip[2] = [[Quantidade fixa de passageiros. Você tem que tentar transportar mais que qualquer outro AI.]]

LNG.menu_choose_region = [[Região:]]
LNG.menu_region_name[1] = [[Rural]]
LNG.menu_region_name[2] = [[Urbana]]
LNG.menu_region_tooltip[1] = [[Cenário aldeia pacata.]]
LNG.menu_region_tooltip[2] = [[O dobro de passageiros que o cenário rural tem.]]

LNG.menu_start = [[Começar]]
LNG.menu_start_tooltip = [[Comece a partida com essas configurações]]

LNG.menu_main_server = [[Servidor principal]]
LNG.menu_main_server_tooltip = [[Conecte-se ao servidor principal. Você deve estar conectado à internet!]]
LNG.menu_local_server = [[Servidor local]]
LNG.menu_local_server_tooltip = [[Conecte-se a um servidor rodando nesta máquina.]]

-- Settings menu:
LNG.menu_settings_resolution = [[Tamanho da tela:]]
LNG.menu_resolution_tooltip = [[Defina uma nove resolução de tela]]
LNG.menu_settings_options = [[Opções:]]
LNG.menu_clouds_on = [[Nuvens: On]]
LNG.menu_clouds_off = [[Nuvens: Off]]
LNG.menu_clouds_on_tooltip = [[Clique para habilitar a renderização das nuvens.]]
LNG.menu_clouds_off_tooltip = [[Clique para desabilitar a renderização das nuvens.]]
LNG.menu_settings_language = [[Idioma:]]
LNG.menu_settings_language_tooltip1 = [[Clique para alterar o idioma do jogo para]]	-- before lang name
LNG.menu_settings_language_tooltip2 = [[]]	-- after lang name

-- Menu errors:
LNG.menu_err_min_ai = [[Você precisa escolher pelo menos um AI!]]
LNG.menu_err_dimensions = [[Dimensões do mapa inválidas!]]
LNG.menu_err_mode = [[Modo de jogo inválido!]]
LNG.menu_err_time = [[Tempo de jogo inválido!]]
LNG.menu_err_resolution = [[Falha ao definir a resolução!]]


-------------------------------------------------
-- INGAME:
-------------------------------------------------
-- Fast forward message:
LNG.fast_forward = [[AVANÇO RÁPIDO PARA ENTRAR NO SERVIDOR]] --------------------------------------------------------------------------------------
LNG.confirm_leave = [[Deixar a partida atual e voltar ao menu?]]

LNG.open_folder = [[Abrir Pasta]]
LNG.open_folder_tooltip = [[Abre a pasta: AI_FOLDER_DIRECTORY]] -- AI_FOLDER_DIRECTORY will be replaced by the game with the correct directory.

LNG.reload = [[Recarregar]]
LNG.reload_confirm = [[Recarregar as AIs?]]
LNG.reload_tooltip = [[Recarrega os scripts de AI e reinicia o round.]]
LNG.disconnect = [[Desconectar]]
LNG.end_match = [[Fim da Partida]]

LNG.speed_up = [[Acelera a partida]]
LNG.slow_down = [[Desacelera a partida]]
LNG.pause = [[Pausa a partida]]

LNG.by = [[por]]
LNG.transported = [[Transportado]]
-- the following three strings are for the string "X of Y passengers"
LNG.transported1 = [[]]		-- before X
LNG.transported2 = [[ de ]]		-- between X and Y
LNG.transported3 = [[ passageiros]]		-- after Y

LNG.round_ends = [[Round termina em]]
LNG.seconds = [[seg]]
LNG.minutes = [[min]]
LNG.hours = [[h]]
LNG.days = [[dias]]
LNG.end_of_match = [[A partida acabou!]]

LNG.live_match = [[PARTIDA AO VIVO]]
LNG.lost_connection = [[CONEXÃO PERDIDA]]

-------------------------------------------------
-- LOADING SCREEN:
-------------------------------------------------
LNG.load_new_map = [[Novo Mapa]]
LNG.load_map_size = [[Tamanho: ]]
LNG.load_map_time = [[Tempo: ]]
LNG.load_map_mode_time = [[Modo: Tempo do round: ]]
LNG.load_map_mode_passengers = [[Modo: Transporte suficiente de passageiros]]
LNG.load_generating_map = [[Gerando o mapa]]
LNG.load_rendering_map = [[Renderizando o mapa]]
LNG.load_connecting = [[Conectando]]
LNG.load_failed = [[Falha!]]
-- leave ["rails"] etc, just translate the right part of the equal sign:
LNG.load_generation["rails"] = [[Trilhos]]
LNG.load_generation["houses"] = [[Casas]]
LNG.load_generation["hotspots"] = [[Hotspots]]

-------------------------------------------------
-- ROUND END STATISTICS:
-------------------------------------------------
-- The round statistics here are placed together using these strings as base. Some have versions in plural and in singular forms. If there's no difference in your language, please just copy the one version into both strings - do NOT delete the singular form!
-- In these strings, _AINAME_ and _NUMBER_ will be replaced by the appropriate values, so make sure to include them!
LNG.stat_most_picked_up_title = [[Hospitalidade]]
LNG.stat_most_picked_up = [[AI _AINAME_ pegou _NUMBER_ passageiros.]]
LNG.stat_most_picked_up_sing = [[AI _AINAME_ pegou _NUMBER_ passageiros.]]

LNG.stat_most_trains_title = [[Fleetus Maximus]]
LNG.stat_most_trains = [[AI _AINAME_ possuiu _NUMBER_ trens.]]
LNG.stat_most_trains_sing = [[AI _AINAME_ possuiu _NUMBER_ trens]]

LNG.stat_most_transported_title = [[Ganhou seu pagamento]]
LNG.stat_most_transported = [[AI _AINAME_ trouxe _NUMBER_ passageiros para seus destinos.]]
LNG.stat_most_transported_sing = [[AI _AINAME_ trouxe _NUMBER_ passageiro para seu destino.]]

LNG.stat_most_normal_transported_title = [[Socialista]]
LNG.stat_most_normal_transported = [[AI _AINAME_ trouxe _NUMBER_ passageiros não VIPs para seus destinos.]]
LNG.stat_most_normal_transported_sing = [[AI _AINAME_ trouxe _NUMBER_ passageiro não VIP para seu destino.]]

LNG.stat_dropped_title = [[Get lost...]]
LNG.stat_dropped = [[AI _AINAME_ deixou _NUMBER_ passageiros onde eles não queriam ir.]]
LNG.stat_dropped_sing = [[AI _AINAME_ deixou _NUMBER_ passageiro onde ele/ela não queria ir.]]

LNG.stat_most_money_title = [[Capitalista]]
LNG.stat_most_money = [[AI _AINAME_ ganhou _NUMBER_ créditos.]]

-- Some of the following can take up to three arguments: _NUMBER_, _AINAME_ and _TRAINNAME_:
LNG.stat_tr_most_picked_up_title = [[Abelhinha ocupada!]]
LNG.stat_tr_most_picked_up = [[_TRAINNAME_ [_AINAME_] pegou mais passageiros que qualquer outro trem.]]

LNG.stat_tr_most_transported_title = [[Lar doce Lar]]
LNG.stat_tr_most_transported = [[_TRAINNAME_ [_AINAME_] trouxe mais passageiros para seus destinos que qualquer outro trem.]]

LNG.stat_tr_dropped_title = [[Por que você não anda?]]
LNG.stat_tr_dropped = [[_TRAINNAME_ [_AINAME_] deixou _NUMBER_ passageiros no meio do nada!]]
LNG.stat_tr_dropped_sing = [[_TRAINNAME_ [_AINAME_] deixou _NUMBER_ passageiro no meio do nada!]]

LNG.stat_tr_blocked_title = [[A linha está ocupada...]]
LNG.stat_tr_blocked = [[_TRAINNAME_ [_AINAME_] foi bloqueada por um total de _NUMBER_ segundos.]]

-------------------------------------------------
-- MESSAGE BOX:
-------------------------------------------------
LNG.exit_confirm = [[Tem certeza que quer sair?]]
LNG.confirm_resolution = [[Manter esta nova resolução?]]
LNG.agree = [[Sim]]
LNG.disagree = [[Não]]
LNG.cancel = [[Cancelar]]

-------------------------------------------------
-- ERRORS:
-------------------------------------------------
LNG.err_already_generating_map = [[Um mapa já está sendo gerado! Aguarde o processo terminar...]]
LNG.err_wait_for_rendering = [[Aguarde a renderização terminar...]]
LNG.err_rendering = [[Algo errado aconteceu em um segmento ao gerar o mapa. Desculpe por isso, por favor, reinicie o jogo e tente novamente.]]
LNG.err_already_connecting = [[Tentativa de estabelecer conexão já está em andamento.]]

LNG.error_header = [[Oh não, houve um erro!]]
LNG.error_steps = [[Se você está atualmente trabalhando em seu próprio mapa de desafio, isso pode ter sido causado pelo seu desafio. Você pode obter ajuda nos fóruns:
http://www.indiedb.com/games/trainsported/forum

Se isso não foi causado por seu próprio código, você pode relatar o erro na página de issues:
https://github.com/Germanunkol/trAInsported/issues

Pressione 'c' para copiar a mensagem de erro para o clipboard.
Pressione 'o' para abrir a página de issues no GitHub.
Pressione 'esc' para fechar.
]]
LNG.error_copied = [[Copiado!]]