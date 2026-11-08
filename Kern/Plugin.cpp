#include "resource.h"

namespace GOTHIC_ENGINE {
    void CoopLobbyAfterLoad();   // v40: CoopMenuLobby.cpp
    void CoopTempoPulse();          // u181: CoopTempo.cpp - gemeinsames Spieltempo der Testinstanzen
    void CoopMenuInjectInstall();   // v81: CoopMenuInject.cpp - COOP-Eintraege in Othellos Menues (vor dem ersten Menue)
    bool CoopTitlePulse();          // v82: CoopTitle.cpp - "Hauptmenue" im Esc-Menue, Startmenue aus Game_Loop
    void CoopSteamPulse();          // v87: CoopSteam.cpp - Steam-Rueckrufe, Tunnel, Rich Presence
    bool CoopSteamClientPrepare();  // v87: Steam-Ziel fuer den naechsten Client-Start (sonst IP)
    bool CoopSteamReconnect();      // v87: Shift+F2 - wieder ueber Steam, wenn die letzte Verbindung Steam war
    bool CoopSteamAvailable();      // v88: Steam angemeldet - Anzeige oben links
    unsigned long long CoopSteamClientHostId();   // v88: Client ueber Steam (0 = IP)
    void CoopSelfTestPulse();       // v107: CoopSelfTest.cpp steht jetzt am Ende von Sources.h
    void CoopAutoTestEarly();       // u49: CoopAutoTest.cpp - automatischer Testlauf (Testinstanz: Einzelinstanz-Sperre)
    void CoopAutoTestPulse();       // u49: Ablauf im Spiel

    // v79: Othellos Plugin-Sperre (OthelloUnlock.cpp, aus DllMain) - Bericht ins Coop-Log; Rueckhalt: sabotierte Engine-Bytes
    // wiederherstellen (bei Game_Init, im ersten Menue- und im ersten Spielbild). Nur Othello.
    extern "C" const char* CoopOthelloUnlockLog();
    extern "C" int CoopOthelloSabotageRepair(char* text, int size);
    void CoopOthelloSabotageCheck(const char* where, bool logOk) {
#if ENGINE == Engine_G1
        char text[512];
        CoopOthelloSabotageRepair(text, sizeof(text));
        if (text[0])
            OthelloCompatLog("%s (%s)", text, where);
        else if (logOk)
            OthelloCompatLog("Othello-Sabotage: die fuenf Engine-Bytes sind unveraendert (%s)", where);
#endif
    }

    static std::string CoopScriptSetLog;   // u195 (P204): Ergebnis der Skript-Weiche, ins Log in Game_Init

    void Game_Entry() {
        GetCurrentDirectory(MAX_PATH, GothicExeFolderPath);
        if (!CoopWpIsWorld())
            CoopScriptSetLog = CoopScriptSetSwitch();   // u195 (P204): Skriptsatz des Profils nach Autorun, bevor Gothic die Skripte liest
        if (CoopWpIsWorld())
            CoopWpEarlyInit();     // u35: Weltprozess - Meldungen und Beenden mitschneiden (CoopWorldProcess.cpp)
        CoopAutoTestEarly();       // u49: Testinstanz (-cooptest:client) - Einzelinstanz-Sperre wie im Weltprozess
        CoopMenuInjectInstall();   // v81: vor CGameManager::Menu (MENU_MAIN)

        SymInitialize(GetCurrentProcess(), NULL, true);
        SymSetSearchPath(GetCurrentProcess(), GothicExeFolderPath);

        std::string logFilePath = GothicExeFolderPath;
        logFilePath.append(CoopWpIsWorld() ? "\\GothicCoopWeltLog.log" : "\\GothicCoopLog.log");   // u33: Weltprozess eigene Datei
        GothicCoopLogPath = logFilePath;

        std::string configFilePath = GothicExeFolderPath;
        configFilePath.append("\\GothicCoopConfig.json");
        std::ifstream configFile(configFilePath);

        if (configFile.good()) {
            try {
                CoopConfig = json::parse(configFile);
            }
            catch (...) {
                OthelloCompatLog("Konfiguration %s nicht lesbar - Spiel endet", configFilePath.c_str());   // u35: auch ins Log
                Message::Error("(Gothic Coop) Invalid config file, please check your GothicCoopConfig.json file!");
                exit(1);
            }
            CoopModApplyConfigDefaults();   // u194 (P196): Vorgaben des Mod-Profils fuer Schalter, die die Datei nicht setzt (Mods\CoopMods.cpp)
            if (CoopWpIsWorld())
                OthelloCompatLog("Konfiguration %s gelesen", configFilePath.c_str());
        }
        else {
            OthelloCompatLog("Konfiguration %s fehlt (Arbeitsordner %s) - Spiel endet", configFilePath.c_str(), GothicExeFolderPath);   // u35
            Message::Error("(Gothic Coop) No config file found!");
            Message::Error(configFilePath.c_str());
            exit(1);
        }
    }

