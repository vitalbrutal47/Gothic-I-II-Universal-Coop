#!/usr/bin/env python3
"""Erzeugt COOP_FUN.D - den Fun-Modus fuer Gothic 2 Die Nacht des Raben (GothicCoop, zParserExtender, MergeMode).

Quelle der Monster: die Original-Skripte (Prototyp + Rumpf der Original-Instanz werden uebernommen), Spawnpunkte aus
STARTUP_NewWorld_Part_City_01 (spawns.json). Ausgabe Windows-1252.
"""
import json, os, re, sys

SCRIPTS = sys.argv[1] if len(sys.argv) > 1 else "g2scripts/_work/Data/Scripts/Content"   # Original-Skripte: github.com/VaanaCZ/gothic-2-addon-scripts (Zweig 2.6-DE)
OUT = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "Gothic II", "Skripte", "COOP_FUN.D")
HERE = os.path.dirname(os.path.abspath(__file__))

SECT = {}
CUR = ["kopf"]
def sect(name):
    CUR[0] = name
    SECT.setdefault(name, [])
def w(s=""):
    SECT.setdefault(CUR[0], []).append(s)

# ------------------------------------------------------------------------------------------------------------------
# Monster: Original-Instanzen lesen
MON_DIR = os.path.join(SCRIPTS, "Story", "NPC", "Monster")
def strip_comments(t):
    t = re.sub(r"/\*.*?\*/", "", t, flags=re.S)
    return re.sub(r"//[^\n]*", "", t)

INST = {}
for f in os.listdir(MON_DIR):
    t = strip_comments(open(os.path.join(MON_DIR, f), encoding="cp1252").read())
    for m in re.finditer(r"(?is)\binstance\s+(\w+)\s*\(\s*(\w+)\s*\)\s*\{(.*?)\n\s*\}\s*;", t):
        INST[m.group(1).lower()] = (m.group(1), m.group(2), m.group(3).strip())

def mon(name):
    n, proto, body = INST[name.lower()]
    body = "\n".join("\t" + ln.strip() for ln in body.splitlines() if ln.strip())
    return proto, body

# Staerkestufen 0-7, je drei Arten (Stufe = Ursprungsstufe des Spawnpunkts + Kapitel - 1)
TIERS = [
    ["Giant_Rat", "Molerat", "Bloodfly"],
    ["Wolf", "Scavenger", "Keiler"],
    ["Giant_Bug", "Gobbo_Black", "Lurker"],
    ["Snapper", "Waran", "Gobbo_Warrior"],
    ["Razor", "Bloodhound", "StoneGolem"],
    ["Warg", "Shadowbeast", "FireWaran"],
    ["DragonSnapper", "Troll", "Shadowbeast"],
    ["Troll_Black", "Troll", "DragonSnapper"],
]
ORIG_TIER = {"scavenger": 0, "molerat": 0, "giant_rat": 0, "ygiant_rat": 0, "sheep": 0, "meatbug": 0, "ygiant_bug": 0,
             "ybloodfly": 0, "bloodfly": 0, "ywolf": 1, "wolf": 1, "giant_bug": 1, "keiler": 1, "ygobbo_green": 1,
             "lurker": 2, "gobbo_green": 2, "gobbo_black": 2, "swamprat": 2, "harpie": 3, "snapper": 3, "waran": 3,
             "gobbo_warrior": 3, "minecrawler": 3, "gobbo_skeleton": 3, "lesser_skeleton": 3, "blackwolf": 3,
             "bloodhound": 4, "razor": 4, "orcbiter": 4, "skeleton": 4, "zombie01": 4, "zombie02": 4, "zombie03": 4,
             "zombie04": 4, "minecrawlerwarrior": 4, "warg": 4, "shadowbeast": 4, "firewaran": 4, "stonegolem": 4,
             "shadowbeast_skeleton": 4, "troll": 4, "troll_black": 4, "dragonsnapper": 4}

spawns = json.load(open(os.path.join(HERE, "spawns.json")))
cand = sorted((wp, v[1], ORIG_TIER[v[1].lower()]) for wp, v in spawns.items()
              if v[1].lower() in ORIG_TIER and not wp.startswith("NW_CITY_"))
# ueber die Karte verteilt: je Gebiet (erste drei Namensteile) etwa jeder dritte Punkt, mindestens einer; nicht direkt an den
# Lagern (Allee zu Onars Hof, Troll an der Burgmine neben dem Banditenturm). Startstufe hoechstens 3, damit Kapitel 1 machbar ist.
from collections import OrderedDict
_groups = OrderedDict()
for wp, inst, tier in cand:
    # u203d (Nutzer: "die mobs spawnen in den lagern teilweise"): keine Punkte in/an den Lagern (Onars Hof mit See, Wald und Muehle,
    # Burgmine neben dem Banditenturm, Kloster, Stadt); dazu schickt der Takt Monster, die ins Lager laufen, an ihren Punkt zurueck
    if wp.startswith(("NW_BIGFARM", "FP_ROAM_BIGFARM", "FP_ROAM_NW_BIGFARM", "NW_BIGMILL", "NW_CASTLEMINE", "FP_ROAM_CASTLEMINE",
                      "NW_MONASTERY", "FP_ROAM_MONASTERY", "NW_CITY", "NW_TROLLAREA_NOVCHASE", "NW_MAGECAVE")):
        continue
    _groups.setdefault("_".join(wp.split("_")[:3]), []).append((wp, inst, min(tier, 2)))
SLOTS = []
# u203c (Nutzer: "die mobs sollen mehr ausgeglichen verteilt werden"): je Gebiet hoechstens 4 Punkte, gleichmaessig aus der Liste
# gezogen (bisher alle - dichte Haufen in Hoehlen und an Freipunkten, z. B. 36 an FP_ROAM_NW, 12 Skelette in einer Gruft), dafuer
# 3 Monster je Punkt; Startstufe hoechstens 2, Stufe steigt mit dem Kapitel
for _k, _v in _groups.items():
    if len(_v) > 6:   # u203d: 6 statt 4 je Gebiet (die Lager-Punkte fallen weg)
        _step = len(_v) / 6.0
        _v = [_v[int(i * _step)] for i in range(6)]
    SLOTS += _v
SLOTS = [x for x in SLOTS for _ in range(3)]   # je Punkt drei Monster (eigene Instanzen, damit jedes einzeln nachkommt)
RESPAWN_TAKTE = 9   # Takte zu 10 s - 90 Sekunden nach dem Tod

