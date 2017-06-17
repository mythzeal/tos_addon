
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
--[[
	if g_txt == nil then
		g_txt = tolua.cast(ui.GetFrame("__syslog"):GetChild("log"), "ui::CTextView");
	end
]]
	local txt = tolua.cast(ui.GetFrame("__syslog"):GetChild("log"), "ui::CTextView");
	txt:AddText(msg, "white_14_ol");
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

	acutil.slashCommand("/log", SYSLOG_TOGGLE_FRAME);
    frame:SetEventScript(ui.LBUTTONUP, "SYSLOG_DRAG_STOP");
	frame:SetAlpha(50);

	local txt = frame:GetChild("log");
	txt:SetAlpha(80);

    g_frame = frame;
    g_txt = tolua.cast(txt, "ui::CTextView");

	if not isLoaded then
		isLoaded = true;
		LOAD_SETTINGS();
		log("[syslog] loaded.");
	end

	if not op.show then
		g_frame:Resize(280, 36);
		g_txt:ShowWindow(0);
	end

	g_frame:SetPos(op.pos.x, op.pos.y);
end