    void Game_Init() {
        MainThreadId = GetCurrentThreadId();
        CoopLegoNoteEntries();   // u170 (P177): Ziele der GT-Spruenge an den Eingaengen, bevor Skripte (LeGo) einhaken (CoopAudit.cpp)
        ToggleGameLogKey = ReadConfigKey("toggleGameLogKey", "KEY_P");
        ToggleGameStatsKey = ReadConfigKey("toggleGameStatsKey", "KEY_O");
        StartServerKey = ReadConfigKey("startServerKey", "KEY_F1");
        StartConnectionKey = ReadConfigKey("startConnectionKey", "KEY_F2");
        ReinitPlayersKey = ReadConfigKey("reinitPlayersKey", "KEY_F3");
        RevivePlayerKey = ReadConfigKey("revivePlayerKey", "KEY_F4");
        CoopSaveSyncInit();   // v17: Slots, Intervall, Tasten fuer gemeinsames Speichern
        CoopLogCrashReportOnce();   // v46: Othellos Absturzbericht der vorigen Sitzung ins GT-Log (geht zum Partner)

        if (CoopConfig.contains("port")) {
            ConnectionPort = CoopConfig["port"].get<int>();
        }

        if (CoopConfig.contains("bodyTextVarNr")) {
            MyBodyTextVarNr = CoopConfig["bodyTextVarNr"].get<int>();
        }

        if (CoopConfig.contains("headVarNr")) {
            MyHeadVarNr = CoopConfig["headVarNr"].get<int>();
        }

        PlayersDamageMultipler = CoopConfig["playersDamageMultipler"].get<int>();
        NpcsDamageMultipler = CoopConfig["npcsDamageMultipler"].get<int>();
        if (CoopConfig.contains("friendInstanceId")) {
            auto stdStringFriendInstanceId = CoopConfig["friendInstanceId"].get<std::string>();
            std::transform(stdStringFriendInstanceId.begin(), stdStringFriendInstanceId.end(), stdStringFriendInstanceId.begin(), ::tolower);
            FriendInstanceId = string(stdStringFriendInstanceId.c_str()).ToChar();
        }
        if (CoopConfig.contains("nickname")) {
            MyNickname = string(CoopConfig["nickname"].get<std::string>().c_str()).ToChar();
        }
        CoopSettingsRefresh(true);   // v55: Gothic.ini [GOTHICCOOP] (COOP-Menue) vor der json
        OthelloCompatLog("%s, gebaut %s", CoopVersionName().c_str(), CoopBuildStamp().c_str());   // v58: Bauzeit im Log
        CoopModulesReport();   // u3: welche Module in dieser Engine nicht laufen
        CoopModsInit();        // u187: Mod-Profil (Mods\CoopMods.cpp, docs\MODULE.md)
        if (!CoopScriptSetLog.empty())
            OthelloCompatLog("%s", CoopScriptSetLog.c_str());   // u195 (P204)
        CoopScriptMapPulse();  // u195 (P199): Skript-Spur im Absturzprotokoll schon fuer das erste Laden
        {
            std::string unlock = CoopOthelloUnlockLog();   // v79: was DllMain an Othellos Sperre abgeschaltet hat
            while (!unlock.empty() && unlock[unlock.size() - 1] == '\n')
                unlock.erase(unlock.size() - 1);
            if (!unlock.empty())
                OthelloCompatLog("%s", unlock.c_str());
            CoopOthelloSabotageCheck("Game_Init", true);
        }
        if (CoopConfig.contains("editmode")) {
            auto editModeValue = string(CoopConfig["editmode"].get<std::string>().c_str());
            if (editModeValue.Compare("MARVIN")) {
                WorldEditMode = true;
                Thread  t;
                ClientThread = &t;
                ChatLog("World edit mode is activated!");
            }
        }
    }

    // --- v39: Verbinden, Neuverbinden, Rollenwechsel -------------------------------------------------------------------
    //
    // Nutzer: (1) "wenn man sich verbunden hat, obwohl der Server nicht an war, soll man sich danach immer noch verbinden
    // koennen, ohne das Spiel neu zu starten", (2) "wenn man aus Versehen F2 drueckt, soll man danach immer noch mit F1 zum
    // Host wechseln koennen und andersrum", (3) nur noch Shift+F1..F4. Bisher: der Client-Faden lief nach einem
    // Fehlschlag ohne Verbindung endlos, ClientThread blieb gesetzt (F2 = nur noch Pause, F1 gesperrt); der Server-Faden
    // liess sich nicht beenden. Jetzt melden beide Faeden ihren Zustand (CoopClientState/CoopServerState, Global.cpp) und
    // enden auf Wunsch (CoopClientStop/CoopServerStop); CoopNetPulse raeumt danach auf und startet die gewuenschte Rolle.
    // Host -> Client nur ohne verbundene Spieler. Fortsetzen nach der Pause gleicht wie beim Verbinden ab (CoopResyncResumed).
    static int CoopPendingRole = 0;   // 1 Host, 2 Client - wird gestartet, sobald kein Faden mehr laeuft

