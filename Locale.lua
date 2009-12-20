
local myname, ns = ...

local locale = GetLocale()
ns.rollpairs = locale == "deDE" and {
	["(.*) passt automatisch bei (.+), weil er den Gegenstand nicht benutzen kann.$"]  = "pass",
	["(.*) w\195\188rfelt nicht f\195\188r: (.+|r)$"] = "pass",
	["(.*) hat f\195\188r (.+) 'Gier' ausgew\195\164hlt"] = "greed",
	["(.*) hat f\195\188r (.+) 'Bedarf' ausgew\195\164hlt"] = "need",
} or locale == "frFR" and {
	["(.*) a pass\195\169 pour\194\160: (.+) parce qu'((il)|(elle)) ne peut pas ramasser cette objet.$"]  = "pass",
	["(.*) a pass\195\169 pour\194\160: (.+)"]  = "pass",
	["(.*) a choisi Cupidit\195\169 pour\194\160: (.+)"] = "greed",
	["(.*) a choisi Besoin pour\194\160: (.+)"]  = "need",
} or locale == "zhTW" and {
	["^(.*) \232\135\170\229\139\149\232\168\173\229\174\154\231\130\186\230\148\190\230\163\132: (.+) \229\155\160\231\130\186\228\187\150/\229\165\185\228\184\141\232\131\189\230\139\191\229\143\150\232\169\178\231\137\169\229\147\129.$"] = "pass",
	["^(.*) \230\148\190\230\163\132: (.+|r)$"]  = "pass",
	["(.*) \229\183\177\233\129\184\230\147\135\232\178\170\229\169\170: (.+)"] = "greed",
	["(.*) \229\183\177\233\129\184\230\147\135\233\156\128\230\177\130: (.+)"]  = "need",
} or {
	["^(.*) automatically passed on: (.+) because s?he cannot loot that item.$"] = "pass",
	["^(.*) passed on: (.+|r)$"]  = "pass",
	["(.*) has selected Greed for: (.+)"] = "greed",
	["(.*) has selected Need for: (.+)"]  = "need",
	["(.*) has selected Disenchant for: (.+)"]  = "disenchant",
}
