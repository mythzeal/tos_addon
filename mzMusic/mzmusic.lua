--v1.0.0
local acutil = require("acutil");
local log = acutil.log;
local floor = math.floor;
local mod = math.mod;

-- util json
local path = "../addons/mzmusic/settings.json";

local function Save(table)
	return acutil.saveJSON(path, table);
end

local function Load()
	return acutil.loadJSON(path);
end

-- util random
local function __rs(x, disp)
  return floor(x % 2^32 / 2^disp);
end

local function __ls(x, disp)
  return (x * 2^disp) % 2^32;
end

function __xor(x, y)
	local z = 0;
	for i = 0, 31 do
		if (x % 2 == 0) then		-- x had a '0' in bit i
			if ( y % 2 == 1) then	-- y had a '1' in bit i
				y = y - 1;
				z = z + 2 ^ i;		-- set bit i of z to '1' 
			end
		else						-- x had a '1' in bit i
			x = x - 1;
			if (y % 2 == 0) then	-- y had a '0' in bit i
				z = z + 2 ^ i;		-- set bit i of z to '1' 
			else
				y = y - 1;
			end
		end
		y = y / 2;
		x = x / 2;
	end
	return z;
end

xors = {
  x = 123456789,
  y = 362436069,
  z = 521288629,
  w = 88675123
};

function xors.seed(s)
  xors.w = s;
end

function xors.__rand()
  --local t = xors.x ^ (xors.x << 11);
  local t = __xor(xors.x, __ls(xors.x, 11));
  xors.x = xors.y;
  xors.y = xors.z;
  xors.z = xors.w;
  --return xors.w = (xors.w^(xors.w>>>19))^(t^(t>>>8));
  xors.w = __xor(__xor(xors.w, __rs(xors.w, 19)), __xor(t, __rs(t, 8)));
  return xors.w;
end

function xors.rand(a, b)
	local r = xors.__rand();
	if a ~= nil and a > 0 then
		if b ~= nil and b > 0 and b > a then
			r = mod(r, (b - a)) + a;
		else
			r = mod(r, a);
		end
	end
	return r;
end