    static void CoopDropQueuedPackets() {   // alte, nicht mehr gesendete Pakete nicht an die neue Verbindung schicken
        while (!ReadyToSendJsons.isEmpty())
            ReadyToSendJsons.dequeue();
        while (!ReadyToBeDistributedPackets.isEmpty())
            ReadyToBeDistributedPackets.dequeue();
    }

    static void CoopStartServer() {
        CoopSettingsRefresh(true);   // v55: Port/Name/Aussehen aus dem COOP-Menue
        CoopDropQueuedPackets();
        wchar_t mappedPort[1234];
        std::wcsncpy(mappedPort, L"UDP", 1234);
        new MappedPort(ConnectionPort, mappedPort, mappedPort);

        CoopServerStop = 0;
        CoopServerState = 0;
        Thread t;
        t.Init(&CoopServerThread);
        t.Detach();
        ServerThread = &t;
        MyselfId = "HOST";
        Myself = NULL;   // neu mit der Kennung HOST anlegen (Game_Loop)
        CoopWorldsResetPeers("Host gestartet");   // u201: alte Kennungen frueherer Sitzungen vergessen
        CoopSaveSyncRoleStart(true);   // v76: gemerkter Held aus einer Client-Verbindung gilt nicht mehr
        CoopLookApplyOwn("Host gestartet");   // v40: im Hauptmenue noch kein Held - dann nach dem Laden (LoadEnd)
    }

    static void CoopStartClient() {
        CoopSettingsRefresh(true);   // v55: IP/Port/Name/Aussehen aus dem COOP-Menue (Client.cpp liest CoopServerIp)
        CoopDropQueuedPackets();
        CoopSteamClientPrepare();    // v87: gewaehltes Steam-Ziel -> Tunnel starten (Client.cpp verbindet sich dann lokal)
        if (player)   // v40: im Hauptmenue noch keine Welt - den HOST legt das erste Paket nach dem Laden an
            addSyncedNpc("HOST");

        CoopClientStop = 0;
        CoopClientState = 0;
        Thread  t;
        t.Init(&CoopClientThread);
        t.Detach();
        ClientThread = &t;
        Myself = NULL;
        CoopWorldsResetPeers("Client gestartet");   // u201: alte Kennungen frueherer Sitzungen vergessen

        if (player && ogame) {   // v40: siehe oben (Uhrzeit kommt nach dem Laden vom Host)
            ogame->SetTime(ogame->GetWorldTimer()->GetDay(), 12, 00);
            rtnMan->RestartRoutines();
        }
        CoopLookApplyOwn("Client gestartet");
    }

    static void CoopClientEnded() {
        CoopCamStop("Verbindung beendet");   // v44
        CoopSaveSyncConnectionEnded();        // v71: offene Uebernahme/Auftraege dieser Verbindung verwerfen
        CoopLeadClear("Verbindung beendet");  // v72
        CoopWorldsResetPeers("Verbindung beendet");   // u201: sonst Geister-Verfolgungspunkt nach dem Wiederverbinden
        ClientThread = NULL;
        CoopClientState = 0;
        CoopClientStop = 0;
        IsCoopPaused = false;
        MyselfId = "_player_";
        Myself = NULL;
        CurrentPing = -1;
        // Figuren der Mitspieler entfernen (DESTROY_NPC, wie beim Trennen am Host), Welt-NPCs wieder frei
        std::vector<string> players, others;
        for (auto const& kv : SyncNpcs) {
            if (IsCoopPlayer(kv.first) && kv.second && kv.second->npc)
                players.push_back(kv.first);
            else
                others.push_back(kv.first);   // auch "HOST" ohne angelegte Figur (nie verbunden)
        }
        for (auto const& n : players)
            if (SyncNpcs[n])
                removeSyncedNpc(n);
        for (auto const& n : others)
            SyncNpcs.erase(n);
    }

    static void CoopServerEnded() {
        CoopCamStop("Host beendet");   // v44
        ServerThread = NULL;
        CoopServerState = 0;
        CoopServerStop = 0;
        MyselfId = "_player_";
        Myself = NULL;
        BroadcastNpcs.clear();   // nur der Host sendet NPCs
        CoopLeadClear("Host beendet");   // v72
        CoopWorldsResetPeers("Host beendet");   // u201
        CoopSaveSyncPeersReset();   // v40: im Hauptmenue darf der Host auch mit Mitspieler enden (ENet meldet kein DISCONNECT mehr)
    }

