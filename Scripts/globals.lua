----------------------------------
-- Define global variables for both client and server.
-- Most of these variables should not change during the game.
----------------------------------

-- General:
VERSION = "1"
CONFIG_FILE = "trAInsported.conf"
DEFAULT_RES_X = 1024
DEFAULT_RES_Y = 600
AI_DIRECTORY = "AI/" -- fallback

-- Connections:
FALLBACK_SERVER_IP = "127.0.0.1"
MAIN_SERVER_IP = "trainsportedgame.no-ip.org"
PORT = 5556

--

if not DEDICATED then

	PLAYERCOLOUR1 = {r=255,g=50,b=50}
	PLAYERCOLOUR2 = {r=64,g=64,b=250}
	PLAYERCOLOUR3 = {r=255,g=200,b=64}
	PLAYERCOLOUR4 = {r=0,g=255,b=0}

	PLAYERCOLOUR1_CONSOLE = {r=255,g=200,b=200}
	PLAYERCOLOUR2_CONSOLE = {r=200,g=200,b=255}
	PLAYERCOLOUR3_CONSOLE = {r=255,g=220,b=100}
	PLAYERCOLOUR4_CONSOLE = {r=200,g=255,b=200}
	
	FONT_BUTTON = love.graphics.newFont( "UbuntuFont/Ubuntu-B.ttf", 19 )
	FONT_BUTTON_SMALL = love.graphics.newFont( "UbuntuFont/Ubuntu-B.ttf", 16 )
	FONT_STANDARD = love.graphics.newFont("UbuntuFont/Ubuntu-B.ttf", 15 )
	FONT_STAT_HEADING = love.graphics.newFont( "UbuntuFont/Ubuntu-B.ttf",18 )
	FONT_STAT_MSGBOX = love.graphics.newFont( "UbuntuFont/Ubuntu-M.ttf",17 )
	FONT_CONSOLE = love.graphics.newFont( "UbuntuFont/Ubuntu-R.ttf", 13)
	FONT_SMALL = love.graphics.newFont( "UbuntuFont/Ubuntu-B.ttf", 14)
	FONT_COORDINATES = love.graphics.newFont( "UbuntuFont/Ubuntu-B.ttf", 25 )
	FONT_HUGE = FONT_COORDINATES
	
	FONT_CODE_PLAIN = love.graphics.newFont( "UbuntuFont/Ubuntu-M.ttf", 17 )
	FONT_CODE_BOLD = love.graphics.newFont( "UbuntuFont/Ubuntu-B.ttf", 17 )
	FONT_CODE_COMMENT = love.graphics.newFont( "UbuntuFont/Ubuntu-LI.ttf", 17 )

	LOGO_IMG = love.graphics.newImage("Images/Logo.png")
	
else
	TIME_BETWEEN_MATCHES = 60
	FALLBACK_ROUND_TIME = 300
	
	MYSQL_DATABASE = "trAInsported"
end

timeFactor = 1

STARTUP_MONEY = 25

TRAIN_COST = 25

MONEY_PASSENGER = 5
MONEY_VIP = 15

CAM_ANGLE = -0.1

TRAIN_SPEED = 90
TRAIN_ACCEL = 1.2
MAX_BLOCK_TIME = 3

PASSENGER_SPEED = 110

GAME_TYPE = 1
GAME_TYPE_MAX_PASSENGERS = 1
GAME_TYPE_TIME = 2
ROUND_TIME = 1000

MAX_NUM_TRAINS = 5
MAX_NUM_PASSENGERS = 50

VIP_RATIO = 1/7
MAX_VIP_TIME = 30
MIN_VIP_TIME = 10

-- game options:

POSSIBLE_TIMES = {"Day", "Rushhour"}
POSSIBLE_TIMES_TOOLTIPS = {"Normal setup, average amount of passengers", "Lots of passengers, more VIPs"}

POSSIBLE_MODES = {"Time", "Passengers"}
POSSIBLE_MODES_TOOLTIPS = {"Transport the most passengers in a set amount of time.", "There will be a set amount of passengers only. You have to try to transport more than any other AI."}