-- settings
local defaults = {
	pos = {x = 0, y = 0},
	moved = false,
	alpha = 80,
	layer = 70,
	kepa = false
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
local __addon;
local musicInst;
nowPlayListName = "";
local isLoaded = false;
local isPause = false;

local playList = {
	{name="", track=0},
    {name="Login_Barrack", track=1},
    {name="test_zone", track=1},
    {name="f_siauliai", track=4},
    {name="f_siauliai_out", track=3},
    {name="f_gele", track=4},
    {name="f_7coloredvalley", track=4},
    {name="f_katyn", track=4},
    {name="f_pilgrimroad", track=4},
    {name="f_stonecursed", track=4},
    {name="f_farm", track=3},
    {name="f_bracken", track=3},
    {name="f_3cmlake", track=3},
    {name="f_castle", track=3},
    {name="f_orchard", track=3},
    {name="f_rokas_1", track=4},
    {name="f_rokas_2", track=4},
    {name="f_remains", track=4},
    {name="f_coral", track=3},
    {name="f_tableland", track=3},
    {name="c_Klaipe", track=1},
    {name="c_fedimian", track=2},
    {name="c_orsha", track=1},
    {name="c_guild", track=1},
    {name="c_abbey", track=2},
    {name="c_nunnery", track=2},
    {name="p_cathedral", track=1},
    {name="d_abbey", track=4},
    {name="d_catacomb", track=3},
    {name="d_crystal_mine", track=3},
    {name="d_cathedral_1", track=4},
    {name="d_cathedral_2", track=3},
    {name="d_firetower", track=4},
    {name="d_velniasprison", track=4},
    {name="d_free", track=2},
    {name="d_thorn", track=4},
    {name="d_underfortress", track=2},
    {name="d_prison", track=3},
    {name="d_zachariel", track=4},
    {name="id_startower", track=2},
    {name="id_firetower", track=1},
    {name="id_chaple", track=1},
    {name="id_remains", track=2},
    {name="id_catacomb", track=1},
    {name="id_catacomb2", track=1},
    {name="id_catacomb_03", track=1},
    {name="id_castle", track=1},
    {name="id_thorn", track=1},
    {name="id_thorn2", track=1},
    {name="id_remains3", track=2},
    {name="id_underfortress", track=1},
    {name="m_boss_a", track=1},
    {name="m_boss_b", track=1},
    {name="m_boss_d", track=1},
    {name="m_boss_guild_hunting", track=1},
    {name="m_boss_scenario", track=1},
    {name="m_boss_scenario2", track=1},
    {name="m_guild_eventraid_a", track=1},
    {name="m_guild_eventraid_b", track=1},
    {name="m_guildbattle", track=3},
    {name="m_teambattle", track=2},
    {name="mission_1", track=2},
    {name="mission_groundtower", track=3},
    {name="mission_remains_01", track=2},
    {name="mission_gele_01", track=1},
    {name="mission_chaple_01", track=1},
    {name="mission_huevillage_01", track=1},
    {name="mission_rokas_01", track=2},
    {name="mission_zachariel_01", track=2},
    {name="mission_f_remains_38", track=2},
    {name="mission_abbey_uphill", track=2},
    {name="onehour_cmine1", track=2},
    {name="boss_field", track=1},
    {name="raid_siauliai1", track=1},
    {name="f_dcapital", track=2},
    {name="d_limestonecave", track=2},
    {name="f_maple", track=3},
    {name="f_whitetrees", track=2},
    {name="d_fantasylibrary ", track=3},
    {name="id_new1", track=1},
    {name="id_new2", track=1},
    {name="id_new3", track=1},
    {name="track", track=1},
};

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
	local frame = ui.GetFrame("mzmusic");

	-- mzMusic on/off
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

	if cmd == "kepa" then
		op.kepa = not op.kepa;
		Save(op);
		log("kepa option: " .. tostring(op.kepa));
		return;
	end

 	if not cmd then
		frame:ShowWindowToggle();
		return;
	end
end

local function GetMusicTitle(fileName)
	local title = "";
	for w in string.gmatch(fileName, "bgm\(.-)mp3") do
		title = string.match(fileName, "tos_.-_(.-)%.mp3");
		title = string.gsub(title, '_', ' ');
    end
	return title;
end

-- now playing update
local GetPlayingMusicInst = imcSound.GetPlayingMusicInst;
function MZMUSIC_NP_UPDATE(frame)

	if config.GetMusicVolume() == 0 then
		return;
	end

    local playInst = GetPlayingMusicInst();
	if playInst == nil or musicInst == playInst then
		return;
	end

	musicInst = playInst;
	local fileName = musicInst:GetFileName();
	for w in string.gmatch(fileName, "bgm\(.-)mp3") do
		local artist = string.match(fileName, "tos_(.-)_");
		local title = string.match(fileName, "tos_.-_(.-)%.mp3");
		title = string.gsub(title, '_', ' ');

		if artist == "Tree" then
			title = "Tree of Savior";
			artist = "Cinenote; Sevin";
		elseif artist == "SFA" then
			artist = "S.F.A";
		end

		local txt = tolua.cast(frame:GetChild("tNP"), "ui::CRichText");
		local msg = string.format("{#BBAA44}{ol}{ds}{b}{s16}♪ %s - %s", artist, title);
        txt:SetText(msg);
    end
end

-- play music
function MZMUSIC_PLAY(name, playType)

	if type(name) ~= "string" then
		return;
	end

	if name == "" then
		local inst = imcSound.GetPlayingMusicInst();

		if inst:IsPlaying() == 1 then
			if isPause then
				inst:Play();
				isPause = false;
			else
				inst:Pause();
				isPause = true;
			end
		end
		return;
	end

	if playType == nil then
		playType = 1;
	end

	imcSound.PlayMusic(name, playType);
	nowPlayListName = name;
	isPause = false;

	frame = ui.GetFrame("mzmusic");
	MZMUSIC_NP_UPDATE(frame);
end

-- create playlist droplist
local function SET_PLAYLIST(frame, mapClsName)

	nowPlayListName = "";

	local map = GetClass('Map', session.GetMapName());
	local listnm = map.BgmPlayList;

	local dPlayList = tolua.cast(frame:GetChild("dPlayList"), "ui::CDropList");
	dPlayList:ClearItems();

	for k, v in ipairs(playList) do
		local nm = "{#BBAA44}{ol}{ds}{b}{s16}" .. v.name;
		dPlayList:AddItem(k, nm, 0, "MZMUSIC_PLAY(\"" .. v.name .. "\")");
		if listnm == v.name then
			dPlayList:SelectItem(k - 1);
			nowPlayListName = listnm;
		end
	end
end

-- for event
function MZMUSIC_SET_KEPA_BGM()

	local mapClsName = session.GetMapName();
    local list = {
        {'m_boss_scenario', 2500},
        {'m_boss_scenario2', 5000},
        {'f_gele', 7500},
        {'c_guild', 10000},
    };
--[[
    local list = {
        {'f_gele', 10000},
    };
]]
	local _r = xors.rand(1, 10000);
	--log("xors:" .. _r);

    local result = 0;
    for i = 1, #list do
        if list[i][2] >= _r then
            result = i
            break;
        end
    end

	if mapClsName == "f_gele_kepa_event" then
		--MZMUSIC_PLAY("m_boss_scenario2");
		--MZMUSIC_PLAY(list[result][1]);
	--elseif mapClsName == "c_orsha" or mapClsName == "f_siauliai_west" then
		--MZMUSIC_PLAY("m_boss_scenario");
		MZMUSIC_PLAY(list[result][1]);

		if list[result][1] == "f_gele" then
			for i = 1, 4 do
				local inst = GetPlayingMusicInst();
				local title = GetMusicTitle(inst:GetFileName());
				--log(title);
				if title == "3rd Wave" then
					break;
				end
				MZMUSIC_PLAY("f_gele");
			end
		end
	end
end

function MZMUSIC_FPS_KEPA()

	if not op.kepa then
		return;
	end

	local mapClsName = session.GetMapName();
	--if mapClsName == "f_siauliai_west" and nowPlayListName == "f_gele" then
	if mapClsName == "f_gele_kepa_event" and nowPlayListName == "f_gele" then
		local inst = GetPlayingMusicInst();
		local title = GetMusicTitle(inst:GetFileName());
		if title ~= "3rd Wave" then
			for i = 1, 4 do
				inst = GetPlayingMusicInst();
				title = GetMusicTitle(inst:GetFileName());
				--log(title);
				if title == "3rd Wave" then
					break;
				end
				MZMUSIC_PLAY("f_gele");
			end
		end
	end
end

function MZMUSIC_START_3SEC(frame)
	MZMUSIC_NP_UPDATE(frame);
	__addon:RegisterMsg("FPS_UPDATE", "MZMUSIC_NP_UPDATE");

	if op.kepa then
		MZMUSIC_SET_KEPA_BGM();
	end
end

function MZMUSIC_DRAG_STOP()
	local frame = ui.GetFrame("mzmusic");
	op.pos.x = frame:GetX();
	op.pos.y = frame:GetY();
	op.moved = true;
	Save(op);
end

function MZMUSIC_ON_INIT(addon, frame)

	isPause = false;
	__addon = addon;
	musicInst = nil;

	frame:SetEventScript(ui.LBUTTONUP, "MZMUSIC_DRAG_STOP");
	addon:RegisterMsg("GAME_START_3SEC", "MZMUSIC_START_3SEC");
	addon:RegisterMsg("FPS_UPDATE", "MZMUSIC_FPS_KEPA");

	acutil.slashCommand("/mu", CheckCommand);
    acutil.slashCommand("/mzmusic", CheckCommand);

	local mapClsName = session.GetMapName();
	SET_PLAYLIST(frame, mapClsName);

	if not isLoaded then
		isLoaded = true;
		LOAD_SETTINGS();
		log("[mzMusic] loaded.");
		xors.seed(os.clock());
		for i = 1, 48 do xors.rand(); end
	end

	if op.moved then
		frame:SetPos(op.pos.x, op.pos.y);
	end

    frame:SetAlpha(op.alpha);

	frame = tolua.cast(frame, "ui::CFrame");
	frame:SetLayerLevel(op.layer);
end