# ------------------------------------------------------------------------------------------------------------------
GUILDS = [   # Kuerzel, Gilde, Lagername, Heldenstart, Haendlerpunkt, 5 Begleiterpunkte, Ruestung Begleiter, Waffe, Overlay
    dict(k="MIL", gil="GIL_MIL", lager="Kaserne in Khorinis", start="NW_CITY_HABOUR_KASERN_CENTRE_01",
         hdl="NW_CITY_HABOUR_KASERN_CENTRE_03",
         begl=["NW_CITY_HABOUR_KASERN_05_01", "NW_CITY_HABOUR_KASERN_08", "NW_CITY_HABOUR_KASERN_10",
               "NW_CITY_HABOUR_KASERN_12", "NW_CITY_HABOUR_KASERN_14"],
         arm="ITAR_MIL_L", wpn="ItMw_1h_Mil_Sword", rng="ItRw_Mil_Crossbow", ovl="Humans_Militia.mds",
         namen=["Konrad", "Walther", "Ulrich", "Bertram", "Egon"], hname="Quartiermeister Albrecht",
         harm="ITAR_MIL_M", tele="ItRu_TeleportSeaport"),
    dict(k="SLD", gil="GIL_SLD", lager="Onars Hof", start="NW_BIGFARM_HOUSE_OUT_05", hdl="NW_BIGFARM_HOUSE_08",
         begl=["NW_BIGFARM_HOUSE_12", "NW_BIGFARM_HOUSE_14", "NW_BIGFARM_ALLEE_04", "NW_BIGFARM_TREE",
               "NW_BIGFARM_KITCHEN_09"],
         arm="ITAR_SLD_M", wpn="ItMw_2h_Sld_Sword", rng="ItRw_Sld_Bow", ovl="Humans_Relaxed.mds",
         namen=["Grimm", "Kurgan", "Ronar", "Drago", "Tjark"], hname="Waffenhändler Brok",
         harm="ITAR_SLD_H", tele="ItRu_TeleportFarm"),
    dict(k="NOV", gil="GIL_NOV", lager="Kloster", start="NW_MONASTERY_PLACE_03", hdl="NW_MONASTERY_PLACE_07",
         begl=["NW_MONASTERY_PLACE_09", "NW_MONASTERY_GRASS_01", "NW_MONASTERY_HERB_05", "NW_MONASTERY_CHURCH_03",
               "NW_MONASTERY_CHAPELL_02"],
         arm="ITAR_NOV_L", wpn="ItMw_1h_Nov_Mace", rng="", ovl="Humans_Mage.mds",
         namen=["Bruder Anselm", "Bruder Elias", "Bruder Matthis", "Bruder Simon", "Bruder Tobias"],
         hname="Bruder Kellermeister", harm="ITAR_KDF_L", tele="ItRu_TeleportMonastery"),
    dict(k="BDT", gil="GIL_BDT", lager="Banditenturm", start="NW_CASTLEMINE_TOWER_CAMPFIRE_01",
         hdl="NW_CASTLEMINE_TOWER_CAMPFIRE_03",
         begl=["NW_CASTLEMINE_TOWER_CAMPFIRE_02", "NW_CASTLEMINE_TOWER_CAMPFIRE_04", "NW_CASTLEMINE_TOWER_STAND_01",
               "NW_CASTLEMINE_TOWER_STAND_02", "NW_CASTLEMINE_TOWER_REP_HUT"],
         arm="ITAR_BDT_M", wpn="ItMw_1h_Sld_Sword", rng="ItRw_Sld_Bow", ovl="Humans_Arrogance.mds",
         namen=["Rattenzahn", "Krummbein", "Narbe", "Schakal", "Knochen"], hname="Hehler Fingerlos",
         harm="ITAR_BDT_H", tele=""),
]
HEADS = ["Hum_Head_Fighter", "Hum_Head_Bald", "Hum_Head_Pony", "Hum_Head_Thief", "Hum_Head_FatBald"]
FACES = ["Face_N_Normal02", "Face_N_Normal03", "Face_N_NormalBart04", "Face_N_Normal08", "Face_N_NormalBart10",
         "Face_B_Normal01", "Face_L_Tough02", "Face_P_Normal01", "Face_N_Normal14", "Face_N_Normal16"]
VOICES = [6, 7, 8, 9, 10, 11, 12, 13]

# Startausruestung je Gilde (Helden-Startwerte Staerke/Geschick 30): Ruestung, Waffe, Fernwaffe, Munition
START = {
    "MIL": ("ITAR_MIL_L", "ItMw_ShortSword3", "ItRw_Crossbow_L_01", "ItRw_Bolt"),
    "SLD": ("ITAR_SLD_L", "ItMw_Nagelkeule", "ItRw_Bow_L_02", "ItRw_Arrow"),
    "NOV": ("ITAR_NOV_L", "ItMw_1h_Nov_Mace", "", ""),
    "BDT": ("ITAR_BDT_M", "ItMw_ShortSword4", "ItRw_Bow_L_02", "ItRw_Arrow"),   # u203d: Banditenruestung (35) statt Leder (25)
}

# Ware je Kapitel (gilt ab diesem Kapitel): Liste (Gegenstand, Anzahl)
COMMON = {
    1: [("ItPo_Health_01", 20), ("ItRw_Arrow", 300), ("ItRw_Bolt", 300), ("ItFoMutton", 10), ("ItFo_Bread", 10),
        ("ItSc_Firebolt", 5), ("ItSc_LightHeal", 5), ("ItMw_ShortSword3", 1), ("ItMw_Nagelkeule", 1),
        ("ItMw_1h_Mil_Sword", 1), ("ItMw_2h_Sld_Sword", 1), ("ItRw_Bow_L_02", 1), ("ItRw_Bow_L_03", 1),
        ("ItRw_Crossbow_L_01", 1), ("ItRw_Mil_Crossbow", 1)],
    2: [("ItPo_Health_02", 10), ("ItSc_InstantFireball", 3), ("ItSc_SumWolf", 2), ("ItMw_Schwert1", 1),
        ("ItMw_Kriegshammer1", 1), ("ItMw_Zweihaender1", 1), ("ItMw_Streitaxt1", 1), ("ItRw_Bow_L_04", 1),
        ("ItRw_Bow_M_01", 1), ("ItRw_Crossbow_L_02", 1)],
    3: [("ItSc_MediumHeal", 3), ("ItPo_Speed", 3), ("ItMw_Schwert4", 1), ("ItMw_Steinbrecher", 1),
        ("ItMw_Morgenstern", 1), ("ItMw_Zweihaender2", 1), ("ItMw_Streitaxt2", 1), ("ItRw_Bow_M_02", 1),
        ("ItRw_Bow_M_03", 1), ("ItRw_Crossbow_M_01", 1)],
    4: [("ItPo_Health_03", 10), ("ItSc_ChargeFireball", 2), ("ItMw_Streitkolben", 1), ("ItMw_Rubinklinge", 1),
        ("ItMw_Runenschwert", 1), ("ItMw_Zweihaender4", 1), ("ItMw_Schlachtaxt", 1), ("ItRw_Bow_M_04", 1),
        ("ItRw_Bow_H_01", 1), ("ItRw_Crossbow_M_02", 1)],
    5: [("ItPo_Perm_STR", 1), ("ItPo_Perm_DEX", 1), ("ItPo_Perm_Health", 1), ("ItSc_Firestorm", 2),
        ("ItMw_Orkschlaechter", 1), ("ItMw_Kriegshammer2", 1), ("ItMw_Folteraxt", 1), ("ItMw_Krummschwert", 1),
        ("ItMw_Barbarenstreitaxt", 1), ("ItRw_Bow_H_02", 1), ("ItRw_Bow_H_03", 1), ("ItRw_Crossbow_H_01", 1)],
    6: [("ItPo_Perm_Mana", 1), ("ItSc_Firerain", 1), ("ItMw_1H_Special_03", 1), ("ItMw_1H_Special_04", 1),
        ("ItMw_2H_Special_04", 1), ("ItMw_Drachenschneide", 1), ("ItMw_2H_Special_03", 1), ("ItRw_Bow_H_04", 1),
        ("ItRw_Crossbow_H_02", 1)],
}
# u203b (Nutzer: "fuege ruestung und mana hinzu ... bei dem haendler"): jeder Haendler hat zusaetzlich Ruestungen fuer alle
# und Manatraenke (auch Kriegergilden) - ab dem jeweiligen Kapitel
EXTRA_ALLE = {
    1: [("ItPo_Mana_01", 20), ("ITAR_Leather_L", 1), ("ITAR_BAU_L", 1)],
    2: [("ItPo_Mana_02", 10), ("ITAR_BDT_M", 1), ("ITAR_SLD_L", 1), ("ITAR_MIL_L", 1), ("ITAR_PIR_L_Addon", 1)],
    3: [("ITAR_DJG_Crawler", 1), ("ITAR_SLD_M", 1), ("ITAR_MIL_M", 1), ("ITAR_PIR_M_Addon", 1), ("ItPo_Mana_Addon_04", 3)],
    4: [("ItPo_Mana_03", 10), ("ITAR_SLD_H", 1), ("ITAR_DJG_L", 1), ("ITAR_PIR_H_Addon", 1), ("ITAR_Thorus_Addon", 1)],
    5: [("ITAR_DJG_M", 1), ("ITAR_PAL_M", 1), ("ITAR_OreBaron_Addon", 1), ("ItPo_Perm_Mana", 1)],
    6: [("ITAR_DJG_H", 1), ("ITAR_PAL_H", 1), ("ITAR_Raven_Addon", 1), ("ItAr_FireArmor_Addon", 1)],
}
for _k, _l in EXTRA_ALLE.items():
    _have = {i for i, _ in COMMON[_k]}
    COMMON[_k] += [x for x in _l if x[0] not in _have]

