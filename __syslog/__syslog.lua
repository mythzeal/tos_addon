
local acutil = require("acutil");
local log = acutil.log;

-- util json
local path = "../addons/__syslog/settings.json";

local function Save(table)
	return acutil.saveJSON(path, table);
end

local function Load()
	return acutil.loadJSON(path);
end

-- settings
local defaults = {
	pos = {x = 0, y = 0},
	show = true;
};

local op;
local function LOAD_SETTINGS()
	local _op, err = Load();
	if err then
		op = defaults;
	else
		op = _op;
	end
end

-- variables
local g_frame;
local g_txt;

function SYSLOG_DRAG_STOP()
	--local frame = ui.GetFrame("__syslog");
	op.pos.x = g_frame:GetX();
	op.pos.y = g_frame:GetY();
	Save(op);
end

CHAT_SYSTEM = function(msg)
	if g_txt == nil then
		g_txt = tolua.cast(ui.GetFrame("__syslog"):GetChild("log"), "ui::CTextView");
	end
	g_txt:AddText(msg, "white_14_ol");
end

function SYSLOG_TOGGLE_FRAME()
	ui.ToggleFrame("__syslog");
end

function SYSLOG_TOGGLE_SHOW()
	op.show = not op.show;
	if op.show then
		g_frame:Resize(280, 472);
		g_txt:ShowWindow(1);
	else
		g_frame:Resize(280, 36);
		g_txt:ShowWindow(0);
	end
	g_frame:SetPos(op.pos.x, op.pos.y);
	Save(op);
end

function SYSLOG_CLEAR()
    g_txt:Clear();
end

local isLoaded = false;
function __SYSLOG_ON_INIT(addon, frame)

    frame:SetEventScript(ui.LBUTTONUP, "SYSLOG_DRAG_STOP");
	acutil.slashCommand("/log", SYSLOG_TOGGLE_FRAME);
	--CLEAR_CONSOLE();

	--frame:Resize(280, 472);
	frame:SetAlpha(50);

	--local clear = frame:GetChild("clear");
	--clear:SetOffset(212, 4);
	--clear:Resize(64, 32);
	--clear:SetText("{s14}{ol}{b}Clear");

	local txt = frame:GetChild("log");
	txt:SetAlpha(80);
	--txt:SetOffset(0, 36);
	--txt:Resize(280, 436);

    g_frame = frame;
    g_txt = tolua.cast(txt, "ui::CTextView");

	if not isLoaded then
		isLoaded = true;
		LOAD_SETTINGS();
		log("[syslog] loaded.");
	end

	g_frame:SetPos(op.pos.x, op.pos.y);
end