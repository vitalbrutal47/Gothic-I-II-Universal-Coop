// Supported with union (c) 2020 Union team
// Union SOURCE file

namespace GOTHIC_ENGINE {

    // --- Kern: Fassung, Sprache, Spielordner, Profil, Log-Archiv, Protokoll (u1) ------------------------------------------
    //
    // Bis Othello v106 lag das alles in OthelloCompat.cpp, das Protokoll nur im G1-Zweig - der G2A-Build fand darum
    // OthelloCompatLog/DiagSeconds nicht (Plan Phase 1, Schritt 1). Hier steht nur engine-neutraler Code (Windows-Aufrufe,
    // keine Engine-Stelle); Othello-Eigenes bleibt in OthelloCompat.cpp.

#define COOP_FASSUNG "u203-fun7"   // 11.11.2026: Fun-Modus (fun7: Absturz beim Start behoben (Zielerfassung); fun6: Rechtsklick zielt, Linksklick schiesst, kein Auto-Erfassen, Lauftasten beim Zielen; fun5: Oe blendet Namen aus, Ziel erfassen bis zur Schussweite, Bewegen beim Zielen; fun4: freies Zielen 150 m+, Startwerte nach dem Tod, Lager ohne Monster, eigene Gilde greift nicht an, Leben lernen; fun3: Bogen/Armbrust anlegen, Monster verteilt, Bosse schwaecher; fun2: Wiederbeleben im Lager nach 30 s) (COOP > Fun-Modus, COOP_FUN.D); Bogen/Armbrust des Helden wieder (Schuss-Haken); Bogen/Armbrust des Helden wieder (Schuss-Haken); 08.11.: 3-4 Spieler (Geister-Verfolgungspunkt, Lobby-Anzeige, Hinweis anderer Spielstand); 07.11.: PvP (Fork vitalbrutal47)

    // Auswahl je Engine, z. B. Adressen: COOP_ENGINE_SWITCH(G1, G1A, G2, G2A). ENGINE wird erst an der Stelle des Gebrauchs
    // eingesetzt - in Mehr-Engine-Builds (MP x2/x4) bindet Interface.cpp Sources.h je Engine neu ein.
#ifndef COOP_ENGINE_SWITCH
#define COOP_ENGINE_SWITCH(g1, g1a, g2, g2a) \
    (ENGINE == Engine_G1 ? (g1) : ENGINE == Engine_G1A ? (g1a) : ENGINE == Engine_G2 ? (g2) : (g2a))
#endif

    // --- Log-Archiv (v35) ------------------------------------------------------------------------
    //
    // Nutzer: "keine Logs loeschen, sondern immer archivieren". Vor dem ersten Log-Schreiben dieses Starts verschiebt GT alle
    // system\GothicCoop*.log der vorigen Sitzung nach CoopLogs\<Fassung>\<Start der Sitzung>\ (Spielordner, auf jedem PC).
    // Fassung und Start stehen ab v35 in der ersten Zeile des Hauptprotokolls ("GothicCoop Othello-Fassung v35, Start
    // ..."); aeltere Logs ohne diese Zeile kommen nach CoopLogs\vor-v35\<letzte Aenderung>\. Geloescht wird nichts. Laesst sich eine Datei nicht verschieben (z. B. von einem Editor gesperrt), bleibt sie liegen und
    // wird weiter angehaengt; fuer das Hauptprotokoll merkt GT sich dann die alte Groesse, damit der Log-Versand erst dahinter
    // beginnt. Jeder Log-Schreiber ruft CoopLogArchiveOnce() vor seinem ersten fopen. Danach steht die Fassung im neuen Log.
    // Nur Windows-Aufrufe, keine Engine-Stelle.

    // --- v95: Sprache der Coop-Anzeigen ----------------------------------------------------------
    // Nutzer: "dass man die Sprache der Coop-Einstellungen und Anzeigen auf Englisch stellen kann". Gothic.ini [GOTHICCOOP]
    // coopLang (0 Deutsch, 1 English; Auswahlfeld in "Deine Figur" und Einstellungen > COOP), gelesen von CoopLangRefresh
    // (CoopLook.cpp). Jeder Text fuer den Spieler geht ueber CoopTr(deutsch, english); Menue-Texte aus COOP_MENU.D tauscht
    // CoopLangMenuPulse (CoopMenuLobby.cpp). Logs bleiben deutsch.
    static int CoopLangEn = 0;

    // char* statt const char*: Unions string::Combine nimmt als Format nur "const text" (= char* const, Types.h) - die Texte
    // werden nie veraendert
    static inline char* CoopTr(const char* de, const char* en) {
        return const_cast<char*>(CoopLangEn ? en : de);
    }

    // --- v58: Anzeige der Fassung --------------------------------------------------------------
    //
    // Nutzer: "ueberall mal die Version der Coop-Mod anzeigen, im Spiel und auch im Hauptmenue, statt der alten Coop-Version",
    // "vielleicht noch mit Datum/Uhrzeit-Stempel der Version im Hauptmenue". GTs COOP_VERSION (60) bleibt nur Protokollnummer
    // (Pruefung beim Verbinden) und wird nicht mehr angezeigt. Bauzeit = __DATE__/__TIME__ dieser Uebersetzungseinheit
    // (Interface.cpp bindet ueber Sources.h alle Quellen ein - jeder Build uebersetzt sie neu).
    static std::string CoopVersionName() {
        return std::string("GothicCoop ") + COOP_FASSUNG;
    }

    static std::string CoopBuildStamp() {   // "Oct 20 2026" + "15:42:07" -> "20.10.2026, 15:42 Uhr"
        static const char months[] = "JanFebMarAprMayJunJulAugSepOctNovDec";
        const char* d = __DATE__;
        const char* hit = strstr(months, std::string(d, 3).c_str());
        const int month = hit ? (int)(hit - months) / 3 + 1 : 0;
        char b[48];
        _snprintf(b, sizeof(b), CoopLangEn ? "%02d.%02d.%.4s, %.5s" : "%02d.%02d.%.4s, %.5s Uhr", atoi(d + 4), month, d + 7, __TIME__);
        b[sizeof(b) - 1] = 0;
        return b;
    }

    void CoopCamNpcGone(oCNpc* npc);   // v44: CoopCamera.cpp - Kamera vor dem Loeschen einer Figur zurueck zum Helden

