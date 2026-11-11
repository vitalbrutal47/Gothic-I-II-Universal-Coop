META
{
	Parser = Game;
	MergeMode = 1;
	Engine = G2A;
};

// GothicCoop - Fun-Modus für Gothic 2 Die Nacht des Raben (ab u203). Erzeugt von tools\funmodus\gen_fun.py - nicht von Hand ändern.
// Nutzer: "man soll im menü auswählen können welche gilde man direkt startet, story entfernen, alle npc entfernen aber in
// kapitel 1 starten, basis und einen händler (bei den jeweiligen gilden), ein kapitel aufsteigen indem man ein mob tötet
// der in der mitte nahe der taverne steht ... coop pvp ... mobs spawnen lassen um ep und geld zu farmen ... händler mit
// unendlich gold ... 5 weitere npc's in den jeweiligen lagern, die man zum kämpfen mitnehmen kann".
// Gewählt: Miliz (Kaserne), Söldner (Onars Hof), Novize (Kloster), Bandit (Turm bei der Burgmine); Gilde gegen Gilde;
// Kapitel 1 bis 6. Start: COOP > Fun-Modus. GothicCoop liefert COOP_FUNMODUS() (1 = dieses neue Spiel ist ein Fun-Spiel)
// und COOP_FUNGILDE() (0 Miliz, 1 Söldner, 2 Novize, 3 Bandit - Gothic.ini [GOTHICCOOP] coopFunGilde) und ruft alle 10 s
// FUN_TAKT_ALLE (jeder PC) und FUN_TAKT_HOST (Host bzw. ohne Coop). Variablen FUNL_* gleicht der Coop nie ab (je PC);
// FUN_AKTIV und FUN_KAPITEL gelten für alle. Ohne Fun-Spiel (FUN_AKTIV = 0) läuft alles wie im Original.

var int FUN_AKTIV;              // dieses Spiel ist ein Fun-Spiel
var int FUN_KAPITEL;            // 1-6, steigt mit dem Kapitelstein
var int FUNL_KAPITEL_GESEHEN;   // je PC: zuletzt angezeigtes Kapitel
var int FUNL_BOSS_T;            // je PC (Host): Takte seit dem Tod des Bosses
var int FUNL_BEGL_KAP;          // je PC (Host): Kapitel, für das die Begleiter zuletzt verstärkt wurden
const int FUN_RESPAWN_TAKTE = 9;
const int FUN_BOSS_TAKTE = 18;
const int FUN_BEGL_TAKTE = 30;
const int FUN_HAENDLER_GOLD = 100000;

func int Fun_KapitelNr()
{
	if (FUN_KAPITEL < 1)
	{
		return 1;
	};
	if (FUN_KAPITEL > 6)
	{
		return 6;
	};
	return FUN_KAPITEL;
};

func int Fun_GildeVonHaendler(var C_NPC slf)
{
	if (slf.id == 9601)
	{
		return GIL_MIL;
	};
	if (slf.id == 9602)
	{
		return GIL_SLD;
	};
	if (slf.id == 9603)
	{
		return GIL_NOV;
	};
	if (slf.id == 9604)
	{
		return GIL_BDT;
	};
	return GIL_NONE;
};

// u203d: Monster in einem Lager? (30 m um Start-, Haendler- und Begleiterpunkte)
func int Fun_NaheLager(var C_NPC m)
{
	if (Npc_GetDistToWP(m, "NW_CITY_HABOUR_KASERN_CENTRE_01") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_CITY_HABOUR_KASERN_CENTRE_03") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_CITY_HABOUR_KASERN_05_01") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_CITY_HABOUR_KASERN_08") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_CITY_HABOUR_KASERN_10") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_CITY_HABOUR_KASERN_12") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_CITY_HABOUR_KASERN_14") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_BIGFARM_HOUSE_OUT_05") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_BIGFARM_HOUSE_08") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_BIGFARM_HOUSE_12") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_BIGFARM_HOUSE_14") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_BIGFARM_ALLEE_04") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_BIGFARM_TREE") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_BIGFARM_KITCHEN_09") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_MONASTERY_PLACE_03") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_MONASTERY_PLACE_07") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_MONASTERY_PLACE_09") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_MONASTERY_GRASS_01") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_MONASTERY_HERB_05") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_MONASTERY_CHURCH_03") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_MONASTERY_CHAPELL_02") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_CASTLEMINE_TOWER_CAMPFIRE_01") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_CASTLEMINE_TOWER_CAMPFIRE_03") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_CASTLEMINE_TOWER_CAMPFIRE_02") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_CASTLEMINE_TOWER_CAMPFIRE_04") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_CASTLEMINE_TOWER_STAND_01") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_CASTLEMINE_TOWER_STAND_02") < 3000)
	{
		return TRUE;
	};
	if (Npc_GetDistToWP(m, "NW_CASTLEMINE_TOWER_REP_HUT") < 3000)
	{
		return TRUE;
	};
	return FALSE;
};

func int Fun_NpcLebt(var C_NPC n)
{
	if (!Hlp_IsValidNpc(n))
	{
		return FALSE;
	};
	if (Npc_IsDead(n))
	{
		return FALSE;
	};
	return TRUE;
};

// --- Kapitelstein: der Boss an der Taverne trägt ihn. Benutzen hebt das Kapitel für alle -----------------------------
instance ItMi_Fun_Kapitelstein (C_Item)
{
	name = "Kapitelstein";
	mainflag = ITEM_KAT_NONE;
	flags = ITEM_MISSION;
	value = 0;
	visual = "ItMi_StonePlate_PowerUp_03.3DS";
	material = MAT_STONE;
	scemename = "MAPSEALED";
	on_state[0] = Use_Fun_Kapitelstein;
	effect = "SPELLFX_WEAKGLIMMER";
	description = name;
	text[0] = "Benutzen: nächstes Kapitel für alle.";
	text[1] = "Die Händler bieten dann bessere Ware.";
};

// --- Monster: je Spawnpunkt eine Instanz pro Stärkestufe (Prototyp und Rumpf wie im Original, dazu Gold) ---------------
func void Fun_MobBeute(var int stufe)
{
	CreateInvItems(self, ItMi_Gold, 4 + stufe * 8);
};

instance FUN_M000_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M000_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M000_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M000_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M000_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M000_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M001_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M001_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M001_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M001_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M001_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M001_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M002_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M002_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M002_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M002_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M002_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M002_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M003_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M003_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M003_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M003_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M003_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M003_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M004_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M004_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M004_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M004_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M004_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M004_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M005_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M005_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M005_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M005_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M005_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M005_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M006_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M006_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M006_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M006_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M006_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M006_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M007_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M007_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M007_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M007_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M007_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M007_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M008_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M008_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M008_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M008_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M008_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M008_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M009_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M009_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M009_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M009_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M009_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M009_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M010_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M010_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M010_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M010_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M010_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M010_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M011_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M011_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M011_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M011_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M011_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M011_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M012_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M012_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M012_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M012_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M012_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M012_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M013_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M013_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M013_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M013_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M013_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M013_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M014_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M014_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M014_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M014_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M014_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M014_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M015_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M015_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M015_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M015_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M015_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M015_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M016_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M016_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M016_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M016_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M016_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M016_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M017_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M017_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M017_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M017_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M017_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M017_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M018_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M018_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M018_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M018_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M018_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M018_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M019_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M019_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M019_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M019_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M019_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M019_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M020_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M020_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M020_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M020_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M020_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M020_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M021_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M021_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M021_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M021_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M021_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M021_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M022_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M022_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M022_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M022_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M022_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M022_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M023_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M023_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M023_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M023_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M023_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M023_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M024_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M024_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M024_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M024_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M024_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M024_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M025_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M025_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M025_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M025_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M025_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M025_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M026_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M026_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M026_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M026_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M026_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M026_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M027_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M027_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M027_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M027_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M027_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M027_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M028_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M028_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M028_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M028_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M028_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M028_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M029_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M029_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M029_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M029_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M029_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M029_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M030_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M030_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M030_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M030_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M030_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M030_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M031_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M031_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M031_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M031_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M031_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M031_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M032_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M032_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M032_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M032_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M032_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M032_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M033_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M033_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M033_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M033_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M033_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M033_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M034_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M034_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M034_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M034_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M034_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M034_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M035_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M035_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M035_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M035_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M035_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M035_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M036_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M036_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M036_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M036_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M036_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M036_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M037_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M037_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M037_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M037_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M037_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M037_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M038_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M038_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M038_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M038_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M038_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M038_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M039_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M039_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M039_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M039_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M039_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M039_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M040_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M040_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M040_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M040_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M040_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M040_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M041_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M041_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M041_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M041_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M041_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M041_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M042_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M042_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M042_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M042_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M042_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M042_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M043_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M043_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M043_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M043_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M043_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M043_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M044_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M044_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M044_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M044_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M044_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M044_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M045_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M045_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M045_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M045_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M045_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M045_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M046_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M046_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M046_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M046_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M046_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M046_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M047_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M047_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M047_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M047_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M047_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M047_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M048_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M048_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M048_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M048_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M048_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M048_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M049_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M049_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M049_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M049_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M049_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M049_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M050_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M050_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M050_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M050_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M050_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M050_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M051_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M051_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M051_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M051_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M051_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M051_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M052_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M052_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M052_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M052_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M052_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M052_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M053_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M053_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M053_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M053_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M053_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M053_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M054_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M054_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M054_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M054_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M054_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M054_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M055_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M055_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M055_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M055_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M055_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M055_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M056_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M056_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M056_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M056_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M056_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M056_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M057_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M057_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M057_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M057_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M057_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M057_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M058_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M058_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M058_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M058_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M058_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M058_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M059_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M059_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M059_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M059_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M059_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M059_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M060_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M060_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M060_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M060_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M060_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M060_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M061_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M061_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M061_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M061_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M061_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M061_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M062_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M062_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M062_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M062_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M062_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M062_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M063_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M063_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M063_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M063_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M063_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M063_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M064_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M064_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M064_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M064_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M064_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M064_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M065_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M065_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M065_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M065_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M065_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M065_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M066_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M066_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M066_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M066_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M066_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M066_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M067_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M067_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M067_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M067_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M067_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M067_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M068_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M068_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M068_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M068_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M068_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M068_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M069_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M069_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M069_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M069_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M069_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M069_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M070_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M070_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M070_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M070_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M070_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M070_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M071_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M071_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M071_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M071_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M071_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M071_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M072_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M072_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M072_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M072_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M072_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M072_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M073_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M073_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M073_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M073_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M073_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M073_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M074_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M074_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M074_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M074_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M074_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M074_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M075_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M075_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M075_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M075_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M075_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M075_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M076_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M076_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M076_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M076_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M076_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M076_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M077_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M077_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M077_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M077_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M077_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M077_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M078_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M078_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M078_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M078_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M078_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M078_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M079_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M079_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M079_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M079_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M079_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M079_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M080_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M080_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M080_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M080_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M080_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M080_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M081_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M081_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M081_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M081_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M081_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M081_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M082_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M082_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M082_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M082_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M082_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M082_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M083_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M083_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M083_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M083_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M083_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M083_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M084_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M084_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M084_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M084_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M084_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M084_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M085_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M085_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M085_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M085_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M085_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M085_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M086_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M086_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M086_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M086_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M086_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M086_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M087_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M087_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M087_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M087_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M087_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M087_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M088_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M088_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M088_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M088_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M088_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M088_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M089_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M089_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M089_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M089_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M089_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M089_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M090_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M090_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M090_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M090_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M090_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M090_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M091_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M091_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M091_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M091_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M091_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M091_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M092_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M092_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M092_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M092_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M092_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M092_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M093_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M093_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M093_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M093_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M093_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M093_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M094_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M094_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M094_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M094_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M094_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M094_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M095_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M095_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M095_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M095_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M095_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M095_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M096_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M096_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M096_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M096_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M096_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M096_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M097_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M097_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M097_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M097_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M097_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M097_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M098_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M098_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M098_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M098_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M098_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M098_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M099_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M099_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M099_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M099_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M099_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M099_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M100_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M100_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M100_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M100_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M100_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M100_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M101_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M101_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M101_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M101_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M101_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M101_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M102_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M102_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M102_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M102_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M102_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M102_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M103_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M103_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M103_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M103_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M103_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M103_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M104_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M104_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M104_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M104_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M104_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M104_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M105_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M105_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M105_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M105_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M105_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M105_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M106_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M106_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M106_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M106_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M106_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M106_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M107_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M107_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M107_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M107_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M107_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M107_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M108_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M108_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M108_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M108_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M108_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M108_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M109_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M109_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M109_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M109_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M109_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M109_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M110_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M110_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M110_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M110_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M110_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M110_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M111_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M111_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M111_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M111_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M111_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M111_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M112_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M112_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M112_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M112_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M112_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M112_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M113_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M113_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M113_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M113_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M113_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M113_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M114_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M114_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M114_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M114_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M114_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M114_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M115_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M115_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M115_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M115_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M115_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M115_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M116_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M116_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M116_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M116_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M116_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M116_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M117_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M117_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M117_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M117_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M117_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M117_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M118_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M118_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M118_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M118_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M118_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M118_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M119_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M119_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M119_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M119_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M119_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M119_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M120_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M120_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M120_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M120_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M120_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M120_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M121_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M121_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M121_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M121_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M121_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M121_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M122_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M122_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M122_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M122_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M122_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M122_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M123_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M123_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M123_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M123_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M123_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M123_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M124_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M124_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M124_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M124_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M124_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M124_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M125_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M125_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M125_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M125_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M125_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M125_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M126_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M126_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M126_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M126_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M126_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M126_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M127_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M127_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M127_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M127_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M127_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M127_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M128_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M128_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M128_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M128_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M128_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M128_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M129_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M129_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M129_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M129_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M129_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M129_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M130_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M130_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M130_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M130_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M130_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M130_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M131_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M131_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M131_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M131_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M131_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M131_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M132_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M132_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M132_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M132_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M132_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M132_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M133_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M133_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M133_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M133_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M133_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M133_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M134_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M134_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M134_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M134_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M134_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M134_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M135_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M135_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M135_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M135_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M135_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M135_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M136_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M136_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M136_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M136_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M136_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M136_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M137_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M137_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M137_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M137_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M137_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M137_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M138_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M138_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M138_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M138_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M138_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M138_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M139_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M139_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M139_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M139_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M139_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M139_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M140_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M140_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M140_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M140_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M140_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M140_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M141_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M141_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M141_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M141_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M141_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M141_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M142_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M142_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M142_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M142_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M142_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M142_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M143_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M143_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M143_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M143_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M143_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M143_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M144_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M144_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M144_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M144_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M144_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M144_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M145_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M145_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M145_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M145_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M145_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M145_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M146_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M146_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M146_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M146_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M146_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M146_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M147_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M147_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M147_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M147_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M147_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M147_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M148_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M148_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M148_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M148_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M148_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M148_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M149_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M149_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M149_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M149_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M149_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M149_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M150_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M150_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M150_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M150_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M150_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M150_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M151_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M151_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M151_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M151_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M151_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M151_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M152_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M152_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M152_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M152_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M152_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M152_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M153_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M153_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M153_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M153_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M153_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M153_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M154_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M154_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M154_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M154_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M154_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M154_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M155_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M155_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M155_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M155_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M155_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M155_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M156_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M156_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M156_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M156_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M156_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M156_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M157_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M157_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M157_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M157_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M157_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M157_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M158_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M158_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M158_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M158_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M158_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M158_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M159_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M159_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M159_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M159_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M159_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M159_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M160_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M160_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M160_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M160_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M160_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M160_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M161_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M161_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M161_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M161_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M161_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M161_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M162_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M162_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M162_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M162_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M162_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M162_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M163_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M163_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M163_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M163_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M163_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M163_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M164_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M164_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M164_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M164_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M164_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M164_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M165_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M165_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M165_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M165_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M165_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M165_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M166_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M166_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M166_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M166_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M166_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M166_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M167_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M167_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M167_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M167_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M167_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M167_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M168_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M168_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M168_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M168_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M168_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M168_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M169_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M169_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M169_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M169_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M169_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M169_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M170_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M170_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M170_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M170_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M170_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M170_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M171_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M171_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M171_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M171_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M171_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M171_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M172_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M172_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M172_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M172_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M172_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M172_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M173_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M173_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M173_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M173_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M173_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M173_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M174_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M174_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M174_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M174_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M174_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M174_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M175_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M175_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M175_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M175_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M175_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M175_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M176_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M176_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M176_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M176_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M176_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M176_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M177_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M177_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M177_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M177_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M177_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M177_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M178_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M178_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M178_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M178_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M178_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M178_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M179_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M179_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M179_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M179_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M179_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M179_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M180_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M180_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M180_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M180_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M180_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M180_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M181_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M181_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M181_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M181_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M181_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M181_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M182_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M182_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M182_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M182_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M182_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M182_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M183_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M183_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M183_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M183_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M183_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M183_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M184_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M184_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M184_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M184_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M184_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M184_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M185_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M185_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M185_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M185_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M185_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M185_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M186_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M186_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M186_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M186_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M186_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M186_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M187_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M187_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M187_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M187_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M187_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M187_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M188_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M188_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M188_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M188_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M188_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M188_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M189_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M189_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M189_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M189_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M189_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M189_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M190_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M190_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M190_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M190_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M190_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M190_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M191_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M191_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M191_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M191_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M191_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M191_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M192_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M192_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M192_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M192_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M192_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M192_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M193_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M193_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M193_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M193_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M193_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M193_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M194_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M194_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M194_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M194_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M194_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M194_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M195_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M195_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M195_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M195_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M195_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M195_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M196_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M196_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M196_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M196_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M196_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M196_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M197_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M197_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M197_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M197_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M197_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M197_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M198_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M198_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M198_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M198_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M198_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M198_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M199_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M199_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M199_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M199_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M199_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M199_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M200_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M200_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M200_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M200_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M200_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M200_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M201_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M201_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M201_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M201_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M201_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M201_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M202_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M202_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M202_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M202_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M202_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M202_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M203_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M203_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M203_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M203_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M203_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M203_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M204_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M204_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M204_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M204_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M204_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M204_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M205_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M205_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M205_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M205_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M205_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M205_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M206_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M206_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M206_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M206_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M206_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M206_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M207_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M207_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M207_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M207_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M207_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M207_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M208_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M208_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M208_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M208_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M208_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M208_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M209_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M209_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M209_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M209_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M209_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M209_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};

// --- Bosse an der Taverne ("Zur toten Harpie"), einer je Kapitel ------------------------------------------------
instance FUN_BOSS_K1 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	name = "Goblin-Häuptling";
	attribute[ATR_HITPOINTS_MAX] = attribute[ATR_HITPOINTS_MAX] * 40 / 10;
	attribute[ATR_HITPOINTS] = attribute[ATR_HITPOINTS_MAX];
	attribute[ATR_STRENGTH] = attribute[ATR_STRENGTH] * 6 / 10;
	Mdl_SetModelScale(self, 1.3, 1.3, 1.3);
	CreateInvItems(self, ItMi_Gold, 250);
	CreateInvItems(self, ItMi_Fun_Kapitelstein, 1);
};
instance FUN_BOSS_K2 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	name = "Reißzahn der Taverne";
	attribute[ATR_HITPOINTS_MAX] = attribute[ATR_HITPOINTS_MAX] * 40 / 10;
	attribute[ATR_HITPOINTS] = attribute[ATR_HITPOINTS_MAX];
	attribute[ATR_STRENGTH] = attribute[ATR_STRENGTH] * 6 / 10;
	Mdl_SetModelScale(self, 1.25, 1.25, 1.25);
	CreateInvItems(self, ItMi_Gold, 500);
	CreateInvItems(self, ItMi_Fun_Kapitelstein, 1);
};
instance FUN_BOSS_K3 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	name = "Bluthund der Taverne";
	attribute[ATR_HITPOINTS_MAX] = attribute[ATR_HITPOINTS_MAX] * 40 / 10;
	attribute[ATR_HITPOINTS] = attribute[ATR_HITPOINTS_MAX];
	attribute[ATR_STRENGTH] = attribute[ATR_STRENGTH] * 6 / 10;
	Mdl_SetModelScale(self, 1.25, 1.25, 1.25);
	CreateInvItems(self, ItMi_Gold, 750);
	CreateInvItems(self, ItMi_Fun_Kapitelstein, 1);
};
instance FUN_BOSS_K4 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	name = "Schattenfürst";
	attribute[ATR_HITPOINTS_MAX] = attribute[ATR_HITPOINTS_MAX] * 35 / 10;
	attribute[ATR_HITPOINTS] = attribute[ATR_HITPOINTS_MAX];
	attribute[ATR_STRENGTH] = attribute[ATR_STRENGTH] * 5 / 10;
	Mdl_SetModelScale(self, 1.2, 1.2, 1.2);
	CreateInvItems(self, ItMi_Gold, 1000);
	CreateInvItems(self, ItMi_Fun_Kapitelstein, 1);
};
instance FUN_BOSS_K5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	name = "Feuerechse";
	attribute[ATR_HITPOINTS_MAX] = attribute[ATR_HITPOINTS_MAX] * 35 / 10;
	attribute[ATR_HITPOINTS] = attribute[ATR_HITPOINTS_MAX];
	attribute[ATR_STRENGTH] = attribute[ATR_STRENGTH] * 5 / 10;
	Mdl_SetModelScale(self, 1.2, 1.2, 1.2);
	CreateInvItems(self, ItMi_Gold, 1250);
	CreateInvItems(self, ItMi_Fun_Kapitelstein, 1);
};
instance FUN_BOSS_K6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	name = "Bergtroll";
	attribute[ATR_HITPOINTS_MAX] = attribute[ATR_HITPOINTS_MAX] * 30 / 10;
	attribute[ATR_HITPOINTS] = attribute[ATR_HITPOINTS_MAX];
	attribute[ATR_STRENGTH] = attribute[ATR_STRENGTH] * 4 / 10;
	Mdl_SetModelScale(self, 1.1, 1.1, 1.1);
	CreateInvItems(self, ItMi_Gold, 1500);
	CreateInvItems(self, ItMi_Gold, 5000);
};

// --- Händler (unsterblich, unendlich Gold, Ware nach Kapitel) und je Lager 5 Begleiter ---------------------------------
instance FUN_HAENDLER_MIL (Npc_Default)
{
	name = "Quartiermeister Albrecht";
	guild = GIL_NONE;
	id = 9601;
	voice = 9;
	flags = NPC_FLAG_IMMORTAL;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Mil_Sword);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Bald", Face_N_NormalBart10, BodyTex_N, ITAR_MIL_M);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Arrogance.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9601;
};
func void Rtn_Start_9601()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_CITY_HABOUR_KASERN_CENTRE_03");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_CITY_HABOUR_KASERN_CENTRE_03");
};
instance FUN_MIL_1 (Npc_Default)
{
	name = "Konrad";
	guild = GIL_MIL;
	id = 9610;
	voice = 6;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Mil_Sword);
	EquipItem(self, ItRw_Mil_Crossbow);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Fighter", Face_N_Normal02, BodyTex_N, ITAR_MIL_L);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Militia.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9610;
};
func void Rtn_Start_9610()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_CITY_HABOUR_KASERN_05_01");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_CITY_HABOUR_KASERN_05_01");
};
func void Rtn_Follow_9610()
{
	TA_Follow_Player(08,00,20,00,"NW_CITY_HABOUR_KASERN_05_01");
	TA_Follow_Player(20,00,08,00,"NW_CITY_HABOUR_KASERN_05_01");
};
instance FUN_MIL_2 (Npc_Default)
{
	name = "Walther";
	guild = GIL_MIL;
	id = 9611;
	voice = 7;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Mil_Sword);
	EquipItem(self, ItRw_Mil_Crossbow);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Bald", Face_N_Normal03, BodyTex_N, ITAR_MIL_L);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Militia.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9611;
};
func void Rtn_Start_9611()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_CITY_HABOUR_KASERN_08");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_CITY_HABOUR_KASERN_08");
};
func void Rtn_Follow_9611()
{
	TA_Follow_Player(08,00,20,00,"NW_CITY_HABOUR_KASERN_08");
	TA_Follow_Player(20,00,08,00,"NW_CITY_HABOUR_KASERN_08");
};
instance FUN_MIL_3 (Npc_Default)
{
	name = "Ulrich";
	guild = GIL_MIL;
	id = 9612;
	voice = 8;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Mil_Sword);
	EquipItem(self, ItRw_Mil_Crossbow);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Pony", Face_N_NormalBart04, BodyTex_N, ITAR_MIL_L);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Militia.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9612;
};
func void Rtn_Start_9612()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_CITY_HABOUR_KASERN_10");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_CITY_HABOUR_KASERN_10");
};
func void Rtn_Follow_9612()
{
	TA_Follow_Player(08,00,20,00,"NW_CITY_HABOUR_KASERN_10");
	TA_Follow_Player(20,00,08,00,"NW_CITY_HABOUR_KASERN_10");
};
instance FUN_MIL_4 (Npc_Default)
{
	name = "Bertram";
	guild = GIL_MIL;
	id = 9613;
	voice = 9;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Mil_Sword);
	EquipItem(self, ItRw_Mil_Crossbow);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Thief", Face_N_Normal08, BodyTex_N, ITAR_MIL_L);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Militia.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9613;
};
func void Rtn_Start_9613()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_CITY_HABOUR_KASERN_12");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_CITY_HABOUR_KASERN_12");
};
func void Rtn_Follow_9613()
{
	TA_Follow_Player(08,00,20,00,"NW_CITY_HABOUR_KASERN_12");
	TA_Follow_Player(20,00,08,00,"NW_CITY_HABOUR_KASERN_12");
};
instance FUN_MIL_5 (Npc_Default)
{
	name = "Egon";
	guild = GIL_MIL;
	id = 9614;
	voice = 10;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Mil_Sword);
	EquipItem(self, ItRw_Mil_Crossbow);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_FatBald", Face_N_NormalBart10, BodyTex_N, ITAR_MIL_L);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Militia.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9614;
};
func void Rtn_Start_9614()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_CITY_HABOUR_KASERN_14");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_CITY_HABOUR_KASERN_14");
};
func void Rtn_Follow_9614()
{
	TA_Follow_Player(08,00,20,00,"NW_CITY_HABOUR_KASERN_14");
	TA_Follow_Player(20,00,08,00,"NW_CITY_HABOUR_KASERN_14");
};
instance FUN_HAENDLER_SLD (Npc_Default)
{
	name = "Waffenhändler Brok";
	guild = GIL_NONE;
	id = 9602;
	voice = 9;
	flags = NPC_FLAG_IMMORTAL;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_2h_Sld_Sword);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Bald", Face_N_NormalBart10, BodyTex_N, ITAR_SLD_H);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Arrogance.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9602;
};
func void Rtn_Start_9602()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_BIGFARM_HOUSE_08");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_BIGFARM_HOUSE_08");
};
instance FUN_SLD_1 (Npc_Default)
{
	name = "Grimm";
	guild = GIL_SLD;
	id = 9620;
	voice = 11;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_2h_Sld_Sword);
	EquipItem(self, ItRw_Sld_Bow);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Fighter", Face_N_Normal08, BodyTex_N, ITAR_SLD_M);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Relaxed.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9620;
};
func void Rtn_Start_9620()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_BIGFARM_HOUSE_12");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_BIGFARM_HOUSE_12");
};
func void Rtn_Follow_9620()
{
	TA_Follow_Player(08,00,20,00,"NW_BIGFARM_HOUSE_12");
	TA_Follow_Player(20,00,08,00,"NW_BIGFARM_HOUSE_12");
};
instance FUN_SLD_2 (Npc_Default)
{
	name = "Kurgan";
	guild = GIL_SLD;
	id = 9621;
	voice = 12;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_2h_Sld_Sword);
	EquipItem(self, ItRw_Sld_Bow);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Bald", Face_N_NormalBart10, BodyTex_N, ITAR_SLD_M);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Relaxed.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9621;
};
func void Rtn_Start_9621()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_BIGFARM_HOUSE_14");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_BIGFARM_HOUSE_14");
};
func void Rtn_Follow_9621()
{
	TA_Follow_Player(08,00,20,00,"NW_BIGFARM_HOUSE_14");
	TA_Follow_Player(20,00,08,00,"NW_BIGFARM_HOUSE_14");
};
instance FUN_SLD_3 (Npc_Default)
{
	name = "Ronar";
	guild = GIL_SLD;
	id = 9622;
	voice = 13;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_2h_Sld_Sword);
	EquipItem(self, ItRw_Sld_Bow);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Pony", Face_B_Normal01, BodyTex_N, ITAR_SLD_M);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Relaxed.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9622;
};
func void Rtn_Start_9622()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_BIGFARM_ALLEE_04");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_BIGFARM_ALLEE_04");
};
func void Rtn_Follow_9622()
{
	TA_Follow_Player(08,00,20,00,"NW_BIGFARM_ALLEE_04");
	TA_Follow_Player(20,00,08,00,"NW_BIGFARM_ALLEE_04");
};
instance FUN_SLD_4 (Npc_Default)
{
	name = "Drago";
	guild = GIL_SLD;
	id = 9623;
	voice = 6;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_2h_Sld_Sword);
	EquipItem(self, ItRw_Sld_Bow);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Thief", Face_L_Tough02, BodyTex_N, ITAR_SLD_M);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Relaxed.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9623;
};
func void Rtn_Start_9623()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_BIGFARM_TREE");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_BIGFARM_TREE");
};
func void Rtn_Follow_9623()
{
	TA_Follow_Player(08,00,20,00,"NW_BIGFARM_TREE");
	TA_Follow_Player(20,00,08,00,"NW_BIGFARM_TREE");
};
instance FUN_SLD_5 (Npc_Default)
{
	name = "Tjark";
	guild = GIL_SLD;
	id = 9624;
	voice = 7;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_2h_Sld_Sword);
	EquipItem(self, ItRw_Sld_Bow);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_FatBald", Face_P_Normal01, BodyTex_N, ITAR_SLD_M);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Relaxed.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9624;
};
func void Rtn_Start_9624()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_BIGFARM_KITCHEN_09");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_BIGFARM_KITCHEN_09");
};
func void Rtn_Follow_9624()
{
	TA_Follow_Player(08,00,20,00,"NW_BIGFARM_KITCHEN_09");
	TA_Follow_Player(20,00,08,00,"NW_BIGFARM_KITCHEN_09");
};
instance FUN_HAENDLER_NOV (Npc_Default)
{
	name = "Bruder Kellermeister";
	guild = GIL_NONE;
	id = 9603;
	voice = 9;
	flags = NPC_FLAG_IMMORTAL;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Nov_Mace);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Bald", Face_N_NormalBart10, BodyTex_N, ITAR_KDF_L);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Arrogance.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9603;
};
func void Rtn_Start_9603()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_MONASTERY_PLACE_07");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_MONASTERY_PLACE_07");
};
instance FUN_NOV_1 (Npc_Default)
{
	name = "Bruder Anselm";
	guild = GIL_NOV;
	id = 9630;
	voice = 8;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Nov_Mace);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Fighter", Face_L_Tough02, BodyTex_N, ITAR_NOV_L);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Mage.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9630;
};
func void Rtn_Start_9630()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_MONASTERY_PLACE_09");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_MONASTERY_PLACE_09");
};
func void Rtn_Follow_9630()
{
	TA_Follow_Player(08,00,20,00,"NW_MONASTERY_PLACE_09");
	TA_Follow_Player(20,00,08,00,"NW_MONASTERY_PLACE_09");
};
instance FUN_NOV_2 (Npc_Default)
{
	name = "Bruder Elias";
	guild = GIL_NOV;
	id = 9631;
	voice = 9;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Nov_Mace);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Bald", Face_P_Normal01, BodyTex_N, ITAR_NOV_L);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Mage.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9631;
};
func void Rtn_Start_9631()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_MONASTERY_GRASS_01");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_MONASTERY_GRASS_01");
};
func void Rtn_Follow_9631()
{
	TA_Follow_Player(08,00,20,00,"NW_MONASTERY_GRASS_01");
	TA_Follow_Player(20,00,08,00,"NW_MONASTERY_GRASS_01");
};
instance FUN_NOV_3 (Npc_Default)
{
	name = "Bruder Matthis";
	guild = GIL_NOV;
	id = 9632;
	voice = 10;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Nov_Mace);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Pony", Face_N_Normal14, BodyTex_N, ITAR_NOV_L);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Mage.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9632;
};
func void Rtn_Start_9632()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_MONASTERY_HERB_05");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_MONASTERY_HERB_05");
};
func void Rtn_Follow_9632()
{
	TA_Follow_Player(08,00,20,00,"NW_MONASTERY_HERB_05");
	TA_Follow_Player(20,00,08,00,"NW_MONASTERY_HERB_05");
};
instance FUN_NOV_4 (Npc_Default)
{
	name = "Bruder Simon";
	guild = GIL_NOV;
	id = 9633;
	voice = 11;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Nov_Mace);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Thief", Face_N_Normal16, BodyTex_N, ITAR_NOV_L);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Mage.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9633;
};
func void Rtn_Start_9633()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_MONASTERY_CHURCH_03");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_MONASTERY_CHURCH_03");
};
func void Rtn_Follow_9633()
{
	TA_Follow_Player(08,00,20,00,"NW_MONASTERY_CHURCH_03");
	TA_Follow_Player(20,00,08,00,"NW_MONASTERY_CHURCH_03");
};
instance FUN_NOV_5 (Npc_Default)
{
	name = "Bruder Tobias";
	guild = GIL_NOV;
	id = 9634;
	voice = 12;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Nov_Mace);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_FatBald", Face_N_Normal02, BodyTex_N, ITAR_NOV_L);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Mage.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9634;
};
func void Rtn_Start_9634()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_MONASTERY_CHAPELL_02");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_MONASTERY_CHAPELL_02");
};
func void Rtn_Follow_9634()
{
	TA_Follow_Player(08,00,20,00,"NW_MONASTERY_CHAPELL_02");
	TA_Follow_Player(20,00,08,00,"NW_MONASTERY_CHAPELL_02");
};
instance FUN_HAENDLER_BDT (Npc_Default)
{
	name = "Hehler Fingerlos";
	guild = GIL_NONE;
	id = 9604;
	voice = 9;
	flags = NPC_FLAG_IMMORTAL;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Sld_Sword);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Bald", Face_N_NormalBart10, BodyTex_N, ITAR_BDT_H);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Arrogance.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9604;
};
func void Rtn_Start_9604()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_CASTLEMINE_TOWER_CAMPFIRE_03");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_CASTLEMINE_TOWER_CAMPFIRE_03");
};
instance FUN_BDT_1 (Npc_Default)
{
	name = "Rattenzahn";
	guild = GIL_BDT;
	id = 9640;
	voice = 13;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Sld_Sword);
	EquipItem(self, ItRw_Sld_Bow);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Fighter", Face_N_Normal16, BodyTex_N, ITAR_BDT_M);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Arrogance.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9640;
};
func void Rtn_Start_9640()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_CASTLEMINE_TOWER_CAMPFIRE_02");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_CASTLEMINE_TOWER_CAMPFIRE_02");
};
func void Rtn_Follow_9640()
{
	TA_Follow_Player(08,00,20,00,"NW_CASTLEMINE_TOWER_CAMPFIRE_02");
	TA_Follow_Player(20,00,08,00,"NW_CASTLEMINE_TOWER_CAMPFIRE_02");
};
instance FUN_BDT_2 (Npc_Default)
{
	name = "Krummbein";
	guild = GIL_BDT;
	id = 9641;
	voice = 6;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Sld_Sword);
	EquipItem(self, ItRw_Sld_Bow);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Bald", Face_N_Normal02, BodyTex_N, ITAR_BDT_M);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Arrogance.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9641;
};
func void Rtn_Start_9641()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_CASTLEMINE_TOWER_CAMPFIRE_04");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_CASTLEMINE_TOWER_CAMPFIRE_04");
};
func void Rtn_Follow_9641()
{
	TA_Follow_Player(08,00,20,00,"NW_CASTLEMINE_TOWER_CAMPFIRE_04");
	TA_Follow_Player(20,00,08,00,"NW_CASTLEMINE_TOWER_CAMPFIRE_04");
};
instance FUN_BDT_3 (Npc_Default)
{
	name = "Narbe";
	guild = GIL_BDT;
	id = 9642;
	voice = 7;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Sld_Sword);
	EquipItem(self, ItRw_Sld_Bow);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Pony", Face_N_Normal03, BodyTex_N, ITAR_BDT_M);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Arrogance.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9642;
};
func void Rtn_Start_9642()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_CASTLEMINE_TOWER_STAND_01");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_CASTLEMINE_TOWER_STAND_01");
};
func void Rtn_Follow_9642()
{
	TA_Follow_Player(08,00,20,00,"NW_CASTLEMINE_TOWER_STAND_01");
	TA_Follow_Player(20,00,08,00,"NW_CASTLEMINE_TOWER_STAND_01");
};
instance FUN_BDT_4 (Npc_Default)
{
	name = "Schakal";
	guild = GIL_BDT;
	id = 9643;
	voice = 8;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Sld_Sword);
	EquipItem(self, ItRw_Sld_Bow);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_Thief", Face_N_NormalBart04, BodyTex_N, ITAR_BDT_M);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Arrogance.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9643;
};
func void Rtn_Start_9643()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_CASTLEMINE_TOWER_STAND_02");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_CASTLEMINE_TOWER_STAND_02");
};
func void Rtn_Follow_9643()
{
	TA_Follow_Player(08,00,20,00,"NW_CASTLEMINE_TOWER_STAND_02");
	TA_Follow_Player(20,00,08,00,"NW_CASTLEMINE_TOWER_STAND_02");
};
instance FUN_BDT_5 (Npc_Default)
{
	name = "Knochen";
	guild = GIL_BDT;
	id = 9644;
	voice = 9;
	flags = 0;
	npctype = NPCTYPE_MAIN;
	B_SetAttributesToChapter(self, Fun_KapitelNr());
	fight_tactic = FAI_HUMAN_STRONG;
	EquipItem(self, ItMw_1h_Sld_Sword);
	EquipItem(self, ItRw_Sld_Bow);
	B_CreateAmbientInv(self);
	B_SetNpcVisual(self, MALE, "Hum_Head_FatBald", Face_N_Normal08, BodyTex_N, ITAR_BDT_M);
	Mdl_SetModelFatness(self, 1);
	Mdl_ApplyOverlayMds(self, "Humans_Arrogance.mds");
	B_GiveNpcTalents(self);
	B_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());
	daily_routine = Rtn_Start_9644;
};
func void Rtn_Start_9644()
{
	TA_Stand_ArmsCrossed(08,00,20,00,"NW_CASTLEMINE_TOWER_REP_HUT");
	TA_Stand_ArmsCrossed(20,00,08,00,"NW_CASTLEMINE_TOWER_REP_HUT");
};
func void Rtn_Follow_9644()
{
	TA_Follow_Player(08,00,20,00,"NW_CASTLEMINE_TOWER_REP_HUT");
	TA_Follow_Player(20,00,08,00,"NW_CASTLEMINE_TOWER_REP_HUT");
};

