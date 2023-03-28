-- Tworzymy nowy addon
local LCGroupLoot = LibStub("AceAddon-3.0"):NewAddon("LCGroupLoot", "AceConsole-3.0")

-- Importujemy niezbędne biblioteki
local AceGUI = LibStub("AceGUI-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local CallbackHandler = LibStub("CallbackHandler-1.0")
local AceComm = LibStub("AceComm-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

local Serialize, Deserialize = AceSerializer.Serialize, AceSerializer.Deserialize

local defaults = {
    profile = {
		enable = false,
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
	}
}

local options = {
  name = "LC AutoPass",
  handler = LCGroupLoot,
}

-- Tablica zawierająca listę itemów
local lootTable = {
}

function LCGroupLoot:OnInitialize() 
	self.db = AceDB:New("LCGroupLootDB", defaults, true)
	--local options = AceDBOptions:GetOptionsTable(db)
	--AceConfig:RegisterOptionsTable("LCGroupLoot", options)
	-- Rejestracja funkcji obsługi wiadomości w AceComm
	AceComm:RegisterComm("LCGroupLootComm", function(prefix, message, distribution, sender)
		LCGroupLoot:OnLCGroupLootCommReceived(prefix, message, distribution, sender)
	end)
	
	lootTable = self.db.profile.lootTable
	tprint(lootTable,2)
end

function LCGroupLoot:OnEnable()
	self:RegisterChatCommand("lca", "SlashProcessor")
	self:RegisterChatCommand("LCGroupLoot", "CreateLCGroupLootUI")
	--RegisterEvent("CHAT_MSG_ADDON", "OnEvent")
	--self:SetScript("OnEvent", OnEvent)
end

-- Tworzymy funkcję do sprawdzania, czy przedmiot znajduje się w tabeli łupu
local function IsItemInLootTable(itemID)
    return self.db.profile.lootTable[itemID] == true
end

-- Tworzymy funkcję do ustawiania wartości przedmiotu w tabeli łupu
function LCGroupLoot:SetLootTableValue(itemID, value)
    db.profile.lootTable[itemID] = value
end

function LCGroupLoot:IsPlayerRaidLeaderOrMasterLooter()
    local playerName = UnitName("player")
    local raidLeaderName, masterLooterName

    for i = 1, 40 do
        local name, rank = GetRaidRosterInfo(i)
        if rank == 2 then
            raidLeaderName = name
        end
        local lootMethod, _, masterLooterRaidID = GetLootMethod()
        if lootMethod == "master" and i == masterLooterRaidID then
            masterLooterName = name
        end
        if playerName == raidLeaderName or playerName == masterLooterName then
            return true
        end
    end

    return false
end

function LCGroupLoot:AutoPassOnLoot()
    for i = 1, GetNumLootItems() do
        local itemLink = GetLootSlotLink(i)
        local itemID = tonumber(itemLink:match("item:(%d+)"))

        if IsItemInLootTable(itemID) then
            if IsPlayerRaidLeaderOrMasterLooter() then
                LootSlot(i) -- Wybiera "Need"
            else
                ConfirmLootSlot(i) -- Wybiera "Pass"
            end
        end
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
	local itemName, itemLink, _, itemLevel, _, _, _, _, _, itemTexture = GetItemInfo(itemIdNumber)
		
	local itemGroup = AceGUI:Create("SimpleGroup")
	itemGroup:SetLayout("Flow")
	itemGroup:SetFullWidth(true)
	itemGroup.frame:SetBackdrop(nil)

	local itemIcon = AceGUI:Create("Icon")
	itemIcon:SetImage(itemTexture)
	itemIcon:SetImageSize(20, 20)
	itemIcon:SetWidth(20)
	itemIcon:SetHeight(20)
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
	itemLabel:SetWidth(180)

	local ilvlLabel = AceGUI:Create("Label")
	ilvlLabel:SetText("["..itemLevel.."]")
	ilvlLabel:SetFontObject(GameFontHighlight)
	ilvlLabel:SetJustifyH("LEFT")
	ilvlLabel:SetWidth(30)

	local checked = lootTable[itemIdNumber]
	
	if(checked == nil) then
		checked = false
	end

	local itemCheckbox = AceGUI:Create("CheckBox")
	itemCheckbox:SetLabel("LC")
	itemCheckbox:SetValue(checked)
	itemCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
		lootTable[itemIdNumber] = value
	end)

	if LCGroupLoot:IsPlayerRaidLeaderOrMasterLooter() then
		itemCheckbox:SetDisabled(false)
	else
		itemCheckbox:SetDisabled(true)
	end
	
	itemGroup:AddChild(itemIcon)
	itemGroup:AddChild(ilvlLabel)
	itemGroup:AddChild(itemLabel)
	itemGroup:AddChild(itemCheckbox)

    return itemGroup
end

function LCGroupLoot:SendLootTableUpdate()
    local message = "LCGroupLoot_UPDATE:" .. AceSerializer:Serialize(lootTable)
	print(message)
	AceComm:SendCommMessage("LCGroupLootComm", message, "RAID", nil, "NORMAL")
end

function LCGroupLoot:CreateLCGroupLootUI()
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("LC Autopass")
    frame:SetStatusText("Lista przedmiotów do automatycznego rozdawania")
    frame:SetLayout("Flow")

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
		print("Ustawienia zostały zapisane.")
		tprint(lootTable,2)
		print("db: ")
		tprint(lootTable,2)
	end)

	if LCGroupLoot:IsPlayerRaidLeaderOrMasterLooter() then
		sendUpdateButton:SetDisabled(false)
		saveSettingsButton:SetDisabled(false)
	else
		sendUpdateButton:SetDisabled(true)
		saveSettingsButton:SetDisabled(true)
	end
	

	frame:AddChild(sendUpdateButton)
	frame:AddChild(saveSettingsButton)
	
	-- Tworzymy zakładki
	local tabGroup = AceGUI:Create("TabGroup")
	tabGroup:SetTabs(tabs)
	tabGroup:SetLayout("Flow")
	tabGroup:SetFullWidth(true)
	tabGroup:SetFullHeight(true)
	tabGroup:SetCallback("OnGroupSelected", function(widget, event, group)
		widget:ReleaseChildren()
		
		local itemList = AceGUI:Create("SimpleGroup")
		itemList:SetLayout("List")
		itemList:SetFullWidth(true)
		itemList.frame:SetBackdrop(nil)
		widget:AddChild(itemList)
		
		 
		items = bossy[group]
		tprint(items,1)
 
		for i, itemID in ipairs(items) do	
			local itemRow = LCGroupLoot:CreateItemRow(itemID)
			itemList:AddChild(itemRow)
		end			
    end)

	frame:AddChild(tabGroup)
