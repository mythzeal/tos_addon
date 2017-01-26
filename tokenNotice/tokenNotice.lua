--v1.0.0
local acutil = require("acutil");
local log = acutil.log;
local floor = math.floor;

-- util json
local path = "../addons/tokennotice/settings.json";

local function Save(table)
	return acutil.saveJSON(path, table);
end

local function Load()
	return acutil.loadJSON(path);
end

-- settings
local defaults = {
	pos = {x = 0, y = 0},
	moved = false,
	alpha = 100,
	layer = 70,
	popup = 2,
	disp = 1
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

-- const & var
local isLoaded = false;
local startSec = 0;
local remainSec = 0;
local tokenImg;

-- 0:"off", 1:"on"
local function ToZeroOne(flag)
	if flag == "on" then
		return 1;
	else
		return 0;
	end
end

-- command
local function CheckCommand(words)

	local cmd = table.remove(words, 1);
	local frame = ui.GetFrame("tokennotice");

	-- tokenNotice on/off
	if cmd == "on" or cmd == "off" then
		frame:ShowWindow(ToZeroOne(cmd));
		return;
	end

	if cmd == "reset" then
		op = defaults;
		frame:SetPos(op.pos.x, op.pos.y);
		frame:SetAlpha(op.alpha);
		frame:SetMargin(0, 32, 392, 0);
		frame:SetGravity(1, 0);
		frame = tolua.cast(frame, "ui::CFrame");
		frame:SetLayerLevel(op.layer);
		Save(op);
		return;
	end

	if cmd == "alpha" then
		local cmd2 = table.remove(words, 1);
		local num = tonumber(cmd2);
		if type(num) ~= "number" then
			return;
		end
		frame:SetAlpha(num);
		Save(op);
		return;
	end

	if cmd == "layer" then
		local cmd2 = table.remove(words, 1);
		local num = tonumber(cmd2);
		if type(num) ~= "number" then
			return;
		end
		frame = tolua.cast(frame, "ui::CFrame");
		frame:SetLayerLevel(num);
		Save(op);
		return;
	end

	if cmd == "pop" then
		local cmd2 = table.remove(words, 1);
		local num = tonumber(cmd2);
		if type(num) ~= "number" then
			return;
		end
		if num > 2 or num <= 0 then
			num = 2;
		end
		op.popup = num;

		if num == 2 then
			log("[tokenNotice] popup enabled.");
		elseif num == 1 then
			log("[tokenNotice] popup enabled. (only overdue)");
		else
			log("[tokenNotice] popup disabled.");
		end

		Save(op);
		return;
	end

	if cmd == "disp" then
		local cmd2 = table.remove(words, 1);
		local num = tonumber(cmd2);
		if type(num) ~= "number" then
			return;
		end
		if num > 1 or num <= 0 then
			num = 1;
		end
		op.disp = num;

		if num == 1 then
			log("[tokenNotice] show window.");
			frame:ShowWindow(1);
		else
			log("[tokenNotice] hide window");
			frame:ShowWindow(0);
		end

		Save(op);
		return;
	end

 	if not cmd then
		--frame:ShowWindowToggle();
		log("[tokenNotice] popup: " .. op.popup);
		log("[tokenNotice] disp: " .. op.disp);
		return;
	end
end

function TOKENNOTICE_DRAG_STOP()
	local frame = ui.GetFrame("tokennotice");
	op.pos.x = frame:GetX();
	op.pos.y = frame:GetY();
	op.moved = true;
	Save(op);
end

local function _GET_TIME_TXT(sec)

	sec = floor(sec);
	local d, h, m, s = GET_DHMS(sec);
	local ret = "";

	--if d > 0 then
	if d >= 0 then
		ret = ScpArgMsg("{Day}","Day",d);
		return ret;
	end

	return 0;
--[[
	if h > 0 then
		ret = ret .. ScpArgMsg("{Hour}","Hour",h) .. " ";
	end

	if m >= 0 then
		ret = ret .. ScpArgMsg("{Min}","Min",m) .. " ";
	else
		return ret;
	end
	
	ret = ret .. ScpArgMsg("{Sec}","Sec",s);
	return ret;
]]
end

local function GetMedalText()
    return "無料TP: " .. GetMyAccountObj().Medal;
end

local isNoticed = false;
function TOKENNOTICE_STATE(frame, msg, argStr, argNum)

	local txt = frame:GetChild("txt");

	if argNum ~= ITEM_TOKEN or "NO" == argStr then
		txt:SetText(tokenImg .. "{@st42} 期限切れだよ");

		if not isNoticed then
			return;
		end

		isNoticed = true;
		if op.popup ~= 0 then
			local medtxt = GetMedalText();
			ui.MsgBox(tokenImg .. "{@st41}期限切れてるよ！{nl} {nl}" ..  medtxt, "None", "None");
		end
		return;
	end

	local sysTime = geTime.GetServerSystemTime();
	local endTime = session.loginInfo.GetTokenTime();
	local difSec = imcTime.GetDifSec(endTime, sysTime);
    startSec = imcTime.GetAppTime();
    remainSec = difSec;

    --------

	local _elapsedSec = imcTime.GetAppTime() - startSec;
	local _startSec = remainSec;
	_startSec = _startSec - _elapsedSec;

	if 0 > _startSec then
		txt:SetText(tokenImg .. "{@st42} 期限切れだよ");
		return 0;
	end

	local timeTxt = _GET_TIME_TXT(_startSec);
	txt:SetText(tokenImg .. "{@st42} あと " .. timeTxt .. " くらい");

	if isNoticed then
		return;
	end

	isNoticed = true;
	if op.popup == 2 then
		local medtxt = GetMedalText();
    	ui.MsgBox(tokenImg .. "{@st41} あと " .. timeTxt .. " くらい{nl} {nl}" .. medtxt, "None", "None");
	end

	return 1;
end

function TOKENNOTICE_ON_INIT(addon, frame)

	frame:SetEventScript(ui.LBUTTONUP, "TOKENNOTICE_DRAG_STOP");
	--addon:RegisterMsg("GAME_START", "TOKENNOTICE_START");
	addon:RegisterMsg("TOKEN_STATE", "TOKENNOTICE_STATE");

	acutil.slashCommand("/tn", CheckCommand);
    acutil.slashCommand("/token", CheckCommand);

	if not isLoaded then
		isLoaded = true;
		LOAD_SETTINGS();
		log("[tokenNotice] loaded.");
        tokenImg = GET_ITEM_IMG_BY_CLS(GetClassByType("Item", 490000), 26);
	end

	if op.moved then
		frame:SetPos(op.pos.x, op.pos.y);
	end

    frame:SetAlpha(op.alpha);
	frame = tolua.cast(frame, "ui::CFrame");
	frame:SetLayerLevel(op.layer);

	if op.disp == 0 then
		frame:ShowWindow(0);
	end
end