GUILD_WARE = {
    "MIL": {1: [("ITAR_MIL_L", 1)], 2: [("ITAR_MIL_M", 1)], 3: [("ITAR_PAL_M", 1), ("ItMw_1h_Pal_Sword", 1),
            ("ItMw_2h_Pal_Sword", 1)], 4: [("ItRu_PalLightHeal", 1), ("ItRu_PalHolyBolt", 1)],
            5: [("ITAR_PAL_H", 1), ("ItRu_PalMediumHeal", 1)], 6: [("ItRu_PalFullHeal", 1), ("ItRu_PalDestroyEvil", 1)]},
    "SLD": {1: [("ITAR_SLD_L", 1)], 2: [("ITAR_SLD_M", 1)], 3: [("ITAR_SLD_H", 1)], 4: [("ITAR_DJG_L", 1)],
            5: [("ITAR_DJG_M", 1)], 6: [("ITAR_DJG_H", 1)]},
    "NOV": {1: [("ITAR_NOV_L", 1), ("ItPo_Mana_01", 20), ("ItRu_FireBolt", 1), ("ItRu_LightHeal", 1), ("ItRu_Light", 1)],
            2: [("ITAR_KDF_L", 1), ("ItPo_Mana_02", 10), ("ItRu_InstantFireball", 1), ("ItRu_Icebolt", 1),
                ("ItRu_SumWolf", 1), ("ItMW_Addon_Stab01", 1)],
            3: [("ItRu_Firestorm", 1), ("ItRu_MediumHeal", 1), ("ItRu_ThunderBall", 1), ("ItRu_SumSkel", 1),
                ("ItMW_Addon_Stab03", 1)],
            4: [("ITAR_KDF_H", 1), ("ItPo_Mana_03", 10), ("ItRu_ChargeFireball", 1), ("ItRu_LightningFlash", 1),
                ("ItRu_SumGol", 1), ("ItMW_Addon_Stab04", 1)],
            5: [("ItRu_Pyrokinesis", 1), ("ItRu_IceWave", 1), ("ItRu_FullHeal", 1), ("ItRu_SumDemon", 1),
                ("ItMW_Addon_Stab05", 1)],
            6: [("ItRu_Firerain", 1), ("ItRu_BreathOfDeath", 1), ("ItRu_MassDeath", 1), ("ItRu_ArmyOfDarkness", 1)]},
    "BDT": {1: [("ITAR_Leather_L", 1)], 2: [("ITAR_BDT_M", 1)], 3: [("ITAR_BDT_H", 1)], 4: [("ITAR_Thorus_Addon", 1)],
            5: [("ITAR_Raven_Addon", 1)], 6: [("ITAR_Dementor", 1)]},
}

# Bosse an der Taverne je Kapitel: Grundart, Name, Lebensfaktor (x10), Groesse
BOSSES = [   # u203d (Nutzer: "die bosse doch mehr leben hinzufuegen aber schwaecher machen damit man laenger braucht"):
    # Leben x10 (40 = 4-fach), Staerke (Schaden) x10 (6 = 60 %)
    # u205 (Nutzer: "die bosse wieder groesser machen von der statur"): groesser als zu Beginn (1.5/1.4/1.3)
    ("Gobbo_Warrior", "Goblin-Häuptling", 40, "1.8", 6),
    ("Razor", "Reißzahn der Taverne", 40, "1.7", 6),
    ("Bloodhound", "Bluthund der Taverne", 40, "1.7", 6),
    ("Shadowbeast", "Schattenfürst", 35, "1.6", 5),
    ("FireWaran", "Feuerechse", 35, "1.7", 5),
    ("Troll", "Bergtroll", 30, "1.35", 4),
]
BOSS_WP = "NW_TAVERNE_CROSS"

# ==================================================================================================================
w("META")
w("{")
w("\tParser = Game;")
w("\tMergeMode = 1;")
w("\tEngine = G2A;")
w("};")
w()
w("// GothicCoop - Fun-Modus für Gothic 2 Die Nacht des Raben (ab u203). Erzeugt von tools\\funmodus\\gen_fun.py - nicht von Hand ändern.")
w("// Nutzer: \"man soll im menü auswählen können welche gilde man direkt startet, story entfernen, alle npc entfernen aber in")
w("// kapitel 1 starten, basis und einen händler (bei den jeweiligen gilden), ein kapitel aufsteigen indem man ein mob tötet")
w("// der in der mitte nahe der taverne steht ... coop pvp ... mobs spawnen lassen um ep und geld zu farmen ... händler mit")
w("// unendlich gold ... 5 weitere npc's in den jeweiligen lagern, die man zum kämpfen mitnehmen kann\".")
w("// Gewählt: Miliz (Kaserne), Söldner (Onars Hof), Novize (Kloster), Bandit (Turm bei der Burgmine); Gilde gegen Gilde;")
w("// Kapitel 1 bis 6. Start: COOP > Fun-Modus. GothicCoop liefert COOP_FUNMODUS() (1 = dieses neue Spiel ist ein Fun-Spiel)")
w("// und COOP_FUNGILDE() (0 Miliz, 1 Söldner, 2 Novize, 3 Bandit - Gothic.ini [GOTHICCOOP] coopFunGilde) und ruft alle 10 s")
w("// FUN_TAKT_ALLE (jeder PC) und FUN_TAKT_HOST (Host bzw. ohne Coop). Variablen FUNL_* gleicht der Coop nie ab (je PC);")
w("// FUN_AKTIV und FUN_KAPITEL gelten für alle. Ohne Fun-Spiel (FUN_AKTIV = 0) läuft alles wie im Original.")
w()
w("var int FUN_AKTIV;              // dieses Spiel ist ein Fun-Spiel")
w("var int FUN_KAPITEL;            // 1-6, steigt mit dem Kapitelstein")
w("var int FUNL_KAPITEL_GESEHEN;   // je PC: zuletzt angezeigtes Kapitel")
w("var int FUNL_BOSS_T;            // je PC (Host): Takte seit dem Tod des Bosses")
w("var int FUNL_BEGL_KAP;          // je PC (Host): Kapitel, für das die Begleiter zuletzt verstärkt wurden")
w(f"const int FUN_RESPAWN_TAKTE = {RESPAWN_TAKTE};")
w("const int FUN_BOSS_TAKTE = 18;")
w("const int FUN_BEGL_TAKTE = 30;")
w("const int FUN_HAENDLER_GOLD = 100000;")
w()

# ---- Kapitelstein
sect("stein")
w("// --- Kapitelstein: der Boss an der Taverne trägt ihn. Benutzen hebt das Kapitel für alle -----------------------------")
w("instance ItMi_Fun_Kapitelstein (C_Item)")
w("{")
w('\tname = "Kapitelstein";')
w("\tmainflag = ITEM_KAT_NONE;")
w("\tflags = ITEM_MISSION;")
w("\tvalue = 0;")
w('\tvisual = "ItMi_StonePlate_PowerUp_03.3DS";')
w("\tmaterial = MAT_STONE;")
w('\tscemename = "MAPSEALED";')
w("\ton_state[0] = Use_Fun_Kapitelstein;")
w('\teffect = "SPELLFX_WEAKGLIMMER";')
w("\tdescription = name;")
w('\ttext[0] = "Benutzen: nächstes Kapitel für alle.";')
w('\ttext[1] = "Die Händler bieten dann bessere Ware.";')
w("};")
w()
sect("steinfunk")
w("func void Use_Fun_Kapitelstein()")
w("{")
w("\tif (FUN_KAPITEL >= 6)")
w("\t{")
w('\t\tPrint("Das letzte Kapitel ist schon erreicht.");')
w("\t\treturn;")
w("\t};")
w("\tNpc_RemoveInvItems(self, ItMi_Fun_Kapitelstein, 1);")
w("\tFUN_KAPITEL = FUN_KAPITEL + 1;")
w("\tKapitel = FUN_KAPITEL;")
w("\tFun_KapitelPruefen();")
w("};")
w()