// Haltung der Begleiter und Händler zum eigenen Helden (je PC; der Coop gleicht sie für FUN_-NPCs nicht ab)
func void Fun_Haltung(var C_NPC n, var int gil)
{
	var int soll;
	if (!Hlp_IsValidNpc(n))
	{
		return;
	};
	if (gil == GIL_NONE)
	{
		soll = ATT_NEUTRAL;
		if (Fun_GildeVonHaendler(n) == Npc_GetTrueGuild(hero))
		{
			soll = ATT_FRIENDLY;
		};
	}
	else if (gil == Npc_GetTrueGuild(hero))
	{
		soll = ATT_FRIENDLY;
	}
	else
	{
		soll = ATT_HOSTILE;
	};
	if (Npc_GetAttitude(n, hero) != soll)
	{
		B_SetAttitude(n, soll);
	};
};
func void Fun_Haltungen()
{
	var C_NPC n;
	if (Npc_GetTrueGuild(hero) == GIL_NONE)
	{
		return;
	};
	n = Hlp_GetNpc(FUN_HAENDLER_MIL);
	Fun_Haltung(n, GIL_NONE);
	n = Hlp_GetNpc(FUN_HAENDLER_SLD);
	Fun_Haltung(n, GIL_NONE);
	n = Hlp_GetNpc(FUN_HAENDLER_NOV);
	Fun_Haltung(n, GIL_NONE);
	n = Hlp_GetNpc(FUN_HAENDLER_BDT);
	Fun_Haltung(n, GIL_NONE);
	n = Hlp_GetNpc(FUN_MIL_1);
	Fun_Haltung(n, GIL_MIL);
	n = Hlp_GetNpc(FUN_MIL_2);
	Fun_Haltung(n, GIL_MIL);
	n = Hlp_GetNpc(FUN_MIL_3);
	Fun_Haltung(n, GIL_MIL);
	n = Hlp_GetNpc(FUN_MIL_4);
	Fun_Haltung(n, GIL_MIL);
	n = Hlp_GetNpc(FUN_MIL_5);
	Fun_Haltung(n, GIL_MIL);
	n = Hlp_GetNpc(FUN_SLD_1);
	Fun_Haltung(n, GIL_SLD);
	n = Hlp_GetNpc(FUN_SLD_2);
	Fun_Haltung(n, GIL_SLD);
	n = Hlp_GetNpc(FUN_SLD_3);
	Fun_Haltung(n, GIL_SLD);
	n = Hlp_GetNpc(FUN_SLD_4);
	Fun_Haltung(n, GIL_SLD);
	n = Hlp_GetNpc(FUN_SLD_5);
	Fun_Haltung(n, GIL_SLD);
	n = Hlp_GetNpc(FUN_NOV_1);
	Fun_Haltung(n, GIL_NOV);
	n = Hlp_GetNpc(FUN_NOV_2);
	Fun_Haltung(n, GIL_NOV);
	n = Hlp_GetNpc(FUN_NOV_3);
	Fun_Haltung(n, GIL_NOV);
	n = Hlp_GetNpc(FUN_NOV_4);
	Fun_Haltung(n, GIL_NOV);
	n = Hlp_GetNpc(FUN_NOV_5);
	Fun_Haltung(n, GIL_NOV);
	n = Hlp_GetNpc(FUN_BDT_1);
	Fun_Haltung(n, GIL_BDT);
	n = Hlp_GetNpc(FUN_BDT_2);
	Fun_Haltung(n, GIL_BDT);
	n = Hlp_GetNpc(FUN_BDT_3);
	Fun_Haltung(n, GIL_BDT);
	n = Hlp_GetNpc(FUN_BDT_4);
	Fun_Haltung(n, GIL_BDT);
	n = Hlp_GetNpc(FUN_BDT_5);
	Fun_Haltung(n, GIL_BDT);
};

// Kapitel: Anzeige und Belohnung je PC, sobald FUN_KAPITEL steigt (auch wenn der Mitspieler den Stein benutzt hat)
func void Fun_KapitelPruefen()
{
	if (FUNL_KAPITEL_GESEHEN >= FUN_KAPITEL)
	{
		return;
	};
	if (FUNL_KAPITEL_GESEHEN == 0)
	{
		FUNL_KAPITEL_GESEHEN = FUN_KAPITEL;
		return;
	};
	FUNL_KAPITEL_GESEHEN = FUN_KAPITEL;
	Kapitel = FUN_KAPITEL;
	hero.lp = hero.lp + 5;
	CreateInvItems(hero, ItMi_Gold, 300 * FUN_KAPITEL);
	if (Npc_GetTrueGuild(hero) == GIL_NOV)
	{
		Npc_SetTalentSkill(hero, NPC_TALENT_MAGE, FUN_KAPITEL);
	};
	if (FUN_KAPITEL == 2)
	{
		IntroduceChapter("Kapitel 2", "Die Händler haben neue Ware", "chapter2.tga", "chapter_01.wav", 6000);
	};
	if (FUN_KAPITEL == 3)
	{
		IntroduceChapter("Kapitel 3", "Die Wälder werden gefährlicher", "chapter2.tga", "chapter_01.wav", 6000);
	};
	if (FUN_KAPITEL == 4)
	{
		IntroduceChapter("Kapitel 4", "Die Lager rüsten auf", "chapter4.tga", "chapter_01.wav", 6000);
	};
	if (FUN_KAPITEL == 5)
	{
		IntroduceChapter("Kapitel 5", "Trolle im Land", "chapter4.tga", "chapter_01.wav", 6000);
	};
	if (FUN_KAPITEL == 6)
	{
		IntroduceChapter("Kapitel 6", "Das letzte Kapitel", "chapter6.tga", "chapter_01.wav", 6000);
	};
};

func void Use_Fun_Kapitelstein()
{
	if (FUN_KAPITEL >= 6)
	{
		Print("Das letzte Kapitel ist schon erreicht.");
		return;
	};
	Npc_RemoveInvItems(self, ItMi_Fun_Kapitelstein, 1);
	FUN_KAPITEL = FUN_KAPITEL + 1;
	Kapitel = FUN_KAPITEL;
	Fun_KapitelPruefen();
};

