// Supported with union (c) 2020 Union team
// Union SOURCE file

namespace GOTHIC_ENGINE {

    // --- u203: Fun-Modus fuer Gothic 2 Die Nacht des Raben (09.11.2026) ------------------------------------------------------
    //
    // Nutzer: "ich moechte aus gothic 2 einen fun modus erstellen, man soll im menue auswaehlen koennen welche gilde man direkt
    // startet, story entfernen alle npc entfernen aber in kapitel 1 starten, basis erstellen und einen haendler hinzufuegen (der
    // bei den jeweiligen gilden steht) ... kapitel aufsteigen indem man z.b. ein mob toetet der in der mitte nahe der taverne
    // steht ... es soll ein coop pvp sein ... mobs spawnen lassen um ep und geld zu farmen ... haendler sollen unendlich gold zur
    // verfuegung haben ... 5 weitere npcs in den jeweiligen lagern die man zum kaempfen mitnehmen kann". Gewaehlt: Miliz,
    // Soeldner, Novize, Bandit; Gilde gegen Gilde; Kapitel 1 bis 6.
    //
    // Die Spielinhalte stehen im Skript system\Autorun\COOP_FUN.D (zParserExtender, MergeMode: ersetzt STARTUP_NewWorld und
    // INIT_NewWorld, das Original bleibt als *_Old; erzeugt von Werkzeuge\funmodus\gen_fun.py). Hier nur, was das Skript nicht
    // selbst kann:
    //  - Engine-Funktionen COOP_FUNMODUS() (1 = dieses neue Spiel ist ein Fun-Spiel) und COOP_FUNGILDE() (Wahl im Menue, Gothic.ini
    //    [GOTHICCOOP] coopFunGilde 0 Miliz, 1 Soeldner, 2 Novize, 3 Bandit) - STARTUP_NewWorld fragt sie beim neuen Spiel.
    //  - Start: COOP > Fun-Modus > "Fun-Spiel starten" (COOP_FUN_NEW_GAME) merkt CoopFunArmed und laeuft dann wie "Neues Spiel"
    //    (Host mit Mitspieler: COOP-Schwierigkeit, LOBBY newgame mit "fun": 1 - der Mitspieler startet ebenfalls als Fun-Spiel).
    //    Jedes andere neue Spiel loescht den Merker.
    //  - Takt: alle 10 s FUN_TAKT_ALLE (jeder PC: eigener Held bekommt Gilde und Ausruestung, Haltung der Lager-NPCs zum eigenen
    //    Helden, Kapitelanzeige) und FUN_TAKT_HOST (Host bzw. ohne Coop: Monster, Boss und Begleiter nachspawnen).
    //  - PvP: im Fun-Spiel immer an; Spieler derselben Gilde treffen sich nicht (Hooks.cpp, CoopHitAuthority.cpp). Die Figur des
    //    Mitspielers traegt seine Gilde (SYNC_ARMOR "gu", LocalNpc/RemoteNpc), damit Begleiter und Wachen sie richtig sehen.
    //  - Abgleich: Skriptvariablen FUNL_* bleiben je PC; Haltungen der FUN_-NPCs ebenso (je Held verschieden) - CoopDialogSync.cpp.

    bool CoopFunArmed = false;              // naechstes neues Spiel ist ein Fun-Spiel
    static bool CoopFunMenuRedirect = false;  // COOP_FUN_NEW_GAME laeuft gerade als NEW_GAME durch das Menue
    static long long CoopFunNextTick = 0;
    static zCParser* CoopFunSymParser = NULL;
    static zCPar_Symbol* CoopFunSym = NULL;
    static bool CoopFunWasActive = false;

    static void FunLog(const char* fmt, ...) {
        char buf[900];
        va_list ap;
        va_start(ap, fmt);
        _vsnprintf(buf, sizeof(buf), fmt, ap);
        va_end(ap);
        buf[sizeof(buf) - 1] = 0;
        OthelloCompatLog("[%lld s, %s] Fun-Modus: %s", DiagSeconds(), DiagRole(), buf);
    }

    int CoopFunGuildChoice() {
        int g = zoptions ? zoptions->ReadInt("GOTHICCOOP", "coopFunGilde", 0) : 0;
        if (g < 0 || g > 3)
            g = 0;
        return g;
    }

    static const char* CoopFunGuildName(int g) {
        static const char* const n[] = { "Miliz", "S\xF6ldner", "Novize", "Bandit" };
        return (g >= 0 && g <= 3) ? n[g] : "?";
    }

    // Laeuft das geladene Spiel als Fun-Spiel? (Skriptvariable FUN_AKTIV aus COOP_FUN.D, mit dem Spielstand gespeichert)
    bool CoopFunActive() {
#if ENGINE == Engine_G2A
        if (!parser)
            return false;
        if (CoopFunSymParser != parser) {
            CoopFunSymParser = parser;
            CoopFunSym = parser->GetSymbol(zSTRING("FUN_AKTIV"));
            if (CoopFunSym && CoopFunSym->type != zPAR_TYPE_INT)
                CoopFunSym = NULL;
        }
        if (!CoopFunSym)
            return false;
        int v = 0;
        CoopFunSym->GetValue(v, 0);
        return v != 0;
#else
        return false;
#endif
    }

#if ENGINE == Engine_G2A
    static int __cdecl CoopFunExtModus() {
        parser->SetReturn(CoopFunArmed ? 1 : 0);
        FunLog("COOP_FUNMODUS() beim Spielstart -> %d%s", CoopFunArmed ? 1 : 0, CoopFunArmed ? " - Fun-Spiel" : " - normales Spiel");
        return 0;
    }