# ---- Monster-Instanzen je Platz und Stufe
sect("monster")
w("// --- Monster: je Spawnpunkt eine Instanz pro Stärkestufe (Prototyp und Rumpf wie im Original, dazu Gold) ---------------")
w("func void Fun_MobBeute(var int stufe)")
w("{")
w("\tCreateInvItems(self, ItMi_Gold, 4 + stufe * 8);")
w("};")
w()
for si, (wp, orig, base) in enumerate(SLOTS):
    for t in range(base, min(7, base + 5) + 1):
        kind = TIERS[t][si % 3]
        proto, body = mon(kind)
        w(f"instance FUN_M{si:03d}_T{t} ({proto})")
        w("{")
        w(body)
        w(f"\tFun_MobBeute({t});")
        w("};")
w()

# ---- Bosse
w("// --- Bosse an der Taverne (\"Zur toten Harpie\"), einer je Kapitel ------------------------------------------------")
for k, (kind, bname, hpx10, scale, strx10) in enumerate(BOSSES, 1):
    proto, body = mon(kind)
    w(f"instance FUN_BOSS_K{k} ({proto})")
    w("{")
    w(body)
    w(f'\tname = "{bname}";')
    w(f"\tattribute[ATR_HITPOINTS_MAX] = attribute[ATR_HITPOINTS_MAX] * {hpx10} / 10;")
    w("\tattribute[ATR_HITPOINTS] = attribute[ATR_HITPOINTS_MAX];")
    w(f"\tattribute[ATR_STRENGTH] = attribute[ATR_STRENGTH] * {strx10} / 10;")
    w(f"\tMdl_SetModelScale(self, {scale}, {scale}, {scale});")
    w(f"\tCreateInvItems(self, ItMi_Gold, {250 * k});")
    if k < 6:
        w("\tCreateInvItems(self, ItMi_Fun_Kapitelstein, 1);")
    else:
        w("\tCreateInvItems(self, ItMi_Gold, 5000);")
    w("};")
w()

# ---- Haendler und Begleiter
def human(inst, name, gil, nid, voice, head, face, armor, weapon, rng, ovl, wp, follow, immortal, extra=None):
    w(f"instance {inst} (Npc_Default)")
    w("{")
    w(f'\tname = "{name}";')
    w(f"\tguild = {gil};")
    w(f"\tid = {nid};")
    w(f"\tvoice = {voice};")
    w(f"\tflags = {'NPC_FLAG_IMMORTAL' if immortal else '0'};")
    w("\tnpctype = NPCTYPE_MAIN;")
    w("\tB_SetAttributesToChapter(self, Fun_KapitelNr());")
    w("\tfight_tactic = FAI_HUMAN_STRONG;")
    w(f"\tEquipItem(self, {weapon});")
    if rng:
        w(f"\tEquipItem(self, {rng});")
    w("\tB_CreateAmbientInv(self);")
    w(f'\tB_SetNpcVisual(self, MALE, "{head}", {face}, BodyTex_N, {armor});')
    w("\tMdl_SetModelFatness(self, 1);")
    w(f'\tMdl_ApplyOverlayMds(self, "{ovl}");')
    w("\tB_GiveNpcTalents(self);")
    w("\tB_SetFightSkills(self, 30 + 10 * Fun_KapitelNr());")
    w(f"\tdaily_routine = Rtn_Start_{nid};")
    for _x in (extra or []):
        w("\t" + _x)
    w("};")
    w(f"func void Rtn_Start_{nid}()")
    w("{")
    w(f'\tTA_Stand_ArmsCrossed(08,00,20,00,"{wp}");')
    w(f'\tTA_Stand_ArmsCrossed(20,00,08,00,"{wp}");')
    w("};")
    if follow:
        w(f"func void Rtn_Follow_{nid}()")
        w("{")
        w(f'\tTA_Follow_Player(08,00,20,00,"{wp}");')
        w(f'\tTA_Follow_Player(20,00,08,00,"{wp}");')
        w("};")

sect("hilfe")
w("func int Fun_KapitelNr()")
w("{")
w("\tif (FUN_KAPITEL < 1) { return 1; };")
w("\tif (FUN_KAPITEL > 6) { return 6; };")
w("\treturn FUN_KAPITEL;")
w("};")
w()
sect("menschen")
w("// --- Händler (unsterblich, unendlich Gold, Ware nach Kapitel) und je Lager 5 Begleiter ---------------------------------")
nid = 9600
companions = []   # (inst, gil)
traders = []
for gi, g in enumerate(GUILDS):
    tinst = f"FUN_HAENDLER_{g['k']}"
    human(tinst, g["hname"], "GIL_NONE", 9601 + gi, 9, "Hum_Head_Bald", "Face_N_NormalBart10", g["harm"], g["wpn"],
          "", "Humans_Arrogance.mds", g["hdl"], False, True)
    traders.append((tinst, g))
    for bi in range(5):
        cid = 9610 + gi * 10 + bi
        cinst = f"FUN_{g['k']}_{bi + 1}"
        human(cinst, g["namen"][bi], g["gil"], cid, VOICES[(gi * 5 + bi) % len(VOICES)], HEADS[bi],
              FACES[(gi * 3 + bi) % len(FACES)], g["arm"], g["wpn"], g["rng"], g["ovl"], g["begl"][bi], True, False)
        companions.append((cinst, g["gil"], g["begl"][bi]))
w()

# ---- Dialoge
sect("dialogfunk")
w("// --- Dialoge -------------------------------------------------------------------------------------------------------")
w("func int DIA_Fun_Exit_Condition() { return TRUE; };")
w("func void DIA_Fun_Exit_Info() { AI_StopProcessInfos(self); };")
w()
# Begleiter
w("func int DIA_Fun_Komm_Condition()")
w("{")
w("\tif (FUN_AKTIV && (Npc_GetTrueGuild(other) == self.guild) && (self.aivar[AIV_PARTYMEMBER] == FALSE))")
w("\t{")
w("\t\treturn TRUE;")
w("\t};")
w("\treturn FALSE;")
w("};")
w("func void DIA_Fun_Komm_Info()")
w("{")
w('\tAI_Output(other, self, "DIA_Addon_Matt_FollowMe_15_00"); //Komm mit.')
w("\tself.aivar[AIV_PARTYMEMBER] = TRUE;")
w('\tPrint(ConcatStrings(self.name, " folgt dir."));')
w("\tAI_StopProcessInfos(self);")
w('\tNpc_ExchangeRoutine(self, "FOLLOW");')
w("};")
w("func int DIA_Fun_Warte_Condition()")
w("{")
w("\tif (FUN_AKTIV && (Npc_GetTrueGuild(other) == self.guild) && (self.aivar[AIV_PARTYMEMBER] == TRUE))")
w("\t{")
w("\t\treturn TRUE;")
w("\t};")
w("\treturn FALSE;")
w("};")
w("func void DIA_Fun_Warte_Info()")
w("{")
w('\tAI_Output(other, self, "DIA_Addon_Diego_WarteHier_15_00"); //Warte hier!')
w("\tself.aivar[AIV_PARTYMEMBER] = FALSE;")
w('\tPrint(ConcatStrings(self.name, " geht zurück ins Lager."));')
w("\tAI_StopProcessInfos(self);")
w('\tNpc_ExchangeRoutine(self, "START");')
w("};")
sect("dialoginst")
for cinst, gil, wp in companions:
    for suf, nr, cond, info, desc in (("EXIT", 999, "DIA_Fun_Exit_Condition", "DIA_Fun_Exit_Info", "DIALOG_ENDE"),
                                     ("KOMM", 1, "DIA_Fun_Komm_Condition", "DIA_Fun_Komm_Info", '"Komm mit, wir ziehen los!"'),
                                     ("WARTE", 2, "DIA_Fun_Warte_Condition", "DIA_Fun_Warte_Info", '"Warte hier - geh zurück ins Lager."')):
        w(f"instance DIA_{cinst}_{suf} (C_INFO)")
        w("{")
        w(f"\tnpc = {cinst};")
        w(f"\tnr = {nr};")
        w(f"\tcondition = {cond};")
        w(f"\tinformation = {info};")
        w("\tpermanent = TRUE;")
        w(f"\tdescription = {desc};")
        w("};")
w()