    static void CoopNetPulse() {
        if (ClientThread && !ServerThread) {
            const LONG st = CoopClientState;
            if (st == 4 && !CoopClientStop) {
                CoopClientStop = 1;   // der Faden zerstoert jetzt seinen ENet-Host und meldet 5
                CoopSaveSyncConnectionLost();   // v76: eigenen Helden merken - beim Wiederverbinden gilt er (Variante b)
                ChatLog(CoopTr("Verbindung zum Host verloren - Shift+F2 verbindet neu, Shift+F1 startet einen Host.", "Lost connection to the host - Shift+F2 reconnects, Shift+F1 starts a host."), zCOLOR(255, 200, 80, 255));
                OthelloCompatLog("[%lld s, %s] Netz: Verbindung zum Host verloren (%s)", DiagSeconds(), DiagRole(), player ? "im Spiel" : "im Hauptmenue");   // v71
            }
            else if (st == 3 || st == 5) {
                CoopClientEnded();
                if (st == 3 && !CoopPendingRole)
                    ChatLog(CoopTr("Nicht verbunden - Shift+F2 versucht es erneut, Shift+F1 startet einen Host.", "Not connected - Shift+F2 tries again, Shift+F1 starts a host."), zCOLOR(255, 200, 80, 255));
            }
        }
        if (ServerThread && CoopServerState == 5) {
            CoopServerEnded();
            if (!CoopPendingRole)
                ChatLog(CoopTr("Host beendet.", "Host stopped."));
        }
        if (CoopPendingRole && !ClientThread && !ServerThread) {
            const int r = CoopPendingRole;
            CoopPendingRole = 0;
            if (r == 1)
                CoopStartServer();
            else
                CoopStartClient();
        }
    }

    static void CoopKeyHost() {
        if (ServerThread) {
            ChatLog(CoopTr("Host l" "\xE4" "uft schon.", "Host already running."));
            return;
        }
        if (ClientThread) {   // z. B. aus Versehen Shift+F2: Client beenden, dann Host
            CoopPendingRole = 1;
            CoopClientStop = 1;
            ChatLog(CoopTr("Wechsel zum Host - die Client-Verbindung wird beendet.", "Switching to host - closing the client connection."));
            return;
        }
        CoopStartServer();
    }

    static void CoopKeyClient() {
        if (ServerThread) {
            if (!PlayerNpcs.empty() || CoopSaveSyncPeers() > 0) {
                ChatLog(CoopTr("Als Host sind Spieler verbunden - Wechsel zum Client nicht m" "\xF6" "glich.", "Players are connected to your host - cannot switch to client."), zCOLOR(255, 200, 80, 255));
                return;
            }
            CoopPendingRole = 2;
            CoopServerStop = 1;
            ChatLog(CoopTr("Wechsel zum Client - der Host wird beendet.", "Switching to client - stopping the host."));
            return;
        }
        if (ClientThread) {
            if (CoopClientState <= 1) {
                ChatLog(CoopTr("Verbindung wird noch aufgebaut ...", "Still connecting ..."));
                return;
            }
            if (CoopClientState != 2)
                return;   // getrennt/fehlgeschlagen: wird im naechsten Durchlauf aufgeraeumt, dann erneut Shift+F2
            if (CoopSaveSyncPauseKey())   // v76: Pause erst nach der gemeinsamen Sicherung, Fortsetzen mit Uebernahme (CoopSaveSync.cpp)
                return;
            if (IsCoopPaused) {
                ChatLog(CoopTr("Weltabgleich l\xE4" "uft wieder.", "Restoring world synchronization."));
            }
            else {
                ChatLog(CoopTr("Weltabgleich angehalten.", "Stop world synchronization."));
            }

            IsCoopPaused = !IsCoopPaused;
            rtnMan->RestartRoutines();
            if (!IsCoopPaused)
                CoopResyncResumed();   // v39: wie beim Verbinden alles neu abgleichen
            return;
        }
        if (CoopSteamReconnect())   // v87: letzte Verbindung lief ueber Steam - wieder dorthin
            return;
        CoopStartClient();
    }