    static long CoopLogSessionStart = 0;   // ab hier gehoert das Hauptprotokoll zu diesem Start

    // v98 (A15): Archiv und Haupt-Log mit festen Pfaden. Test v97: auf beiden PCs seit v81 kein Archiv mehr, die Logs wuchsen ueber
    // alle Starts (letzte Kopfzeile v79). Ursache: seit v81 schreibt Game_Entry (CoopMenuInjectInstall) die erste Logzeile, solange
    // der Arbeitsordner noch system\ ist (dort liegt auch GothicCoopConfig.json) - erst danach wechselt Gothic in den Spielordner.
    // "system\GothicCoop*.log" zeigte dann auf system\system\: nichts gefunden, Kopfzeile ins Leere, das Archiv galt fuer diesen
    // Start als erledigt. Jetzt: Spielordner = Ordner ueber dem Ordner der Exe (system\), unabhaengig vom Arbeitsordner.
    static const std::string& CoopGameRoot() {
        static const std::string root = [] {
            char p[MAX_PATH] = "";
            GetModuleFileNameA(NULL, p, MAX_PATH);
            std::string s = p;
            const size_t a = s.find_last_of("\\/");
            if (a != std::string::npos)
                s.resize(a);   // ...\system
            const size_t b = s.find_last_of("\\/");
            if (b != std::string::npos && _stricmp(s.c_str() + b + 1, "system") == 0)
                s.resize(b);   // Spielordner
            else {             // ungewoehnlicher Aufbau: wie bisher relativ zum Arbeitsordner
                char c[MAX_PATH] = "";
                GetCurrentDirectoryA(MAX_PATH, c);
                s = c;
            }
            return s;
        }();
        return root;
    }

    // u33 (P75): Weltprozess - zweites Gothic beim Host, das die Welt eines Mitspielers laedt (CoopWorldProcess.cpp). Erkannt an
    // "-coopwelt:<PID des Hosts>:<Fenster>" in der Kommandozeile (setzt nur GT beim Start). Er schreibt ein eigenes Log und
    // archiviert nichts - die Logs des Hauptspiels laufen weiter. Nur Windows-Aufrufe.
    static bool CoopWpIsWorld() {
        static const int on = strstr(GetCommandLineA(), "-coopwelt:") ? 1 : 0;
        return on == 1;
    }

    static std::string CoopSystemFile(const char* name) {
        return CoopGameRoot() + "\\system\\" + name;
    }

    static std::string CoopSystemFile(const std::string& name) {
        return CoopSystemFile(name.c_str());
    }

    // Modul + Abstand einer Adresse fuers Log ("GothicMod.exe+CE720"). Bis u7 in CoopWorldSync.cpp - u8: hier, weil auch
    // CoopMenuInject.cpp es braucht, wenn das Welt-Modul in einer Engine (G2A) noch nicht freigegeben ist. Nur Windows-Aufrufe.
    static void CoopModuleOf(const void* addr, char* out, size_t n) {
        HMODULE mod = NULL;
        out[0] = 0;
        if (GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, (LPCSTR)addr, &mod) && mod) {
            char path[MAX_PATH];
            if (GetModuleFileNameA(mod, path, MAX_PATH)) {
                const char* base = strrchr(path, '\\');
                _snprintf(out, n, "%s+%X", base ? base + 1 : path, (unsigned)((const char*)addr - (const char*)mod));
                out[n - 1] = 0;
                return;
            }
        }
        _snprintf(out, n, "%p", addr);
        out[n - 1] = 0;
    }

    // Anfang des Speicherbereichs (Modul) einer Adresse. u20: bis u19 in OthelloHookOrder.cpp (nur Othello) - die Selbstpruefung
    // braucht ihn in allen Engines. Nur Windows-Aufrufe.
    static const void* ModuleOf(const void* p) {
        MEMORY_BASIC_INFORMATION mbi;
        if (VirtualQuery(p, &mbi, sizeof(mbi)) != sizeof(mbi))
            return NULL;
        return mbi.AllocationBase;
    }

    // Nur der Dateiname des Moduls einer Adresse ("Gothic2.exe"). u13: bis u12 in OthelloHookOrder.cpp (nur Othello) - der
    // Dialog-Waechter und die Selbstpruefung brauchen sie in allen Engines. Nur Windows-Aufrufe.
    static void ModuleName(const void* p, char* out, size_t len) {
        out[0] = 0;
        HMODULE m = NULL;
        if (GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                (LPCSTR)p, &m) && m) {
            char path[MAX_PATH];
            if (GetModuleFileNameA(m, path, MAX_PATH)) {
                const char* s = strrchr(path, '\\');
                strncpy(out, s ? s + 1 : path, len - 1);
                out[len - 1] = 0;
                return;
            }
        }
        strncpy(out, "kein Modul", len - 1);
        out[len - 1] = 0;
    }

    // u11: bis u10 in CoopWorldSync.cpp - das Dialog-Modul braucht den Weltnamen auch, wenn das Welt-Modul (G2A) noch aus ist
    static std::string CoopWorldName() {
        oCWorld* w = ogame ? ogame->GetGameWorld() : NULL;
        if (!w)
            return std::string();
        zSTRING name = w->GetWorldFilename();
        name.Upper();
        return std::string(name.ToChar());
    }

    // v20: Enter kam per KeyToggled nie an (Test 18.10.: "kann nicht mit Enter geladen werden") - das
    // Gedrueckt-Ereignis verbraucht vorher die Engine bzw. ein Plugin, die F-Tasten dagegen kommen an.
    // Darum die Flanke selbst aus dem Tastenzustand bilden (zinput->KeyPressed, dazu GetAsyncKeyState,
    // nur wenn das Spielfenster vorn ist). u11: bis u10 in CoopSaveSync.cpp (Dialog-Modul ohne Speichern-Modul, G2A).
    static bool CoopKeyEdge(int zkey, int vk, bool& was) {
        bool down = zinput->KeyPressed(zkey) != 0;
        if (!down && vk) {
            HWND fg = GetForegroundWindow();
            DWORD pid = 0;
            if (fg)
                GetWindowThreadProcessId(fg, &pid);
            if (pid == GetCurrentProcessId() && (GetAsyncKeyState(vk) & 0x8000))
                down = true;
        }
        const bool edge = down && !was;
        was = down;
        return edge;
    }

    // Engine-Bytes vergleichen (bis u2 in OthelloCompat.cpp, nur G1)
    static bool EngineBytesEqual(size_t addr, const unsigned char* expect, size_t len) {
        if (!IsReadableMemory((const void*)addr, len))
            return false;
        return memcmp((const void*)addr, expect, len) == 0;
    }

    // Original oder Detour (E9 rel32) eines anderen Plugins - beides heisst: die Funktion ist da.
    static bool EngineFunctionPresent(size_t addr, const unsigned char* head, size_t len) {
        if (EngineBytesEqual(addr, head, len))
            return true;
        return IsReadableMemory((const void*)addr, 5) && *(const unsigned char*)addr == 0xE9;
    }

    // u3 (Plan Phase 1, Schritt 4): Zahl der Skriptvariablen aivar[] je Engine - G1 50, G2/G2A 100 (SDK oCNpc::aiscriptvars).
    // Ersetzt die feste 50 in Schleifen, Grenzen und gespeicherten Feldern.