# Haendler: Ware
sect("dialogfunk")
w("func void Fun_Ware(var C_NPC slf, var int itm, var int anz)")
w("{")
w("\tvar int hat;")
w("\that = Npc_HasItems(slf, itm);")
w("\tif (hat < anz)")
w("\t{")
w("\t\tCreateInvItems(slf, itm, anz - hat);")
w("\t};")
w("};")
w()
w("func void Fun_HaendlerWare(var C_NPC slf)")
w("{")
w("\tvar int vorrat;")
w("\tvorrat = Npc_HasItems(slf, ItMi_Gold);")
w("\tif (vorrat < FUN_HAENDLER_GOLD)")
w("\t{")
w("\t\tCreateInvItems(slf, ItMi_Gold, FUN_HAENDLER_GOLD - vorrat);")
w("\t};")
for k in range(1, 7):
    w(f"\tif (FUN_KAPITEL >= {k})")
    w("\t{")
    for itm, n in COMMON[k]:
        w(f"\t\tFun_Ware(slf, {itm}, {n});")
    for gi, g in enumerate(GUILDS):
        lst = GUILD_WARE[g["k"]].get(k, [])
        if lst:
            w(f"\t\tif (slf.id == {9601 + gi})")
            w("\t\t{")
            for itm, n in lst:
                w(f"\t\t\tFun_Ware(slf, {itm}, {n});")
            w("\t\t};")
    w("\t};")
w("};")
w()
w("func int DIA_Fun_Handel_Condition()")
w("{")
w("\tif (FUN_AKTIV && (Npc_GetTrueGuild(other) == Fun_GildeVonHaendler(self)) && Fun_FuehrerDa(other))")
w("\t{")
w("\t\treturn TRUE;")
w("\t};")
w("\treturn FALSE;")
w("};")
w("func void DIA_Fun_Handel_Info()")
w("{")
w('\tAI_Output(other, self, "DIA_Bosper_Trade_15_00"); //Zeig mir deine Ware.')
w("\tFun_HaendlerWare(self);")
w("};")
w()
sect("hilfe")
w("func int Fun_GildeVonHaendler(var C_NPC slf)")
w("{")
for gi, g in enumerate(GUILDS):
    w(f"\tif (slf.id == {9601 + gi}) {{ return {g['gil']}; }};")
w("\treturn GIL_NONE;")
w("};")
w()
sect("dialogfunk")
w("func void Fun_LehreLeben(var int lp)")
w("{")
w("\tif (other.lp < lp)")
w("\t{")
w('\t\tPrint("Zu wenige Lernpunkte!");')
w("\t\treturn;")
w("\t};")
w("\tother.lp = other.lp - lp;")
w("\tother.attribute[ATR_HITPOINTS_MAX] = other.attribute[ATR_HITPOINTS_MAX] + lp * 10;")
w("\tother.attribute[ATR_HITPOINTS] = other.attribute[ATR_HITPOINTS] + lp * 10;")
w('\tPrint(ConcatStrings("Lebensenergie + ", IntToString(lp * 10)));')
w("};")
w()
# Lehrer: Attribute und Kampf (Lernpunkte wie bei Gothics Lehrern)
TEACH = {
    "ATTR": [("STR1", "PRINT_LearnSTR1", "B_GetLearnCostAttribute(other, ATR_STRENGTH)", "B_TeachAttributePoints(self, other, ATR_STRENGTH, 1, T_MAX)"),
             ("STR5", "PRINT_LearnSTR5", "B_GetLearnCostAttribute(other, ATR_STRENGTH) * 5", "B_TeachAttributePoints(self, other, ATR_STRENGTH, 5, T_MAX)"),
             ("DEX1", "PRINT_LearnDEX1", "B_GetLearnCostAttribute(other, ATR_DEXTERITY)", "B_TeachAttributePoints(self, other, ATR_DEXTERITY, 1, T_MAX)"),
             ("DEX5", "PRINT_LearnDEX5", "B_GetLearnCostAttribute(other, ATR_DEXTERITY) * 5", "B_TeachAttributePoints(self, other, ATR_DEXTERITY, 5, T_MAX)"),
             ("MANA1", "PRINT_LearnMANA1", "B_GetLearnCostAttribute(other, ATR_MANA_MAX)", "B_TeachAttributePoints(self, other, ATR_MANA_MAX, 1, T_MEGA)"),
             ("MANA5", "PRINT_LearnMANA5", "B_GetLearnCostAttribute(other, ATR_MANA_MAX) * 5", "B_TeachAttributePoints(self, other, ATR_MANA_MAX, 5, T_MEGA)"),
             # u203d (Nutzer: "leben sollte man auch durch lernpunkte aufbauen koennen"): 1 LP = 10 Lebenspunkte
             ("HP1", '"Lebensenergie + 10"', "1", "Fun_LehreLeben(1)"),
             ("HP5", '"Lebensenergie + 50"', "5", "Fun_LehreLeben(5)")],
    "KAMPF": [("1H1", "PRINT_Learn1h1", "B_GetLearnCostTalent(other, NPC_TALENT_1H, 1)", "B_TeachFightTalentPercent(self, other, NPC_TALENT_1H, 1, 100)"),
              ("1H5", "PRINT_Learn1h5", "B_GetLearnCostTalent(other, NPC_TALENT_1H, 1) * 5", "B_TeachFightTalentPercent(self, other, NPC_TALENT_1H, 5, 100)"),
              ("2H1", "PRINT_Learn2h1", "B_GetLearnCostTalent(other, NPC_TALENT_2H, 1)", "B_TeachFightTalentPercent(self, other, NPC_TALENT_2H, 1, 100)"),
              ("2H5", "PRINT_Learn2h5", "B_GetLearnCostTalent(other, NPC_TALENT_2H, 1) * 5", "B_TeachFightTalentPercent(self, other, NPC_TALENT_2H, 5, 100)"),
              ("BOW1", "PRINT_LearnBow1", "B_GetLearnCostTalent(other, NPC_TALENT_BOW, 1)", "B_TeachFightTalentPercent(self, other, NPC_TALENT_BOW, 1, 100)"),
              ("BOW5", "PRINT_LearnBow5", "B_GetLearnCostTalent(other, NPC_TALENT_BOW, 1) * 5", "B_TeachFightTalentPercent(self, other, NPC_TALENT_BOW, 5, 100)"),
              ("CBOW1", "PRINT_LearnCrossBow1", "B_GetLearnCostTalent(other, NPC_TALENT_CROSSBOW, 1)", "B_TeachFightTalentPercent(self, other, NPC_TALENT_CROSSBOW, 1, 100)"),
              ("CBOW5", "PRINT_LearnCrossBow5", "B_GetLearnCostTalent(other, NPC_TALENT_CROSSBOW, 1) * 5", "B_TeachFightTalentPercent(self, other, NPC_TALENT_CROSSBOW, 5, 100)")],
}
for grp, rows in TEACH.items():
    info = f"DIA_Fun_Lehre{grp}"
    for tinst, g in traders:
        pass
    w(f"func void {info}_Menue()")
    w("{")
    w(f"\tInfo_ClearChoices(DIA_FUN_HAENDLER_MIL_{grp});")
    w(f"\tInfo_ClearChoices(DIA_FUN_HAENDLER_SLD_{grp});")
    w(f"\tInfo_ClearChoices(DIA_FUN_HAENDLER_NOV_{grp});")
    w(f"\tInfo_ClearChoices(DIA_FUN_HAENDLER_BDT_{grp});")
    for tinst, g in traders:
        w(f"\tif (self.id == {9601 + GUILDS.index(g)})")
        w("\t{")
        w(f"\t\tInfo_AddChoice(DIA_{tinst}_{grp}, DIALOG_BACK, {info}_Zurueck);")
        for key, txt, cost, call in rows:
            w(f"\t\tInfo_AddChoice(DIA_{tinst}_{grp}, B_BuildLearnString({txt}, {cost}), {info}_{key});")
        w("\t};")
    w("};")
    w(f"func void {info}_Zurueck()")
    w("{")
    for tinst, g in traders:
        w(f"\tInfo_ClearChoices(DIA_{tinst}_{grp});")
    w("};")
    for key, txt, cost, call in rows:
        w(f"func void {info}_{key}()")
        w("{")
        w(f"\t{call};")
        w(f"\t{info}_Menue();")
        w("};")
    w(f"func void {info}_Info()")
    w("{")
    w('\tAI_Output(other, self, "DIA_Wolf_WannaLearn_15_00"); //Kannst du mir was beibringen?')
    w(f"\t{info}_Menue();")
    w("};")