    void Game_Loop() {
        PluginState = "GameLoop";
        if (IsLoadingLevel) {
            return;
        }

        CurrentMs = GetCurrentMs();
        GameChat->Render();
        GameStatsLoop();
        PacketProcessorLoop();
        CoopSlotGuardPulse();     // u88 (P112): geloeschte Gegenstaende in NPC-Slots austragen, bevor die Engine sie anfasst (Helpers.cpp)
        CoopNpcLagePulse();       // u164 (P171): NPCs mit ungueltiger Lage (NaN) an ihren Ort setzen (Helpers.cpp)
        DamageProcessorLoop();
        SpellCastProcessorLoop();
        ReviveFriendLoop();
        CoopDiagPulse();
        CoopDiagClientPulse();
        CoopDialogWatchPulse();   // 18.10.2026: haengende Dialoge (verlorenes EV_PROCESSINFOS) wieder anstossen
        CoopWorldSyncPulse();     // v13: Weltbestand anfragen (Client) / senden (Host)
        CoopDialogSyncPulse();    // v26: eigener Dialog melden, NPCs in fremden Dialogen angehalten lassen
        CoopLogShipPulse();       // v34/v35: Coop-Log zum Partner (Client -> Host und Host -> Client)
        CoopSelfTestPulse();      // v37: Coop-Testlauf (Shift+F11)
        CoopAutoTestPulse();      // u49: automatischer Testlauf (-cooptest:host/client)
        CoopEnsureHookOrder();
        {   // u170 (P177): LeGo-Haken vor GT - kopierten GT-Sprung versetzen (CoopAudit.cpp)
            static long long nextLego = 0;
            if (CurrentMs >= nextLego) {
                nextLego = CurrentMs + 1000;
                CoopLegoFixPulse();
                CoopScriptMapPulse();   // u195 (P199): Skript-Funktionen fuer die Skript-Spur im Absturzprotokoll (Hooks.cpp)
            }
        }
        CoopAuditOnce();     // Pruefebene 1: einmal je Start, nach dem CanUse-Vorbau
        CoopTracePulse();    // Pruefebenen 2/3: Schnappschuesse, F7-Testschritte

        if (CurrentMs > LastNpcListRefreshTime + 1000) {
            BuildGlobalNpcList();
            LastNpcListRefreshTime = CurrentMs;
            PluginState = "GameLoop";
        }

        if (CurrentMs > LastUpdateListOfVisibleNpcs + 500) {
            UpdateVisibleNpc();
            LastUpdateListOfVisibleNpcs = CurrentMs;
            PluginState = "GameLoop";
        }

        PluginState = "Worlds";
        CoopWorldsPulse();    // u29: getrennte Welten - Meldungen, wer wo ist
        CoopWorldChangePulse();   // u32: gemeinsamer Weltwechsel - Abfrage beim Ausloeser, Nachholen beim Partner
        PluginState = "WorldProcess";
        CoopWpHostPulse();    // u33: Weltprozess (Host) - Auftrag, Meldungen, Uhrzeit, Mitspieler verfolgen
        PluginState = "FarSync";
        CoopFarSyncPulse();   // v41: Todesabgleich ausserhalb der Reichweite, Bericht zum Verfolgungspunkt
        PluginState = "Teleport";
        CoopTeleportPulse();  // v102: Teleport-Rune (Ziel Mitspieler, Startausstattung)
        PluginState = "Truhe";
        CoopTruhePulse();     // u97: Coop-Truhe (Benutzen -> Fenster, Schliessen, Gegenstand im Inventar)
        PluginState = "PartnerMarker";
        CoopPartnerMarkerPulse();   // v104: Name ueber dem Kopf / Pfeil am Bildrand / Marke auf Othellos Karte
        PluginState = "Camera";
        CoopCamPulse();       // v48: Zuschau-Fenster (Kamera je Bild, Automatik ausserhalb des Radius)
        PluginState = "Look";
        CoopLookPulse();      // v55: Name/Aussehen aus dem COOP-Menue uebernehmen
        if (CoopLookTakeChanged() && Myself)
            Myself->ResendInit();   // Partner: Name und Aussehen der Figur neu (RemoteNpc::UpdateInitialization)
        PluginState = "GameLoop";

        if (!IsCoopPaused) {
            PluginState = "PulseMyself";
            if (Myself) {
                Myself->Pulse();
                Myself->PackUpdate();
            }

            PluginState = "PulseBroadcastNpcs";
            for (auto p : BroadcastNpcs) {
                p.second->Pulse();
                p.second->PackUpdate();
            }
            PluginState = "WorldProcessMirror";
            CoopWpMirrorSendPulse();   // u46: Client ohne Host in seiner Welt - NPCs um ihn fuer den Weltprozess des Hosts

            PluginState = "UpdateSyncNpcs";
            // Zwei Korrekturen gegenueber dem Original:
            //  1. SyncNpcs[...] legt bei unbekanntem Schluessel einen Eintrag mit NULL an
            //     (Hooks.cpp, RemoteNpc.cpp, SyncHelpers.cpp lesen so). Unter Othello heissen
            //     die NPCs anders als in Gothic, es entstehen also laufend NULL-Eintraege.
            //     npc->Update() darauf war der haeufigste Absturz, gemessen 29 von 30.
            //  2. erase() mitten in der range-for macht den Iterator ungueltig. Erst sammeln,
            //     dann loeschen - genau so macht es auch die ausgelieferte 2.0.0.
            std::vector<string> npcsToErase;
            for (auto const& pair : SyncNpcs) {
                auto npc = pair.second;

                if (npc == NULL) {
                    npcsToErase.push_back(pair.first);
                    continue;
                }

                npc->Update();

                if (npc->destroyed) {
                    npcsToErase.push_back(pair.first);
                }
            }
            for (auto const& key : npcsToErase) {
                SyncNpcs.erase(key);
            }

            PluginState = "DisplayPing";
            if ((ServerThread || ClientThread) && !CoopRecordMode()) {   // v58: Fassung oben links, solange Coop laeuft (vorher nur "Ping:" beim Client); u171: nicht in Aufnahmen
                auto font = screen->GetFontName();
                auto color = screen->fontColor;

                std::string line = CoopVersionName();
                // v88: Verbindungsweg dazu (Test v87: "Oben stand immer noch etwas mit Port, sollte da nicht Steam stehen?")
                if (ServerThread && CoopSteamAvailable())
                    line += "  -  Host (Steam + IP)";
                else if (ClientThread)
                    line += CoopSteamClientHostId() ? CoopTr("  -  \xFC" "ber Steam", "  -  via Steam") : CoopTr("  -  \xFC" "ber IP", "  -  via IP");
                if (ClientThread && CurrentPing > 0)
                    line = "Ping: " + std::to_string(CurrentPing) + "    " + line;
                screen->SetFont(zSTRING("Font_Old_10_White_Hi.TGA"));
                screen->SetFontColor(ClientThread && CurrentPing > 100 ? GFX_RED : GFX_WHITE);
                screen->Print(50, 0, zSTRING(line.c_str()));

                screen->SetFont(font);
                screen->SetColor(color);
            }
        }

        PluginState = "Tempo";
        CoopTempoPulse();  // u181: gemeinsames Spieltempo der Testinstanzen (CoopTempo.cpp) - Abgleich, Zeitfaktor, Anzeige oben rechts

        PluginState = "CombatLead";
        CoopLeadPulse();  // v72: Kampf-Uebergabe - Host gibt NPCs ab, Client sendet/prueft die selbst gefuehrten

        PluginState = "Steam";
        CoopSteamPulse();   // v87: Steam-Rueckrufe, Tunnel zum Host-/Client-Zustand, Rich Presence, Beitreten aus Steam

        PluginState = "NetPulse";
        CoopNetPulse();   // v39: beendete Netz-Faeden aufraeumen, angeforderten Rollenwechsel starten

        PluginState = "KeysPressedChecks";
        if (!IsPlayerTalkingWithAnybody() && !WorldEditMode) {
            const bool shift = CoopShiftDown();   // v39: Coop-Tasten nur noch mit Shift
            if (shift && zinput->KeyToggled(StartServerKey)) {
                CoopKeyHost();
            }

            if (shift && zinput->KeyToggled(StartConnectionKey)) {
                CoopKeyClient();
            }

            if (CoopCamKeyHit(shift)) {
                CoopCamToggle();   // v48: Zuschau-Fenster an / naechster Mitspieler / aus; v47: einmal je Druck
            }

            CoopTruheKeyPulse(shift);   // u101: Taste fuers Coop-Inventar (COOP-Einstellungen, Vorgabe I) - oeffnen bzw. schliessen

            if (shift && zinput->KeyToggled(KEY_F12)) {
                CoopWpHostToggle();   // u33: Weltprozess starten/beenden (CoopWorldProcess.cpp)
            }

            // v51 (O1): nicht im Test-Modus - dort ist Shift+F3 Othellos Noclip (Helpers.cpp)
            if (shift && zinput->KeyToggled(ReinitPlayersKey) && CoopReinitKeyAllowed(ReinitPlayersKey)) {
                ChatLog("Respawning all coop friend NPCs.");

                std::map<oCNpc*, string> PlayerNpcsCopy = PlayerNpcs;
                for (auto playerNpcToName : PlayerNpcsCopy) {
                    auto name = playerNpcToName.second;
                    if (SyncNpcs.count(name)) {
                        SyncNpcs[name]->ReinitCoopFriendNpc();
                    }
                }
            }
        }

        if (WorldEditMode) {
            if (zinput->KeyToggled(StartServerKey)) {
                if (player->GetObjectName() == "PC_HERO") {
                    return;
                }

                auto currentNpc = player;
                Myself->npc->SetAsPlayer();

                ogame->spawnman->SpawnNpc(currentNpc, currentNpc->GetPositionWorld(), 0.f);
                ChatLog(string::Combine("%s was added to the world!", string(currentNpc->GetObjectName())));
            }

            if (zinput->KeyToggled(RevivePlayerKey)) {
                if (player->GetObjectName() == "PC_HERO") {
                    return;
                }

                auto currentNpc = player;
                Myself->npc->SetAsPlayer();

                CoopDeleteNpc(ogame->spawnman, currentNpc);
                ogame->GetGameWorld()->RemoveVob(currentNpc);

                ChatLog(string::Combine("%s was removed from the world!", string(currentNpc->GetObjectName())));
            }

            if (zinput->KeyToggled(ToggleGameLogKey)) {
                if (player->GetObjectName() == "PC_HERO") {
                    return;
                }

                Myself->npc->SetAsPlayer();
            }
        }

        if ((ClientThread || ServerThread) && !Myself) {
            PluginState = "Myself_Init";
            Myself = new LocalNpc(player, MyselfId);
        }

        // v82: "Hauptmenue" gewaehlt - nach dem Trennen das Startmenue (laedt ggf. ein Spiel; danach in diesem Frame nichts mehr)
        PluginState = "Title";
        if (CoopTitlePulse())
            return;

        // v17: zuletzt - kann einen Ladevorgang ausloesen (danach laeuft in diesem Frame nichts mehr).
        PluginState = "SaveSync";
        CoopSaveSyncPulse();

        PluginState = "GameLoop_End";
    }

