--v1.0.0
local acutil = require("acutil");
local log = acutil.log;

-- util
local path = "../addons/mzmusic/settings.json";

local function Save(table)
	return acutil.saveJSON(path, table);
end

local function Load()
	return acutil.loadJSON(path);
end

local defaults = {
	pos = {x = 0, y = 0},
	moved = false,
	alpha = 80,
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
local __addon;

local playList = {
	{name="", track=0},
    {name="Login_Barrack", track=1},
--    {name="test_zone", track=1},
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
    --{name="id_catacomb2", track=1},
    --{name="id_catacomb_03", track=1},
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
    {name="d_fantasylibrary", track=3},
    {name="id_new1", track=1},
    {name="id_new2", track=1},
    {name="id_new3", track=1},
    {name="track", track=1},
};

local isLoaded = false;

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

    local icmd = tonumber(cmd);
    if type(icmd) == "number" then
		local cmd2 = table.remove(words, 1);
		local track = tonumber(cmd2);

        local music = playList[icmd];
        if music == nil then
            return;
        end

		if type(track) ~= "number" then
			track = 1;
        elseif track > music.track then
            track = music.track;
        end

        imcSound.PlayMusic(music.name, track);
        return;
    end

	if not cmd then
		frame:ShowWindowToggle();
		return;
	end
end

local musicInst;
function MZMUSIC_NP_UPDATE(frame)

	if config.GetMusicVolume() == 0 then
		--frame:ShowWindow(0);
		return;
	end

    local playInst = imcSound.GetPlayingMusicInst();
	if playInst == nil then
		--frame:ShowWindow(0);
		return;
	end

    local playInst = imcSound.GetPlayingMusicInst();
	if musicInst == playInst then
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
		local msg = string.format("{#BBAA44}{ol}{ds}{b}{s17}♪ %s - %s", artist, title);
        txt:SetText(msg);
    end
end

function MZMUSIC_START_3SEC(frame)
	MZMUSIC_NP_UPDATE(frame);
	__addon:RegisterMsg("FPS_UPDATE", "MZMUSIC_NP_UPDATE");
end

local isPause = false;
function MZMUSIC_PLAY(name, track)

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

	if track == nil then
		track = 1;
	end

	imcSound.PlayMusic(name, track);
	isPause = false;
end

local function SET_PLAYLIST(frame)

	local dList = tolua.cast(frame:GetChild("dList"), "ui::CDropList");
	for k, v in ipairs(playList) do
		local name = "{#BBAA44}{ol}{ds}{b}{s17}" .. v.name;
		dList:AddItem(k, name, 0, "MZMUSIC_PLAY(\"" .. v.name .. "\")");
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

	frame:SetEventScript(ui.LBUTTONUP, "MZMUSIC_DRAG_STOP");
	addon:RegisterMsg('GAME_START_3SEC', 'MZMUSIC_START_3SEC');

	acutil.slashCommand("/mu", checkCommand);
    acutil.slashCommand("/mzmusic", checkCommand);

	SET_PLAYLIST(frame);

	if not isLoaded then
		isLoaded = true;
		LOAD_SETTINGS();
		log("[mzMusic] loaded.");
	end

	if op.moved then
		frame:SetPos(op.pos.x, op.pos.y);
	end

    frame:SetAlpha(op.alpha);

	frame = tolua.cast(frame, "ui::CFrame");
	frame:SetLayerLevel(op.layer);
end