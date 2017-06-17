
mzDlgTalk = mzDlgTalk or {};
mzDlgTalk.__talks = mzDlgTalk.__talks or {};

local __talks = mzDlgTalk.__talks;
local talkNames = {"rein1", "rein2", "rein3"};
talkNames[#talkNames + 1] = talkNames[#talkNames];

__talks[talkNames[1]] = {
    [1] = {img = "hauberk", title = "魔将ホーバーク", text = "待つのだ、啓示者よ。"},
    [2] = {img = "hauberk", title = "魔将ホーバーク", text = "その武具のポテンシャルは\"0\"だぞ。"},
    [3] = {img = "hauberk", title = "魔将ホーバーク", text = "どうしても叩きたくば、\"黄金の金床\"を用意することだ。"},
};

__talks[talkNames[2]] = {
    [1] = {img = "raima", title = "女神ライマ", text = "待つのです、救済者よ。"},
    [2] = {img = "raima", title = "女神ライマ", text = "その武具のポテンシャルはすでに\"0\"。"},
    [3] = {img = "raima", title = "女神ライマ", text = "どうしても叩きたければ、\"黄金の金床\"を使うのです。"},
};

__talks[talkNames[3]] = {
    [1] = {img = "gesti", title = "魔王ジェスティ", text = "・・・。"},
    [2] = {img = "gesti", title = "魔王ジェスティ", text = "おや、ポテンシャルが\"0\"だぞ？"},
    [3] = {img = "gesti", title = "魔王ジェスティ", text = "どうした、叩かぬのか？臆病者め。"},
};


-- Hooked function
function REINFORCE_131014_MSGBOX(frame)

	local fromItem, fromMoru = UPGRADE2_GET_ITEM(frame);
	local fromItemObj = GetIES(fromItem:GetObject());
	local curReinforce = fromItemObj.Reinforce_2;

	local moruObj = GetIES(fromMoru:GetObject());
	local price = GET_REINFORCE_131014_PRICE(fromItemObj, moruObj)
	local hadmoney = GET_TOTAL_MONEY();

	if hadmoney < price then
		ui.AddText("SystemMsgFrame", ScpArgMsg('NotEnoughMoney'));
		return;
	end
	
	local classType = TryGetProp(fromItemObj,"ClassType");
    local talkName = talkNames[math.floor(math.random(#talkNames))];

    if moruObj.ClassName ~= "Moru_Potential" and moruObj.ClassName ~= "Moru_Potential14d" then
        if fromItemObj.GroupName == 'Weapon' or (fromItemObj.GroupName == 'SubWeapon' and  classType ~='Shield') then
            if curReinforce >= 5 then
                if moruObj.ClassName == "Moru_Premium" or moruObj.ClassName == "Moru_Gold" or moruObj.ClassName == "Moru_Gold_14d" or moruObj.ClassName == "Moru_Gold_TA" then
                    ui.MsgBox(ScpArgMsg("GOLDMORUdontbrokenitemProcessReinforce?", "Auto_1", 3), "REINFORCE_131014_EXEC", "None");
                    return;
                else
                    if fromItemObj.PR > 0 then
                        ui.MsgBox(ScpArgMsg("WeaponWarningMSG", "Auto_1", 5), "REINFORCE_131014_EXEC", "None");
                    else
                        frame:ShowWindow(0);
                        if DLGTALK_SHOW ~= nil then
                            DLGTALK_SHOW(talkName);
                        else
                            ui.MsgBox("ポテンシャルが0だよ", "None", "None");
                        end
                    end
                    return;
                end
            end
        else
            if curReinforce >= 3 then
                if moruObj.ClassName == "Moru_Premium" or moruObj.ClassName == "Moru_Gold" or moruObj.ClassName == "Moru_Gold_14d" or moruObj.ClassName == "Moru_Gold_TA" then
                    ui.MsgBox(ScpArgMsg("GOLDMORUdontbrokenitemProcessReinforce?", "Auto_1", 3), "REINFORCE_131014_EXEC", "None");
                    return;
                else
                    if fromItemObj.PR > 0 then
                        ui.MsgBox(ScpArgMsg("Over_+{Auto_1}_ReinforceItemCanBeBroken_ProcessReinforce?", "Auto_1", 3), "REINFORCE_131014_EXEC", "None");
                    else
                        frame:ShowWindow(0);
                        if DLGTALK_SHOW ~= nil then
                            DLGTALK_SHOW(talkName);
                        else
                            ui.MsgBox("ポテンシャルが0だよ", "None", "None");
                        end
                    end
                    return;
                end
            end
        end
	end
	
	REINFORCE_131014_EXEC();
end

math.randomseed(os.time());
CHAT_SYSTEM("reinforce loaded.");