    void CoopRefloorAfterLoad(const char* why);   // u50 (P94): OthelloCompat.cpp
    void CoopDiffHpSaveBegin();   // v70: CoopDifficulty.cpp - skalierte Lebenspunkte nicht in den Spielstand
    void CoopDiffHpSaveEnd();
    void CoopDiffHpWorldGone();

    void Game_SaveBegin() {
        CoopCamSuspendForSave();   // v44 (Vollbild-Kamera, Sperr-Bit +0x79C); v48: tut nichts mehr
        IsSavingGame = true;
        CoopDiffHpSaveBegin();     // v70: NPCs mit skalierten HP vor dem Speichern auf den Grundwert
    }

    void Game_SaveEnd() {
        CoopDiffHpSaveEnd();       // v70: und wieder zurueck

        // u50 (P94): beim Levelwechsel speichert Gothic erst die alte Welt (Game_SaveBegin/End zwischen LoadBegin und LoadEnd) - die
        // Figuren nicht mehr in diese Welt einsetzen, sie wird gleich verworfen (Lauf 3: "Spawn HOST" mitten im Weltwechsel, ohne
        // eigenen Helden, kurz danach der Absturz). Nach dem Laden setzt RemoteNpc sie ohnehin neu ein.
        if (!IsLoadingLevel) {
            for (auto playerNpcToName : PlayerNpcs) {
                auto name = playerNpcToName.second;
                if (SyncNpcs.count(name)) {
                    SyncNpcs[name]->InitCoopFriendNpc();
                }
            }
        }

        IsSavingGame = false;
        CoopSaveSyncOnSaveEnd();   // v17: im naechsten Frame archivieren und den Partner mitspeichern lassen
        CoopTeleportSaveEnd();     // u7: Rune-Aussehen nach dem Speichern neu setzen (zUnionUtils raeumt das Inventar um)
        CoopTruheSaveEnd();        // u97: Inhalt der Coop-Truhe in den Slot (COOPTRUHE.TXT)
    }

