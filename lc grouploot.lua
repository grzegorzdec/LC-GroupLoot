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
		rwLcItems = false,
        lootTable = {
			lc = ""
        },
    }
}

function LCGroupLoot:FactionSwitch(horde, alliance)
	return UnitFactionGroup("player") == "Horde" and horde or alliance
end

local content = {
	["Ulduar"] = {
		"Flame Leviathan",
		"Ignis the Furnance Master",
		"Razorscale",
		"XT-002 Deconstructor",
		"The Iron Council",
		"Kologarn",
		"Algalon the Observer",
		"Auriaya",
		"Hodir",
		"Thorim",
		"Freya",
		"Mimiron",
		"General Vezax",
		"Yogg-Saron"		
	},
	["ToGC"] = {
		"The Beasts of Northrend",
		"Lord Jaraxxus",
		"Faction Champions",
		"The Twin Val'kyr",
		"Anub'arak",
		"Argent Crusade Tribute Chest"
	},
}

local contentDifficulty = {
	["Ulduar"] = {
		"10 raid",
		"25 raid"
	},
	["ToGC"] = {
		"10 raid", 
		"10 raid HC",
		"25 raid",
		"25 raid HC"
	}
}

local contentOrder = {
	[1] = "Ulduar",
	[2] = "ToGC",
}

