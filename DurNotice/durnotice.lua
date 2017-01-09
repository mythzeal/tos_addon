--v1.0.0

local acutil = require("acutil");
local log = acutil.log;

-- util

local path = "../addons/durnotice/settings.json";

local function Save(table)
	return acutil.saveJSON(path, table);
end

local function Load()
	return acutil.loadJSON(path);
end

local defaults = {
	pos = {x = 0, y = 0},
	moved = false,
	alpha = 70,
	layer = 70
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
local eqTypes = {"RH", "LH", "SHIRT", "GLOVES", "PANTS", "BOOTS", "RING1", "RING2", "NECK"};

local isLoaded = false;

local function GetColor(pt, max, rev)

	local col = math.floor(pt * max);

	if col < 0 or col > max then
		if rev then
			return 0;
		end
		return max;
	end

	return col;
end

local function GET_RGB(dur, maxDur)

	local pt = dur / maxDur;

	local r = GetColor((1 - pt), 255, true);
	local g = GetColor(pt, 255);
	local b = GetColor(pt, 64);
	
	return string.format("%02x%02x%02x", r, g, b);
end

local function CHECK_DUR(frame, eqType)

	local eqlist = session.GetEquipItemList();

	local slot = tolua.cast(frame:GetChild("s" .. eqType), "ui::CSlot");
	local gauge = tolua.cast(frame:GetChild("g" .. eqType), "ui::CGauge");
    local text = tolua.cast(frame:GetChild("t" .. eqType), "ui::CRichText");

	local num = item.GetEquipSpotNum(eqType)
	local eq = eqlist:Element(num);

	if eq.type ~= item.GetNoneItem(eq.equipSpot) then
		local icon = CreateIcon(slot);
		local obj = GetIES(eq:GetObject());
		local img = GET_ITEM_ICON_IMAGE(obj);
		icon:Set(img, 'Item', eq.type, eq.equipSpot, eq:GetIESID());

		--local arg1 = math.floor(obj.Dur/100);
		--local arg2 = math.floor(obj.MaxDur/100);
		local col = GET_RGB(obj.Dur, obj.MaxDur);
		gauge:SetColorTone("FF" .. col);
		gauge:SetPoint(obj.Dur, obj.MaxDur);
		gauge:ShowWindow(1);
		
        text:SetText("{#BBAA44}{ol}{ds}{b}{s15}" .. obj.Dur .. " / " .. obj.MaxDur);
        text:ShowWindow(1);
	else
		slot:ClearIcon();
		gauge:ShowWindow(0);
        text:ShowWindow(0);
	end
end

function UPDATE_DUR(frame)
	for i = 1, #eqTypes do
		CHECK_DUR(frame, eqTypes[i]);
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
	local frame = ui.GetFrame("durnotice");

	-- DurNotice on/off
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

	if not cmd then
		frame:ShowWindowToggle();
		return;
	end
end

function DURNOTICE_DRAG_STOP()
	local frame = ui.GetFrame("durnotice");
	op.pos.x = frame:GetX();
	op.pos.y = frame:GetY();
	op.moved = true;
	Save(op);
end

function DURNOTICE_ON_INIT(addon, frame)

	frame:SetEventScript(ui.LBUTTONUP, "DURNOTICE_DRAG_STOP");

	addon:RegisterOpenOnlyMsg('UPDATE_ITEM_REPAIR', 'UPDATE_DUR');
	addon:RegisterOpenOnlyMsg('ITEM_PROP_UPDATE', 'UPDATE_DUR');
	addon:RegisterOpenOnlyMsg('EQUIP_ITEM_LIST_GET', 'UPDATE_DUR');
	addon:RegisterOpenOnlyMsg('MYPC_CHANGE_SHAPE', 'UPDATE_DUR');
	addon:RegisterMsg('GAME_START', 'UPDATE_DUR');

	acutil.slashCommand("/durNotice", checkCommand);
	acutil.slashCommand("/dn", checkCommand);

	if not isLoaded then
		isLoaded = true;
		LOAD_SETTINGS();
		log("[DurNotice] loaded.");
	end

	if op.moved then
		frame:SetPos(op.pos.x, op.pos.y);
	end

    frame:SetAlpha(op.alpha);

	frame = tolua.cast(frame, "ui::CFrame");
	frame:SetLayerLevel(op.layer);
end