w()
sect("dialoginst")
for tinst, g in traders:
    for suf, nr, cond, info, desc, extra in (
            ("EXIT", 999, "DIA_Fun_Exit_Condition", "DIA_Fun_Exit_Info", "DIALOG_ENDE", None),
            ("HANDEL", 1, "DIA_Fun_Handel_Condition", "DIA_Fun_Handel_Info", '"Zeig mir deine Ware."', "trade = TRUE;"),
            ("ATTR", 2, "DIA_Fun_Handel_Condition", "DIA_Fun_LehreATTR_Info", '"Ich will stärker, geschickter oder mächtiger werden."', None),
            ("KAMPF", 3, "DIA_Fun_Handel_Condition", "DIA_Fun_LehreKAMPF_Info", '"Ich will besser kämpfen."', None)):
        w(f"instance DIA_{tinst}_{suf} (C_INFO)")
        w("{")
        w(f"\tnpc = {tinst};")
        w(f"\tnr = {nr};")
        w(f"\tcondition = {cond};")
        w(f"\tinformation = {info};")
        w("\tpermanent = TRUE;")
        if extra:
            w(f"\t{extra}")
        w(f"\tdescription = {desc};")
        w("};")
w()

# ---- Gilden, Held, Takt
sect("held")
w("// --- Gilden: gleiche Gilde Freund, die vier Spielergilden untereinander Feind, Händler (GIL_NONE) neutral -------------")
PG = [g["gil"] for g in GUILDS]
w("func void Fun_Gilden()")
w("{")
for a in PG:
    for b in PG:
        w(f"\tWld_SetGuildAttitude({a}, {'ATT_FRIENDLY' if a == b else 'ATT_HOSTILE'}, {b});")
    w(f"\tWld_SetGuildAttitude({a}, ATT_NEUTRAL, GIL_NONE);")
    w(f"\tWld_SetGuildAttitude(GIL_NONE, ATT_NEUTRAL, {a});")
w("};")
w()
w("func int Fun_GildeVonWahl(var int wahl)")
w("{")
for i, g in enumerate(GUILDS):
    w(f"\tif (wahl == {i}) {{ return {g['gil']}; }};")
w("\treturn GIL_MIL;")
w("};")
w()
sect("heldstart")
w("// Held bekommt Gilde, Werte und Ausrüstung - einmal, solange er noch keine Gilde hat (FUN_TAKT_ALLE)")
w("func void Fun_HeldStart(var int wahl)")
w("{")
w("\tvar int g;")
w("\tg = Fun_GildeVonWahl(wahl);")
w("\thero.guild = g;")
w("\tNpc_SetTrueGuild(hero, g);")
w("\tif (hero.attribute[ATR_STRENGTH] < Fun_StartStaerke(g)) { hero.attribute[ATR_STRENGTH] = Fun_StartStaerke(g); };")
w("\tif (hero.attribute[ATR_DEXTERITY] < Fun_StartGeschick(g)) { hero.attribute[ATR_DEXTERITY] = Fun_StartGeschick(g); };")
w("\thero.aivar[REAL_STRENGTH] = hero.attribute[ATR_STRENGTH];")
w("\thero.aivar[REAL_DEXTERITY] = hero.attribute[ATR_DEXTERITY];")
w("\tFun_GildenStaerke(g);")
w("\tif (hero.attribute[ATR_HITPOINTS_MAX] < 100) { hero.attribute[ATR_HITPOINTS_MAX] = 100; };")
w("\thero.attribute[ATR_HITPOINTS] = hero.attribute[ATR_HITPOINTS_MAX];")
w("\thero.lp = hero.lp + 10;")
w("\tif (hero.attribute[ATR_MANA_MAX] < 20) { hero.attribute[ATR_MANA_MAX] = 20; };")
w("\thero.attribute[ATR_MANA] = hero.attribute[ATR_MANA_MAX];")
w("\tCreateInvItems(hero, ItPo_Mana_01, 3);")
for i in range(14):
    pass
w("\tPLAYER_TALENT_TAKEANIMALTROPHY[TROPHY_Teeth] = TRUE;")
for t in ["TROPHY_Claws", "TROPHY_Fur", "TROPHY_Heart", "TROPHY_ShadowHorn", "TROPHY_FireTongue", "TROPHY_BFWing",
          "TROPHY_BFSting", "TROPHY_Mandibles", "TROPHY_CrawlerPlate", "TROPHY_DrgSnapperHorn", "TROPHY_ReptileSkin"]:
    w(f"\tPLAYER_TALENT_TAKEANIMALTROPHY[{t}] = TRUE;")
w("\tCreateInvItems(hero, ItMi_Gold, 200);")
w("\tCreateInvItems(hero, ItPo_Health_01, 5);")
w("\tCreateInvItems(hero, ItRu_TeleportTaverne, 1);")
for i, g in enumerate(GUILDS):
    arm, wpn, rng, ammo = START[g["k"]]
    w(f"\tif (wahl == {i})")
    w("\t{")
    w(f"\t\tCreateInvItem(hero, {arm});")
    w(f"\t\tAI_EquipArmor(hero, {arm});")
    # u203d (Nutzer: "die anfangsarmbrust kann nicht ausgeruestet werden erst wenn man eine neue kauft"): wie gekaufte Ware ins
    # Inventar legen und von Gothic anlegen lassen (EquipItem beim Helden lieferte eine nicht anlegbare Waffe)
    w(f"\t\tCreateInvItem(hero, {wpn});")
    w("\t\tAI_EquipBestMeleeWeapon(hero);")
    if rng:
        w(f"\t\tCreateInvItems(hero, {ammo}, 60);")
        w(f"\t\tCreateInvItem(hero, {rng});")
        w("\t\tAI_EquipBestRangedWeapon(hero);")
    if g["k"] == "NOV":
        w("\t\tif (hero.attribute[ATR_MANA_MAX] < 40) { hero.attribute[ATR_MANA_MAX] = 40; };")
        w("\t\thero.attribute[ATR_MANA] = hero.attribute[ATR_MANA_MAX];")
        w("\t\tNpc_SetTalentSkill(hero, NPC_TALENT_MAGE, 1);")
        w("\t\tCreateInvItems(hero, ItRu_FireBolt, 1);")
        w("\t\tCreateInvItems(hero, ItPo_Mana_01, 5);")
        w("\t\tCreateInvItems(hero, ItKe_Innos_MIS, 1);")
    if g["tele"]:
        w(f"\t\tCreateInvItems(hero, {g['tele']}, 1);")
    w(f'\t\tAI_Teleport(hero, "{g["start"]}");')
    w(f'\t\tPrint("Fun-Modus: du gehörst zum Lager {g["lager"]}. Ü = Schlachtübersicht, Ä = Schlachtruf, # = Begleiter-Befehl.");')
    w("\t};")
w("\tFun_Haltungen();")
w("};")
w()
sect("frueh")
w("// Haltung der Begleiter und Händler zum eigenen Helden (je PC; der Coop gleicht sie für FUN_-NPCs nicht ab)")
w("func void Fun_Haltung(var C_NPC n, var int gil)")
w("{")
w("\tvar int soll;")
w("\tif (!Hlp_IsValidNpc(n))")
w("\t{")
w("\t\treturn;")
w("\t};")
w("\tif (gil == GIL_NONE)")
w("\t{")
w("\t\tsoll = ATT_NEUTRAL;")
w("\t\tif (Fun_GildeVonHaendler(n) == Npc_GetTrueGuild(hero))")
w("\t\t{")
w("\t\t\tsoll = ATT_FRIENDLY;")
w("\t\t};")
w("\t}")
w("\telse if (gil == Npc_GetTrueGuild(hero))")
w("\t{")
w("\t\tsoll = ATT_FRIENDLY;")
w("\t}")
w("\telse")
w("\t{")
w("\t\tsoll = ATT_HOSTILE;")
w("\t};")
w("\tif (Npc_GetAttitude(n, hero) != soll)")
w("\t{")
w("\t\tB_SetAttitude(n, soll);")
w("\t};")
w("};")
w("func void Fun_Haltungen()")
w("{")
w("\tvar C_NPC n;")
w("\tif (Npc_GetTrueGuild(hero) == GIL_NONE)")
w("\t{")
w("\t\treturn;")
w("\t};")
for tinst, g in traders:
    w(f"\tn = Hlp_GetNpc({tinst});")
    w("\tFun_Haltung(n, GIL_NONE);")
