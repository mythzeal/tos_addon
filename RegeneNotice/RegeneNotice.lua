--v1.0.0

local acutil = require("acutil");
local log = acutil.log;

-- util
local path = "../addons/regenenotice/settings.json";

local function Save(table)
	return acutil.saveJSON(path, table);
end

local function Load()
	return acutil.loadJSON(path);
end

-- constants
local BUFF_REST = 58;
local BUFF_FIRE = 4017;

-- variables
local oldSp = 0;
local curSp = 0;

local baseTime = 0;
local curTime = 0;
local reserveTime = 0;

local isStart = false;
local st = 0;  -- stage

local emot = {"09", "12", "13", "15", "21", "22", "23"};

local defaults = {
	show = true,
	timer = false
};

-- load json
local op, err = Load();

if err then
	op = defaults;
end

local function RESET_TIME()
	baseTime = os.clock();
	curTime = 0;
	reserveTime = baseTime;
	st = 0;
end

local function RESET_TIME_TEMP()
	reserveTime = baseTime;
	baseTime = os.clock();
	curTime = 0;
end

local function GET_TIMER(frame)
	return tolua.cast(frame:GetChild("addontimer"), "ui::CAddOnTimer");
end

local function GET_TEXT(frame)
	return tolua.cast(frame:GetChild("txt"), "ui::CRichText");
end

local function GET_ICON(frame)
	return tolua.cast(frame:GetChild("icon"), "ui::CPicture");
end

-- set timer text
local function SET_REGENE_TIME_TEXT(frame, sec)
	if not op.timer then return; end
	local txt = tolua.cast(frame:GetChild("txt"), "ui::CRichText");
	local msg = string.format("{#99ff00}{s18}{ol}RegeneTime: %02d", sec);
	txt:SetText(msg);
end

-- buff check: sitrest and campfire
local function CheckBuff()

	local buff_ui = _G["s_buff_ui"];
	local handle  = session.GetMyHandle();

	-- under buff
	local slotlist = buff_ui["slotlist"][1];
	local slotcount = buff_ui["slotcount"][1];

	if slotcount == nill or slotcount < 0 then
		return false;
	end

	local icon = nil;
	local _type = 0;
	local buff = nil;

	local result = {};
	result[BUFF_REST] = false;
	result[BUFF_FIRE] = false;

	for i = 0, slotcount - 1 do

		icon = slotlist[i]:GetIcon();
		_type = icon:GetInfo().type;

		if _type == BUFF_REST or _type == BUFF_FIRE then

			buff = info.GetBuff(handle, _type, icon:GetUserIValue("BuffIndex"));

			if buff ~= nil then
				result[_type] = true;
			end
		end
	end

	return result;
end

