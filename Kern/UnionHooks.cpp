#include "resource.h"

namespace GOTHIC_ENGINE {
    TSaveLoadGameInfo& SaveLoadGameInfo = UnionCore::SaveLoadGameInfo;

    void _Game_Entry() {
        Game_Entry();
    }

    void _Game_Init() {
        Game_Init();
        CoopCrashFilterPulse();   // v101 (A18b): GTs Absturz-Filter vor Othellos (Hooks.cpp)
        CoopRuneLookInit();       // v106: eigenes Aussehen der Teleport-Rune (CoopTeleport.cpp)
        if (CoopWpIsWorld())
            CoopWpWorldInit();    // u33: Weltprozess - eigener Ordner, Fenster, Verbindung zum Host
        else {
            CoopWpHostCleanupOld();   // u36: alten <Spiel>\CoopWelt (u34/u35) entfernen - lag im Spielordner (CoopWorldProcess.cpp)
            CoopAutoTestInit();       // u49: automatischer Testlauf - Plugins des Testordners verstecken, Rolle melden
        }
    }

    void _Game_Loop() {
        if (CoopWpIsWorld()) {   // u33: Weltprozess - nur Figur, Held, Kamera (CoopWorldProcess.cpp), keine Coop-Module
            try {
                CoopCrashFilterPulse();
                CoopWpWorldLoop();
            }
            catch (std::exception& e) {
                CoopErrorLog("Weltprozess", e.what(), PluginState.c_str());
            }
            catch (...) {
                CoopErrorLog("Weltprozess", "Zugriffsfehler (SEH) oder unbekannte Ausnahme", PluginState.c_str());
            }
            return;
        }
        try {
            static bool sabotageChecked = false;   // v79: Rueckhalt fuer Othellos Sabotage (Plugin.cpp)
            if (!sabotageChecked) {
                sabotageChecked = true;
                CoopOthelloSabotageCheck("erstes Spielbild", false);
            }
            CoopCrashFilterPulse();     // v101 (A18b): Othello setzt seinen Absturz-Filter bei SetIsActive neu - GT bleibt davor
            CoopMenuMouseGameFrame();   // v57: ohne offenes Menue Zeiger weg
            CoopLangRefresh();          // v95: Sprache der Coop-Anzeigen (Gothic.ini coopLang)
            Game_Loop();
            CoopDiffPulse();            // v67: Schwierigkeitsgrad (Host sendet, Kampf-EP-Konstante)
            CoopNewGamePulse();         // v91: gemeinsames neues Spiel (Intro-Abgleich aus, Platz neben dem Host, Diego-Sperre)
            CoopFunPulse();             // u203: Fun-Modus - Takt alle 10 s (auch ohne Verbindung)
        }
        catch (std::exception& e) {
            CoopErrorLog("Game_Loop", e.what(), PluginState.c_str());
            if (CoopErrorSaveDetails()) SaveErrorDetails();
        }
        catch (...) {
            CoopErrorLog("Game_Loop", "Zugriffsfehler (SEH) oder unbekannte Ausnahme", PluginState.c_str());
            if (CoopErrorSaveDetails()) SaveErrorDetails();
        }
    }

    void _Game_Exit() {
        CoopWpHostShutdown();   // u33: Weltprozess beenden (falls er nicht im Job-Objekt laeuft)
    }

    void _Game_PreLoop() {
    }

    void _Game_PostLoop() {
    }