instance DIA_FUN_MIL_1_EXIT (C_INFO)
{
	npc = FUN_MIL_1;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_MIL_1_KOMM (C_INFO)
{
	npc = FUN_MIL_1;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_MIL_1_WARTE (C_INFO)
{
	npc = FUN_MIL_1;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_MIL_2_EXIT (C_INFO)
{
	npc = FUN_MIL_2;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_MIL_2_KOMM (C_INFO)
{
	npc = FUN_MIL_2;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_MIL_2_WARTE (C_INFO)
{
	npc = FUN_MIL_2;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_MIL_3_EXIT (C_INFO)
{
	npc = FUN_MIL_3;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_MIL_3_KOMM (C_INFO)
{
	npc = FUN_MIL_3;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_MIL_3_WARTE (C_INFO)
{
	npc = FUN_MIL_3;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_MIL_4_EXIT (C_INFO)
{
	npc = FUN_MIL_4;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_MIL_4_KOMM (C_INFO)
{
	npc = FUN_MIL_4;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_MIL_4_WARTE (C_INFO)
{
	npc = FUN_MIL_4;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_MIL_5_EXIT (C_INFO)
{
	npc = FUN_MIL_5;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_MIL_5_KOMM (C_INFO)
{
	npc = FUN_MIL_5;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_MIL_5_WARTE (C_INFO)
{
	npc = FUN_MIL_5;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_SLD_1_EXIT (C_INFO)
{
	npc = FUN_SLD_1;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_SLD_1_KOMM (C_INFO)
{
	npc = FUN_SLD_1;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_SLD_1_WARTE (C_INFO)
{
	npc = FUN_SLD_1;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_SLD_2_EXIT (C_INFO)
{
	npc = FUN_SLD_2;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_SLD_2_KOMM (C_INFO)
{
	npc = FUN_SLD_2;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_SLD_2_WARTE (C_INFO)
{
	npc = FUN_SLD_2;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_SLD_3_EXIT (C_INFO)
{
	npc = FUN_SLD_3;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_SLD_3_KOMM (C_INFO)
{
	npc = FUN_SLD_3;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_SLD_3_WARTE (C_INFO)
{
	npc = FUN_SLD_3;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_SLD_4_EXIT (C_INFO)
{
	npc = FUN_SLD_4;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_SLD_4_KOMM (C_INFO)
{
	npc = FUN_SLD_4;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_SLD_4_WARTE (C_INFO)
{
	npc = FUN_SLD_4;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_SLD_5_EXIT (C_INFO)
{
	npc = FUN_SLD_5;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_SLD_5_KOMM (C_INFO)
{
	npc = FUN_SLD_5;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_SLD_5_WARTE (C_INFO)
{
	npc = FUN_SLD_5;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_NOV_1_EXIT (C_INFO)
{
	npc = FUN_NOV_1;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_NOV_1_KOMM (C_INFO)
{
	npc = FUN_NOV_1;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_NOV_1_WARTE (C_INFO)
{
	npc = FUN_NOV_1;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_NOV_2_EXIT (C_INFO)
{
	npc = FUN_NOV_2;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_NOV_2_KOMM (C_INFO)
{
	npc = FUN_NOV_2;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_NOV_2_WARTE (C_INFO)
{
	npc = FUN_NOV_2;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_NOV_3_EXIT (C_INFO)
{
	npc = FUN_NOV_3;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_NOV_3_KOMM (C_INFO)
{
	npc = FUN_NOV_3;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_NOV_3_WARTE (C_INFO)
{
	npc = FUN_NOV_3;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_NOV_4_EXIT (C_INFO)
{
	npc = FUN_NOV_4;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_NOV_4_KOMM (C_INFO)
{
	npc = FUN_NOV_4;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_NOV_4_WARTE (C_INFO)
{
	npc = FUN_NOV_4;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_NOV_5_EXIT (C_INFO)
{
	npc = FUN_NOV_5;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_NOV_5_KOMM (C_INFO)
{
	npc = FUN_NOV_5;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_NOV_5_WARTE (C_INFO)
{
	npc = FUN_NOV_5;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_BDT_1_EXIT (C_INFO)
{
	npc = FUN_BDT_1;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_BDT_1_KOMM (C_INFO)
{
	npc = FUN_BDT_1;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_BDT_1_WARTE (C_INFO)
{
	npc = FUN_BDT_1;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_BDT_2_EXIT (C_INFO)
{
	npc = FUN_BDT_2;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_BDT_2_KOMM (C_INFO)
{
	npc = FUN_BDT_2;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_BDT_2_WARTE (C_INFO)
{
	npc = FUN_BDT_2;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_BDT_3_EXIT (C_INFO)
{
	npc = FUN_BDT_3;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_BDT_3_KOMM (C_INFO)
{
	npc = FUN_BDT_3;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_BDT_3_WARTE (C_INFO)
{
	npc = FUN_BDT_3;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_BDT_4_EXIT (C_INFO)
{
	npc = FUN_BDT_4;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_BDT_4_KOMM (C_INFO)
{
	npc = FUN_BDT_4;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_BDT_4_WARTE (C_INFO)
{
	npc = FUN_BDT_4;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};
instance DIA_FUN_BDT_5_EXIT (C_INFO)
{
	npc = FUN_BDT_5;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_BDT_5_KOMM (C_INFO)
{
	npc = FUN_BDT_5;
	nr = 1;
	condition = DIA_Fun_Komm_Condition;
	information = DIA_Fun_Komm_Info;
	permanent = TRUE;
	description = "Komm mit, wir ziehen los!";
};
instance DIA_FUN_BDT_5_WARTE (C_INFO)
{
	npc = FUN_BDT_5;
	nr = 2;
	condition = DIA_Fun_Warte_Condition;
	information = DIA_Fun_Warte_Info;
	permanent = TRUE;
	description = "Warte hier - geh zurück ins Lager.";
};

instance DIA_FUN_HAENDLER_MIL_EXIT (C_INFO)
{
	npc = FUN_HAENDLER_MIL;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_HAENDLER_MIL_HANDEL (C_INFO)
{
	npc = FUN_HAENDLER_MIL;
	nr = 1;
	condition = DIA_Fun_Handel_Condition;
	information = DIA_Fun_Handel_Info;
	permanent = TRUE;
	trade = TRUE;
	description = "Zeig mir deine Ware.";
};
instance DIA_FUN_HAENDLER_MIL_ATTR (C_INFO)
{
	npc = FUN_HAENDLER_MIL;
	nr = 2;
	condition = DIA_Fun_Handel_Condition;
	information = DIA_Fun_LehreATTR_Info;
	permanent = TRUE;
	description = "Ich will stärker, geschickter oder mächtiger werden.";
};
instance DIA_FUN_HAENDLER_MIL_KAMPF (C_INFO)
{
	npc = FUN_HAENDLER_MIL;
	nr = 3;
	condition = DIA_Fun_Handel_Condition;
	information = DIA_Fun_LehreKAMPF_Info;
	permanent = TRUE;
	description = "Ich will besser kämpfen.";
};
instance DIA_FUN_HAENDLER_SLD_EXIT (C_INFO)
{
	npc = FUN_HAENDLER_SLD;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_HAENDLER_SLD_HANDEL (C_INFO)
{
	npc = FUN_HAENDLER_SLD;
	nr = 1;
	condition = DIA_Fun_Handel_Condition;
	information = DIA_Fun_Handel_Info;
	permanent = TRUE;
	trade = TRUE;
	description = "Zeig mir deine Ware.";
};
instance DIA_FUN_HAENDLER_SLD_ATTR (C_INFO)
{
	npc = FUN_HAENDLER_SLD;
	nr = 2;
	condition = DIA_Fun_Handel_Condition;
	information = DIA_Fun_LehreATTR_Info;
	permanent = TRUE;
	description = "Ich will stärker, geschickter oder mächtiger werden.";
};
instance DIA_FUN_HAENDLER_SLD_KAMPF (C_INFO)
{
	npc = FUN_HAENDLER_SLD;
	nr = 3;
	condition = DIA_Fun_Handel_Condition;
	information = DIA_Fun_LehreKAMPF_Info;
	permanent = TRUE;
	description = "Ich will besser kämpfen.";
};
instance DIA_FUN_HAENDLER_NOV_EXIT (C_INFO)
{
	npc = FUN_HAENDLER_NOV;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_HAENDLER_NOV_HANDEL (C_INFO)
{
	npc = FUN_HAENDLER_NOV;
	nr = 1;
	condition = DIA_Fun_Handel_Condition;
	information = DIA_Fun_Handel_Info;
	permanent = TRUE;
	trade = TRUE;
	description = "Zeig mir deine Ware.";
};
instance DIA_FUN_HAENDLER_NOV_ATTR (C_INFO)
{
	npc = FUN_HAENDLER_NOV;
	nr = 2;
	condition = DIA_Fun_Handel_Condition;
	information = DIA_Fun_LehreATTR_Info;
	permanent = TRUE;
	description = "Ich will stärker, geschickter oder mächtiger werden.";
};
instance DIA_FUN_HAENDLER_NOV_KAMPF (C_INFO)
{
	npc = FUN_HAENDLER_NOV;
	nr = 3;
	condition = DIA_Fun_Handel_Condition;
	information = DIA_Fun_LehreKAMPF_Info;
	permanent = TRUE;
	description = "Ich will besser kämpfen.";
};
instance DIA_FUN_HAENDLER_BDT_EXIT (C_INFO)
{
	npc = FUN_HAENDLER_BDT;
	nr = 999;
	condition = DIA_Fun_Exit_Condition;
	information = DIA_Fun_Exit_Info;
	permanent = TRUE;
	description = DIALOG_ENDE;
};
instance DIA_FUN_HAENDLER_BDT_HANDEL (C_INFO)
{
	npc = FUN_HAENDLER_BDT;
	nr = 1;
	condition = DIA_Fun_Handel_Condition;
	information = DIA_Fun_Handel_Info;
	permanent = TRUE;
	trade = TRUE;
	description = "Zeig mir deine Ware.";
};
instance DIA_FUN_HAENDLER_BDT_ATTR (C_INFO)
{
	npc = FUN_HAENDLER_BDT;
	nr = 2;
	condition = DIA_Fun_Handel_Condition;
	information = DIA_Fun_LehreATTR_Info;
	permanent = TRUE;
	description = "Ich will stärker, geschickter oder mächtiger werden.";
};
instance DIA_FUN_HAENDLER_BDT_KAMPF (C_INFO)
{
	npc = FUN_HAENDLER_BDT;
	nr = 3;
	condition = DIA_Fun_Handel_Condition;
	information = DIA_Fun_LehreKAMPF_Info;
	permanent = TRUE;
	description = "Ich will besser kämpfen.";
};

// --- Dialoge -------------------------------------------------------------------------------------------------------
func int DIA_Fun_Exit_Condition()
{
	return TRUE;
};
func void DIA_Fun_Exit_Info()
{
	AI_StopProcessInfos(self);
};

func int DIA_Fun_Komm_Condition()
{
	if (FUN_AKTIV && (Npc_GetTrueGuild(other) == self.guild) && (self.aivar[AIV_PARTYMEMBER] == FALSE))
	{
		return TRUE;
	};
	return FALSE;
};
func void DIA_Fun_Komm_Info()
{
	AI_Output(other, self, "DIA_Addon_Matt_FollowMe_15_00"); //Komm mit.
	self.aivar[AIV_PARTYMEMBER] = TRUE;
	Print(ConcatStrings(self.name, " folgt dir."));
	AI_StopProcessInfos(self);
	Npc_ExchangeRoutine(self, "FOLLOW");
};
func int DIA_Fun_Warte_Condition()
{
	if (FUN_AKTIV && (Npc_GetTrueGuild(other) == self.guild) && (self.aivar[AIV_PARTYMEMBER] == TRUE))
	{
		return TRUE;
	};
	return FALSE;
};
func void DIA_Fun_Warte_Info()
{
	AI_Output(other, self, "DIA_Addon_Diego_WarteHier_15_00"); //Warte hier!
	self.aivar[AIV_PARTYMEMBER] = FALSE;
	Print(ConcatStrings(self.name, " geht zurück ins Lager."));
	AI_StopProcessInfos(self);
	Npc_ExchangeRoutine(self, "START");
};
func void Fun_Ware(var C_NPC slf, var int itm, var int anz)
{
	var int hat;
	hat = Npc_HasItems(slf, itm);
	if (hat < anz)
	{
		CreateInvItems(slf, itm, anz - hat);
	};
};

func void Fun_HaendlerWare(var C_NPC slf)
{
	var int vorrat;
	vorrat = Npc_HasItems(slf, ItMi_Gold);
	if (vorrat < FUN_HAENDLER_GOLD)
	{
		CreateInvItems(slf, ItMi_Gold, FUN_HAENDLER_GOLD - vorrat);
	};
	if (FUN_KAPITEL >= 1)
	{
		Fun_Ware(slf, ItPo_Health_01, 20);
		Fun_Ware(slf, ItRw_Arrow, 300);
		Fun_Ware(slf, ItRw_Bolt, 300);
		Fun_Ware(slf, ItFoMutton, 10);
		Fun_Ware(slf, ItFo_Bread, 10);
		Fun_Ware(slf, ItSc_Firebolt, 5);
		Fun_Ware(slf, ItSc_LightHeal, 5);
		Fun_Ware(slf, ItMw_ShortSword3, 1);
		Fun_Ware(slf, ItMw_Nagelkeule, 1);
		Fun_Ware(slf, ItMw_1h_Mil_Sword, 1);
		Fun_Ware(slf, ItMw_2h_Sld_Sword, 1);
		Fun_Ware(slf, ItRw_Bow_L_02, 1);
		Fun_Ware(slf, ItRw_Bow_L_03, 1);
		Fun_Ware(slf, ItRw_Crossbow_L_01, 1);
		Fun_Ware(slf, ItRw_Mil_Crossbow, 1);
		Fun_Ware(slf, ItPo_Mana_01, 20);
		Fun_Ware(slf, ITAR_Leather_L, 1);
		Fun_Ware(slf, ITAR_BAU_L, 1);
		if (slf.id == 9601)
		{
			Fun_Ware(slf, ITAR_MIL_L, 1);
		};
		if (slf.id == 9602)
		{
			Fun_Ware(slf, ITAR_SLD_L, 1);
		};
		if (slf.id == 9603)
		{
			Fun_Ware(slf, ITAR_NOV_L, 1);
			Fun_Ware(slf, ItPo_Mana_01, 20);
			Fun_Ware(slf, ItRu_FireBolt, 1);
			Fun_Ware(slf, ItRu_LightHeal, 1);
			Fun_Ware(slf, ItRu_Light, 1);
		};
		if (slf.id == 9604)
		{
			Fun_Ware(slf, ITAR_Leather_L, 1);
		};
	};
	if (FUN_KAPITEL >= 2)
	{
		Fun_Ware(slf, ItPo_Health_02, 10);
		Fun_Ware(slf, ItSc_InstantFireball, 3);
		Fun_Ware(slf, ItSc_SumWolf, 2);
		Fun_Ware(slf, ItMw_Schwert1, 1);
		Fun_Ware(slf, ItMw_Kriegshammer1, 1);
		Fun_Ware(slf, ItMw_Zweihaender1, 1);
		Fun_Ware(slf, ItMw_Streitaxt1, 1);
		Fun_Ware(slf, ItRw_Bow_L_04, 1);
		Fun_Ware(slf, ItRw_Bow_M_01, 1);
		Fun_Ware(slf, ItRw_Crossbow_L_02, 1);
		Fun_Ware(slf, ItPo_Mana_02, 10);
		Fun_Ware(slf, ITAR_BDT_M, 1);
		Fun_Ware(slf, ITAR_SLD_L, 1);
		Fun_Ware(slf, ITAR_MIL_L, 1);
		Fun_Ware(slf, ITAR_PIR_L_Addon, 1);
		if (slf.id == 9601)
		{
			Fun_Ware(slf, ITAR_MIL_M, 1);
		};
		if (slf.id == 9602)
		{
			Fun_Ware(slf, ITAR_SLD_M, 1);
		};
		if (slf.id == 9603)
		{
			Fun_Ware(slf, ITAR_KDF_L, 1);
			Fun_Ware(slf, ItPo_Mana_02, 10);
			Fun_Ware(slf, ItRu_InstantFireball, 1);
			Fun_Ware(slf, ItRu_Icebolt, 1);
			Fun_Ware(slf, ItRu_SumWolf, 1);
			Fun_Ware(slf, ItMW_Addon_Stab01, 1);
		};
		if (slf.id == 9604)
		{
			Fun_Ware(slf, ITAR_BDT_M, 1);
		};
	};
	if (FUN_KAPITEL >= 3)
	{
		Fun_Ware(slf, ItSc_MediumHeal, 3);
		Fun_Ware(slf, ItPo_Speed, 3);
		Fun_Ware(slf, ItMw_Schwert4, 1);
		Fun_Ware(slf, ItMw_Steinbrecher, 1);
		Fun_Ware(slf, ItMw_Morgenstern, 1);
		Fun_Ware(slf, ItMw_Zweihaender2, 1);
		Fun_Ware(slf, ItMw_Streitaxt2, 1);
		Fun_Ware(slf, ItRw_Bow_M_02, 1);
		Fun_Ware(slf, ItRw_Bow_M_03, 1);
		Fun_Ware(slf, ItRw_Crossbow_M_01, 1);
		Fun_Ware(slf, ITAR_DJG_Crawler, 1);
		Fun_Ware(slf, ITAR_SLD_M, 1);
		Fun_Ware(slf, ITAR_MIL_M, 1);
		Fun_Ware(slf, ITAR_PIR_M_Addon, 1);
		Fun_Ware(slf, ItPo_Mana_Addon_04, 3);
		if (slf.id == 9601)
		{
			Fun_Ware(slf, ITAR_PAL_M, 1);
			Fun_Ware(slf, ItMw_1h_Pal_Sword, 1);
			Fun_Ware(slf, ItMw_2h_Pal_Sword, 1);
		};
		if (slf.id == 9602)
		{
			Fun_Ware(slf, ITAR_SLD_H, 1);
		};
		if (slf.id == 9603)
		{
			Fun_Ware(slf, ItRu_Firestorm, 1);
			Fun_Ware(slf, ItRu_MediumHeal, 1);
			Fun_Ware(slf, ItRu_ThunderBall, 1);
			Fun_Ware(slf, ItRu_SumSkel, 1);
			Fun_Ware(slf, ItMW_Addon_Stab03, 1);
		};
		if (slf.id == 9604)
		{
			Fun_Ware(slf, ITAR_BDT_H, 1);
		};
	};
	if (FUN_KAPITEL >= 4)
	{
		Fun_Ware(slf, ItPo_Health_03, 10);
		Fun_Ware(slf, ItSc_ChargeFireball, 2);
		Fun_Ware(slf, ItMw_Streitkolben, 1);
		Fun_Ware(slf, ItMw_Rubinklinge, 1);
		Fun_Ware(slf, ItMw_Runenschwert, 1);
		Fun_Ware(slf, ItMw_Zweihaender4, 1);
		Fun_Ware(slf, ItMw_Schlachtaxt, 1);
		Fun_Ware(slf, ItRw_Bow_M_04, 1);
		Fun_Ware(slf, ItRw_Bow_H_01, 1);
		Fun_Ware(slf, ItRw_Crossbow_M_02, 1);
		Fun_Ware(slf, ItPo_Mana_03, 10);
		Fun_Ware(slf, ITAR_SLD_H, 1);
		Fun_Ware(slf, ITAR_DJG_L, 1);
		Fun_Ware(slf, ITAR_PIR_H_Addon, 1);
		Fun_Ware(slf, ITAR_Thorus_Addon, 1);
		if (slf.id == 9601)
		{
			Fun_Ware(slf, ItRu_PalLightHeal, 1);
			Fun_Ware(slf, ItRu_PalHolyBolt, 1);
		};
		if (slf.id == 9602)
		{
			Fun_Ware(slf, ITAR_DJG_L, 1);
		};
		if (slf.id == 9603)
		{
			Fun_Ware(slf, ITAR_KDF_H, 1);
			Fun_Ware(slf, ItPo_Mana_03, 10);
			Fun_Ware(slf, ItRu_ChargeFireball, 1);
			Fun_Ware(slf, ItRu_LightningFlash, 1);
			Fun_Ware(slf, ItRu_SumGol, 1);
			Fun_Ware(slf, ItMW_Addon_Stab04, 1);
		};
		if (slf.id == 9604)
		{
			Fun_Ware(slf, ITAR_Thorus_Addon, 1);
		};
	};
	if (FUN_KAPITEL >= 5)
	{
		Fun_Ware(slf, ItPo_Perm_STR, 1);
		Fun_Ware(slf, ItPo_Perm_DEX, 1);
		Fun_Ware(slf, ItPo_Perm_Health, 1);
		Fun_Ware(slf, ItSc_Firestorm, 2);
		Fun_Ware(slf, ItMw_Orkschlaechter, 1);
		Fun_Ware(slf, ItMw_Kriegshammer2, 1);
		Fun_Ware(slf, ItMw_Folteraxt, 1);
		Fun_Ware(slf, ItMw_Krummschwert, 1);
		Fun_Ware(slf, ItMw_Barbarenstreitaxt, 1);
		Fun_Ware(slf, ItRw_Bow_H_02, 1);
		Fun_Ware(slf, ItRw_Bow_H_03, 1);
		Fun_Ware(slf, ItRw_Crossbow_H_01, 1);
		Fun_Ware(slf, ITAR_DJG_M, 1);
		Fun_Ware(slf, ITAR_PAL_M, 1);
		Fun_Ware(slf, ITAR_OreBaron_Addon, 1);
		Fun_Ware(slf, ItPo_Perm_Mana, 1);
		if (slf.id == 9601)
		{
			Fun_Ware(slf, ITAR_PAL_H, 1);
			Fun_Ware(slf, ItRu_PalMediumHeal, 1);
		};
		if (slf.id == 9602)
		{
			Fun_Ware(slf, ITAR_DJG_M, 1);
		};
		if (slf.id == 9603)
		{
			Fun_Ware(slf, ItRu_Pyrokinesis, 1);
			Fun_Ware(slf, ItRu_IceWave, 1);
			Fun_Ware(slf, ItRu_FullHeal, 1);
			Fun_Ware(slf, ItRu_SumDemon, 1);
			Fun_Ware(slf, ItMW_Addon_Stab05, 1);
		};
		if (slf.id == 9604)
		{
			Fun_Ware(slf, ITAR_Raven_Addon, 1);
		};
	};
	if (FUN_KAPITEL >= 6)
	{
		Fun_Ware(slf, ItPo_Perm_Mana, 1);
		Fun_Ware(slf, ItSc_Firerain, 1);
		Fun_Ware(slf, ItMw_1H_Special_03, 1);
		Fun_Ware(slf, ItMw_1H_Special_04, 1);
		Fun_Ware(slf, ItMw_2H_Special_04, 1);
		Fun_Ware(slf, ItMw_Drachenschneide, 1);
		Fun_Ware(slf, ItMw_2H_Special_03, 1);
		Fun_Ware(slf, ItRw_Bow_H_04, 1);
		Fun_Ware(slf, ItRw_Crossbow_H_02, 1);
		Fun_Ware(slf, ITAR_DJG_H, 1);
		Fun_Ware(slf, ITAR_PAL_H, 1);
		Fun_Ware(slf, ITAR_Raven_Addon, 1);
		Fun_Ware(slf, ItAr_FireArmor_Addon, 1);
		if (slf.id == 9601)
		{
			Fun_Ware(slf, ItRu_PalFullHeal, 1);
			Fun_Ware(slf, ItRu_PalDestroyEvil, 1);
		};
		if (slf.id == 9602)
		{
			Fun_Ware(slf, ITAR_DJG_H, 1);
		};
		if (slf.id == 9603)
		{
			Fun_Ware(slf, ItRu_Firerain, 1);
			Fun_Ware(slf, ItRu_BreathOfDeath, 1);
			Fun_Ware(slf, ItRu_MassDeath, 1);
			Fun_Ware(slf, ItRu_ArmyOfDarkness, 1);
		};
		if (slf.id == 9604)
		{
			Fun_Ware(slf, ITAR_Dementor, 1);
		};
	};
};

func int DIA_Fun_Handel_Condition()
{
	if (FUN_AKTIV && (Npc_GetTrueGuild(other) == Fun_GildeVonHaendler(self)))
	{
		return TRUE;
	};
	return FALSE;
};
func void DIA_Fun_Handel_Info()
{
	AI_Output(other, self, "DIA_Bosper_Trade_15_00"); //Zeig mir deine Ware.
	Fun_HaendlerWare(self);
};

func void Fun_LehreLeben(var int lp)
{
	if (other.lp < lp)
	{
		Print("Zu wenige Lernpunkte!");
		return;
	};
	other.lp = other.lp - lp;
	other.attribute[ATR_HITPOINTS_MAX] = other.attribute[ATR_HITPOINTS_MAX] + lp * 10;
	other.attribute[ATR_HITPOINTS] = other.attribute[ATR_HITPOINTS] + lp * 10;
	Print(ConcatStrings("Lebensenergie + ", IntToString(lp * 10)));
};

func void DIA_Fun_LehreATTR_Menue()
{
	Info_ClearChoices(DIA_FUN_HAENDLER_MIL_ATTR);
	Info_ClearChoices(DIA_FUN_HAENDLER_SLD_ATTR);
	Info_ClearChoices(DIA_FUN_HAENDLER_NOV_ATTR);
	Info_ClearChoices(DIA_FUN_HAENDLER_BDT_ATTR);
	if (self.id == 9601)
	{
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_ATTR, DIALOG_BACK, DIA_Fun_LehreATTR_Zurueck);
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_ATTR, B_BuildLearnString(PRINT_LearnSTR1, B_GetLearnCostAttribute(other, ATR_STRENGTH)), DIA_Fun_LehreATTR_STR1);
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_ATTR, B_BuildLearnString(PRINT_LearnSTR5, B_GetLearnCostAttribute(other, ATR_STRENGTH) * 5), DIA_Fun_LehreATTR_STR5);
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_ATTR, B_BuildLearnString(PRINT_LearnDEX1, B_GetLearnCostAttribute(other, ATR_DEXTERITY)), DIA_Fun_LehreATTR_DEX1);
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_ATTR, B_BuildLearnString(PRINT_LearnDEX5, B_GetLearnCostAttribute(other, ATR_DEXTERITY) * 5), DIA_Fun_LehreATTR_DEX5);
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_ATTR, B_BuildLearnString(PRINT_LearnMANA1, B_GetLearnCostAttribute(other, ATR_MANA_MAX)), DIA_Fun_LehreATTR_MANA1);
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_ATTR, B_BuildLearnString(PRINT_LearnMANA5, B_GetLearnCostAttribute(other, ATR_MANA_MAX) * 5), DIA_Fun_LehreATTR_MANA5);
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_ATTR, B_BuildLearnString("Lebensenergie + 10", 1), DIA_Fun_LehreATTR_HP1);
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_ATTR, B_BuildLearnString("Lebensenergie + 50", 5), DIA_Fun_LehreATTR_HP5);
	};
	if (self.id == 9602)
	{
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_ATTR, DIALOG_BACK, DIA_Fun_LehreATTR_Zurueck);
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_ATTR, B_BuildLearnString(PRINT_LearnSTR1, B_GetLearnCostAttribute(other, ATR_STRENGTH)), DIA_Fun_LehreATTR_STR1);
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_ATTR, B_BuildLearnString(PRINT_LearnSTR5, B_GetLearnCostAttribute(other, ATR_STRENGTH) * 5), DIA_Fun_LehreATTR_STR5);
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_ATTR, B_BuildLearnString(PRINT_LearnDEX1, B_GetLearnCostAttribute(other, ATR_DEXTERITY)), DIA_Fun_LehreATTR_DEX1);
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_ATTR, B_BuildLearnString(PRINT_LearnDEX5, B_GetLearnCostAttribute(other, ATR_DEXTERITY) * 5), DIA_Fun_LehreATTR_DEX5);
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_ATTR, B_BuildLearnString(PRINT_LearnMANA1, B_GetLearnCostAttribute(other, ATR_MANA_MAX)), DIA_Fun_LehreATTR_MANA1);
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_ATTR, B_BuildLearnString(PRINT_LearnMANA5, B_GetLearnCostAttribute(other, ATR_MANA_MAX) * 5), DIA_Fun_LehreATTR_MANA5);
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_ATTR, B_BuildLearnString("Lebensenergie + 10", 1), DIA_Fun_LehreATTR_HP1);
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_ATTR, B_BuildLearnString("Lebensenergie + 50", 5), DIA_Fun_LehreATTR_HP5);
	};
	if (self.id == 9603)
	{
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_ATTR, DIALOG_BACK, DIA_Fun_LehreATTR_Zurueck);
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_ATTR, B_BuildLearnString(PRINT_LearnSTR1, B_GetLearnCostAttribute(other, ATR_STRENGTH)), DIA_Fun_LehreATTR_STR1);
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_ATTR, B_BuildLearnString(PRINT_LearnSTR5, B_GetLearnCostAttribute(other, ATR_STRENGTH) * 5), DIA_Fun_LehreATTR_STR5);
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_ATTR, B_BuildLearnString(PRINT_LearnDEX1, B_GetLearnCostAttribute(other, ATR_DEXTERITY)), DIA_Fun_LehreATTR_DEX1);
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_ATTR, B_BuildLearnString(PRINT_LearnDEX5, B_GetLearnCostAttribute(other, ATR_DEXTERITY) * 5), DIA_Fun_LehreATTR_DEX5);
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_ATTR, B_BuildLearnString(PRINT_LearnMANA1, B_GetLearnCostAttribute(other, ATR_MANA_MAX)), DIA_Fun_LehreATTR_MANA1);
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_ATTR, B_BuildLearnString(PRINT_LearnMANA5, B_GetLearnCostAttribute(other, ATR_MANA_MAX) * 5), DIA_Fun_LehreATTR_MANA5);
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_ATTR, B_BuildLearnString("Lebensenergie + 10", 1), DIA_Fun_LehreATTR_HP1);
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_ATTR, B_BuildLearnString("Lebensenergie + 50", 5), DIA_Fun_LehreATTR_HP5);
	};
	if (self.id == 9604)
	{
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_ATTR, DIALOG_BACK, DIA_Fun_LehreATTR_Zurueck);
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_ATTR, B_BuildLearnString(PRINT_LearnSTR1, B_GetLearnCostAttribute(other, ATR_STRENGTH)), DIA_Fun_LehreATTR_STR1);
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_ATTR, B_BuildLearnString(PRINT_LearnSTR5, B_GetLearnCostAttribute(other, ATR_STRENGTH) * 5), DIA_Fun_LehreATTR_STR5);
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_ATTR, B_BuildLearnString(PRINT_LearnDEX1, B_GetLearnCostAttribute(other, ATR_DEXTERITY)), DIA_Fun_LehreATTR_DEX1);
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_ATTR, B_BuildLearnString(PRINT_LearnDEX5, B_GetLearnCostAttribute(other, ATR_DEXTERITY) * 5), DIA_Fun_LehreATTR_DEX5);
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_ATTR, B_BuildLearnString(PRINT_LearnMANA1, B_GetLearnCostAttribute(other, ATR_MANA_MAX)), DIA_Fun_LehreATTR_MANA1);
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_ATTR, B_BuildLearnString(PRINT_LearnMANA5, B_GetLearnCostAttribute(other, ATR_MANA_MAX) * 5), DIA_Fun_LehreATTR_MANA5);
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_ATTR, B_BuildLearnString("Lebensenergie + 10", 1), DIA_Fun_LehreATTR_HP1);
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_ATTR, B_BuildLearnString("Lebensenergie + 50", 5), DIA_Fun_LehreATTR_HP5);
	};
};
func void DIA_Fun_LehreATTR_Zurueck()
{
	Info_ClearChoices(DIA_FUN_HAENDLER_MIL_ATTR);
	Info_ClearChoices(DIA_FUN_HAENDLER_SLD_ATTR);
	Info_ClearChoices(DIA_FUN_HAENDLER_NOV_ATTR);
	Info_ClearChoices(DIA_FUN_HAENDLER_BDT_ATTR);
};
func void DIA_Fun_LehreATTR_STR1()
{
	B_TeachAttributePoints(self, other, ATR_STRENGTH, 1, T_MAX);
	DIA_Fun_LehreATTR_Menue();
};
func void DIA_Fun_LehreATTR_STR5()
{
	B_TeachAttributePoints(self, other, ATR_STRENGTH, 5, T_MAX);
	DIA_Fun_LehreATTR_Menue();
};
func void DIA_Fun_LehreATTR_DEX1()
{
	B_TeachAttributePoints(self, other, ATR_DEXTERITY, 1, T_MAX);
	DIA_Fun_LehreATTR_Menue();
};
func void DIA_Fun_LehreATTR_DEX5()
{
	B_TeachAttributePoints(self, other, ATR_DEXTERITY, 5, T_MAX);
	DIA_Fun_LehreATTR_Menue();
};
func void DIA_Fun_LehreATTR_MANA1()
{
	B_TeachAttributePoints(self, other, ATR_MANA_MAX, 1, T_MEGA);
	DIA_Fun_LehreATTR_Menue();
};
func void DIA_Fun_LehreATTR_MANA5()
{
	B_TeachAttributePoints(self, other, ATR_MANA_MAX, 5, T_MEGA);
	DIA_Fun_LehreATTR_Menue();
};
func void DIA_Fun_LehreATTR_HP1()
{
	Fun_LehreLeben(1);
	DIA_Fun_LehreATTR_Menue();
};
func void DIA_Fun_LehreATTR_HP5()
{
	Fun_LehreLeben(5);
	DIA_Fun_LehreATTR_Menue();
};
func void DIA_Fun_LehreATTR_Info()
{
	AI_Output(other, self, "DIA_Wolf_WannaLearn_15_00"); //Kannst du mir was beibringen?
	DIA_Fun_LehreATTR_Menue();
};
func void DIA_Fun_LehreKAMPF_Menue()
{
	Info_ClearChoices(DIA_FUN_HAENDLER_MIL_KAMPF);
	Info_ClearChoices(DIA_FUN_HAENDLER_SLD_KAMPF);
	Info_ClearChoices(DIA_FUN_HAENDLER_NOV_KAMPF);
	Info_ClearChoices(DIA_FUN_HAENDLER_BDT_KAMPF);
	if (self.id == 9601)
	{
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_KAMPF, DIALOG_BACK, DIA_Fun_LehreKAMPF_Zurueck);
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_KAMPF, B_BuildLearnString(PRINT_Learn1h1, B_GetLearnCostTalent(other, NPC_TALENT_1H, 1)), DIA_Fun_LehreKAMPF_1H1);
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_KAMPF, B_BuildLearnString(PRINT_Learn1h5, B_GetLearnCostTalent(other, NPC_TALENT_1H, 1) * 5), DIA_Fun_LehreKAMPF_1H5);
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_KAMPF, B_BuildLearnString(PRINT_Learn2h1, B_GetLearnCostTalent(other, NPC_TALENT_2H, 1)), DIA_Fun_LehreKAMPF_2H1);
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_KAMPF, B_BuildLearnString(PRINT_Learn2h5, B_GetLearnCostTalent(other, NPC_TALENT_2H, 1) * 5), DIA_Fun_LehreKAMPF_2H5);
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_KAMPF, B_BuildLearnString(PRINT_LearnBow1, B_GetLearnCostTalent(other, NPC_TALENT_BOW, 1)), DIA_Fun_LehreKAMPF_BOW1);
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_KAMPF, B_BuildLearnString(PRINT_LearnBow5, B_GetLearnCostTalent(other, NPC_TALENT_BOW, 1) * 5), DIA_Fun_LehreKAMPF_BOW5);
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_KAMPF, B_BuildLearnString(PRINT_LearnCrossBow1, B_GetLearnCostTalent(other, NPC_TALENT_CROSSBOW, 1)), DIA_Fun_LehreKAMPF_CBOW1);
		Info_AddChoice(DIA_FUN_HAENDLER_MIL_KAMPF, B_BuildLearnString(PRINT_LearnCrossBow5, B_GetLearnCostTalent(other, NPC_TALENT_CROSSBOW, 1) * 5), DIA_Fun_LehreKAMPF_CBOW5);
	};
	if (self.id == 9602)
	{
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_KAMPF, DIALOG_BACK, DIA_Fun_LehreKAMPF_Zurueck);
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_KAMPF, B_BuildLearnString(PRINT_Learn1h1, B_GetLearnCostTalent(other, NPC_TALENT_1H, 1)), DIA_Fun_LehreKAMPF_1H1);
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_KAMPF, B_BuildLearnString(PRINT_Learn1h5, B_GetLearnCostTalent(other, NPC_TALENT_1H, 1) * 5), DIA_Fun_LehreKAMPF_1H5);
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_KAMPF, B_BuildLearnString(PRINT_Learn2h1, B_GetLearnCostTalent(other, NPC_TALENT_2H, 1)), DIA_Fun_LehreKAMPF_2H1);
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_KAMPF, B_BuildLearnString(PRINT_Learn2h5, B_GetLearnCostTalent(other, NPC_TALENT_2H, 1) * 5), DIA_Fun_LehreKAMPF_2H5);
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_KAMPF, B_BuildLearnString(PRINT_LearnBow1, B_GetLearnCostTalent(other, NPC_TALENT_BOW, 1)), DIA_Fun_LehreKAMPF_BOW1);
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_KAMPF, B_BuildLearnString(PRINT_LearnBow5, B_GetLearnCostTalent(other, NPC_TALENT_BOW, 1) * 5), DIA_Fun_LehreKAMPF_BOW5);
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_KAMPF, B_BuildLearnString(PRINT_LearnCrossBow1, B_GetLearnCostTalent(other, NPC_TALENT_CROSSBOW, 1)), DIA_Fun_LehreKAMPF_CBOW1);
		Info_AddChoice(DIA_FUN_HAENDLER_SLD_KAMPF, B_BuildLearnString(PRINT_LearnCrossBow5, B_GetLearnCostTalent(other, NPC_TALENT_CROSSBOW, 1) * 5), DIA_Fun_LehreKAMPF_CBOW5);
	};
	if (self.id == 9603)
	{
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_KAMPF, DIALOG_BACK, DIA_Fun_LehreKAMPF_Zurueck);
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_KAMPF, B_BuildLearnString(PRINT_Learn1h1, B_GetLearnCostTalent(other, NPC_TALENT_1H, 1)), DIA_Fun_LehreKAMPF_1H1);
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_KAMPF, B_BuildLearnString(PRINT_Learn1h5, B_GetLearnCostTalent(other, NPC_TALENT_1H, 1) * 5), DIA_Fun_LehreKAMPF_1H5);
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_KAMPF, B_BuildLearnString(PRINT_Learn2h1, B_GetLearnCostTalent(other, NPC_TALENT_2H, 1)), DIA_Fun_LehreKAMPF_2H1);
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_KAMPF, B_BuildLearnString(PRINT_Learn2h5, B_GetLearnCostTalent(other, NPC_TALENT_2H, 1) * 5), DIA_Fun_LehreKAMPF_2H5);
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_KAMPF, B_BuildLearnString(PRINT_LearnBow1, B_GetLearnCostTalent(other, NPC_TALENT_BOW, 1)), DIA_Fun_LehreKAMPF_BOW1);
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_KAMPF, B_BuildLearnString(PRINT_LearnBow5, B_GetLearnCostTalent(other, NPC_TALENT_BOW, 1) * 5), DIA_Fun_LehreKAMPF_BOW5);
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_KAMPF, B_BuildLearnString(PRINT_LearnCrossBow1, B_GetLearnCostTalent(other, NPC_TALENT_CROSSBOW, 1)), DIA_Fun_LehreKAMPF_CBOW1);
		Info_AddChoice(DIA_FUN_HAENDLER_NOV_KAMPF, B_BuildLearnString(PRINT_LearnCrossBow5, B_GetLearnCostTalent(other, NPC_TALENT_CROSSBOW, 1) * 5), DIA_Fun_LehreKAMPF_CBOW5);
	};
	if (self.id == 9604)
	{
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_KAMPF, DIALOG_BACK, DIA_Fun_LehreKAMPF_Zurueck);
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_KAMPF, B_BuildLearnString(PRINT_Learn1h1, B_GetLearnCostTalent(other, NPC_TALENT_1H, 1)), DIA_Fun_LehreKAMPF_1H1);
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_KAMPF, B_BuildLearnString(PRINT_Learn1h5, B_GetLearnCostTalent(other, NPC_TALENT_1H, 1) * 5), DIA_Fun_LehreKAMPF_1H5);
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_KAMPF, B_BuildLearnString(PRINT_Learn2h1, B_GetLearnCostTalent(other, NPC_TALENT_2H, 1)), DIA_Fun_LehreKAMPF_2H1);
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_KAMPF, B_BuildLearnString(PRINT_Learn2h5, B_GetLearnCostTalent(other, NPC_TALENT_2H, 1) * 5), DIA_Fun_LehreKAMPF_2H5);
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_KAMPF, B_BuildLearnString(PRINT_LearnBow1, B_GetLearnCostTalent(other, NPC_TALENT_BOW, 1)), DIA_Fun_LehreKAMPF_BOW1);
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_KAMPF, B_BuildLearnString(PRINT_LearnBow5, B_GetLearnCostTalent(other, NPC_TALENT_BOW, 1) * 5), DIA_Fun_LehreKAMPF_BOW5);
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_KAMPF, B_BuildLearnString(PRINT_LearnCrossBow1, B_GetLearnCostTalent(other, NPC_TALENT_CROSSBOW, 1)), DIA_Fun_LehreKAMPF_CBOW1);
		Info_AddChoice(DIA_FUN_HAENDLER_BDT_KAMPF, B_BuildLearnString(PRINT_LearnCrossBow5, B_GetLearnCostTalent(other, NPC_TALENT_CROSSBOW, 1) * 5), DIA_Fun_LehreKAMPF_CBOW5);
	};
};
func void DIA_Fun_LehreKAMPF_Zurueck()
{
	Info_ClearChoices(DIA_FUN_HAENDLER_MIL_KAMPF);
	Info_ClearChoices(DIA_FUN_HAENDLER_SLD_KAMPF);
	Info_ClearChoices(DIA_FUN_HAENDLER_NOV_KAMPF);
	Info_ClearChoices(DIA_FUN_HAENDLER_BDT_KAMPF);
};
func void DIA_Fun_LehreKAMPF_1H1()
{
	B_TeachFightTalentPercent(self, other, NPC_TALENT_1H, 1, 100);
	DIA_Fun_LehreKAMPF_Menue();
};
func void DIA_Fun_LehreKAMPF_1H5()
{
	B_TeachFightTalentPercent(self, other, NPC_TALENT_1H, 5, 100);
	DIA_Fun_LehreKAMPF_Menue();
};
func void DIA_Fun_LehreKAMPF_2H1()
{
	B_TeachFightTalentPercent(self, other, NPC_TALENT_2H, 1, 100);
	DIA_Fun_LehreKAMPF_Menue();
};
func void DIA_Fun_LehreKAMPF_2H5()
{
	B_TeachFightTalentPercent(self, other, NPC_TALENT_2H, 5, 100);
	DIA_Fun_LehreKAMPF_Menue();
};
func void DIA_Fun_LehreKAMPF_BOW1()
{
	B_TeachFightTalentPercent(self, other, NPC_TALENT_BOW, 1, 100);
	DIA_Fun_LehreKAMPF_Menue();
};
func void DIA_Fun_LehreKAMPF_BOW5()
{
	B_TeachFightTalentPercent(self, other, NPC_TALENT_BOW, 5, 100);
	DIA_Fun_LehreKAMPF_Menue();
};
func void DIA_Fun_LehreKAMPF_CBOW1()
{
	B_TeachFightTalentPercent(self, other, NPC_TALENT_CROSSBOW, 1, 100);
	DIA_Fun_LehreKAMPF_Menue();
};
func void DIA_Fun_LehreKAMPF_CBOW5()
{
	B_TeachFightTalentPercent(self, other, NPC_TALENT_CROSSBOW, 5, 100);
	DIA_Fun_LehreKAMPF_Menue();
};
func void DIA_Fun_LehreKAMPF_Info()
{
	AI_Output(other, self, "DIA_Wolf_WannaLearn_15_00"); //Kannst du mir was beibringen?
	DIA_Fun_LehreKAMPF_Menue();
};

// --- Gilden: gleiche Gilde Freund, die vier Spielergilden untereinander Feind, Händler (GIL_NONE) neutral -------------
func void Fun_Gilden()
{
	Wld_SetGuildAttitude(GIL_MIL, ATT_FRIENDLY, GIL_MIL);
	Wld_SetGuildAttitude(GIL_MIL, ATT_HOSTILE, GIL_SLD);
	Wld_SetGuildAttitude(GIL_MIL, ATT_HOSTILE, GIL_NOV);
	Wld_SetGuildAttitude(GIL_MIL, ATT_HOSTILE, GIL_BDT);
	Wld_SetGuildAttitude(GIL_MIL, ATT_NEUTRAL, GIL_NONE);
	Wld_SetGuildAttitude(GIL_NONE, ATT_NEUTRAL, GIL_MIL);
	Wld_SetGuildAttitude(GIL_SLD, ATT_HOSTILE, GIL_MIL);
	Wld_SetGuildAttitude(GIL_SLD, ATT_FRIENDLY, GIL_SLD);
	Wld_SetGuildAttitude(GIL_SLD, ATT_HOSTILE, GIL_NOV);
	Wld_SetGuildAttitude(GIL_SLD, ATT_HOSTILE, GIL_BDT);
	Wld_SetGuildAttitude(GIL_SLD, ATT_NEUTRAL, GIL_NONE);
	Wld_SetGuildAttitude(GIL_NONE, ATT_NEUTRAL, GIL_SLD);
	Wld_SetGuildAttitude(GIL_NOV, ATT_HOSTILE, GIL_MIL);
	Wld_SetGuildAttitude(GIL_NOV, ATT_HOSTILE, GIL_SLD);
	Wld_SetGuildAttitude(GIL_NOV, ATT_FRIENDLY, GIL_NOV);
	Wld_SetGuildAttitude(GIL_NOV, ATT_HOSTILE, GIL_BDT);
	Wld_SetGuildAttitude(GIL_NOV, ATT_NEUTRAL, GIL_NONE);
	Wld_SetGuildAttitude(GIL_NONE, ATT_NEUTRAL, GIL_NOV);
	Wld_SetGuildAttitude(GIL_BDT, ATT_HOSTILE, GIL_MIL);
	Wld_SetGuildAttitude(GIL_BDT, ATT_HOSTILE, GIL_SLD);
	Wld_SetGuildAttitude(GIL_BDT, ATT_HOSTILE, GIL_NOV);
	Wld_SetGuildAttitude(GIL_BDT, ATT_FRIENDLY, GIL_BDT);
	Wld_SetGuildAttitude(GIL_BDT, ATT_NEUTRAL, GIL_NONE);
	Wld_SetGuildAttitude(GIL_NONE, ATT_NEUTRAL, GIL_BDT);
};

func int Fun_GildeVonWahl(var int wahl)
{
	if (wahl == 0)
	{
		return GIL_MIL;
	};
	if (wahl == 1)
	{
		return GIL_SLD;
	};
	if (wahl == 2)
	{
		return GIL_NOV;
	};
	if (wahl == 3)
	{
		return GIL_BDT;
	};
	return GIL_MIL;
};

// Held bekommt Gilde, Werte und Ausrüstung - einmal, solange er noch keine Gilde hat (FUN_TAKT_ALLE)
func void Fun_HeldStart(var int wahl)
{
	var int g;
	g = Fun_GildeVonWahl(wahl);
	hero.guild = g;
	Npc_SetTrueGuild(hero, g);
	if (hero.attribute[ATR_STRENGTH] < 30)
	{
		hero.attribute[ATR_STRENGTH] = 30;
	};
	if (hero.attribute[ATR_DEXTERITY] < 30)
	{
		hero.attribute[ATR_DEXTERITY] = 30;
	};
	if (hero.attribute[ATR_HITPOINTS_MAX] < 100)
	{
		hero.attribute[ATR_HITPOINTS_MAX] = 100;
	};
	hero.attribute[ATR_HITPOINTS] = hero.attribute[ATR_HITPOINTS_MAX];
	hero.lp = hero.lp + 10;
	if (hero.attribute[ATR_MANA_MAX] < 20)
	{
		hero.attribute[ATR_MANA_MAX] = 20;
	};
	hero.attribute[ATR_MANA] = hero.attribute[ATR_MANA_MAX];
	CreateInvItems(hero, ItPo_Mana_01, 3);
	PLAYER_TALENT_TAKEANIMALTROPHY[TROPHY_Teeth] = TRUE;
	PLAYER_TALENT_TAKEANIMALTROPHY[TROPHY_Claws] = TRUE;
	PLAYER_TALENT_TAKEANIMALTROPHY[TROPHY_Fur] = TRUE;
	PLAYER_TALENT_TAKEANIMALTROPHY[TROPHY_Heart] = TRUE;
	PLAYER_TALENT_TAKEANIMALTROPHY[TROPHY_ShadowHorn] = TRUE;
	PLAYER_TALENT_TAKEANIMALTROPHY[TROPHY_FireTongue] = TRUE;
	PLAYER_TALENT_TAKEANIMALTROPHY[TROPHY_BFWing] = TRUE;
	PLAYER_TALENT_TAKEANIMALTROPHY[TROPHY_BFSting] = TRUE;
	PLAYER_TALENT_TAKEANIMALTROPHY[TROPHY_Mandibles] = TRUE;
	PLAYER_TALENT_TAKEANIMALTROPHY[TROPHY_CrawlerPlate] = TRUE;
	PLAYER_TALENT_TAKEANIMALTROPHY[TROPHY_DrgSnapperHorn] = TRUE;
	PLAYER_TALENT_TAKEANIMALTROPHY[TROPHY_ReptileSkin] = TRUE;
	CreateInvItems(hero, ItMi_Gold, 200);
	CreateInvItems(hero, ItPo_Health_01, 5);
	CreateInvItems(hero, ItRu_TeleportTaverne, 1);
	if (wahl == 0)
	{
		CreateInvItem(hero, ITAR_MIL_L);
		AI_EquipArmor(hero, ITAR_MIL_L);
		CreateInvItem(hero, ItMw_ShortSword3);
		AI_EquipBestMeleeWeapon(hero);
		CreateInvItems(hero, ItRw_Bolt, 60);
		CreateInvItem(hero, ItRw_Crossbow_L_01);
		AI_EquipBestRangedWeapon(hero);
		CreateInvItems(hero, ItRu_TeleportSeaport, 1);
		AI_Teleport(hero, "NW_CITY_HABOUR_KASERN_CENTRE_01");
		Print("Fun-Modus: du gehörst zum Lager Kaserne in Khorinis.");
	};
	if (wahl == 1)
	{
		CreateInvItem(hero, ITAR_SLD_L);
		AI_EquipArmor(hero, ITAR_SLD_L);
		CreateInvItem(hero, ItMw_Nagelkeule);
		AI_EquipBestMeleeWeapon(hero);
		CreateInvItems(hero, ItRw_Arrow, 60);
		CreateInvItem(hero, ItRw_Bow_L_02);
		AI_EquipBestRangedWeapon(hero);
		CreateInvItems(hero, ItRu_TeleportFarm, 1);
		AI_Teleport(hero, "NW_BIGFARM_HOUSE_OUT_05");
		Print("Fun-Modus: du gehörst zum Lager Onars Hof.");
	};
	if (wahl == 2)
	{
		CreateInvItem(hero, ITAR_NOV_L);
		AI_EquipArmor(hero, ITAR_NOV_L);
		CreateInvItem(hero, ItMw_1h_Nov_Mace);
		AI_EquipBestMeleeWeapon(hero);
		if (hero.attribute[ATR_MANA_MAX] < 30)
		{
			hero.attribute[ATR_MANA_MAX] = 30;
		};
		hero.attribute[ATR_MANA] = hero.attribute[ATR_MANA_MAX];
		Npc_SetTalentSkill(hero, NPC_TALENT_MAGE, 1);
		CreateInvItems(hero, ItRu_FireBolt, 1);
		CreateInvItems(hero, ItPo_Mana_01, 5);
		CreateInvItems(hero, ItKe_Innos_MIS, 1);
		CreateInvItems(hero, ItRu_TeleportMonastery, 1);
		AI_Teleport(hero, "NW_MONASTERY_PLACE_03");
		Print("Fun-Modus: du gehörst zum Lager Kloster.");
	};
	if (wahl == 3)
	{
		CreateInvItem(hero, ITAR_BDT_M);
		AI_EquipArmor(hero, ITAR_BDT_M);
		CreateInvItem(hero, ItMw_ShortSword4);
		AI_EquipBestMeleeWeapon(hero);
		CreateInvItems(hero, ItRw_Arrow, 60);
		CreateInvItem(hero, ItRw_Bow_L_02);
		AI_EquipBestRangedWeapon(hero);
		AI_Teleport(hero, "NW_CASTLEMINE_TOWER_CAMPFIRE_01");
		Print("Fun-Modus: du gehörst zum Lager Banditenturm.");
	};
	Fun_Haltungen();
};

func void FUN_HELD_NACH_TOD()
{
	if (!FUN_AKTIV)
	{
		return;
	};
	hero.attribute[ATR_STRENGTH] = 30;
	hero.attribute[ATR_DEXTERITY] = 30;
	hero.aivar[REAL_STRENGTH] = 30;
	hero.aivar[REAL_DEXTERITY] = 30;
	hero.attribute[ATR_HITPOINTS_MAX] = 100;
	hero.attribute[ATR_HITPOINTS] = 100;
	hero.attribute[ATR_MANA_MAX] = 20;
	if (Npc_GetTrueGuild(hero) == GIL_NOV)
	{
		hero.attribute[ATR_MANA_MAX] = 30;
	};
	hero.aivar[REAL_MANA_MAX] = hero.attribute[ATR_MANA_MAX];
	hero.attribute[ATR_MANA] = hero.attribute[ATR_MANA_MAX];
	Print("Du bist gefallen - Stärke, Geschick, Leben und Mana sind wieder auf den Startwerten.");
};

func void B_Attack(var C_NPC slf, var C_NPC oth, var int attack_reason, var int wait)
{
	if (FUN_AKTIV)
	{
		if ((slf.guild < GIL_SEPERATOR_HUM) && (slf.guild != GIL_NONE) && (slf.guild == Npc_GetTrueGuild(oth)))
		{
			return;
		};
	};
	B_Attack_Old(slf, oth, attack_reason, wait);
};

func int C_PlayerIsFakeBandit(var C_NPC slf, var C_NPC oth)
{
	if (FUN_AKTIV)
	{
		if (Npc_GetTrueGuild(oth) == GIL_BDT)
		{
			return TRUE;
		};
	};
	return C_PlayerIsFakeBandit_Old(slf, oth);
};

