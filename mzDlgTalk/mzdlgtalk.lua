

local curPage = 0;
local curTalk = "";
local prevImg = "";

mzDlgTalk = mzDlgTalk or {};
mzDlgTalk.__talks = mzDlgTalk.__talks or {};

local __talks = mzDlgTalk.__talks;
local talkNames = {"mainte", "miko"};
talkNames[#talkNames + 1] = talkNames[#talkNames];

__talks[talkNames[1]] = {
	[1] = {img = "lexiper", title = "レキシファー", text = "あと数分でメンテが明ける。"},
	[2] = {img = "gesti", title = "魔王ジェスティ", text = "メンテが明けるとどうなるのかしら？"},
	[3] = {img = "lexiper", title = "レキシファー", text = "知らんのか？"},
	[4] = {img = "gesti", title = "魔王ジェスティ", text = "？"},
	[5] = {img = "lexiper", title = "レキシファー", text = "メンテが始まる。"},
};

__talks[talkNames[2]] = {
	[1] = {img = "hitomiko", title = "ひとみこ", text = "あなたの今日の運勢は・・・"},
	[2] = {img = "hitomiko", title = "ひとみこ", text = "はらいたまえ～{nl}きよめたまえ～{nl}しるかしるかべさべさ～"},
	[3] = {img = "hitomiko", title = "ひとみこ", text = "・・・大凶だよ。"},
};

-- Main
function DLGTALK_SHOW(talkName)

	local illFrame = ui.GetFrame("dialogillust");
	local dlgFrame = ui.GetFrame("dialog");

	if talkName == nil or __talks[talkName] == nil then
		if curTalk ~= "" and curTalk ~= nil then
			talkName = curTalk;
		else
			curPage = 0;
			curTalk = "";
			return;
		end
	end

	local talk = __talks[talkName];
	curTalk = talkName;

	if curPage == #talk then
		curPage = 0;
		curTalk = "";
		prevImg = "";
		return;
	else
		curPage = curPage + 1;
	end

	local idx = curPage;

	-- set illust and text
	DIALOG_SHOW_DIALOG_IMG(illFrame, talk[idx].img);
	__DIALOG_SHOW_DIALOG_TEXT(dlgFrame, talk[idx].text, talk[idx].title);
end

-- Show illust
function DIALOG_SHOW_DIALOG_IMG(frame, imgName)

	if prevImg == imgName then
		return;
	end

	local imgObject = frame:GetChild('dialogimage');
	tolua.cast(imgObject, 'ui::CPicture');
	imgObject:SetImage("Dlg_port_" .. imgName);
	frame:ShowWindow(1);

	prevImg = imgName;
end

-- Time Action
function RUN_DLG_UPDATE()
	if 1 == keyboard.IsKeyDown("SPACE") then

		local illFrame = ui.GetFrame("dialogillust");
		local dlgFrame = ui.GetFrame("dialog");

		local talk = __talks[curTalk];
		local imgName = talk[curPage].img;
		
		if curPage == #talk then
			illFrame:ShowWindow(0);
		else
			if talk[curPage].img ~= talk[curPage + 1].img then
				illFrame:ShowWindow(0);
			end
		end

		dlgFrame:ShowWindow(0);
		dlgFrame:SetUserValue("DialogType", 0);
		dlgFrame:StopUpdateScript("RUN_DLG_UPDATE");
		dlgFrame:SetCloseScript("DLGTALK_SHOW");

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

	frame:ShowWindow(1);
	frame:SetUserValue("DialogType", 1);
	frame:RunUpdateScript("RUN_DLG_UPDATE");
end