    void _Game_MenuLoop() {
        if (CoopWpIsWorld()) {   // u33: Weltprozess - nur den Slot laden (CoopWorldProcess.cpp)
            try {
                CoopCrashFilterPulse();
                CoopWpWorldMenuPulse();
            }
            catch (...) {
                CoopErrorLog("Weltprozess-Menue", "Zugriffsfehler (SEH) oder unbekannte Ausnahme", PluginState.c_str());
            }
            return;
        }
        // v40: Mehrspieler im Hauptmenue - Union ruft das aus dem Render-Platz (+0x1C) jeder Menue-vtable (SHW32+0x59C00)
        try {
            static bool sabotageChecked = false;   // v79: Rueckhalt fuer Othellos Sabotage (Plugin.cpp)
            if (!sabotageChecked) {
                sabotageChecked = true;
                CoopOthelloSabotageCheck("erstes Menuebild", false);
            }
            CoopCrashFilterPulse();   // v101 (A18b)
            CoopRuneLookInit();       // v106: falls beim Start noch nicht moeglich
            CoopLangRefresh();        // v95: Sprache der Coop-Anzeigen (Gothic.ini coopLang)
            CoopLobbyPulse();
            CoopSteamPulse();         // v87: Steam - auch im Hauptmenue (Rueckrufe, Tunnel, Beitreten aus Steam)
            CoopWpHostMenuPulse();    // u39: Weltprozess schon ab dem COOP-Menue vorstarten (versteckt)
            CoopAutoTestMenuPulse();  // u49: automatischer Testlauf - Client starten (Host), Slot laden
        }
        catch (std::exception& e) {
            CoopErrorLog("Game_MenuLoop", e.what(), PluginState.c_str());
        }
        catch (...) {
            CoopErrorLog("Game_MenuLoop", "Zugriffsfehler (SEH) oder unbekannte Ausnahme", PluginState.c_str());
        }
        try {
            CoopTitleMenuPulse();     // v84: "Hauptmenue" im Esc-Menue - Menues im naechsten Menuebild schliessen
            CoopIngameMenuLoadPulse(); // u91: Held tot bzw. Sitzung beendet - ueber das Menue laden (CoopMenuLobby.cpp)
            CoopMainMenuEscGuard();   // v59: Esc im Hauptmenue ohne Spiel = schwarzer Bildschirm - abfangen
            CoopVersionMenuPulse();   // v58: Fassung in den Versionszeilen (auch im Esc-Menue)
            CoopLangMenuPulse();      // v95: Menue-Texte Deutsch/English (COOP_MENU.D userString[2]/[3])
            CoopSteamMenuPulse();     // v87: Steam-Menue (Freunde, Status)
            CoopIngameLoadListPulse(); // v91: Spielstand-Liste im Esc-Menue
            CoopMenuMousePulse();     // v57: Maus im Menue
            CoopPreviewPulse();       // v60: 3D-Vorschau im COOP-Menue (zeichnet im naechsten Bild ueber DrawItems des Rahmens)
            CoopDiffMenuPulse();      // v67: Schwierigkeitsgrad - Stufe/Einzelwerte, Hinweiszeile
            CoopDiffPulse();          // v67: auch im Menue (Host sendet die Regeln schon in der Wartephase)
        }
        catch (std::exception& e) {
            CoopErrorLog("Menue-Maus", e.what(), PluginState.c_str());
        }
        catch (...) {
            CoopErrorLog("Menue-Maus", "Zugriffsfehler (SEH) oder unbekannte Ausnahme", PluginState.c_str());
        }
    }

    void _Game_SaveBegin() {
        if (CoopWpIsWorld()) {   // u33: Weltprozess - Gothic speichert beim Weltwechsel die alte Welt (nur Saves_CoopWelt), kein Coop
            IsSavingGame = true;
            return;
        }
        try {
            Game_SaveBegin();
        }
        catch (std::exception& e) {
            CoopErrorLog("Game_SaveBegin", e.what(), PluginState.c_str());
            if (CoopErrorSaveDetails()) SaveErrorDetails();
        }
        catch (...) {
            CoopErrorLog("Game_SaveBegin", "Zugriffsfehler (SEH) oder unbekannte Ausnahme", PluginState.c_str());
            if (CoopErrorSaveDetails()) SaveErrorDetails();
        }
    }

    void _Game_SaveEnd() {
        if (CoopWpIsWorld()) {
            IsSavingGame = false;
            return;
        }
        try {
            Game_SaveEnd();
        }
        catch (std::exception& e) {
            CoopErrorLog("Game_SaveEnd", e.what(), PluginState.c_str());
            if (CoopErrorSaveDetails()) SaveErrorDetails();
        }
        catch (...) {
            CoopErrorLog("Game_SaveEnd", "Zugriffsfehler (SEH) oder unbekannte Ausnahme", PluginState.c_str());
            if (CoopErrorSaveDetails()) SaveErrorDetails();
        }
    }