// --- Start: keine Story, keine Story-NPCs, nur Lager, Händler, Begleiter, Monster und der Boss --------------------------
func void Fun_Startup()
{
	FUN_AKTIV = TRUE;
	FUN_KAPITEL = 1;
	Kapitel = 1;
	FUNL_KAPITEL_GESEHEN = 1;
	FUNL_BEGL_KAP = 1;
	Hero_HackChance = 10;
	Wld_InsertNpc(FUN_HAENDLER_MIL, "NW_CITY_HABOUR_KASERN_CENTRE_03");
	Wld_InsertNpc(FUN_HAENDLER_SLD, "NW_BIGFARM_HOUSE_08");
	Wld_InsertNpc(FUN_HAENDLER_NOV, "NW_MONASTERY_PLACE_07");
	Wld_InsertNpc(FUN_HAENDLER_BDT, "NW_CASTLEMINE_TOWER_CAMPFIRE_03");
	Wld_InsertNpc(FUN_MIL_1, "NW_CITY_HABOUR_KASERN_05_01");
	Wld_InsertNpc(FUN_MIL_2, "NW_CITY_HABOUR_KASERN_08");
	Wld_InsertNpc(FUN_MIL_3, "NW_CITY_HABOUR_KASERN_10");
	Wld_InsertNpc(FUN_MIL_4, "NW_CITY_HABOUR_KASERN_12");
	Wld_InsertNpc(FUN_MIL_5, "NW_CITY_HABOUR_KASERN_14");
	Wld_InsertNpc(FUN_SLD_1, "NW_BIGFARM_HOUSE_12");
	Wld_InsertNpc(FUN_SLD_2, "NW_BIGFARM_HOUSE_14");
	Wld_InsertNpc(FUN_SLD_3, "NW_BIGFARM_ALLEE_04");
	Wld_InsertNpc(FUN_SLD_4, "NW_BIGFARM_TREE");
	Wld_InsertNpc(FUN_SLD_5, "NW_BIGFARM_KITCHEN_09");
	Wld_InsertNpc(FUN_NOV_1, "NW_MONASTERY_PLACE_09");
	Wld_InsertNpc(FUN_NOV_2, "NW_MONASTERY_GRASS_01");
	Wld_InsertNpc(FUN_NOV_3, "NW_MONASTERY_HERB_05");
	Wld_InsertNpc(FUN_NOV_4, "NW_MONASTERY_CHURCH_03");
	Wld_InsertNpc(FUN_NOV_5, "NW_MONASTERY_CHAPELL_02");
	Wld_InsertNpc(FUN_BDT_1, "NW_CASTLEMINE_TOWER_CAMPFIRE_02");
	Wld_InsertNpc(FUN_BDT_2, "NW_CASTLEMINE_TOWER_CAMPFIRE_04");
	Wld_InsertNpc(FUN_BDT_3, "NW_CASTLEMINE_TOWER_STAND_01");
	Wld_InsertNpc(FUN_BDT_4, "NW_CASTLEMINE_TOWER_STAND_02");
	Wld_InsertNpc(FUN_BDT_5, "NW_CASTLEMINE_TOWER_REP_HUT");
	Wld_InsertNpc(FUN_M000_T1, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	Wld_InsertNpc(FUN_M001_T1, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	Wld_InsertNpc(FUN_M002_T1, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	Wld_InsertNpc(FUN_M003_T0, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	Wld_InsertNpc(FUN_M004_T0, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	Wld_InsertNpc(FUN_M005_T0, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	Wld_InsertNpc(FUN_M006_T2, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	Wld_InsertNpc(FUN_M007_T2, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	Wld_InsertNpc(FUN_M008_T2, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	Wld_InsertNpc(FUN_M009_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	Wld_InsertNpc(FUN_M010_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	Wld_InsertNpc(FUN_M011_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	Wld_InsertNpc(FUN_M012_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	Wld_InsertNpc(FUN_M013_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	Wld_InsertNpc(FUN_M014_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	Wld_InsertNpc(FUN_M015_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	Wld_InsertNpc(FUN_M016_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	Wld_InsertNpc(FUN_M017_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	Wld_InsertNpc(FUN_M018_T0, "FP_ROAM_RITUALFOREST_CAVE_05");
	Wld_InsertNpc(FUN_M019_T0, "FP_ROAM_RITUALFOREST_CAVE_05");
	Wld_InsertNpc(FUN_M020_T0, "FP_ROAM_RITUALFOREST_CAVE_05");
	Wld_InsertNpc(FUN_M021_T2, "FP_ROAM_RITUALFOREST_CAVE_07");
	Wld_InsertNpc(FUN_M022_T2, "FP_ROAM_RITUALFOREST_CAVE_07");
	Wld_InsertNpc(FUN_M023_T2, "FP_ROAM_RITUALFOREST_CAVE_07");
	Wld_InsertNpc(FUN_M024_T2, "FP_ROAM_RITUALFOREST_CAVE_08");
	Wld_InsertNpc(FUN_M025_T2, "FP_ROAM_RITUALFOREST_CAVE_08");
	Wld_InsertNpc(FUN_M026_T2, "FP_ROAM_RITUALFOREST_CAVE_08");
	Wld_InsertNpc(FUN_M027_T2, "FP_ROAM_RITUALFOREST_CAVE_09");
	Wld_InsertNpc(FUN_M028_T2, "FP_ROAM_RITUALFOREST_CAVE_09");
	Wld_InsertNpc(FUN_M029_T2, "FP_ROAM_RITUALFOREST_CAVE_09");
	Wld_InsertNpc(FUN_M030_T2, "FP_ROAM_RITUALFOREST_CAVE_11");
	Wld_InsertNpc(FUN_M031_T2, "FP_ROAM_RITUALFOREST_CAVE_11");
	Wld_InsertNpc(FUN_M032_T2, "FP_ROAM_RITUALFOREST_CAVE_11");
	Wld_InsertNpc(FUN_M033_T0, "FP_ROAM_TROLLAREA_SEA_01");
	Wld_InsertNpc(FUN_M034_T0, "FP_ROAM_TROLLAREA_SEA_01");
	Wld_InsertNpc(FUN_M035_T0, "FP_ROAM_TROLLAREA_SEA_01");
	Wld_InsertNpc(FUN_M036_T0, "FP_ROAM_TROLLAREA_SEA_02");
	Wld_InsertNpc(FUN_M037_T0, "FP_ROAM_TROLLAREA_SEA_02");
	Wld_InsertNpc(FUN_M038_T0, "FP_ROAM_TROLLAREA_SEA_02");
	Wld_InsertNpc(FUN_M039_T0, "FP_ROAM_TROLLAREA_SEA_03");
	Wld_InsertNpc(FUN_M040_T0, "FP_ROAM_TROLLAREA_SEA_03");
	Wld_InsertNpc(FUN_M041_T0, "FP_ROAM_TROLLAREA_SEA_03");
	Wld_InsertNpc(FUN_M042_T0, "FP_ROAM_TROLLAREA_SEA_04");
	Wld_InsertNpc(FUN_M043_T0, "FP_ROAM_TROLLAREA_SEA_04");
	Wld_InsertNpc(FUN_M044_T0, "FP_ROAM_TROLLAREA_SEA_04");
	Wld_InsertNpc(FUN_M045_T2, "NW_CRYPT_MONSTER02");
	Wld_InsertNpc(FUN_M046_T2, "NW_CRYPT_MONSTER02");
	Wld_InsertNpc(FUN_M047_T2, "NW_CRYPT_MONSTER02");
	Wld_InsertNpc(FUN_M048_T2, "NW_CRYPT_MONSTER04");
	Wld_InsertNpc(FUN_M049_T2, "NW_CRYPT_MONSTER04");
	Wld_InsertNpc(FUN_M050_T2, "NW_CRYPT_MONSTER04");
	Wld_InsertNpc(FUN_M051_T2, "NW_CRYPT_MONSTER06");
	Wld_InsertNpc(FUN_M052_T2, "NW_CRYPT_MONSTER06");
	Wld_InsertNpc(FUN_M053_T2, "NW_CRYPT_MONSTER06");
	Wld_InsertNpc(FUN_M054_T2, "NW_CRYPT_MONSTER08");
	Wld_InsertNpc(FUN_M055_T2, "NW_CRYPT_MONSTER08");
	Wld_InsertNpc(FUN_M056_T2, "NW_CRYPT_MONSTER08");
	Wld_InsertNpc(FUN_M057_T0, "NW_FARM3_BIGWOOD_02");
	Wld_InsertNpc(FUN_M058_T0, "NW_FARM3_BIGWOOD_02");
	Wld_InsertNpc(FUN_M059_T0, "NW_FARM3_BIGWOOD_02");
	Wld_InsertNpc(FUN_M060_T1, "NW_FARM3_BIGWOOD_03");
	Wld_InsertNpc(FUN_M061_T1, "NW_FARM3_BIGWOOD_03");
	Wld_InsertNpc(FUN_M062_T1, "NW_FARM3_BIGWOOD_03");
	Wld_InsertNpc(FUN_M063_T2, "NW_FARM3_MOUNTAINLAKE_03");
	Wld_InsertNpc(FUN_M064_T2, "NW_FARM3_MOUNTAINLAKE_03");
	Wld_InsertNpc(FUN_M065_T2, "NW_FARM3_MOUNTAINLAKE_03");
	Wld_InsertNpc(FUN_M066_T2, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	Wld_InsertNpc(FUN_M067_T2, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	Wld_InsertNpc(FUN_M068_T2, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	Wld_InsertNpc(FUN_M069_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	Wld_InsertNpc(FUN_M070_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	Wld_InsertNpc(FUN_M071_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	Wld_InsertNpc(FUN_M072_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	Wld_InsertNpc(FUN_M073_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	Wld_InsertNpc(FUN_M074_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	Wld_InsertNpc(FUN_M075_T2, "NW_FARM3_PATH_11_SMALLRIVER_04");
	Wld_InsertNpc(FUN_M076_T2, "NW_FARM3_PATH_11_SMALLRIVER_04");
	Wld_InsertNpc(FUN_M077_T2, "NW_FARM3_PATH_11_SMALLRIVER_04");
	Wld_InsertNpc(FUN_M078_T0, "NW_FARM3_PATH_11_SMALLRIVER_10");
	Wld_InsertNpc(FUN_M079_T0, "NW_FARM3_PATH_11_SMALLRIVER_10");
	Wld_InsertNpc(FUN_M080_T0, "NW_FARM3_PATH_11_SMALLRIVER_10");
	Wld_InsertNpc(FUN_M081_T2, "NW_FARM3_PATH_11_SMALLRIVER_20");
	Wld_InsertNpc(FUN_M082_T2, "NW_FARM3_PATH_11_SMALLRIVER_20");
	Wld_InsertNpc(FUN_M083_T2, "NW_FARM3_PATH_11_SMALLRIVER_20");
	Wld_InsertNpc(FUN_M084_T1, "NW_FARM3_PATH_12_MONSTER_01");
	Wld_InsertNpc(FUN_M085_T1, "NW_FARM3_PATH_12_MONSTER_01");
	Wld_InsertNpc(FUN_M086_T1, "NW_FARM3_PATH_12_MONSTER_01");
	Wld_InsertNpc(FUN_M087_T1, "NW_FARM4_WOOD_MONSTER_MORE_01");
	Wld_InsertNpc(FUN_M088_T1, "NW_FARM4_WOOD_MONSTER_MORE_01");
	Wld_InsertNpc(FUN_M089_T1, "NW_FARM4_WOOD_MONSTER_MORE_01");
	Wld_InsertNpc(FUN_M090_T2, "NW_FARM4_WOOD_MONSTER_MORE_02");
	Wld_InsertNpc(FUN_M091_T2, "NW_FARM4_WOOD_MONSTER_MORE_02");
	Wld_InsertNpc(FUN_M092_T2, "NW_FARM4_WOOD_MONSTER_MORE_02");
	Wld_InsertNpc(FUN_M093_T1, "NW_FARM4_WOOD_MONSTER_N_3");
	Wld_InsertNpc(FUN_M094_T1, "NW_FARM4_WOOD_MONSTER_N_3");
	Wld_InsertNpc(FUN_M095_T1, "NW_FARM4_WOOD_MONSTER_N_3");
	Wld_InsertNpc(FUN_M096_T0, "NW_FARM4_WOOD_NEARPEASANT2_10");
	Wld_InsertNpc(FUN_M097_T0, "NW_FARM4_WOOD_NEARPEASANT2_10");
	Wld_InsertNpc(FUN_M098_T0, "NW_FARM4_WOOD_NEARPEASANT2_10");
	Wld_InsertNpc(FUN_M099_T0, "NW_FARM4_WOOD_NEARPEASANT2_14");
	Wld_InsertNpc(FUN_M100_T0, "NW_FARM4_WOOD_NEARPEASANT2_14");
	Wld_InsertNpc(FUN_M101_T0, "NW_FARM4_WOOD_NEARPEASANT2_14");
	Wld_InsertNpc(FUN_M102_T1, "NW_FARM4_WOOD_NEARPEASANT2_8");
	Wld_InsertNpc(FUN_M103_T1, "NW_FARM4_WOOD_NEARPEASANT2_8");
	Wld_InsertNpc(FUN_M104_T1, "NW_FARM4_WOOD_NEARPEASANT2_8");
	Wld_InsertNpc(FUN_M105_T1, "NW_SAGITTA_MOREMONSTER_01");
	Wld_InsertNpc(FUN_M106_T1, "NW_SAGITTA_MOREMONSTER_01");
	Wld_InsertNpc(FUN_M107_T1, "NW_SAGITTA_MOREMONSTER_01");
	Wld_InsertNpc(FUN_M108_T1, "NW_SAGITTA_MOREMONSTER_03");
	Wld_InsertNpc(FUN_M109_T1, "NW_SAGITTA_MOREMONSTER_03");
	Wld_InsertNpc(FUN_M110_T1, "NW_SAGITTA_MOREMONSTER_03");
	Wld_InsertNpc(FUN_M111_T1, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	Wld_InsertNpc(FUN_M112_T1, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	Wld_InsertNpc(FUN_M113_T1, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	Wld_InsertNpc(FUN_M114_T0, "NW_TROLLAREA_BRIGDE_05");
	Wld_InsertNpc(FUN_M115_T0, "NW_TROLLAREA_BRIGDE_05");
	Wld_InsertNpc(FUN_M116_T0, "NW_TROLLAREA_BRIGDE_05");
	Wld_InsertNpc(FUN_M117_T2, "NW_TROLLAREA_PATH_08");
	Wld_InsertNpc(FUN_M118_T2, "NW_TROLLAREA_PATH_08");
	Wld_InsertNpc(FUN_M119_T2, "NW_TROLLAREA_PATH_08");
	Wld_InsertNpc(FUN_M120_T0, "NW_TROLLAREA_PATH_15_MONSTER");
	Wld_InsertNpc(FUN_M121_T0, "NW_TROLLAREA_PATH_15_MONSTER");
	Wld_InsertNpc(FUN_M122_T0, "NW_TROLLAREA_PATH_15_MONSTER");
	Wld_InsertNpc(FUN_M123_T0, "NW_TROLLAREA_PATH_38_MONSTER");
	Wld_InsertNpc(FUN_M124_T0, "NW_TROLLAREA_PATH_38_MONSTER");
	Wld_InsertNpc(FUN_M125_T0, "NW_TROLLAREA_PATH_38_MONSTER");
	Wld_InsertNpc(FUN_M126_T2, "NW_TROLLAREA_PATH_56");
	Wld_InsertNpc(FUN_M127_T2, "NW_TROLLAREA_PATH_56");
	Wld_InsertNpc(FUN_M128_T2, "NW_TROLLAREA_PATH_56");
	Wld_InsertNpc(FUN_M129_T2, "NW_TROLLAREA_PATH_71_MONSTER");
	Wld_InsertNpc(FUN_M130_T2, "NW_TROLLAREA_PATH_71_MONSTER");
	Wld_InsertNpc(FUN_M131_T2, "NW_TROLLAREA_PATH_71_MONSTER");
	Wld_InsertNpc(FUN_M132_T0, "NW_TROLLAREA_PATH_71_MONSTER2");
	Wld_InsertNpc(FUN_M133_T0, "NW_TROLLAREA_PATH_71_MONSTER2");
	Wld_InsertNpc(FUN_M134_T0, "NW_TROLLAREA_PATH_71_MONSTER2");
	Wld_InsertNpc(FUN_M135_T0, "NW_TROLLAREA_PLANE_04");
	Wld_InsertNpc(FUN_M136_T0, "NW_TROLLAREA_PLANE_04");
	Wld_InsertNpc(FUN_M137_T0, "NW_TROLLAREA_PLANE_04");
	Wld_InsertNpc(FUN_M138_T0, "NW_TROLLAREA_PLANE_07");
	Wld_InsertNpc(FUN_M139_T0, "NW_TROLLAREA_PLANE_07");
	Wld_InsertNpc(FUN_M140_T0, "NW_TROLLAREA_PLANE_07");
	Wld_InsertNpc(FUN_M141_T0, "NW_TROLLAREA_PORTALTEMPEL_06");
	Wld_InsertNpc(FUN_M142_T0, "NW_TROLLAREA_PORTALTEMPEL_06");
	Wld_InsertNpc(FUN_M143_T0, "NW_TROLLAREA_PORTALTEMPEL_06");
	Wld_InsertNpc(FUN_M144_T0, "NW_TROLLAREA_PORTALTEMPEL_08");
	Wld_InsertNpc(FUN_M145_T0, "NW_TROLLAREA_PORTALTEMPEL_08");
	Wld_InsertNpc(FUN_M146_T0, "NW_TROLLAREA_PORTALTEMPEL_08");
	Wld_InsertNpc(FUN_M147_T0, "NW_TROLLAREA_PORTALTEMPEL_09");
	Wld_InsertNpc(FUN_M148_T0, "NW_TROLLAREA_PORTALTEMPEL_09");
	Wld_InsertNpc(FUN_M149_T0, "NW_TROLLAREA_PORTALTEMPEL_09");
	Wld_InsertNpc(FUN_M150_T0, "NW_TROLLAREA_PORTALTEMPEL_12");
	Wld_InsertNpc(FUN_M151_T0, "NW_TROLLAREA_PORTALTEMPEL_12");
	Wld_InsertNpc(FUN_M152_T0, "NW_TROLLAREA_PORTALTEMPEL_12");
	Wld_InsertNpc(FUN_M153_T2, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	Wld_InsertNpc(FUN_M154_T2, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	Wld_InsertNpc(FUN_M155_T2, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	Wld_InsertNpc(FUN_M156_T2, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	Wld_InsertNpc(FUN_M157_T2, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	Wld_InsertNpc(FUN_M158_T2, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	Wld_InsertNpc(FUN_M159_T0, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	Wld_InsertNpc(FUN_M160_T0, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	Wld_InsertNpc(FUN_M161_T0, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	Wld_InsertNpc(FUN_M162_T0, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	Wld_InsertNpc(FUN_M163_T0, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	Wld_InsertNpc(FUN_M164_T0, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	Wld_InsertNpc(FUN_M165_T0, "NW_TROLLAREA_RITUALPATH_032");
	Wld_InsertNpc(FUN_M166_T0, "NW_TROLLAREA_RITUALPATH_032");
	Wld_InsertNpc(FUN_M167_T0, "NW_TROLLAREA_RITUALPATH_032");
	Wld_InsertNpc(FUN_M168_T0, "NW_TROLLAREA_RITUALPATH_04");
	Wld_InsertNpc(FUN_M169_T0, "NW_TROLLAREA_RITUALPATH_04");
	Wld_InsertNpc(FUN_M170_T0, "NW_TROLLAREA_RITUALPATH_04");
	Wld_InsertNpc(FUN_M171_T2, "NW_TROLLAREA_RITUAL_13");
	Wld_InsertNpc(FUN_M172_T2, "NW_TROLLAREA_RITUAL_13");
	Wld_InsertNpc(FUN_M173_T2, "NW_TROLLAREA_RITUAL_13");
	Wld_InsertNpc(FUN_M174_T2, "NW_TROLLAREA_RIVERSIDECAVE_02");
	Wld_InsertNpc(FUN_M175_T2, "NW_TROLLAREA_RIVERSIDECAVE_02");
	Wld_InsertNpc(FUN_M176_T2, "NW_TROLLAREA_RIVERSIDECAVE_02");
	Wld_InsertNpc(FUN_M177_T2, "NW_TROLLAREA_RIVERSIDECAVE_07");
	Wld_InsertNpc(FUN_M178_T2, "NW_TROLLAREA_RIVERSIDECAVE_07");
	Wld_InsertNpc(FUN_M179_T2, "NW_TROLLAREA_RIVERSIDECAVE_07");
	Wld_InsertNpc(FUN_M180_T2, "NW_TROLLAREA_RUINS_14");
	Wld_InsertNpc(FUN_M181_T2, "NW_TROLLAREA_RUINS_14");
	Wld_InsertNpc(FUN_M182_T2, "NW_TROLLAREA_RUINS_14");
	Wld_InsertNpc(FUN_M183_T0, "NW_TROLLAREA_RUINS_17");
	Wld_InsertNpc(FUN_M184_T0, "NW_TROLLAREA_RUINS_17");
	Wld_InsertNpc(FUN_M185_T0, "NW_TROLLAREA_RUINS_17");
	Wld_InsertNpc(FUN_M186_T2, "NW_TROLLAREA_RUINS_21");
	Wld_InsertNpc(FUN_M187_T2, "NW_TROLLAREA_RUINS_21");
	Wld_InsertNpc(FUN_M188_T2, "NW_TROLLAREA_RUINS_21");
	Wld_InsertNpc(FUN_M189_T2, "NW_TROLLAREA_RUINS_32");
	Wld_InsertNpc(FUN_M190_T2, "NW_TROLLAREA_RUINS_32");
	Wld_InsertNpc(FUN_M191_T2, "NW_TROLLAREA_RUINS_32");
	Wld_InsertNpc(FUN_M192_T0, "NW_TROLLAREA_TROLLLAKECAVE_02");
	Wld_InsertNpc(FUN_M193_T0, "NW_TROLLAREA_TROLLLAKECAVE_02");
	Wld_InsertNpc(FUN_M194_T0, "NW_TROLLAREA_TROLLLAKECAVE_02");
	Wld_InsertNpc(FUN_M195_T0, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	Wld_InsertNpc(FUN_M196_T0, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	Wld_InsertNpc(FUN_M197_T0, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	Wld_InsertNpc(FUN_M198_T2, "NW_TROLLAREA_TROLLLAKECAVE_08");
	Wld_InsertNpc(FUN_M199_T2, "NW_TROLLAREA_TROLLLAKECAVE_08");
	Wld_InsertNpc(FUN_M200_T2, "NW_TROLLAREA_TROLLLAKECAVE_08");
	Wld_InsertNpc(FUN_M201_T2, "NW_TROLLAREA_TROLLLAKECAVE_09");
	Wld_InsertNpc(FUN_M202_T2, "NW_TROLLAREA_TROLLLAKECAVE_09");
	Wld_InsertNpc(FUN_M203_T2, "NW_TROLLAREA_TROLLLAKECAVE_09");
	Wld_InsertNpc(FUN_M204_T2, "NW_TROLLAREA_TROLLROCKCAVE_03");
	Wld_InsertNpc(FUN_M205_T2, "NW_TROLLAREA_TROLLROCKCAVE_03");
	Wld_InsertNpc(FUN_M206_T2, "NW_TROLLAREA_TROLLROCKCAVE_03");
	Wld_InsertNpc(FUN_M207_T2, "NW_TROLLAREA_TROLLROCKCAVE_05");
	Wld_InsertNpc(FUN_M208_T2, "NW_TROLLAREA_TROLLROCKCAVE_05");
	Wld_InsertNpc(FUN_M209_T2, "NW_TROLLAREA_TROLLROCKCAVE_05");
	Wld_InsertNpc(FUN_BOSS_K1, "NW_TAVERNE_CROSS");
};

func void Fun_Init()
{
	B_InitMonsterAttitudes();
	Fun_Gilden();
	Fun_Haltungen();
};

FUNC VOID STARTUP_NewWorld()
{
	if (COOP_FUNMODUS())
	{
		Fun_Startup();
		return;
	};
	FUN_AKTIV = FALSE;
	STARTUP_NewWorld_Old();
};

FUNC VOID INIT_NewWorld()
{
	if (FUN_AKTIV)
	{
		Fun_Init();
		return;
	};
	INIT_NewWorld_Old();
};

// --- Takt (GothicCoop alle 10 s) -------------------------------------------------------------------------------------
var int FUNL_T000;
var int FUNL_T001;
var int FUNL_T002;
var int FUNL_T003;
var int FUNL_T004;
var int FUNL_T005;
var int FUNL_T006;
var int FUNL_T007;
var int FUNL_T008;
var int FUNL_T009;
var int FUNL_T010;
var int FUNL_T011;
var int FUNL_T012;
var int FUNL_T013;
var int FUNL_T014;
var int FUNL_T015;
var int FUNL_T016;
var int FUNL_T017;
var int FUNL_T018;
var int FUNL_T019;
var int FUNL_T020;
var int FUNL_T021;
var int FUNL_T022;
var int FUNL_T023;
var int FUNL_T024;
var int FUNL_T025;
var int FUNL_T026;
var int FUNL_T027;
var int FUNL_T028;
var int FUNL_T029;
var int FUNL_T030;
var int FUNL_T031;
var int FUNL_T032;
var int FUNL_T033;
var int FUNL_T034;
var int FUNL_T035;
var int FUNL_T036;
var int FUNL_T037;
var int FUNL_T038;
var int FUNL_T039;
var int FUNL_T040;
var int FUNL_T041;
var int FUNL_T042;
var int FUNL_T043;
var int FUNL_T044;
var int FUNL_T045;
var int FUNL_T046;
var int FUNL_T047;
var int FUNL_T048;
var int FUNL_T049;
var int FUNL_T050;
var int FUNL_T051;
var int FUNL_T052;
var int FUNL_T053;
var int FUNL_T054;
var int FUNL_T055;
var int FUNL_T056;
var int FUNL_T057;
var int FUNL_T058;
var int FUNL_T059;
var int FUNL_T060;
var int FUNL_T061;
var int FUNL_T062;
var int FUNL_T063;
var int FUNL_T064;
var int FUNL_T065;
var int FUNL_T066;
var int FUNL_T067;
var int FUNL_T068;
var int FUNL_T069;
var int FUNL_T070;
var int FUNL_T071;
var int FUNL_T072;
var int FUNL_T073;
var int FUNL_T074;
var int FUNL_T075;
var int FUNL_T076;
var int FUNL_T077;
var int FUNL_T078;
var int FUNL_T079;
var int FUNL_T080;
var int FUNL_T081;
var int FUNL_T082;
var int FUNL_T083;
var int FUNL_T084;
var int FUNL_T085;
var int FUNL_T086;
var int FUNL_T087;
var int FUNL_T088;
var int FUNL_T089;
var int FUNL_T090;
var int FUNL_T091;
var int FUNL_T092;
var int FUNL_T093;
var int FUNL_T094;
var int FUNL_T095;
var int FUNL_T096;
var int FUNL_T097;
var int FUNL_T098;
var int FUNL_T099;
var int FUNL_T100;
var int FUNL_T101;
var int FUNL_T102;
var int FUNL_T103;
var int FUNL_T104;
var int FUNL_T105;
var int FUNL_T106;
var int FUNL_T107;
var int FUNL_T108;
var int FUNL_T109;
var int FUNL_T110;
var int FUNL_T111;
var int FUNL_T112;
var int FUNL_T113;
var int FUNL_T114;
var int FUNL_T115;
var int FUNL_T116;
var int FUNL_T117;
var int FUNL_T118;
var int FUNL_T119;
var int FUNL_T120;
var int FUNL_T121;
var int FUNL_T122;
var int FUNL_T123;
var int FUNL_T124;
var int FUNL_T125;
var int FUNL_T126;
var int FUNL_T127;
var int FUNL_T128;
var int FUNL_T129;
var int FUNL_T130;
var int FUNL_T131;
var int FUNL_T132;
var int FUNL_T133;
var int FUNL_T134;
var int FUNL_T135;
var int FUNL_T136;
var int FUNL_T137;
var int FUNL_T138;
var int FUNL_T139;
var int FUNL_T140;
var int FUNL_T141;
var int FUNL_T142;
var int FUNL_T143;
var int FUNL_T144;
var int FUNL_T145;
var int FUNL_T146;
var int FUNL_T147;
var int FUNL_T148;
var int FUNL_T149;
var int FUNL_T150;
var int FUNL_T151;
var int FUNL_T152;
var int FUNL_T153;
var int FUNL_T154;
var int FUNL_T155;
var int FUNL_T156;
var int FUNL_T157;
var int FUNL_T158;
var int FUNL_T159;
var int FUNL_T160;
var int FUNL_T161;
var int FUNL_T162;
var int FUNL_T163;
var int FUNL_T164;
var int FUNL_T165;
var int FUNL_T166;
var int FUNL_T167;
var int FUNL_T168;
var int FUNL_T169;
var int FUNL_T170;
var int FUNL_T171;
var int FUNL_T172;
var int FUNL_T173;
var int FUNL_T174;
var int FUNL_T175;
var int FUNL_T176;
var int FUNL_T177;
var int FUNL_T178;
var int FUNL_T179;
var int FUNL_T180;
var int FUNL_T181;
var int FUNL_T182;
var int FUNL_T183;
var int FUNL_T184;
var int FUNL_T185;
var int FUNL_T186;
var int FUNL_T187;
var int FUNL_T188;
var int FUNL_T189;
var int FUNL_T190;
var int FUNL_T191;
var int FUNL_T192;
var int FUNL_T193;
var int FUNL_T194;
var int FUNL_T195;
var int FUNL_T196;
var int FUNL_T197;
var int FUNL_T198;
var int FUNL_T199;
var int FUNL_T200;
var int FUNL_T201;
var int FUNL_T202;
var int FUNL_T203;
var int FUNL_T204;
var int FUNL_T205;
var int FUNL_T206;
var int FUNL_T207;
var int FUNL_T208;
var int FUNL_T209;
var int FUNL_BEGL_T;

func void Fun_Platz000()   // FP_ROAM_NW_TROLLAREA_RUINS_01 (Original: Giant_Bug)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M000_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M000_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M000_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M000_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M000_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M000_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M000_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T000 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_01");
			};
			return;
		};
	};
	FUNL_T000 = FUNL_T000 + 1;
	if (FUNL_T000 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T000 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M000_T1, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M000_T2, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M000_T3, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M000_T4, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M000_T5, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M000_T6, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M000_T1, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	};
};
func void Fun_Platz001()   // FP_ROAM_NW_TROLLAREA_RUINS_01 (Original: Giant_Bug)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M001_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M001_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M001_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M001_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M001_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M001_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M001_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T001 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_01");
			};
			return;
		};
	};
	FUNL_T001 = FUNL_T001 + 1;
	if (FUNL_T001 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T001 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M001_T1, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M001_T2, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M001_T3, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M001_T4, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M001_T5, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M001_T6, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M001_T1, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	};
};
func void Fun_Platz002()   // FP_ROAM_NW_TROLLAREA_RUINS_01 (Original: Giant_Bug)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M002_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M002_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M002_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M002_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M002_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M002_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M002_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T002 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_01");
			};
			return;
		};
	};
	FUNL_T002 = FUNL_T002 + 1;
	if (FUNL_T002 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T002 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M002_T1, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M002_T2, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M002_T3, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M002_T4, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M002_T5, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M002_T6, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M002_T1, "FP_ROAM_NW_TROLLAREA_RUINS_01");
	};
};
func void Fun_Platz003()   // FP_ROAM_NW_TROLLAREA_RUINS_14 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M003_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M003_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M003_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M003_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M003_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M003_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M003_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T003 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_14");
			};
			return;
		};
	};
	FUNL_T003 = FUNL_T003 + 1;
	if (FUNL_T003 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T003 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M003_T0, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M003_T1, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M003_T2, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M003_T3, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M003_T4, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M003_T5, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else
	{
		Wld_InsertNpc(FUN_M003_T0, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	};
};
func void Fun_Platz004()   // FP_ROAM_NW_TROLLAREA_RUINS_14 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M004_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M004_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M004_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M004_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M004_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M004_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M004_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T004 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_14");
			};
			return;
		};
	};
	FUNL_T004 = FUNL_T004 + 1;
	if (FUNL_T004 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T004 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M004_T0, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M004_T1, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M004_T2, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M004_T3, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M004_T4, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M004_T5, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else
	{
		Wld_InsertNpc(FUN_M004_T0, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	};
};
func void Fun_Platz005()   // FP_ROAM_NW_TROLLAREA_RUINS_14 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M005_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M005_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M005_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M005_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M005_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M005_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M005_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T005 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_14");
			};
			return;
		};
	};
	FUNL_T005 = FUNL_T005 + 1;
	if (FUNL_T005 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T005 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M005_T0, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M005_T1, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M005_T2, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M005_T3, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M005_T4, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M005_T5, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else
	{
		Wld_InsertNpc(FUN_M005_T0, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	};
};
func void Fun_Platz006()   // FP_ROAM_NW_TROLLAREA_RUINS_28 (Original: Waran)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M006_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M006_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M006_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M006_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M006_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M006_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M006_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T006 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_28");
			};
			return;
		};
	};
	FUNL_T006 = FUNL_T006 + 1;
	if (FUNL_T006 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T006 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M006_T2, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M006_T3, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M006_T4, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M006_T5, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M006_T6, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M006_T7, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else
	{
		Wld_InsertNpc(FUN_M006_T2, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	};
};
func void Fun_Platz007()   // FP_ROAM_NW_TROLLAREA_RUINS_28 (Original: Waran)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M007_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M007_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M007_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M007_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M007_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M007_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M007_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T007 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_28");
			};
			return;
		};
	};
	FUNL_T007 = FUNL_T007 + 1;
	if (FUNL_T007 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T007 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M007_T2, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M007_T3, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M007_T4, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M007_T5, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M007_T6, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M007_T7, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else
	{
		Wld_InsertNpc(FUN_M007_T2, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	};
};
func void Fun_Platz008()   // FP_ROAM_NW_TROLLAREA_RUINS_28 (Original: Waran)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M008_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M008_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M008_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M008_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M008_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M008_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M008_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T008 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_28");
			};
			return;
		};
	};
	FUNL_T008 = FUNL_T008 + 1;
	if (FUNL_T008 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T008 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M008_T2, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M008_T3, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M008_T4, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M008_T5, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M008_T6, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M008_T7, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	}
	else
	{
		Wld_InsertNpc(FUN_M008_T2, "FP_ROAM_NW_TROLLAREA_RUINS_28");
	};
};
func void Fun_Platz009()   // FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03 (Original: Gobbo_Black)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M009_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M009_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M009_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M009_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M009_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M009_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M009_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T009 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
			};
			return;
		};
	};
	FUNL_T009 = FUNL_T009 + 1;
	if (FUNL_T009 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T009 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M009_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M009_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M009_T4, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M009_T5, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M009_T6, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M009_T7, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M009_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	};
};
func void Fun_Platz010()   // FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03 (Original: Gobbo_Black)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M010_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M010_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M010_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M010_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M010_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M010_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M010_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T010 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
			};
			return;
		};
	};
	FUNL_T010 = FUNL_T010 + 1;
	if (FUNL_T010 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T010 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M010_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M010_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M010_T4, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M010_T5, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M010_T6, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M010_T7, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M010_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	};
};
func void Fun_Platz011()   // FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03 (Original: Gobbo_Black)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M011_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M011_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M011_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M011_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M011_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M011_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M011_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T011 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
			};
			return;
		};
	};
	FUNL_T011 = FUNL_T011 + 1;
	if (FUNL_T011 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T011 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M011_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M011_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M011_T4, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M011_T5, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M011_T6, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M011_T7, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M011_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_03");
	};
};
func void Fun_Platz012()   // FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09 (Original: Gobbo_Black)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M012_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M012_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M012_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M012_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M012_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M012_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M012_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T012 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
			};
			return;
		};
	};
	FUNL_T012 = FUNL_T012 + 1;
	if (FUNL_T012 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T012 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M012_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M012_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M012_T4, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M012_T5, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M012_T6, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M012_T7, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else
	{
		Wld_InsertNpc(FUN_M012_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	};
};
func void Fun_Platz013()   // FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09 (Original: Gobbo_Black)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M013_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M013_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M013_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M013_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M013_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M013_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M013_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T013 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
			};
			return;
		};
	};
	FUNL_T013 = FUNL_T013 + 1;
	if (FUNL_T013 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T013 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M013_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M013_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M013_T4, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M013_T5, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M013_T6, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M013_T7, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else
	{
		Wld_InsertNpc(FUN_M013_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	};
};
func void Fun_Platz014()   // FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09 (Original: Gobbo_Black)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M014_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M014_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M014_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M014_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M014_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M014_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M014_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T014 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
			};
			return;
		};
	};
	FUNL_T014 = FUNL_T014 + 1;
	if (FUNL_T014 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T014 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M014_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M014_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M014_T4, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M014_T5, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M014_T6, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M014_T7, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	}
	else
	{
		Wld_InsertNpc(FUN_M014_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_09");
	};
};
func void Fun_Platz015()   // FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16 (Original: Minecrawler)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M015_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M015_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M015_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M015_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M015_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M015_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M015_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T015 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
			};
			return;
		};
	};
	FUNL_T015 = FUNL_T015 + 1;
	if (FUNL_T015 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T015 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M015_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M015_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M015_T4, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M015_T5, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M015_T6, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M015_T7, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else
	{
		Wld_InsertNpc(FUN_M015_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	};
};
func void Fun_Platz016()   // FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16 (Original: Minecrawler)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M016_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M016_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M016_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M016_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M016_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M016_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M016_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T016 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
			};
			return;
		};
	};
	FUNL_T016 = FUNL_T016 + 1;
	if (FUNL_T016 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T016 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M016_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M016_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M016_T4, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M016_T5, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M016_T6, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M016_T7, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else
	{
		Wld_InsertNpc(FUN_M016_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	};
};
func void Fun_Platz017()   // FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16 (Original: Minecrawler)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M017_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M017_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M017_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M017_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M017_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M017_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M017_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T017 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
			};
			return;
		};
	};
	FUNL_T017 = FUNL_T017 + 1;
	if (FUNL_T017 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T017 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M017_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M017_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M017_T4, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M017_T5, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M017_T6, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M017_T7, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	}
	else
	{
		Wld_InsertNpc(FUN_M017_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_16");
	};
};
func void Fun_Platz018()   // FP_ROAM_RITUALFOREST_CAVE_05 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M018_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M018_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M018_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M018_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M018_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M018_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M018_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T018 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_RITUALFOREST_CAVE_05");
			};
			return;
		};
	};
	FUNL_T018 = FUNL_T018 + 1;
	if (FUNL_T018 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T018 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M018_T0, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M018_T1, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M018_T2, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M018_T3, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M018_T4, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M018_T5, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else
	{
		Wld_InsertNpc(FUN_M018_T0, "FP_ROAM_RITUALFOREST_CAVE_05");
	};
};
func void Fun_Platz019()   // FP_ROAM_RITUALFOREST_CAVE_05 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M019_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M019_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M019_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M019_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M019_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M019_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M019_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T019 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_RITUALFOREST_CAVE_05");
			};
			return;
		};
	};
	FUNL_T019 = FUNL_T019 + 1;
	if (FUNL_T019 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T019 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M019_T0, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M019_T1, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M019_T2, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M019_T3, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M019_T4, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M019_T5, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else
	{
		Wld_InsertNpc(FUN_M019_T0, "FP_ROAM_RITUALFOREST_CAVE_05");
	};
};
func void Fun_Platz020()   // FP_ROAM_RITUALFOREST_CAVE_05 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M020_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M020_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M020_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M020_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M020_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M020_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M020_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T020 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_RITUALFOREST_CAVE_05");
			};
			return;
		};
	};
	FUNL_T020 = FUNL_T020 + 1;
	if (FUNL_T020 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T020 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M020_T0, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M020_T1, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M020_T2, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M020_T3, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M020_T4, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M020_T5, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else
	{
		Wld_InsertNpc(FUN_M020_T0, "FP_ROAM_RITUALFOREST_CAVE_05");
	};
};
func void Fun_Platz021()   // FP_ROAM_RITUALFOREST_CAVE_07 (Original: MinecrawlerWarrior)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M021_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M021_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M021_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M021_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M021_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M021_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M021_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T021 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_RITUALFOREST_CAVE_07");
			};
			return;
		};
	};
	FUNL_T021 = FUNL_T021 + 1;
	if (FUNL_T021 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T021 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M021_T2, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M021_T3, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M021_T4, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M021_T5, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M021_T6, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M021_T7, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else
	{
		Wld_InsertNpc(FUN_M021_T2, "FP_ROAM_RITUALFOREST_CAVE_07");
	};
};
func void Fun_Platz022()   // FP_ROAM_RITUALFOREST_CAVE_07 (Original: MinecrawlerWarrior)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M022_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M022_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M022_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M022_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M022_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M022_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M022_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T022 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_RITUALFOREST_CAVE_07");
			};
			return;
		};
	};
	FUNL_T022 = FUNL_T022 + 1;
	if (FUNL_T022 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T022 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M022_T2, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M022_T3, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M022_T4, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M022_T5, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M022_T6, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M022_T7, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else
	{
		Wld_InsertNpc(FUN_M022_T2, "FP_ROAM_RITUALFOREST_CAVE_07");
	};
};
func void Fun_Platz023()   // FP_ROAM_RITUALFOREST_CAVE_07 (Original: MinecrawlerWarrior)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M023_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M023_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M023_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M023_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M023_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M023_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M023_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T023 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_RITUALFOREST_CAVE_07");
			};
			return;
		};
	};
	FUNL_T023 = FUNL_T023 + 1;
	if (FUNL_T023 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T023 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M023_T2, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M023_T3, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M023_T4, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M023_T5, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M023_T6, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M023_T7, "FP_ROAM_RITUALFOREST_CAVE_07");
	}
	else
	{
		Wld_InsertNpc(FUN_M023_T2, "FP_ROAM_RITUALFOREST_CAVE_07");
	};
};
func void Fun_Platz024()   // FP_ROAM_RITUALFOREST_CAVE_08 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M024_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M024_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M024_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M024_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M024_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M024_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M024_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T024 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_RITUALFOREST_CAVE_08");
			};
			return;
		};
	};
	FUNL_T024 = FUNL_T024 + 1;
	if (FUNL_T024 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T024 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M024_T2, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M024_T3, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M024_T4, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M024_T5, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M024_T6, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M024_T7, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else
	{
		Wld_InsertNpc(FUN_M024_T2, "FP_ROAM_RITUALFOREST_CAVE_08");
	};
};
func void Fun_Platz025()   // FP_ROAM_RITUALFOREST_CAVE_08 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M025_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M025_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M025_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M025_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M025_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M025_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M025_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T025 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_RITUALFOREST_CAVE_08");
			};
			return;
		};
	};
	FUNL_T025 = FUNL_T025 + 1;
	if (FUNL_T025 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T025 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M025_T2, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M025_T3, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M025_T4, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M025_T5, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M025_T6, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M025_T7, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else
	{
		Wld_InsertNpc(FUN_M025_T2, "FP_ROAM_RITUALFOREST_CAVE_08");
	};
};
func void Fun_Platz026()   // FP_ROAM_RITUALFOREST_CAVE_08 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M026_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M026_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M026_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M026_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M026_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M026_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M026_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T026 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_RITUALFOREST_CAVE_08");
			};
			return;
		};
	};
	FUNL_T026 = FUNL_T026 + 1;
	if (FUNL_T026 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T026 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M026_T2, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M026_T3, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M026_T4, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M026_T5, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M026_T6, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M026_T7, "FP_ROAM_RITUALFOREST_CAVE_08");
	}
	else
	{
		Wld_InsertNpc(FUN_M026_T2, "FP_ROAM_RITUALFOREST_CAVE_08");
	};
};
func void Fun_Platz027()   // FP_ROAM_RITUALFOREST_CAVE_09 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M027_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M027_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M027_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M027_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M027_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M027_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M027_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T027 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_RITUALFOREST_CAVE_09");
			};
			return;
		};
	};
	FUNL_T027 = FUNL_T027 + 1;
	if (FUNL_T027 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T027 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M027_T2, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M027_T3, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M027_T4, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M027_T5, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M027_T6, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M027_T7, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else
	{
		Wld_InsertNpc(FUN_M027_T2, "FP_ROAM_RITUALFOREST_CAVE_09");
	};
};
func void Fun_Platz028()   // FP_ROAM_RITUALFOREST_CAVE_09 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M028_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M028_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M028_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M028_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M028_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M028_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M028_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T028 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_RITUALFOREST_CAVE_09");
			};
			return;
		};
	};
	FUNL_T028 = FUNL_T028 + 1;
	if (FUNL_T028 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T028 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M028_T2, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M028_T3, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M028_T4, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M028_T5, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M028_T6, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M028_T7, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else
	{
		Wld_InsertNpc(FUN_M028_T2, "FP_ROAM_RITUALFOREST_CAVE_09");
	};
};
func void Fun_Platz029()   // FP_ROAM_RITUALFOREST_CAVE_09 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M029_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M029_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M029_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M029_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M029_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M029_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M029_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T029 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_RITUALFOREST_CAVE_09");
			};
			return;
		};
	};
	FUNL_T029 = FUNL_T029 + 1;
	if (FUNL_T029 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T029 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M029_T2, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M029_T3, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M029_T4, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M029_T5, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M029_T6, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M029_T7, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else
	{
		Wld_InsertNpc(FUN_M029_T2, "FP_ROAM_RITUALFOREST_CAVE_09");
	};
};
func void Fun_Platz030()   // FP_ROAM_RITUALFOREST_CAVE_11 (Original: MinecrawlerWarrior)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M030_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M030_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M030_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M030_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M030_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M030_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M030_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T030 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_RITUALFOREST_CAVE_11");
			};
			return;
		};
	};
	FUNL_T030 = FUNL_T030 + 1;
	if (FUNL_T030 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T030 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M030_T2, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M030_T3, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M030_T4, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M030_T5, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M030_T6, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M030_T7, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else
	{
		Wld_InsertNpc(FUN_M030_T2, "FP_ROAM_RITUALFOREST_CAVE_11");
	};
};
func void Fun_Platz031()   // FP_ROAM_RITUALFOREST_CAVE_11 (Original: MinecrawlerWarrior)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M031_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M031_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M031_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M031_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M031_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M031_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M031_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T031 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_RITUALFOREST_CAVE_11");
			};
			return;
		};
	};
	FUNL_T031 = FUNL_T031 + 1;
	if (FUNL_T031 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T031 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M031_T2, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M031_T3, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M031_T4, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M031_T5, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M031_T6, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M031_T7, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else
	{
		Wld_InsertNpc(FUN_M031_T2, "FP_ROAM_RITUALFOREST_CAVE_11");
	};
};
func void Fun_Platz032()   // FP_ROAM_RITUALFOREST_CAVE_11 (Original: MinecrawlerWarrior)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M032_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M032_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M032_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M032_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M032_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M032_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M032_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T032 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_RITUALFOREST_CAVE_11");
			};
			return;
		};
	};
	FUNL_T032 = FUNL_T032 + 1;
	if (FUNL_T032 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T032 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M032_T2, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M032_T3, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M032_T4, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M032_T5, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M032_T6, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M032_T7, "FP_ROAM_RITUALFOREST_CAVE_11");
	}
	else
	{
		Wld_InsertNpc(FUN_M032_T2, "FP_ROAM_RITUALFOREST_CAVE_11");
	};
};
func void Fun_Platz033()   // FP_ROAM_TROLLAREA_SEA_01 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M033_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M033_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M033_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M033_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M033_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M033_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M033_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T033 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_TROLLAREA_SEA_01");
			};
			return;
		};
	};
	FUNL_T033 = FUNL_T033 + 1;
	if (FUNL_T033 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T033 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M033_T0, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M033_T1, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M033_T2, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M033_T3, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M033_T4, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M033_T5, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M033_T0, "FP_ROAM_TROLLAREA_SEA_01");
	};
};
func void Fun_Platz034()   // FP_ROAM_TROLLAREA_SEA_01 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M034_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M034_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M034_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M034_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M034_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M034_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M034_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T034 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_TROLLAREA_SEA_01");
			};
			return;
		};
	};
	FUNL_T034 = FUNL_T034 + 1;
	if (FUNL_T034 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T034 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M034_T0, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M034_T1, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M034_T2, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M034_T3, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M034_T4, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M034_T5, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M034_T0, "FP_ROAM_TROLLAREA_SEA_01");
	};
};
func void Fun_Platz035()   // FP_ROAM_TROLLAREA_SEA_01 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M035_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M035_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M035_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M035_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M035_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M035_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M035_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T035 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_TROLLAREA_SEA_01");
			};
			return;
		};
	};
	FUNL_T035 = FUNL_T035 + 1;
	if (FUNL_T035 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T035 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M035_T0, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M035_T1, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M035_T2, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M035_T3, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M035_T4, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M035_T5, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M035_T0, "FP_ROAM_TROLLAREA_SEA_01");
	};
};
func void Fun_Platz036()   // FP_ROAM_TROLLAREA_SEA_02 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M036_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M036_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M036_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M036_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M036_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M036_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M036_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T036 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_TROLLAREA_SEA_02");
			};
			return;
		};
	};
	FUNL_T036 = FUNL_T036 + 1;
	if (FUNL_T036 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T036 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M036_T0, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M036_T1, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M036_T2, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M036_T3, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M036_T4, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M036_T5, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M036_T0, "FP_ROAM_TROLLAREA_SEA_02");
	};
};
func void Fun_Platz037()   // FP_ROAM_TROLLAREA_SEA_02 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M037_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M037_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M037_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M037_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M037_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M037_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M037_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T037 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_TROLLAREA_SEA_02");
			};
			return;
		};
	};
	FUNL_T037 = FUNL_T037 + 1;
	if (FUNL_T037 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T037 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M037_T0, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M037_T1, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M037_T2, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M037_T3, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M037_T4, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M037_T5, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M037_T0, "FP_ROAM_TROLLAREA_SEA_02");
	};
};
func void Fun_Platz038()   // FP_ROAM_TROLLAREA_SEA_02 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M038_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M038_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M038_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M038_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M038_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M038_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M038_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T038 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_TROLLAREA_SEA_02");
			};
			return;
		};
	};
	FUNL_T038 = FUNL_T038 + 1;
	if (FUNL_T038 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T038 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M038_T0, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M038_T1, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M038_T2, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M038_T3, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M038_T4, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M038_T5, "FP_ROAM_TROLLAREA_SEA_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M038_T0, "FP_ROAM_TROLLAREA_SEA_02");
	};
};
func void Fun_Platz039()   // FP_ROAM_TROLLAREA_SEA_03 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M039_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M039_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M039_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M039_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M039_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M039_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M039_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T039 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_TROLLAREA_SEA_03");
			};
			return;
		};
	};
	FUNL_T039 = FUNL_T039 + 1;
	if (FUNL_T039 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T039 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M039_T0, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M039_T1, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M039_T2, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M039_T3, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M039_T4, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M039_T5, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M039_T0, "FP_ROAM_TROLLAREA_SEA_03");
	};
};
func void Fun_Platz040()   // FP_ROAM_TROLLAREA_SEA_03 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M040_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M040_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M040_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M040_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M040_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M040_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M040_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T040 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_TROLLAREA_SEA_03");
			};
			return;
		};
	};
	FUNL_T040 = FUNL_T040 + 1;
	if (FUNL_T040 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T040 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M040_T0, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M040_T1, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M040_T2, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M040_T3, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M040_T4, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M040_T5, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M040_T0, "FP_ROAM_TROLLAREA_SEA_03");
	};
};
func void Fun_Platz041()   // FP_ROAM_TROLLAREA_SEA_03 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M041_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M041_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M041_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M041_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M041_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M041_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M041_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T041 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_TROLLAREA_SEA_03");
			};
			return;
		};
	};
	FUNL_T041 = FUNL_T041 + 1;
	if (FUNL_T041 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T041 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M041_T0, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M041_T1, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M041_T2, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M041_T3, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M041_T4, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M041_T5, "FP_ROAM_TROLLAREA_SEA_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M041_T0, "FP_ROAM_TROLLAREA_SEA_03");
	};
};
func void Fun_Platz042()   // FP_ROAM_TROLLAREA_SEA_04 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M042_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M042_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M042_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M042_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M042_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M042_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M042_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T042 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_TROLLAREA_SEA_04");
			};
			return;
		};
	};
	FUNL_T042 = FUNL_T042 + 1;
	if (FUNL_T042 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T042 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M042_T0, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M042_T1, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M042_T2, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M042_T3, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M042_T4, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M042_T5, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M042_T0, "FP_ROAM_TROLLAREA_SEA_04");
	};
};
func void Fun_Platz043()   // FP_ROAM_TROLLAREA_SEA_04 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M043_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M043_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M043_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M043_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M043_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M043_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M043_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T043 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_TROLLAREA_SEA_04");
			};
			return;
		};
	};
	FUNL_T043 = FUNL_T043 + 1;
	if (FUNL_T043 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T043 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M043_T0, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M043_T1, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M043_T2, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M043_T3, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M043_T4, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M043_T5, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M043_T0, "FP_ROAM_TROLLAREA_SEA_04");
	};
};
func void Fun_Platz044()   // FP_ROAM_TROLLAREA_SEA_04 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M044_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M044_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M044_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M044_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M044_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M044_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M044_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T044 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "FP_ROAM_TROLLAREA_SEA_04");
			};
			return;
		};
	};
	FUNL_T044 = FUNL_T044 + 1;
	if (FUNL_T044 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T044 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M044_T0, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M044_T1, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M044_T2, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M044_T3, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M044_T4, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M044_T5, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M044_T0, "FP_ROAM_TROLLAREA_SEA_04");
	};
};
func void Fun_Platz045()   // NW_CRYPT_MONSTER02 (Original: Gobbo_skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M045_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M045_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M045_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M045_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M045_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M045_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M045_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T045 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_CRYPT_MONSTER02");
			};
			return;
		};
	};
	FUNL_T045 = FUNL_T045 + 1;
	if (FUNL_T045 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T045 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M045_T2, "NW_CRYPT_MONSTER02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M045_T3, "NW_CRYPT_MONSTER02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M045_T4, "NW_CRYPT_MONSTER02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M045_T5, "NW_CRYPT_MONSTER02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M045_T6, "NW_CRYPT_MONSTER02");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M045_T7, "NW_CRYPT_MONSTER02");
	}
	else
	{
		Wld_InsertNpc(FUN_M045_T2, "NW_CRYPT_MONSTER02");
	};
};
func void Fun_Platz046()   // NW_CRYPT_MONSTER02 (Original: Gobbo_skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M046_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M046_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M046_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M046_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M046_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M046_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M046_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T046 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_CRYPT_MONSTER02");
			};
			return;
		};
	};
	FUNL_T046 = FUNL_T046 + 1;
	if (FUNL_T046 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T046 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M046_T2, "NW_CRYPT_MONSTER02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M046_T3, "NW_CRYPT_MONSTER02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M046_T4, "NW_CRYPT_MONSTER02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M046_T5, "NW_CRYPT_MONSTER02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M046_T6, "NW_CRYPT_MONSTER02");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M046_T7, "NW_CRYPT_MONSTER02");
	}
	else
	{
		Wld_InsertNpc(FUN_M046_T2, "NW_CRYPT_MONSTER02");
	};
};
func void Fun_Platz047()   // NW_CRYPT_MONSTER02 (Original: Gobbo_skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M047_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M047_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M047_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M047_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M047_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M047_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M047_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T047 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_CRYPT_MONSTER02");
			};
			return;
		};
	};
	FUNL_T047 = FUNL_T047 + 1;
	if (FUNL_T047 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T047 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M047_T2, "NW_CRYPT_MONSTER02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M047_T3, "NW_CRYPT_MONSTER02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M047_T4, "NW_CRYPT_MONSTER02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M047_T5, "NW_CRYPT_MONSTER02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M047_T6, "NW_CRYPT_MONSTER02");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M047_T7, "NW_CRYPT_MONSTER02");
	}
	else
	{
		Wld_InsertNpc(FUN_M047_T2, "NW_CRYPT_MONSTER02");
	};
};
func void Fun_Platz048()   // NW_CRYPT_MONSTER04 (Original: Lesser_skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M048_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M048_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M048_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M048_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M048_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M048_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M048_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T048 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_CRYPT_MONSTER04");
			};
			return;
		};
	};
	FUNL_T048 = FUNL_T048 + 1;
	if (FUNL_T048 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T048 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M048_T2, "NW_CRYPT_MONSTER04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M048_T3, "NW_CRYPT_MONSTER04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M048_T4, "NW_CRYPT_MONSTER04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M048_T5, "NW_CRYPT_MONSTER04");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M048_T6, "NW_CRYPT_MONSTER04");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M048_T7, "NW_CRYPT_MONSTER04");
	}
	else
	{
		Wld_InsertNpc(FUN_M048_T2, "NW_CRYPT_MONSTER04");
	};
};
func void Fun_Platz049()   // NW_CRYPT_MONSTER04 (Original: Lesser_skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M049_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M049_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M049_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M049_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M049_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M049_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M049_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T049 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_CRYPT_MONSTER04");
			};
			return;
		};
	};
	FUNL_T049 = FUNL_T049 + 1;
	if (FUNL_T049 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T049 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M049_T2, "NW_CRYPT_MONSTER04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M049_T3, "NW_CRYPT_MONSTER04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M049_T4, "NW_CRYPT_MONSTER04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M049_T5, "NW_CRYPT_MONSTER04");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M049_T6, "NW_CRYPT_MONSTER04");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M049_T7, "NW_CRYPT_MONSTER04");
	}
	else
	{
		Wld_InsertNpc(FUN_M049_T2, "NW_CRYPT_MONSTER04");
	};
};
func void Fun_Platz050()   // NW_CRYPT_MONSTER04 (Original: Lesser_skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M050_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M050_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M050_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M050_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M050_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M050_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M050_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T050 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_CRYPT_MONSTER04");
			};
			return;
		};
	};
	FUNL_T050 = FUNL_T050 + 1;
	if (FUNL_T050 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T050 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M050_T2, "NW_CRYPT_MONSTER04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M050_T3, "NW_CRYPT_MONSTER04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M050_T4, "NW_CRYPT_MONSTER04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M050_T5, "NW_CRYPT_MONSTER04");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M050_T6, "NW_CRYPT_MONSTER04");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M050_T7, "NW_CRYPT_MONSTER04");
	}
	else
	{
		Wld_InsertNpc(FUN_M050_T2, "NW_CRYPT_MONSTER04");
	};
};
func void Fun_Platz051()   // NW_CRYPT_MONSTER06 (Original: Lesser_skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M051_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M051_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M051_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M051_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M051_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M051_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M051_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T051 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_CRYPT_MONSTER06");
			};
			return;
		};
	};
	FUNL_T051 = FUNL_T051 + 1;
	if (FUNL_T051 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T051 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M051_T2, "NW_CRYPT_MONSTER06");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M051_T3, "NW_CRYPT_MONSTER06");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M051_T4, "NW_CRYPT_MONSTER06");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M051_T5, "NW_CRYPT_MONSTER06");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M051_T6, "NW_CRYPT_MONSTER06");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M051_T7, "NW_CRYPT_MONSTER06");
	}
	else
	{
		Wld_InsertNpc(FUN_M051_T2, "NW_CRYPT_MONSTER06");
	};
};
func void Fun_Platz052()   // NW_CRYPT_MONSTER06 (Original: Lesser_skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M052_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M052_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M052_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M052_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M052_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M052_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M052_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T052 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_CRYPT_MONSTER06");
			};
			return;
		};
	};
	FUNL_T052 = FUNL_T052 + 1;
	if (FUNL_T052 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T052 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M052_T2, "NW_CRYPT_MONSTER06");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M052_T3, "NW_CRYPT_MONSTER06");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M052_T4, "NW_CRYPT_MONSTER06");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M052_T5, "NW_CRYPT_MONSTER06");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M052_T6, "NW_CRYPT_MONSTER06");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M052_T7, "NW_CRYPT_MONSTER06");
	}
	else
	{
		Wld_InsertNpc(FUN_M052_T2, "NW_CRYPT_MONSTER06");
	};
};
func void Fun_Platz053()   // NW_CRYPT_MONSTER06 (Original: Lesser_skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M053_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M053_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M053_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M053_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M053_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M053_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M053_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T053 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_CRYPT_MONSTER06");
			};
			return;
		};
	};
	FUNL_T053 = FUNL_T053 + 1;
	if (FUNL_T053 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T053 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M053_T2, "NW_CRYPT_MONSTER06");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M053_T3, "NW_CRYPT_MONSTER06");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M053_T4, "NW_CRYPT_MONSTER06");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M053_T5, "NW_CRYPT_MONSTER06");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M053_T6, "NW_CRYPT_MONSTER06");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M053_T7, "NW_CRYPT_MONSTER06");
	}
	else
	{
		Wld_InsertNpc(FUN_M053_T2, "NW_CRYPT_MONSTER06");
	};
};
func void Fun_Platz054()   // NW_CRYPT_MONSTER08 (Original: Gobbo_skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M054_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M054_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M054_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M054_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M054_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M054_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M054_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T054 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_CRYPT_MONSTER08");
			};
			return;
		};
	};
	FUNL_T054 = FUNL_T054 + 1;
	if (FUNL_T054 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T054 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M054_T2, "NW_CRYPT_MONSTER08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M054_T3, "NW_CRYPT_MONSTER08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M054_T4, "NW_CRYPT_MONSTER08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M054_T5, "NW_CRYPT_MONSTER08");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M054_T6, "NW_CRYPT_MONSTER08");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M054_T7, "NW_CRYPT_MONSTER08");
	}
	else
	{
		Wld_InsertNpc(FUN_M054_T2, "NW_CRYPT_MONSTER08");
	};
};
func void Fun_Platz055()   // NW_CRYPT_MONSTER08 (Original: Gobbo_skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M055_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M055_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M055_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M055_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M055_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M055_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M055_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T055 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_CRYPT_MONSTER08");
			};
			return;
		};
	};
	FUNL_T055 = FUNL_T055 + 1;
	if (FUNL_T055 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T055 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M055_T2, "NW_CRYPT_MONSTER08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M055_T3, "NW_CRYPT_MONSTER08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M055_T4, "NW_CRYPT_MONSTER08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M055_T5, "NW_CRYPT_MONSTER08");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M055_T6, "NW_CRYPT_MONSTER08");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M055_T7, "NW_CRYPT_MONSTER08");
	}
	else
	{
		Wld_InsertNpc(FUN_M055_T2, "NW_CRYPT_MONSTER08");
	};
};
func void Fun_Platz056()   // NW_CRYPT_MONSTER08 (Original: Gobbo_skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M056_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M056_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M056_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M056_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M056_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M056_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M056_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T056 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_CRYPT_MONSTER08");
			};
			return;
		};
	};
	FUNL_T056 = FUNL_T056 + 1;
	if (FUNL_T056 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T056 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M056_T2, "NW_CRYPT_MONSTER08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M056_T3, "NW_CRYPT_MONSTER08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M056_T4, "NW_CRYPT_MONSTER08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M056_T5, "NW_CRYPT_MONSTER08");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M056_T6, "NW_CRYPT_MONSTER08");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M056_T7, "NW_CRYPT_MONSTER08");
	}
	else
	{
		Wld_InsertNpc(FUN_M056_T2, "NW_CRYPT_MONSTER08");
	};
};
func void Fun_Platz057()   // NW_FARM3_BIGWOOD_02 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M057_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M057_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M057_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M057_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M057_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M057_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M057_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T057 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_BIGWOOD_02");
			};
			return;
		};
	};
	FUNL_T057 = FUNL_T057 + 1;
	if (FUNL_T057 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T057 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M057_T0, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M057_T1, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M057_T2, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M057_T3, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M057_T4, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M057_T5, "NW_FARM3_BIGWOOD_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M057_T0, "NW_FARM3_BIGWOOD_02");
	};
};
func void Fun_Platz058()   // NW_FARM3_BIGWOOD_02 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M058_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M058_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M058_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M058_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M058_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M058_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M058_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T058 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_BIGWOOD_02");
			};
			return;
		};
	};
	FUNL_T058 = FUNL_T058 + 1;
	if (FUNL_T058 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T058 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M058_T0, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M058_T1, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M058_T2, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M058_T3, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M058_T4, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M058_T5, "NW_FARM3_BIGWOOD_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M058_T0, "NW_FARM3_BIGWOOD_02");
	};
};
func void Fun_Platz059()   // NW_FARM3_BIGWOOD_02 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M059_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M059_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M059_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M059_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M059_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M059_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M059_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T059 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_BIGWOOD_02");
			};
			return;
		};
	};
	FUNL_T059 = FUNL_T059 + 1;
	if (FUNL_T059 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T059 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M059_T0, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M059_T1, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M059_T2, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M059_T3, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M059_T4, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M059_T5, "NW_FARM3_BIGWOOD_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M059_T0, "NW_FARM3_BIGWOOD_02");
	};
};
func void Fun_Platz060()   // NW_FARM3_BIGWOOD_03 (Original: Keiler)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M060_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M060_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M060_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M060_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M060_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M060_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M060_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T060 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_BIGWOOD_03");
			};
			return;
		};
	};
	FUNL_T060 = FUNL_T060 + 1;
	if (FUNL_T060 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T060 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M060_T1, "NW_FARM3_BIGWOOD_03");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M060_T2, "NW_FARM3_BIGWOOD_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M060_T3, "NW_FARM3_BIGWOOD_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M060_T4, "NW_FARM3_BIGWOOD_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M060_T5, "NW_FARM3_BIGWOOD_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M060_T6, "NW_FARM3_BIGWOOD_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M060_T1, "NW_FARM3_BIGWOOD_03");
	};
};
func void Fun_Platz061()   // NW_FARM3_BIGWOOD_03 (Original: Keiler)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M061_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M061_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M061_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M061_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M061_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M061_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M061_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T061 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_BIGWOOD_03");
			};
			return;
		};
	};
	FUNL_T061 = FUNL_T061 + 1;
	if (FUNL_T061 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T061 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M061_T1, "NW_FARM3_BIGWOOD_03");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M061_T2, "NW_FARM3_BIGWOOD_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M061_T3, "NW_FARM3_BIGWOOD_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M061_T4, "NW_FARM3_BIGWOOD_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M061_T5, "NW_FARM3_BIGWOOD_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M061_T6, "NW_FARM3_BIGWOOD_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M061_T1, "NW_FARM3_BIGWOOD_03");
	};
};
func void Fun_Platz062()   // NW_FARM3_BIGWOOD_03 (Original: Keiler)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M062_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M062_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M062_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M062_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M062_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M062_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M062_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T062 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_BIGWOOD_03");
			};
			return;
		};
	};
	FUNL_T062 = FUNL_T062 + 1;
	if (FUNL_T062 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T062 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M062_T1, "NW_FARM3_BIGWOOD_03");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M062_T2, "NW_FARM3_BIGWOOD_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M062_T3, "NW_FARM3_BIGWOOD_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M062_T4, "NW_FARM3_BIGWOOD_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M062_T5, "NW_FARM3_BIGWOOD_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M062_T6, "NW_FARM3_BIGWOOD_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M062_T1, "NW_FARM3_BIGWOOD_03");
	};
};
func void Fun_Platz063()   // NW_FARM3_MOUNTAINLAKE_03 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M063_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M063_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M063_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M063_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M063_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M063_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M063_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T063 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_MOUNTAINLAKE_03");
			};
			return;
		};
	};
	FUNL_T063 = FUNL_T063 + 1;
	if (FUNL_T063 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T063 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M063_T2, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M063_T3, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M063_T4, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M063_T5, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M063_T6, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M063_T7, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M063_T2, "NW_FARM3_MOUNTAINLAKE_03");
	};
};
func void Fun_Platz064()   // NW_FARM3_MOUNTAINLAKE_03 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M064_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M064_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M064_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M064_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M064_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M064_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M064_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T064 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_MOUNTAINLAKE_03");
			};
			return;
		};
	};
	FUNL_T064 = FUNL_T064 + 1;
	if (FUNL_T064 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T064 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M064_T2, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M064_T3, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M064_T4, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M064_T5, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M064_T6, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M064_T7, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M064_T2, "NW_FARM3_MOUNTAINLAKE_03");
	};
};
func void Fun_Platz065()   // NW_FARM3_MOUNTAINLAKE_03 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M065_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M065_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M065_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M065_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M065_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M065_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M065_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T065 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_MOUNTAINLAKE_03");
			};
			return;
		};
	};
	FUNL_T065 = FUNL_T065 + 1;
	if (FUNL_T065 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T065 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M065_T2, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M065_T3, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M065_T4, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M065_T5, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M065_T6, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M065_T7, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M065_T2, "NW_FARM3_MOUNTAINLAKE_03");
	};
};
func void Fun_Platz066()   // NW_FARM3_MOUNTAINLAKE_MONSTER_01 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M066_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M066_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M066_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M066_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M066_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M066_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M066_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T066 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
			};
			return;
		};
	};
	FUNL_T066 = FUNL_T066 + 1;
	if (FUNL_T066 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T066 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M066_T2, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M066_T3, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M066_T4, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M066_T5, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M066_T6, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M066_T7, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M066_T2, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	};
};
func void Fun_Platz067()   // NW_FARM3_MOUNTAINLAKE_MONSTER_01 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M067_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M067_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M067_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M067_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M067_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M067_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M067_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T067 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
			};
			return;
		};
	};
	FUNL_T067 = FUNL_T067 + 1;
	if (FUNL_T067 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T067 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M067_T2, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M067_T3, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M067_T4, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M067_T5, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M067_T6, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M067_T7, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M067_T2, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	};
};
func void Fun_Platz068()   // NW_FARM3_MOUNTAINLAKE_MONSTER_01 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M068_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M068_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M068_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M068_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M068_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M068_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M068_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T068 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
			};
			return;
		};
	};
	FUNL_T068 = FUNL_T068 + 1;
	if (FUNL_T068 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T068 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M068_T2, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M068_T3, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M068_T4, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M068_T5, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M068_T6, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M068_T7, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M068_T2, "NW_FARM3_MOUNTAINLAKE_MONSTER_01");
	};
};
func void Fun_Platz069()   // NW_FARM3_PATH_11_SMALLRIVERMID_02 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M069_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M069_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M069_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M069_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M069_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M069_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M069_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T069 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
			};
			return;
		};
	};
	FUNL_T069 = FUNL_T069 + 1;
	if (FUNL_T069 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T069 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M069_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M069_T3, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M069_T4, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M069_T5, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M069_T6, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M069_T7, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M069_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	};
};
func void Fun_Platz070()   // NW_FARM3_PATH_11_SMALLRIVERMID_02 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M070_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M070_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M070_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M070_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M070_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M070_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M070_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T070 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
			};
			return;
		};
	};
	FUNL_T070 = FUNL_T070 + 1;
	if (FUNL_T070 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T070 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M070_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M070_T3, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M070_T4, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M070_T5, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M070_T6, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M070_T7, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M070_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	};
};
func void Fun_Platz071()   // NW_FARM3_PATH_11_SMALLRIVERMID_02 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M071_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M071_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M071_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M071_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M071_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M071_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M071_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T071 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
			};
			return;
		};
	};
	FUNL_T071 = FUNL_T071 + 1;
	if (FUNL_T071 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T071 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M071_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M071_T3, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M071_T4, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M071_T5, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M071_T6, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M071_T7, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M071_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	};
};
func void Fun_Platz072()   // NW_FARM3_PATH_11_SMALLRIVERMID_03 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M072_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M072_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M072_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M072_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M072_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M072_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M072_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T072 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
			};
			return;
		};
	};
	FUNL_T072 = FUNL_T072 + 1;
	if (FUNL_T072 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T072 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M072_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M072_T3, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M072_T4, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M072_T5, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M072_T6, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M072_T7, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M072_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	};
};
func void Fun_Platz073()   // NW_FARM3_PATH_11_SMALLRIVERMID_03 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M073_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M073_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M073_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M073_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M073_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M073_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M073_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T073 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
			};
			return;
		};
	};
	FUNL_T073 = FUNL_T073 + 1;
	if (FUNL_T073 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T073 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M073_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M073_T3, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M073_T4, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M073_T5, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M073_T6, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M073_T7, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M073_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	};
};
func void Fun_Platz074()   // NW_FARM3_PATH_11_SMALLRIVERMID_03 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M074_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M074_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M074_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M074_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M074_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M074_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M074_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T074 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
			};
			return;
		};
	};
	FUNL_T074 = FUNL_T074 + 1;
	if (FUNL_T074 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T074 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M074_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M074_T3, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M074_T4, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M074_T5, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M074_T6, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M074_T7, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M074_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_03");
	};
};
func void Fun_Platz075()   // NW_FARM3_PATH_11_SMALLRIVER_04 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M075_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M075_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M075_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M075_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M075_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M075_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M075_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T075 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_11_SMALLRIVER_04");
			};
			return;
		};
	};
	FUNL_T075 = FUNL_T075 + 1;
	if (FUNL_T075 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T075 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M075_T2, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M075_T3, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M075_T4, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M075_T5, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M075_T6, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M075_T7, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M075_T2, "NW_FARM3_PATH_11_SMALLRIVER_04");
	};
};
func void Fun_Platz076()   // NW_FARM3_PATH_11_SMALLRIVER_04 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M076_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M076_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M076_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M076_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M076_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M076_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M076_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T076 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_11_SMALLRIVER_04");
			};
			return;
		};
	};
	FUNL_T076 = FUNL_T076 + 1;
	if (FUNL_T076 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T076 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M076_T2, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M076_T3, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M076_T4, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M076_T5, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M076_T6, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M076_T7, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M076_T2, "NW_FARM3_PATH_11_SMALLRIVER_04");
	};
};
func void Fun_Platz077()   // NW_FARM3_PATH_11_SMALLRIVER_04 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M077_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M077_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M077_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M077_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M077_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M077_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M077_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T077 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_11_SMALLRIVER_04");
			};
			return;
		};
	};
	FUNL_T077 = FUNL_T077 + 1;
	if (FUNL_T077 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T077 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M077_T2, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M077_T3, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M077_T4, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M077_T5, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M077_T6, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M077_T7, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M077_T2, "NW_FARM3_PATH_11_SMALLRIVER_04");
	};
};
func void Fun_Platz078()   // NW_FARM3_PATH_11_SMALLRIVER_10 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M078_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M078_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M078_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M078_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M078_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M078_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M078_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T078 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_11_SMALLRIVER_10");
			};
			return;
		};
	};
	FUNL_T078 = FUNL_T078 + 1;
	if (FUNL_T078 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T078 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M078_T0, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M078_T1, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M078_T2, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M078_T3, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M078_T4, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M078_T5, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else
	{
		Wld_InsertNpc(FUN_M078_T0, "NW_FARM3_PATH_11_SMALLRIVER_10");
	};
};
func void Fun_Platz079()   // NW_FARM3_PATH_11_SMALLRIVER_10 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M079_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M079_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M079_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M079_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M079_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M079_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M079_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T079 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_11_SMALLRIVER_10");
			};
			return;
		};
	};
	FUNL_T079 = FUNL_T079 + 1;
	if (FUNL_T079 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T079 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M079_T0, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M079_T1, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M079_T2, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M079_T3, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M079_T4, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M079_T5, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else
	{
		Wld_InsertNpc(FUN_M079_T0, "NW_FARM3_PATH_11_SMALLRIVER_10");
	};
};
func void Fun_Platz080()   // NW_FARM3_PATH_11_SMALLRIVER_10 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M080_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M080_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M080_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M080_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M080_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M080_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M080_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T080 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_11_SMALLRIVER_10");
			};
			return;
		};
	};
	FUNL_T080 = FUNL_T080 + 1;
	if (FUNL_T080 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T080 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M080_T0, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M080_T1, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M080_T2, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M080_T3, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M080_T4, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M080_T5, "NW_FARM3_PATH_11_SMALLRIVER_10");
	}
	else
	{
		Wld_InsertNpc(FUN_M080_T0, "NW_FARM3_PATH_11_SMALLRIVER_10");
	};
};
func void Fun_Platz081()   // NW_FARM3_PATH_11_SMALLRIVER_20 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M081_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M081_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M081_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M081_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M081_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M081_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M081_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T081 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_11_SMALLRIVER_20");
			};
			return;
		};
	};
	FUNL_T081 = FUNL_T081 + 1;
	if (FUNL_T081 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T081 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M081_T2, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M081_T3, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M081_T4, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M081_T5, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M081_T6, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M081_T7, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else
	{
		Wld_InsertNpc(FUN_M081_T2, "NW_FARM3_PATH_11_SMALLRIVER_20");
	};
};
func void Fun_Platz082()   // NW_FARM3_PATH_11_SMALLRIVER_20 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M082_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M082_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M082_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M082_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M082_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M082_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M082_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T082 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_11_SMALLRIVER_20");
			};
			return;
		};
	};
	FUNL_T082 = FUNL_T082 + 1;
	if (FUNL_T082 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T082 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M082_T2, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M082_T3, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M082_T4, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M082_T5, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M082_T6, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M082_T7, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else
	{
		Wld_InsertNpc(FUN_M082_T2, "NW_FARM3_PATH_11_SMALLRIVER_20");
	};
};
func void Fun_Platz083()   // NW_FARM3_PATH_11_SMALLRIVER_20 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M083_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M083_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M083_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M083_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M083_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M083_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M083_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T083 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_11_SMALLRIVER_20");
			};
			return;
		};
	};
	FUNL_T083 = FUNL_T083 + 1;
	if (FUNL_T083 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T083 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M083_T2, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M083_T3, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M083_T4, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M083_T5, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M083_T6, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M083_T7, "NW_FARM3_PATH_11_SMALLRIVER_20");
	}
	else
	{
		Wld_InsertNpc(FUN_M083_T2, "NW_FARM3_PATH_11_SMALLRIVER_20");
	};
};
func void Fun_Platz084()   // NW_FARM3_PATH_12_MONSTER_01 (Original: Keiler)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M084_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M084_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M084_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M084_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M084_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M084_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M084_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T084 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_12_MONSTER_01");
			};
			return;
		};
	};
	FUNL_T084 = FUNL_T084 + 1;
	if (FUNL_T084 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T084 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M084_T1, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M084_T2, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M084_T3, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M084_T4, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M084_T5, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M084_T6, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M084_T1, "NW_FARM3_PATH_12_MONSTER_01");
	};
};
func void Fun_Platz085()   // NW_FARM3_PATH_12_MONSTER_01 (Original: Keiler)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M085_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M085_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M085_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M085_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M085_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M085_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M085_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T085 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_12_MONSTER_01");
			};
			return;
		};
	};
	FUNL_T085 = FUNL_T085 + 1;
	if (FUNL_T085 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T085 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M085_T1, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M085_T2, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M085_T3, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M085_T4, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M085_T5, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M085_T6, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M085_T1, "NW_FARM3_PATH_12_MONSTER_01");
	};
};
func void Fun_Platz086()   // NW_FARM3_PATH_12_MONSTER_01 (Original: Keiler)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M086_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M086_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M086_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M086_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M086_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M086_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M086_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T086 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM3_PATH_12_MONSTER_01");
			};
			return;
		};
	};
	FUNL_T086 = FUNL_T086 + 1;
	if (FUNL_T086 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T086 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M086_T1, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M086_T2, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M086_T3, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M086_T4, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M086_T5, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M086_T6, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M086_T1, "NW_FARM3_PATH_12_MONSTER_01");
	};
};
func void Fun_Platz087()   // NW_FARM4_WOOD_MONSTER_MORE_01 (Original: Giant_Bug)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M087_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M087_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M087_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M087_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M087_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M087_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M087_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T087 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_MONSTER_MORE_01");
			};
			return;
		};
	};
	FUNL_T087 = FUNL_T087 + 1;
	if (FUNL_T087 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T087 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M087_T1, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M087_T2, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M087_T3, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M087_T4, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M087_T5, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M087_T6, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M087_T1, "NW_FARM4_WOOD_MONSTER_MORE_01");
	};
};
func void Fun_Platz088()   // NW_FARM4_WOOD_MONSTER_MORE_01 (Original: Giant_Bug)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M088_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M088_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M088_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M088_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M088_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M088_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M088_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T088 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_MONSTER_MORE_01");
			};
			return;
		};
	};
	FUNL_T088 = FUNL_T088 + 1;
	if (FUNL_T088 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T088 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M088_T1, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M088_T2, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M088_T3, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M088_T4, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M088_T5, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M088_T6, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M088_T1, "NW_FARM4_WOOD_MONSTER_MORE_01");
	};
};
func void Fun_Platz089()   // NW_FARM4_WOOD_MONSTER_MORE_01 (Original: Giant_Bug)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M089_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M089_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M089_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M089_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M089_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M089_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M089_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T089 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_MONSTER_MORE_01");
			};
			return;
		};
	};
	FUNL_T089 = FUNL_T089 + 1;
	if (FUNL_T089 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T089 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M089_T1, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M089_T2, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M089_T3, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M089_T4, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M089_T5, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M089_T6, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M089_T1, "NW_FARM4_WOOD_MONSTER_MORE_01");
	};
};
func void Fun_Platz090()   // NW_FARM4_WOOD_MONSTER_MORE_02 (Original: Gobbo_skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M090_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M090_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M090_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M090_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M090_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M090_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M090_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T090 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_MONSTER_MORE_02");
			};
			return;
		};
	};
	FUNL_T090 = FUNL_T090 + 1;
	if (FUNL_T090 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T090 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M090_T2, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M090_T3, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M090_T4, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M090_T5, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M090_T6, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M090_T7, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M090_T2, "NW_FARM4_WOOD_MONSTER_MORE_02");
	};
};
func void Fun_Platz091()   // NW_FARM4_WOOD_MONSTER_MORE_02 (Original: Gobbo_skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M091_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M091_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M091_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M091_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M091_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M091_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M091_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T091 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_MONSTER_MORE_02");
			};
			return;
		};
	};
	FUNL_T091 = FUNL_T091 + 1;
	if (FUNL_T091 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T091 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M091_T2, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M091_T3, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M091_T4, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M091_T5, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M091_T6, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M091_T7, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M091_T2, "NW_FARM4_WOOD_MONSTER_MORE_02");
	};
};
func void Fun_Platz092()   // NW_FARM4_WOOD_MONSTER_MORE_02 (Original: Gobbo_skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M092_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M092_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M092_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M092_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M092_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M092_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M092_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T092 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_MONSTER_MORE_02");
			};
			return;
		};
	};
	FUNL_T092 = FUNL_T092 + 1;
	if (FUNL_T092 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T092 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M092_T2, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M092_T3, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M092_T4, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M092_T5, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M092_T6, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M092_T7, "NW_FARM4_WOOD_MONSTER_MORE_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M092_T2, "NW_FARM4_WOOD_MONSTER_MORE_02");
	};
};
func void Fun_Platz093()   // NW_FARM4_WOOD_MONSTER_N_3 (Original: Giant_Bug)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M093_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M093_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M093_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M093_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M093_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M093_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M093_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T093 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_MONSTER_N_3");
			};
			return;
		};
	};
	FUNL_T093 = FUNL_T093 + 1;
	if (FUNL_T093 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T093 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M093_T1, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M093_T2, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M093_T3, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M093_T4, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M093_T5, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M093_T6, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else
	{
		Wld_InsertNpc(FUN_M093_T1, "NW_FARM4_WOOD_MONSTER_N_3");
	};
};
func void Fun_Platz094()   // NW_FARM4_WOOD_MONSTER_N_3 (Original: Giant_Bug)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M094_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M094_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M094_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M094_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M094_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M094_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M094_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T094 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_MONSTER_N_3");
			};
			return;
		};
	};
	FUNL_T094 = FUNL_T094 + 1;
	if (FUNL_T094 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T094 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M094_T1, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M094_T2, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M094_T3, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M094_T4, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M094_T5, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M094_T6, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else
	{
		Wld_InsertNpc(FUN_M094_T1, "NW_FARM4_WOOD_MONSTER_N_3");
	};
};
func void Fun_Platz095()   // NW_FARM4_WOOD_MONSTER_N_3 (Original: Giant_Bug)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M095_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M095_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M095_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M095_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M095_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M095_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M095_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T095 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_MONSTER_N_3");
			};
			return;
		};
	};
	FUNL_T095 = FUNL_T095 + 1;
	if (FUNL_T095 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T095 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M095_T1, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M095_T2, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M095_T3, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M095_T4, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M095_T5, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M095_T6, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else
	{
		Wld_InsertNpc(FUN_M095_T1, "NW_FARM4_WOOD_MONSTER_N_3");
	};
};
func void Fun_Platz096()   // NW_FARM4_WOOD_NEARPEASANT2_10 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M096_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M096_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M096_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M096_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M096_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M096_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M096_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T096 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_NEARPEASANT2_10");
			};
			return;
		};
	};
	FUNL_T096 = FUNL_T096 + 1;
	if (FUNL_T096 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T096 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M096_T0, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M096_T1, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M096_T2, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M096_T3, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M096_T4, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M096_T5, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else
	{
		Wld_InsertNpc(FUN_M096_T0, "NW_FARM4_WOOD_NEARPEASANT2_10");
	};
};
func void Fun_Platz097()   // NW_FARM4_WOOD_NEARPEASANT2_10 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M097_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M097_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M097_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M097_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M097_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M097_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M097_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T097 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_NEARPEASANT2_10");
			};
			return;
		};
	};
	FUNL_T097 = FUNL_T097 + 1;
	if (FUNL_T097 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T097 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M097_T0, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M097_T1, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M097_T2, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M097_T3, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M097_T4, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M097_T5, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else
	{
		Wld_InsertNpc(FUN_M097_T0, "NW_FARM4_WOOD_NEARPEASANT2_10");
	};
};
func void Fun_Platz098()   // NW_FARM4_WOOD_NEARPEASANT2_10 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M098_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M098_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M098_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M098_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M098_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M098_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M098_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T098 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_NEARPEASANT2_10");
			};
			return;
		};
	};
	FUNL_T098 = FUNL_T098 + 1;
	if (FUNL_T098 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T098 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M098_T0, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M098_T1, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M098_T2, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M098_T3, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M098_T4, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M098_T5, "NW_FARM4_WOOD_NEARPEASANT2_10");
	}
	else
	{
		Wld_InsertNpc(FUN_M098_T0, "NW_FARM4_WOOD_NEARPEASANT2_10");
	};
};
func void Fun_Platz099()   // NW_FARM4_WOOD_NEARPEASANT2_14 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M099_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M099_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M099_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M099_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M099_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M099_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M099_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T099 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_NEARPEASANT2_14");
			};
			return;
		};
	};
	FUNL_T099 = FUNL_T099 + 1;
	if (FUNL_T099 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T099 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M099_T0, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M099_T1, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M099_T2, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M099_T3, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M099_T4, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M099_T5, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else
	{
		Wld_InsertNpc(FUN_M099_T0, "NW_FARM4_WOOD_NEARPEASANT2_14");
	};
};
func void Fun_Platz100()   // NW_FARM4_WOOD_NEARPEASANT2_14 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M100_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M100_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M100_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M100_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M100_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M100_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M100_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T100 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_NEARPEASANT2_14");
			};
			return;
		};
	};
	FUNL_T100 = FUNL_T100 + 1;
	if (FUNL_T100 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T100 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M100_T0, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M100_T1, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M100_T2, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M100_T3, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M100_T4, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M100_T5, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else
	{
		Wld_InsertNpc(FUN_M100_T0, "NW_FARM4_WOOD_NEARPEASANT2_14");
	};
};
func void Fun_Platz101()   // NW_FARM4_WOOD_NEARPEASANT2_14 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M101_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M101_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M101_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M101_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M101_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M101_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M101_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T101 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_NEARPEASANT2_14");
			};
			return;
		};
	};
	FUNL_T101 = FUNL_T101 + 1;
	if (FUNL_T101 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T101 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M101_T0, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M101_T1, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M101_T2, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M101_T3, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M101_T4, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M101_T5, "NW_FARM4_WOOD_NEARPEASANT2_14");
	}
	else
	{
		Wld_InsertNpc(FUN_M101_T0, "NW_FARM4_WOOD_NEARPEASANT2_14");
	};
};
func void Fun_Platz102()   // NW_FARM4_WOOD_NEARPEASANT2_8 (Original: Wolf)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M102_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M102_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M102_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M102_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M102_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M102_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M102_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T102 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_NEARPEASANT2_8");
			};
			return;
		};
	};
	FUNL_T102 = FUNL_T102 + 1;
	if (FUNL_T102 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T102 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M102_T1, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M102_T2, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M102_T3, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M102_T4, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M102_T5, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M102_T6, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else
	{
		Wld_InsertNpc(FUN_M102_T1, "NW_FARM4_WOOD_NEARPEASANT2_8");
	};
};
func void Fun_Platz103()   // NW_FARM4_WOOD_NEARPEASANT2_8 (Original: Wolf)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M103_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M103_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M103_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M103_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M103_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M103_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M103_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T103 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_NEARPEASANT2_8");
			};
			return;
		};
	};
	FUNL_T103 = FUNL_T103 + 1;
	if (FUNL_T103 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T103 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M103_T1, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M103_T2, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M103_T3, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M103_T4, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M103_T5, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M103_T6, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else
	{
		Wld_InsertNpc(FUN_M103_T1, "NW_FARM4_WOOD_NEARPEASANT2_8");
	};
};
func void Fun_Platz104()   // NW_FARM4_WOOD_NEARPEASANT2_8 (Original: Wolf)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M104_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M104_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M104_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M104_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M104_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M104_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M104_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T104 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_FARM4_WOOD_NEARPEASANT2_8");
			};
			return;
		};
	};
	FUNL_T104 = FUNL_T104 + 1;
	if (FUNL_T104 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T104 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M104_T1, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M104_T2, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M104_T3, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M104_T4, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M104_T5, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M104_T6, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else
	{
		Wld_InsertNpc(FUN_M104_T1, "NW_FARM4_WOOD_NEARPEASANT2_8");
	};
};
func void Fun_Platz105()   // NW_SAGITTA_MOREMONSTER_01 (Original: Wolf)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M105_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M105_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M105_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M105_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M105_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M105_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M105_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T105 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_SAGITTA_MOREMONSTER_01");
			};
			return;
		};
	};
	FUNL_T105 = FUNL_T105 + 1;
	if (FUNL_T105 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T105 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M105_T1, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M105_T2, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M105_T3, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M105_T4, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M105_T5, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M105_T6, "NW_SAGITTA_MOREMONSTER_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M105_T1, "NW_SAGITTA_MOREMONSTER_01");
	};
};
func void Fun_Platz106()   // NW_SAGITTA_MOREMONSTER_01 (Original: Wolf)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M106_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M106_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M106_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M106_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M106_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M106_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M106_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T106 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_SAGITTA_MOREMONSTER_01");
			};
			return;
		};
	};
	FUNL_T106 = FUNL_T106 + 1;
	if (FUNL_T106 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T106 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M106_T1, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M106_T2, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M106_T3, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M106_T4, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M106_T5, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M106_T6, "NW_SAGITTA_MOREMONSTER_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M106_T1, "NW_SAGITTA_MOREMONSTER_01");
	};
};
func void Fun_Platz107()   // NW_SAGITTA_MOREMONSTER_01 (Original: Wolf)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M107_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M107_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M107_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M107_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M107_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M107_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M107_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T107 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_SAGITTA_MOREMONSTER_01");
			};
			return;
		};
	};
	FUNL_T107 = FUNL_T107 + 1;
	if (FUNL_T107 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T107 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M107_T1, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M107_T2, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M107_T3, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M107_T4, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M107_T5, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M107_T6, "NW_SAGITTA_MOREMONSTER_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M107_T1, "NW_SAGITTA_MOREMONSTER_01");
	};
};
func void Fun_Platz108()   // NW_SAGITTA_MOREMONSTER_03 (Original: Giant_Bug)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M108_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M108_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M108_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M108_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M108_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M108_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M108_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T108 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_SAGITTA_MOREMONSTER_03");
			};
			return;
		};
	};
	FUNL_T108 = FUNL_T108 + 1;
	if (FUNL_T108 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T108 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M108_T1, "NW_SAGITTA_MOREMONSTER_03");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M108_T2, "NW_SAGITTA_MOREMONSTER_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M108_T3, "NW_SAGITTA_MOREMONSTER_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M108_T4, "NW_SAGITTA_MOREMONSTER_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M108_T5, "NW_SAGITTA_MOREMONSTER_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M108_T6, "NW_SAGITTA_MOREMONSTER_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M108_T1, "NW_SAGITTA_MOREMONSTER_03");
	};
};
func void Fun_Platz109()   // NW_SAGITTA_MOREMONSTER_03 (Original: Giant_Bug)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M109_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M109_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M109_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M109_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M109_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M109_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M109_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T109 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_SAGITTA_MOREMONSTER_03");
			};
			return;
		};
	};
	FUNL_T109 = FUNL_T109 + 1;
	if (FUNL_T109 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T109 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M109_T1, "NW_SAGITTA_MOREMONSTER_03");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M109_T2, "NW_SAGITTA_MOREMONSTER_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M109_T3, "NW_SAGITTA_MOREMONSTER_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M109_T4, "NW_SAGITTA_MOREMONSTER_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M109_T5, "NW_SAGITTA_MOREMONSTER_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M109_T6, "NW_SAGITTA_MOREMONSTER_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M109_T1, "NW_SAGITTA_MOREMONSTER_03");
	};
};
func void Fun_Platz110()   // NW_SAGITTA_MOREMONSTER_03 (Original: Giant_Bug)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M110_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M110_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M110_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M110_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M110_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M110_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M110_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T110 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_SAGITTA_MOREMONSTER_03");
			};
			return;
		};
	};
	FUNL_T110 = FUNL_T110 + 1;
	if (FUNL_T110 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T110 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M110_T1, "NW_SAGITTA_MOREMONSTER_03");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M110_T2, "NW_SAGITTA_MOREMONSTER_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M110_T3, "NW_SAGITTA_MOREMONSTER_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M110_T4, "NW_SAGITTA_MOREMONSTER_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M110_T5, "NW_SAGITTA_MOREMONSTER_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M110_T6, "NW_SAGITTA_MOREMONSTER_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M110_T1, "NW_SAGITTA_MOREMONSTER_03");
	};
};
func void Fun_Platz111()   // NW_TAVERNE_TROLLAREA_MONSTER_03_01M1 (Original: Giant_Bug)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M111_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M111_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M111_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M111_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M111_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M111_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M111_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T111 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
			};
			return;
		};
	};
	FUNL_T111 = FUNL_T111 + 1;
	if (FUNL_T111 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T111 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M111_T1, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M111_T2, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M111_T3, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M111_T4, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M111_T5, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M111_T6, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else
	{
		Wld_InsertNpc(FUN_M111_T1, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	};
};
func void Fun_Platz112()   // NW_TAVERNE_TROLLAREA_MONSTER_03_01M1 (Original: Giant_Bug)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M112_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M112_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M112_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M112_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M112_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M112_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M112_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T112 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
			};
			return;
		};
	};
	FUNL_T112 = FUNL_T112 + 1;
	if (FUNL_T112 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T112 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M112_T1, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M112_T2, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M112_T3, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M112_T4, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M112_T5, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M112_T6, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else
	{
		Wld_InsertNpc(FUN_M112_T1, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	};
};
func void Fun_Platz113()   // NW_TAVERNE_TROLLAREA_MONSTER_03_01M1 (Original: Giant_Bug)
{
	var C_NPC m;
	var int t;
	t = 1 + Fun_KapitelNr() - 1;
	if (t > 6)
	{
		t = 6;
	};
	if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M113_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M113_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M113_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M113_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M113_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M113_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M113_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T113 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
			};
			return;
		};
	};
	FUNL_T113 = FUNL_T113 + 1;
	if (FUNL_T113 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T113 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M113_T1, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M113_T2, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M113_T3, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M113_T4, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M113_T5, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M113_T6, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else
	{
		Wld_InsertNpc(FUN_M113_T1, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	};
};
func void Fun_Platz114()   // NW_TROLLAREA_BRIGDE_05 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M114_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M114_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M114_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M114_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M114_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M114_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M114_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T114 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_BRIGDE_05");
			};
			return;
		};
	};
	FUNL_T114 = FUNL_T114 + 1;
	if (FUNL_T114 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T114 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M114_T0, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M114_T1, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M114_T2, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M114_T3, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M114_T4, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M114_T5, "NW_TROLLAREA_BRIGDE_05");
	}
	else
	{
		Wld_InsertNpc(FUN_M114_T0, "NW_TROLLAREA_BRIGDE_05");
	};
};
func void Fun_Platz115()   // NW_TROLLAREA_BRIGDE_05 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M115_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M115_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M115_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M115_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M115_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M115_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M115_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T115 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_BRIGDE_05");
			};
			return;
		};
	};
	FUNL_T115 = FUNL_T115 + 1;
	if (FUNL_T115 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T115 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M115_T0, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M115_T1, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M115_T2, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M115_T3, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M115_T4, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M115_T5, "NW_TROLLAREA_BRIGDE_05");
	}
	else
	{
		Wld_InsertNpc(FUN_M115_T0, "NW_TROLLAREA_BRIGDE_05");
	};
};
func void Fun_Platz116()   // NW_TROLLAREA_BRIGDE_05 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M116_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M116_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M116_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M116_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M116_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M116_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M116_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T116 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_BRIGDE_05");
			};
			return;
		};
	};
	FUNL_T116 = FUNL_T116 + 1;
	if (FUNL_T116 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T116 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M116_T0, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M116_T1, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M116_T2, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M116_T3, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M116_T4, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M116_T5, "NW_TROLLAREA_BRIGDE_05");
	}
	else
	{
		Wld_InsertNpc(FUN_M116_T0, "NW_TROLLAREA_BRIGDE_05");
	};
};
func void Fun_Platz117()   // NW_TROLLAREA_PATH_08 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M117_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M117_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M117_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M117_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M117_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M117_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M117_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T117 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_08");
			};
			return;
		};
	};
	FUNL_T117 = FUNL_T117 + 1;
	if (FUNL_T117 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T117 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M117_T2, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M117_T3, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M117_T4, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M117_T5, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M117_T6, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M117_T7, "NW_TROLLAREA_PATH_08");
	}
	else
	{
		Wld_InsertNpc(FUN_M117_T2, "NW_TROLLAREA_PATH_08");
	};
};
func void Fun_Platz118()   // NW_TROLLAREA_PATH_08 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M118_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M118_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M118_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M118_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M118_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M118_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M118_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T118 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_08");
			};
			return;
		};
	};
	FUNL_T118 = FUNL_T118 + 1;
	if (FUNL_T118 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T118 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M118_T2, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M118_T3, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M118_T4, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M118_T5, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M118_T6, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M118_T7, "NW_TROLLAREA_PATH_08");
	}
	else
	{
		Wld_InsertNpc(FUN_M118_T2, "NW_TROLLAREA_PATH_08");
	};
};
func void Fun_Platz119()   // NW_TROLLAREA_PATH_08 (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M119_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M119_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M119_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M119_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M119_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M119_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M119_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T119 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_08");
			};
			return;
		};
	};
	FUNL_T119 = FUNL_T119 + 1;
	if (FUNL_T119 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T119 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M119_T2, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M119_T3, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M119_T4, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M119_T5, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M119_T6, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M119_T7, "NW_TROLLAREA_PATH_08");
	}
	else
	{
		Wld_InsertNpc(FUN_M119_T2, "NW_TROLLAREA_PATH_08");
	};
};
func void Fun_Platz120()   // NW_TROLLAREA_PATH_15_MONSTER (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M120_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M120_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M120_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M120_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M120_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M120_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M120_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T120 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_15_MONSTER");
			};
			return;
		};
	};
	FUNL_T120 = FUNL_T120 + 1;
	if (FUNL_T120 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T120 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M120_T0, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M120_T1, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M120_T2, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M120_T3, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M120_T4, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M120_T5, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M120_T0, "NW_TROLLAREA_PATH_15_MONSTER");
	};
};
func void Fun_Platz121()   // NW_TROLLAREA_PATH_15_MONSTER (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M121_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M121_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M121_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M121_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M121_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M121_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M121_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T121 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_15_MONSTER");
			};
			return;
		};
	};
	FUNL_T121 = FUNL_T121 + 1;
	if (FUNL_T121 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T121 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M121_T0, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M121_T1, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M121_T2, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M121_T3, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M121_T4, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M121_T5, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M121_T0, "NW_TROLLAREA_PATH_15_MONSTER");
	};
};
func void Fun_Platz122()   // NW_TROLLAREA_PATH_15_MONSTER (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M122_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M122_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M122_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M122_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M122_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M122_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M122_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T122 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_15_MONSTER");
			};
			return;
		};
	};
	FUNL_T122 = FUNL_T122 + 1;
	if (FUNL_T122 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T122 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M122_T0, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M122_T1, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M122_T2, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M122_T3, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M122_T4, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M122_T5, "NW_TROLLAREA_PATH_15_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M122_T0, "NW_TROLLAREA_PATH_15_MONSTER");
	};
};
func void Fun_Platz123()   // NW_TROLLAREA_PATH_38_MONSTER (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M123_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M123_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M123_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M123_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M123_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M123_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M123_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T123 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_38_MONSTER");
			};
			return;
		};
	};
	FUNL_T123 = FUNL_T123 + 1;
	if (FUNL_T123 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T123 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M123_T0, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M123_T1, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M123_T2, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M123_T3, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M123_T4, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M123_T5, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M123_T0, "NW_TROLLAREA_PATH_38_MONSTER");
	};
};
func void Fun_Platz124()   // NW_TROLLAREA_PATH_38_MONSTER (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M124_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M124_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M124_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M124_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M124_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M124_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M124_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T124 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_38_MONSTER");
			};
			return;
		};
	};
	FUNL_T124 = FUNL_T124 + 1;
	if (FUNL_T124 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T124 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M124_T0, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M124_T1, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M124_T2, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M124_T3, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M124_T4, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M124_T5, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M124_T0, "NW_TROLLAREA_PATH_38_MONSTER");
	};
};
func void Fun_Platz125()   // NW_TROLLAREA_PATH_38_MONSTER (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M125_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M125_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M125_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M125_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M125_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M125_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M125_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T125 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_38_MONSTER");
			};
			return;
		};
	};
	FUNL_T125 = FUNL_T125 + 1;
	if (FUNL_T125 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T125 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M125_T0, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M125_T1, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M125_T2, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M125_T3, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M125_T4, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M125_T5, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M125_T0, "NW_TROLLAREA_PATH_38_MONSTER");
	};
};
func void Fun_Platz126()   // NW_TROLLAREA_PATH_56 (Original: Gobbo_Green)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M126_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M126_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M126_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M126_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M126_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M126_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M126_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T126 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_56");
			};
			return;
		};
	};
	FUNL_T126 = FUNL_T126 + 1;
	if (FUNL_T126 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T126 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M126_T2, "NW_TROLLAREA_PATH_56");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M126_T3, "NW_TROLLAREA_PATH_56");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M126_T4, "NW_TROLLAREA_PATH_56");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M126_T5, "NW_TROLLAREA_PATH_56");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M126_T6, "NW_TROLLAREA_PATH_56");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M126_T7, "NW_TROLLAREA_PATH_56");
	}
	else
	{
		Wld_InsertNpc(FUN_M126_T2, "NW_TROLLAREA_PATH_56");
	};
};
func void Fun_Platz127()   // NW_TROLLAREA_PATH_56 (Original: Gobbo_Green)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M127_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M127_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M127_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M127_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M127_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M127_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M127_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T127 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_56");
			};
			return;
		};
	};
	FUNL_T127 = FUNL_T127 + 1;
	if (FUNL_T127 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T127 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M127_T2, "NW_TROLLAREA_PATH_56");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M127_T3, "NW_TROLLAREA_PATH_56");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M127_T4, "NW_TROLLAREA_PATH_56");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M127_T5, "NW_TROLLAREA_PATH_56");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M127_T6, "NW_TROLLAREA_PATH_56");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M127_T7, "NW_TROLLAREA_PATH_56");
	}
	else
	{
		Wld_InsertNpc(FUN_M127_T2, "NW_TROLLAREA_PATH_56");
	};
};
func void Fun_Platz128()   // NW_TROLLAREA_PATH_56 (Original: Gobbo_Green)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M128_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M128_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M128_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M128_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M128_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M128_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M128_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T128 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_56");
			};
			return;
		};
	};
	FUNL_T128 = FUNL_T128 + 1;
	if (FUNL_T128 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T128 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M128_T2, "NW_TROLLAREA_PATH_56");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M128_T3, "NW_TROLLAREA_PATH_56");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M128_T4, "NW_TROLLAREA_PATH_56");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M128_T5, "NW_TROLLAREA_PATH_56");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M128_T6, "NW_TROLLAREA_PATH_56");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M128_T7, "NW_TROLLAREA_PATH_56");
	}
	else
	{
		Wld_InsertNpc(FUN_M128_T2, "NW_TROLLAREA_PATH_56");
	};
};
func void Fun_Platz129()   // NW_TROLLAREA_PATH_71_MONSTER (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M129_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M129_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M129_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M129_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M129_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M129_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M129_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T129 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_71_MONSTER");
			};
			return;
		};
	};
	FUNL_T129 = FUNL_T129 + 1;
	if (FUNL_T129 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T129 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M129_T2, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M129_T3, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M129_T4, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M129_T5, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M129_T6, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M129_T7, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M129_T2, "NW_TROLLAREA_PATH_71_MONSTER");
	};
};
func void Fun_Platz130()   // NW_TROLLAREA_PATH_71_MONSTER (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M130_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M130_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M130_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M130_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M130_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M130_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M130_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T130 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_71_MONSTER");
			};
			return;
		};
	};
	FUNL_T130 = FUNL_T130 + 1;
	if (FUNL_T130 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T130 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M130_T2, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M130_T3, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M130_T4, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M130_T5, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M130_T6, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M130_T7, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M130_T2, "NW_TROLLAREA_PATH_71_MONSTER");
	};
};
func void Fun_Platz131()   // NW_TROLLAREA_PATH_71_MONSTER (Original: Lurker)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M131_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M131_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M131_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M131_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M131_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M131_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M131_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T131 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_71_MONSTER");
			};
			return;
		};
	};
	FUNL_T131 = FUNL_T131 + 1;
	if (FUNL_T131 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T131 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M131_T2, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M131_T3, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M131_T4, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M131_T5, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M131_T6, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M131_T7, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M131_T2, "NW_TROLLAREA_PATH_71_MONSTER");
	};
};
func void Fun_Platz132()   // NW_TROLLAREA_PATH_71_MONSTER2 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M132_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M132_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M132_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M132_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M132_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M132_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M132_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T132 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_71_MONSTER2");
			};
			return;
		};
	};
	FUNL_T132 = FUNL_T132 + 1;
	if (FUNL_T132 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T132 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M132_T0, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M132_T1, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M132_T2, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M132_T3, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M132_T4, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M132_T5, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else
	{
		Wld_InsertNpc(FUN_M132_T0, "NW_TROLLAREA_PATH_71_MONSTER2");
	};
};
func void Fun_Platz133()   // NW_TROLLAREA_PATH_71_MONSTER2 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M133_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M133_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M133_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M133_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M133_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M133_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M133_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T133 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_71_MONSTER2");
			};
			return;
		};
	};
	FUNL_T133 = FUNL_T133 + 1;
	if (FUNL_T133 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T133 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M133_T0, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M133_T1, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M133_T2, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M133_T3, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M133_T4, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M133_T5, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else
	{
		Wld_InsertNpc(FUN_M133_T0, "NW_TROLLAREA_PATH_71_MONSTER2");
	};
};
func void Fun_Platz134()   // NW_TROLLAREA_PATH_71_MONSTER2 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M134_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M134_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M134_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M134_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M134_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M134_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M134_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T134 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PATH_71_MONSTER2");
			};
			return;
		};
	};
	FUNL_T134 = FUNL_T134 + 1;
	if (FUNL_T134 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T134 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M134_T0, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M134_T1, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M134_T2, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M134_T3, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M134_T4, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M134_T5, "NW_TROLLAREA_PATH_71_MONSTER2");
	}
	else
	{
		Wld_InsertNpc(FUN_M134_T0, "NW_TROLLAREA_PATH_71_MONSTER2");
	};
};
func void Fun_Platz135()   // NW_TROLLAREA_PLANE_04 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M135_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M135_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M135_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M135_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M135_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M135_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M135_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T135 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PLANE_04");
			};
			return;
		};
	};
	FUNL_T135 = FUNL_T135 + 1;
	if (FUNL_T135 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T135 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M135_T0, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M135_T1, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M135_T2, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M135_T3, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M135_T4, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M135_T5, "NW_TROLLAREA_PLANE_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M135_T0, "NW_TROLLAREA_PLANE_04");
	};
};
func void Fun_Platz136()   // NW_TROLLAREA_PLANE_04 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M136_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M136_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M136_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M136_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M136_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M136_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M136_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T136 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PLANE_04");
			};
			return;
		};
	};
	FUNL_T136 = FUNL_T136 + 1;
	if (FUNL_T136 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T136 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M136_T0, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M136_T1, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M136_T2, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M136_T3, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M136_T4, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M136_T5, "NW_TROLLAREA_PLANE_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M136_T0, "NW_TROLLAREA_PLANE_04");
	};
};
func void Fun_Platz137()   // NW_TROLLAREA_PLANE_04 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M137_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M137_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M137_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M137_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M137_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M137_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M137_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T137 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PLANE_04");
			};
			return;
		};
	};
	FUNL_T137 = FUNL_T137 + 1;
	if (FUNL_T137 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T137 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M137_T0, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M137_T1, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M137_T2, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M137_T3, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M137_T4, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M137_T5, "NW_TROLLAREA_PLANE_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M137_T0, "NW_TROLLAREA_PLANE_04");
	};
};
func void Fun_Platz138()   // NW_TROLLAREA_PLANE_07 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M138_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M138_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M138_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M138_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M138_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M138_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M138_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T138 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PLANE_07");
			};
			return;
		};
	};
	FUNL_T138 = FUNL_T138 + 1;
	if (FUNL_T138 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T138 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M138_T0, "NW_TROLLAREA_PLANE_07");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M138_T1, "NW_TROLLAREA_PLANE_07");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M138_T2, "NW_TROLLAREA_PLANE_07");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M138_T3, "NW_TROLLAREA_PLANE_07");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M138_T4, "NW_TROLLAREA_PLANE_07");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M138_T5, "NW_TROLLAREA_PLANE_07");
	}
	else
	{
		Wld_InsertNpc(FUN_M138_T0, "NW_TROLLAREA_PLANE_07");
	};
};
func void Fun_Platz139()   // NW_TROLLAREA_PLANE_07 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M139_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M139_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M139_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M139_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M139_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M139_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M139_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T139 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PLANE_07");
			};
			return;
		};
	};
	FUNL_T139 = FUNL_T139 + 1;
	if (FUNL_T139 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T139 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M139_T0, "NW_TROLLAREA_PLANE_07");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M139_T1, "NW_TROLLAREA_PLANE_07");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M139_T2, "NW_TROLLAREA_PLANE_07");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M139_T3, "NW_TROLLAREA_PLANE_07");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M139_T4, "NW_TROLLAREA_PLANE_07");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M139_T5, "NW_TROLLAREA_PLANE_07");
	}
	else
	{
		Wld_InsertNpc(FUN_M139_T0, "NW_TROLLAREA_PLANE_07");
	};
};
func void Fun_Platz140()   // NW_TROLLAREA_PLANE_07 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M140_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M140_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M140_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M140_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M140_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M140_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M140_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T140 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PLANE_07");
			};
			return;
		};
	};
	FUNL_T140 = FUNL_T140 + 1;
	if (FUNL_T140 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T140 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M140_T0, "NW_TROLLAREA_PLANE_07");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M140_T1, "NW_TROLLAREA_PLANE_07");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M140_T2, "NW_TROLLAREA_PLANE_07");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M140_T3, "NW_TROLLAREA_PLANE_07");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M140_T4, "NW_TROLLAREA_PLANE_07");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M140_T5, "NW_TROLLAREA_PLANE_07");
	}
	else
	{
		Wld_InsertNpc(FUN_M140_T0, "NW_TROLLAREA_PLANE_07");
	};
};
func void Fun_Platz141()   // NW_TROLLAREA_PORTALTEMPEL_06 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M141_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M141_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M141_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M141_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M141_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M141_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M141_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T141 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_06");
			};
			return;
		};
	};
	FUNL_T141 = FUNL_T141 + 1;
	if (FUNL_T141 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T141 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M141_T0, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M141_T1, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M141_T2, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M141_T3, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M141_T4, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M141_T5, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else
	{
		Wld_InsertNpc(FUN_M141_T0, "NW_TROLLAREA_PORTALTEMPEL_06");
	};
};
func void Fun_Platz142()   // NW_TROLLAREA_PORTALTEMPEL_06 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M142_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M142_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M142_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M142_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M142_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M142_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M142_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T142 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_06");
			};
			return;
		};
	};
	FUNL_T142 = FUNL_T142 + 1;
	if (FUNL_T142 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T142 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M142_T0, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M142_T1, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M142_T2, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M142_T3, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M142_T4, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M142_T5, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else
	{
		Wld_InsertNpc(FUN_M142_T0, "NW_TROLLAREA_PORTALTEMPEL_06");
	};
};
func void Fun_Platz143()   // NW_TROLLAREA_PORTALTEMPEL_06 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M143_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M143_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M143_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M143_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M143_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M143_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M143_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T143 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_06");
			};
			return;
		};
	};
	FUNL_T143 = FUNL_T143 + 1;
	if (FUNL_T143 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T143 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M143_T0, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M143_T1, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M143_T2, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M143_T3, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M143_T4, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M143_T5, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else
	{
		Wld_InsertNpc(FUN_M143_T0, "NW_TROLLAREA_PORTALTEMPEL_06");
	};
};
func void Fun_Platz144()   // NW_TROLLAREA_PORTALTEMPEL_08 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M144_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M144_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M144_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M144_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M144_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M144_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M144_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T144 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_08");
			};
			return;
		};
	};
	FUNL_T144 = FUNL_T144 + 1;
	if (FUNL_T144 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T144 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M144_T0, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M144_T1, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M144_T2, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M144_T3, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M144_T4, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M144_T5, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else
	{
		Wld_InsertNpc(FUN_M144_T0, "NW_TROLLAREA_PORTALTEMPEL_08");
	};
};
func void Fun_Platz145()   // NW_TROLLAREA_PORTALTEMPEL_08 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M145_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M145_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M145_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M145_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M145_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M145_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M145_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T145 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_08");
			};
			return;
		};
	};
	FUNL_T145 = FUNL_T145 + 1;
	if (FUNL_T145 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T145 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M145_T0, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M145_T1, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M145_T2, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M145_T3, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M145_T4, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M145_T5, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else
	{
		Wld_InsertNpc(FUN_M145_T0, "NW_TROLLAREA_PORTALTEMPEL_08");
	};
};
func void Fun_Platz146()   // NW_TROLLAREA_PORTALTEMPEL_08 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M146_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M146_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M146_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M146_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M146_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M146_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M146_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T146 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_08");
			};
			return;
		};
	};
	FUNL_T146 = FUNL_T146 + 1;
	if (FUNL_T146 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T146 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M146_T0, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M146_T1, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M146_T2, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M146_T3, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M146_T4, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M146_T5, "NW_TROLLAREA_PORTALTEMPEL_08");
	}
	else
	{
		Wld_InsertNpc(FUN_M146_T0, "NW_TROLLAREA_PORTALTEMPEL_08");
	};
};
func void Fun_Platz147()   // NW_TROLLAREA_PORTALTEMPEL_09 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M147_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M147_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M147_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M147_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M147_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M147_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M147_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T147 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_09");
			};
			return;
		};
	};
	FUNL_T147 = FUNL_T147 + 1;
	if (FUNL_T147 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T147 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M147_T0, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M147_T1, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M147_T2, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M147_T3, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M147_T4, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M147_T5, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else
	{
		Wld_InsertNpc(FUN_M147_T0, "NW_TROLLAREA_PORTALTEMPEL_09");
	};
};
func void Fun_Platz148()   // NW_TROLLAREA_PORTALTEMPEL_09 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M148_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M148_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M148_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M148_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M148_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M148_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M148_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T148 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_09");
			};
			return;
		};
	};
	FUNL_T148 = FUNL_T148 + 1;
	if (FUNL_T148 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T148 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M148_T0, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M148_T1, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M148_T2, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M148_T3, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M148_T4, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M148_T5, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else
	{
		Wld_InsertNpc(FUN_M148_T0, "NW_TROLLAREA_PORTALTEMPEL_09");
	};
};
func void Fun_Platz149()   // NW_TROLLAREA_PORTALTEMPEL_09 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M149_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M149_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M149_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M149_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M149_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M149_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M149_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T149 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_09");
			};
			return;
		};
	};
	FUNL_T149 = FUNL_T149 + 1;
	if (FUNL_T149 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T149 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M149_T0, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M149_T1, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M149_T2, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M149_T3, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M149_T4, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M149_T5, "NW_TROLLAREA_PORTALTEMPEL_09");
	}
	else
	{
		Wld_InsertNpc(FUN_M149_T0, "NW_TROLLAREA_PORTALTEMPEL_09");
	};
};
func void Fun_Platz150()   // NW_TROLLAREA_PORTALTEMPEL_12 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M150_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M150_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M150_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M150_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M150_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M150_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M150_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T150 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_12");
			};
			return;
		};
	};
	FUNL_T150 = FUNL_T150 + 1;
	if (FUNL_T150 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T150 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M150_T0, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M150_T1, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M150_T2, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M150_T3, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M150_T4, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M150_T5, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else
	{
		Wld_InsertNpc(FUN_M150_T0, "NW_TROLLAREA_PORTALTEMPEL_12");
	};
};
func void Fun_Platz151()   // NW_TROLLAREA_PORTALTEMPEL_12 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M151_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M151_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M151_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M151_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M151_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M151_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M151_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T151 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_12");
			};
			return;
		};
	};
	FUNL_T151 = FUNL_T151 + 1;
	if (FUNL_T151 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T151 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M151_T0, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M151_T1, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M151_T2, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M151_T3, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M151_T4, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M151_T5, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else
	{
		Wld_InsertNpc(FUN_M151_T0, "NW_TROLLAREA_PORTALTEMPEL_12");
	};
};
func void Fun_Platz152()   // NW_TROLLAREA_PORTALTEMPEL_12 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M152_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M152_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M152_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M152_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M152_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M152_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M152_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T152 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_12");
			};
			return;
		};
	};
	FUNL_T152 = FUNL_T152 + 1;
	if (FUNL_T152 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T152 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M152_T0, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M152_T1, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M152_T2, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M152_T3, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M152_T4, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M152_T5, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else
	{
		Wld_InsertNpc(FUN_M152_T0, "NW_TROLLAREA_PORTALTEMPEL_12");
	};
};
func void Fun_Platz153()   // NW_TROLLAREA_PORTALTEMPEL_15_A (Original: Gobbo_Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M153_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M153_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M153_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M153_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M153_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M153_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M153_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T153 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_15_A");
			};
			return;
		};
	};
	FUNL_T153 = FUNL_T153 + 1;
	if (FUNL_T153 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T153 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M153_T2, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M153_T3, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M153_T4, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M153_T5, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M153_T6, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M153_T7, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else
	{
		Wld_InsertNpc(FUN_M153_T2, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	};
};
func void Fun_Platz154()   // NW_TROLLAREA_PORTALTEMPEL_15_A (Original: Gobbo_Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M154_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M154_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M154_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M154_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M154_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M154_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M154_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T154 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_15_A");
			};
			return;
		};
	};
	FUNL_T154 = FUNL_T154 + 1;
	if (FUNL_T154 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T154 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M154_T2, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M154_T3, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M154_T4, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M154_T5, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M154_T6, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M154_T7, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else
	{
		Wld_InsertNpc(FUN_M154_T2, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	};
};
func void Fun_Platz155()   // NW_TROLLAREA_PORTALTEMPEL_15_A (Original: Gobbo_Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M155_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M155_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M155_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M155_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M155_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M155_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M155_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T155 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_15_A");
			};
			return;
		};
	};
	FUNL_T155 = FUNL_T155 + 1;
	if (FUNL_T155 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T155 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M155_T2, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M155_T3, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M155_T4, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M155_T5, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M155_T6, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M155_T7, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	}
	else
	{
		Wld_InsertNpc(FUN_M155_T2, "NW_TROLLAREA_PORTALTEMPEL_15_A");
	};
};
func void Fun_Platz156()   // NW_TROLLAREA_PORTALTEMPEL_15_B (Original: Gobbo_Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M156_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M156_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M156_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M156_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M156_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M156_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M156_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T156 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_15_B");
			};
			return;
		};
	};
	FUNL_T156 = FUNL_T156 + 1;
	if (FUNL_T156 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T156 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M156_T2, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M156_T3, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M156_T4, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M156_T5, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M156_T6, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M156_T7, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else
	{
		Wld_InsertNpc(FUN_M156_T2, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	};
};
func void Fun_Platz157()   // NW_TROLLAREA_PORTALTEMPEL_15_B (Original: Gobbo_Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M157_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M157_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M157_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M157_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M157_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M157_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M157_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T157 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_15_B");
			};
			return;
		};
	};
	FUNL_T157 = FUNL_T157 + 1;
	if (FUNL_T157 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T157 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M157_T2, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M157_T3, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M157_T4, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M157_T5, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M157_T6, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M157_T7, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else
	{
		Wld_InsertNpc(FUN_M157_T2, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	};
};
func void Fun_Platz158()   // NW_TROLLAREA_PORTALTEMPEL_15_B (Original: Gobbo_Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M158_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M158_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M158_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M158_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M158_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M158_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M158_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T158 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_PORTALTEMPEL_15_B");
			};
			return;
		};
	};
	FUNL_T158 = FUNL_T158 + 1;
	if (FUNL_T158 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T158 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M158_T2, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M158_T3, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M158_T4, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M158_T5, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M158_T6, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M158_T7, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	}
	else
	{
		Wld_InsertNpc(FUN_M158_T2, "NW_TROLLAREA_PORTALTEMPEL_15_B");
	};
};
func void Fun_Platz159()   // NW_TROLLAREA_RITUALFOREST_04_MONSTER (Original: Molerat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M159_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M159_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M159_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M159_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M159_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M159_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M159_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T159 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
			};
			return;
		};
	};
	FUNL_T159 = FUNL_T159 + 1;
	if (FUNL_T159 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T159 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M159_T0, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M159_T1, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M159_T2, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M159_T3, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M159_T4, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M159_T5, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M159_T0, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	};
};
func void Fun_Platz160()   // NW_TROLLAREA_RITUALFOREST_04_MONSTER (Original: Molerat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M160_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M160_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M160_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M160_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M160_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M160_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M160_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T160 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
			};
			return;
		};
	};
	FUNL_T160 = FUNL_T160 + 1;
	if (FUNL_T160 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T160 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M160_T0, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M160_T1, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M160_T2, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M160_T3, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M160_T4, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M160_T5, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M160_T0, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	};
};
func void Fun_Platz161()   // NW_TROLLAREA_RITUALFOREST_04_MONSTER (Original: Molerat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M161_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M161_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M161_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M161_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M161_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M161_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M161_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T161 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
			};
			return;
		};
	};
	FUNL_T161 = FUNL_T161 + 1;
	if (FUNL_T161 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T161 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M161_T0, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M161_T1, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M161_T2, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M161_T3, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M161_T4, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M161_T5, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M161_T0, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	};
};
func void Fun_Platz162()   // NW_TROLLAREA_RITUALFOREST_06_MONSTER (Original: Molerat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M162_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M162_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M162_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M162_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M162_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M162_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M162_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T162 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
			};
			return;
		};
	};
	FUNL_T162 = FUNL_T162 + 1;
	if (FUNL_T162 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T162 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M162_T0, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M162_T1, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M162_T2, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M162_T3, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M162_T4, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M162_T5, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M162_T0, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	};
};
func void Fun_Platz163()   // NW_TROLLAREA_RITUALFOREST_06_MONSTER (Original: Molerat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M163_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M163_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M163_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M163_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M163_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M163_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M163_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T163 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
			};
			return;
		};
	};
	FUNL_T163 = FUNL_T163 + 1;
	if (FUNL_T163 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T163 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M163_T0, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M163_T1, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M163_T2, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M163_T3, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M163_T4, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M163_T5, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M163_T0, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	};
};
func void Fun_Platz164()   // NW_TROLLAREA_RITUALFOREST_06_MONSTER (Original: Molerat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M164_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M164_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M164_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M164_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M164_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M164_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M164_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T164 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
			};
			return;
		};
	};
	FUNL_T164 = FUNL_T164 + 1;
	if (FUNL_T164 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T164 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M164_T0, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M164_T1, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M164_T2, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M164_T3, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M164_T4, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M164_T5, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M164_T0, "NW_TROLLAREA_RITUALFOREST_06_MONSTER");
	};
};
func void Fun_Platz165()   // NW_TROLLAREA_RITUALPATH_032 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M165_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M165_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M165_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M165_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M165_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M165_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M165_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T165 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RITUALPATH_032");
			};
			return;
		};
	};
	FUNL_T165 = FUNL_T165 + 1;
	if (FUNL_T165 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T165 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M165_T0, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M165_T1, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M165_T2, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M165_T3, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M165_T4, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M165_T5, "NW_TROLLAREA_RITUALPATH_032");
	}
	else
	{
		Wld_InsertNpc(FUN_M165_T0, "NW_TROLLAREA_RITUALPATH_032");
	};
};
func void Fun_Platz166()   // NW_TROLLAREA_RITUALPATH_032 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M166_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M166_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M166_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M166_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M166_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M166_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M166_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T166 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RITUALPATH_032");
			};
			return;
		};
	};
	FUNL_T166 = FUNL_T166 + 1;
	if (FUNL_T166 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T166 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M166_T0, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M166_T1, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M166_T2, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M166_T3, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M166_T4, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M166_T5, "NW_TROLLAREA_RITUALPATH_032");
	}
	else
	{
		Wld_InsertNpc(FUN_M166_T0, "NW_TROLLAREA_RITUALPATH_032");
	};
};
func void Fun_Platz167()   // NW_TROLLAREA_RITUALPATH_032 (Original: Bloodfly)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M167_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M167_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M167_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M167_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M167_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M167_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M167_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T167 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RITUALPATH_032");
			};
			return;
		};
	};
	FUNL_T167 = FUNL_T167 + 1;
	if (FUNL_T167 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T167 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M167_T0, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M167_T1, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M167_T2, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M167_T3, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M167_T4, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M167_T5, "NW_TROLLAREA_RITUALPATH_032");
	}
	else
	{
		Wld_InsertNpc(FUN_M167_T0, "NW_TROLLAREA_RITUALPATH_032");
	};
};
func void Fun_Platz168()   // NW_TROLLAREA_RITUALPATH_04 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M168_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M168_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M168_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M168_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M168_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M168_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M168_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T168 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RITUALPATH_04");
			};
			return;
		};
	};
	FUNL_T168 = FUNL_T168 + 1;
	if (FUNL_T168 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T168 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M168_T0, "NW_TROLLAREA_RITUALPATH_04");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M168_T1, "NW_TROLLAREA_RITUALPATH_04");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M168_T2, "NW_TROLLAREA_RITUALPATH_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M168_T3, "NW_TROLLAREA_RITUALPATH_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M168_T4, "NW_TROLLAREA_RITUALPATH_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M168_T5, "NW_TROLLAREA_RITUALPATH_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M168_T0, "NW_TROLLAREA_RITUALPATH_04");
	};
};
func void Fun_Platz169()   // NW_TROLLAREA_RITUALPATH_04 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M169_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M169_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M169_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M169_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M169_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M169_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M169_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T169 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RITUALPATH_04");
			};
			return;
		};
	};
	FUNL_T169 = FUNL_T169 + 1;
	if (FUNL_T169 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T169 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M169_T0, "NW_TROLLAREA_RITUALPATH_04");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M169_T1, "NW_TROLLAREA_RITUALPATH_04");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M169_T2, "NW_TROLLAREA_RITUALPATH_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M169_T3, "NW_TROLLAREA_RITUALPATH_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M169_T4, "NW_TROLLAREA_RITUALPATH_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M169_T5, "NW_TROLLAREA_RITUALPATH_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M169_T0, "NW_TROLLAREA_RITUALPATH_04");
	};
};
func void Fun_Platz170()   // NW_TROLLAREA_RITUALPATH_04 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M170_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M170_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M170_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M170_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M170_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M170_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M170_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T170 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RITUALPATH_04");
			};
			return;
		};
	};
	FUNL_T170 = FUNL_T170 + 1;
	if (FUNL_T170 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T170 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M170_T0, "NW_TROLLAREA_RITUALPATH_04");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M170_T1, "NW_TROLLAREA_RITUALPATH_04");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M170_T2, "NW_TROLLAREA_RITUALPATH_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M170_T3, "NW_TROLLAREA_RITUALPATH_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M170_T4, "NW_TROLLAREA_RITUALPATH_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M170_T5, "NW_TROLLAREA_RITUALPATH_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M170_T0, "NW_TROLLAREA_RITUALPATH_04");
	};
};
func void Fun_Platz171()   // NW_TROLLAREA_RITUAL_13 (Original: Gobbo_Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M171_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M171_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M171_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M171_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M171_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M171_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M171_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T171 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RITUAL_13");
			};
			return;
		};
	};
	FUNL_T171 = FUNL_T171 + 1;
	if (FUNL_T171 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T171 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M171_T2, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M171_T3, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M171_T4, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M171_T5, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M171_T6, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M171_T7, "NW_TROLLAREA_RITUAL_13");
	}
	else
	{
		Wld_InsertNpc(FUN_M171_T2, "NW_TROLLAREA_RITUAL_13");
	};
};
func void Fun_Platz172()   // NW_TROLLAREA_RITUAL_13 (Original: Gobbo_Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M172_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M172_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M172_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M172_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M172_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M172_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M172_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T172 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RITUAL_13");
			};
			return;
		};
	};
	FUNL_T172 = FUNL_T172 + 1;
	if (FUNL_T172 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T172 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M172_T2, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M172_T3, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M172_T4, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M172_T5, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M172_T6, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M172_T7, "NW_TROLLAREA_RITUAL_13");
	}
	else
	{
		Wld_InsertNpc(FUN_M172_T2, "NW_TROLLAREA_RITUAL_13");
	};
};
func void Fun_Platz173()   // NW_TROLLAREA_RITUAL_13 (Original: Gobbo_Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M173_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M173_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M173_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M173_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M173_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M173_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M173_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T173 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RITUAL_13");
			};
			return;
		};
	};
	FUNL_T173 = FUNL_T173 + 1;
	if (FUNL_T173 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T173 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M173_T2, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M173_T3, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M173_T4, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M173_T5, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M173_T6, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M173_T7, "NW_TROLLAREA_RITUAL_13");
	}
	else
	{
		Wld_InsertNpc(FUN_M173_T2, "NW_TROLLAREA_RITUAL_13");
	};
};
func void Fun_Platz174()   // NW_TROLLAREA_RIVERSIDECAVE_02 (Original: Shadowbeast)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M174_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M174_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M174_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M174_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M174_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M174_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M174_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T174 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RIVERSIDECAVE_02");
			};
			return;
		};
	};
	FUNL_T174 = FUNL_T174 + 1;
	if (FUNL_T174 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T174 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M174_T2, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M174_T3, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M174_T4, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M174_T5, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M174_T6, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M174_T7, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M174_T2, "NW_TROLLAREA_RIVERSIDECAVE_02");
	};
};
func void Fun_Platz175()   // NW_TROLLAREA_RIVERSIDECAVE_02 (Original: Shadowbeast)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M175_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M175_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M175_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M175_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M175_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M175_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M175_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T175 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RIVERSIDECAVE_02");
			};
			return;
		};
	};
	FUNL_T175 = FUNL_T175 + 1;
	if (FUNL_T175 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T175 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M175_T2, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M175_T3, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M175_T4, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M175_T5, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M175_T6, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M175_T7, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M175_T2, "NW_TROLLAREA_RIVERSIDECAVE_02");
	};
};
func void Fun_Platz176()   // NW_TROLLAREA_RIVERSIDECAVE_02 (Original: Shadowbeast)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M176_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M176_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M176_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M176_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M176_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M176_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M176_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T176 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RIVERSIDECAVE_02");
			};
			return;
		};
	};
	FUNL_T176 = FUNL_T176 + 1;
	if (FUNL_T176 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T176 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M176_T2, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M176_T3, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M176_T4, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M176_T5, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M176_T6, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M176_T7, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M176_T2, "NW_TROLLAREA_RIVERSIDECAVE_02");
	};
};
func void Fun_Platz177()   // NW_TROLLAREA_RIVERSIDECAVE_07 (Original: Shadowbeast)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M177_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M177_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M177_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M177_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M177_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M177_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M177_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T177 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RIVERSIDECAVE_07");
			};
			return;
		};
	};
	FUNL_T177 = FUNL_T177 + 1;
	if (FUNL_T177 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T177 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M177_T2, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M177_T3, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M177_T4, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M177_T5, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M177_T6, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M177_T7, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else
	{
		Wld_InsertNpc(FUN_M177_T2, "NW_TROLLAREA_RIVERSIDECAVE_07");
	};
};
func void Fun_Platz178()   // NW_TROLLAREA_RIVERSIDECAVE_07 (Original: Shadowbeast)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M178_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M178_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M178_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M178_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M178_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M178_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M178_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T178 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RIVERSIDECAVE_07");
			};
			return;
		};
	};
	FUNL_T178 = FUNL_T178 + 1;
	if (FUNL_T178 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T178 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M178_T2, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M178_T3, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M178_T4, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M178_T5, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M178_T6, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M178_T7, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else
	{
		Wld_InsertNpc(FUN_M178_T2, "NW_TROLLAREA_RIVERSIDECAVE_07");
	};
};
func void Fun_Platz179()   // NW_TROLLAREA_RIVERSIDECAVE_07 (Original: Shadowbeast)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M179_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M179_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M179_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M179_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M179_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M179_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M179_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T179 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RIVERSIDECAVE_07");
			};
			return;
		};
	};
	FUNL_T179 = FUNL_T179 + 1;
	if (FUNL_T179 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T179 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M179_T2, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M179_T3, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M179_T4, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M179_T5, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M179_T6, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M179_T7, "NW_TROLLAREA_RIVERSIDECAVE_07");
	}
	else
	{
		Wld_InsertNpc(FUN_M179_T2, "NW_TROLLAREA_RIVERSIDECAVE_07");
	};
};
func void Fun_Platz180()   // NW_TROLLAREA_RUINS_14 (Original: Gobbo_Black)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M180_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M180_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M180_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M180_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M180_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M180_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M180_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T180 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RUINS_14");
			};
			return;
		};
	};
	FUNL_T180 = FUNL_T180 + 1;
	if (FUNL_T180 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T180 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M180_T2, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M180_T3, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M180_T4, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M180_T5, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M180_T6, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M180_T7, "NW_TROLLAREA_RUINS_14");
	}
	else
	{
		Wld_InsertNpc(FUN_M180_T2, "NW_TROLLAREA_RUINS_14");
	};
};
func void Fun_Platz181()   // NW_TROLLAREA_RUINS_14 (Original: Gobbo_Black)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M181_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M181_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M181_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M181_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M181_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M181_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M181_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T181 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RUINS_14");
			};
			return;
		};
	};
	FUNL_T181 = FUNL_T181 + 1;
	if (FUNL_T181 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T181 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M181_T2, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M181_T3, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M181_T4, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M181_T5, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M181_T6, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M181_T7, "NW_TROLLAREA_RUINS_14");
	}
	else
	{
		Wld_InsertNpc(FUN_M181_T2, "NW_TROLLAREA_RUINS_14");
	};
};
func void Fun_Platz182()   // NW_TROLLAREA_RUINS_14 (Original: Gobbo_Black)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M182_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M182_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M182_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M182_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M182_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M182_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M182_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T182 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RUINS_14");
			};
			return;
		};
	};
	FUNL_T182 = FUNL_T182 + 1;
	if (FUNL_T182 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T182 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M182_T2, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M182_T3, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M182_T4, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M182_T5, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M182_T6, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M182_T7, "NW_TROLLAREA_RUINS_14");
	}
	else
	{
		Wld_InsertNpc(FUN_M182_T2, "NW_TROLLAREA_RUINS_14");
	};
};
func void Fun_Platz183()   // NW_TROLLAREA_RUINS_17 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M183_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M183_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M183_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M183_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M183_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M183_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M183_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T183 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RUINS_17");
			};
			return;
		};
	};
	FUNL_T183 = FUNL_T183 + 1;
	if (FUNL_T183 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T183 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M183_T0, "NW_TROLLAREA_RUINS_17");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M183_T1, "NW_TROLLAREA_RUINS_17");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M183_T2, "NW_TROLLAREA_RUINS_17");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M183_T3, "NW_TROLLAREA_RUINS_17");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M183_T4, "NW_TROLLAREA_RUINS_17");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M183_T5, "NW_TROLLAREA_RUINS_17");
	}
	else
	{
		Wld_InsertNpc(FUN_M183_T0, "NW_TROLLAREA_RUINS_17");
	};
};
func void Fun_Platz184()   // NW_TROLLAREA_RUINS_17 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M184_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M184_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M184_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M184_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M184_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M184_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M184_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T184 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RUINS_17");
			};
			return;
		};
	};
	FUNL_T184 = FUNL_T184 + 1;
	if (FUNL_T184 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T184 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M184_T0, "NW_TROLLAREA_RUINS_17");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M184_T1, "NW_TROLLAREA_RUINS_17");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M184_T2, "NW_TROLLAREA_RUINS_17");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M184_T3, "NW_TROLLAREA_RUINS_17");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M184_T4, "NW_TROLLAREA_RUINS_17");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M184_T5, "NW_TROLLAREA_RUINS_17");
	}
	else
	{
		Wld_InsertNpc(FUN_M184_T0, "NW_TROLLAREA_RUINS_17");
	};
};
func void Fun_Platz185()   // NW_TROLLAREA_RUINS_17 (Original: Scavenger)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M185_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M185_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M185_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M185_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M185_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M185_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M185_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T185 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RUINS_17");
			};
			return;
		};
	};
	FUNL_T185 = FUNL_T185 + 1;
	if (FUNL_T185 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T185 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M185_T0, "NW_TROLLAREA_RUINS_17");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M185_T1, "NW_TROLLAREA_RUINS_17");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M185_T2, "NW_TROLLAREA_RUINS_17");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M185_T3, "NW_TROLLAREA_RUINS_17");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M185_T4, "NW_TROLLAREA_RUINS_17");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M185_T5, "NW_TROLLAREA_RUINS_17");
	}
	else
	{
		Wld_InsertNpc(FUN_M185_T0, "NW_TROLLAREA_RUINS_17");
	};
};
func void Fun_Platz186()   // NW_TROLLAREA_RUINS_21 (Original: FireWaran)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M186_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M186_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M186_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M186_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M186_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M186_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M186_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T186 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RUINS_21");
			};
			return;
		};
	};
	FUNL_T186 = FUNL_T186 + 1;
	if (FUNL_T186 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T186 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M186_T2, "NW_TROLLAREA_RUINS_21");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M186_T3, "NW_TROLLAREA_RUINS_21");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M186_T4, "NW_TROLLAREA_RUINS_21");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M186_T5, "NW_TROLLAREA_RUINS_21");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M186_T6, "NW_TROLLAREA_RUINS_21");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M186_T7, "NW_TROLLAREA_RUINS_21");
	}
	else
	{
		Wld_InsertNpc(FUN_M186_T2, "NW_TROLLAREA_RUINS_21");
	};
};
func void Fun_Platz187()   // NW_TROLLAREA_RUINS_21 (Original: FireWaran)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M187_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M187_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M187_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M187_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M187_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M187_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M187_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T187 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RUINS_21");
			};
			return;
		};
	};
	FUNL_T187 = FUNL_T187 + 1;
	if (FUNL_T187 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T187 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M187_T2, "NW_TROLLAREA_RUINS_21");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M187_T3, "NW_TROLLAREA_RUINS_21");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M187_T4, "NW_TROLLAREA_RUINS_21");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M187_T5, "NW_TROLLAREA_RUINS_21");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M187_T6, "NW_TROLLAREA_RUINS_21");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M187_T7, "NW_TROLLAREA_RUINS_21");
	}
	else
	{
		Wld_InsertNpc(FUN_M187_T2, "NW_TROLLAREA_RUINS_21");
	};
};
func void Fun_Platz188()   // NW_TROLLAREA_RUINS_21 (Original: FireWaran)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M188_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M188_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M188_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M188_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M188_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M188_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M188_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T188 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RUINS_21");
			};
			return;
		};
	};
	FUNL_T188 = FUNL_T188 + 1;
	if (FUNL_T188 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T188 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M188_T2, "NW_TROLLAREA_RUINS_21");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M188_T3, "NW_TROLLAREA_RUINS_21");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M188_T4, "NW_TROLLAREA_RUINS_21");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M188_T5, "NW_TROLLAREA_RUINS_21");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M188_T6, "NW_TROLLAREA_RUINS_21");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M188_T7, "NW_TROLLAREA_RUINS_21");
	}
	else
	{
		Wld_InsertNpc(FUN_M188_T2, "NW_TROLLAREA_RUINS_21");
	};
};
func void Fun_Platz189()   // NW_TROLLAREA_RUINS_32 (Original: Waran)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M189_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M189_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M189_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M189_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M189_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M189_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M189_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T189 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RUINS_32");
			};
			return;
		};
	};
	FUNL_T189 = FUNL_T189 + 1;
	if (FUNL_T189 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T189 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M189_T2, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M189_T3, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M189_T4, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M189_T5, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M189_T6, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M189_T7, "NW_TROLLAREA_RUINS_32");
	}
	else
	{
		Wld_InsertNpc(FUN_M189_T2, "NW_TROLLAREA_RUINS_32");
	};
};
func void Fun_Platz190()   // NW_TROLLAREA_RUINS_32 (Original: Waran)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M190_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M190_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M190_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M190_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M190_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M190_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M190_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T190 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RUINS_32");
			};
			return;
		};
	};
	FUNL_T190 = FUNL_T190 + 1;
	if (FUNL_T190 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T190 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M190_T2, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M190_T3, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M190_T4, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M190_T5, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M190_T6, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M190_T7, "NW_TROLLAREA_RUINS_32");
	}
	else
	{
		Wld_InsertNpc(FUN_M190_T2, "NW_TROLLAREA_RUINS_32");
	};
};
func void Fun_Platz191()   // NW_TROLLAREA_RUINS_32 (Original: Waran)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M191_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M191_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M191_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M191_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M191_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M191_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M191_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T191 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_RUINS_32");
			};
			return;
		};
	};
	FUNL_T191 = FUNL_T191 + 1;
	if (FUNL_T191 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T191 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M191_T2, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M191_T3, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M191_T4, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M191_T5, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M191_T6, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M191_T7, "NW_TROLLAREA_RUINS_32");
	}
	else
	{
		Wld_InsertNpc(FUN_M191_T2, "NW_TROLLAREA_RUINS_32");
	};
};
func void Fun_Platz192()   // NW_TROLLAREA_TROLLLAKECAVE_02 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M192_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M192_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M192_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M192_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M192_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M192_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M192_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T192 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLLAKECAVE_02");
			};
			return;
		};
	};
	FUNL_T192 = FUNL_T192 + 1;
	if (FUNL_T192 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T192 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M192_T0, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M192_T1, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M192_T2, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M192_T3, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M192_T4, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M192_T5, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M192_T0, "NW_TROLLAREA_TROLLLAKECAVE_02");
	};
};
func void Fun_Platz193()   // NW_TROLLAREA_TROLLLAKECAVE_02 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M193_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M193_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M193_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M193_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M193_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M193_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M193_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T193 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLLAKECAVE_02");
			};
			return;
		};
	};
	FUNL_T193 = FUNL_T193 + 1;
	if (FUNL_T193 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T193 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M193_T0, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M193_T1, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M193_T2, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M193_T3, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M193_T4, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M193_T5, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M193_T0, "NW_TROLLAREA_TROLLLAKECAVE_02");
	};
};
func void Fun_Platz194()   // NW_TROLLAREA_TROLLLAKECAVE_02 (Original: Giant_Rat)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M194_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M194_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M194_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M194_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M194_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M194_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M194_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T194 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLLAKECAVE_02");
			};
			return;
		};
	};
	FUNL_T194 = FUNL_T194 + 1;
	if (FUNL_T194 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T194 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M194_T0, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M194_T1, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M194_T2, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M194_T3, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M194_T4, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M194_T5, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M194_T0, "NW_TROLLAREA_TROLLLAKECAVE_02");
	};
};
func void Fun_Platz195()   // NW_TROLLAREA_TROLLLAKECAVE_03A (Original: Meatbug)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M195_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M195_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M195_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M195_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M195_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M195_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M195_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T195 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLLAKECAVE_03A");
			};
			return;
		};
	};
	FUNL_T195 = FUNL_T195 + 1;
	if (FUNL_T195 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T195 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M195_T0, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M195_T1, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M195_T2, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M195_T3, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M195_T4, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M195_T5, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else
	{
		Wld_InsertNpc(FUN_M195_T0, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	};
};
func void Fun_Platz196()   // NW_TROLLAREA_TROLLLAKECAVE_03A (Original: Meatbug)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M196_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M196_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M196_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M196_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M196_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M196_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M196_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T196 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLLAKECAVE_03A");
			};
			return;
		};
	};
	FUNL_T196 = FUNL_T196 + 1;
	if (FUNL_T196 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T196 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M196_T0, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M196_T1, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M196_T2, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M196_T3, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M196_T4, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M196_T5, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else
	{
		Wld_InsertNpc(FUN_M196_T0, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	};
};
func void Fun_Platz197()   // NW_TROLLAREA_TROLLLAKECAVE_03A (Original: Meatbug)
{
	var C_NPC m;
	var int t;
	t = 0 + Fun_KapitelNr() - 1;
	if (t > 5)
	{
		t = 5;
	};
	if (t == 0)
	{
		m = Hlp_GetNpc(FUN_M197_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M197_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M197_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M197_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M197_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M197_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M197_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T197 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLLAKECAVE_03A");
			};
			return;
		};
	};
	FUNL_T197 = FUNL_T197 + 1;
	if (FUNL_T197 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T197 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M197_T0, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M197_T1, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M197_T2, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M197_T3, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M197_T4, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M197_T5, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	}
	else
	{
		Wld_InsertNpc(FUN_M197_T0, "NW_TROLLAREA_TROLLLAKECAVE_03A");
	};
};
func void Fun_Platz198()   // NW_TROLLAREA_TROLLLAKECAVE_08 (Original: Gobbo_Warrior)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M198_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M198_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M198_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M198_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M198_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M198_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M198_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T198 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLLAKECAVE_08");
			};
			return;
		};
	};
	FUNL_T198 = FUNL_T198 + 1;
	if (FUNL_T198 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T198 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M198_T2, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M198_T3, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M198_T4, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M198_T5, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M198_T6, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M198_T7, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else
	{
		Wld_InsertNpc(FUN_M198_T2, "NW_TROLLAREA_TROLLLAKECAVE_08");
	};
};
func void Fun_Platz199()   // NW_TROLLAREA_TROLLLAKECAVE_08 (Original: Gobbo_Warrior)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M199_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M199_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M199_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M199_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M199_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M199_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M199_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T199 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLLAKECAVE_08");
			};
			return;
		};
	};
	FUNL_T199 = FUNL_T199 + 1;
	if (FUNL_T199 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T199 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M199_T2, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M199_T3, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M199_T4, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M199_T5, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M199_T6, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M199_T7, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else
	{
		Wld_InsertNpc(FUN_M199_T2, "NW_TROLLAREA_TROLLLAKECAVE_08");
	};
};
func void Fun_Platz200()   // NW_TROLLAREA_TROLLLAKECAVE_08 (Original: Gobbo_Warrior)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M200_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M200_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M200_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M200_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M200_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M200_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M200_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T200 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLLAKECAVE_08");
			};
			return;
		};
	};
	FUNL_T200 = FUNL_T200 + 1;
	if (FUNL_T200 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T200 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M200_T2, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M200_T3, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M200_T4, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M200_T5, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M200_T6, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M200_T7, "NW_TROLLAREA_TROLLLAKECAVE_08");
	}
	else
	{
		Wld_InsertNpc(FUN_M200_T2, "NW_TROLLAREA_TROLLLAKECAVE_08");
	};
};
func void Fun_Platz201()   // NW_TROLLAREA_TROLLLAKECAVE_09 (Original: Gobbo_Green)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M201_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M201_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M201_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M201_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M201_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M201_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M201_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T201 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLLAKECAVE_09");
			};
			return;
		};
	};
	FUNL_T201 = FUNL_T201 + 1;
	if (FUNL_T201 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T201 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M201_T2, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M201_T3, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M201_T4, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M201_T5, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M201_T6, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M201_T7, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else
	{
		Wld_InsertNpc(FUN_M201_T2, "NW_TROLLAREA_TROLLLAKECAVE_09");
	};
};
func void Fun_Platz202()   // NW_TROLLAREA_TROLLLAKECAVE_09 (Original: Gobbo_Green)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M202_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M202_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M202_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M202_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M202_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M202_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M202_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T202 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLLAKECAVE_09");
			};
			return;
		};
	};
	FUNL_T202 = FUNL_T202 + 1;
	if (FUNL_T202 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T202 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M202_T2, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M202_T3, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M202_T4, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M202_T5, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M202_T6, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M202_T7, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else
	{
		Wld_InsertNpc(FUN_M202_T2, "NW_TROLLAREA_TROLLLAKECAVE_09");
	};
};
func void Fun_Platz203()   // NW_TROLLAREA_TROLLLAKECAVE_09 (Original: Gobbo_Green)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M203_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M203_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M203_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M203_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M203_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M203_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M203_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T203 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLLAKECAVE_09");
			};
			return;
		};
	};
	FUNL_T203 = FUNL_T203 + 1;
	if (FUNL_T203 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T203 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M203_T2, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M203_T3, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M203_T4, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M203_T5, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M203_T6, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M203_T7, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else
	{
		Wld_InsertNpc(FUN_M203_T2, "NW_TROLLAREA_TROLLLAKECAVE_09");
	};
};
func void Fun_Platz204()   // NW_TROLLAREA_TROLLROCKCAVE_03 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M204_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M204_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M204_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M204_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M204_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M204_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M204_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T204 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLROCKCAVE_03");
			};
			return;
		};
	};
	FUNL_T204 = FUNL_T204 + 1;
	if (FUNL_T204 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T204 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M204_T2, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M204_T3, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M204_T4, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M204_T5, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M204_T6, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M204_T7, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M204_T2, "NW_TROLLAREA_TROLLROCKCAVE_03");
	};
};
func void Fun_Platz205()   // NW_TROLLAREA_TROLLROCKCAVE_03 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M205_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M205_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M205_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M205_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M205_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M205_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M205_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T205 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLROCKCAVE_03");
			};
			return;
		};
	};
	FUNL_T205 = FUNL_T205 + 1;
	if (FUNL_T205 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T205 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M205_T2, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M205_T3, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M205_T4, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M205_T5, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M205_T6, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M205_T7, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M205_T2, "NW_TROLLAREA_TROLLROCKCAVE_03");
	};
};
func void Fun_Platz206()   // NW_TROLLAREA_TROLLROCKCAVE_03 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M206_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M206_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M206_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M206_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M206_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M206_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M206_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T206 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLROCKCAVE_03");
			};
			return;
		};
	};
	FUNL_T206 = FUNL_T206 + 1;
	if (FUNL_T206 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T206 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M206_T2, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M206_T3, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M206_T4, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M206_T5, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M206_T6, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M206_T7, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M206_T2, "NW_TROLLAREA_TROLLROCKCAVE_03");
	};
};
func void Fun_Platz207()   // NW_TROLLAREA_TROLLROCKCAVE_05 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M207_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M207_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M207_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M207_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M207_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M207_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M207_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T207 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLROCKCAVE_05");
			};
			return;
		};
	};
	FUNL_T207 = FUNL_T207 + 1;
	if (FUNL_T207 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T207 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M207_T2, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M207_T3, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M207_T4, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M207_T5, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M207_T6, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M207_T7, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else
	{
		Wld_InsertNpc(FUN_M207_T2, "NW_TROLLAREA_TROLLROCKCAVE_05");
	};
};
func void Fun_Platz208()   // NW_TROLLAREA_TROLLROCKCAVE_05 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M208_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M208_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M208_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M208_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M208_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M208_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M208_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T208 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLROCKCAVE_05");
			};
			return;
		};
	};
	FUNL_T208 = FUNL_T208 + 1;
	if (FUNL_T208 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T208 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M208_T2, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M208_T3, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M208_T4, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M208_T5, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M208_T6, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M208_T7, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else
	{
		Wld_InsertNpc(FUN_M208_T2, "NW_TROLLAREA_TROLLROCKCAVE_05");
	};
};
func void Fun_Platz209()   // NW_TROLLAREA_TROLLROCKCAVE_05 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 2 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M209_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M209_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M209_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M209_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M209_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M209_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M209_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T209 = 0;
			if (Fun_NaheLager(m))
			{
				AI_Teleport(m, "NW_TROLLAREA_TROLLROCKCAVE_05");
			};
			return;
		};
	};
	FUNL_T209 = FUNL_T209 + 1;
	if (FUNL_T209 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T209 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M209_T2, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M209_T3, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M209_T4, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M209_T5, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M209_T6, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M209_T7, "NW_TROLLAREA_TROLLROCKCAVE_05");
	}
	else
	{
		Wld_InsertNpc(FUN_M209_T2, "NW_TROLLAREA_TROLLROCKCAVE_05");
	};
};