local bossy = {
	["Flame Leviathan"] = {
		["25 raid"] = {
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
		["10 raid"] = { 
			45289,
			45291,
			45288,
			45283,
			45285,
			45292,
			45286,
			45284,
			45287,
			45282,
			45293,
			45300,
			45295,
			45297,
			45296,
		}
	},
	["Ignis the Furnance Master"] = {
		["25 raid"] = {
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
		["10 raid"] = {
			45317,
			45318,
			45312,
			45316,
			45321,
			45310,
			45313,
			45314,
			45311,
			45309,
		}
	},
	["Razorscale"] = {
		["25 raid"] = {
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
		["10 raid"] = { 
			45306,
			45302,
			45301,
			45307,
			45299,
			45305,
			45304,
			45303,
			45308,
			45398,
		}
	},
	["XT-002 Deconstructor"] = {
		["25 raid"] = {
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
		["10 raid"] = { 
			45694,
			45677,
			45686,
			45687,
			45679,
			45676,
			45680,
			45675,
			45685,
			45682,
			45869,
			45867,
			45871,
			45868,
			45870,
		}
	},
	["The Iron Council"] = {
		["25 raid"] = {
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
		["10 raid"] = { 
			45322,
			45323,
			45324,
			45378,
			45329,
			45333,
			45330,
			45318,
			45332,
			45331,
			45455,
			45447,
			45456,
			45449,
			45448,
			45506,
		}
	},
	["Kologarn"] = {
		["25 raid"] = {
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
		["10 raid"] = { 
			45704,
			45701,
			45697,
			45698,
			45696,
			45699,
			45702,
			45703,
			45700,
			45795,
		}
	},
	["Algalon the Observer"] = {
		["25 raid"] = {
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
		["10 raid"] = { 
			46042,
			46045,
			46050,
			46043,
			46049,
			46044,
			46037,
			46039,
			46041,
			46047,
			46040,
			46048,
			46046,
			46038,
			46051,
		}
	},
	["Auriaya"] = {
		["25 raid"] = {
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
		["10 raid"] = { 
			45832,
			45856,
			45864,
			45709,
			45711,
			45712,
			45708,
			45866,
			45707,
			45713,
		}
	},
	["Hodir"] = {
		["25 raid"] = {
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
		["10 raid"] = { 
			45873,
			45464,
			45874,
			45458,
			45872,
			45888,
			45876,
			45886,
			45887,
			45877,
			45650,
			45651,
			45652,
		}
	},
	["Thorim"] = {
		["25 raid"] = {
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
		["10 raid"] = { 
			45896,
			45927,
			45894,
			45895,
			45892,
			45828,
			45833,
			45831,
			45929,
			45930,
			45659,
			45660,
			45661,
		}
	},
	["Freya"] = {
		["25 raid"] = {
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
		["10 raid"] = { 
			45940,
			45941,
			45935,
			45936,
			45934,
			45943,
			45945,
			45946,
			45947,
			45294,
			45788,
			45644,
			45645,
			45646,
			46110,
		}	
	},
	["Mimiron"] = {
		["25 raid"] = {
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
		["10 raid"] = { 
			45973,
			45976,
			45974,
			45975,
			45972,
			45993,
			45989,
			45982,
			45988,
			45990,
			45787,
			45647,
			45648,
			45649,
		}
	},
	["General Vezax"] = {
		["25 raid"] = {
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
		["10 raid"] = { 
			46014,
			46013,
			46012,
			46009,
			46346,
			45997,
			46008,
			46015,
			46010,
			46011,
			45996,
			46032,
			46034,
			46036,
			46035,
			46033,
		}	
	},
	["Yogg-Saron"] = {
		["25 raid"] = {
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
		["10 raid"] = { 
			46030,
			46019,
			46028,
			46022,
			46021,
			46024,
			46016,
			46031,
			46025,
			46018,
			45635,
			45636,
			45637,
			46068,
			46095,
			46096,
			46097,
			46067,
			46312,
		}	
	},
	["The Beasts of Northrend"] = {
		["10 raid"] = LCGroupLoot:FactionSwitch({
				47885,
				47857,
				47853,
				47860,
				47850,
				47852,
				47851,
				47859,
				47858,
				47849,
				47854,
				47856
			}, {
				47617,			
				47613,
				47608,
				47616,
				47610,
				47611,
				47609,
				47615,
				47614,
				47607,
				47578,
				47612,
			}
		), 
		["10 raid HC"] = LCGroupLoot:FactionSwitch({
				47994,
				47996,
				47992,
				47999,
				47989,
				47991,
				47990,
				47998,
				47997,
				47988,
				47993,
				47995
			}, {
				47921,
				47923,
				47919,
				47926,
				47916,
				47918,
				47917,
				47924,
				47925,
				47915,
				47920,
				47922,
			}
		),
		["25 raid"] = LCGroupLoot:FactionSwitch({
				47257,
				47256,
				47264,
				47258,
				47259,
				47262,
				47251,
				47256,
				47254,
				47253,
				47263,
				47242,
				47252,
				47251,
				47255,
				47260,
			}, {
				46970,
				46976,
				46992,
				46972,
				46974,
				46988,
				46960,
				46990,
				46962,
				46961,
				46985,
				47242,
				46959,
				46979,
				46958,
				46963,
			}
		),
		["25 raid HC"] = LCGroupLoot:FactionSwitch({
				47418,
				47417,
				47425,
				47419,
				47420,
				47423,
				47412,
				47426,
				47415,
				47414,
				47424,
				47442,
				47413,
				47422,
				47416,
				47421,
			}, {
				46971,
				46977,
				46993,
				46973,
				46975,
				46989,
				46965,
				46991,
				46968,
				46967,
				46986,
				47242,
				46966,
				46980,
				46969,
				46964,
			}
		),
	},
	["Lord Jaraxxus"] = {
		["10 raid"] = LCGroupLoot:FactionSwitch({
				47861,
				47865,
				47863,
				47866,
				49236,
				47867,
				47869,
				47870,
				47872,
				47864,
				47862,
				47868,
				47871,
			}, {
				47663,
				47620,
				47669,
				47621,
				49235,
				47683,
				47680,
				47711,
				47619,
				47679,
				47618,
				47703,
				47676,			
			}
		), 
		["10 raid HC"] = LCGroupLoot:FactionSwitch({
				48000,
				48004,
				48002,
				48005,
				49237,
				48006,
				48008,
				48009,
				48011,
				48003,
				48001,
				48007,
				48010,
			}, {
				47927,
				47931,
				47929,
				47932,
				49238,
				47933,
				47935,
				47937,
				47930,
				47939,
				47928,
				47934,
				47938,
			}
		), 
		["25 raid"] = LCGroupLoot:FactionSwitch({
				47275, 
				47274, 				
				47270, 				
				47277, 				
				47280, 				
				47268, 				
				47279, 				
				47273, 				
				47269, 				
				47242,				
				47272,				
				47278,				
				47271,				
				47276,				
				47266,				
				47267,				
			}, {
				47042,
			    47051,
			    47000,
			    47055,
			    47056,
			    46999,
			    47057,
			    47052,
			    46997,
				47242,
				47043,
				47223,
				47041,
				47053,
				46996,
				46994,
			}
		), 
		["25 raid HC"] = LCGroupLoot:FactionSwitch({
				47436,
				47435,
				47431,
				47438,
				47441,
				47429,
				47440,
				47434,
				47430,
				47242,
				47433,
				47439,
				47432,
				47437,
				47427,
				47428,
			}, {
				47063,
				47062,
				47004,
				47066,
				47068,
				47002,
				47067,
				47061,
				47003,
				47242,
				47060,
				47224,
				47059,
				47064,
				47001,
				46995,
			}
		), 
	},
	["Faction Champions"] = {
		["10 raid"] = LCGroupLoot:FactionSwitch({
				47873,
				47878,
				47875,
				47876,
				47877,
				47880,
				47882,
				47879,
				47881,
				47874,				
			}, {
				47721,
				47719,
				47718,
				47717,
				47720,
				47728,
				47727,
				47726,
				47725,
				47724,				
			}
		), 
		["10 raid HC"] = LCGroupLoot:FactionSwitch({
				48012,
				48017,
				48014,
				48015,
				48016,
				48019,
				48021,
				48018,
				48020,
				48013,				
			}, {     
				47940,
				47945,
				47942,
				47943,
				47944,
				47947,
				47949,
				47946,
				47948,
				47941,
			}
		), 
		["25 raid"] = LCGroupLoot:FactionSwitch({
				47291,
				47286,
				47293,
				47292,
				47284,
				47281,
				47289,
				47295,
				47288,
				47294,
				47283,
				47242,
				47282,
				47290,
				47285,
				47287,
			}, {     
				47089,
				47081,
				47092,
				47094,
				47071,
				47073,
				47083,
				47090,
				47082,
				47093,
				47072,
				47242,
				47070,
				47080,
				47069,
				47079,
			}
		), 
		["25 raid HC"] = LCGroupLoot:FactionSwitch({
				47452,
		        47447,
		        47454,
		        47453,
		        47445,
		        47442,
		        47450,
		        47456,
		        47449,
		        47455,
		        47444,
		        47242,
		        47443,
		        47451,
		        47446,
		        47448,
			}, {     
				47095,
				47084,
				47097,
				47096,
				47077,
			    47074,
			    47087,
			    47099,
			    47086,
			    47098,
			    47076,
			    47242,
			    47075,
			    47088,
			    47078,
				47085,
			}
		), 
	},
	["The Twin Val'kyr"] = {
		["10 raid"] = LCGroupLoot:FactionSwitch({
				47889,
				49232,
				47891,
				47887,
				47893,
				47885,
				47890,
				47888,
				47913,
				47886,
				47884,
				47892,
				47883,				
			}, {     
				47745,
				49231,
				47746,
				47739,
				47744,
				47738,
				47747,
				47700,
				47742,
				47736,
				47737,
				47743,
				47740,
			}
		), 
		["10 raid HC"] = LCGroupLoot:FactionSwitch({
				48028,
				49233,
				48034,
				48026,
				48038,
				48024,
				48030,
				48027,
				48032,
				48025,
				48023,
				48036,
				48022,
			}, {     
			    47956,
			    49234,
			    47959,
			    47954,
			    47961,
			    47952,
				47957,
				47955,
				47958,
				47953,
				47951,
				47960,
				47950,
			}
		), 
		["25 raid"] = LCGroupLoot:FactionSwitch({
				47301,
				47306,
				47308,
				47299,
				47296,
				47310,
		        47298,
		        47304,
		        47307,
		        47305,
		        47297,
		        47303,
		        47309,
		        47242,
		        47300,
		        47302,
			}, {     
				47126,
				47141,
				47107,
				47140,
				47106,
				47142,
				47108,
				47121,
				47116,
				47105,
				47139,
				47115,
				47138,
				47242,
				47104,
				47114,
			}
		), 
		["25 raid HC"] = LCGroupLoot:FactionSwitch({
				47462,
		        47467,
		        47469,
		        47460,
		        47457,
		        47471,
		        47459,
		        47465,
		        47468,
		        47466,
		        47458,
		        47464,
		        47470,
		        47242,
		        47461,
		        47463,
			}, {	 
				47129,
				47143,
				47112,
				47145,
				47109,
				47147,
				47111,
				47132,
				47133,
				47110,
				47144,
				47131,
				47146,
				47242,
				47113,
				47130,
			}
		), 
	},
	["Anub'arak"] = {
		["10 raid"] = LCGroupLoot:FactionSwitch({
				47906,
				47909,
				47904,
		        47897,
		        47901,
		        47896,
		        47902,
		        47908,
		        47899,
		        47903,
		        47898,
		        47894,
		        47905,
		        47911,
		        47900,
		        47910,
		        47895,
		        47907,
			}, {     
				47838,
				47837,
				47832,
				47813,
				47829,
				47811,
				47836,
				47830,
				47810,
				47814,
				47808,
				47809,
				47816,
				47834,
				47815,
				47835,
				47812,
				47741,
			}
		), 
		["10 raid HC"] = LCGroupLoot:FactionSwitch({
				48051,
		        48054,
		        48049,
		        48042,
		        48046,
		        48041,
		        48047,
		        48053,
		        48044,
		        48048,
		        48043,
		        48039,
		        48050,
		        48056,
		        48045,
		        48055,
		        48040,
		        48052,
			}, {     
				47974,
				47977,
				47972,
				47965,
				47969,
				47964,
				47976,
				47970,
				47967,
				47971,
				47966,
				47962,
				47973,
				47979,
				47968,
				47978,
				47963,
				47975,
			}
		), 
		["25 raid"] = LCGroupLoot:FactionSwitch({
				47328,
		        47320,
		        47324,
		        47326,
		        47317,
		        47321,
		        47313,
		        47318,
		        47325,
		        47311,
		        47319,
		        47330,
		        47323,
		        47312,
		        47242,
		        47315,
		        47327,
		        47316,
		        47314,
		        47322,
		        47329,
			}, {     
				47225,
				47183,
				47203,
				47235,
				47187,
				47194,
				47151,
				47186,
				47204,
				47152,
				47184,
				47234,
				47195,
				47150,
				47242,
				47054,
				47149,
				47182,
				47148,
				47193,
				47233,
			}
		), 
		["25 raid HC"] = LCGroupLoot:FactionSwitch({
				47490,
				47481,
				47485,
				47487,
				47478,
				47482,
				47474,
				47479,
				47486,
				47472,
				47480,
				47492,
				47484,
				47473,
				47242,
				47476,
				47489,
				47477,
				47475,
				47483,
				47491,
			}, {     
				47238,
				47192,
				47208,
				47236,
				47189,
				47205,
				47155,
				47190,
				47209,
				47153,
				47191,
				47240,
				47207,
				47154,
				47242,
				47237,
				47157,
				47188,
				47156,
				47206,
				47239,
			}
		), 
	},
	["Argent Crusade Tribute Chest"] = {
		["10 raid HC"] = LCGroupLoot:FactionSwitch({
				47242,
				47556,
				48703,
				48699,
				48693,
				48701,
				48697,
				48705,
				48695,
				47242,
				49046,
				48669,
				48668,
				48670,
				48666,
				48667,
			}, {
				47242,
				47556,
				48712,
				48714,
				48709,
				48708,
				48711,
				48710,
			    48713,
			    47242,
			    49044,
			    48674,
			    48673,
			    48675,
			    48671,
			    48672,				
			}
		), 
		["25 raid HC"] = LCGroupLoot:FactionSwitch({
				47557,
		        47558,
		        47559,
		        47513,
		        47528,
		        47518,
		        47520,
		        47523,
		        47525,
		        47516,
		        47557,
		        47558,
		        47559,
		        47548,
		        47546,
		        47550,
		        49098,
		        47551,
		        47554,
			}, {
				47557,
				47558,
				47559,
				47506,
				47526,
				47517,
				47519,
				47521,
				47524,
				47515,
				47557,
				47558,
				47559,
				47547,
				47545,
				47549,
				49096,
				47552,
				47553,
			}
		), 
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

-- Tablica zawierająca listę itemów LC
local lootTable = {
}

local selectedTab = ""
local bossTabRef = {}
local difficultyTabRef = {}
local selectedContent = contentOrder[1]
local selectedDifficulty = "10 raid"

function LCGroupLoot:PreloadItemLinks()
	for bossName, diff in pairs(bossy) do
		for _, items in pairs(diff) do
			for i, itemId in ipairs(items) do
					local itemIdNumber = tonumber(itemId)
					local _= GetItemInfo(itemIdNumber)
			end
		end	
	end
end

function LCGroupLoot:OnInitialize() 
	self.db = AceDB:New("LCGroupLootDB", defaults, true)

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

end

function LCGroupLoot:IsItemInLootTable(itemID)
    return self.db.profile.lootTable[itemID] == true
end

function LCGroupLoot:SetLootTableValue(itemID, value)
    db.profile.lootTable[itemID] = value
end

--todo: combine below functions
function LCGroupLoot:IsPlayerRaidLeaderOrML()
    local playerName = UnitName("player")
    local raidLeaderName

	if self.db.profile.lootTable.lc == playerName then
		return true
	end

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

function LCGroupLoot:IsPlayerML()
 local playerName = UnitName("player")
    local raidLeaderName

	if self.db.profile.lootTable.lc then 
		if self.db.profile.lootTable.lc == playerName then
			return true
		end
		return false
	end

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
		if LCGroupLoot:IsPlayerML() and self.db.profile.rwLcItems then
			SendChatMessage("LC ITEM: "..itemLink, "RW")
		end
		if LCGroupLoot:IsPlayerML() then
			print(itemLink .. " - need")
			--RollOnLoot(rollId, 1) -- "Need"
		else
			--RollOnLoot(rollId, 0) -- "Pass"
			print(itemLink .. " - pass")
		end
	else 
		--print(itemLink .. " - not in LC table")
	end
end

function LCGroupLoot:CreateItemRow(itemId)
	local itemIdNumber = tonumber(itemId)
	local itemName, itemLink, _, itemLevel, _, _, _, _, _, itemTexture = GetItemInfo(itemIdNumber)

	local itemGroup = AceGUI:Create("SimpleGroup")
	itemGroup:SetLayout("Flow")
	itemGroup:SetWidth(350)

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

	if LCGroupLoot:IsPlayerRaidLeaderOrML() then
		itemCheckbox:SetDisabled(false)
	else
		itemCheckbox:SetDisabled(true)
	end
	
	itemGroup:AddChild(itemIcon)
	itemGroup:AddChild(itemLabel)
	itemGroup:AddChild(itemCheckbox)

    return itemGroup
end

function rebuildLootListFrame(lootListFrame) 
	lootListFrame:ReleaseChildren()
	lootListFrame:SetTitle(selectedTab.. " ".. selectedDifficulty)
	local items = bossy[selectedTab][selectedDifficulty]
	local tabContent = AceGUI:Create("ScrollFrame")
	tabContent:SetLayout("List")
	tabContent:SetFullWidth(true)
	tabContent:SetPoint("TOP")
	for i, itemID in ipairs(items) do	
		local itemRow = LCGroupLoot:CreateItemRow(itemID)
		tabContent:AddChild(itemRow)
	end	
	lootListFrame:AddChild(tabContent)
end

function LCGroupLoot:CreateBossList(lootListFrame) 
	local tabList = AceGUI:Create("ScrollFrame")
	tabList:SetFullWidth(true)
	tabList:SetLayout("List")
	
	for it, bossName in pairs(content[selectedContent]) do
		local bossLabel = AceGUI:Create("InteractiveLabel")
		bossLabel:SetText(bossName)
		bossLabel:SetFontObject(GameFontHighlightSmall)
		bossLabel:SetColor(1,1,1)
		bossLabel:SetJustifyH("Left")
		bossLabel:SetWidth(150)
		bossLabel:SetCallback("OnClick", function(widget,event,group)
			selectedTab = bossName
			
			for i, tab in ipairs(bossTabRef) do 
				tab:SetColor(1,1,1)
			end
			widget:SetColor(0.67,0.83,0.45)
			rebuildLootListFrame(lootListFrame) 
		end)
		
		bossTabRef[#bossTabRef+1] = bossLabel
		tabList:AddChild(bossLabel)
	end
	
	return tabList
end

function LCGroupLoot:CreateDiffList(lootListFrame) 
	local tabList = AceGUI:Create("ScrollFrame")
	tabList:SetFullWidth(true)
	tabList:SetLayout("List")
	
	for _, difficulty in ipairs(contentDifficulty[selectedContent]) do
		local difficultyLabel = AceGUI:Create("InteractiveLabel")
		difficultyLabel:SetText(difficulty)
		difficultyLabel:SetFontObject(GameFontHighlightSmall)
		difficultyLabel:SetColor(1,1,1)
		difficultyLabel:SetJustifyH("Left")
		difficultyLabel:SetWidth(150)
		difficultyLabel:SetCallback("OnClick", function(widget,event,group)
			selectedDifficulty = difficulty
			
			for i, tab in ipairs(difficultyTabRef) do 
				tab:SetColor(1,1,1)
			end
			widget:SetColor(0.67,0.83,0.45)
			
			rebuildLootListFrame(lootListFrame) 
		end)
		
		difficultyTabRef[#difficultyTabRef+1] = difficultyLabel
		tabList:AddChild(difficultyLabel)
	end
	
	return tabList
end


function LCGroupLoot:SendLootTableUpdate()
    local message = "LCGroupLoot_UPDATE:" .. AceSerializer:Serialize(lootTable)
	AceComm:SendCommMessage("LCGroupLootComm", message, "RAID", nil, "NORMAL")
end

function LCGroupLoot:CreateLCGroupLootUI()
    UIConfig = AceGUI:Create("Frame")
    UIConfig:SetTitle("LC GroupLoot")
    UIConfig:SetLayout("Flow")
	UIConfig:SetWidth(620)
	UIConfig:SetHeight(500)
	UIConfig:EnableResize(false)

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
	end)
	
	local lootListFrame = AceGUI:Create("InlineGroup")
	lootListFrame:SetLayout("Flow")
	lootListFrame:SetWidth(400)	
	lootListFrame:SetFullHeight(true)
	lootListFrame:SetPoint("TOP")
	
	local bossListFrame = AceGUI:Create("InlineGroup", bodyContainer)
	bossListFrame:SetLayout("Fill")
	bossListFrame:SetWidth(160)	
	bossListFrame:SetFullHeight(true)
	--bossListFrame:SetHeight(300)
	bossListFrame:SetPoint("TOP")
	
	local difficultyListFrame = AceGUI:Create("InlineGroup", bottomContainer)
	difficultyListFrame:SetLayout("Fill")
	difficultyListFrame:SetWidth(160)	
	difficultyListFrame:SetFullHeight(true)
	--bossListFrame:SetHeight(300)
	difficultyListFrame:SetPoint("TOP")
	
	local raidDropdown = AceGUI:Create("Dropdown")
	raidDropdown:SetLabel("Content:")
	raidDropdown:SetMultiselect(false)
	raidDropdown:SetWidth(150)
	raidDropdown:SetFullWidth(false)
	raidDropdown:SetText(selectedContent)
	for i = 1, #contentOrder do
		raidDropdown:AddItem(contentOrder[i], contentOrder[i])
	end
	raidDropdown:SetCallback("OnValueChanged", function(widget, event, item)
		selectedContent = item
		bossTabRef = {}
		difficultyListFrame:ReleaseChildren()
		difficultyListFrame:AddChild(LCGroupLoot:CreateDiffList(lootListFrame))
		bossListFrame:ReleaseChildren()
		bossListFrame:AddChild(LCGroupLoot:CreateBossList(lootListFrame))		
	end)

	local masterLooterDropdown = AceGUI:Create("Dropdown")
	masterLooterDropdown:SetLabel("LC:")
	masterLooterDropdown:SetMultiselect(false)
	masterLooterDropdown:SetWidth(150)
	masterLooterDropdown:SetFullWidth(false)
	masterLooterDropdown:SetText(self.db.profile.lootTable.lc)
	if IsInRaid() then 
		for i = 1, MAX_RAID_MEMBERS do
			local name = GetRaidRosterInfo(i)
			if name then
				masterLooterDropdown:AddItem(name,name) 
			end
		end
	end
	masterLooterDropdown:SetCallback("OnValueChanged", function(widget,event,item)
		self.db.profile.lootTable.lc = item
	end)
	
	local rwCheckbox = AceGUI:Create("CheckBox")
	rwCheckbox:SetLabel("/RW LC items")
	rwCheckbox:SetValue(self.db.profile.rwLcItems)
	rwCheckbox:SetWidth(150)
	rwCheckbox:SetPoint("RIGHT", -10, 0)
	rwCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
		self.db.profile.rwLcItems = value
	end)

	if LCGroupLoot:IsPlayerRaidLeaderOrML() then
		rwCheckbox:SetDisabled(false)
	else
		rwCheckbox:SetDisabled(true)
	end

	if LCGroupLoot:IsPlayerRaidLeader() then
		sendUpdateButton:SetDisabled(false)
		saveSettingsButton:SetDisabled(false)
		masterLooterDropdown:SetDisabled(false)
	else
		sendUpdateButton:SetDisabled(true)
		saveSettingsButton:SetDisabled(true)
		masterLooterDropdown:SetDisabled(true)
	end
	
	UIConfig:AddChild(sendUpdateButton)
	UIConfig:AddChild(saveSettingsButton)
	UIConfig:AddChild(raidDropdown)
	
	local bodyContainer = AceGUI:Create("SimpleGroup")
	bodyContainer:SetLayout("Flow")
	bodyContainer:SetFullWidth(true)	
	bodyContainer:SetFullHeight(true)
	--bodyContainer:SetHeight(300)
	bodyContainer:SetPoint("TOP")

	local bottomContainer = AceGUI:Create("SimpleGroup")
	bottomContainer:SetLayout("Flow")
	bottomContainer:SetFullWidth(true)	
	bottomContainer:SetHeight(70)
	--bodyContainer:SetHeight(300)
	bottomContainer:SetPoint("TOP")


	local lcContainer = AceGUI:Create("InlineGroup")
	lcContainer:SetLayout("Flow")
	lcContainer:SetWidth(400)	
	lcContainer:SetFullHeight(true)
	lcContainer:SetPoint("TOP")
	
	lcContainer:AddChild(masterLooterDropdown)
	lcContainer:AddChild(rwCheckbox)
	
	difficultyListFrame:AddChild(LCGroupLoot:CreateDiffList(lootListFrame))
	bossListFrame:AddChild(LCGroupLoot:CreateBossList(lootListFrame))

	bodyContainer:AddChild(lootListFrame)
	bodyContainer:AddChild(bossListFrame)
	
	bottomContainer:AddChild(lcContainer)
	bottomContainer:AddChild(difficultyListFrame)
	
	UIConfig:AddChild(bottomContainer)
	UIConfig:AddChild(bodyContainer)

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
    if event == "CHAT_MSG_ADDON" and prefix == "LCGroupLoot" then
        HandleLootTableUpdate(sender, message)
    end

end

function LCGroupLoot:OnLCGroupLootCommReceived(prefix, message, distribution, sender)
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