    void LoadBegin() {
        CoopCamStop("Laden");   // v44/v48: noch vor IsLoadingLevel - Zuschau-Fenster aus, Automatik neu
        CoopTruheLoadBegin();   // u97: offene Coop-Truhe schliessen (Inhalt an den Host)
        CoopDiffHpWorldGone();  // v70: gemerkte NPC-Zeiger der alten Welt verwerfen
        CoopLeadClear("Laden"); // v72: Kampf-Uebergaben der alten Welt vergessen
        // v98 (A16): alles mit Zeigern in die alte Welt verwerfen - nach dem Laden gilt nur der Spielstand (Nutzer: "beim Laden sollte
        // genau der Zustand des Spiels uebergeben werden, das heisst unsere Coop sollte auch auf dem Stand sein")
        CoopDamageWorldGone();       // Treffer des letzten Bilds (CoopDamage.cpp)
        CoopHitWorldGone();          // Bestrafungs-Merker, Schlag-Erlaubnisse/-Ergebnisse (CoopHitAuthority.cpp)
        CoopFigureHitsWorldGone();   // C20-Merker (Hooks.cpp)
        CoopPartnerMarkerWorldGone(); // v104: Sicht-Merker je Figur (CoopPartnerMarker.cpp)
        CoopNpcLageWorldGone();      // u164 (P171): Versuche des Lage-Schutzes je NPC (Helpers.cpp)
        CoopSaveSyncStandHeroForget(); // u168 (P175): Lage des Helden des Stands gilt bis zum naechsten Laden (CoopSaveSync.cpp)
        CoopMsgItemsWorldGone();       // u169 (P176): gemerkte Gegenstaende laufender Nachrichten (Helpers.cpp)
        while (!ReadyToSyncDamages.isEmpty())
            ReadyToSyncDamages.dequeue();
        while (!ReadyToSyncSpellCasts.isEmpty())
            ReadyToSyncSpellCasts.dequeue();
        ReviveState = "READY";       // Wiederbeleben (ReviveFriendLoop.cpp) zeigte sonst auf die Figur der alten Welt
        ReviveNpc = NULL;
        ReviveStartTime = 0;
        IsLoadingLevel = true;
        CoopWorldsLoadBegin();   // u29: eigener Weltschluessel nach dem Laden neu
        CoopWorldChangeLoadBegin();   // u32: offene Weltwechsel-Abfrage verwerfen
        Myself = NULL;
    }