func void Fun_Boss()
{
	var C_NPC b;
	if (Fun_KapitelNr() == 1)
	{
		b = Hlp_GetNpc(FUN_BOSS_K1);
	}
	else if (Fun_KapitelNr() == 2)
	{
		b = Hlp_GetNpc(FUN_BOSS_K2);
	}
	else if (Fun_KapitelNr() == 3)
	{
		b = Hlp_GetNpc(FUN_BOSS_K3);
	}
	else if (Fun_KapitelNr() == 4)
	{
		b = Hlp_GetNpc(FUN_BOSS_K4);
	}
	else if (Fun_KapitelNr() == 5)
	{
		b = Hlp_GetNpc(FUN_BOSS_K5);
	}
	else if (Fun_KapitelNr() == 6)
	{
		b = Hlp_GetNpc(FUN_BOSS_K6);
	}
	else
	{
		b = Hlp_GetNpc(FUN_BOSS_K1);
	};
	if (Fun_NpcLebt(b))
	{
		FUNL_BOSS_T = 0;
		return;
	};
	FUNL_BOSS_T = FUNL_BOSS_T + 1;
	if (FUNL_BOSS_T < FUN_BOSS_TAKTE)
	{
		return;
	};
	FUNL_BOSS_T = 0;
	if (Fun_KapitelNr() == 1)
	{
		Wld_InsertNpc(FUN_BOSS_K1, "NW_TAVERNE_CROSS");
	}
	else if (Fun_KapitelNr() == 2)
	{
		Wld_InsertNpc(FUN_BOSS_K2, "NW_TAVERNE_CROSS");
	}
	else if (Fun_KapitelNr() == 3)
	{
		Wld_InsertNpc(FUN_BOSS_K3, "NW_TAVERNE_CROSS");
	}
	else if (Fun_KapitelNr() == 4)
	{
		Wld_InsertNpc(FUN_BOSS_K4, "NW_TAVERNE_CROSS");
	}
	else if (Fun_KapitelNr() == 5)
	{
		Wld_InsertNpc(FUN_BOSS_K5, "NW_TAVERNE_CROSS");
	}
	else if (Fun_KapitelNr() == 6)
	{
		Wld_InsertNpc(FUN_BOSS_K6, "NW_TAVERNE_CROSS");
	}
	else
	{
		Wld_InsertNpc(FUN_BOSS_K1, "NW_TAVERNE_CROSS");
	};
	Print("An der Taverne ist ein neuer Boss aufgetaucht!");
};

