-- v1.0.1jp
local addonName = "NOWPLAYING";
_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['MIEI'] = _G['ADDONS']['MIEI'] or {}
_G['ADDONS']['MIEI'][addonName] = _G['ADDONS']['MIEI'][addonName] or {};

local g = _G["ADDONS"]['MIEI'][addonName];
local acutil = require('acutil');

if not g.loaded then
	g.settings = {
		showFrame = 1;
		onlyNotification = 0;
		notifyDuration = 15;
		chatMessage = 0;
	}
end

g.settingsComment = [[%s
Now Playing by Miei, settings file
http://github.com/Miei/TOS-lua

showFrame 			- Default enable or disable onscreen text. This will also disable notifications.
onlyNotification 	- Do you want to only show text as a temporary notification after bgm changes?
notifyDuration		- Duration of the notification text
chatMessage			- Chat message for each new bgm?

%s

]];

g.settingsComment = string.format(g.settingsComment, "--[[", "]]");
g.settingsFileLoc = "../addons/nowplaying/settings.json";


function NOWPLAYING_ON_INIT(addon, frame)
	local g = _G["ADDONS"]["MIEI"]["NOWPLAYING"];
	g.addon = addon;
	g.addon:RegisterMsg("GAME_START_3SEC", "NOWPLAYING_3SEC")
end


function NOWPLAYING_3SEC()
	local g = _G["ADDONS"]["MIEI"]["NOWPLAYING"];
	local acutil = require('acutil');

	g.chatFrame = ui.GetFrame("chatframe");
	g.frame = ui.GetFrame("nowplaying");
	g.textBox = GET_CHILD(g.frame, "textbox");

	if not g.loaded then
		local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
		if err then
			acutil.saveJSON(g.settingsFileLoc, g.settings);
		else
			g.settings = t;
		end

		g.frame:ShowWindow(g.settings.showFrame);

		if g.settings.onlyNotification == 1 then
			g.frame:SetDuration(g.settings.notifyDuration);
		end

		acutil.slashCommand('/nowplaying', g.processCommand);
		acutil.slashCommand('/np', g.processCommand);
		CHAT_SYSTEM('[nowPlaying:help] /np [on/off]');

		g.loaded = true;
	end
	
	g.addon:RegisterMsg('FPS_UPDATE', 'NOWPLAYING_UPDATE_FRAME');
	g.musicInst = nil;
	g.timeCount = 2;
	
end

function NOWPLAYING_UPDATE_FRAME()
	local g = _G["ADDONS"]["MIEI"]["NOWPLAYING"];

    if g.timeCount < 3 then
        g.timeCount = g.timeCount + 1;
        return
    else
        g.timeCount = 0;
    end

	if g.settings.showFrame ~= 1 then 
		g.frame:ShowWindow(0);
		return 
	end

	if imcSound.GetPlayingMusicInst() == nil then
		g.frame:ShowWindow(0);
		return
	end

	if config.GetMusicVolume() == 0 then
		g.frame:ShowWindow(0);
		return
	end

	if g.musicInst == imcSound.GetPlayingMusicInst() then
	    return
	end

	g.musicInst = imcSound.GetPlayingMusicInst();

	local musicFileName = g.musicInst:GetFileName();
	
	for word in string.gmatch(musicFileName, "bgm\(.-)mp3") do
		local musicArtist = string.match(musicFileName, "tos_(.-)_");
		local musicTitle = string.match(musicFileName, "tos_.-_(.-)%.mp3");
		musicTitle = string.gsub(musicTitle, '_', ' ');

		if musicArtist == "Tree" then
			musicTitle = "Tree of Savior";
			musicArtist = "Cinenote; Sevin";
		end
		if musicArtist == "SFA" then
			musicArtist = "S.F.A"
		end

		g.currentTrack = string.format('Now playing: %s - %s', musicArtist, musicTitle);

		g.frame:ShowWindow(1);
		if g.settings.onlyNotification == 1 then
			g.frame:SetDuration(g.settings.notifyDuration);
		end

		if g.settings.chatMessage == 1 then
			CHAT_SYSTEM(g.currentTrack);
		end

		g.frame:SetPos(g.chatFrame:GetX()+2, g.chatFrame:GetY()-g.frame:GetHeight());
		g.textBox:SetTextByKey("text", g.currentTrack);
	end
end

function g.processCommand(words)
	local g = _G["ADDONS"]["MIEI"]["NOWPLAYING"];
	local cmd = table.remove(words,1);
	if cmd == 'off' then
		g.settings.showFrame = 0;
		g.frame:ShowWindow(0);
		g.save()
		return;
	elseif cmd == 'on' then
		g.settings.showFrame = 1;
		g.frame:ShowWindow(1);
		g.save()
		return;
	elseif cmd == 'chat' then
		cmd = table.remove(words,1);
		if cmd == 'on' then
			g.settings.chatMessage = 1;
			CHAT_SYSTEM("[nowPlaying] Chat messages enabled");
			g.frame.SetDuration(g.settings.notifyDuration);
		elseif cmd == 'off' then
			g.settings.chatMessage = 0;
			CHAT_SYSTEM("[nowPlaying] Chat messages disabled");
		end
		g.save()
		return;
	elseif cmd == 'notify' then
		cmd = table.remove(words,1);
		if cmd == 'on' then
			g.settings.onlyNotification = 1;
			CHAT_SYSTEM("[nowPlaying] Notify mode enabled");
			g.frame:SetDuration(g.settings.notifyDuration);
		elseif cmd == 'off' then
			g.settings.onlyNotification = 0;
			CHAT_SYSTEM("[nowPlaying] Notify mode disabled");
		end
		g.save()
		return;
	elseif cmd == 'help' then
		local msg = 'nowPlaying{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/np{nl}'
		msg = msg .. 'Show the current track name.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/np [on/off]{nl}';
		msg = msg .. 'Show/hide the yellow text above chat.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/np chat [on/off]{nl}';
		msg = msg .. 'Show/hide chat messages on new track.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/np notify [on/off]{nl}';
		msg = msg .. 'Enable/disable notification mode.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/np help{nl}';
		msg = msg .. 'Shows this window.{nl}';
		msg = msg .. '-----------{nl}';
		msg = msg .. '/np can also be used as /nowplaying';

		return ui.MsgBox(msg,"","Nope");
	end

	local msg = '';
	msg = g.currentTrack;
	if msg == '' then
		msg = 'Now Playing: None';
	end
	CHAT_SYSTEM(msg);
end

function g.save()
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end