-- fade out
local function FADEOUT_ICON(icon)

	if icon:IsVisible() == 0 then
		return;
	end

	if st ~= 0 then
		st = 0;
		local num = math.floor(math.random(#emot));
		icon:SetImage("emoticon_00" .. emot[num]);
		icon:ReleaseBlink();

		_func1 = function() icon:SetBlink(1, 0.5, "00FFFFFF"); _func1 = nil; end;
		ReserveScript("_func1()", 0.5);
	end

	_func2 = function() icon:ShowWindow(0); _func2 = nil; end;
	ReserveScript("_func2()", 1);
end

-- STAT_UPDATE event
function REGENE_STAT_ON_MSG(frame, msg, argStr, argNum)

	local stat = info.GetStat(session.GetMyHandle());

	if curSp == stat.SP then
		return;
	end

	oldSp = curSp;
	curSp = stat.SP;

	-- when not SP recovery
	if curSp <= oldSp then
		return;
	end

	local timer = GET_TIMER(frame);

	if curSp >= stat.maxSP then

		if isStart then
			isStart = false;
			timer:Stop();
			SET_REGENE_TIME_TEXT(frame, 0);
			FADEOUT_ICON(GET_ICON(frame));
		end

		--log("SP_UPDATE: SPMAX.");
		return;
	end

	if not isStart then
		isStart = true;
		timer:SetUpdateScript("PROC_REGENE_TIME");
		timer:Start(0.5);
	end

	RESET_TIME_TEMP();
	SET_REGENE_TIME_TEXT(frame, curTime);

	--local __msg = "SP_UPDATE cur:" .. curSp .. " old:" .. oldSp;
	--log(__msg);
end

-- TAKE_HEAL event
function REGENE_HEAL_ON_MSG(frame, msg, argStr, argNum)

	if oldSp == curSp then
		return;
	end

	if not isStart then
		return;
	end

	baseTime = reserveTime;
	curTime = math.floor(os.clock() - baseTime);

	SET_REGENE_TIME_TEXT(frame, curTime);
end

-- icon animation
local function ICON_ANIM(frame, limit)

	local icon = GET_ICON(frame);

	-- 19
	if curTime >= (limit - 1) then

		if st == 2 then
			FADEOUT_ICON(icon);
		end

	-- 15
	elseif curTime >= (limit - 5) then

		if st == 1 then
			st = 2;
			icon:SetImage("emoticon_0011");
		end

	-- 9.5
	elseif curTime >= (limit - 10.5) then

		if st == 0 then
			if not bRest then
				st = 1;
				icon:SetImage("emoticon_0010");
				icon:SetBlink(12, 0.5, "00FFFFFF");
				icon:ShowWindow(1);
			end
		end

	else
		FADEOUT_ICON(icon);
	end
end

-- timer process
function PROC_REGENE_TIME(frame)

	local buff = CheckBuff();
	local bRest = buff[BUFF_REST];
	local bFire = buff[BUFF_FIRE];

	if bFire then
		isStart = false;
		GET_TIMER(frame):Stop();
		return;
	end

	-- sec update
	curTime = math.floor(os.clock() - baseTime);

	local limit = 20;

	ICON_ANIM(frame, limit);

	if bRest then
		limit = math.floor(limit / 2);
	end

	if curTime >= limit then
		RESET_TIME();
	end

	SET_REGENE_TIME_TEXT(frame, curTime);
end

-- "on":true, "off":false
local function IsOnOff(flag)
	return (flag == "on");
end

local function ToOnOff(flag)
	if flag then
		return "on";
	else
		return "off";
	end
end

-- 0:"off", 1:"on"
local function ToZeroOne(flag)
	if flag == "on" then
		return 1;
	else
		return 0;
	end
end

-- command
local function checkCommand(words)

	local cmd = table.remove(words, 1);
	local title = "RegeneNotice{nl}" .. "-----------{nl} {nl}";
	local frame = ui.GetFrame("regenenotice");

	-- RegeneNotice on/off
	if cmd == "on" or cmd == "off" then

		op.show = IsOnOff(cmd);
		frame:ShowWindow(ToZeroOne(cmd));
		Save(op);

		local msg = title .. "RegeneNotice set to [" .. cmd .. "].";
		return ui.MsgBox(msg);
	end

	if cmd == "timer" then

		local val = table.remove(words, 1);

		-- timer on/off
		if val == "on" or val == "off" then

			if val == "on" then
				op.show = true;
				frame:ShowWindow(1);
			end

			op.timer = IsOnOff(val);
			GET_TEXT(frame):ShowWindow(ToZeroOne(val));
			Save(op);

			local msg = title .. "Show timer set to [" .. val .. "].";
			return ui.MsgBox(msg);		
		else 
			return ui.MsgBox(title .. "The value should be 'on' or 'off' (without quotes).");
		end
	end

	if not cmd then
		local msg = title .. "RegeneNotice is [" .. ToOnOff(op.show) .. "].{nl}";
		msg = msg .. "Show timer is [" .. ToOnOff(op.timer) .. "].";
		return ui.MsgBox(msg);
	end

	ui.MsgBox(title .. "Command not valid.{nl}", "", "Nope");
end

-- init frame
local function INIT_FRAME(frame)

	if not op.show then
		frame:ShowWindow(0);
		return;
	end

	local txt = frame:GetChild("txt");
	if op.timer then
		txt:ShowWindow(1);
	else
		txt:ShowWindow(0);
	end

	local icon = frame:GetChild("icon");
	if isStart then
		RESET_TIME();
		local timer = GET_TIMER(frame);
		timer:SetUpdateScript("PROC_REGENE_TIME");
		timer:Start(0.5);
		icon:ShowWindow(1);
	else
		icon:ShowWindow(0);
	end

	SET_REGENE_TIME_TEXT(frame, 0);
end

local isLoaded = false;

-- on init
function REGENENOTICE_ON_INIT(addon, frame)

	math.randomseed(os.clock());

	addon:RegisterMsg("STAT_UPDATE", "REGENE_STAT_ON_MSG");
	addon:RegisterMsg("TAKE_HEAL", "REGENE_HEAL_ON_MSG");

	local stat = info.GetStat(session.GetMyHandle());
	isStart = (stat.SP < stat.maxSP);

	INIT_FRAME(frame);

	--local _msg = "SP:" .. stat.SP .. " maxSP:" .. stat.maxSP .. " isStart:" .. tostring(isStart);
	--log(_msg);

	if isLoaded then
		return;
	end

	acutil.slashCommand("/regeneNotice", checkCommand);
	acutil.slashCommand("/rn", checkCommand);

	Save(op);
	isLoaded = true;

	curSp = stat.SP;
	oldSp = curSp;

	log("[RegeneNotice] loaded.");
end