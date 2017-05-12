

local curPage = 0;
local curTalk = "";

local __talks = {
	["mainte"] = {
		[1] = {img = "lexiper", title = "レキシファー", text = "あと数分でメンテが明ける。"},
		[2] = {img = "gesti", title = "魔王ジェスティ", text = "メンテが明けるとどうなるのかしら？"},
		[3] = {img = "lexiper", title = "レキシファー", text = "知らんのか？"},
		[4] = {img = "gesti", title = "魔王ジェスティ", text = "？"},
		[5] = {img = "lexiper", title = "レキシファー", text = "メンテが始まる。"},
	},
	["miko"] = {
		[1] = {img = "hitomiko", title = "巫女マスター ひとみこ", text = "あなたの今日の運勢は・・・"},
		[2] = {img = "hitomiko", title = "巫女マスター ひとみこ", text = "はらいたまえ～{nl}きよめたまえ～{nl}しるかしるかべさべさ～"},
		[3] = {img = "hitomiko", title = "巫女マスター ひとみこ", text = "・・・大凶ですね。"},
	},
};

--[[
local DLGILL_INFO = {
	["gesti"] = {title = "魔王ジェスティ", text = "お前ら全員死ね！"},
	["hauberk"] = {title = "魔将ホーバーク", text = "ここでは誰も信じてはならぬ。女神も、お前自身も。"},
	["lexiper"] = {title = "レキシファー", text = "知らんのか？"},
	["raima"] = {title = "女神ライマ", text = "次の啓示は・・・えっと・・・どこだっけ？"},
	["raima2"] = {title = "女神ライマ", text = "おなかすいた..."},
	["vakarine"] = {title = "女神ヴァカリネ", text = ""},
};
]]

-- Main
function DLGTALK_SHOW(talkName)

	local illFrame = ui.GetFrame("dialogillust");
	local dlgFrame = ui.GetFrame("dialog");

	illFrame:ShowWindow(0);
	dlgFrame:ShowWindow(0);
	dlgFrame:SetUserValue("DialogType", 0);
	dlgFrame:StopUpdateScript("RUN_DLG_UPDATE");

	if talkName == nil or __talks[talkName] == nil then
		if curTalk ~= "" and curTalk ~= nil then
			talkName = curTalk;
		else
			curTalk = "";
			curPage = 0;
			return;
		end
	end

	local talk = __talks[talkName];
	curTalk = talkName;

	if curPage == #talk then
		curTalk = "";
		curPage = 0;
		return;
	else
		curPage = curPage + 1;
	end

	local idx = curPage;

	-- set illust and text
	DIALOG_SHOW_DIALOG_IMG(illFrame, talk[idx].img);
	__DIALOG_SHOW_DIALOG_TEXT(dlgFrame, talk[idx].text, talk[idx].title);

	dlgFrame:ShowWindow(1);
	dlgFrame:SetUserValue("DialogType", 1);
	dlgFrame:RunUpdateScript("RUN_DLG_UPDATE");
end

-- Show illust
function DIALOG_SHOW_DIALOG_IMG(frame, imgName)
	local imgObject = frame:GetChild('dialogimage');
	tolua.cast(imgObject, 'ui::CPicture');
	imgObject:SetImage("Dlg_port_" .. imgName);
	frame:ShowWindow(1);
end

-- Time Action
function RUN_DLG_UPDATE()
	if 1 == keyboard.IsKeyDown("SPACE") then

		local illFrame = ui.GetFrame("dialogillust");
		local dlgFrame = ui.GetFrame("dialog");

		if curPage ~= 0 then
			dlgFrame:SetCloseScript("DLGTALK_SHOW");
		else
			dlgFrame:SetCloseScript("");
		end

		illFrame:ShowWindow(0);
		dlgFrame:ShowWindow(0);
		dlgFrame:SetUserValue("DialogType", 0);
		dlgFrame:StopUpdateScript("RUN_DLG_UPDATE");

		return 0;
	end
	return 1;
end

function __DIALOG_SHOW_DIALOG_TEXT(frame, text, titleName)
	
    local textObj = GET_CHILD(frame, "textlist", "ui::CFlowText");
	textObj:SetText("");

	if titleName == nil then
		frame:ShowTitleBar(0);
	else
		frame:ShowTitleBar(1);
		frame:SetTitleName('{s20}{ol}{gr gradation2}  ' .. titleName .. '  {/}');
	end

	local spaceObj = GET_CHILD(frame, "space", "ui::CAnimPicture");
	spaceObj:PlayAnimation();

	local viewText = '{s20}{b}{#1f100b}' .. text;
	textObj:ClearText();
	textObj:SetText(viewText);
    textObj:SetFontName('dialog');
	textObj:SetFlowSpeed(35);
end

--[[

dofile("..\\test.lua")
DLGTALK_SHOW("test")

]]