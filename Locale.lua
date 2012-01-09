
local myname, ns = ...

local locale = GetLocale()
ns.rollpairs = locale == "deDE" and {
	["(.*) passt automatisch bei (.+), weil [ersi]+ den Gegenstand nicht benutzen kann.$"]  = "pass",
	["(.*) würfelt nicht für: (.+|r)$"] = "pass",
	["(.*) hat für (.+) 'Gier' ausgewählt"] = "greed",
	["(.*) hat für (.+) 'Bedarf' ausgewählt"] = "need",
	["(.*) hat für '(.+)' Entzauberung gewählt."]  = "disenchant",
} or locale == "frFR" and {
	["(.*) a passé pour : (.+) parce qu'((il)|(elle)) ne peut pas ramasser cette objet.$"]  = "pass",
	["(.*) a passé pour : (.+)"]  = "pass",
	["(.*) a choisi Cupidité pour : (.+)"] = "greed",
	["(.*) a choisi Besoin pour : (.+)"]  = "need",
} or locale == "ruRU" and {
	["(.*) автоматически передает предмет (.+), поскольку не может его забрать"] = "pass",
	["(.*) пропускает розыгрыш предмета \"(.+)\", поскольку не может его забрать"] = "pass",
	["(.*) отказывается от предмета (.+)%."]  = "pass",
	["(.*): (.+)%. (.*): \"Не откажусь\""] = "greed",
	["(.*): (.+)%. (.*): \"Мне это нужно\""] = "need",
	["(.*): (.+)%. (.*): \"Распылить\""] = "disenchant",
} or locale == "zhCN" and {
	["(.*)自动放弃：(.+)，因为"]  = "pass",
	["(.*)放弃了：(.+)"] = "pass",
	["(.*)选择了贪婪取向：(.+)"] = "greed",
	["(.*)选择了需求取向：(.+)"] = "need",
	["(.*)选择了分解取向：(.+)"] = "disenchant",
} or locale == "zhTW" and {
	["(.*)自動放棄:(.+)，因為"]  = "pass",
	["(.*)放棄了:(.+)"] = "pass",
	["(.*)選擇了貪婪:(.+)"] = "greed",
	["(.*)選擇了需求:(.+)"] = "need",
	["(.*)選擇分解:(.+)"] = "disenchant",
} or locale == "koKR" and {
	["(.*)님이 획득할 수 없는 획득할 수 없는 아이템이어서 자동으로 주사위 굴리기를 포기했습니다. (.*)$"] = "pass",
	["(.*)님이 주사위 굴리기를 포기했습니다. (.*)$"]  = "pass",
	["(.+)님이 차비를 선택했습니다. (.*)$"] = "greed",
	["(.*)님이 입찰을 선택했습니다. (.*)$"]  = "need",
	["(.*)님이 마력 추출을 선택했습니다. (.*)$"]  = "disenchant",
} or {
	["^(.*) automatically passed on: (.+) because s?he cannot loot that item.$"] = "pass",
	["^(.*) passed on: (.+|r)$"]  = "pass",
	["(.*) has selected Greed for: (.+)"] = "greed",
	["(.*) has selected Need for: (.+)"]  = "need",
	["(.*) has selected Disenchant for: (.+)"]  = "disenchant",
}
