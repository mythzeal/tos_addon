--v1.1.0
local acutil = require("acutil");
local log = acutil.log;
local floor = math.floor;
local mod = math.mod;
--local random = math.random;

local random = function(min, max)
	local _r = math.random(min, max);
	--log(_r);
	--log(math.random(5));
	--log(math.random(5));
	return _r;
end;

--[[
local random = function(min, max)
	local _r = mod(floor(os.clock() * 100), max) + min;
	log(_r);
	return _r;
end;
]]

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

	if cmd == "popup" then
		local cmd2 = table.remove(words, 1);
		local num = tonumber(cmd2);
		if type(num) ~= "number" then
			return;
		end
		if num > 2 or num < 0 then
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
		if num > 1 or num < 0 then
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

		if isNoticed then
			return;
		end

		isNoticed = true;
		if op.popup ~= 0 then
			local medtxt = GetMedalText();
			local yesScp = string.format("TOKENNOTICE_DLGSHOW(%d)", 0);
			ui.MsgBox(tokenImg .. "{@st41}期限切れてるよ！{nl} {nl}" ..  medtxt, yesScp, "None");
		end
		return;
	end

	local sysTime = geTime.GetServerSystemTime();
	local endTime = session.loginInfo.GetTokenTime();
	local remainSec = imcTime.GetDifSec(endTime, sysTime);

	if 0 > remainSec then
		txt:SetText(tokenImg .. "{@st42} 期限切れだよ");
		return 0;
	end

	local timeTxt = _GET_TIME_TXT(remainSec);
	txt:SetText(tokenImg .. "{@st42} あと " .. timeTxt .. " くらい");

	if isNoticed then
		return;
	end

	isNoticed = true;
	if op.popup == 2 then
		local medtxt = GetMedalText();
		local yesScp = string.format("TOKENNOTICE_DLGSHOW(%d)", remainSec);
		--log("random test laoding:" .. math.random(5));
		math.randomseed(floor(os.clock()));
		ui.MsgBox(tokenImg .. "{@st41} あと " .. timeTxt .. " くらい{nl} {nl}" .. medtxt, yesScp, "None");
	end

	return 1;
end

function TOKENNOTICE_ON_INIT(addon, frame)

	frame:SetEventScript(ui.LBUTTONUP, "TOKENNOTICE_DRAG_STOP");
	--addon:RegisterMsg("GAME_START", "TOKENNOTICE_START");
	addon:RegisterMsg("TOKEN_STATE", "TOKENNOTICE_STATE");

	acutil.slashCommand("/tn", CheckCommand);
    acutil.slashCommand("/token", CheckCommand);

	-- debug
	--isNoticed = false;

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

-- dialog talk settings
mzDlgTalk = mzDlgTalk or {};
mzDlgTalk.__talks = mzDlgTalk.__talks or {};

local __talks = mzDlgTalk.__talks;
local talkNames = {};
for i = 1, 12 do
	talkNames[i] = "tn" .. i;
end