RESOLUTIONS = {}
--RESOLUTIONS[#RESOLUTIONS+1] = {width=640, height=480}
RESOLUTIONS[#RESOLUTIONS+1] = {width=800, height=600}
RESOLUTIONS[#RESOLUTIONS+1] = {width=1024, height=768}
RESOLUTIONS[#RESOLUTIONS+1] = {width=1280, height=720}
RESOLUTIONS[#RESOLUTIONS+1] = {width=1280, height=960}
RESOLUTIONS[#RESOLUTIONS+1] = {width=1280, height=1024}
RESOLUTIONS[#RESOLUTIONS+1] = {width=1440, height=960}
RESOLUTIONS[#RESOLUTIONS+1] = {width=1600, height=1200}
RESOLUTIONS[#RESOLUTIONS+1] = {width=1680, height=1050}
RESOLUTIONS[#RESOLUTIONS+1] = {width=1920, height=1024}
RESOLUTIONS[#RESOLUTIONS+1] = {width=1920, height=1200}
RESOLUTIONS[#RESOLUTIONS+1] = {width=2048, height=1536}

-- tutorial:

TUT_BOX_X = 20
TUT_BOX_Y = 75
CODE_BOX_X = 80
CODE_BOX_Y = 75

tutDescriptions = {}
tutDescriptions[1] = [[Start here! Basic introduction to the game.]]
tutDescriptions[2] = [[Teaches you all the stuff you need to know about the Lua scripting language.]]
tutDescriptions[3] = [[The first junction! Basic decision making.]]
tutDescriptions[4] = [[Be faster! Choose your customers smartly - or watch your AI get pwned by competition.]]


-- sizes:


TILE_SIZE = 128
MAX_IMG_SIZE = 5
MAP_MINIMUM_SIZE = 4
MAP_MAXIMUM_SIZE = 30


-- UI sizes:

STND_BUTTON_WIDTH = 150
STND_BUTTON_HEIGHT = 35

SMALL_BUTTON_WIDTH = 100
SMALL_BUTTON_HEIGHT = 28

TUT_BOX_WIDTH = 500
TUT_BOX_HEIGHT = 250

CODE_BOX_WIDTH = 470
CODE_BOX_HEIGHT = 350

BOX_STATUS_WIDTH = 200
BOX_STATUS_HEIGHT = 150

STAT_BOX_WIDTH = 350
STAT_BOX_HEIGHT = 95

STAT_MSG_WIDTH = 550
STAT_MSG_HEIGHT = 45

TOOL_TIP_WIDTH = 350
TOOL_TIP_HEIGHT = 45

BUBBLE_WIDTH = 200
BUBBLE_HEIGHT = 75

CHECKMARK_WIDTH = 50
CHECKMARK_HEIGHT = 50

--- colours:

BG_R = 50
BG_G = 30
BG_B = 20

CODE_BOX_R = 85
CODE_BOX_G = 85
CODE_BOX_B = 85

STAT_BOX_POSITIVE_R = 70
STAT_BOX_POSITIVE_G = 155
STAT_BOX_POSITIVE_B = 55

STAT_BOX_NEGATIVE_R = 150
STAT_BOX_NEGATIVE_G = 60
STAT_BOX_NEGATIVE_B = 40

STAT_BOX_STATUS_R = 150
STAT_BOX_STATUS_G = 150
STAT_BOX_STATUS_B = 150

BUTTON_OFF_R = 40
BUTTON_OFF_G = 110
BUTTON_OFF_B = 40

BUTTON_OVER_R = 90
BUTTON_OVER_G = 160
BUTTON_OVER_B = 90

--MSG_BOX_R = 55
--MSG_BOX_G = 65
--MSG_BOX_B = 45

MSG_BOX_R = 75
MSG_BOX_G = 95
MSG_BOX_B = 65

--HELP_BOX_R = 55
--HELP_BOX_G = 65
--HELP_BOX_B = 45

LOAD_BOX_SMALL_R = 95
LOAD_BOX_SMALL_G = 105
LOAD_BOX_SMALL_B = 85

LOAD_BOX_LARGE_R = 125
LOAD_BOX_LARGE_G = 135
LOAD_BOX_LARGE_B = 115

STAT_MSG_R = MSG_BOX_R
STAT_MSG_G = MSG_BOX_G
STAT_MSG_B = MSG_BOX_B

STAT_ERR_R = 150
STAT_ERR_G = 60
STAT_ERR_B = 40

TOOL_TIP_R = MSG_BOX_R
TOOL_TIP_G = MSG_BOX_G
TOOL_TIP_B = MSG_BOX_B

BUBBLE_R = 200
BUBBLE_G = 200
BUBBLE_B = 200