    void _LoadBegin() {
        if (CoopWpIsWorld()) {   // u33: Weltprozess (CoopWorldProcess.cpp)
            try {
                CoopWpWorldLoadBegin();
            }
            catch (...) {
                CoopErrorLog("Weltprozess LoadBegin", "Zugriffsfehler (SEH) oder unbekannte Ausnahme", PluginState.c_str());
            }
            return;
        }
        try {
            CoopDialogWatchLoadBegin();   // u155 (P160): offenen Dialog beenden, solange NPC und Held noch leben
        }
        catch (...) {
            CoopErrorLog("Dialog-Waechter LoadBegin", "Zugriffsfehler (SEH) oder unbekannte Ausnahme", PluginState.c_str());
        }
        try {
            CoopMenuMouseHide();   // v57: kein Zeiger ueber dem Ladebild
            CoopRuneLookInit();    // v106: vor dem Anlegen der Gegenstaende aus dem Spielstand
            LoadBegin();
        }
        catch (std::exception& e) {
            CoopErrorLog("LoadBegin", e.what(), PluginState.c_str());
            if (CoopErrorSaveDetails()) SaveErrorDetails();
        }
        catch (...) {
            CoopErrorLog("LoadBegin", "Zugriffsfehler (SEH) oder unbekannte Ausnahme", PluginState.c_str());
            if (CoopErrorSaveDetails()) SaveErrorDetails();
        }
    }

    void _LoadEnd() {
        if (CoopWpIsWorld()) {   // u33: Weltprozess (CoopWorldProcess.cpp)
            try {
                CoopWpWorldLoadEnd(false);
            }
            catch (...) {
                CoopErrorLog("Weltprozess LoadEnd", "Zugriffsfehler (SEH) oder unbekannte Ausnahme", PluginState.c_str());
            }
            return;
        }
        try {
            LoadEnd();
        }
        catch (std::exception& e) {
            CoopErrorLog("LoadEnd", e.what(), PluginState.c_str());
            if (CoopErrorSaveDetails()) SaveErrorDetails();
        }
        catch (...) {
            CoopErrorLog("LoadEnd", "Zugriffsfehler (SEH) oder unbekannte Ausnahme", PluginState.c_str());
            if (CoopErrorSaveDetails()) SaveErrorDetails();
        }
    }

    void CoopDialogSyncLoadKind(bool levelChange);   // u140 (P139): CoopDialogSync.cpp

    void _Game_LoadBegin_NewGame() {
        CoopDialogSyncLoadKind(false);
        try {
            CoopSaveSyncOnNewGame();   // v76: offene Coop-Auftraege und gemerkter Held gelten nicht fuer ein neues Spiel
            CoopTruheNeuesSpiel();     // u97: Coop-Truhe leer
        }
        catch (std::exception& e) {
            CoopErrorLog("CoopSaveSyncOnNewGame", e.what(), PluginState.c_str());
        }
        _LoadBegin();
    }

    void _Game_LoadEnd_NewGame() {
        _LoadEnd();
        try {
            CoopNewGameLoadEnd();   // v91: gemeinsames neues Spiel - Client neben den Host, Diego-Sperre
            CoopFunLoadEnd(true);   // u203: Fun-Modus - erster Takt, Merker fuer das neue Spiel aus
        }
        catch (std::exception& e) {
            CoopErrorLog("CoopNewGameLoadEnd", e.what(), PluginState.c_str());
        }
        catch (...) {
            CoopErrorLog("CoopNewGameLoadEnd", "Zugriffsfehler (SEH) oder unbekannte Ausnahme", PluginState.c_str());
        }
    }

    void CoopLegoHandleRepair(int slot);   // u196 (P206): CoopSaveSync.cpp

