--v1.0.0

local acutil = require("acutil");
local log = acutil.log;
local slash = acutil.slashCommand;
local floor = math.floor;
local format = string.format;
local cast = tolua.cast;

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

	local col = floor(pt * max);

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
	
	return format("FF%02x%02x%02x", r, g, b);
end

local GetEquipItemList = session.GetEquipItemList;
local function CHECK_DUR(frame, eqType)

	local eqlist = GetEquipItemList();

	local slot = cast(frame:GetChild("s" .. eqType), "ui::CSlot");
	local gauge = cast(frame:GetChild("g" .. eqType), "ui::CGauge");
    local text = cast(frame:GetChild("t" .. eqType), "ui::CRichText");

	local num = item.GetEquipSpotNum(eqType)
	local eq = eqlist:Element(num);
	local eqtype = eq.type;
	local spot = eq.equipSpot;

	if eqtype ~= item.GetNoneItem(spot) then
		local icon = CreateIcon(slot);
		local obj = GetIES(eq:GetObject());
		local dur = obj.Dur;
		local max = obj.MaxDur;
		local img = GET_ITEM_ICON_IMAGE(obj);
		icon:Set(img, 'Item', eqtype, spot, eq:GetIESID());

		gauge:SetColorTone(GET_RGB(dur, max));
		gauge:SetPoint(dur, max);
		gauge:ShowWindow(1);
		
		text:SetText("{#DDAA55}{ol}{b}{s13}" .. dur .. " / " .. max);
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

		frame = cast(frame, "ui::CFrame");
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

		frame = cast(frame, "ui::CFrame");
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

	slash("/durNotice", checkCommand);
	slash("/dn", checkCommand);

	if not isLoaded then
		isLoaded = true;
		LOAD_SETTINGS();
		log("[DurNotice] loaded.");
	end

	if op.moved then
		frame:SetPos(op.pos.x, op.pos.y);
	end

    frame:SetAlpha(op.alpha);

	frame = cast(frame, "ui::CFrame");
	frame:SetLayerLevel(op.layer);
end