// Händler fehlen nie, tote Begleiter kommen nach 5 Minuten zurück; beim Kapitelaufstieg werden die Begleiter stärker
func void Fun_Lager()
{
	var int fehlt;
	var C_NPC n;
	n = Hlp_GetNpc(FUN_HAENDLER_MIL);
	if (!Hlp_IsValidNpc(n))
	{
		Wld_InsertNpc(FUN_HAENDLER_MIL, "NW_CITY_HABOUR_KASERN_CENTRE_03");
	};
	n = Hlp_GetNpc(FUN_HAENDLER_SLD);
	if (!Hlp_IsValidNpc(n))
	{
		Wld_InsertNpc(FUN_HAENDLER_SLD, "NW_BIGFARM_HOUSE_08");
	};
	n = Hlp_GetNpc(FUN_HAENDLER_NOV);
	if (!Hlp_IsValidNpc(n))
	{
		Wld_InsertNpc(FUN_HAENDLER_NOV, "NW_MONASTERY_PLACE_07");
	};
	n = Hlp_GetNpc(FUN_HAENDLER_BDT);
	if (!Hlp_IsValidNpc(n))
	{
		Wld_InsertNpc(FUN_HAENDLER_BDT, "NW_CASTLEMINE_TOWER_CAMPFIRE_03");
	};
	fehlt = FALSE;
	n = Hlp_GetNpc(FUN_MIL_1);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_MIL_2);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_MIL_3);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_MIL_4);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_MIL_5);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_SLD_1);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_SLD_2);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_SLD_3);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_SLD_4);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_SLD_5);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_NOV_1);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_NOV_2);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_NOV_3);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_NOV_4);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_NOV_5);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_BDT_1);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_BDT_2);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_BDT_3);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_BDT_4);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	n = Hlp_GetNpc(FUN_BDT_5);
	if (!Fun_NpcLebt(n))
	{
		fehlt = TRUE;
	};
	if (fehlt)
	{
		FUNL_BEGL_T = FUNL_BEGL_T + 1;
		if (FUNL_BEGL_T >= FUN_BEGL_TAKTE)
		{
			FUNL_BEGL_T = 0;
			n = Hlp_GetNpc(FUN_MIL_1);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_MIL_1, "NW_CITY_HABOUR_KASERN_05_01");
			};
			n = Hlp_GetNpc(FUN_MIL_2);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_MIL_2, "NW_CITY_HABOUR_KASERN_08");
			};
			n = Hlp_GetNpc(FUN_MIL_3);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_MIL_3, "NW_CITY_HABOUR_KASERN_10");
			};
			n = Hlp_GetNpc(FUN_MIL_4);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_MIL_4, "NW_CITY_HABOUR_KASERN_12");
			};
			n = Hlp_GetNpc(FUN_MIL_5);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_MIL_5, "NW_CITY_HABOUR_KASERN_14");
			};
			n = Hlp_GetNpc(FUN_SLD_1);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_SLD_1, "NW_BIGFARM_HOUSE_12");
			};
			n = Hlp_GetNpc(FUN_SLD_2);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_SLD_2, "NW_BIGFARM_HOUSE_14");
			};
			n = Hlp_GetNpc(FUN_SLD_3);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_SLD_3, "NW_BIGFARM_ALLEE_04");
			};
			n = Hlp_GetNpc(FUN_SLD_4);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_SLD_4, "NW_BIGFARM_TREE");
			};
			n = Hlp_GetNpc(FUN_SLD_5);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_SLD_5, "NW_BIGFARM_KITCHEN_09");
			};
			n = Hlp_GetNpc(FUN_NOV_1);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_NOV_1, "NW_MONASTERY_PLACE_09");
			};
			n = Hlp_GetNpc(FUN_NOV_2);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_NOV_2, "NW_MONASTERY_GRASS_01");
			};
			n = Hlp_GetNpc(FUN_NOV_3);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_NOV_3, "NW_MONASTERY_HERB_05");
			};
			n = Hlp_GetNpc(FUN_NOV_4);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_NOV_4, "NW_MONASTERY_CHURCH_03");
			};
			n = Hlp_GetNpc(FUN_NOV_5);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_NOV_5, "NW_MONASTERY_CHAPELL_02");
			};
			n = Hlp_GetNpc(FUN_BDT_1);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_BDT_1, "NW_CASTLEMINE_TOWER_CAMPFIRE_02");
			};
			n = Hlp_GetNpc(FUN_BDT_2);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_BDT_2, "NW_CASTLEMINE_TOWER_CAMPFIRE_04");
			};
			n = Hlp_GetNpc(FUN_BDT_3);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_BDT_3, "NW_CASTLEMINE_TOWER_STAND_01");
			};
			n = Hlp_GetNpc(FUN_BDT_4);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_BDT_4, "NW_CASTLEMINE_TOWER_STAND_02");
			};
			n = Hlp_GetNpc(FUN_BDT_5);
			if (!Fun_NpcLebt(n))
			{
				Wld_InsertNpc(FUN_BDT_5, "NW_CASTLEMINE_TOWER_REP_HUT");
			};
		};
	}
	else
	{
		FUNL_BEGL_T = 0;
	};
	if (FUNL_BEGL_KAP < FUN_KAPITEL)
	{
		FUNL_BEGL_KAP = FUN_KAPITEL;
		n = Hlp_GetNpc(FUN_MIL_1);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_MIL_2);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_MIL_3);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_MIL_4);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_MIL_5);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_SLD_1);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_SLD_2);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_SLD_3);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_SLD_4);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_SLD_5);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_NOV_1);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_NOV_2);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_NOV_3);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_NOV_4);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_NOV_5);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_BDT_1);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_BDT_2);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_BDT_3);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_BDT_4);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
		n = Hlp_GetNpc(FUN_BDT_5);
		if (Fun_NpcLebt(n))
		{
			B_SetAttributesToChapter(n, Fun_KapitelNr());
			B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr());
		};
	};
};