    void _Game_LoadBegin_SaveGame() {
        CoopDialogSyncLoadKind(false);
        try {
            CoopLegoHandleRepair(UnionCore::SaveLoadGameInfo.slotID);   // u196 (P206): LeGo-Zaehler vor dem Lesen der Dateien (auch Weltprozess)
        }
        catch (...) {
            CoopErrorLog("CoopLegoHandleRepair", "Ausnahme", PluginState.c_str());
        }
        try {
            if (!CoopWpIsWorld()) {          // u33: im Weltprozess kein gemeinsames Laden
                CoopSaveSyncOnLoadBegin();   // v17: Partner laedt denselben Stand mit
                CoopWorldSeenReset("Spielstand geladen");   // u47 (P88): "wer war zuletzt wo" gilt fuer den alten Stand
            }
        }
        catch (std::exception& e) {
            CoopErrorLog("CoopSaveSyncOnLoadBegin", e.what(), PluginState.c_str());
        }
        _LoadBegin();
    }

    void _Game_LoadEnd_SaveGame() {
        try {
            CoopFunLoadEnd(false);   // u203: Fun-Modus - erster Takt 3 s nach dem Laden
            Game_LoadEnd_SaveGame();
        }
        catch (std::exception& e) {
            CoopErrorLog("Game_LoadEnd_SaveGame", e.what(), PluginState.c_str());
            if (CoopErrorSaveDetails()) SaveErrorDetails();
        }
        catch (...) {
            CoopErrorLog("Game_LoadEnd_SaveGame", "Zugriffsfehler (SEH) oder unbekannte Ausnahme", PluginState.c_str());
            if (CoopErrorSaveDetails()) SaveErrorDetails();
        }
    }

    void _Game_LoadBegin_ChangeLevel() {
        CoopDialogSyncLoadKind(true);
        _LoadBegin();
    }

    void _Game_LoadEnd_ChangeLevel() {
        _LoadEnd();
        CoopFunLoadEnd(false);   // u203
    }

    // u64 (Othello-Coop v114, COOP-FIXES B10, nur Othello; dort Test v113: Absturz beim Client 2 s nach dem gemeinsamen Weltwechsel
    // in die Alte Mine, RemoteNpc::SanitizeStaleVisual auf einem NPC der alten Welt): Union meldet einen Weltwechsel aus seinem Haken
    // auf dem vtable-Platz oCGame::ChangeLevel (+0xA8: Game_LoadBegin_ChangeLevel, Original, Game_LoadEnd_ChangeLevel). Othello
    // ersetzt in oCGame::Render den virtuellen Aufruf (G1 0x0063DD5C, call [edx+0xA8]) durch OTHELLO_ABI+0xC5670 - das nimmt die vom
    // Helden beschworenen NPCs mit (aivar-Bit 0x10 bei +0x304, auch die Coop-Figur) und ruft ChangeLevel direkt (mov eax, 0x0063CD60;
    // call eax). Unions Meldungen kamen darum unter Othello nie an: GTs LoadBegin/LoadEnd liefen nicht (Namensliste, SyncNpcs,
    // Weltschluessel, Story-Vergleichsstand blieben bei der alten Welt). GT hakt den Eingang von ChangeLevel darum selbst ein
    // (unveraendert unter Othello, Speicherabbild) und fuehrt LoadBegin/LoadEnd aus, wenn Union es nicht schon getan hat
    // (IsLoadingLevel). In G2A und Vanilla G1 kommt Union vorher an, der Haken reicht dort nur durch.
    void __fastcall oCGame_ChangeLevel_Coop(oCGame* _this, void* vtable, zSTRING const& level, zSTRING const& start);
    CInvoke<void(__thiscall*)(oCGame*, zSTRING const&, zSTRING const&)> Ivk_oCGame_ChangeLevel_Coop(CoopAddr::oCGame_ChangeLevel,
        &oCGame_ChangeLevel_Coop);
    void __fastcall oCGame_ChangeLevel_Coop(oCGame* _this, void* vtable, zSTRING const& level, zSTRING const& start) {
        const bool own = !IsLoadingLevel;   // Union hat Game_LoadBegin_ChangeLevel nicht gemeldet
        if (own) {
            static int logged = 0;
            if (logged++ < 20)
                OthelloCompatLog("[%lld s, %s] Weltwechsel nach %s (Startpunkt %s) ohne Meldung von Union - GT laedt selbst (LoadBegin/LoadEnd)",
                    DiagSeconds(), DiagRole(), level.ToChar(), start.ToChar());
            CoopDialogSyncLoadKind(true);
            _LoadBegin();
        }
        Ivk_oCGame_ChangeLevel_Coop(_this, level, start);
        if (own)
            _LoadEnd();
    }