for cinst, gil, wp in companions:
    w(f"\tn = Hlp_GetNpc({cinst});")
    w(f"\tFun_Haltung(n, {gil});")
w("};")
w()
w("// Kapitel: Anzeige und Belohnung je PC, sobald FUN_KAPITEL steigt (auch wenn der Mitspieler den Stein benutzt hat)")
w("func void Fun_KapitelPruefen()")
w("{")
w("\tif (FUNL_KAPITEL_GESEHEN >= FUN_KAPITEL)")
w("\t{")
w("\t\treturn;")
w("\t};")
w("\tif (FUNL_KAPITEL_GESEHEN == 0)")
w("\t{")
w("\t\tFUNL_KAPITEL_GESEHEN = FUN_KAPITEL;")
w("\t\treturn;")
w("\t};")
w("\tFUNL_KAPITEL_GESEHEN = FUN_KAPITEL;")
w("\tKapitel = FUN_KAPITEL;")
w("\thero.lp = hero.lp + 5;")
w("\tCreateInvItems(hero, ItMi_Gold, 300 * FUN_KAPITEL);")
w("\tif (Npc_GetTrueGuild(hero) == GIL_NOV)")
w("\t{")
w("\t\tNpc_SetTalentSkill(hero, NPC_TALENT_MAGE, FUN_KAPITEL);")
w("\t};")
SUB = {2: "Die Händler haben neue Ware", 3: "Die Wälder werden gefährlicher", 4: "Die Lager rüsten auf",
       5: "Trolle im Land", 6: "Das letzte Kapitel"}
TEX = {2: "chapter2.tga", 3: "chapter2.tga", 4: "chapter4.tga", 5: "chapter4.tga", 6: "chapter6.tga"}
for k in range(2, 7):
    w(f'\tif (FUN_KAPITEL == {k}) {{ IntroduceChapter("Kapitel {k}", "{SUB[k]}", "{TEX[k]}", "chapter_01.wav", 6000); }};')
w("};")
w()

# u203d: nach dem Tod Startwerte (Nutzer: "nach dem man stirbt und respawn sollten staerke etc. zurueckgesetzt werden")
sect("heldstart")
w("func void FUN_HELD_NACH_TOD()")
w("{")
w("\tif (!FUN_AKTIV)")
w("\t{")
w("\t\treturn;")
w("\t};")
# u205 (Nutzer: "nehm doch wenn man stirbt die verluste weg ... keep inventory und staerke etc. sollen bleiben"): nichts mehr
# zuruecksetzen - Inventar, Staerke, Geschick, Leben-Max und Mana-Max bleiben; nur volle Lebensenergie und volles Mana
w("\thero.aivar[AIV_FUN_GEZAEHLT] = FALSE;")
w("\thero.attribute[ATR_HITPOINTS] = hero.attribute[ATR_HITPOINTS_MAX];")
w("\thero.attribute[ATR_MANA] = hero.attribute[ATR_MANA_MAX];")
w('\tPrint("Du bist gefallen - Ausrüstung und Werte bleiben erhalten.");')
w("};")
w()

# u203d (Nutzer: "die eigenen npc duerfen einen selber nicht angreifen"): Menschen greifen im Fun-Spiel keinen Spieler ihrer Gilde
# an (auch die Figur des Mitspielers, sie traegt seine Gilde); Banditen sehen jeden Spieler der Gilde Bandit als einen der Ihren,
# egal welche Ruestung er traegt (sonst greifen sie jeden ohne Banditenruestung an, C_PlayerIsFakeBandit)
sect("start")
w("func void B_Attack(var C_NPC slf, var C_NPC oth, var int attack_reason, var int wait)")
w("{")
w("\tif (FUN_AKTIV)")
w("\t{")
w("\t\tif ((slf.guild < GIL_SEPERATOR_HUM) && (slf.guild != GIL_NONE) && (slf.guild == Npc_GetTrueGuild(oth)))")
w("\t\t{")
w("\t\t\treturn;")
w("\t\t};")
w("\t};")
w("\tB_Attack_Old(slf, oth, attack_reason, wait);")
w("};")
w()
w("func int C_PlayerIsFakeBandit(var C_NPC slf, var C_NPC oth)")
w("{")
w("\tif (FUN_AKTIV)")
w("\t{")
w("\t\tif (Npc_GetTrueGuild(oth) == GIL_BDT)")
w("\t\t{")
w("\t\t\treturn TRUE;")
w("\t\t};")
w("\t};")
w("\treturn C_PlayerIsFakeBandit_Old(slf, oth);")
w("};")
w()

# Startup und Init
sect("start")
w("// --- Start: keine Story, keine Story-NPCs, nur Lager, Händler, Begleiter, Monster und der Boss --------------------------")
w("func void Fun_Startup()")
w("{")
w("\tFUN_AKTIV = TRUE;")
w("\tFUN_KAPITEL = 1;")
w("\tKapitel = 1;")
w("\tFUNL_KAPITEL_GESEHEN = 1;")
w("\tFUNL_BEGL_KAP = 1;")
w("\tHero_HackChance = 10;")
for tinst, g in traders:
    w(f'\tWld_InsertNpc({tinst}, "{g["hdl"]}");')
for cinst, gil, wp in companions:
    w(f'\tWld_InsertNpc({cinst}, "{wp}");')
for si, (wp, orig, base) in enumerate(SLOTS):
    w(f'\tWld_InsertNpc(FUN_M{si:03d}_T{base}, "{wp}");')
w(f'\tWld_InsertNpc(FUN_BOSS_K1, "{BOSS_WP}");')
w("\tFun_SchlachtStart();")
w("};")
w()
w("func void Fun_Init()")
w("{")
w("\tB_InitMonsterAttitudes();")
w("\tFun_Gilden();")
w("\tFun_Haltungen();")
w("\tFun_HaltungenSchlacht();")
w("};")
w()
w("FUNC VOID STARTUP_NewWorld()")
w("{")
w("\tif (COOP_FUNMODUS())")
w("\t{")
w("\t\tFun_Startup();")
w("\t\treturn;")
w("\t};")
w("\tFUN_AKTIV = FALSE;")
w("\tSTARTUP_NewWorld_Old();")
w("};")
w()
w("FUNC VOID INIT_NewWorld()")
w("{")
w("\tif (FUN_AKTIV)")
w("\t{")
w("\t\tFun_Init();")
w("\t\treturn;")
w("\t};")
w("\tINIT_NewWorld_Old();")
w("};")
w()

# Takt
sect("takt")
w("// --- Takt (GothicCoop alle 10 s) -------------------------------------------------------------------------------------")
for si, (wp, orig, base) in enumerate(SLOTS):
    w(f"var int FUNL_T{si:03d};")