local function SetTextToken(time)
	__talks[talkNames[1]] = {
		[1] = {img = "hauberk", title = "魔将ホーバーク", text = "戻ったか、啓示者よ。"},
		[2] = {img = "hauberk", title = "魔将ホーバーク", text = "たまには休憩も大事だぞ。"},
		[3] = {img = "hauberk", title = "魔将ホーバーク", text = "では、また会おう。"},
	};

	__talks[talkNames[2]] = {
		[1] = {img = "hauberk_dark", title = "魔将ホーバーク", text = "戻ったか、啓示者よ。"},
		[2] = {img = "hauberk_dark", title = "魔将ホーバーク", text = "ここでは誰も信じてはならぬ。女神も、お前自身も。"},
		[3] = {img = "vakarine", title = "女神ヴァカリネ", text = "・・・。"},
		[4] = {img = "hauberk_dark", title = "魔将ホーバーク", text = "・・・。"},
		[5] = {img = "hauberk_dark", title = "魔将ホーバーク", text = "さらばだ、啓示者よ。"},
		[6] = {img = "hauberk_dark", title = "魔将ホーバーク", text = "(逃走)"},
		[7] = {img = "vakarine", title = "女神ヴァカリネ", text = "まてこらー！"},
	};

	__talks[talkNames[3]] = {
		[1] = {img = "raima", title = "女神ライマ", text = "よくぞ戻られました、救済者よ。"},
		[2] = {img = "raima", title = "女神ライマ", text = "次のレベルに上がるまでの経験値は・・・{nl}おや、これは違う世界の作法でしたね。"},
		[3] = {img = "raima", title = "女神ライマ", text = "それでは、良い旅を。"},
	};

	__talks[talkNames[4]] = {
		[1] = {img = "raima2", title = "女神ライマ", text = "・・・。"},
		[2] = {img = "giltine", title = "魔神ギルティネ", text = "無様だな、ライマ。"},
		[3] = {img = "giltine", title = "魔神ギルティネ", text = "おや、自慢の翼はどうした？{nl}まさか腹が減ったからといって、食べてしまったのか？"},
		[4] = {img = "giltine", title = "魔神ギルティネ", text = "ふふ、冗談だ。"},
		[5] = {img = "raima2", title = "女神ライマ", text = "・・・。"},
		[6] = {img = "raima2", title = "女神ライマ", text = "(紅潮している)"},
		[7] = {img = "giltine", title = "魔神ギルティネ", text = "・・・えっ？"},
		[8] = {img = "giltine", title = "魔神ギルティネ", text = "(青ざめる)"},
	};

	__talks[talkNames[5]] = {
		[1] = {img = "gesti", title = "魔王ジェスティ", text = "遅かったな、啓示者。"},
		[2] = {img = "gesti", title = "魔王ジェスティ", text = "どうした、かかってこないのか？"},
		[3] = {img = "gesti", title = "魔王ジェスティ", text = "ふん、臆病者め。"},
	};

	__talks[talkNames[6]] = {
		[1] = {img = "gesti", title = "魔王ジェスティ", text = "遅かったな、啓示者。"},
		[2] = {img = "gesti", title = "魔王ジェスティ", text = "どうした、かかってこないのか？"},
		[3] = {img = "gesti", title = "魔王ジェスティ", text = "ふん、臆病者め。"},
		[4] = {img = "dalia", title = "女神ダリア", text = "・・・。"},
		[5] = {img = "gesti", title = "魔王ジェスティ", text = "あっ・・・。{nl}きょ、今日のところは見逃してやろう。{nl}感謝するがいい。"},
		[6] = {img = "dalia", title = "女神ダリア", text = "逃しませんよ？{nl}さぁ、共に爆ぜましょう。"},
		[7] = {img = "gesti", title = "魔王ジェスティ", text = "ちょ、馬鹿、やめ・・・。"},
		[8] = {img = "dalia", title = "女神ダリア", text = "(爆発)"},
		[9] = {img = "gesti", title = "魔王ジェスティ", text = "(爆発)"},
		[10]= {img = "lutha", title = "クポル メデナ", text = "ダリア様・・・。"},
	};

	if time ~= nil and time >= 0 then
		__talks[talkNames[7]] = {
			[1] = {img = "lexiper", title = "レキシファー", text = "貴様、啓示者か。"},
			[2] = {img = "lexiper", title = "レキシファー", text = "王陵では世話になったな。だが・・・。"},
			[3] = {img = "lexiper", title = "レキシファー", text = "・・・今は任務中だ。{nl}生憎、今はお前の相手をしている暇はない。"},
			[4] = {img = "", title = "啓示者ちゃん", text = "うぅ～い？"},
			[5] = {img = "lexiper", title = "レキシファー", text = "・・・。"},
		};
	else
		__talks[talkNames[7]] = {
			[1] = {img = "lexiper", title = "歴史学者", text = "え？" .. tokenImg .. "をお持ちでない？（笑）"},
			[2] = {img = "lexiper", title = "歴史学者", text = "・・・。{nl}この口上が通じる方が、どれほど生き残っているのでしょうか・・・。"},
		};
	end

	__talks[talkNames[8]] = {
		[1] = {img = "vakarine", title = "女神ヴァカリネ", text = "戻りましたか、救済者。"},
		[2] = {img = "vakarine", title = "女神ヴァカリネ", text = "ディオニスですか？{nl}ええ、あの子なら元気になりましたよ。"},
		[3] = {img = "vakarine", title = "女神ヴァカリネ", text = "ところで、最近ホーバークの霊魂の欠片が少し減っている気がします。{nl}気のせいだといいのですが・・・。"},	
		[4] = {img = "vakarine", title = "女神ヴァカリネ", text = "では、またお会いしましょう。"},
	};

	__talks[talkNames[9]] = {
		[1] = {img = "vakarine", title = "女神ヴァカリネ", text = "戻りましたか、救済者。"},
		[2] = {img = "vakarine", title = "女神ヴァカリネ", text = "クポルからの報告で知ったのですが、何故か私の評判が下がっているそうです。"},
		[3] = {img = "vakarine", title = "紐神様", text = "曰く、 \" またヴァカリネか・・・ \" と。"},
		[4] = {img = "vakarine", title = "女神ヴァカリネ", text = "私には心当たりが全く無いのですが、何かご存知ですか？"},
		[5] = {img = "vakarine", title = "女神ヴァカリネ", text = "一体誰がこんな噂を・・・。"},
	};

	__talks[talkNames[10]] = {
		[1] = {img = "blackman", title = "注視者", text = "・・・。"},
		[2] = {img = "blackman", title = "注視者", text = "忘れるな、私は常に貴様を見ているぞ。"},
		[3] = {img = "", title = "啓示者ちゃん", text = "うぅ～い？"},
		[4] = {img = "blackman", title = "注視者", text = "・・・。"},
	};

	__talks[talkNames[11]] = {
		[1] = {img = "gabija", title = "女神ガビヤ", text = "あっ、救済者。"},
		[2] = {img = "gabija", title = "女神ガビヤ", text = "グリタを知りませんか？{nl}あの子ったら、また人の姿でどこかに行ってしまったらしくて・・・。"},
		[3] = {img = "gabija", title = "女神ガビヤ", text = "もし見かけたら、塔に戻るように言ってくださいね。"},
	};

	__talks[talkNames[12]] = {
		[1] = {img = "worpat", title = "ポイズンシューターマスター", text = "あら、啓示者さん、こんにちは。"},
		[2] = {img = "worpat", title = "ポイズンシューターマスター", text = "なんだか、ポイズンシューターの人口が減ってる気がするの。"},
		[3] = {img = "worpat", title = "ポイズンシューターマスター", text = "毒ってとっても強いんだよ？{nl}でも、最近なんだか毒が効果を発揮していないような・・・。"},
		[4] = {img = "worpat", title = "ポイズンシューターマスター", text = "プレイグドクターマスターにでも相談してみようかしら？"},
	};
end

function TOKENNOTICE_DLGSHOW(remainSec)

	if DLGTALK_SHOW == nill then
		return;
	end

	local index = random(1, #talkNames);

	if index == 2 then
		imcSound.PlayMusic("m_boss_scenario2", 1);
	elseif index >= 5 then
		imcSound.PlayMusic("m_boss_scenario", 1);
	end

	SetTextToken(remainSec);
	--log("random test laoded:" .. math.random(5));
	local talkName = talkNames[index];
	DLGTALK_SHOW(talkName);
end