    static int __cdecl CoopFunExtGilde() {
        parser->SetReturn(CoopFunGuildChoice());
        return 0;
    }
#endif

    // UnionHooks.cpp: Game_DefineExternals
    void CoopFunDefineExternals() {
#if ENGINE == Engine_G2A
        if (!parser)
            return;
        parser->DefineExternal(zSTRING("COOP_FUNMODUS"), CoopFunExtModus, zPAR_TYPE_INT, zPAR_TYPE_VOID);
        parser->DefineExternal(zSTRING("COOP_FUNGILDE"), CoopFunExtGilde, zPAR_TYPE_INT, zPAR_TYPE_VOID);
        FunLog("Engine-Funktionen COOP_FUNMODUS und COOP_FUNGILDE angelegt");
#endif
    }

    // Skriptfunktion ohne Parameter mit SELF = eigener Held ausfuehren (wie CoopDialogSync DialogRunScript)
    static bool FunCall(const char* name) {
        if (!parser || !player)
            return false;
        const int idx = parser->GetIndex(zSTRING(name));
        zCPar_Symbol* f = idx >= 0 ? parser->GetSymbol(idx) : NULL;
        if (!f || f->type != zPAR_TYPE_FUNC || (f->flags & zPAR_FLAG_EXTERNAL) || f->ele != 0)
            return false;
        zCPar_Symbol* selfSym = parser->GetSymbol(zSTRING("SELF"));
        void* oldSelf = selfSym ? (void*)selfSym->offset : NULL;
        parser->SetInstance(zSTRING("SELF"), player);
        parser->CallFunc(idx);
        parser->SetInstance(zSTRING("SELF"), oldSelf);
        return true;
    }

    // UnionHooks.cpp: Game_Loop (immer, auch ohne Verbindung)
    void CoopFunPulse() {
#if ENGINE == Engine_G2A
        if (!player || !ogame || IsLoadingLevel)
            return;
        const bool active = CoopFunActive();
        if (active != CoopFunWasActive) {
            CoopFunWasActive = active;
            FunLog(active ? "Fun-Spiel l\xE4uft (Gilde im Men\xFC: %s)" : "kein Fun-Spiel", CoopFunGuildName(CoopFunGuildChoice()));
        }
        if (!active)
            return;
        const long long now = GetCurrentMs();
        if (now < CoopFunNextTick)
            return;
        CoopFunNextTick = now + 10000;
        const bool host = ServerThread != NULL || ClientThread == NULL;
        if (host && !FunCall("FUN_TAKT_HOST"))
            FunLog("FUN_TAKT_HOST fehlt im Skript (system\\Autorun\\COOP_FUN.D nicht geladen?)");
        FunCall("FUN_TAKT_ALLE");
#endif
    }

    // UnionHooks.cpp: Ladeende - erster Takt 3 s danach; nach einem neuen Spiel gilt der Merker nicht mehr
    void CoopFunLoadEnd(bool newGame) {
        CoopFunNextTick = GetCurrentMs() + 3000;
        CoopFunSymParser = NULL;
        if (newGame && CoopFunArmed) {
            FunLog("neues Fun-Spiel geladen (Gilde %s)", CoopFunGuildName(CoopFunGuildChoice()));
            CoopFunArmed = false;
        }
    }

    // CoopMenuLobby.cpp: Menue-Befehle. true = erledigt (result gesetzt)
    int __fastcall zCMenu_HandleSelAction_Coop(zCMenu* _this, void* vtable, int action, const zSTRING& s, zCMenuItem* item);
    bool CoopFunMenuAction(zCMenu* menu, int action, const std::string& arg, int& result, bool clientWaits) {
        if (action == SEL_ACTION_CLOSE && arg == "COOP_FUN_NEW_GAME") {
#if ENGINE == Engine_G2A
            if (ClientThread && !ServerThread)
                return false;   // Aufrufer zeigt "der Host startet" (wie NEW_GAME)
            CoopFunArmed = true;
            FunLog("Men\xFC: Fun-Spiel starten (Gilde %s)", CoopFunGuildName(CoopFunGuildChoice()));
            CoopFunMenuRedirect = true;
            result = zCMenu_HandleSelAction_Coop(menu, NULL, SEL_ACTION_CLOSE, zSTRING("NEW_GAME"), NULL);
            CoopFunMenuRedirect = false;
            return true;
#else
            return false;
#endif
        }
        if (action == SEL_ACTION_CLOSE && !CoopFunMenuRedirect && !clientWaits &&
            (arg == "NEW_GAME" || arg.compare(0, 12, "OTHELLO_NEW_") == 0) && CoopFunArmed) {
            CoopFunArmed = false;
            FunLog("Men\xFC: normales neues Spiel - Fun-Merker aus");
        }
        return false;
    }

    // CoopMenuLobby.cpp: LOBBY newgame des Hosts (Client) - "fun" uebernehmen
    void CoopFunFromHost(bool fun) {
        if (CoopFunArmed != fun)
            FunLog("Host startet %s", fun ? "ein Fun-Spiel - starte als Fun-Spiel mit" : "ein normales Spiel");
        CoopFunArmed = fun;
    }
}
