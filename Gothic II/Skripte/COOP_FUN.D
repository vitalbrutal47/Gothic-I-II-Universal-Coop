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
const int FUN_RESPAWN_TAKTE = 12;
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

instance FUN_M00_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M00_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M00_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M00_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M00_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M00_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M01_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M01_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M01_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M01_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M01_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M01_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M02_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M02_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M02_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M02_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M02_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M02_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M03_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M03_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M03_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M03_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M03_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M03_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M04_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M04_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M04_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M04_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M04_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M05_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M05_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M05_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M05_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M05_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M06_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M06_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M06_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M06_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M06_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M07_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M07_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M07_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M07_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M07_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M08_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M08_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M08_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M08_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M08_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M08_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M09_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M09_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M09_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M09_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M09_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M09_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M10_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M10_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M10_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M10_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M10_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M10_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M11_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M11_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M11_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M11_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M11_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M12_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M12_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M12_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M12_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M12_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M12_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M13_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M13_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M13_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M13_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M13_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M13_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M14_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M14_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M14_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M14_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M14_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M15_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M15_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M15_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M15_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M15_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M15_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M16_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M16_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M16_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M16_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M16_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M16_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M17_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M17_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M17_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M17_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M17_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M18_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M18_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M18_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M18_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M18_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M18_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M19_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M19_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M19_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M19_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M19_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M20_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M20_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M20_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M20_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M20_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M20_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M21_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M21_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M21_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M21_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M21_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M22_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M22_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M22_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M22_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M22_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M22_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M23_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M23_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M23_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M23_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M23_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M23_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M24_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M24_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M24_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M24_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M24_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M24_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M25_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M25_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M25_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M25_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M25_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M25_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M26_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M26_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M26_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M26_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M26_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M26_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M27_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M27_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M27_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M27_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M27_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M27_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M28_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M28_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M28_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M28_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M28_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M28_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M29_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M29_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M29_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M29_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M29_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M30_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M30_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M30_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M30_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M30_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M31_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M31_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M31_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M31_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M31_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M32_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M32_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M32_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M32_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M32_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M33_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M33_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M33_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M33_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M33_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M34_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M34_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M34_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M34_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M34_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M35_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M35_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M35_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M35_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M35_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M36_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M36_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M36_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M36_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M36_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M37_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M37_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M37_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M37_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M37_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M37_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M38_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M38_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M38_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M38_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M38_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M38_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M39_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M39_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M39_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M39_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M39_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M39_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M40_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M40_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M40_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M40_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M40_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M40_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M41_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M41_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M41_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M41_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M41_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M41_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M42_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M42_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M42_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M42_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M42_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M42_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M43_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M43_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M43_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M43_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M43_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M43_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M44_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M44_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M44_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M44_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M44_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M44_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M45_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M45_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M45_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M45_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M45_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M45_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M46_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M46_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M46_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M46_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M46_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M46_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M47_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M47_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M47_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M47_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M47_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M47_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M48_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M48_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M48_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M48_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M48_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M49_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M49_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M49_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M49_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M49_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M50_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M50_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M50_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M50_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M50_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M50_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M51_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M51_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M51_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M51_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M51_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M51_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M52_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M52_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M52_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M52_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M52_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M52_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M53_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M53_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M53_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M53_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M53_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M53_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M54_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M54_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M54_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M54_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M54_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M54_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M55_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M55_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M55_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M55_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M55_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M55_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M56_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M56_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M56_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M56_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M56_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M56_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M57_T0 (Mst_Default_Giant_Rat)
{
	B_SetVisuals_Giant_Rat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M57_T1 (Mst_Default_Wolf)
{
	B_SetVisuals_Wolf();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M57_T2 (Mst_Default_Giant_Bug)
{
	B_SetVisuals_Giant_Bug();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M57_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M57_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M57_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M58_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M58_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M58_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M58_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M58_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M58_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M59_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M59_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M59_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M59_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M59_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M59_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M60_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M60_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M60_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M60_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M60_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M61_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M61_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M61_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M61_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M61_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M61_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M62_T0 (Mst_Default_Bloodfly)
{
	B_SetVisuals_Bloodfly();
	Npc_SetToFistMode(self);
	Fun_MobBeute(0);
};
instance FUN_M62_T1 (Mst_Default_Keiler)
{
	B_SetVisuals_Keiler();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M62_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M62_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M62_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M62_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M63_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M63_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M63_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M63_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M63_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M64_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M64_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M64_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M64_T6 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M64_T7 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M65_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M65_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M65_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M65_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M65_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M65_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M66_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M66_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M66_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M66_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M66_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M67_T0 (Mst_Default_Molerat)
{
	B_SetVisuals_Molerat();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(0);
};
instance FUN_M67_T1 (Mst_Default_Scavenger)
{
	B_SetVisuals_Scavenger();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(1);
};
instance FUN_M67_T2 (Mst_Default_Gobbo_Black)
{
	B_SetVisuals_Gobbo_Black();
	Npc_SetToFightMode (self, ItMw_1h_Bau_Mace);
	Fun_MobBeute(2);
};
instance FUN_M67_T3 (Mst_Default_Waran)
{
	B_SetVisuals_Waran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M67_T4 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M67_T5 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(5);
};
instance FUN_M68_T2 (Mst_Default_Lurker)
{
	B_SetVisuals_Lurker();
	Npc_SetToFistMode(self);
	Fun_MobBeute(2);
};
instance FUN_M68_T3 (Mst_Default_Gobbo_Warrior)
{
	B_SetVisuals_Gobbo_Warrior();
	Npc_SetToFightMode (self, ItMw_1h_Misc_Sword);
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	Fun_MobBeute(3);
};
instance FUN_M68_T4 (Mst_Default_StoneGolem)
{
	B_SetVisuals_StoneGolem();
	Npc_SetToFistMode	(self);
	Fun_MobBeute(4);
};
instance FUN_M68_T5 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	Fun_MobBeute(5);
};
instance FUN_M68_T6 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	Fun_MobBeute(6);
};
instance FUN_M68_T7 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(7);
};
instance FUN_M69_T3 (Mst_Default_Snapper)
{
	B_SetVisuals_Snapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(3);
};
instance FUN_M69_T4 (Mst_Default_Razor)
{
	Set_Razor_Visuals();
	Npc_SetToFistMode(self);
	Fun_MobBeute(4);
};
instance FUN_M69_T5 (Mst_Default_Warg)
{
	B_SetVisuals_Warg();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 1);
	Fun_MobBeute(5);
};
instance FUN_M69_T6 (Mst_Default_DragonSnapper)
{
	B_SetVisuals_DragonSnapper();
	Npc_SetToFistMode(self);
	Fun_MobBeute(6);
};
instance FUN_M69_T7 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
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
	Mdl_SetModelScale(self, 1.5, 1.5, 1.5);
	CreateInvItems(self, ItMi_Gold, 250);
	CreateInvItems(self, ItMi_Fun_Kapitelstein, 1);
};
instance FUN_BOSS_K2 (Mst_Default_Bloodhound)
{
	Set_Bloodhound_Visuals();
	Npc_SetToFistMode(self);
	name = "Bluthund der Taverne";
	attribute[ATR_HITPOINTS_MAX] = attribute[ATR_HITPOINTS_MAX] * 30 / 10;
	attribute[ATR_HITPOINTS] = attribute[ATR_HITPOINTS_MAX];
	Mdl_SetModelScale(self, 1.4, 1.4, 1.4);
	CreateInvItems(self, ItMi_Gold, 500);
	CreateInvItems(self, ItMi_Fun_Kapitelstein, 1);
};
instance FUN_BOSS_K3 (Mst_Default_Shadowbeast)
{
	B_SetVisuals_Shadowbeast();
	Npc_SetToFistMode(self);
	CreateInvItems (self, ItFoMuttonRaw, 2);
	name = "Schattenfürst";
	attribute[ATR_HITPOINTS_MAX] = attribute[ATR_HITPOINTS_MAX] * 25 / 10;
	attribute[ATR_HITPOINTS] = attribute[ATR_HITPOINTS_MAX];
	Mdl_SetModelScale(self, 1.3, 1.3, 1.3);
	CreateInvItems(self, ItMi_Gold, 750);
	CreateInvItems(self, ItMi_Fun_Kapitelstein, 1);
};
instance FUN_BOSS_K4 (Mst_Default_FireWaran)
{
	B_SetVisuals_FireWaran();
	Npc_SetToFistMode(self);
	name = "Feuerechse";
	attribute[ATR_HITPOINTS_MAX] = attribute[ATR_HITPOINTS_MAX] * 30 / 10;
	attribute[ATR_HITPOINTS] = attribute[ATR_HITPOINTS_MAX];
	Mdl_SetModelScale(self, 1.4, 1.4, 1.4);
	CreateInvItems(self, ItMi_Gold, 1000);
	CreateInvItems(self, ItMi_Fun_Kapitelstein, 1);
};
instance FUN_BOSS_K5 (Mst_Default_Troll)
{
	B_SetVisuals_Troll();
	Npc_SetToFistMode(self);
	name = "Bergtroll";
	attribute[ATR_HITPOINTS_MAX] = attribute[ATR_HITPOINTS_MAX] * 15 / 10;
	attribute[ATR_HITPOINTS] = attribute[ATR_HITPOINTS_MAX];
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
	CreateInvItems(self, ItMi_Gold, 1250);
	CreateInvItems(self, ItMi_Fun_Kapitelstein, 1);
};
instance FUN_BOSS_K6 (Mst_Default_Troll_Black)
{
	B_SetVisuals_Troll_Black();
	Npc_SetToFistMode(self);
	name = "Schwarzer Troll";
	attribute[ATR_HITPOINTS_MAX] = attribute[ATR_HITPOINTS_MAX] * 12 / 10;
	attribute[ATR_HITPOINTS] = attribute[ATR_HITPOINTS_MAX];
	Mdl_SetModelScale(self, 1.15, 1.15, 1.15);
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
		EquipItem(hero, ItMw_ShortSword3);
		EquipItem(hero, ItRw_Crossbow_L_01);
		CreateInvItems(hero, ItRw_Bolt, 60);
		CreateInvItems(hero, ItRu_TeleportSeaport, 1);
		AI_Teleport(hero, "NW_CITY_HABOUR_KASERN_CENTRE_01");
		Print("Fun-Modus: du gehörst zum Lager Kaserne in Khorinis.");
	};
	if (wahl == 1)
	{
		CreateInvItem(hero, ITAR_SLD_L);
		AI_EquipArmor(hero, ITAR_SLD_L);
		EquipItem(hero, ItMw_Nagelkeule);
		EquipItem(hero, ItRw_Bow_L_02);
		CreateInvItems(hero, ItRw_Arrow, 60);
		CreateInvItems(hero, ItRu_TeleportFarm, 1);
		AI_Teleport(hero, "NW_BIGFARM_HOUSE_OUT_05");
		Print("Fun-Modus: du gehörst zum Lager Onars Hof.");
	};
	if (wahl == 2)
	{
		CreateInvItem(hero, ITAR_NOV_L);
		AI_EquipArmor(hero, ITAR_NOV_L);
		EquipItem(hero, ItMw_1h_Nov_Mace);
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
		CreateInvItem(hero, ITAR_Leather_L);
		AI_EquipArmor(hero, ITAR_Leather_L);
		EquipItem(hero, ItMw_ShortSword4);
		EquipItem(hero, ItRw_Bow_L_02);
		CreateInvItems(hero, ItRw_Arrow, 60);
		AI_Teleport(hero, "NW_CASTLEMINE_TOWER_CAMPFIRE_01");
		Print("Fun-Modus: du gehörst zum Lager Banditenturm.");
	};
	Fun_Haltungen();
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
	Wld_InsertNpc(FUN_M00_T2, "FP_ROAM_BIGFARM_LAKE_CAVE_01");
	Wld_InsertNpc(FUN_M01_T2, "FP_ROAM_BIGFARM_LAKE_CAVE_04");
	Wld_InsertNpc(FUN_M02_T2, "FP_ROAM_BIGFARM_LAKE_CAVE_07");
	Wld_InsertNpc(FUN_M03_T2, "FP_ROAM_BIGFARM_LAKE_CAVE_11");
	Wld_InsertNpc(FUN_M04_T3, "FP_ROAM_CASTLEMINE2_01");
	Wld_InsertNpc(FUN_M05_T3, "FP_ROAM_CASTLEMINE2_04");
	Wld_InsertNpc(FUN_M06_T3, "FP_ROAM_CASTLEMINE2_07");
	Wld_InsertNpc(FUN_M07_T3, "FP_ROAM_CASTLEMINE2_11");
	Wld_InsertNpc(FUN_M08_T2, "FP_ROAM_NW_BIGFARMFORESTCAVE_01");
	Wld_InsertNpc(FUN_M09_T2, "FP_ROAM_NW_BIGFARMFORESTCAVE_04");
	Wld_InsertNpc(FUN_M10_T2, "FP_ROAM_NW_BIGFARMFORESTCAVE_08");
	Wld_InsertNpc(FUN_M11_T3, "FP_ROAM_NW_TROLLAREA_RUINS_05");
	Wld_InsertNpc(FUN_M12_T0, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	Wld_InsertNpc(FUN_M13_T0, "FP_ROAM_NW_TROLLAREA_RUINS_22");
	Wld_InsertNpc(FUN_M14_T3, "FP_ROAM_NW_TROLLAREA_RUINS_29");
	Wld_InsertNpc(FUN_M15_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_02");
	Wld_InsertNpc(FUN_M16_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_06");
	Wld_InsertNpc(FUN_M17_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_10");
	Wld_InsertNpc(FUN_M18_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_14");
	Wld_InsertNpc(FUN_M19_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_21");
	Wld_InsertNpc(FUN_M20_T0, "FP_ROAM_RITUALFOREST_CAVE_05");
	Wld_InsertNpc(FUN_M21_T3, "FP_ROAM_RITUALFOREST_CAVE_09");
	Wld_InsertNpc(FUN_M22_T0, "FP_ROAM_TROLLAREA_SEA_01");
	Wld_InsertNpc(FUN_M23_T0, "FP_ROAM_TROLLAREA_SEA_04");
	Wld_InsertNpc(FUN_M24_T1, "NW_BIGFARM_FOREST_02");
	Wld_InsertNpc(FUN_M25_T1, "NW_BIGFARM_LAKE_03_MOVEMENT");
	Wld_InsertNpc(FUN_M26_T0, "NW_BIGFARM_LAKE_MONSTER_BLOODFLY");
	Wld_InsertNpc(FUN_M27_T0, "NW_BIGMILL_05");
	Wld_InsertNpc(FUN_M28_T0, "NW_BIGMILL_FARM3_03");
	Wld_InsertNpc(FUN_M29_T3, "NW_CASTLEMINE_06");
	Wld_InsertNpc(FUN_M30_T3, "NW_CASTLEMINE_10");
	Wld_InsertNpc(FUN_M31_T3, "NW_CASTLEMINE_12");
	Wld_InsertNpc(FUN_M32_T3, "NW_CASTLEMINE_13");
	Wld_InsertNpc(FUN_M33_T3, "NW_CRYPT_MONSTER02");
	Wld_InsertNpc(FUN_M34_T3, "NW_CRYPT_MONSTER04");
	Wld_InsertNpc(FUN_M35_T3, "NW_CRYPT_MONSTER06");
	Wld_InsertNpc(FUN_M36_T3, "NW_CRYPT_MONSTER08");
	Wld_InsertNpc(FUN_M37_T0, "NW_FARM3_BIGWOOD_02");
	Wld_InsertNpc(FUN_M38_T2, "NW_FARM3_MOUNTAINLAKE_03");
	Wld_InsertNpc(FUN_M39_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	Wld_InsertNpc(FUN_M40_T2, "NW_FARM3_PATH_11_SMALLRIVER_04");
	Wld_InsertNpc(FUN_M41_T2, "NW_FARM3_PATH_11_SMALLRIVER_17");
	Wld_InsertNpc(FUN_M42_T1, "NW_FARM3_PATH_12_MONSTER_01");
	Wld_InsertNpc(FUN_M43_T1, "NW_FARM4_WOOD_MONSTER_MORE_01");
	Wld_InsertNpc(FUN_M44_T1, "NW_FARM4_WOOD_MONSTER_N_3");
	Wld_InsertNpc(FUN_M45_T1, "NW_FARM4_WOOD_NEARPEASANT2_12");
	Wld_InsertNpc(FUN_M46_T1, "NW_FARM4_WOOD_NEARPEASANT2_8");
	Wld_InsertNpc(FUN_M47_T0, "NW_MAGECAVE_20");
	Wld_InsertNpc(FUN_M48_T3, "NW_MAGECAVE_23");
	Wld_InsertNpc(FUN_M49_T3, "NW_MAGECAVE_27");
	Wld_InsertNpc(FUN_M50_T1, "NW_SAGITTA_MOREMONSTER_01");
	Wld_InsertNpc(FUN_M51_T1, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	Wld_InsertNpc(FUN_M52_T0, "NW_TROLLAREA_BRIGDE_05");
	Wld_InsertNpc(FUN_M53_T0, "NW_TROLLAREA_NOVCHASE_01");
	Wld_InsertNpc(FUN_M54_T2, "NW_TROLLAREA_PATH_08");
	Wld_InsertNpc(FUN_M55_T0, "NW_TROLLAREA_PATH_38_MONSTER");
	Wld_InsertNpc(FUN_M56_T2, "NW_TROLLAREA_PATH_71_MONSTER");
	Wld_InsertNpc(FUN_M57_T0, "NW_TROLLAREA_PLANE_04");
	Wld_InsertNpc(FUN_M58_T0, "NW_TROLLAREA_PORTALTEMPEL_06");
	Wld_InsertNpc(FUN_M59_T0, "NW_TROLLAREA_PORTALTEMPEL_12");
	Wld_InsertNpc(FUN_M60_T3, "NW_TROLLAREA_PORTALTEMPEL_17_A");
	Wld_InsertNpc(FUN_M61_T0, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	Wld_InsertNpc(FUN_M62_T0, "NW_TROLLAREA_RITUALPATH_032");
	Wld_InsertNpc(FUN_M63_T3, "NW_TROLLAREA_RITUAL_13");
	Wld_InsertNpc(FUN_M64_T3, "NW_TROLLAREA_RIVERSIDECAVE_02");
	Wld_InsertNpc(FUN_M65_T2, "NW_TROLLAREA_RUINS_14");
	Wld_InsertNpc(FUN_M66_T3, "NW_TROLLAREA_RUINS_32");
	Wld_InsertNpc(FUN_M67_T0, "NW_TROLLAREA_TROLLLAKECAVE_02");
	Wld_InsertNpc(FUN_M68_T2, "NW_TROLLAREA_TROLLLAKECAVE_09");
	Wld_InsertNpc(FUN_M69_T3, "NW_TROLLAREA_TROLLROCKCAVE_03");
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
var int FUNL_T00;
var int FUNL_T01;
var int FUNL_T02;
var int FUNL_T03;
var int FUNL_T04;
var int FUNL_T05;
var int FUNL_T06;
var int FUNL_T07;
var int FUNL_T08;
var int FUNL_T09;
var int FUNL_T10;
var int FUNL_T11;
var int FUNL_T12;
var int FUNL_T13;
var int FUNL_T14;
var int FUNL_T15;
var int FUNL_T16;
var int FUNL_T17;
var int FUNL_T18;
var int FUNL_T19;
var int FUNL_T20;
var int FUNL_T21;
var int FUNL_T22;
var int FUNL_T23;
var int FUNL_T24;
var int FUNL_T25;
var int FUNL_T26;
var int FUNL_T27;
var int FUNL_T28;
var int FUNL_T29;
var int FUNL_T30;
var int FUNL_T31;
var int FUNL_T32;
var int FUNL_T33;
var int FUNL_T34;
var int FUNL_T35;
var int FUNL_T36;
var int FUNL_T37;
var int FUNL_T38;
var int FUNL_T39;
var int FUNL_T40;
var int FUNL_T41;
var int FUNL_T42;
var int FUNL_T43;
var int FUNL_T44;
var int FUNL_T45;
var int FUNL_T46;
var int FUNL_T47;
var int FUNL_T48;
var int FUNL_T49;
var int FUNL_T50;
var int FUNL_T51;
var int FUNL_T52;
var int FUNL_T53;
var int FUNL_T54;
var int FUNL_T55;
var int FUNL_T56;
var int FUNL_T57;
var int FUNL_T58;
var int FUNL_T59;
var int FUNL_T60;
var int FUNL_T61;
var int FUNL_T62;
var int FUNL_T63;
var int FUNL_T64;
var int FUNL_T65;
var int FUNL_T66;
var int FUNL_T67;
var int FUNL_T68;
var int FUNL_T69;
var int FUNL_BEGL_T;

func void Fun_Platz00()   // FP_ROAM_BIGFARM_LAKE_CAVE_01 (Original: Gobbo_Green)
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
		m = Hlp_GetNpc(FUN_M00_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M00_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M00_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M00_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M00_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M00_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M00_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T00 = 0;
			return;
		};
	};
	FUNL_T00 = FUNL_T00 + 1;
	if (FUNL_T00 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T00 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M00_T2, "FP_ROAM_BIGFARM_LAKE_CAVE_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M00_T3, "FP_ROAM_BIGFARM_LAKE_CAVE_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M00_T4, "FP_ROAM_BIGFARM_LAKE_CAVE_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M00_T5, "FP_ROAM_BIGFARM_LAKE_CAVE_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M00_T6, "FP_ROAM_BIGFARM_LAKE_CAVE_01");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M00_T7, "FP_ROAM_BIGFARM_LAKE_CAVE_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M00_T2, "FP_ROAM_BIGFARM_LAKE_CAVE_01");
	};
};
func void Fun_Platz01()   // FP_ROAM_BIGFARM_LAKE_CAVE_04 (Original: Gobbo_Green)
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
		m = Hlp_GetNpc(FUN_M01_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M01_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M01_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M01_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M01_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M01_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M01_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T01 = 0;
			return;
		};
	};
	FUNL_T01 = FUNL_T01 + 1;
	if (FUNL_T01 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T01 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M01_T2, "FP_ROAM_BIGFARM_LAKE_CAVE_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M01_T3, "FP_ROAM_BIGFARM_LAKE_CAVE_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M01_T4, "FP_ROAM_BIGFARM_LAKE_CAVE_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M01_T5, "FP_ROAM_BIGFARM_LAKE_CAVE_04");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M01_T6, "FP_ROAM_BIGFARM_LAKE_CAVE_04");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M01_T7, "FP_ROAM_BIGFARM_LAKE_CAVE_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M01_T2, "FP_ROAM_BIGFARM_LAKE_CAVE_04");
	};
};
func void Fun_Platz02()   // FP_ROAM_BIGFARM_LAKE_CAVE_07 (Original: Gobbo_Black)
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
		m = Hlp_GetNpc(FUN_M02_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M02_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M02_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M02_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M02_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M02_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M02_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T02 = 0;
			return;
		};
	};
	FUNL_T02 = FUNL_T02 + 1;
	if (FUNL_T02 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T02 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M02_T2, "FP_ROAM_BIGFARM_LAKE_CAVE_07");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M02_T3, "FP_ROAM_BIGFARM_LAKE_CAVE_07");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M02_T4, "FP_ROAM_BIGFARM_LAKE_CAVE_07");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M02_T5, "FP_ROAM_BIGFARM_LAKE_CAVE_07");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M02_T6, "FP_ROAM_BIGFARM_LAKE_CAVE_07");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M02_T7, "FP_ROAM_BIGFARM_LAKE_CAVE_07");
	}
	else
	{
		Wld_InsertNpc(FUN_M02_T2, "FP_ROAM_BIGFARM_LAKE_CAVE_07");
	};
};
func void Fun_Platz03()   // FP_ROAM_BIGFARM_LAKE_CAVE_11 (Original: Gobbo_Black)
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
		m = Hlp_GetNpc(FUN_M03_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M03_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M03_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M03_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M03_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M03_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M03_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T03 = 0;
			return;
		};
	};
	FUNL_T03 = FUNL_T03 + 1;
	if (FUNL_T03 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T03 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M03_T2, "FP_ROAM_BIGFARM_LAKE_CAVE_11");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M03_T3, "FP_ROAM_BIGFARM_LAKE_CAVE_11");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M03_T4, "FP_ROAM_BIGFARM_LAKE_CAVE_11");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M03_T5, "FP_ROAM_BIGFARM_LAKE_CAVE_11");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M03_T6, "FP_ROAM_BIGFARM_LAKE_CAVE_11");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M03_T7, "FP_ROAM_BIGFARM_LAKE_CAVE_11");
	}
	else
	{
		Wld_InsertNpc(FUN_M03_T2, "FP_ROAM_BIGFARM_LAKE_CAVE_11");
	};
};
func void Fun_Platz04()   // FP_ROAM_CASTLEMINE2_01 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M04_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M04_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M04_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M04_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M04_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M04_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T04 = 0;
			return;
		};
	};
	FUNL_T04 = FUNL_T04 + 1;
	if (FUNL_T04 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T04 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M04_T3, "FP_ROAM_CASTLEMINE2_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M04_T4, "FP_ROAM_CASTLEMINE2_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M04_T5, "FP_ROAM_CASTLEMINE2_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M04_T6, "FP_ROAM_CASTLEMINE2_01");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M04_T7, "FP_ROAM_CASTLEMINE2_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M04_T3, "FP_ROAM_CASTLEMINE2_01");
	};
};
func void Fun_Platz05()   // FP_ROAM_CASTLEMINE2_04 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M05_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M05_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M05_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M05_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M05_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M05_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T05 = 0;
			return;
		};
	};
	FUNL_T05 = FUNL_T05 + 1;
	if (FUNL_T05 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T05 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M05_T3, "FP_ROAM_CASTLEMINE2_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M05_T4, "FP_ROAM_CASTLEMINE2_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M05_T5, "FP_ROAM_CASTLEMINE2_04");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M05_T6, "FP_ROAM_CASTLEMINE2_04");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M05_T7, "FP_ROAM_CASTLEMINE2_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M05_T3, "FP_ROAM_CASTLEMINE2_04");
	};
};
func void Fun_Platz06()   // FP_ROAM_CASTLEMINE2_07 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M06_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M06_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M06_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M06_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M06_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M06_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T06 = 0;
			return;
		};
	};
	FUNL_T06 = FUNL_T06 + 1;
	if (FUNL_T06 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T06 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M06_T3, "FP_ROAM_CASTLEMINE2_07");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M06_T4, "FP_ROAM_CASTLEMINE2_07");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M06_T5, "FP_ROAM_CASTLEMINE2_07");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M06_T6, "FP_ROAM_CASTLEMINE2_07");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M06_T7, "FP_ROAM_CASTLEMINE2_07");
	}
	else
	{
		Wld_InsertNpc(FUN_M06_T3, "FP_ROAM_CASTLEMINE2_07");
	};
};
func void Fun_Platz07()   // FP_ROAM_CASTLEMINE2_11 (Original: Zombie03)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M07_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M07_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M07_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M07_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M07_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M07_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T07 = 0;
			return;
		};
	};
	FUNL_T07 = FUNL_T07 + 1;
	if (FUNL_T07 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T07 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M07_T3, "FP_ROAM_CASTLEMINE2_11");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M07_T4, "FP_ROAM_CASTLEMINE2_11");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M07_T5, "FP_ROAM_CASTLEMINE2_11");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M07_T6, "FP_ROAM_CASTLEMINE2_11");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M07_T7, "FP_ROAM_CASTLEMINE2_11");
	}
	else
	{
		Wld_InsertNpc(FUN_M07_T3, "FP_ROAM_CASTLEMINE2_11");
	};
};
func void Fun_Platz08()   // FP_ROAM_NW_BIGFARMFORESTCAVE_01 (Original: Gobbo_Black)
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
		m = Hlp_GetNpc(FUN_M08_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M08_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M08_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M08_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M08_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M08_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M08_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T08 = 0;
			return;
		};
	};
	FUNL_T08 = FUNL_T08 + 1;
	if (FUNL_T08 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T08 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M08_T2, "FP_ROAM_NW_BIGFARMFORESTCAVE_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M08_T3, "FP_ROAM_NW_BIGFARMFORESTCAVE_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M08_T4, "FP_ROAM_NW_BIGFARMFORESTCAVE_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M08_T5, "FP_ROAM_NW_BIGFARMFORESTCAVE_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M08_T6, "FP_ROAM_NW_BIGFARMFORESTCAVE_01");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M08_T7, "FP_ROAM_NW_BIGFARMFORESTCAVE_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M08_T2, "FP_ROAM_NW_BIGFARMFORESTCAVE_01");
	};
};
func void Fun_Platz09()   // FP_ROAM_NW_BIGFARMFORESTCAVE_04 (Original: Gobbo_Black)
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
		m = Hlp_GetNpc(FUN_M09_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M09_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M09_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M09_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M09_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M09_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M09_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T09 = 0;
			return;
		};
	};
	FUNL_T09 = FUNL_T09 + 1;
	if (FUNL_T09 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T09 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M09_T2, "FP_ROAM_NW_BIGFARMFORESTCAVE_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M09_T3, "FP_ROAM_NW_BIGFARMFORESTCAVE_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M09_T4, "FP_ROAM_NW_BIGFARMFORESTCAVE_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M09_T5, "FP_ROAM_NW_BIGFARMFORESTCAVE_04");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M09_T6, "FP_ROAM_NW_BIGFARMFORESTCAVE_04");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M09_T7, "FP_ROAM_NW_BIGFARMFORESTCAVE_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M09_T2, "FP_ROAM_NW_BIGFARMFORESTCAVE_04");
	};
};
func void Fun_Platz10()   // FP_ROAM_NW_BIGFARMFORESTCAVE_08 (Original: Gobbo_Green)
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
		m = Hlp_GetNpc(FUN_M10_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M10_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M10_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M10_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M10_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M10_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M10_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T10 = 0;
			return;
		};
	};
	FUNL_T10 = FUNL_T10 + 1;
	if (FUNL_T10 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T10 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M10_T2, "FP_ROAM_NW_BIGFARMFORESTCAVE_08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M10_T3, "FP_ROAM_NW_BIGFARMFORESTCAVE_08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M10_T4, "FP_ROAM_NW_BIGFARMFORESTCAVE_08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M10_T5, "FP_ROAM_NW_BIGFARMFORESTCAVE_08");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M10_T6, "FP_ROAM_NW_BIGFARMFORESTCAVE_08");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M10_T7, "FP_ROAM_NW_BIGFARMFORESTCAVE_08");
	}
	else
	{
		Wld_InsertNpc(FUN_M10_T2, "FP_ROAM_NW_BIGFARMFORESTCAVE_08");
	};
};
func void Fun_Platz11()   // FP_ROAM_NW_TROLLAREA_RUINS_05 (Original: Snapper)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M11_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M11_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M11_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M11_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M11_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M11_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T11 = 0;
			return;
		};
	};
	FUNL_T11 = FUNL_T11 + 1;
	if (FUNL_T11 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T11 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M11_T3, "FP_ROAM_NW_TROLLAREA_RUINS_05");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M11_T4, "FP_ROAM_NW_TROLLAREA_RUINS_05");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M11_T5, "FP_ROAM_NW_TROLLAREA_RUINS_05");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M11_T6, "FP_ROAM_NW_TROLLAREA_RUINS_05");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M11_T7, "FP_ROAM_NW_TROLLAREA_RUINS_05");
	}
	else
	{
		Wld_InsertNpc(FUN_M11_T3, "FP_ROAM_NW_TROLLAREA_RUINS_05");
	};
};
func void Fun_Platz12()   // FP_ROAM_NW_TROLLAREA_RUINS_14 (Original: Giant_Rat)
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
		m = Hlp_GetNpc(FUN_M12_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M12_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M12_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M12_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M12_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M12_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M12_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T12 = 0;
			return;
		};
	};
	FUNL_T12 = FUNL_T12 + 1;
	if (FUNL_T12 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T12 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M12_T0, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M12_T1, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M12_T2, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M12_T3, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M12_T4, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M12_T5, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	}
	else
	{
		Wld_InsertNpc(FUN_M12_T0, "FP_ROAM_NW_TROLLAREA_RUINS_14");
	};
};
func void Fun_Platz13()   // FP_ROAM_NW_TROLLAREA_RUINS_22 (Original: Bloodfly)
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
		m = Hlp_GetNpc(FUN_M13_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M13_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M13_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M13_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M13_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M13_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M13_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T13 = 0;
			return;
		};
	};
	FUNL_T13 = FUNL_T13 + 1;
	if (FUNL_T13 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T13 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M13_T0, "FP_ROAM_NW_TROLLAREA_RUINS_22");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M13_T1, "FP_ROAM_NW_TROLLAREA_RUINS_22");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M13_T2, "FP_ROAM_NW_TROLLAREA_RUINS_22");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M13_T3, "FP_ROAM_NW_TROLLAREA_RUINS_22");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M13_T4, "FP_ROAM_NW_TROLLAREA_RUINS_22");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M13_T5, "FP_ROAM_NW_TROLLAREA_RUINS_22");
	}
	else
	{
		Wld_InsertNpc(FUN_M13_T0, "FP_ROAM_NW_TROLLAREA_RUINS_22");
	};
};
func void Fun_Platz14()   // FP_ROAM_NW_TROLLAREA_RUINS_29 (Original: Waran)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M14_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M14_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M14_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M14_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M14_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M14_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T14 = 0;
			return;
		};
	};
	FUNL_T14 = FUNL_T14 + 1;
	if (FUNL_T14 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T14 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M14_T3, "FP_ROAM_NW_TROLLAREA_RUINS_29");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M14_T4, "FP_ROAM_NW_TROLLAREA_RUINS_29");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M14_T5, "FP_ROAM_NW_TROLLAREA_RUINS_29");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M14_T6, "FP_ROAM_NW_TROLLAREA_RUINS_29");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M14_T7, "FP_ROAM_NW_TROLLAREA_RUINS_29");
	}
	else
	{
		Wld_InsertNpc(FUN_M14_T3, "FP_ROAM_NW_TROLLAREA_RUINS_29");
	};
};
func void Fun_Platz15()   // FP_ROAM_NW_TROLLAREA_RUINS_CAVE_02 (Original: Gobbo_Black)
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
		m = Hlp_GetNpc(FUN_M15_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M15_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M15_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M15_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M15_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M15_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M15_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T15 = 0;
			return;
		};
	};
	FUNL_T15 = FUNL_T15 + 1;
	if (FUNL_T15 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T15 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M15_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M15_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M15_T4, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M15_T5, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M15_T6, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_02");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M15_T7, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M15_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_02");
	};
};
func void Fun_Platz16()   // FP_ROAM_NW_TROLLAREA_RUINS_CAVE_06 (Original: Gobbo_Black)
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
		m = Hlp_GetNpc(FUN_M16_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M16_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M16_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M16_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M16_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M16_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M16_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T16 = 0;
			return;
		};
	};
	FUNL_T16 = FUNL_T16 + 1;
	if (FUNL_T16 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T16 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M16_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_06");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M16_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_06");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M16_T4, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_06");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M16_T5, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_06");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M16_T6, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_06");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M16_T7, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_06");
	}
	else
	{
		Wld_InsertNpc(FUN_M16_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_06");
	};
};
func void Fun_Platz17()   // FP_ROAM_NW_TROLLAREA_RUINS_CAVE_10 (Original: Gobbo_Warrior)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M17_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M17_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M17_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M17_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M17_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M17_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T17 = 0;
			return;
		};
	};
	FUNL_T17 = FUNL_T17 + 1;
	if (FUNL_T17 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T17 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M17_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_10");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M17_T4, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_10");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M17_T5, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_10");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M17_T6, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_10");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M17_T7, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_10");
	}
	else
	{
		Wld_InsertNpc(FUN_M17_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_10");
	};
};
func void Fun_Platz18()   // FP_ROAM_NW_TROLLAREA_RUINS_CAVE_14 (Original: Gobbo_Black)
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
		m = Hlp_GetNpc(FUN_M18_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M18_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M18_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M18_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M18_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M18_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M18_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T18 = 0;
			return;
		};
	};
	FUNL_T18 = FUNL_T18 + 1;
	if (FUNL_T18 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T18 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M18_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_14");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M18_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_14");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M18_T4, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_14");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M18_T5, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_14");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M18_T6, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_14");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M18_T7, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_14");
	}
	else
	{
		Wld_InsertNpc(FUN_M18_T2, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_14");
	};
};
func void Fun_Platz19()   // FP_ROAM_NW_TROLLAREA_RUINS_CAVE_21 (Original: Minecrawler)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M19_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M19_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M19_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M19_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M19_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M19_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T19 = 0;
			return;
		};
	};
	FUNL_T19 = FUNL_T19 + 1;
	if (FUNL_T19 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T19 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M19_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_21");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M19_T4, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_21");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M19_T5, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_21");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M19_T6, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_21");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M19_T7, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_21");
	}
	else
	{
		Wld_InsertNpc(FUN_M19_T3, "FP_ROAM_NW_TROLLAREA_RUINS_CAVE_21");
	};
};
func void Fun_Platz20()   // FP_ROAM_RITUALFOREST_CAVE_05 (Original: Giant_Rat)
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
		m = Hlp_GetNpc(FUN_M20_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M20_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M20_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M20_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M20_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M20_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M20_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T20 = 0;
			return;
		};
	};
	FUNL_T20 = FUNL_T20 + 1;
	if (FUNL_T20 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T20 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M20_T0, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M20_T1, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M20_T2, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M20_T3, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M20_T4, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M20_T5, "FP_ROAM_RITUALFOREST_CAVE_05");
	}
	else
	{
		Wld_InsertNpc(FUN_M20_T0, "FP_ROAM_RITUALFOREST_CAVE_05");
	};
};
func void Fun_Platz21()   // FP_ROAM_RITUALFOREST_CAVE_09 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M21_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M21_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M21_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M21_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M21_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M21_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T21 = 0;
			return;
		};
	};
	FUNL_T21 = FUNL_T21 + 1;
	if (FUNL_T21 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T21 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M21_T3, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M21_T4, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M21_T5, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M21_T6, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M21_T7, "FP_ROAM_RITUALFOREST_CAVE_09");
	}
	else
	{
		Wld_InsertNpc(FUN_M21_T3, "FP_ROAM_RITUALFOREST_CAVE_09");
	};
};
func void Fun_Platz22()   // FP_ROAM_TROLLAREA_SEA_01 (Original: Bloodfly)
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
		m = Hlp_GetNpc(FUN_M22_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M22_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M22_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M22_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M22_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M22_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M22_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T22 = 0;
			return;
		};
	};
	FUNL_T22 = FUNL_T22 + 1;
	if (FUNL_T22 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T22 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M22_T0, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M22_T1, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M22_T2, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M22_T3, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M22_T4, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M22_T5, "FP_ROAM_TROLLAREA_SEA_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M22_T0, "FP_ROAM_TROLLAREA_SEA_01");
	};
};
func void Fun_Platz23()   // FP_ROAM_TROLLAREA_SEA_04 (Original: Bloodfly)
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
		m = Hlp_GetNpc(FUN_M23_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M23_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M23_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M23_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M23_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M23_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M23_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T23 = 0;
			return;
		};
	};
	FUNL_T23 = FUNL_T23 + 1;
	if (FUNL_T23 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T23 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M23_T0, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M23_T1, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M23_T2, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M23_T3, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M23_T4, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M23_T5, "FP_ROAM_TROLLAREA_SEA_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M23_T0, "FP_ROAM_TROLLAREA_SEA_04");
	};
};
func void Fun_Platz24()   // NW_BIGFARM_FOREST_02 (Original: Giant_Bug)
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
		m = Hlp_GetNpc(FUN_M24_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M24_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M24_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M24_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M24_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M24_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M24_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T24 = 0;
			return;
		};
	};
	FUNL_T24 = FUNL_T24 + 1;
	if (FUNL_T24 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T24 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M24_T1, "NW_BIGFARM_FOREST_02");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M24_T2, "NW_BIGFARM_FOREST_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M24_T3, "NW_BIGFARM_FOREST_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M24_T4, "NW_BIGFARM_FOREST_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M24_T5, "NW_BIGFARM_FOREST_02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M24_T6, "NW_BIGFARM_FOREST_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M24_T1, "NW_BIGFARM_FOREST_02");
	};
};
func void Fun_Platz25()   // NW_BIGFARM_LAKE_03_MOVEMENT (Original: Keiler)
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
		m = Hlp_GetNpc(FUN_M25_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M25_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M25_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M25_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M25_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M25_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M25_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T25 = 0;
			return;
		};
	};
	FUNL_T25 = FUNL_T25 + 1;
	if (FUNL_T25 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T25 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M25_T1, "NW_BIGFARM_LAKE_03_MOVEMENT");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M25_T2, "NW_BIGFARM_LAKE_03_MOVEMENT");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M25_T3, "NW_BIGFARM_LAKE_03_MOVEMENT");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M25_T4, "NW_BIGFARM_LAKE_03_MOVEMENT");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M25_T5, "NW_BIGFARM_LAKE_03_MOVEMENT");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M25_T6, "NW_BIGFARM_LAKE_03_MOVEMENT");
	}
	else
	{
		Wld_InsertNpc(FUN_M25_T1, "NW_BIGFARM_LAKE_03_MOVEMENT");
	};
};
func void Fun_Platz26()   // NW_BIGFARM_LAKE_MONSTER_BLOODFLY (Original: Bloodfly)
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
		m = Hlp_GetNpc(FUN_M26_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M26_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M26_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M26_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M26_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M26_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M26_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T26 = 0;
			return;
		};
	};
	FUNL_T26 = FUNL_T26 + 1;
	if (FUNL_T26 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T26 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M26_T0, "NW_BIGFARM_LAKE_MONSTER_BLOODFLY");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M26_T1, "NW_BIGFARM_LAKE_MONSTER_BLOODFLY");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M26_T2, "NW_BIGFARM_LAKE_MONSTER_BLOODFLY");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M26_T3, "NW_BIGFARM_LAKE_MONSTER_BLOODFLY");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M26_T4, "NW_BIGFARM_LAKE_MONSTER_BLOODFLY");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M26_T5, "NW_BIGFARM_LAKE_MONSTER_BLOODFLY");
	}
	else
	{
		Wld_InsertNpc(FUN_M26_T0, "NW_BIGFARM_LAKE_MONSTER_BLOODFLY");
	};
};
func void Fun_Platz27()   // NW_BIGMILL_05 (Original: Scavenger)
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
		m = Hlp_GetNpc(FUN_M27_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M27_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M27_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M27_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M27_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M27_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M27_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T27 = 0;
			return;
		};
	};
	FUNL_T27 = FUNL_T27 + 1;
	if (FUNL_T27 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T27 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M27_T0, "NW_BIGMILL_05");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M27_T1, "NW_BIGMILL_05");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M27_T2, "NW_BIGMILL_05");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M27_T3, "NW_BIGMILL_05");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M27_T4, "NW_BIGMILL_05");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M27_T5, "NW_BIGMILL_05");
	}
	else
	{
		Wld_InsertNpc(FUN_M27_T0, "NW_BIGMILL_05");
	};
};
func void Fun_Platz28()   // NW_BIGMILL_FARM3_03 (Original: Scavenger)
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
		m = Hlp_GetNpc(FUN_M28_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M28_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M28_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M28_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M28_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M28_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M28_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T28 = 0;
			return;
		};
	};
	FUNL_T28 = FUNL_T28 + 1;
	if (FUNL_T28 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T28 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M28_T0, "NW_BIGMILL_FARM3_03");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M28_T1, "NW_BIGMILL_FARM3_03");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M28_T2, "NW_BIGMILL_FARM3_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M28_T3, "NW_BIGMILL_FARM3_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M28_T4, "NW_BIGMILL_FARM3_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M28_T5, "NW_BIGMILL_FARM3_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M28_T0, "NW_BIGMILL_FARM3_03");
	};
};
func void Fun_Platz29()   // NW_CASTLEMINE_06 (Original: MinecrawlerWarrior)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M29_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M29_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M29_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M29_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M29_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M29_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T29 = 0;
			return;
		};
	};
	FUNL_T29 = FUNL_T29 + 1;
	if (FUNL_T29 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T29 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M29_T3, "NW_CASTLEMINE_06");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M29_T4, "NW_CASTLEMINE_06");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M29_T5, "NW_CASTLEMINE_06");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M29_T6, "NW_CASTLEMINE_06");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M29_T7, "NW_CASTLEMINE_06");
	}
	else
	{
		Wld_InsertNpc(FUN_M29_T3, "NW_CASTLEMINE_06");
	};
};
func void Fun_Platz30()   // NW_CASTLEMINE_10 (Original: MinecrawlerWarrior)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M30_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M30_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M30_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M30_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M30_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M30_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T30 = 0;
			return;
		};
	};
	FUNL_T30 = FUNL_T30 + 1;
	if (FUNL_T30 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T30 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M30_T3, "NW_CASTLEMINE_10");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M30_T4, "NW_CASTLEMINE_10");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M30_T5, "NW_CASTLEMINE_10");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M30_T6, "NW_CASTLEMINE_10");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M30_T7, "NW_CASTLEMINE_10");
	}
	else
	{
		Wld_InsertNpc(FUN_M30_T3, "NW_CASTLEMINE_10");
	};
};
func void Fun_Platz31()   // NW_CASTLEMINE_12 (Original: Minecrawler)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M31_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M31_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M31_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M31_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M31_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M31_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T31 = 0;
			return;
		};
	};
	FUNL_T31 = FUNL_T31 + 1;
	if (FUNL_T31 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T31 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M31_T3, "NW_CASTLEMINE_12");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M31_T4, "NW_CASTLEMINE_12");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M31_T5, "NW_CASTLEMINE_12");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M31_T6, "NW_CASTLEMINE_12");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M31_T7, "NW_CASTLEMINE_12");
	}
	else
	{
		Wld_InsertNpc(FUN_M31_T3, "NW_CASTLEMINE_12");
	};
};
func void Fun_Platz32()   // NW_CASTLEMINE_13 (Original: Minecrawler)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M32_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M32_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M32_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M32_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M32_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M32_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T32 = 0;
			return;
		};
	};
	FUNL_T32 = FUNL_T32 + 1;
	if (FUNL_T32 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T32 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M32_T3, "NW_CASTLEMINE_13");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M32_T4, "NW_CASTLEMINE_13");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M32_T5, "NW_CASTLEMINE_13");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M32_T6, "NW_CASTLEMINE_13");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M32_T7, "NW_CASTLEMINE_13");
	}
	else
	{
		Wld_InsertNpc(FUN_M32_T3, "NW_CASTLEMINE_13");
	};
};
func void Fun_Platz33()   // NW_CRYPT_MONSTER02 (Original: Gobbo_skeleton)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M33_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M33_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M33_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M33_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M33_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M33_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T33 = 0;
			return;
		};
	};
	FUNL_T33 = FUNL_T33 + 1;
	if (FUNL_T33 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T33 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M33_T3, "NW_CRYPT_MONSTER02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M33_T4, "NW_CRYPT_MONSTER02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M33_T5, "NW_CRYPT_MONSTER02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M33_T6, "NW_CRYPT_MONSTER02");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M33_T7, "NW_CRYPT_MONSTER02");
	}
	else
	{
		Wld_InsertNpc(FUN_M33_T3, "NW_CRYPT_MONSTER02");
	};
};
func void Fun_Platz34()   // NW_CRYPT_MONSTER04 (Original: Lesser_skeleton)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M34_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M34_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M34_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M34_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M34_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M34_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T34 = 0;
			return;
		};
	};
	FUNL_T34 = FUNL_T34 + 1;
	if (FUNL_T34 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T34 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M34_T3, "NW_CRYPT_MONSTER04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M34_T4, "NW_CRYPT_MONSTER04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M34_T5, "NW_CRYPT_MONSTER04");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M34_T6, "NW_CRYPT_MONSTER04");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M34_T7, "NW_CRYPT_MONSTER04");
	}
	else
	{
		Wld_InsertNpc(FUN_M34_T3, "NW_CRYPT_MONSTER04");
	};
};
func void Fun_Platz35()   // NW_CRYPT_MONSTER06 (Original: Lesser_skeleton)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M35_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M35_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M35_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M35_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M35_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M35_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T35 = 0;
			return;
		};
	};
	FUNL_T35 = FUNL_T35 + 1;
	if (FUNL_T35 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T35 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M35_T3, "NW_CRYPT_MONSTER06");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M35_T4, "NW_CRYPT_MONSTER06");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M35_T5, "NW_CRYPT_MONSTER06");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M35_T6, "NW_CRYPT_MONSTER06");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M35_T7, "NW_CRYPT_MONSTER06");
	}
	else
	{
		Wld_InsertNpc(FUN_M35_T3, "NW_CRYPT_MONSTER06");
	};
};
func void Fun_Platz36()   // NW_CRYPT_MONSTER08 (Original: Gobbo_skeleton)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M36_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M36_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M36_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M36_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M36_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M36_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T36 = 0;
			return;
		};
	};
	FUNL_T36 = FUNL_T36 + 1;
	if (FUNL_T36 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T36 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M36_T3, "NW_CRYPT_MONSTER08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M36_T4, "NW_CRYPT_MONSTER08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M36_T5, "NW_CRYPT_MONSTER08");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M36_T6, "NW_CRYPT_MONSTER08");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M36_T7, "NW_CRYPT_MONSTER08");
	}
	else
	{
		Wld_InsertNpc(FUN_M36_T3, "NW_CRYPT_MONSTER08");
	};
};
func void Fun_Platz37()   // NW_FARM3_BIGWOOD_02 (Original: Scavenger)
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
		m = Hlp_GetNpc(FUN_M37_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M37_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M37_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M37_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M37_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M37_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M37_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T37 = 0;
			return;
		};
	};
	FUNL_T37 = FUNL_T37 + 1;
	if (FUNL_T37 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T37 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M37_T0, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M37_T1, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M37_T2, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M37_T3, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M37_T4, "NW_FARM3_BIGWOOD_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M37_T5, "NW_FARM3_BIGWOOD_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M37_T0, "NW_FARM3_BIGWOOD_02");
	};
};
func void Fun_Platz38()   // NW_FARM3_MOUNTAINLAKE_03 (Original: Lurker)
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
		m = Hlp_GetNpc(FUN_M38_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M38_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M38_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M38_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M38_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M38_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M38_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T38 = 0;
			return;
		};
	};
	FUNL_T38 = FUNL_T38 + 1;
	if (FUNL_T38 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T38 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M38_T2, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M38_T3, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M38_T4, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M38_T5, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M38_T6, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M38_T7, "NW_FARM3_MOUNTAINLAKE_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M38_T2, "NW_FARM3_MOUNTAINLAKE_03");
	};
};
func void Fun_Platz39()   // NW_FARM3_PATH_11_SMALLRIVERMID_02 (Original: Lurker)
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
		m = Hlp_GetNpc(FUN_M39_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M39_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M39_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M39_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M39_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M39_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M39_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T39 = 0;
			return;
		};
	};
	FUNL_T39 = FUNL_T39 + 1;
	if (FUNL_T39 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T39 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M39_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M39_T3, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M39_T4, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M39_T5, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M39_T6, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M39_T7, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M39_T2, "NW_FARM3_PATH_11_SMALLRIVERMID_02");
	};
};
func void Fun_Platz40()   // NW_FARM3_PATH_11_SMALLRIVER_04 (Original: Lurker)
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
		m = Hlp_GetNpc(FUN_M40_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M40_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M40_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M40_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M40_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M40_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M40_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T40 = 0;
			return;
		};
	};
	FUNL_T40 = FUNL_T40 + 1;
	if (FUNL_T40 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T40 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M40_T2, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M40_T3, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M40_T4, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M40_T5, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M40_T6, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M40_T7, "NW_FARM3_PATH_11_SMALLRIVER_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M40_T2, "NW_FARM3_PATH_11_SMALLRIVER_04");
	};
};
func void Fun_Platz41()   // NW_FARM3_PATH_11_SMALLRIVER_17 (Original: Lurker)
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
		m = Hlp_GetNpc(FUN_M41_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M41_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M41_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M41_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M41_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M41_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M41_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T41 = 0;
			return;
		};
	};
	FUNL_T41 = FUNL_T41 + 1;
	if (FUNL_T41 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T41 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M41_T2, "NW_FARM3_PATH_11_SMALLRIVER_17");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M41_T3, "NW_FARM3_PATH_11_SMALLRIVER_17");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M41_T4, "NW_FARM3_PATH_11_SMALLRIVER_17");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M41_T5, "NW_FARM3_PATH_11_SMALLRIVER_17");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M41_T6, "NW_FARM3_PATH_11_SMALLRIVER_17");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M41_T7, "NW_FARM3_PATH_11_SMALLRIVER_17");
	}
	else
	{
		Wld_InsertNpc(FUN_M41_T2, "NW_FARM3_PATH_11_SMALLRIVER_17");
	};
};
func void Fun_Platz42()   // NW_FARM3_PATH_12_MONSTER_01 (Original: Keiler)
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
		m = Hlp_GetNpc(FUN_M42_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M42_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M42_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M42_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M42_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M42_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M42_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T42 = 0;
			return;
		};
	};
	FUNL_T42 = FUNL_T42 + 1;
	if (FUNL_T42 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T42 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M42_T1, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M42_T2, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M42_T3, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M42_T4, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M42_T5, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M42_T6, "NW_FARM3_PATH_12_MONSTER_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M42_T1, "NW_FARM3_PATH_12_MONSTER_01");
	};
};
func void Fun_Platz43()   // NW_FARM4_WOOD_MONSTER_MORE_01 (Original: Giant_Bug)
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
		m = Hlp_GetNpc(FUN_M43_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M43_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M43_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M43_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M43_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M43_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M43_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T43 = 0;
			return;
		};
	};
	FUNL_T43 = FUNL_T43 + 1;
	if (FUNL_T43 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T43 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M43_T1, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M43_T2, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M43_T3, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M43_T4, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M43_T5, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M43_T6, "NW_FARM4_WOOD_MONSTER_MORE_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M43_T1, "NW_FARM4_WOOD_MONSTER_MORE_01");
	};
};
func void Fun_Platz44()   // NW_FARM4_WOOD_MONSTER_N_3 (Original: Giant_Bug)
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
		m = Hlp_GetNpc(FUN_M44_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M44_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M44_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M44_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M44_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M44_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M44_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T44 = 0;
			return;
		};
	};
	FUNL_T44 = FUNL_T44 + 1;
	if (FUNL_T44 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T44 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M44_T1, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M44_T2, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M44_T3, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M44_T4, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M44_T5, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M44_T6, "NW_FARM4_WOOD_MONSTER_N_3");
	}
	else
	{
		Wld_InsertNpc(FUN_M44_T1, "NW_FARM4_WOOD_MONSTER_N_3");
	};
};
func void Fun_Platz45()   // NW_FARM4_WOOD_NEARPEASANT2_12 (Original: Giant_Bug)
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
		m = Hlp_GetNpc(FUN_M45_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M45_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M45_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M45_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M45_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M45_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M45_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T45 = 0;
			return;
		};
	};
	FUNL_T45 = FUNL_T45 + 1;
	if (FUNL_T45 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T45 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M45_T1, "NW_FARM4_WOOD_NEARPEASANT2_12");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M45_T2, "NW_FARM4_WOOD_NEARPEASANT2_12");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M45_T3, "NW_FARM4_WOOD_NEARPEASANT2_12");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M45_T4, "NW_FARM4_WOOD_NEARPEASANT2_12");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M45_T5, "NW_FARM4_WOOD_NEARPEASANT2_12");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M45_T6, "NW_FARM4_WOOD_NEARPEASANT2_12");
	}
	else
	{
		Wld_InsertNpc(FUN_M45_T1, "NW_FARM4_WOOD_NEARPEASANT2_12");
	};
};
func void Fun_Platz46()   // NW_FARM4_WOOD_NEARPEASANT2_8 (Original: Wolf)
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
		m = Hlp_GetNpc(FUN_M46_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M46_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M46_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M46_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M46_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M46_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M46_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T46 = 0;
			return;
		};
	};
	FUNL_T46 = FUNL_T46 + 1;
	if (FUNL_T46 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T46 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M46_T1, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M46_T2, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M46_T3, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M46_T4, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M46_T5, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M46_T6, "NW_FARM4_WOOD_NEARPEASANT2_8");
	}
	else
	{
		Wld_InsertNpc(FUN_M46_T1, "NW_FARM4_WOOD_NEARPEASANT2_8");
	};
};
func void Fun_Platz47()   // NW_MAGECAVE_20 (Original: Meatbug)
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
		m = Hlp_GetNpc(FUN_M47_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M47_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M47_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M47_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M47_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M47_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M47_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T47 = 0;
			return;
		};
	};
	FUNL_T47 = FUNL_T47 + 1;
	if (FUNL_T47 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T47 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M47_T0, "NW_MAGECAVE_20");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M47_T1, "NW_MAGECAVE_20");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M47_T2, "NW_MAGECAVE_20");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M47_T3, "NW_MAGECAVE_20");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M47_T4, "NW_MAGECAVE_20");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M47_T5, "NW_MAGECAVE_20");
	}
	else
	{
		Wld_InsertNpc(FUN_M47_T0, "NW_MAGECAVE_20");
	};
};
func void Fun_Platz48()   // NW_MAGECAVE_23 (Original: Minecrawler)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M48_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M48_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M48_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M48_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M48_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M48_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T48 = 0;
			return;
		};
	};
	FUNL_T48 = FUNL_T48 + 1;
	if (FUNL_T48 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T48 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M48_T3, "NW_MAGECAVE_23");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M48_T4, "NW_MAGECAVE_23");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M48_T5, "NW_MAGECAVE_23");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M48_T6, "NW_MAGECAVE_23");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M48_T7, "NW_MAGECAVE_23");
	}
	else
	{
		Wld_InsertNpc(FUN_M48_T3, "NW_MAGECAVE_23");
	};
};
func void Fun_Platz49()   // NW_MAGECAVE_27 (Original: MinecrawlerWarrior)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M49_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M49_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M49_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M49_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M49_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M49_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T49 = 0;
			return;
		};
	};
	FUNL_T49 = FUNL_T49 + 1;
	if (FUNL_T49 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T49 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M49_T3, "NW_MAGECAVE_27");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M49_T4, "NW_MAGECAVE_27");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M49_T5, "NW_MAGECAVE_27");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M49_T6, "NW_MAGECAVE_27");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M49_T7, "NW_MAGECAVE_27");
	}
	else
	{
		Wld_InsertNpc(FUN_M49_T3, "NW_MAGECAVE_27");
	};
};
func void Fun_Platz50()   // NW_SAGITTA_MOREMONSTER_01 (Original: Wolf)
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
		m = Hlp_GetNpc(FUN_M50_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M50_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M50_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M50_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M50_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M50_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M50_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T50 = 0;
			return;
		};
	};
	FUNL_T50 = FUNL_T50 + 1;
	if (FUNL_T50 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T50 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M50_T1, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M50_T2, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M50_T3, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M50_T4, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M50_T5, "NW_SAGITTA_MOREMONSTER_01");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M50_T6, "NW_SAGITTA_MOREMONSTER_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M50_T1, "NW_SAGITTA_MOREMONSTER_01");
	};
};
func void Fun_Platz51()   // NW_TAVERNE_TROLLAREA_MONSTER_03_01M1 (Original: Giant_Bug)
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
		m = Hlp_GetNpc(FUN_M51_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M51_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M51_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M51_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M51_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M51_T6);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M51_T1);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T51 = 0;
			return;
		};
	};
	FUNL_T51 = FUNL_T51 + 1;
	if (FUNL_T51 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T51 = 0;
	if (t == 1)
	{
		Wld_InsertNpc(FUN_M51_T1, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M51_T2, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M51_T3, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M51_T4, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M51_T5, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M51_T6, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	}
	else
	{
		Wld_InsertNpc(FUN_M51_T1, "NW_TAVERNE_TROLLAREA_MONSTER_03_01M1");
	};
};
func void Fun_Platz52()   // NW_TROLLAREA_BRIGDE_05 (Original: Giant_Rat)
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
		m = Hlp_GetNpc(FUN_M52_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M52_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M52_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M52_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M52_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M52_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M52_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T52 = 0;
			return;
		};
	};
	FUNL_T52 = FUNL_T52 + 1;
	if (FUNL_T52 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T52 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M52_T0, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M52_T1, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M52_T2, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M52_T3, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M52_T4, "NW_TROLLAREA_BRIGDE_05");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M52_T5, "NW_TROLLAREA_BRIGDE_05");
	}
	else
	{
		Wld_InsertNpc(FUN_M52_T0, "NW_TROLLAREA_BRIGDE_05");
	};
};
func void Fun_Platz53()   // NW_TROLLAREA_NOVCHASE_01 (Original: Molerat)
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
		m = Hlp_GetNpc(FUN_M53_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M53_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M53_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M53_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M53_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M53_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M53_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T53 = 0;
			return;
		};
	};
	FUNL_T53 = FUNL_T53 + 1;
	if (FUNL_T53 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T53 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M53_T0, "NW_TROLLAREA_NOVCHASE_01");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M53_T1, "NW_TROLLAREA_NOVCHASE_01");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M53_T2, "NW_TROLLAREA_NOVCHASE_01");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M53_T3, "NW_TROLLAREA_NOVCHASE_01");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M53_T4, "NW_TROLLAREA_NOVCHASE_01");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M53_T5, "NW_TROLLAREA_NOVCHASE_01");
	}
	else
	{
		Wld_InsertNpc(FUN_M53_T0, "NW_TROLLAREA_NOVCHASE_01");
	};
};
func void Fun_Platz54()   // NW_TROLLAREA_PATH_08 (Original: Lurker)
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
		m = Hlp_GetNpc(FUN_M54_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M54_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M54_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M54_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M54_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M54_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M54_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T54 = 0;
			return;
		};
	};
	FUNL_T54 = FUNL_T54 + 1;
	if (FUNL_T54 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T54 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M54_T2, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M54_T3, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M54_T4, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M54_T5, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M54_T6, "NW_TROLLAREA_PATH_08");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M54_T7, "NW_TROLLAREA_PATH_08");
	}
	else
	{
		Wld_InsertNpc(FUN_M54_T2, "NW_TROLLAREA_PATH_08");
	};
};
func void Fun_Platz55()   // NW_TROLLAREA_PATH_38_MONSTER (Original: Bloodfly)
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
		m = Hlp_GetNpc(FUN_M55_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M55_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M55_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M55_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M55_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M55_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M55_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T55 = 0;
			return;
		};
	};
	FUNL_T55 = FUNL_T55 + 1;
	if (FUNL_T55 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T55 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M55_T0, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M55_T1, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M55_T2, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M55_T3, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M55_T4, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M55_T5, "NW_TROLLAREA_PATH_38_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M55_T0, "NW_TROLLAREA_PATH_38_MONSTER");
	};
};
func void Fun_Platz56()   // NW_TROLLAREA_PATH_71_MONSTER (Original: Lurker)
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
		m = Hlp_GetNpc(FUN_M56_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M56_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M56_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M56_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M56_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M56_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M56_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T56 = 0;
			return;
		};
	};
	FUNL_T56 = FUNL_T56 + 1;
	if (FUNL_T56 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T56 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M56_T2, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M56_T3, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M56_T4, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M56_T5, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M56_T6, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M56_T7, "NW_TROLLAREA_PATH_71_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M56_T2, "NW_TROLLAREA_PATH_71_MONSTER");
	};
};
func void Fun_Platz57()   // NW_TROLLAREA_PLANE_04 (Original: Scavenger)
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
		m = Hlp_GetNpc(FUN_M57_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M57_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M57_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M57_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M57_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M57_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M57_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T57 = 0;
			return;
		};
	};
	FUNL_T57 = FUNL_T57 + 1;
	if (FUNL_T57 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T57 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M57_T0, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M57_T1, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M57_T2, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M57_T3, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M57_T4, "NW_TROLLAREA_PLANE_04");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M57_T5, "NW_TROLLAREA_PLANE_04");
	}
	else
	{
		Wld_InsertNpc(FUN_M57_T0, "NW_TROLLAREA_PLANE_04");
	};
};
func void Fun_Platz58()   // NW_TROLLAREA_PORTALTEMPEL_06 (Original: Giant_Rat)
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
		m = Hlp_GetNpc(FUN_M58_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M58_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M58_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M58_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M58_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M58_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M58_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T58 = 0;
			return;
		};
	};
	FUNL_T58 = FUNL_T58 + 1;
	if (FUNL_T58 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T58 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M58_T0, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M58_T1, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M58_T2, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M58_T3, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M58_T4, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M58_T5, "NW_TROLLAREA_PORTALTEMPEL_06");
	}
	else
	{
		Wld_InsertNpc(FUN_M58_T0, "NW_TROLLAREA_PORTALTEMPEL_06");
	};
};
func void Fun_Platz59()   // NW_TROLLAREA_PORTALTEMPEL_12 (Original: Giant_Rat)
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
		m = Hlp_GetNpc(FUN_M59_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M59_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M59_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M59_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M59_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M59_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M59_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T59 = 0;
			return;
		};
	};
	FUNL_T59 = FUNL_T59 + 1;
	if (FUNL_T59 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T59 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M59_T0, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M59_T1, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M59_T2, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M59_T3, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M59_T4, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M59_T5, "NW_TROLLAREA_PORTALTEMPEL_12");
	}
	else
	{
		Wld_InsertNpc(FUN_M59_T0, "NW_TROLLAREA_PORTALTEMPEL_12");
	};
};
func void Fun_Platz60()   // NW_TROLLAREA_PORTALTEMPEL_17_A (Original: Gobbo_Skeleton)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M60_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M60_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M60_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M60_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M60_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M60_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T60 = 0;
			return;
		};
	};
	FUNL_T60 = FUNL_T60 + 1;
	if (FUNL_T60 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T60 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M60_T3, "NW_TROLLAREA_PORTALTEMPEL_17_A");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M60_T4, "NW_TROLLAREA_PORTALTEMPEL_17_A");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M60_T5, "NW_TROLLAREA_PORTALTEMPEL_17_A");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M60_T6, "NW_TROLLAREA_PORTALTEMPEL_17_A");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M60_T7, "NW_TROLLAREA_PORTALTEMPEL_17_A");
	}
	else
	{
		Wld_InsertNpc(FUN_M60_T3, "NW_TROLLAREA_PORTALTEMPEL_17_A");
	};
};
func void Fun_Platz61()   // NW_TROLLAREA_RITUALFOREST_04_MONSTER (Original: Molerat)
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
		m = Hlp_GetNpc(FUN_M61_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M61_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M61_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M61_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M61_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M61_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M61_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T61 = 0;
			return;
		};
	};
	FUNL_T61 = FUNL_T61 + 1;
	if (FUNL_T61 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T61 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M61_T0, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M61_T1, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M61_T2, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M61_T3, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M61_T4, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M61_T5, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	}
	else
	{
		Wld_InsertNpc(FUN_M61_T0, "NW_TROLLAREA_RITUALFOREST_04_MONSTER");
	};
};
func void Fun_Platz62()   // NW_TROLLAREA_RITUALPATH_032 (Original: Bloodfly)
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
		m = Hlp_GetNpc(FUN_M62_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M62_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M62_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M62_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M62_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M62_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M62_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T62 = 0;
			return;
		};
	};
	FUNL_T62 = FUNL_T62 + 1;
	if (FUNL_T62 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T62 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M62_T0, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M62_T1, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M62_T2, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M62_T3, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M62_T4, "NW_TROLLAREA_RITUALPATH_032");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M62_T5, "NW_TROLLAREA_RITUALPATH_032");
	}
	else
	{
		Wld_InsertNpc(FUN_M62_T0, "NW_TROLLAREA_RITUALPATH_032");
	};
};
func void Fun_Platz63()   // NW_TROLLAREA_RITUAL_13 (Original: Gobbo_Skeleton)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M63_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M63_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M63_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M63_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M63_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M63_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T63 = 0;
			return;
		};
	};
	FUNL_T63 = FUNL_T63 + 1;
	if (FUNL_T63 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T63 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M63_T3, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M63_T4, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M63_T5, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M63_T6, "NW_TROLLAREA_RITUAL_13");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M63_T7, "NW_TROLLAREA_RITUAL_13");
	}
	else
	{
		Wld_InsertNpc(FUN_M63_T3, "NW_TROLLAREA_RITUAL_13");
	};
};
func void Fun_Platz64()   // NW_TROLLAREA_RIVERSIDECAVE_02 (Original: Shadowbeast)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M64_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M64_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M64_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M64_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M64_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M64_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T64 = 0;
			return;
		};
	};
	FUNL_T64 = FUNL_T64 + 1;
	if (FUNL_T64 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T64 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M64_T3, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M64_T4, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M64_T5, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M64_T6, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M64_T7, "NW_TROLLAREA_RIVERSIDECAVE_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M64_T3, "NW_TROLLAREA_RIVERSIDECAVE_02");
	};
};
func void Fun_Platz65()   // NW_TROLLAREA_RUINS_14 (Original: Gobbo_Black)
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
		m = Hlp_GetNpc(FUN_M65_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M65_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M65_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M65_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M65_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M65_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M65_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T65 = 0;
			return;
		};
	};
	FUNL_T65 = FUNL_T65 + 1;
	if (FUNL_T65 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T65 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M65_T2, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M65_T3, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M65_T4, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M65_T5, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M65_T6, "NW_TROLLAREA_RUINS_14");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M65_T7, "NW_TROLLAREA_RUINS_14");
	}
	else
	{
		Wld_InsertNpc(FUN_M65_T2, "NW_TROLLAREA_RUINS_14");
	};
};
func void Fun_Platz66()   // NW_TROLLAREA_RUINS_32 (Original: Waran)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M66_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M66_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M66_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M66_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M66_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M66_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T66 = 0;
			return;
		};
	};
	FUNL_T66 = FUNL_T66 + 1;
	if (FUNL_T66 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T66 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M66_T3, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M66_T4, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M66_T5, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M66_T6, "NW_TROLLAREA_RUINS_32");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M66_T7, "NW_TROLLAREA_RUINS_32");
	}
	else
	{
		Wld_InsertNpc(FUN_M66_T3, "NW_TROLLAREA_RUINS_32");
	};
};
func void Fun_Platz67()   // NW_TROLLAREA_TROLLLAKECAVE_02 (Original: Giant_Rat)
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
		m = Hlp_GetNpc(FUN_M67_T0);
	}
	else if (t == 1)
	{
		m = Hlp_GetNpc(FUN_M67_T1);
	}
	else if (t == 2)
	{
		m = Hlp_GetNpc(FUN_M67_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M67_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M67_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M67_T5);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M67_T0);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T67 = 0;
			return;
		};
	};
	FUNL_T67 = FUNL_T67 + 1;
	if (FUNL_T67 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T67 = 0;
	if (t == 0)
	{
		Wld_InsertNpc(FUN_M67_T0, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 1)
	{
		Wld_InsertNpc(FUN_M67_T1, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 2)
	{
		Wld_InsertNpc(FUN_M67_T2, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M67_T3, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M67_T4, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M67_T5, "NW_TROLLAREA_TROLLLAKECAVE_02");
	}
	else
	{
		Wld_InsertNpc(FUN_M67_T0, "NW_TROLLAREA_TROLLLAKECAVE_02");
	};
};
func void Fun_Platz68()   // NW_TROLLAREA_TROLLLAKECAVE_09 (Original: Gobbo_Green)
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
		m = Hlp_GetNpc(FUN_M68_T2);
	}
	else if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M68_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M68_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M68_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M68_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M68_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M68_T2);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T68 = 0;
			return;
		};
	};
	FUNL_T68 = FUNL_T68 + 1;
	if (FUNL_T68 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T68 = 0;
	if (t == 2)
	{
		Wld_InsertNpc(FUN_M68_T2, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 3)
	{
		Wld_InsertNpc(FUN_M68_T3, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M68_T4, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M68_T5, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M68_T6, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M68_T7, "NW_TROLLAREA_TROLLLAKECAVE_09");
	}
	else
	{
		Wld_InsertNpc(FUN_M68_T2, "NW_TROLLAREA_TROLLLAKECAVE_09");
	};
};
func void Fun_Platz69()   // NW_TROLLAREA_TROLLROCKCAVE_03 (Original: Skeleton)
{
	var C_NPC m;
	var int t;
	t = 3 + Fun_KapitelNr() - 1;
	if (t > 7)
	{
		t = 7;
	};
	if (t == 3)
	{
		m = Hlp_GetNpc(FUN_M69_T3);
	}
	else if (t == 4)
	{
		m = Hlp_GetNpc(FUN_M69_T4);
	}
	else if (t == 5)
	{
		m = Hlp_GetNpc(FUN_M69_T5);
	}
	else if (t == 6)
	{
		m = Hlp_GetNpc(FUN_M69_T6);
	}
	else if (t == 7)
	{
		m = Hlp_GetNpc(FUN_M69_T7);
	}
	else
	{
		m = Hlp_GetNpc(FUN_M69_T3);
	};
	if (Hlp_IsValidNpc(m))
	{
		if (!Npc_IsDead(m))
		{
			FUNL_T69 = 0;
			return;
		};
	};
	FUNL_T69 = FUNL_T69 + 1;
	if (FUNL_T69 < FUN_RESPAWN_TAKTE)
	{
		return;
	};
	FUNL_T69 = 0;
	if (t == 3)
	{
		Wld_InsertNpc(FUN_M69_T3, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 4)
	{
		Wld_InsertNpc(FUN_M69_T4, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 5)
	{
		Wld_InsertNpc(FUN_M69_T5, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 6)
	{
		Wld_InsertNpc(FUN_M69_T6, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else if (t == 7)
	{
		Wld_InsertNpc(FUN_M69_T7, "NW_TROLLAREA_TROLLROCKCAVE_03");
	}
	else
	{
		Wld_InsertNpc(FUN_M69_T3, "NW_TROLLAREA_TROLLROCKCAVE_03");
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
	Fun_Platz00();
	Fun_Platz01();
	Fun_Platz02();
	Fun_Platz03();
	Fun_Platz04();
	Fun_Platz05();
	Fun_Platz06();
	Fun_Platz07();
	Fun_Platz08();
	Fun_Platz09();
	Fun_Platz10();
	Fun_Platz11();
	Fun_Platz12();
	Fun_Platz13();
	Fun_Platz14();
	Fun_Platz15();
	Fun_Platz16();
	Fun_Platz17();
	Fun_Platz18();
	Fun_Platz19();
	Fun_Platz20();
	Fun_Platz21();
	Fun_Platz22();
	Fun_Platz23();
	Fun_Platz24();
	Fun_Platz25();
	Fun_Platz26();
	Fun_Platz27();
	Fun_Platz28();
	Fun_Platz29();
	Fun_Platz30();
	Fun_Platz31();
	Fun_Platz32();
	Fun_Platz33();
	Fun_Platz34();
	Fun_Platz35();
	Fun_Platz36();
	Fun_Platz37();
	Fun_Platz38();
	Fun_Platz39();
	Fun_Platz40();
	Fun_Platz41();
	Fun_Platz42();
	Fun_Platz43();
	Fun_Platz44();
	Fun_Platz45();
	Fun_Platz46();
	Fun_Platz47();
	Fun_Platz48();
	Fun_Platz49();
	Fun_Platz50();
	Fun_Platz51();
	Fun_Platz52();
	Fun_Platz53();
	Fun_Platz54();
	Fun_Platz55();
	Fun_Platz56();
	Fun_Platz57();
	Fun_Platz58();
	Fun_Platz59();
	Fun_Platz60();
	Fun_Platz61();
	Fun_Platz62();
	Fun_Platz63();
	Fun_Platz64();
	Fun_Platz65();
	Fun_Platz66();
	Fun_Platz67();
	Fun_Platz68();
	Fun_Platz69();
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