    void _Game_LoadBegin_Trigger() {
        try {
            Game_LoadBegin_Trigger();
        }
        catch (std::exception& e) {
            CoopErrorLog("Game_LoadBegin_Trigger", e.what(), PluginState.c_str());
            if (CoopErrorSaveDetails()) SaveErrorDetails();
        }
        catch (...) {
            CoopErrorLog("Game_LoadBegin_Trigger", "Zugriffsfehler (SEH) oder unbekannte Ausnahme", PluginState.c_str());
            if (CoopErrorSaveDetails()) SaveErrorDetails();
        }
    }

    void _Game_LoadEnd_Trigger() {
    }

    void _Game_Pause() {
    }

    void _Game_Unpause() {
    }

    void _Game_DefineExternals() {
        try {
            CoopFunDefineExternals();   // u203: COOP_FUNMODUS, COOP_FUNGILDE fuer COOP_FUN.D
        }
        catch (...) {
            CoopErrorLog("Game_DefineExternals", "Ausnahme", "CoopFunDefineExternals");
        }
    }

    void _Game_ApplyOptions() {
    }

    /*
    Functions call order on Game initialization:
      - Game_Entry           * Gothic entry point
      - Game_DefineExternals * Define external script functions
      - Game_Init            * After DAT files init

    Functions call order on Change level:
      - Game_LoadBegin_Trigger     * Entry in trigger
      - Game_LoadEnd_Trigger       *
      - Game_Loop                  * Frame call window
      - Game_LoadBegin_ChangeLevel * Load begin
      - Game_SaveBegin             * Save previous level information
      - Game_SaveEnd               *
      - Game_LoadEnd_ChangeLevel   *

    Functions call order on Save game:
      - Game_Pause     * Open menu
      - Game_Unpause   * Click on save
      - Game_Loop      * Frame call window
      - Game_SaveBegin * Save begin
      - Game_SaveEnd   *

    Functions call order on Load game:
      - Game_Pause              * Open menu
      - Game_Unpause            * Click on load
      - Game_LoadBegin_SaveGame * Load begin
      - Game_LoadEnd_SaveGame   *
    */


#define AppDefault True
    CApplication* lpApplication = !CHECK_THIS_ENGINE ? Null : CApplication::CreateRefApplication(
        Enabled(AppDefault) _Game_Entry,
        Enabled(AppDefault) _Game_Init,
        Enabled(AppDefault) _Game_Exit,
        Enabled(AppDefault) _Game_PreLoop,
        Enabled(AppDefault) _Game_Loop,
        Enabled(AppDefault) _Game_PostLoop,
        Enabled(AppDefault) _Game_MenuLoop,
        Enabled(AppDefault) _Game_SaveBegin,
        Enabled(AppDefault) _Game_SaveEnd,
        Enabled(AppDefault) _Game_LoadBegin_NewGame,
        Enabled(AppDefault) _Game_LoadEnd_NewGame,
        Enabled(AppDefault) _Game_LoadBegin_SaveGame,
        Enabled(AppDefault) _Game_LoadEnd_SaveGame,
        Enabled(AppDefault) _Game_LoadBegin_ChangeLevel,
        Enabled(AppDefault) _Game_LoadEnd_ChangeLevel,
        Enabled(AppDefault) _Game_LoadBegin_Trigger,
        Enabled(AppDefault) _Game_LoadEnd_Trigger,
        Enabled(AppDefault) _Game_Pause,
        Enabled(AppDefault) _Game_Unpause,
        Enabled(AppDefault) _Game_DefineExternals,
        Enabled(AppDefault) _Game_ApplyOptions
    );
}