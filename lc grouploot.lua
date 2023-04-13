local LCGroupLoot = LibStub("AceAddon-3.0"):NewAddon("LCGroupLoot", "AceConsole-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local CallbackHandler = LibStub("CallbackHandler-1.0")
local AceComm = LibStub("AceComm-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

local UIConfig

local Serialize, Deserialize = AceSerializer.Serialize, AceSerializer.Deserialize

local defaults = {
    profile = {
		enable = false,
		lc = "",
        lootTable = {
        },
    }
}

local bossy = {
	["Flame Leviathan"] = {
		45117,
		45119,
		45108,
		45118,
		45109,
		45107,
		45111,
		45116,
		45113,
		45106,
		45112,
		45115,
		45114,
		45110,
		45086,
		45135,
		45136,
		45134,
		45133,
		45132
	},
	["Ignis the Furnance Master"] = {
		45186,
		45185,
		45162,
		45164,
		45187,
		45167,
		45161,
		45166,
		45157,
		45168,
		45158,
		45169,
		45165,
		45171,
		45170,
	},
	["Razorscale"] = {
		45138,
		45150,
		45146,
		45149,
		45141,
		45151,
		45143,
		45140,
		45139,
		45148,
		45510,
		45144,
		45142,
		45147,
		45137
	},
	["XT-002 Deconstructor"] = {
		45253,
		45258,
		45260,
		45259,
		45249,
		45251,
		45252,
		45248,
		45250,
		45247,
		45254,
		45255,
		45246,
		45256,
		45257,
		45446,
		45444,
		45445,
		45443,
		45442
	},
	["The Iron Council"] = {
		45224,
		45240,
		45238,
		45237,
		45232,
		45227,
		45239,
		45226,
		45225,		
		45228,
		45139,
		45236,
		45235,
		45233,
		45234,
		45242,
		45245,
		45244,
		45241,
		45243,
		45607,
		
	},
	["Kologarn"] = {
		45272,
		45275,
		45273,
		45265,
		45274,
		45264,
		45269,
		45268,
		45267,
		45262,
		45263,
		45271,
		45270,
		45266,
		45261,
	
	},
	["Algalon the Observer"] = {
		45665,
		45619,
		45611,
		45616,
		45610,
		45615,
		45594,
		45599,
		45609,
		45620,
		45607,
		45612,
		45613,
		45587,
		45570,
		45617,
		46053
	},
	["Auriaya"] = {
		45319,
		45435,
		45441,
		45439,
		45352,
		45440,
		45320,
		45334,
		45434,
		45326,
		45438,
		45436,
		45437,
		45315,
		45227,
	},
	["Hodir"] = {
		45453,
		45454,
		45452,
		45451,
		45450,
		45461,
		45462,
		45460,
		45459,
		45612,
		45457,
		45632,
		45633,
		45634,
	},
	["Thorim"] = {
		45468,
		45467,
		45469,
		45466,
		45463,
		45473,
		45474,
		45472,
		45471,
		45570,
		45470,
		45638,
		45639,
		45640,
	},
	["Freya"] = {
		45483,
		45482,
		45481,
		45480,
		45479,
		45486,
		45488,
		45487,
		45485,
		45484,
		45613,
		45653,
		45654,
		45655,
	},
	["Mimiron"] = {
		45493,
		45492,
		45491,
		45490,
		45489,
		45496,
		45497,
		45663,
		45495,
		45494,
		45620,
		45641,
		45642,
		45643,
	},
	["General Vezax"] = {
		45514,
		45508,
		45512,
		45504,
		45513,
		45502,
		45505,
		45501,
		45503,
		45515,
		45507,
		45509,
		45145,
		45498,
		45511,
		45520,
		45519,
		45517,
		45518,
		45516,
	},
	["Yogg-Saron"] = {
		45529,
		45532,
		45523,
		45524,
		45531,
		45525,
		45530,
		45522,
		45527,
		45521,
		45656,
		45657,
		45658,
		45537,
		45536,
		45534,
		45535,
		45533,
		45693,
	},
	-- ["Trash and Quest"] = {
		-- 45038,
		-- 43102
	-- }, 
	-- ["Custom 10m"] = {
		-- 45297,
		-- 45314,
		-- 45447,
		-- 46042,
		-- 46045,
		-- 46050,
		-- 46046,
		-- 45294,
		-- 45946,
		-- 46034,
		-- 46068,
		-- 46096,
		
	-- }
}

local options = {
  name = "LCGroupLoot",
  handler = LCGroupLoot,
}

-- Tablica zawierająca listę itemów
local lootTable = {
}

local selectedTab = ""
local tabRef = {}

function LCGroupLoot:PreloadItemLinks()
	for bossName, items in pairs(bossy) do
		for i, itemId in ipairs(items) do
				local itemIdNumber = tonumber(itemId)
				local _= GetItemInfo(itemIdNumber)
		end
	end
end

function LCGroupLoot:OnInitialize() 
	self.db = AceDB:New("LCGroupLootDB", defaults, true)

	--local options = AceDBOptions:GetOptionsTable(db)
	--AceConfig:RegisterOptionsTable("LCGroupLoot", options)
	-- Rejestracja funkcji obsługi wiadomości w AceComm
	AceComm:RegisterComm("LCGroupLootComm", function(prefix, message, distribution, sender)
		LCGroupLoot:OnLCGroupLootCommReceived(prefix, message, distribution, sender)
	end)	
	
	AceEvent:RegisterEvent("START_LOOT_ROLL", function(event, rollId, lootTime)
		LCGroupLoot:RollOnLoot(rollId)
	end)
	
	lootTable = self.db.profile.lootTable
	
	LCGroupLoot:PreloadItemLinks()
end

function LCGroupLoot:OnEnable()
	self:RegisterChatCommand("lcgl", "SlashProcessor")
	self:RegisterChatCommand("LCGroupLoot", "CreateLCGroupLootUI")
	--RegisterEvent("CHAT_MSG_ADDON", "OnEvent")
	--self:SetScript("OnEvent", OnEvent)
end

-- Tworzymy funkcję do sprawdzania, czy przedmiot znajduje się w tabeli łupu
function LCGroupLoot:IsItemInLootTable(itemID)
    return self.db.profile.lootTable[itemID] == true
end

-- Tworzymy funkcję do ustawiania wartości przedmiotu w tabeli łupu
function LCGroupLoot:SetLootTableValue(itemID, value)
    db.profile.lootTable[itemID] = value
end

function LCGroupLoot:IsPlayerRaidLeader()
    local playerName = UnitName("player")
    local raidLeaderName

    for i = 1, 40 do
        local name, rank = GetRaidRosterInfo(i)
        if rank == 2 then
            raidLeaderName = name
        end
        
        if playerName == raidLeaderName then
            return true
        end
    end

    return false
end

function LCGroupLoot:RollOnLoot(rollId)
    local itemLink = GetLootRollItemLink(rollId)

	local itemString = string.match(itemLink, "item:(%d+)")
    local itemId = tonumber(itemString)

	if LCGroupLoot:IsItemInLootTable(itemId) then
		if LCGroupLoot:IsPlayerRaidLeader() then
			--print(itemLink .. " - need")
			RollOnLoot(rollId, 1) -- "Need"
		else
			RollOnLoot(rollId, 0) -- "Pass"
			--print(itemLink .. " - pass")
		end
	else 
		--print(itemLink .. " - not in LC table")
	end
end

function LCGroupLoot:AreAllItemInfosAvailable()
    for itemID, _ in pairs(lootTable) do
        if not GetItemInfo(itemID) then
            return false
        end
    end
    return true
end

function LCGroupLoot:TryCreatingLCGroupLootUI()
    if AreAllItemInfosAvailable() then
        CreateLCGroupLootUI()
    else
        -- Odczekaj 1 sekundę i spróbuj ponownie
        C_Timer.After(1, TryCreatingLCGroupLootUI)
    end
end

function LCGroupLoot:CreateItemRow(itemId)
	local itemIdNumber = tonumber(itemId)
	--print(itemIdNumber)
	local itemName, itemLink, _, itemLevel, _, _, _, _, _, itemTexture = GetItemInfo(itemIdNumber)

	local itemGroup = AceGUI:Create("SimpleGroup")
	itemGroup:SetLayout("Flow")
	itemGroup:SetWidth(350)

	--itemGroup.frame:SetBackdrop(nil)

	local itemIcon = AceGUI:Create("Icon")
	itemIcon:SetImage(itemTexture)
	itemIcon:SetImageSize(25, 25)
	itemIcon:SetWidth(25)
	itemIcon:SetHeight(25)
	itemIcon:SetPoint("Left", UIParent, "Left", 10, -10)
	itemIcon:SetCallback("OnEnter", function()
		LCGroupLoot:ShowTooltip(itemIdNumber)
	end)
	itemIcon:SetCallback("OnLeave", function()
		GameTooltip:Hide()
	end)

	local itemLabel = AceGUI:Create("Label")
	itemLabel:SetText(itemLink)
	itemLabel:SetFontObject(GameFontHighlight)
	itemLabel:SetJustifyH("LEFT")
	itemLabel:SetWidth(200)
	
	-- local ilvlLabel = AceGUI:Create("Label")
	-- ilvlLabel:SetText("["..itemLevel.."]")
	-- ilvlLabel:SetFontObject(GameFontHighlight)
	-- ilvlLabel:SetJustifyH("LEFT")
	-- ilvlLabel:SetWidth(30)

	local checked = lootTable[itemIdNumber]
	
	if(checked == nil) then
		checked = false
	end

	local itemCheckbox = AceGUI:Create("CheckBox")
	itemCheckbox:SetLabel("LC")
	itemCheckbox:SetValue(checked)
	itemCheckbox:SetWidth(50)
	itemCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
		lootTable[itemIdNumber] = value
	end)

	if LCGroupLoot:IsPlayerRaidLeader() then
		itemCheckbox:SetDisabled(false)
	else
		itemCheckbox:SetDisabled(true)
	end
	
	itemGroup:AddChild(itemIcon)
	--itemGroup:AddChild(ilvlLabel)
	itemGroup:AddChild(itemLabel)
	itemGroup:AddChild(itemCheckbox)

    return itemGroup
end

function LCGroupLoot:SendLootTableUpdate()
    local message = "LCGroupLoot_UPDATE:" .. AceSerializer:Serialize(lootTable)
	--print(message)
	AceComm:SendCommMessage("LCGroupLootComm", message, "RAID", nil, "NORMAL")
end

function LCGroupLoot:SendLCUpdate()
    local message = "LC_UPDATE:" .. AceSerializer:Serialize(self.db.profile.LC)
	--print(message)
	AceComm:SendCommMessage("LCGroupLootComm", message, "RAID", nil, "NORMAL")
end

function LCGroupLoot:CreateLCGroupLootUI()
    UIConfig = AceGUI:Create("Frame")
    UIConfig:SetTitle("LC GroupLoot")
    UIConfig:SetLayout("Flow")
	UIConfig:SetWidth(600)

    -- lista zakładek
	local tabs = {} 
	for bossName, items in pairs(bossy) do
		table.insert(tabs, {text = bossName, value = bossName})
	end
	
	local sendUpdateButton = AceGUI:Create("Button")
	sendUpdateButton:SetText("Send Update")
	sendUpdateButton:SetWidth(150)
	sendUpdateButton:SetCallback("OnClick", function()
		LCGroupLoot:SendLootTableUpdate()
	end)
	
	local saveSettingsButton = AceGUI:Create("Button")
	saveSettingsButton:SetText("Save Settings")
	saveSettingsButton:SetWidth(150)
	saveSettingsButton:SetCallback("OnClick", function()
		self.db.profile.lootTable = lootTable
		--tprint(lootTable,2)
	end)
	
	local masteLooterLabel = AceGUI:Create("Label")
	masteLooterLabel:SetText("LC:")
	masteLooterLabel:SetFontObject(GameFontHighlight)
	masteLooterLabel:SetJustifyH("Right")
	masteLooterLabel:SetWidth(50)
	
	local masterLooterET = AceGUI:Create("EditBox")
	masterLooterET:SetWidth(150)
	masterLooterET:SetText(self.db.profile.lc)
	masterLooterET:SetCallback("OnTextChanged", function(widget, event, text)
		self.db.profile.lc = text
	end)

	if LCGroupLoot:IsPlayerRaidLeader() then
		sendUpdateButton:SetDisabled(false)
		saveSettingsButton:SetDisabled(false)
		masterLooterET:SetDisabled(true)
	else
		sendUpdateButton:SetDisabled(true)
		saveSettingsButton:SetDisabled(true)
		masterLooterET:SetDisabled(true)
	end
	

	UIConfig:AddChild(sendUpdateButton)
	UIConfig:AddChild(saveSettingsButton)
	UIConfig:AddChild(masteLooterLabel)
	UIConfig:AddChild(masterLooterET)
	
	local bottomContainer = AceGUI:Create("SimpleGroup")
	bottomContainer:SetLayout("Flow")
	bottomContainer:SetFullWidth(true)	
	bottomContainer:SetFullHeight(true)
	
	local lootListFrame = AceGUI:Create("InlineGroup")
	lootListFrame:SetLayout("Flow")
	lootListFrame:SetWidth(400)	
	lootListFrame:SetFullHeight(true)
	
	local bossListFrame = AceGUI:Create("InlineGroup")
	bossListFrame:SetLayout("Flow")
	bossListFrame:SetWidth(160)	
	bossListFrame:SetFullHeight(true)
	
	local tabList = AceGUI:Create("ScrollFrame")
	tabList:SetFullWidth(true)
	tabList:SetLayout("List")
	for bossName, items in pairs(bossy) do
		local bossLabel = AceGUI:Create("InteractiveLabel")
		bossLabel:SetText(bossName)
		bossLabel:SetFontObject(GameFontHighlightSmall)
		bossLabel:SetColor(1,1,1)
		bossLabel:SetJustifyH("Left")
		bossLabel:SetWidth(150)
		bossLabel:SetCallback("OnClick", function(widget,event,group)
			selectedTab = bossName
			
			for i, tab in ipairs(tabRef) do 
				tab:SetColor(1,1,1)
			end
			widget:SetColor(0.67,0.83,0.45)
			lootListFrame:ReleaseChildren()
			lootListFrame:SetTitle(bossName)
			local items = bossy[selectedTab]
			local tabContent = AceGUI:Create("ScrollFrame")
			tabContent:SetLayout("List")
			tabContent:SetFullWidth(true)
			for i, itemID in ipairs(items) do	
				local itemRow = LCGroupLoot:CreateItemRow(itemID)
				tabContent:AddChild(itemRow)
			end	
			lootListFrame:AddChild(tabContent)
		end)
		
		tabRef[#tabRef+1] = bossLabel
		tabList:AddChild(bossLabel)
	end
	
	bossListFrame:AddChild(tabList)
	bottomContainer:AddChild(lootListFrame)
	bottomContainer:AddChild(bossListFrame)
	
	UIConfig:AddChild(bottomContainer)
end

function LCGroupLoot:HandleLootTableUpdate(sender, message)
    local _, _, encodedData = string.find(message, "LCGroupLoot_UPDATE:(.+)")
    local success, newLootTable = AceSerializer:Deserialize(encodedData)
    if success then
        lootTable = newLootTable
        self.db.profile.lootTable = lootTable
    end
end

function LCGroupLoot:OnEvent(event, prefix, message, channel, sender)
	--self.print("on event")
    if event == "CHAT_MSG_ADDON" and prefix == "LCGroupLoot" then
        HandleLootTableUpdate(sender, message)
    end

end

function LCGroupLoot:OnLCGroupLootCommReceived(prefix, message, distribution, sender)
	--print("OnLCGroupLootCommReceived")
	LCGroupLoot:HandleLootTableUpdate(sender, message)
end

function LCGroupLoot:SlashProcessor(input)
	LCGroupLoot:CreateLCGroupLootUI()
end

function LCGroupLoot:ShowTooltip(itemID)
    local tooltip = GameTooltip
    tooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
    tooltip:SetHyperlink("item:" .. itemID)
    tooltip:Show()
end

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))      
    else
      print(formatting .. v)
    end
  end
end