w("var int FUNL_BEGL_T;")
w()
for si, (wp, orig, base) in enumerate(SLOTS):
    tiers = list(range(base, min(7, base + 5) + 1))
    w(f"func void Fun_Platz{si:03d}()   // {wp} (Original: {orig})")
    w("{")
    w("\tvar C_NPC m;")
    w("\tvar int t;")
    w(f"\tt = {base} + Fun_KapitelNr() - 1;")
    w(f"\tif (t > {tiers[-1]}) {{ t = {tiers[-1]}; }};")
    for i, t in enumerate(tiers):
        kw = "if" if i == 0 else "else if"
        w(f"\t{kw} (t == {t}) {{ m = Hlp_GetNpc(FUN_M{si:03d}_T{t}); }}")
    w("\telse { m = Hlp_GetNpc(FUN_M%03d_T%d); };" % (si, tiers[0]))
    w("\tif (Hlp_IsValidNpc(m))")
    w("\t{")
    w("\t\tif (!Npc_IsDead(m))")
    w("\t\t{")
    w(f"\t\t\tFUNL_T{si:03d} = 0;")
    w("\t\t\tif (Fun_NaheLager(m))")
    w("\t\t\t{")
    w(f'\t\t\t\tAI_Teleport(m, "{wp}");')
    w("\t\t\t};")
    w("\t\t\treturn;")
    w("\t\t};")
    w("\t};")
    w(f"\tFUNL_T{si:03d} = FUNL_T{si:03d} + 1;")
    w(f"\tif (FUNL_T{si:03d} < FUN_RESPAWN_TAKTE)")
    w("\t{")
    w("\t\treturn;")
    w("\t};")
    w(f"\tFUNL_T{si:03d} = 0;")
    for i, t in enumerate(tiers):
        kw = "if" if i == 0 else "else if"
        w(f'\t{kw} (t == {t}) {{ Wld_InsertNpc(FUN_M{si:03d}_T{t}, "{wp}"); }}')
    w(f'\telse {{ Wld_InsertNpc(FUN_M{si:03d}_T{tiers[0]}, "{wp}"); }};')
    w("};")
w()
sect("hilfe")
w("// u203d: Monster in einem Lager? (30 m um Start-, Haendler- und Begleiterpunkte)")
w("func int Fun_NaheLager(var C_NPC m)")
w("{")
_lagerwps = []
for _g in GUILDS:
    _lagerwps += [_g["start"], _g["hdl"]] + _g["begl"]
for _wp in _lagerwps:
    w(f'\tif (Npc_GetDistToWP(m, "{_wp}") < 3000)')
    w("\t{")
    w("\t\treturn TRUE;")
    w("\t};")
w("\treturn FALSE;")
w("};")
w()
w("func int Fun_NpcLebt(var C_NPC n)")
w("{")
w("\tif (!Hlp_IsValidNpc(n)) { return FALSE; };")
w("\tif (Npc_IsDead(n)) { return FALSE; };")
w("\treturn TRUE;")
w("};")
w()
sect("takt")
w("func void Fun_Boss()")
w("{")
w("\tvar C_NPC b;")
for k in range(1, 7):
    kw = "if" if k == 1 else "else if"
    w(f"\t{kw} (Fun_KapitelNr() == {k}) {{ b = Hlp_GetNpc(FUN_BOSS_K{k}); }}")
w("\telse { b = Hlp_GetNpc(FUN_BOSS_K1); };")
w("\tif (Fun_NpcLebt(b))")
w("\t{")
w("\t\tFUNL_BOSS_T = 0;")
w("\t\treturn;")
w("\t};")
w("\tFUNL_BOSS_T = FUNL_BOSS_T + 1;")
w("\tif (FUNL_BOSS_T < FUN_BOSS_TAKTE)")
w("\t{")
w("\t\treturn;")
w("\t};")
w("\tFUNL_BOSS_T = 0;")
for k in range(1, 7):
    kw = "if" if k == 1 else "else if"
    w(f'\t{kw} (Fun_KapitelNr() == {k}) {{ Wld_InsertNpc(FUN_BOSS_K{k}, "{BOSS_WP}"); }}')
w('\telse { Wld_InsertNpc(FUN_BOSS_K1, "%s"); };' % BOSS_WP)
w('\tPrint("An der Taverne ist ein neuer Boss aufgetaucht!");')
w("};")
w()
w("// Händler fehlen nie, tote Begleiter kommen nach 5 Minuten zurück; beim Kapitelaufstieg werden die Begleiter stärker")
w("func void Fun_Lager()")
w("{")
w("\tvar int fehlt;")
w("\tvar C_NPC n;")
for tinst, g in traders:
    w(f"\tn = Hlp_GetNpc({tinst});")
    w(f"\tif (!Hlp_IsValidNpc(n)) {{ Wld_InsertNpc({tinst}, \"{g['hdl']}\"); }};")
w("\tfehlt = FALSE;")
for cinst, gil, wp in companions:
    w(f"\tn = Hlp_GetNpc({cinst});")
    w("\tif (!Fun_NpcLebt(n)) { fehlt = TRUE; };")
w("\tif (fehlt)")
w("\t{")
w("\t\tFUNL_BEGL_T = FUNL_BEGL_T + 1;")
w("\t\tif (FUNL_BEGL_T >= FUN_BEGL_TAKTE)")
w("\t\t{")
w("\t\t\tFUNL_BEGL_T = 0;")
for cinst, gil, wp in companions:
    w(f"\t\t\tn = Hlp_GetNpc({cinst});")
    w(f"\t\t\tif (!Fun_NpcLebt(n)) {{ Wld_InsertNpc({cinst}, \"{wp}\"); }};")
w("\t\t};")
w("\t}")
w("\telse")
w("\t{")
w("\t\tFUNL_BEGL_T = 0;")
w("\t};")
w("\tif (FUNL_BEGL_KAP < FUN_KAPITEL)")
w("\t{")
w("\t\tFUNL_BEGL_KAP = FUN_KAPITEL;")
for cinst, gil, wp in companions:
    w(f"\t\tn = Hlp_GetNpc({cinst});")
    w("\t\tif (Fun_NpcLebt(n)) { B_SetAttributesToChapter(n, Fun_KapitelNr()); B_SetFightSkills(n, 30 + 10 * Fun_KapitelNr()); };")
w("\t};")
w("};")
w()
w("func void FUN_TAKT_HOST()")
w("{")
w("\tif (!FUN_AKTIV)")
w("\t{")
w("\t\treturn;")
w("\t};")
for si in range(len(SLOTS)):
    w(f"\tFun_Platz{si:03d}();")
w("\tFun_Boss();")
w("\tFun_Lager();")
w("\tFun_SchlachtHost();")
w("};")
w()
w("func void FUN_TAKT_ALLE()")
w("{")
w("\tif (!FUN_AKTIV)")
w("\t{")
w("\t\treturn;")
w("\t};")
w("\tif (Npc_GetTrueGuild(hero) == GIL_NONE)")
w("\t{")
w("\t\tFun_HeldStart(COOP_FUNGILDE());")
w("\t};")
w("\tFun_Haltungen();")
w("\tFun_KapitelPruefen();")
w("\tFun_SchlachtAlle();")
w("};")

exec(open(os.path.join(HERE, "gen_schlacht.py"), encoding="utf-8").read())   # u204: Schlacht-Paket
ORDER = ["kopf", "hilfe", "stein", "monster", "menschen", "frueh", "steinfunk", "dialoginst", "dialogfunk", "held", "heldstart",
         "schlacht", "start", "takt"]
assert set(SECT) <= set(ORDER), set(SECT) - set(ORDER)
out = []
for n in ORDER:
    out += SECT.get(n, [])

# Gothics Parser (zParserExtender) meldet bei einzeiligen Bloecken wie "func int X() { return TRUE; };" oder
# "if (...) { return; };" teils "Expected ';'" (Test 09.11.: Zeilen 3367, 4158). Darum jeden Block mehrzeilig wie in den
# Original-Skripten: Kopf, "{", jede Anweisung eine Zeile, "}" bzw. "};".
_BLK = re.compile(r'^(\t*)([^{}"]*?)\s*\{\s*([^{}]*?)\s*\}(;?)\s*$')   # Zeichenketten im Rumpf ohne ; { }
def _expand(lines):
    res = []
    for ln in lines:
        m = _BLK.match(ln)
        if not m or not m.group(3) or "//" in ln or any(";" in q for q in re.findall(r'"[^"]*"', m.group(3))):
            res.append(ln)
            continue
        ind, head, body, semi = m.groups()
        if head:
            res.append(ind + head)
        res.append(ind + "{")
        for st in [x.strip() for x in body.split(";") if x.strip()]:
            res.append(ind + "\t" + st + ";")
        res.append(ind + "}" + semi)
    return res
out = _expand(out)
text = "\r\n".join(out) + "\r\n"
open(OUT, "wb").write(text.encode("cp1252"))
print(OUT, len(out), "Zeilen,", len(SLOTS), "Spawnpunkte,", sum(min(7, b + 5) - b + 1 for _, _, b in SLOTS), "Monster-Instanzen")
