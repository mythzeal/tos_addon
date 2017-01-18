--v1.1.0

local cwAPI = require("cwapi");
local acutil = require("acutil");

local log = cwAPI.util.log;

-- setting defaults
local defaults = {};
defaults.flag = true;

-- loading json file(dir, filename(without .json), ignoreError)
local options = cwAPI.json.load("remove_pump_recipe", "remove_pump_recipe", true);
if not options then
	options = defaults;
end

-- applying defaults if needed
for key, val in pairs(defaults) do

	if not options[key] then
		options[key] = val;
	end

	local tpval = type(val);

	if tpval == "table" then

		for key2, val2 in pairs(val) do
			if options[key][key2] == nil then
				options[key][key2] = val2;
			end
		end

	end

end

local function checkCommand(words)

	local cmd = table.remove(words, 1);

	if not cmd then
		options.flag = not options.flag;
	elseif cmd == "on" then
		options.flag = true;
	elseif cmd == "off" then
		options.flag = false;
	else
		options.flag = not options.flag;
	end

	cwAPI.json.save(options, "remove_pump_recipe");
	setPumpRecipe(options.flag);
end

function setPumpRecipe(flag)

	local msg;

	if flag then
		PUMP_RECIPE_OPEN = PUMP_RECIPE_OPEN_DUMMY;
		ON_PUMP_COLLECTION_OPEN = PUMP_RECIPE_OPEN_DUMMY;
		msg = "[RemovePR] set enabled. (hide recipe)";
	else
		PUMP_RECIPE_OPEN = PUMP_RECIPE_OPEN_OLD;
		ON_PUMP_COLLECTION_OPEN = ON_PUMP_COLLECTION_OPEN_OLD;
		msg = "[RemovePR] set disabled. (show recipe)";
	end

	log(msg);
end

function PUMP_RECIPE_OPEN_DUMMY() end

local isLoaded = false;

function REMOVE_PUMP_RECIPE_ON_INIT(addon, frame)

	if isLoaded then
		return;
	end

	if not cwAPI then
		ui.SysMsg("[RemovePR] requires cwAPI to run.");
		return false;
	end

	if PUMP_RECIPE_OPEN_OLD == nil then
		-- backup origin function
		PUMP_RECIPE_OPEN_OLD = PUMP_RECIPE_OPEN;
	end
--[[
	if PUMP_COLLECTION_ON_INIT_OLD == nil then
		-- backup origin function
		PUMP_COLLECTION_ON_INIT_OLD = PUMP_COLLECTION_ON_INIT;
	end
]]
	if ON_PUMP_COLLECTION_OPEN_OLD == nil then
		-- backup origin function
		ON_PUMP_COLLECTION_OPEN_OLD = ON_PUMP_COLLECTION_OPEN;
	end

	acutil.slashCommand("/removepr", checkCommand);
	acutil.slashCommand("/rpr", checkCommand);
	cwAPI.json.save(options, "remove_pump_recipe");

	isLoaded = true;

	log("[RemovePR] /removepr switch on/off.");
	setPumpRecipe(options.flag);

end