#define COOP_AIV_MAX ((int)(sizeof(((oCNpc*)0)->aiscriptvars) / sizeof(((oCNpc*)0)->aiscriptvars[0])))

    // --- u3: Freigabe je Modul und Engine (Plan Phase 1, Schritt 5) ----------------------------------------------------
    //
    // Bis u2 stand jedes Modul in "#if ENGINE == Engine_G1" mit Platzhaltern im #else. Ab u3 heisst die Bedingung
    // COOP_BUILD(<Modul>): der echte Code wird gebaut, wo das Modul freigegeben ist (COOP_READY_<Modul> = 1), sonst gelten die
    // Platzhalter wie bisher, und einmal je Start steht im Log, welche Module in dieser Engine nicht laufen
    // (CoopModulesReport). Freigeben = Wert hier aendern, nachdem das Modul fuer die Engine nach COOP-FIXES.md Abschnitt 2
    // geprueft und im Spiel getestet ist.
    // Pruefbau (tools\pruefbau.ps1, cl /DCOOP_PRUEFBAU): baut jedes Modul fuer jede Engine echt - so zeigt der Compiler jede
    // API-Abweichung einer Engine, bevor man ein Modul freigibt. Haken bleiben dort aus, wo das Modul nicht freigegeben ist
    // (COOP_IVK -> IVK_DISABLED: Unions CInvoke haengt nicht ein, ein Aufruf darueber geht ins Original). Ein Pruefbau wird nie
    // verteilt. (Ein erster Ansatz mit eigenem Namensraum je nicht freigegebenem Modul scheiterte an der argumentabhaengigen
    // Namenssuche: CoopLeadIsMine(npc) fand Platzhalter und echten Code zugleich.)
    // Stand u3: alle Module nur G1 (Othello und Vanilla-G1, gleiche Exe). Zusammengehoerig (gemeinsam freigeben): Kampf =
    // HooksExt + Damage + Hit + CombatLead + Difficulty; Menue = Lobby + MenuInject + Mouse + Look + Preview + Title + NewGame;
    // Speichern = Save + SavePreview.
#ifndef COOP_READY_G1_ONLY
#define COOP_READY_G1_ONLY   (ENGINE == Engine_G1)
    // u8 (Phase 3, Schritt 1): erste Freigaben fuer Gothic 2 NotR - Diagnose, Menue (ohne 3D-Vorschau, Esc-Hauptmenue, neues Spiel),
    // Steam. Geprueft: keine festen Abstaende/Adressen ausser CoopAddr.h (tools\feldliste.py), Pruefbau, Gothic2.exe (GetInput ohne
    // Mauscodes, SAVEGAME_LOAD-Vergleich in CGameManager::Menu 0x00429CCD, Menue-Lagen, Koepfe/Texturen). Spieltest steht aus.