    void LoadEnd() {
        CoopLegoFixPulse();   // u170 (P177): die Skripte des Mods haben beim Laden eingehakt - vor dem ersten Spielbild versetzen
        if (ServerThread || ClientThread) {
            Myself = new LocalNpc(player, MyselfId);
        }

        std::map<string, RemoteNpc*> syncPlayerNpcs;
        for (auto playerNpcToName : PlayerNpcs) {
            auto name = playerNpcToName.second;
            if (SyncNpcs.count(name)) {
                syncPlayerNpcs[name] = SyncNpcs[name];
            }
        }

        SyncNpcs.clear();
        for (auto syncPlayerNpc : syncPlayerNpcs) {
            SyncNpcs[syncPlayerNpc.first] = syncPlayerNpc.second;
        }

        BroadcastNpcs.clear();
        UniqueNameToNpcList.clear();
        NpcToUniqueNameList.clear();
        NamesCounter.clear();
        NpcToFirstRoutineWp.clear();
        GameChat->Clear();
        LastNpcListRefreshTime = 0;
        LastUpdateListOfVisibleNpcs = 0;
        KilledByPlayerNpcNames.clear();
        CoopWorldSyncWorldLoaded();   // v13: Sperren/Merker der alten Welt verwerfen, neu abgleichen
        CoopSaveSyncWorldLoaded();    // v19: Zeitpunkt fuer das Wiederherstellen des eigenen Helden
        CoopDialogSyncWorldLoaded();  // v26: Dialog-Sperren der alten Welt verwerfen
        CoopFarSyncWorldLoaded();     // v41: Todesliste/Vergleichsstand der alten Welt verwerfen
        CoopTeleportLoadEnd();        // v102: Teleport-Rune - nach dem Laden pruefen, ob sie im Inventar ist
        CoopTruheLoadEnd(false);      // u97: Coop-Truhe - Gegenstand pruefen (Inhalt nur beim Laden eines Spielstands, unten)

        auto totWp = ogame->GetWorld()->wayNet->GetWaypoint("TOT");
        if (totWp) {
            CurrentWorldTOTPosition = &totWp->GetPositionWorld();
        }
        else {
            CurrentWorldTOTPosition = NULL;
        }

        IsLoadingLevel = false;
        CoopRemoveStrayHeroes("geladen");   // u39 (P81): Held aus der getauschten Weltdatei eines Mitspielers (CoopPlace.cpp)
        CoopHeroSymbolFixNow();             // u195 (P201): PC_HERO/HERO gleich auf den eigenen Helden (CoopDialogSync.cpp)
        CoopRefloorAfterLoad("geladen");    // u50 (P94): Kollisionsstand der alten Welt verwerfen (OthelloCompat.cpp)
        CoopWorldsLoadEnd();     // u29: Schluessel der neuen Welt (Log)
        CoopTeleportAcrossLoadEnd();   // u48 (P90): Teleport ueber Welten - gleich an die letzte Lage des Mitspielers
        CoopLookApplyOwn("geladen");   // v55: gewaehltes Aussehen nach jedem Laden (sonst gilt das aus dem Spielstand)
        CoopLobbyAfterLoad();   // v40: Wartephase aus dem Hauptmenue beenden (Aussehen, keine Host-Uebernahme nach dem Verbinden)
    }

    void Game_LoadEnd_SaveGame() {
        if (CoopWpIsWorld()) {   // u33: Weltprozess - eigenes LoadEnd, kein Coop-Laden (CoopWorldProcess.cpp)
            CoopWpWorldLoadEnd(true);
            return;
        }
        LoadEnd();
        CoopWorldSyncSaveLoaded();       // u137: wartende Mechanismen anderer Welten verwerfen
        CoopSaveSyncEntryVarsAtLoad();   // u140: Eintritts-Merker der fremden Weltdateien dieses Slots

        auto coopFriendInstanceId = GetFriendDefaultInstanceId();
        auto* list = CoopWorldNpcListFirst(ogame->GetGameWorld());

        while (list) {
            auto npc = list->data;
            auto next = list->next;   // u48: Loeschen nimmt den Listeneintrag mit - erst den naechsten merken
            if (npc && npc->GetInstance() == coopFriendInstanceId && npc->GetAttribute(NPC_ATR_STRENGTH) == COOP_MAGIC_NUMBER) {
                CoopDeleteNpc(ogame->spawnman, npc);
            }
            list = next;
        }

        CoopSaveSyncApplyHeroAtLoad();   // v24: eigener Held + Lage noch im Ladevorgang (kein sichtbarer Sprung)
        CoopHeroSymbolFixNow();          // u195 (P201): nach dem Einsetzen des eigenen Helden
        CoopTruheLoadEnd(true);          // u97: Inhalt der Coop-Truhe aus dem Slot (Client: bis der Host-Stand kommt)
    }

    void Game_LoadBegin_Trigger() {
        return;
    }
}