func void FUN_TAKT_HOST()
{
	if (!FUN_AKTIV)
	{
		return;
	};
	Fun_Platz000();
	Fun_Platz001();
	Fun_Platz002();
	Fun_Platz003();
	Fun_Platz004();
	Fun_Platz005();
	Fun_Platz006();
	Fun_Platz007();
	Fun_Platz008();
	Fun_Platz009();
	Fun_Platz010();
	Fun_Platz011();
	Fun_Platz012();
	Fun_Platz013();
	Fun_Platz014();
	Fun_Platz015();
	Fun_Platz016();
	Fun_Platz017();
	Fun_Platz018();
	Fun_Platz019();
	Fun_Platz020();
	Fun_Platz021();
	Fun_Platz022();
	Fun_Platz023();
	Fun_Platz024();
	Fun_Platz025();
	Fun_Platz026();
	Fun_Platz027();
	Fun_Platz028();
	Fun_Platz029();
	Fun_Platz030();
	Fun_Platz031();
	Fun_Platz032();
	Fun_Platz033();
	Fun_Platz034();
	Fun_Platz035();
	Fun_Platz036();
	Fun_Platz037();
	Fun_Platz038();
	Fun_Platz039();
	Fun_Platz040();
	Fun_Platz041();
	Fun_Platz042();
	Fun_Platz043();
	Fun_Platz044();
	Fun_Platz045();
	Fun_Platz046();
	Fun_Platz047();
	Fun_Platz048();
	Fun_Platz049();
	Fun_Platz050();
	Fun_Platz051();
	Fun_Platz052();
	Fun_Platz053();
	Fun_Platz054();
	Fun_Platz055();
	Fun_Platz056();
	Fun_Platz057();
	Fun_Platz058();
	Fun_Platz059();
	Fun_Platz060();
	Fun_Platz061();
	Fun_Platz062();
	Fun_Platz063();
	Fun_Platz064();
	Fun_Platz065();
	Fun_Platz066();
	Fun_Platz067();
	Fun_Platz068();
	Fun_Platz069();
	Fun_Platz070();
	Fun_Platz071();
	Fun_Platz072();
	Fun_Platz073();
	Fun_Platz074();
	Fun_Platz075();
	Fun_Platz076();
	Fun_Platz077();
	Fun_Platz078();
	Fun_Platz079();
	Fun_Platz080();
	Fun_Platz081();
	Fun_Platz082();
	Fun_Platz083();
	Fun_Platz084();
	Fun_Platz085();
	Fun_Platz086();
	Fun_Platz087();
	Fun_Platz088();
	Fun_Platz089();
	Fun_Platz090();
	Fun_Platz091();
	Fun_Platz092();
	Fun_Platz093();
	Fun_Platz094();
	Fun_Platz095();
	Fun_Platz096();
	Fun_Platz097();
	Fun_Platz098();
	Fun_Platz099();
	Fun_Platz100();
	Fun_Platz101();
	Fun_Platz102();
	Fun_Platz103();
	Fun_Platz104();
	Fun_Platz105();
	Fun_Platz106();
	Fun_Platz107();
	Fun_Platz108();
	Fun_Platz109();
	Fun_Platz110();
	Fun_Platz111();
	Fun_Platz112();
	Fun_Platz113();
	Fun_Platz114();
	Fun_Platz115();
	Fun_Platz116();
	Fun_Platz117();
	Fun_Platz118();
	Fun_Platz119();
	Fun_Platz120();
	Fun_Platz121();
	Fun_Platz122();
	Fun_Platz123();
	Fun_Platz124();
	Fun_Platz125();
	Fun_Platz126();
	Fun_Platz127();
	Fun_Platz128();
	Fun_Platz129();
	Fun_Platz130();
	Fun_Platz131();
	Fun_Platz132();
	Fun_Platz133();
	Fun_Platz134();
	Fun_Platz135();
	Fun_Platz136();
	Fun_Platz137();
	Fun_Platz138();
	Fun_Platz139();
	Fun_Platz140();
	Fun_Platz141();
	Fun_Platz142();
	Fun_Platz143();
	Fun_Platz144();
	Fun_Platz145();
	Fun_Platz146();
	Fun_Platz147();
	Fun_Platz148();
	Fun_Platz149();
	Fun_Platz150();
	Fun_Platz151();
	Fun_Platz152();
	Fun_Platz153();
	Fun_Platz154();
	Fun_Platz155();
	Fun_Platz156();
	Fun_Platz157();
	Fun_Platz158();
	Fun_Platz159();
	Fun_Platz160();
	Fun_Platz161();
	Fun_Platz162();
	Fun_Platz163();
	Fun_Platz164();
	Fun_Platz165();
	Fun_Platz166();
	Fun_Platz167();
	Fun_Platz168();
	Fun_Platz169();
	Fun_Platz170();
	Fun_Platz171();
	Fun_Platz172();
	Fun_Platz173();
	Fun_Platz174();
	Fun_Platz175();
	Fun_Platz176();
	Fun_Platz177();
	Fun_Platz178();
	Fun_Platz179();
	Fun_Platz180();
	Fun_Platz181();
	Fun_Platz182();
	Fun_Platz183();
	Fun_Platz184();
	Fun_Platz185();
	Fun_Platz186();
	Fun_Platz187();
	Fun_Platz188();
	Fun_Platz189();
	Fun_Platz190();
	Fun_Platz191();
	Fun_Platz192();
	Fun_Platz193();
	Fun_Platz194();
	Fun_Platz195();
	Fun_Platz196();
	Fun_Platz197();
	Fun_Platz198();
	Fun_Platz199();
	Fun_Platz200();
	Fun_Platz201();
	Fun_Platz202();
	Fun_Platz203();
	Fun_Platz204();
	Fun_Platz205();
	Fun_Platz206();
	Fun_Platz207();
	Fun_Platz208();
	Fun_Platz209();
	Fun_Boss();
	Fun_Lager();
};

func void FUN_TAKT_ALLE()
{
	if (!FUN_AKTIV)
	{
		return;
	};
	if (Npc_GetTrueGuild(hero) == GIL_NONE)
	{
		Fun_HeldStart(COOP_FUNGILDE());
	};
	Fun_Haltungen();
	Fun_KapitelPruefen();
};