#define COOP_READY_G1_G2A    (ENGINE == Engine_G1 || ENGINE == Engine_G2A)
#define COOP_READY_Audit       COOP_READY_G1_G2A    // CoopAudit.cpp      Selbstpruefung (Erwartungsliste Othello; u20: G2A mit CoopHookTable_G2A.h)
#define COOP_READY_Camera      COOP_READY_G1_G2A    // CoopCamera.cpp     Zuschau-Fenster (braucht Coop-GD3D11; u10: G2A mit g2a_avx2 coop6)
#define COOP_READY_CombatLead  COOP_READY_G1_G2A    // CoopCombatLead.cpp Kampf-Uebergabe an den Client (C18; u16: G2A)
#define COOP_READY_Damage      COOP_READY_G1_G2A    // CoopDamage.cpp     HP-Abzug messen/skalieren (C8, H16; u16: G2A)
#define COOP_READY_DiagClient  COOP_READY_G1_G2A    // CoopDiagClient.cpp Diagnose beim Client (u8: G2A)
#define COOP_READY_Dialog      COOP_READY_G1_G2A    // CoopDialogSync.cpp Dialoge, Story, Tagebuch (D; u11: G2A - B_GivePlayerXP, je-PC-Variablen)
#define COOP_READY_DialogWatch COOP_READY_G1_G2A    // CoopDialogWatch.cpp Dialog-Waechter (u13: G2A - ClearEM, EV_PROCESSINFOS gleich)
#define COOP_READY_Difficulty  COOP_READY_G1_G2A    // CoopDifficulty.cpp Schwierigkeitsgrad, Abgleich-Regeln (H16, H21; u16: G2A - XP_PER_VICTORY)
#define COOP_READY_FarSync     COOP_READY_G1_G2A    // CoopFarSync.cpp    Abgleich ausserhalb der Reichweite (I; u12: G2A - Spawn-Manager gleich)
#define COOP_READY_Hit         COOP_READY_G1_G2A    // CoopHitAuthority.cpp Treffer-Hoheit des Clients (C11; u16: G2A - CreateHit-Kopf)
#define COOP_READY_Look        COOP_READY_G1_G2A    // CoopLook.cpp       Aussehen, Name, Sprache (H8, H33; u8: G2A-Tabellen)
#define COOP_READY_MenuInject  COOP_READY_G1_G2A    // CoopMenuInject.cpp COOP-Eintraege im Hauptmenue (H25; u8: G2A)
#define COOP_READY_Lobby       COOP_READY_G1_G2A    // CoopMenuLobby.cpp  COOP-Menue, Verbinden, Liste (H5 ff.; u8: G2A)
#define COOP_READY_Mouse       COOP_READY_G1_G2A    // CoopMenuMouse.cpp  Maus in den Menues (H9; u8: G2A Rechtsklick/Rad)
#define COOP_READY_NewGame     COOP_READY_G1_G2A    // CoopNewGame.cpp    gemeinsames neues Spiel (H30; u10: G2A - Intro, Platz neben dem Host)
#define COOP_READY_Marker      COOP_READY_G1_G2A    // CoopPartnerMarker.cpp Mitspieler-Markierung (O; u18: G2A - Name/Randpfeil, Karte nur Othello)
#define COOP_READY_Preview     COOP_READY_G1_G2A    // CoopPreview.cpp    3D-Vorschau (braucht Coop-GD3D11; u10: G2A mit g2a_avx2 coop6)
#define COOP_READY_SavePreview COOP_READY_G1_G2A    // CoopSavePreview.cpp Vorschau der Spielstaende (H23; u15: G2A)
#define COOP_READY_Save        COOP_READY_G1_G2A    // CoopSaveSync.cpp   gemeinsames Speichern/Laden (F, S; u15: G2A - 20 Slots, Trefferchancen, Heldenwerte)
#define COOP_READY_SelfTest    COOP_READY_G1_G2A    // CoopSelfTest.cpp   Testlauf Shift+F11 (D12; u12: G2A - Schritte gesperrter Module "--")
#define COOP_READY_Steam       COOP_READY_G1_G2A    // CoopSteam.cpp      Coop ueber Steam (H28; u8: G2A, App 39510)
#define COOP_READY_Teleport    COOP_READY_G1_G2A    // CoopTeleport.cpp   Teleport-Rune (N1; u17: G2A - SPL_TELEPORTXARDAS, Wirken in Spell_Cast)
#define COOP_READY_Title       COOP_READY_G1_G2A    // CoopTitle.cpp      "Hauptmenue" im Esc-Menue (H26; u19: G2A, Esc-Eintraege auch ohne Mod)
#define COOP_READY_Trace       COOP_READY_G1_G2A    // CoopTrace.cpp      Schnappschuss, Zaehler (G; u8: G2A)
#define COOP_READY_World       COOP_READY_G1_G2A    // CoopWorldSync.cpp  Truhen, Gegenstaende, Leichen (E; u13: G2A - DisableVob +0x74, Teilmengen E6b)
#define COOP_READY_HooksExt    COOP_READY_G1_G2A    // Hooks.cpp          Kampf-Erweiterungen (C3, C10, C13, C20, C21), A17, A19 (u16: G2A)
#define COOP_READY_HookOrder   COOP_READY_G1_ONLY   // OthelloHookOrder.cpp Haken-Reihenfolge (B3, nur Othello)
#define COOP_IVK(mod)          ((COOP_READY_##mod) ? IVK_AUTO : IVK_DISABLED)
#ifdef COOP_PRUEFBAU
#define COOP_BUILD(mod)        1
#else
#define COOP_BUILD(mod)        (COOP_READY_##mod)
#endif
#endif

    // --- u1: Spiel und Mod-Profil (Plan Phase 1, Schritt 2) ------------------------------------------------------------
    //
    // Alles, was nur fuer ein Spiel oder eine Mod gilt, haengt kuenftig am Profil (docs\PLAN-ALLGEMEINES-COOP.md Abschnitt 3).
    // Erkannt wird beim ersten Zugriff - das kann schon die erste Logzeile in Game_Entry sein, darum nur Dateien und geladene
    // Module, keine Engine. Othello (nur Gothic 1): OTHELLO_ABI.DLL ist geladen oder eine der Skript-VDFs von Othello 4.x liegt
    // in Data\ (dieselben Dateien wie der Skriptstempel in CoopMenuLobby.cpp). Sonst das Spiel selbst (Vanilla).
    // u1 benutzt das Profil fuer Namen (Hauptprotokoll, Partner-Kopien, Kopfzeile). Die Othello-Sonderwege erkennen sich weiter
    // selbst an den Engine-Bytes ("sonst Original") und wandern schrittweise hinter CoopProfileIsOthello().
    // u187 (Fundament mit Mod-Varianten, docs\MODULE.md): COOP_PROFILE_LOA (Legend of Ahssun) und COOP_PROFILE_MOD (jede andere Mod, die
    // Gothic mit -game:<ini> startet - es laeuft das Fundament, das Log nennt die Mod). Bekannte Mods stehen in Mods\CoopModList.h.
    // u194 (P196): Daten eines Profils auch als Datei (system\GothicCoopMod-<Ini>.json bzw. system\GothicCoopMod.json,
    // Mods\CoopModProfile.h) - jede Mod bekommt so Werte je PC, Vorgaben und Hinweise ohne neuen Bau.
    enum CoopProfileId { COOP_PROFILE_VANILLA, COOP_PROFILE_OTHELLO, COOP_PROFILE_LOA, COOP_PROFILE_MOD };

    struct CoopProfileInfo {
        CoopProfileId id = COOP_PROFILE_VANILLA;
        std::string game;      // Spiel nach ENGINE
        std::string name;      // Profil fuer Anzeige und Log
        std::string tag;       // Kopfzeile des Hauptprotokolls "GothicCoop <tag>-Fassung ..." (Othello wie bis v106)
        std::string logBase;   // system\<logBase>.log, Partner-Kopien <logBase>Host.log / <logBase>Client.log
        std::string why;       // woran erkannt
        std::string modIni;    // u187: Spiel-Ini der Mod aus -game:<ini> (leer ohne Mod)
    };

    // u187: Spiel-Ini aus der Befehlszeile ("-game:LoA.ini", auch in Anfuehrungszeichen); leer ohne -game
    static std::string CoopProfileGameIni() {
        const char* c = GetCommandLineA();
        for (const char* p = c; p && *p; p++) {
            if ((p == c || p[-1] == ' ' || p[-1] == '"') && !_strnicmp(p, "-game:", 6)) {
                std::string ini;
                for (const char* q = p + 6; *q && *q != ' ' && *q != '"'; q++)
                    ini += *q;
                return ini;
            }
        }
        return std::string();
    }