end

function LCGroupLoot:test(widget, group) 
			local itemLabel = AceGUI:Create("Label")
			itemLabel:SetText(group)
			itemLabel:SetFontObject(GameFontHighlight)
			itemLabel:SetJustifyH("LEFT")
			itemLabel:SetWidth(300)
        tabGroup:AddChild(itemLabel)
end

function LCGroupLoot:fireGroup(widget, group) 
    print(widget)
	print(event)
	print(group)

	for bossName, items in pairs(bossy) do
		local itemGroup = AceGUI:Create("SimpleGroup")
		itemGroup:SetLayout("Flow")
		itemGroup:SetFullWidth(true)
		tprint(items,1)

		for i, itemID in ipairs(items) do	
			local itemName, itemLink, _, itemLevel, _, _, _, _, _, itemTexture = GetItemInfo(itemID)

			local itemIcon = AceGUI:Create("Icon")
			itemIcon:SetImage(itemTexture)
			itemIcon:SetImageSize(40, 40)
			itemIcon:SetWidth(40)
			itemIcon:SetHeight(40)
			itemIcon:SetCallback("OnEnter", function()
				LCGroupLoot:ShowTooltip(itemID)
			end)
			itemIcon:SetCallback("OnLeave", function()
				GameTooltip:Hide()
			end)

			local itemLabel = AceGUI:Create("Label")
			itemLabel:SetText(itemLink)
			itemLabel:SetFontObject(GameFontHighlight)
			itemLabel:SetJustifyH("LEFT")
			itemLabel:SetWidth(300)

			local ilvlLabel = AceGUI:Create("Label")
			ilvlLabel:SetText(itemLevel)
			ilvlLabel:SetFontObject(GameFontHighlight)
			ilvlLabel:SetJustifyH("LEFT")
			ilvlLabel:SetWidth(300)

			local checked = lootTable[itemID]
			
			if(checked == nil) then
				checked = false
			end

			local itemCheckbox = AceGUI:Create("CheckBox")
			itemCheckbox:SetLabel("LC")
			itemCheckbox:SetValue(checked)
			itemCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
				lootTable[itemID] = value
			end)

			if LCGroupLoot:IsPlayerRaidLeaderOrMasterLooter() then
				itemCheckbox:SetDisabled(false)
			else
				itemCheckbox:SetDisabled(true)
			end
			
			print("aaaa")

			itemGroup:AddChild(itemIcon)
			print("bbb")
			itemGroup:AddChild(ilvlLabel)
			print("ccc")
			itemGroup:AddChild(itemLabel)
			print("ddd")
			itemGroup:AddChild(itemCheckbox)
			print("eee")
			
			frame:AddChild(itemGroup)
		end
	end
	
end

function LCGroupLoot:HandleLootTableUpdate(sender, message)
    local _, _, encodedData = string.find(message, "LCGroupLoot_UPDATE:(.+)")
    local success, newLootTable = AceSerializer:Deserialize(encodedData)
	print("HandleLootTableUpdate ")
    if success then
		print("new loot table")
		tprint(newLootTable)
        lootTable = newLootTable
        self.db.profile.lootTable = lootTable
		print("Ustawienia zostały pobrane.")
		tprint(lootTable,2)
    end
end

function LCGroupLoot:OnEvent(event, prefix, message, channel, sender)
	self.print("on event")
    if event == "CHAT_MSG_ADDON" and prefix == "LCGroupLoot" then
        HandleLootTableUpdate(sender, message)
    end
end

function LCGroupLoot:OnLCGroupLootCommReceived(prefix, message, distribution, sender)
	print("OnLCGroupLootCommReceived")
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