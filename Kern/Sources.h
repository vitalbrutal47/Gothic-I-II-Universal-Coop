// Supported with union (c) 2018-2021 Union team
// Add your sources this

// Automatically generated block
#pragma region Includes
#include "SafeQueue.cpp"
#include "CustomTypes.cpp"
#include "Chat.cpp"
#include "Utils.cpp"
#include "CoopCore.cpp"        // u1: Fassung, Sprache, Spielordner, Profil (Othello/Vanilla), Log-Archiv, Hauptprotokoll - alle Engines
#include "CoopAddr.h"          // u2: Engine-Tabelle - jede feste Adresse mit Namen, Wert je Engine (G1, G1A, G2, G2A)
#include "OthelloCompat.cpp"
#include "Global.cpp"
#include "CoopDiag.cpp"
#include "CoopLook.cpp"        // v55: Name, Adresse, eigenes Aussehen aus dem COOP-Menue (Gothic.ini), NPC-Suche
#include "Helpers.cpp"
#include "CoopWorlds.cpp"      // u29: getrennte Welten - Weltschluessel in den Grundpaketen, Spieler -> Welt
#include "CoopDamage.cpp"
#include "CoopDiagClient.cpp"
#include "Debugger.cpp"
#include "PlayerAnimation.cpp"
#include "LocalNpc.cpp"
#include "RemoteNpc.cpp"
#include "SyncHelpers.cpp"
#include "CoopTrace.cpp"
#include "CoopWorldSync.cpp"   // v13: Truhen und Gegenstaende (Host fuehrt den Bestand)
#include "CoopPlace.cpp"       // u10: Platz neben einem Helden, Bewegung zuruecksetzen (Speichern, Teleport, Neues Spiel) - alle Engines
#include "CoopSaveSync.cpp"    // v17: gemeinsames Speichern/Laden, Archiv, Liste im Spiel
#include "CoopCamera.cpp"      // v44: Kamera beim Mitspieler (Shift+F5)
#include "CoopFarSync.cpp"     // v41: Verfolgungspunkt beim Mitspieler, Todesabgleich ausserhalb der Reichweite
#include "CoopHitAuthority.cpp" // v53: Treffer auf den Helden eines Clients entscheidet der Client
#include "CoopDialogSync.cpp"  // v26: Dialoge - einer je NPC, von aussen beobachtbar
#include "CoopTruhe.cpp"       // u97: gemeinsame Coop-Truhe im Inventar (ITMI_COOP_TRUHE, Inhalt beim Host, im Spielstand)
#include "CoopFun.cpp"         // u203: Fun-Modus Gothic 2 (COOP_FUN.D: Gilde waehlen, Lager, Haendler, Begleiter, Boss, Gilden-PvP)
#include "CoopLogShip.cpp"     // v34/v35: Coop-Logs zum Partner (GothicCoopOthelloClient.log / GothicCoopOthelloHost.log)
#include "CoopCombatLead.cpp"  // v72: Kampf-Uebergabe - NPCs, die gegen einen Client kaempfen, rechnet dessen PC
#include "CoopTeleport.cpp"    // v102: Teleport-Rune zum Mitspieler (COOP_ITEMS.D, Ziel Mitspieler, Mana 0, Startausstattung)
#include "CoopPartnerMarker.cpp" // v104: Mitspieler-Markierung (Name ueber dem Kopf, Pfeil am Bildrand, Marke auf Othellos Karte)
#include "Client.cpp"
#include "Server.cpp"
#include "MappedPort.cpp"
#include "GameStats.cpp"
#include "PacketProcessor.cpp"
#include "DamageProcessor.cpp"
#include "VisibleNpcsUpdater.cpp"
#include "SpellCastProcessor.cpp"
#include "ReviveFriendLoop.cpp"
#include "Hooks.cpp"
#include "OthelloHookOrder.cpp"
#include "CoopDialogWatch.cpp"   // 18.10.2026: Dialog-Waechter (EV_PROCESSINFOS verloren)
#include "CoopAudit.cpp"
#include "CoopWorldProcess.cpp" // u33: Weltprozess - zweites Gothic beim Host, laedt die Welt eines Mitspielers (Shift+F12)
#include "Mods\ModLoA.cpp"     // u187: Mod-Profil Legend of Ahssun (Fundament + Mod-Varianten, docs\MODULE.md)
#include "Mods\CoopMods.cpp"   // u187: Verteiler der Mod-Profile (CoopModsInit)
#include "Plugin.cpp"
#include "CoopMenuLobby.cpp"   // v40: Mehrspieler im Hauptmenue (COOP_MENU.D, Haken auf zCMenu::HandleSelAction)
#include "CoopMenuInject.cpp"  // v81: COOP-Eintrag zur Laufzeit in Othellos MENU_MAIN / MENU_OPTIONS (vtable-Platz SetByScript)
#include "CoopSavePreview.cpp" // v77: Vorschau in der Liste "Spielstand waehlen" (Bilder beider PCs, Kapitel, Tag, Aufgaben)
#include "CoopMenuMouse.cpp"   // v57: Maus in Gothics Menues (Zeiger, Ueberfahren, Klick; GRawInput RegisterWrapCheck)
#include "CoopTitle.cpp"       // v82: "Hauptmenue" im Esc-Menue - zurueck zum Startbildschirm ohne Neustart
#include "CoopSteam.cpp"       // v87: Coop ueber Steam (Tunnel unter ENet, Rich Presence, Steam-Menue)
#include "CoopPreview.cpp"     // v60: 3D-Vorschau der eigenen Figur im COOP-Menue (Renderer coop6, GDX_CoopPreviewDraw)
#include "CoopDifficulty.cpp"  // v67: Schwierigkeitsgrad (Schaden, Leben der Gegner, Kampf-EP; Host gibt vor)
#include "CoopTempo.cpp"       // u181: gemeinsames Spieltempo der Testinstanzen (Abgleich Host/Client, Anzeige "Zeitraffer x2")
#include "CoopNewGame.cpp"     // v91: gemeinsames neues Spiel (Intro fuer beide ueberspringen, Platz neben dem Host, Diego)
#include "CoopSelfTest.cpp"    // v37: Coop-Testlauf (Shift+F11); v107: 100 Schritte, am Ende - liest den Zustand aller Module
#include "CoopShow.cpp"        // u171: Vorfuehrung fuer Aufnahmen (-coopaufnahme) - Host und Client gehen sichtbar durchs Menue
#include "CoopAutoTest.cpp"    // u49: automatischer Testlauf auf einem PC (-cooptest:host / -cooptest:client, tools\cooptest_lauf.py)
#include "UnionHooks.cpp"
#pragma endregion

// ...