#include "Mods\CoopModList.h"   // u187: bekannte Mods (Ini-Name -> Profil) - im Namensraum der Engine, ohne #pragma once (je Engine)

    static bool CoopProfileFileExists(const std::string& path) {
        const DWORD a = GetFileAttributesA(path.c_str());
        return a != INVALID_FILE_ATTRIBUTES && !(a & FILE_ATTRIBUTE_DIRECTORY);
    }

#include "Mods\CoopModProfile.h"   // u194 (P196): Mod-Profil als Datei (system\GothicCoopMod[-<Ini>].json) und eingebaute Profile

    static const CoopProfileInfo& CoopProfile() {
        static const CoopProfileInfo profile = [] {
            CoopProfileInfo p;
            p.game = COOP_ENGINE_SWITCH("Gothic 1", "Gothic Sequel", "Gothic 2", "Gothic 2 NotR");
            p.name = p.game;
            p.tag = COOP_ENGINE_SWITCH("Gothic1", "GothicSequel", "Gothic2", "Gothic2NotR");
            p.logBase = "GothicCoop";
            p.why = "keine Mod erkannt";
            if (ENGINE == Engine_G1) {
                const char* vdfs[] = { "\\Data\\ScriptsOthello4.0_de.vdf", "\\Data\\ScriptsOthello4.0.vdf" };
                std::string hit;
                if (GetModuleHandleW(L"OTHELLO_ABI.DLL"))
                    hit = "OTHELLO_ABI.DLL geladen";
                for (const char* v : vdfs)
                    if (hit.empty() && CoopProfileFileExists(CoopGameRoot() + v))
                        hit = std::string("Data") + (v + 5) + " vorhanden";
                if (!hit.empty()) {
                    p.id = COOP_PROFILE_OTHELLO;
                    p.name = "Othello";
                    p.tag = "Othello";
                    p.logBase = "GothicCoopOthello";
                    p.why = hit;
                }
            }
            // u187: jede andere Mod mit eigener Spiel-Ini (-game:<ini>, nicht Gothics eigene) - Name aus [INFO] Title der Ini, eigenes
            // Profil nur fuer bekannte Mods (Mods\CoopModList.h); Kopfzeile (tag) und Logname bleiben die des Spiels
            const std::string ini = CoopProfileGameIni();
            const CoopModKnown* known = NULL;
            std::string base;   // u194: Ini-Name ohne Endung - Name der Profil-Datei
            if (p.id == COOP_PROFILE_VANILLA && !ini.empty() && _stricmp(ini.c_str(), "Gothic.ini") && _stricmp(ini.c_str(), "GothicGame.ini")) {
                const size_t dot = ini.find_last_of('.');
                base = dot == std::string::npos ? ini : ini.substr(0, dot);
                char title[160] = {};
                GetPrivateProfileStringA("INFO", "Title", "", title, sizeof(title), (CoopGameRoot() + "\\system\\" + ini).c_str());
                known = CoopModFind(base);
                p.id = known ? known->id : COOP_PROFILE_MOD;
                p.name = title[0] ? title : known ? known->name : base;
                p.modIni = ini;
                p.why = "-game:" + ini + (known ? " (bekannte Mod)" : " (Mod ohne eigenes Profil - Fundament)");
            }
            CoopModDataLoad(p, known, base);   // u194 (P196): eingebautes Profil und system\GothicCoopMod[-<Ini>].json (ohne Log)
            return p;
        }();
        return profile;
    }

    static inline bool CoopProfileIsOthello() {
        return CoopProfile().id == COOP_PROFILE_OTHELLO;
    }

    // u187: Legend of Ahssun (Mods\ModLoA.cpp)
    static inline bool CoopProfileIsLoA() {
        return CoopProfile().id == COOP_PROFILE_LOA;
    }

    // --- u198 (P209): Beitritt nur mit demselben Spiel ------------------------------------------------------------------------
    // Release-Test 0.6.0 (05.11.): Zwei Testlaeufe lagen auf demselben Port, der Client der Gothic-2-Probe trat dem Gothic-1-Host bei,
    // lud dessen Stand (WORLD.ZEN) und stuerzte in oCMobInter::Reset ab (P181 beendete Gothic). Beim Verbinden wurden nur Fassung
    // und GT-Version verglichen - seit dem Universal-Installer melden Gothic 1 und Gothic 2 dieselbe Fassung. Jetzt gehen Engine und
    // Mod mit: Kennung zum Vergleich (Engine, Spiel-Ini der Mod klein bzw. "othello" - unabhaengig von der Sprache des Mod-Titels),
    // Name zur Anzeige. Ein Partner ohne Angabe (Fassung vor u198) gilt als gleich - dort greift schon der Fassungsvergleich.
    static std::string CoopGameKey() {
        const CoopProfileInfo& p = CoopProfile();
        std::string mod = p.id == COOP_PROFILE_OTHELLO ? std::string("othello") : p.modIni;
        for (auto& c : mod)
            c = (char)tolower((unsigned char)c);
        return mod.empty() ? p.game : p.game + "|" + mod;
    }

    static std::string CoopGameShown() {
        const CoopProfileInfo& p = CoopProfile();
        return p.name == p.game ? p.game : p.game + CoopTr(" mit ", " with ") + p.name;
    }

    // Spielt der Absender von e ein anderes Spiel? why: Text fuer Log und Anzeige
    static bool CoopGameMismatch(const json& e, std::string& why) {
        why.clear();
        if (!e.contains("spiel") || !e["spiel"].is_string())
            return false;
        const std::string theirs = e["spiel"].get<std::string>();
        if (theirs == CoopGameKey())
            return false;
        const std::string shown = e.contains("spielname") && e["spielname"].is_string() ? e["spielname"].get<std::string>() : theirs;
        why = CoopTr("Der Partner spielt ", "The partner plays ") + shown + CoopTr(", hier ", ", here ") + CoopGameShown() +
            CoopTr(" - gemeinsam geht nur dasselbe Spiel mit derselben Mod.", " - co-op needs the same game and mod on both PCs.");
        return true;
    }

    // --- u195 (P204): Skript-Weiche - ein Paket fuer alle Mods einer Engine -------------------------------------------------
    // Nutzer: "soll aber jetzt eine Mod installiert werden, die mit allen kompatibel ist automatisch, also auch wenn dann die Gothic
    // erweiterung gewechselt wird". Ein Spielordner behaelt seine Engine, die Mod darin wechselt (GothicStarter, Othello spaeter
    // installiert oder entfernt). Gothic 2, Legend of Ahssun, Gothic II Classic und andere G2-Mods laufen mit denselben Skripten
    // (Satz g2); Gothic 1 und Othello brauchen eigene (Satz g1 bzw. othello: Hauptmenue, Neues Spiel, Figur, Coop-Rune). Installer
    // und Pakete legen alle Saetze der Engine nach system\GothicCoop\Skripte\<Satz>\ (Union reiht nur Skripte aus system\Autorun
    // ein) und einen davon nach system\Autorun. Beim Start (Game_Entry - zParserExtender liest die Dateien erst beim Laden der
    // Parser) legt GT den Satz des erkannten Profils dorthin: eine Datei, die Byte fuer Byte zu einem anderen Satz gehoert, wird
    // ersetzt; eine fehlende kommt dazu (wirkt erst beim naechsten Start - Union hat seine Liste schon); eine eigene oder andere
    // Fassung bleibt (Hinweis im Log). Ohne den Ordner (aeltere Installation, Testinstanz) und im Weltprozess tut sie nichts.
    // Geschrieben wird ueber eine neue Datei und Umbenennen (eine harte Verknuepfung auf die alte Datei bleibt unberuehrt).
    static const char* const CoopScriptSetFiles[] = { "COOP_MENU.D", "COOP_ITEMS.D", "PC_MULTIPLAYER_HERO.D", "COOP_FUN.D" };   // u203: Fun-Modus (nur Satz g2)

    static bool CoopReadWholeFile(const std::string& path, std::string& out) {
        out.clear();
        FILE* f = fopen(path.c_str(), "rb");
        if (!f)
            return false;
        char buf[16384];
        size_t n;
        while ((n = fread(buf, 1, sizeof(buf), f)) > 0)
            out.append(buf, n);
        fclose(f);
        return true;
    }

    static std::string CoopScriptSetSwitch() {
        const std::string store = CoopGameRoot() + "\\system\\GothicCoop\\Skripte\\";
        const DWORD attr = GetFileAttributesA(store.c_str());
        if (attr == INVALID_FILE_ATTRIBUTES || !(attr & FILE_ATTRIBUTE_DIRECTORY))
            return std::string();
        const std::string want = CoopProfileIsOthello() ? "othello" : COOP_ENGINE_SWITCH("g1", "g1a", "g2", "g2");
        std::vector<std::string> sets;   // alle Saetze (Unterordner)
        bool haveWant = false;
        WIN32_FIND_DATAA fd;
        HANDLE h = FindFirstFileA((store + "*").c_str(), &fd);
        if (h != INVALID_HANDLE_VALUE) {
            do {
                if ((fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) && fd.cFileName[0] != '.') {
                    sets.push_back(fd.cFileName);
                    haveWant |= !_stricmp(fd.cFileName, want.c_str());
                }
            } while (FindNextFileA(h, &fd));
            FindClose(h);
        }
        const std::string head = "Skript-Weiche (P204, " + CoopProfile().name + "): Satz " + want;
        if (!haveWant)
            return head + " fehlt in system\\GothicCoop\\Skripte - Skripte in Autorun unveraendert";
        std::string done;
        int same = 0;
        for (const char* name : CoopScriptSetFiles) {
            std::string wanted, have, other;
            if (!CoopReadWholeFile(store + want + "\\" + name, wanted))
                continue;   // Satz ohne diese Datei
            const std::string target = CoopGameRoot() + "\\system\\Autorun\\" + name;
            const bool exists = CoopReadWholeFile(target, have);
            if (exists && have == wanted) {
                same++;
                continue;
            }
            std::string from;   // Satz, zu dem die vorhandene Datei gehoert
            for (size_t k = 0; exists && from.empty() && k < sets.size(); k++)
                if (_stricmp(sets[k].c_str(), want.c_str()) && CoopReadWholeFile(store + sets[k] + "\\" + name, other) && other == have)
                    from = sets[k];
            if (!done.empty())
                done += "; ";
            if (exists && from.empty()) {
                done += std::string(name) + " eigene Fassung - bleibt";
                continue;
            }
            const std::string tmp = target + ".coopneu";
            FILE* f = fopen(tmp.c_str(), "wb");
            bool ok = f && fwrite(wanted.data(), 1, wanted.size(), f) == wanted.size();
            if (f)
                ok = fclose(f) == 0 && ok;
            ok = ok && MoveFileExA(tmp.c_str(), target.c_str(), MOVEFILE_REPLACE_EXISTING);
            if (!ok)
                DeleteFileA(tmp.c_str());   // nur die eigene halbe Zwischendatei
            done += std::string(name) + (exists ? " " + from + " -> " + want : std::string(" fehlte, gelegt (wirkt ab dem naechsten Start)")) +
                (ok ? "" : " - FEHLER beim Schreiben, bleibt");
        }
        return head + ", " + std::to_string(same) + " Dateien passen" + (done.empty() ? std::string() : " - " + done);
    }

    // Eigene Dateien (Modell, Textur) in Gothics Ordner fuer vorkompilierte Daten legen - zoptions DIR_COMPILED_MESHES /
    // DIR_COMPILED_TEXTURES, nur wenn sie fehlen oder abweichen. where = voller Pfad. Bis u4 TpLookWrite in CoopTeleport.cpp
    // (Teleport-Rune v106); u5 auch fuer den Menue-Zeiger ohne Othello (CoopMenuMouse.cpp).
    static bool CoopAssetWrite(int dirKind, const char* name, const unsigned char* data, size_t n, std::string& where) {
        if (!zoptions)
            return false;
        std::string rel = zoptions->GetDirString((zTOptionPaths)dirKind).ToChar();
        if (rel.empty())
            return false;
        if (rel[0] != '\\' && rel[0] != '/')
            rel = "\\" + rel;
        if (rel[rel.size() - 1] != '\\' && rel[rel.size() - 1] != '/')
            rel += "\\";
        const std::string dir = CoopGameRoot() + rel;
        for (size_t p = CoopGameRoot().size() + 1; p < dir.size(); p++)   // Ordner der Reihe nach anlegen
            if (dir[p] == '\\' || dir[p] == '/')
                CreateDirectoryA(dir.substr(0, p).c_str(), NULL);
        where = dir + name;
        if (FILE* f = fopen(where.c_str(), "rb")) {
            std::string have;
            char buf[4096];
            size_t k;
            while ((k = fread(buf, 1, sizeof(buf), f)) > 0 && have.size() <= n)
                have.append(buf, k);
            fclose(f);
            if (have.size() == n && memcmp(have.data(), data, n) == 0)
                return true;
        }
        FILE* f = fopen(where.c_str(), "wb");
        if (!f)
            return false;
        const bool ok = fwrite(data, 1, n, f) == n;
        fclose(f);
        return ok;
    }

    // system\GothicCoopOthello.log (Othello, wie bis v106) bzw. system\GothicCoop.log; u33: Weltprozess <logBase>Welt.log
    static const std::string& CoopLogMainName() {
        static const std::string n = CoopProfile().logBase + (CoopWpIsWorld() ? "Welt.log" : ".log");
        return n;
    }

    // Kopie des Partner-Protokolls: <logBase>Host.log beim Client, <logBase>Client.log bzw. <logBase>Client_<Name>.log beim Host
    static std::string CoopLogPartnerPath(bool fromHost, const std::string& friendName) {
        const std::string& b = CoopProfile().logBase;
        if (fromHost)
            return "system\\" + b + "Host.log";
        return friendName == "FRIEND_1" ? "system\\" + b + "Client.log" : "system\\" + b + "Client_" + friendName + ".log";
    }

    static CRITICAL_SECTION* CoopLogArchiveLock() {
        static CRITICAL_SECTION cs;
        static bool ready = (InitializeCriticalSection(&cs), true);
        (void)ready;
        return &cs;
    }

    static void CoopLogArchiveOnce() {
        static volatile LONG done = 0;
        if (done)
            return;
        EnterCriticalSection(CoopLogArchiveLock());
        if (done) {
            LeaveCriticalSection(CoopLogArchiveLock());
            return;
        }
        if (CoopWpIsWorld()) {
            // u33: der Weltprozess laeuft neben dem Hauptspiel - dessen Logs (system\GothicCoop*.log) sind offen und gehoeren zu
            // dessen Sitzung. Nichts verschieben; das eigene Log wird angehaengt und beim naechsten Start des Hauptspiels mit
            // dessen Logs archiviert.
            if (FILE* f = fopen(CoopSystemFile(CoopLogMainName()).c_str(), "a")) {
                SYSTEMTIME now;
                GetLocalTime(&now);
                fprintf(f, "GothicCoop %s-Fassung %s, Start %04d-%02d-%02d %02d:%02d:%02d - Weltprozess (%s)\n", CoopProfile().tag.c_str(),
                    COOP_FASSUNG, now.wYear, now.wMonth, now.wDay, now.wHour, now.wMinute, now.wSecond, GetCommandLineA());
                fclose(f);
            }
            done = 1;
            LeaveCriticalSection(CoopLogArchiveLock());
            return;
        }
        struct Entry { std::string name; };
        std::vector<Entry> files;
        FILETIME newest = { 0, 0 };
        WIN32_FIND_DATAA fd;
        const std::string& root = CoopGameRoot();   // v98 (A15)
        HANDLE h = FindFirstFileA(CoopSystemFile("GothicCoop*.log").c_str(), &fd);
        if (h != INVALID_HANDLE_VALUE) {
            do {
                if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
                    continue;
                files.push_back({ fd.cFileName });
                if (CompareFileTime(&fd.ftLastWriteTime, &newest) > 0)
                    newest = fd.ftLastWriteTime;
            } while (FindNextFileA(h, &fd));
            FindClose(h);
        }
        char note[600];
        if (files.empty()) {
            _snprintf(note, sizeof(note), "Log-Archiv: keine Logs einer vorigen Sitzung in system\\");
        }
        else {
            // Fassung und Start aus der ersten Zeile des alten Logs, sonst "vor-v35" und die letzte Aenderung.
            // u1: "GothicCoop <Profil>-Fassung ..." - Othello schreibt wie bis v106 "GothicCoop Othello-Fassung ...".
            // u137: die letzte Startzeile statt der ersten (Test-Fenster, 30.10.: ein nicht verschiebbares Log haengt die neue Sitzung an - die u136-Sitzung
            // landete sonst beim naechsten Start unter CoopLogs\u134\)
            char ver[32] = "vor-v35";
            int y = 0, mo = 0, d = 0, hh = 0, mi = 0, ss = 0;
            bool haveStart = false;
            if (FILE* old = fopen(CoopSystemFile(CoopLogMainName()).c_str(), "r")) {
                char line[256] = "";
                while (fgets(line, sizeof(line), old)) {
                    if (strncmp(line, "GothicCoop ", 11))
                        continue;
                    char v[32] = "";
                    int ly = 0, lmo = 0, ld = 0, lhh = 0, lmi = 0, lss = 0;
                    if (sscanf(line, "GothicCoop %*[^-]-Fassung %31[^,], Start %d-%d-%d %d:%d:%d", v, &ly, &lmo, &ld, &lhh, &lmi, &lss) != 7)
                        continue;
                    bool clean = v[0] != 0;
                    for (const char* p = v; *p; p++)
                        if (!isalnum((unsigned char)*p) && *p != '.' && *p != '-' && *p != '_')
                            clean = false;
                    if (clean) {
                        strncpy(ver, v, sizeof(ver) - 1);
                        y = ly; mo = lmo; d = ld; hh = lhh; mi = lmi; ss = lss;
                        haveStart = true;
                    }
                }
                fclose(old);
            }
            if (!haveStart) {
                FILETIME loc;
                SYSTEMTIME st;
                FileTimeToLocalFileTime(&newest, &loc);
                FileTimeToSystemTime(&loc, &st);
                y = st.wYear; mo = st.wMonth; d = st.wDay; hh = st.wHour; mi = st.wMinute; ss = st.wSecond;
            }
            CreateDirectoryA((root + "\\CoopLogs").c_str(), NULL);
            const std::string verDir = root + "\\CoopLogs\\" + ver;
            CreateDirectoryA(verDir.c_str(), NULL);
            char base[MAX_PATH];
            _snprintf(base, sizeof(base), "%s\\%04d-%02d-%02d_%02d-%02d-%02d", verDir.c_str(), y, mo, d, hh, mi, ss);
            base[sizeof(base) - 1] = 0;
            std::string target = base;
            for (int n = 2; !CreateDirectoryA(target.c_str(), NULL); n++) {
                if (GetLastError() != ERROR_ALREADY_EXISTS || n > 99) {
                    target.clear();
                    break;
                }
                target = std::string(base) + "_" + std::to_string(n);
            }
            int moved = 0, kept = 0;
            const std::string shown = target.empty() ? std::string("(kein Ordner)") : target.substr(root.size() + 1);   // CoopLogs\...
            for (auto& f : files) {
                const std::string src = CoopSystemFile(f.name.c_str());
                if (!target.empty() &&
                    MoveFileExA(src.c_str(), (target + "\\" + f.name).c_str(), MOVEFILE_COPY_ALLOWED | MOVEFILE_WRITE_THROUGH)) {
                    moved++;
                    continue;
                }
                kept++;
                if (_stricmp(f.name.c_str(), CoopLogMainName().c_str()) == 0) {
                    WIN32_FILE_ATTRIBUTE_DATA a;
                    if (GetFileAttributesExA(src.c_str(), GetFileExInfoStandard, &a))
                        CoopLogSessionStart = (long)a.nFileSizeLow;
                }
            }
            if (kept)
                _snprintf(note, sizeof(note), "Log-Archiv: %d Datei(en) der vorigen Sitzung nach %s\\ verschoben, %d nicht"
                    " verschiebbar (bleiben in system\\ und werden weiter angehaengt)", moved, shown.c_str(), kept);
            else
                _snprintf(note, sizeof(note), "Log-Archiv: %d Datei(en) der vorigen Sitzung nach %s\\ verschoben", moved,
                    shown.c_str());
        }
        note[sizeof(note) - 1] = 0;
        FILE* f = fopen(CoopSystemFile(CoopLogMainName()).c_str(), "a");
        if (f) {
            SYSTEMTIME now;
            GetLocalTime(&now);
            const CoopProfileInfo& p = CoopProfile();
            fprintf(f, "GothicCoop %s-Fassung %s, Start %04d-%02d-%02d %02d:%02d:%02d\n%s\nProfil: %s (%s; %s)\n",
                p.tag.c_str(), COOP_FASSUNG, now.wYear, now.wMonth, now.wDay, now.wHour, now.wMinute, now.wSecond, note,
                p.name.c_str(), p.game.c_str(), p.why.c_str());
            fclose(f);
        }
        done = 1;
        LeaveCriticalSection(CoopLogArchiveLock());
    }

    // Hauptprotokoll. Auch aus den Netzwerk-Faeden aufgerufen (CoopErrorLog) - darum mit Sperre.
    // Der Name OthelloCompatLog stammt aus dem Othello-Coop (schreibt in jedem Profil, u1).
    static CRITICAL_SECTION* OthelloCompatLogLock() {
        static CRITICAL_SECTION cs;
        static bool ready = (InitializeCriticalSection(&cs), true);
        (void)ready;
        return &cs;
    }

    static void OthelloCompatLog(const char* fmt, ...) {
        EnterCriticalSection(OthelloCompatLogLock());
        CoopLogArchiveOnce();   // v35: vorige Sitzung zuerst archivieren
        static const std::string path = CoopSystemFile(CoopLogMainName());   // v98 (A15): auch vor dem Ordnerwechsel
        FILE* f = fopen(path.c_str(), "a");
        if (f) {
            va_list ap;
            va_start(ap, fmt);
            vfprintf(f, fmt, ap);
            va_end(ap);
            fputc('\n', f);
            fclose(f);
        }
        LeaveCriticalSection(OthelloCompatLogLock());
    }

    // u3: welche Module laufen in dieser Engine nicht (Platzhalter aktiv, Haken aus) - einmal je Start ins Log (Game_Init)
    static void CoopModulesReport() {
        static const struct { const char* name; bool ready; } mods[] = {
            { "Selbstpruefung", COOP_READY_Audit }, { "Zuschau-Fenster", COOP_READY_Camera },
            { "Kampf-Uebergabe", COOP_READY_CombatLead }, { "Schaden", COOP_READY_Damage },
            { "Client-Diagnose", COOP_READY_DiagClient }, { "Dialoge/Story", COOP_READY_Dialog },
            { "Dialog-Waechter", COOP_READY_DialogWatch }, { "Schwierigkeit/Regeln", COOP_READY_Difficulty },
            { "Fern-Abgleich", COOP_READY_FarSync }, { "Treffer-Hoheit", COOP_READY_Hit },
            { "Aussehen/Sprache", COOP_READY_Look }, { "Hauptmenue-Eintraege", COOP_READY_MenuInject },
            { "COOP-Menue", COOP_READY_Lobby }, { "Menue-Maus", COOP_READY_Mouse },
            { "Neues Spiel", COOP_READY_NewGame }, { "Markierung", COOP_READY_Marker },
            { "3D-Vorschau", COOP_READY_Preview }, { "Spielstand-Vorschau", COOP_READY_SavePreview },
            { "Speichern/Laden", COOP_READY_Save }, { "Testlauf", COOP_READY_SelfTest },
            { "Steam", COOP_READY_Steam }, { "Teleport-Rune", COOP_READY_Teleport },
            { "Esc-Hauptmenue", COOP_READY_Title }, { "Schnappschuss", COOP_READY_Trace },
            { "Welt-Abgleich", COOP_READY_World }, { "Kampf-Erweiterungen", COOP_READY_HooksExt },
            { "Haken-Reihenfolge (Othello)", COOP_READY_HookOrder },
        };
        std::string off;
        int n = 0;
        for (auto& m : mods) {
            if (m.ready)
                continue;
            off += (off.empty() ? "" : ", ") + std::string(m.name);
            n++;
        }
#ifdef COOP_PRUEFBAU
        OthelloCompatLog("PRUEFBAU (COOP_PRUEFBAU) - nur zum Uebersetzen gedacht, nicht zum Spielen: alle Module sind gebaut, die"
            " Haken nicht freigegebener Module bleiben aus");
#endif
        if (n)
            OthelloCompatLog("Module: %d von %u in %s noch nicht freigegeben (Platzhalter aktiv, Haken aus): %s",
                n, (unsigned)(sizeof(mods) / sizeof(mods[0])), CoopProfile().game.c_str(), off.c_str());
        else
            OthelloCompatLog("Module: alle %u in %s freigegeben", (unsigned)(sizeof(mods) / sizeof(mods[0])),
                CoopProfile().game.c_str());
    }
}
