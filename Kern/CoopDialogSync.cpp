// Supported with union (c) 2020 Union team
// Union SOURCE file

namespace GOTHIC_ENGINE {

    // --- Dialoge: nur einer je NPC, von aussen beobachtbar (v26), Fortschritt + Ueberspringen (v27) -----
    //
    // Wunsch des Nutzers: immer nur ein Spieler spricht mit einem NPC; der Dialog ist von aussen beobachtbar -
    // der NPC spricht seine Zeilen, die Coop-Figur die gewaehlten Heldenzeilen. v27: der Dialog-Fortschritt gilt
    // danach fuer beide, und Ueberspringen (Rechtsklick) laesst die Zeile bei beiden enden.
    //
    // Sprecher-Seite:
    // - Eigener Dialog wird im Pulse an oCInformationManager erkannt (Npc gesetzt, Player == Held, IsDone == 0)
    //   -> DIALOG_START {n = GT-Name des NPCs}, beim Ende DIALOG_END.
    // - Zeilen: Hook hinter oCNpc::EV_Output (0x006B1A70) bzw. EV_OutputSVM (0x006B15A0) -> DIALOG_LINE {n, s = h
    //   (Held) | n (NPC), o = Ausgabename, svm}. EV_Output ist sofort "fertig" (Rueckgabe 1 nach StartOutputUnit);
    //   gesprochen wird danach von der Ton-Nachricht der Ausgabe-Einheit (oCMsgConversation EV_PLAYANISOUND /
    //   EV_PLAYSOUND) in der Warteschlange des Sprechers, Restzeit in ms im Feld +0x90 (SDK-Name f_no; Othello zaehlt
    //   es in OTHELLO_ABI+0x7EA40 herunter, die Nachricht endet bei <= 0).
    // - Ueberspringen: je Sprecher wird diese Ton-Nachricht verfolgt. Verschwindet sie mit mehr als
    //   DIALOG_SKIP_REST_MS Restzeit, wurde die Zeile abgebrochen -> DIALOG_SKIP {n, s, o}. Unabhaengig davon, wie
    //   das Ueberspringen ausgeloest wird (Rechtsklick, Taste, anderes Plugin).
    // - Fortschritt: Hooks um oCInformationManager::OnInfo(oCInfo*) (0x0072D560) und OnChoice(oCInfoChoice*)
    //   (0x0072DC70), beide __fastcall. Darin laeuft das Dialogskript synchron (oCInfo::Info -> CallFunc, told = 1;
    //   Othello setzt told schon vor dem Aufruf). Vorher/nachher Schnappschuss, der Unterschied geht als
    //   DIALOG_STATE {i = Info, v = Skript-Ganzzahlen [Name, Index, Wert], l = Tagebuch, p = NPC-Zustand}.
    //   Skript-Ganzzahlen: alle globalen int-Symbole (nicht const/Klassenfeld/extern, ohne '.' = keine lokalen).
    //   Othello benutzt kein Ikarus/LeGo (GOTHIC.DAT geprueft) - es gibt keine Zeiger in Skriptvariablen.
    //   NPC-Zustand (alle NPCs der Welt ausser Spielern): aivar[50], Haltung (+0x824/+0x828, Felder unter Othello
    //   unveraendert), Tagesablauf (daily_routine = Symbolindex, als Name uebertragen).
    // Zuschauer-Seite (Host und Clients):
    // - Sperre fuer NPC n: oCNpc::AssessTalk_S (0x006B5F50) liefert 0, Chat-Hinweis. GTs Client-Freiraeumen im
    //   StandActions-Hook laesst solche NPCs in Ruhe.
    // - NPC n anhalten (v27): Warteschlange leeren, zur Coop-Figur drehen; danach unterdrueckt ein Hook auf
    //   oCNpc_States::DoAIState (0x006C5C60, Aufrufer oCAIHuman::DoAI ignoriert die Rueckgabe) die ZS-Schleife -
    //   der Tagesablauf laeuft nicht weiter, die Warteschlange (Zeilen) aber schon. v26 schob dafuer EV_WAIT nach;
    //   die standen vor den Ton-Nachrichten und verzoegerten jede Zeile.
    // - Zeile abspielen: neue oCMsgConversation(EV_OUTPUT bzw. EV_OUTPUTSVM, Name) OHNE Ziel in die Warteschlange des
    //   Sprechers, nur in Hoerweite (DIALOG_HEAR_RANGE). Ohne Ziel nimmt EV_Output den Monolog-Weg, und EV_PlaySound
    //   zeigt den Untertitel wie bei Leuten in der Umgebung (v27, Wunsch des Nutzers: rot). Untertitel-Arten in
    //   EV_PlaySound (msg+0x94): 1 eigener Dialog (Held weiss 0x8DB548, NPC gelb 0x8DB478; Spieler beteiligt UND
    //   ZS_TALK), 5 Umgebung/Zuruf (orange-rot 0x8DB480, ogame+0x44; Spieler beteiligt ohne ZS_TALK oder kein
    //   Partner), 3 Zwischensequenz, 2 NPC-NPC (weiss, PrintMessageCXY ogame+0x38). "Spieler" = vtable+0x104
    //   oCNpc::IsSelfPlayer. Die Farben setzt das Spiel zur Laufzeit. Die Reihenfolge NPC/Held stellt ohne Ziel
    //   DialogLineQueue her (naechste Zeile erst, wenn beide still sind).
    // - SKIP: wartet die Zeile noch, wird sie ausgelassen; sonst Ton-Nachrichten des Sprechers auf Restzeit 0 (reines
    //   Datenfeld), Stimme aus (oCNpc::StopAllVoices, nicht virtuell).
    // - STATE: Ganzzahlen ueber zCPar_Symbol::SetValue, told direkt, Tagebuch ueber die Skript-Externals
    //   LOG_CREATETOPIC / LOG_SETTOPICSTATUS / LOG_ADDENTRY (Funktionszeiger aus dem Symbol, zCPar_Symbol::offset -
    //   so wie DefineExternal ihn ablegt; Parameter auf den Datenstapel: int = Wert, 0x40; string = zSTRING*, 0x41),
    //   NPCs ueber aivar, SetAttitude/SetTmpAttitude, oCNpc_States::ChangeRoutine(int).
    // - Ende: Sperre sofort frei; NPC erst freigeben, wenn er nicht mehr spricht (hoechstens 15 s).
    // Alle benutzten Engine-Stellen und ihre Aufrufer unter Othello geprueft (Speicherabbild): unveraendert bis auf
    // oCInfo::Info (Othello: told vor dem Skript) - deshalb wird dort nicht gehookt.
    //
    // u11: fuer Gothic 2 NotR freigegeben (Test u10: "beide sind im Dialog [mit Xardas], es soll ja aber nur einer sein. Der andere
    // soll auch die Dialoge hoeren"). Gegen Gothic2.exe und die G2-Skripte geprueft: Haken-Adressen aus dem G2A-SDK (CoopAddr.h),
    // OnInfo/OnChoice dort ebenfalls __fastcall; DoAIState rufen oCAIHuman::DoAI (0x0069BFBA, Rueckgabe ungenutzt) und
    // StartAIState (0x0076CD9A, gibt sie bei Programm-Zustaenden weiter - betrifft nur angehaltene NPCs). Npc_CheckInfo nutzen
    // B_AssessPlayer/B_AssessTalk wie in G1. Skript-Unterschiede: EP ueber B_GivePlayerXP (G1 B_GiveXP), B_LogEntry(topic, entry)
    // gleich, Log_*/Wld_*/IntroduceChapter gleich. Nie abgeglichen (je PC): PLAYER_MOBSI_PRODUCTION (G2-Herstellung laeuft als
    // Dialog des Helden mit sich selbst), CURRENTLEVEL (je Welt), HERO_HACKCHANCE (Goldhacken des eigenen Helden).

    bool CoopRuleQuests();   // v75: CoopDifficulty.cpp - Abgleich "Quests" / "Tagebuch" (Regeln des Hosts)
    bool CoopRuleWorld();    // u27: Abgleich "Gegenstaende/Truhen" (Wld_InsertItem ueber den Host)
    bool CoopRuleLog();
    bool CoopRuleTakeOnConnect();   // v110: beim Verbinden gilt der Stand des Hosts
    bool CoopNewGameInfoBlocked();   // v91: CoopNewGame.cpp - gemeinsames neues Spiel: der Host spricht zuerst (Diego)
    void CoopNewGameDialogEnded(const std::string& by, const std::string& npc);

#if COOP_BUILD(Dialog)   // u3: bis u2 nur G1 - Freigabe je Engine in CoopCore.cpp

    static const float DIALOG_HEAR_RANGE = 3000.f;   // cm
    static const int DIALOG_SKIP_REST_MS = 350;

    struct CoopDialogLock {
        std::string owner;
        long long since;
    };

    struct CoopDialogEnd {
        std::string n;
        std::string by;
        long long since;
    };

    struct CoopDialogQueuedLine {
        std::string by;
        std::string s;
        std::string o;
        bool svm;
    };

    struct CoopDialogLineTrack {
        void* msg = NULL;        // verfolgte Ton-Nachricht (nur Vergleich, nie dereferenziert)
        int lastRest = 0;        // zuletzt gesehene Restzeit in ms
        std::string line;        // zuletzt gemeldete Zeile dieses Sprechers
        long long lineMs = 0;
        bool soundSeen = false;
        bool ran = false;        // v80: Restzeit seit dem ersten Sehen gesunken - die Nachricht lief wirklich
    };

    static std::map<std::string, CoopDialogLock> DialogLocks;    // GT-Name des NPCs -> wer spricht
    static std::vector<CoopDialogEnd> DialogEnds;                 // beendet, NPC spricht evtl. noch die letzte Zeile
    static std::set<oCNpc*> DialogFrozen;                         // Tagesablauf angehalten (nur Vergleich)
    static std::map<std::string, std::deque<CoopDialogQueuedLine>> DialogLineQueue;   // je NPC: Zeilen, die noch warten
    static std::map<std::string, long long> DialogLastInjectMs;
    static oCNpc* MyDialogNpcPtr = NULL;
    static std::string MyDialogNpc;
    static std::map<oCNpc*, std::pair<void*, std::string>> LastLineMsg;
    static CoopDialogLineTrack TrackHero, TrackNpc;
    static long long DialogBusyMsgMs = 0;
    static int DialogInjecting = 0;
    static unsigned long DialogLogLines = 0;
    static int DialogSoundDiag = 0;

    static void DialogLog(const char* fmt, ...) {
        if (DialogLogLines >= 1500)
            return;
        DialogLogLines++;
        char buf[600];
        va_list ap;
        va_start(ap, fmt);
        _vsnprintf(buf, sizeof(buf), fmt, ap);
        va_end(ap);
        buf[sizeof(buf) - 1] = 0;
        OthelloCompatLog("[%lld s, %s] Dialog-Sync: %s", DiagSeconds(), DiagRole(), buf);
    }

    static bool DialogSyncAktiv() {
        return (ServerThread || ClientThread) && !IsCoopPaused && !IsLoadingLevel && !WorldEditMode && ogame && player
            && !(MyselfId == "_player_");
    }

    static std::string DialogMe() {
        return std::string(MyselfId.ToChar());
    }

    static std::string DialogNpcName(oCNpc* npc) {
        auto f = NpcToUniqueNameList.find(npc);
        return f == NpcToUniqueNameList.end() ? std::string() : std::string(f->second.ToChar());
    }

    static void PartyNoteEntry(const json& jn, const std::string& by);              // u199 (P217), weiter unten
    static void PartyNote(oCNpc* npc, const std::string& client, const char* why);
    static void PartyLeaderClear();
    static int PartyAiv();
    static void HeroStateClear();                                                    // u199 (P221), weiter unten

    static oCNpc* DialogNpcByName(const std::string& n) {
        auto f = UniqueNameToNpcList.find(string(n.c_str()));
        return f == UniqueNameToNpcList.end() ? NULL : f->second;
    }

    static oCNpc* DialogFigureOf(const std::string& who) {
        auto f = PlayerNameToNpc.find(string(who.c_str()));
        return f == PlayerNameToNpc.end() ? NULL : f->second;
    }

    static void DialogSend(json& j, int type) {
        j["type"] = type;
        j["id"] = MyselfId.ToChar();
        j["w"] = CoopWorldName();
        if (ServerThread && !j.contains("by"))
            j["by"] = MyselfId.ToChar();
        CoopTraceCount(TRACE_SENT, type);
        ReadyToSendJsons.enqueue(j);
    }

    // Fuer den StandActions-Hook: steht dieser NPC in einem Dialog eines Mitspielers?
    bool CoopDialogNpcBusy(oCNpc* npc) {
        if (!npc || DialogLocks.empty())
            return false;
        auto f = DialogLocks.find(DialogNpcName(npc));
        return f != DialogLocks.end() && f->second.owner != DialogMe();
    }

    // --- Nachrichten in Warteschlangen --------------------------------------------------------------

    static bool DialogIsSoundMsg(oCMsgConversation* m) {
        return m && (m->subType == oCMsgConversation::EV_PLAYANISOUND || m->subType == oCMsgConversation::EV_PLAYSOUND);
    }

    // laufende Ton-Nachricht: Restzeit gueltig (v28). Eine noch nicht gestartete Nachricht traegt in +0x90 anderes
    // (beim Helden gesehen: 0x3F800000 = 1.0f); EV_PlaySound setzt dort beim Start die Dauer in ms.
    static oCMsgConversation* DialogFindSound(oCNpc* npc) {
        zCEventManager* em = npc ? npc->GetEM(0) : NULL;
        if (!em)
            return NULL;
        const int cnt = em->GetNumMessages();
        for (int i = 0; i < cnt; i++) {
            oCMsgConversation* m = zDYNAMIC_CAST<oCMsgConversation>(em->GetEventMessage(i));
            if (DialogIsSoundMsg(m) && !m->IsDeleted() && m->f_no > 0 && m->f_no <= 120000)
                return m;
        }
        return NULL;
    }

    // spricht der NPC noch (Zeile wartet oder Ton laeuft)?
    static bool DialogSpeaking(oCNpc* npc) {
        zCEventManager* em = npc ? npc->GetEM(0) : NULL;
        if (!em)
            return false;
        const int cnt = em->GetNumMessages();
        for (int i = 0; i < cnt; i++) {
            oCMsgConversation* m = zDYNAMIC_CAST<oCMsgConversation>(em->GetEventMessage(i));
            if (m && !m->IsDeleted() && (DialogIsSoundMsg(m) || m->subType == oCMsgConversation::EV_OUTPUT
                || m->subType == oCMsgConversation::EV_OUTPUTSVM))
                return true;
        }
        return false;
    }

    // --- Sprecher-Seite: Ueberspringen erkennen -----------------------------------------------------

    static void DialogCheckSkip(oCNpc* speaker, CoopDialogLineTrack& t, const char* s) {
        oCMsgConversation* cur = speaker ? DialogFindSound(speaker) : NULL;
        const int rest = cur ? cur->f_no : 0;
        // v80: dieselbe Nachricht, Restzeit gestiegen, ohne vorher gesunken zu sein - sie startet erst jetzt. Eine neue Ton-Nachricht
        // im Speicher einer alten traegt in +0x90 bis zum Start noch deren Rest (Test v79 nach Tod + Laden: 561, 2521, 1202 ms wie vor
        // dem Tod) - das war kein Ueberspringen, der Partner brach die Zeilen trotzdem ab.
        if (t.msg && cur == (void*)t.msg && rest > t.lastRest + 50 && !t.ran) {
            static int restartLogged = 0;
            if (restartLogged < 20) {
                restartLogged++;
                DialogLog("Ton der Zeile %s (%s) startet erst jetzt (%d ms, vorher %d ms aus altem Speicher) - kein Ueberspringen",
                    t.line.c_str(), s, rest, t.lastRest);
            }
            t.lastRest = rest;
            return;
        }
        // die verfolgte Ton-Nachricht ist weg - oder an derselben Adresse steht schon die naechste (Restzeit stieg)
        if (t.msg && (cur != (void*)t.msg || rest > t.lastRest + 50)) {
            if (t.ran && t.lastRest > DIALOG_SKIP_REST_MS && !t.line.empty() && !MyDialogNpc.empty()) {
                json j;
                j["n"] = MyDialogNpc;
                j["s"] = s;
                j["o"] = t.line;
                j["r"] = t.lastRest;
                DialogSend(j, SYNC_DIALOG_SKIP);
                DialogLog("Zeile %s uebersprungen (Rest %d ms) - Partner ueberspringt mit", t.line.c_str(), t.lastRest);
            }
            t.msg = NULL;
            t.lastRest = 0;
            t.ran = false;
        }
        if (cur && !t.msg) {
            t.msg = cur;
            t.soundSeen = true;
            t.ran = false;
            t.lastRest = rest;   // v80: Ausgangswert - "lief" erst, wenn die Restzeit darunter sinkt
            if (DialogSoundDiag < 30) {
                DialogSoundDiag++;
                DialogLog("Ton der Zeile %s (%s): Art %d, Restzeit %d ms", t.line.c_str(), s, (int)cur->subType, rest);
            }
        }
        if (cur) {
            if (rest < t.lastRest)
                t.ran = true;
            t.lastRest = rest;
        }
        else if (!t.soundSeen && !t.line.empty() && t.lineMs && CurrentMs > t.lineMs + 2000) {
            DialogLog("Zeile %s (%s): keine Ton-Nachricht in der Warteschlange gefunden - Ueberspringen hier nicht erkennbar",
                t.line.c_str(), s);
            t.lineMs = 0;
        }
    }

    static void DialogCheckSkips() {
        DialogCheckSkip(player, TrackHero, "h");
        DialogCheckSkip(MyDialogNpcPtr, TrackNpc, "n");
    }

    // --- Sprecher-Seite: Beginn, Ende, Zeilen --------------------------------------------------------

    static void TrackOwnDialog() {
        oCInformationManager& im = oCInformationManager::GetInformationManager();
        // u11: Npc == Held ist in G2 die Herstellung (Amboss, Alchemie, Gebet ...: AI_ProcessInfos(hero)) - kein Gespraech
        oCNpc* now = (im.Npc && im.Npc != player && im.Player == player && !im.IsDone) ? im.Npc : NULL;
        if (now == MyDialogNpcPtr)
            return;
        if (MyDialogNpcPtr && !MyDialogNpc.empty()) {
            DialogCheckSkips();   // letzte Zeile uebersprungen und gleich beendet?
            json j;
            j["n"] = MyDialogNpc;
            DialogSend(j, SYNC_DIALOG_END);
            DialogLog("eigener Dialog mit %s beendet", MyDialogNpc.c_str());
        }
        MyDialogNpcPtr = now;
        MyDialogNpc = now ? DialogNpcName(now) : std::string();
        LastLineMsg.clear();
        TrackHero = CoopDialogLineTrack();
        TrackNpc = CoopDialogLineTrack();
        if (!now)
            return;
        if (MyDialogNpc.empty()) {
            DialogLog("eigener Dialog mit %s - NPC hat keinen GT-Namen, nicht beobachtbar", now->GetInstanceName().ToChar());
            return;
        }
        auto f = DialogLocks.find(MyDialogNpc);
        if (f != DialogLocks.end() && f->second.owner != DialogMe())
            DialogLog("eigener Dialog mit %s, obwohl %s mit ihm spricht (gleichzeitig angesprochen oder vom NPC gestartet)",
                MyDialogNpc.c_str(), f->second.owner.c_str());
        json j;
        j["n"] = MyDialogNpc;
        DialogSend(j, SYNC_DIALOG_START);
        DialogLog("eigener Dialog mit %s beginnt", MyDialogNpc.c_str());
    }

    static void ReportLine(oCNpc* speaker, oCMsgConversation* msg, bool svm) {
        if (DialogInjecting || !msg || !speaker || !DialogSyncAktiv())
            return;
        if (!MyDialogNpcPtr)
            TrackOwnDialog();   // Zeile im selben Bild wie der Dialogbeginn
        if (!MyDialogNpcPtr || MyDialogNpc.empty())
            return;
        const bool hero = speaker == player;
        if (!hero && speaker != MyDialogNpcPtr)
            return;
        const std::string name = msg->name.ToChar();
        if (name.empty())
            return;
        auto& last = LastLineMsg[speaker];
        if (last.first == (void*)msg && last.second == name)
            return;   // dieselbe Nachricht, schon gemeldet
        last = std::make_pair((void*)msg, name);
        DialogCheckSkips();   // vorige Zeile vorzeitig zu Ende? Erst SKIP, dann die neue Zeile
        CoopDialogLineTrack& t = hero ? TrackHero : TrackNpc;
        t.line = name;
        t.lineMs = CurrentMs;
        t.soundSeen = false;
        json j;
        j["n"] = MyDialogNpc;
        j["s"] = hero ? "h" : "n";
        j["o"] = name;
        j["svm"] = svm ? 1 : 0;
        DialogSend(j, SYNC_DIALOG_LINE);
    }

    // --- Sprecher-Seite: Fortschritt (Skript-Zustand vor/nach Info bzw. Auswahl) --------------------

    struct CoopDlgTopic {
        std::string t;
        int sec = 0;
        int st = 0;
        std::vector<std::string> e;
    };

    // u139 (P138): Felder, die Skripte am NPC direkt setzen. Vom Test-Fenster (b74, Kapitel 4): DIA_DRAGON_SWAMP_EXIT_INFO setzt
    // SWAMPDRAGON.flags = 0, gesprochen hatte der Host. Der Client hoert das Gespraech nie (die Info ist als gehoert abgeglichen), sein
    // Drache blieb unsterblich: Fuehrte er den Kampf, traf er ohne Wirkung ("Schaden 0, HP 750 -> 750"), der Drache konnte nicht sterben.
    // Betroffen: flags (Skripte G2A 74 Stellen, G1 18: Drachen, Begleiter, Sekob, Garond, Gomez, Dusty), Gilde und wahre Gilde (G1: Gomez,
    // Bartholo, Bullit, Stone, Skip, Dusty), npctype, noFocus (G2A: Golem). Felder wie Haltung und Tagesablauf: Dialog (DlgSendDiff),
    // Takt (StoryTick), RESYNC (CoopStorySendAllNpcs). Betritt der Partner die Welt spaeter, holt er ihren Stand samt Feldern (P88).
    // Die wahre Gilde nur ueber die Funktionen - Othello verlegt das Feld (0x7A6 -> 0xA34). Allgemein.
    struct CoopNpcFields {
        int flags, guild, guildTrue, npcType, noFocus;
    };

    static CoopNpcFields DlgNpcFields(oCNpc* n) {
        CoopNpcFields f;
        f.flags = n->variousFlags;
        f.guild = n->guild;
        f.guildTrue = n->GetTrueGuild();
        f.npcType = n->npcType;
#if ENGINE == Engine_G2A
        f.noFocus = n->noFocus;
#else
        f.noFocus = 0;
#endif
        return f;
    }

    static bool DlgNpcFieldsSame(const CoopNpcFields& a, const CoopNpcFields& b) {
        return a.flags == b.flags && a.guild == b.guild && a.guildTrue == b.guildTrue && a.npcType == b.npcType && a.noFocus == b.noFocus;
    }

    static void DlgNpcFieldsDiff(const CoopNpcFields& a, const CoopNpcFields& b, json& jn) {
        if (a.flags != b.flags)
            jn["fl"] = b.flags;
        if (a.guild != b.guild)
            jn["gu"] = b.guild;
        if (a.guildTrue != b.guildTrue)
            jn["gt"] = b.guildTrue;
        if (a.npcType != b.npcType)
            jn["nt"] = b.npcType;
        if (a.noFocus != b.noFocus)
            jn["nf"] = b.noFocus;
    }

    struct CoopDlgNpc {
        oCNpc* npc = NULL;
        int aiv[COOP_AIV_MAX];   // u3: G1 50, G2 100
        int att = 0;
        int tatt = 0;
        int rtn = 0;
        CoopNpcFields f;   // u139
    };

    struct CoopDlgSnap {
        std::vector<int> ints;
        std::vector<CoopDlgTopic> log;
        std::vector<CoopDlgNpc> npcs;
        long long exp = 0;   // v31: Erfahrung des eigenen Helden (Quest-EP fuer beide)
        std::map<std::string, int> inv;   // u85: Inventar des eigenen Helden (Instanz -> Menge) - Belohnung aus Gilden-Quests
        int guild = 0;                    // u85: Gilde des eigenen Helden (Aufnahme waehrend des Infos)
    };

    // u163 (P170): Vom Test-Fenster (b214, Gothic 1 Kapitel 4): Cronos' Handelsfenster hatte dieselben 20 Sorten wie am 2.11. - ohne die Ware aus
    // B_Kapitelwechsel (B_Give_CronosChapter2/3/4Runes: CreateInvItems(Hlp_GetNpc(KDW_604_Cronos), ...), ebenso Fisk, Darrion, Sharky, Wolf, Riordian,
    // Baal Cadar, Xardas ...). Die Kapitelwechsel 2, 3 und 4 liefen im Gespraech des Clients. Der Abgleich brachte dem Host Variablen, Tagebuch,
    // NPC-Zustaende und den Kapitel-Bildschirm, nicht aber, was das Skript in die Inventare anderer NPCs legte - die Ware gab es nur beim Client,
    // nach dem naechsten Laden (Stand des Hosts) auf keinem PC mehr. Gothic 2 fuellt Haendler beim Handel (B_GiveTradeInv, die Merker
    // *_ITEMSGIVEN_CHAPTER_n gleicht der Abgleich ab) - dort bekam der Haendler des Partners die Ware nie.
    // Jetzt zaehlen CreateInvItem(s) und Npc_RemoveInvItem(s) an Welt-NPCs (nicht der eigene Held, keine Coop-Figur) mit, solange ein eigenes
    // Dialogskript laeuft (OnInfo/OnChoice): Menge der Instanz vorher und nachher (oCNpcInventory::GetAmount wie Npc_HasItems), je NPC und Instanz
    // zusammengezaehlt - was ein NPC erst bekommt und gleich dem Helden gibt (CreateInvItems + B_GiveInvItems), hebt sich auf. Der Unterschied geht
    // mit dem Fortschritt hinaus ("ni": [Name, Instanz, Menge]); der Partner legt ihn in derselben Welt bei seiner Kopie des NPCs an bzw. nimmt ihn
    // heraus (DlgInvApply). Nicht dabei: Skripte ausserhalb von Gespraechen (Tagesablauf, Todesskripte - die laufen auf jedem PC), EquipItem,
    // Mob_CreateItems. Allgemein (G1, G2, Othello).
    static int DlgInvDepth = 0;   // > 0: eigenes Dialogskript laeuft
    static std::map<std::pair<std::string, std::string>, int> DlgInvChanges;   // (NPC, Instanz) -> Menge

    struct CoopDlgIntSlot {
        zCPar_Symbol* sym;
        int idx;
    };

    static std::vector<CoopDlgIntSlot> DlgIntSlots;
    static std::map<std::pair<zCPar_Symbol*, int>, int> DlgSlotIndex;   // (Symbol, Feld) -> Platz in DlgIntSlots
    static int DlgIntSymCount = -1;

    // --- Story-Abgleich (v28): Stand, gegen den jede Sekunde verglichen wird ---------------------------
    // Was vom Partner kommt, wird auch hier eingetragen (kein Echo). Nach dem Laden neu aufgenommen.
    static bool StoryReady = false;
    static bool StoryLevelChange = false;   // u140 (P139): Weltwechsel laeuft, der Vergleichsstand von davor gilt noch fuer die Skriptvariablen
    static std::map<std::string, int> StoryEntryBase;   // u141 (P141): Eintritts-Merker meiner Welt, zuletzt verglichen
    static bool StorySyncOn = true;
    static bool StoryCfgRead = false;
    static long long StoryNextMs = 0;
    static std::vector<int> StoryBaseInts;
    static std::map<std::string, CoopDlgTopic> StoryBaseLog;
    static std::vector<std::deque<long long>> StoryChangeTimes;
    static std::vector<char> StoryNoisy;
    static std::set<std::string> StoryIgnore;

    // v31: NPC-Tagesablauf (daily_routine) und dauerhafte Haltung (attitude) aller Welt-NPCs, Gildenhaltungs-Tabelle
    struct CoopStoryNpcBase {
        int rtn;
        int att;
        CoopNpcFields f;   // u139
    };
    static std::map<std::string, CoopStoryNpcBase> StoryBaseNpc;   // GT-Name -> Stand
    static std::map<std::string, std::deque<long long>> StoryNpcTimes;
    static std::set<std::string> StoryNpcNoisy;
    static std::vector<unsigned char> StoryBaseGuilds;
    static int StoryGuildSize = 0;

    // Story-Werte sind kleine Zahlen (Merker, Zaehler, Tage, LOG_*). Grosse Werte koennten Zeiger/Handles von
    // Plugin-Skripten sein (zParserExtender) - nie uebertragen.
    static bool StoryValueOk(int v) {
        return v > -0x400000 && v < 0x400000;
    }

    // --- Heldenwerte (v31) -------------------------------------------------------------------------
    //
    // Othello legt Ausruestungs- und Bonuszustaende des Helden in GLOBALE Skriptvariablen (HERO_*_EQ, GET_ITAM_*, MODREGENHP,
    // HPPERKILL ...; Analyse tools\herovars.py: 135 nur von Helden-Funktionen geschrieben, 15 gemischt). Die duerfen weder der
    // Story-Abgleich noch D4 uebertragen, sonst bekaeme der Held des Partners fremde Boni. Einordnung zur Laufzeit aus dem
    // Bytecode (parser->stack: stack = Code, stacksize = Laenge, siehe zCPar_Stack::Load 0x006FB450):
    // - Wurzeln: alle Funktionen, die einem C_ITEM.ON_EQUIP/ON_UNEQUIP zugewiesen werden (PUSHINT|PUSHVAR f; PUSHVAR feld;
    //   ASSIGNFUNC), dazu B_GIVEXP, B_ADDBONUS, B_BUYATTRIBUTEPOINTS, B_TEACH*, die Instanz PC_HERO;
    // - Helden-Kontext = Wurzeln + alles, was sie aufrufen (CALL);
    // - Heldenwert = globale int-Variable, die irgendeine Funktion im Helden-Kontext schreibt (PUSHVAR|ARRAYVAR v; = += -= *= /=).
    static std::set<zCPar_Symbol*> StoryHeroVars;
    static bool StoryHeroVarsBuilt = false;

    // u26 (docs\G2-SKRIPTABGLEICH.md B2, Abgleich mit dem G2-Modkit): Gothic 2 schreibt Helden-Zaehler und Einmal-Merker auch aus
    // Verbrauchs-Gegenstaenden (C_ITEM.ON_STATE) und Lesepulten (*_S1) - die zaehlt die Wurzel-Regel oben nicht zum Helden, sie
    // liefen bis u25 als Story-Werte (gemeinsam). Feste Liste, je Held (nicht abgleichen, in COOPHERO.TXT):
    // - Zaehler fuer Boni: Aepfel (+1 Staerke beim 25.), Dunkelpilze (+5 Mana beim 50.), Blutfliegen-Stachel/Zangen (je 10 Heilungen),
    //   Muscheln (erste gibt eine Perle);
    // - Einmal-Boni beim Lesen/Trinken: Einhand-/Zweihandbuch, Astronomie, Lous Hammer, erster Joint, Lesepulte (einmalige EP);
    // - eigene Karte (B_SetPlayerMap), Besessenheit (B_SCIsObsessed, Heiltrank, Schrein), Zwischenwerte von Steintafel/Maya-Pult;
    // - Rezepte aus Schriftstuecken (Nutzer: "Rezepte je Held", wie die Talente PLAYER_TALENT_*): Lous Hammer, Schlafhammer,
    //   Schneller Hering, Elixier der Geistveraenderung, Banditenaxt, Blutfliegen-Wissen, Joint-Rezept.
    // Story-Merker aus Briefen (CORNELIUS_ISLIAR, KNOWS_HALVOR, PLAYER_KNOWSSCHNELLERHERING, MIS_*, SC_KNOWS*) bleiben gemeinsam -
    // Dialoge fragen sie ab. In Gothic 1 gibt es diese Namen nicht.
    static const char* const StoryHeroVarsExtra[] = {
        "APPLE_BONUS", "DUNKELPILZ_BONUS", "BLOODFLY_BONUS", "MANDIBLES_BONUS", "SHELL_OPENER",
        "LERNE_EINHAND", "LERNE_ZWEIHAND", "ASTRONOMY_ONCE", "HAMMER_ONCE", "FIRSTJOINT",
        "ALCHEMY_1_PERMANENT", "ALCHEMY_2_PERMANENT", "ALCHEMY_3_PERMANENT", "ANIMALS_1_PERMANENT", "ANIMALS_2_PERMANENT",
        "ANIMALS_3_PERMANENT", "HISTORY_1_PERMANENT", "HISTORY_2_PERMANENT", "BOOKSTANDMAYAHIERCHARY_1_PERMANENT",
        "BOOKSTANDMAYAHIERCHARY_2_PERMANENT", "BOOKSTANDMAYAHIERCHARY_3_PERMANENT", "BOOKSTANDMAYAHIERCHARY_4_PERMANENT",
        "BOOKSTANDMAYAHIERCHARY_5_PERMANENT",
        "PLAYERMAPINSTANCE", "SC_ISOBSESSED", "SC_OBSESSIONCOUNTER", "SC_OBSESSIONTIMES", "STONEPLATEITEM", "STONEPLATELEVEL",
        "BOOKSTANDMAYAART",
        "KNOWS_LOUSHAMMER", "KNOWS_SCHLAFHAMMER", "KNOWS_SCHNELLERHERING", "KNOWS_MCELIXIER", "KNOWS_BANDITENAXT", "KNOWS_BLOODFLY",
        "GREEN_EXTREM",
        // u195 (P203, aus der Gegenprobe von tools\mod_analyse.py mit Gothic II): Ausbaustufe der Klaue Beliars und Menuestand der
        // Herstell-Mobsis (Gespraeche des Helden mit sich selbst) - je Held, gingen bisher zum Partner
        "BELIARDAMAGECHANCE", "BELIARNEXTDAMAGECHANCE", "BELIARWEAPCURRENTLVL", "BELIARWEAPNEXTLVL",
        "BOOZESTART", "HEALTHSTART", "MANASTART", "SPECIALSTART", "TABAKSTART", "ERZWAFFEN", "NORMALWAFFEN",
        // u199 (P214, aus der LoA-Durchsicht, gilt fuer Gothic II): Goldhacken im Addon (PC_GOLDHACKEN_ADDON_HOUR, Gespraech des Helden
        // mit sich selbst) - Uebung, geschuerfte Stunden und Schlag-Zaehler des eigenen Helden gingen bisher zum Partner. Den gelernten
        // Truemmerschlag (KNOWS_TRUEMMERSCHLAG, Finns Gespraech) behaelt der Abgleich: das Lehr-Gespraech gilt fuer beide als erzaehlt
        "LEARN_BY_DOING", "GOLDCOUNTER", "TRUEMMER_COUNT" };

    static bool DlgScriptLibraryVar(const char* nm);   // u196 (P206): weiter unten
    bool CoopModHeroVar(const char* nm);                // u197 (P207): Mods\CoopMods.cpp - "heroVars" des Mod-Profils

    static void StoryBuildHeroVars() {
        StoryHeroVarsBuilt = true;
        if (!parser)
            return;
        const unsigned char* code = parser->stack.stack;
        const int size = parser->stack.stacksize;
        const int cnt = parser->symtab.table.GetNum();
        if (!code || size <= 0 || cnt <= 0) {
            DialogLog("Heldenwerte: kein Skript-Code (%p, %d) - nicht eingeordnet", code, size);
            return;
        }
        std::vector<std::pair<int, int>> owners;   // Code-Anfang -> Symbol (Funktion, Prototyp, Instanz)
        std::map<int, int> funcAt;                  // Code-Anfang -> Funktionssymbol
        for (int i = 0; i < cnt; i++) {
            zCPar_Symbol* s = parser->symtab.table[i];
            if (!s || (s->flags & (zPAR_FLAG_EXTERNAL | zPAR_FLAG_CLASSVAR)))
                continue;
            if (s->type != zPAR_TYPE_FUNC && s->type != zPAR_TYPE_PROTOTYPE && s->type != zPAR_TYPE_INSTANCE)
                continue;
            const int st = s->single_intdata;
            if (st < 0 || st >= size)
                continue;
            owners.push_back(std::make_pair(st, i));
            if (s->type == zPAR_TYPE_FUNC)
                funcAt[st] = i;
        }
        std::sort(owners.begin(), owners.end());
        auto ownerOf = [&](int q) {
            auto it = std::upper_bound(owners.begin(), owners.end(), std::make_pair(q, 0x7FFFFFFF));
            return it == owners.begin() ? -1 : (it - 1)->second;
        };
        auto isGlobalInt = [&](int i) {
            if (i < 0 || i >= cnt)
                return false;
            zCPar_Symbol* s = parser->symtab.table[i];
            return s && s->type == zPAR_TYPE_INT && !(s->flags & (zPAR_FLAG_CONST | zPAR_FLAG_CLASSVAR)) && !strchr(s->name.ToChar(), '.');
        };
        const int onEq = parser->GetIndex(zSTRING("C_ITEM.ON_EQUIP"));
        const int onUneq = parser->GetIndex(zSTRING("C_ITEM.ON_UNEQUIP"));
        std::map<int, std::set<int>> calls, writers;
        std::set<int> roots;
        int p1op = -1, p1arg = 0, p2op = -1, p2arg = 0;
        for (int q = 0; q < size;) {
            const unsigned char op = code[q];
            int arg = 0, len = 1;
            if (op == 61 || op == 62 || op == 64 || op == 65 || op == 67 || op == 75 || op == 76 || op == 80) {
                if (q + 5 > size)
                    break;
                arg = *(const int*)(code + q + 1);
                len = 5;
            }
            else if (op == 245) {
                if (q + 6 > size)
                    break;
                arg = *(const int*)(code + q + 1);
                len = 6;
            }
            const int o = ownerOf(q);
            if (op == 61) {
                auto f = funcAt.find(arg);
                if (f != funcAt.end())
                    calls[o].insert(f->second);
            }
            else if ((op == 9 || (op >= 19 && op <= 22)) && (p1op == 65 || p1op == 245) && isGlobalInt(p1arg))
                writers[p1arg].insert(o);
            else if (op == 72 && p1op == 65 && (p1arg == onEq || p1arg == onUneq) && (p2op == 64 || p2op == 65)
                && p2arg >= 0 && p2arg < cnt && parser->symtab.table[p2arg] && parser->symtab.table[p2arg]->type == zPAR_TYPE_FUNC)
                roots.insert(p2arg);
            p2op = p1op; p2arg = p1arg;
            p1op = op; p1arg = arg;
            q += len;
        }
        const int equipRoots = (int)roots.size();
        for (const char* nm : { "B_GIVEXP", "B_GIVEPLAYERXP", "B_ADDBONUS", "B_BUYATTRIBUTEPOINTS", "PC_HERO" }) {   // u11: G2 B_GivePlayerXP
            const int i = parser->GetIndex(zSTRING(nm));
            if (i >= 0)
                roots.insert(i);
        }
        for (int i = 0; i < cnt; i++) {
            zCPar_Symbol* s = parser->symtab.table[i];
            if (s && s->type == zPAR_TYPE_FUNC && !strncmp(s->name.ToChar(), "B_TEACH", 7))
                roots.insert(i);
        }
        std::set<int> hero;
        std::vector<int> work(roots.begin(), roots.end());
        while (!work.empty()) {
            const int f = work.back();
            work.pop_back();
            if (!hero.insert(f).second)
                continue;
            auto c = calls.find(f);
            if (c != calls.end())
                work.insert(work.end(), c->second.begin(), c->second.end());
        }
        std::string sample;
        int library = 0;   // u196 (P206)
        for (auto& w : writers)
            for (int o : w.second)
                if (hero.count(o)) {
                    zCPar_Symbol* v = parser->symtab.table[w.first];
                    // u196 (P206): Ikarus/LeGo/GFA/Spine-Interna (NEXTHANDLE, _TIMER, PRINT_SCREEN, SPINE_...) schreiben Helden-Funktionen nur
                    // nebenbei (LoA: Anlege-Funktionen legen Buffs/Leisten an -> LeGo new()). Sie gehoeren zum Skriptstand des geladenen
                    // Spielstands, nicht zum Helden: aus COOPHERO.TXT zurueckgeschrieben passte nach einer Uebernahme der Handle-Zaehler
                    // NEXTHANDLE (151) nicht mehr zur PermMem-Datei des Hosts (Handles bis 180) - neue LeGo-Objekte bekamen belegte
                    // Nummern, LoAs LOA_CHANGEHPBAR (INIT_GLOBAL) griff beim naechsten Laden auf ein fremdes Objekt (zCView::InsertBack,
                    // Absturz LoA u177/u194/u195). Je PC bleiben sie trotzdem (DlgNeverSync). Allgemein (alle Mods mit diesen Paketen).
                    if (DlgScriptLibraryVar(v->name.ToChar())) {
                        library++;
                        break;
                    }
                    StoryHeroVars.insert(v);
                    if (sample.size() < 300)
                        sample += (sample.empty() ? "" : ", ") + std::string(v->name.ToChar());
                    break;
                }
        if (library)
            DialogLog("Heldenwerte: %d Werte von Ikarus/LeGo/GFA/Spine aus Helden-Funktionen ausgelassen - sie gehoeren zum Spielstand (P206)", library);
        int extra = 0;   // u26
        for (const char* nm : StoryHeroVarsExtra) {
            zCPar_Symbol* v = parser->GetSymbol(zSTRING(nm));
            if (v && v->type == zPAR_TYPE_INT && !(v->flags & (zPAR_FLAG_CONST | zPAR_FLAG_CLASSVAR)) && StoryHeroVars.insert(v).second)
                extra++;
        }
        // u197 (P207): "heroVars" des Mod-Profils - Werte des eigenen Helden, die der Aufrufgraph nicht findet (LoA: Talente, Rezepte,
        // Uebung, Erfolge, Boni - geschrieben beim Lesen, Trinken, Benutzen, nicht in Helden-Funktionen). Bis u196 standen sie nur in
        // "perPcVars": nie abgeglichen, aber beim Uebernehmen des Host-Stands (bei jedem Verbinden) kamen die Werte des Hosts.
        int profile = 0;
        for (int i = 0; i < cnt; i++) {
            zCPar_Symbol* v = parser->symtab.table[i];
            if (!v || v->type != zPAR_TYPE_INT || (v->flags & (zPAR_FLAG_CONST | zPAR_FLAG_CLASSVAR | zPAR_FLAG_EXTERNAL)))
                continue;
            const char* nm = v->name.ToChar();
            if (!nm || strchr(nm, '.') || !CoopModHeroVar(nm) || DlgScriptLibraryVar(nm))
                continue;
            if (StoryHeroVars.insert(v).second)
                profile++;
        }
        DialogLog("Heldenwerte: %u globale Variablen gehoeren zum Helden und werden nicht abgeglichen (%d Anlege-/Ablege-Funktionen, "
            "%u im Helden-Kontext, %d aus der festen Liste fuer Gegenstaende/Lesepulte/Rezepte, %d aus dem Mod-Profil), z. B. %s",
            (unsigned)StoryHeroVars.size(), equipRoots, (unsigned)hero.size(), extra, profile, sample.c_str());
    }

    static bool StoryIsHeroVar(zCPar_Symbol* s) {
        if (!StoryHeroVarsBuilt)
            StoryBuildHeroVars();
        return s && StoryHeroVars.count(s) != 0;
    }

    // --- u85 (P110): Gilden je Held - Variante C (docs\GILDEN-KONZEPT.md) --------------------------------------------------
    //
    // Nutzer: "Ok mache C": jeder tritt selbst einer Gilde bei; Gilden-Quests teilen nur Helden derselben Gilde (samt den
    // Gegenstaenden daraus), bei verschiedenen Gilden behaelt jeder seinen eigenen Fortschritt. Bis u84 gingen auch diese Infos an
    // alle - trat einer bei, galt die Aufnahme beim Partner als erzaehlt, und er kam nicht mehr in die Gilde.
    // - Gilden-Info: die Bedingung vergleicht die Gilde des Helden (other/hero.guild oder Npc_GetTrueGuild(other/hero)) mit einer
    //   Gilde ausser GIL_NONE (kleine Auswertung des Bytecodes wie bei den Heldenwerten: Werte auf einem Mini-Stapel, beim
    //   Vergleich == / != zaehlt die Konstante). Nur "keine Gilde" (GIL_NONE) ist keine Gilden-Info - das sind die Wege dorthin, die
    //   bleiben gemeinsam.
    // - Aufnahme: waehrend des Infos aenderte sich die Gilde des Sprechers - beim Partner gilt das Info nie als erzaehlt, er tritt
    //   selbst bei (seine Rüstung bekommt er dann selbst).
    // - Variablen aus solchen Infos gelten danach als Werte je Held: kein Story-Abgleich mehr, nur noch ueber die Infos nach dieser
    //   Regel. Allgemein (G1/G2).
    static std::map<int, std::vector<int>> DlgGuildOfCond;   // Bedingungsfunktion -> verglichene Gilden (leer = keine Gilden-Info)
    static std::set<zCPar_Symbol*> DlgGuildVars;
    static std::set<std::string> DlgGuildInfos;              // u150 (P154): Aufnahme-Infos - ihre Bedingung fragt keine Gilde ab, sie gelten trotzdem je Held
    static std::set<std::string> DlgGuildTopics;             // u150 (P154): Tagebuch-Themen aus Gilden-Infos und Aufnahmen
    static std::map<std::string, std::set<int>> DlgGuildNpcs;   // u152 (P156): NPCs, deren Haltung (und diese Merker) aus Gilden-Infos und Aufnahmen stammen

    // u154 (P159): Stand vor dem ersten Gilden-Info - Wert je Variable und Index, Haltung, Zwischenhaltung und Merker je NPC. Ein Partner, der nie dabei war, bekommt ihn
    // beim Uebernehmen des Host-Stands (CoopHeroGuildMerge). Beim Laden gilt der des geladenen Stands (CoopHeroGuildBaseReset, danach aus COOPHERO.TXT)
    static std::map<std::pair<zCPar_Symbol*, int>, int> DlgGuildVarBase;
    struct CoopGuildNpcBase {
        int att = 0, tatt = 0;
        std::map<int, int> aiv;
    };
    static std::map<std::string, CoopGuildNpcBase> DlgGuildNpcBase;

    static void DlgGuildNpcBaseKeep(const json& jn, int att, int tatt, const int* aiv) {
        if (!jn.is_object() || !jn.contains("n") || !jn["n"].is_string() || !(jn.contains("at") || jn.contains("tt") || jn.contains("a")))
            return;
        auto r = DlgGuildNpcBase.emplace(jn["n"].get<std::string>(), CoopGuildNpcBase());
        if (r.second) {
            r.first->second.att = att;
            r.first->second.tatt = tatt;
        }
        if (jn.contains("a") && jn["a"].is_array())
            for (auto& x : jn["a"])
                if (x.is_array() && !x.empty() && x.at(0).is_number_integer() && x.at(0).get<int>() >= 0 && x.at(0).get<int>() < COOP_AIV_MAX)
                    r.first->second.aiv.emplace(x.at(0).get<int>(), aiv[x.at(0).get<int>()]);
    }

    // u152 (P156): Tritt einer einer Gilde bei, aendert das Gespraech die Haltung ganzer Lager zu seinem Helden (Testlauf Gothic 1: 96 NPCs). Beim Partner gilt das nicht (P110), die Haltung
    // haengt also am Helden. Bis u151 holte der Gesamtstand des Hosts nach jedem Laden sie beim Client wieder auf seinen Stand, und beim Uebernehmen eines Host-Stands kam sie ohnehin von dort.
    static bool DlgGuildNpcHas(const std::string& n) {
        return DlgGuildNpcs.count(n) != 0;
    }

    static void DlgGuildNpcNote(const json& jn) {
        if (!jn.is_object() || !jn.contains("n") || !jn["n"].is_string() || !(jn.contains("at") || jn.contains("tt") || jn.contains("a")))
            return;
        std::set<int>& s = DlgGuildNpcs[jn["n"].get<std::string>()];
        if (jn.contains("a") && jn["a"].is_array())
            for (auto& x : jn["a"])
                if (x.is_array() && !x.empty() && x.at(0).is_number_integer())
                    s.insert(x.at(0).get<int>());
    }

    // Story- und Gesamtstand des Partners lassen die Haltung je Held und die Merker aus Gilden-Infos hier stehen
    static void DlgGuildNpcStrip(json& jn) {
        auto f = DlgGuildNpcs.find(jn.value("n", std::string()));
        if (f == DlgGuildNpcs.end())
            return;
        jn.erase("at");
        jn.erase("tt");
        if (jn.contains("a") && jn["a"].is_array()) {
            json keep = json::array();
            for (auto& x : jn["a"])
                if (!(x.is_array() && !x.empty() && x.at(0).is_number_integer() && f->second.count(x.at(0).get<int>())))
                    keep.push_back(x);
            if (keep.empty())
                jn.erase("a");
            else
                jn["a"] = keep;
        }
    }
    static std::vector<int> DlgFuncStarts;                   // Code-Anfaenge aller Funktionen/Instanzen (Ende einer Bedingung)

    static std::vector<int> DlgGuildCheck(int cond) {
        auto known = DlgGuildOfCond.find(cond);
        if (known != DlgGuildOfCond.end())
            return known->second;
        std::vector<int>& out = DlgGuildOfCond[cond];
        const unsigned char* code = parser ? parser->stack.stack : NULL;
        const int size = parser ? parser->stack.stacksize : 0;
        const int cnt = parser ? parser->symtab.table.GetNum() : 0;
        zCPar_Symbol* cs = cond >= 0 && cond < cnt ? parser->symtab.table[cond] : NULL;
        if (!code || size <= 0 || !cs || cs->type != zPAR_TYPE_FUNC)
            return out;
        if (DlgFuncStarts.empty()) {
            for (int i = 0; i < cnt; i++) {
                zCPar_Symbol* s = parser->symtab.table[i];
                if (s && !(s->flags & (zPAR_FLAG_EXTERNAL | zPAR_FLAG_CLASSVAR)) &&
                    (s->type == zPAR_TYPE_FUNC || s->type == zPAR_TYPE_PROTOTYPE || s->type == zPAR_TYPE_INSTANCE) &&
                    s->single_intdata >= 0 && s->single_intdata < size)
                    DlgFuncStarts.push_back(s->single_intdata);
            }
            std::sort(DlgFuncStarts.begin(), DlgFuncStarts.end());
        }
        const int start = cs->single_intdata;
        if (start < 0 || start >= size)
            return out;
        auto nx = std::upper_bound(DlgFuncStarts.begin(), DlgFuncStarts.end(), start);
        const int end = nx == DlgFuncStarts.end() ? size : *nx;
        static int symOther = -2, symHero, symGuild, symTrueGuild;
        if (symOther == -2) {
            symOther = parser->GetIndex(zSTRING("OTHER"));
            symHero = parser->GetIndex(zSTRING("HERO"));
            symGuild = parser->GetIndex(zSTRING("C_NPC.GUILD"));
            symTrueGuild = parser->GetIndex(zSTRING("NPC_GETTRUEGUILD"));
        }
        // Mini-Stapel: 1 = Gilde des Helden, 2 = Konstante (Wert), 3 = Instanz Held, 0 = anderes
        std::vector<std::pair<int, int>> st;
        int inst = -1;
        std::set<int> found;
        for (int q = start; q < end;) {
            const unsigned char op = code[q];
            int arg = 0, len = 1;
            if (op == 61 || op == 62 || op == 64 || op == 65 || op == 67 || op == 75 || op == 76 || op == 80) {
                if (q + 5 > end)
                    break;
                arg = *(const int*)(code + q + 1);
                len = 5;
            }
            else if (op == 245) {
                if (q + 6 > end)
                    break;
                arg = *(const int*)(code + q + 1);
                len = 6;
            }
            q += len;
            if (op == 80)   // SETINSTANCE
                inst = arg;
            else if (op == 64)   // PUSHINT
                st.push_back({ 2, arg });
            else if (op == 65) {   // PUSHVAR
                zCPar_Symbol* s = arg >= 0 && arg < cnt ? parser->symtab.table[arg] : NULL;
                int v = 0;
                if (arg == symGuild && (inst == symOther || inst == symHero))
                    st.push_back({ 1, 0 });
                else if (s && (s->flags & zPAR_FLAG_CONST) && s->type == zPAR_TYPE_INT && (s->GetValue(v, 0), true))
                    st.push_back({ 2, v });
                else
                    st.push_back({ 0, 0 });
            }
            else if (op == 67)   // PUSHINST
                st.push_back({ (arg == symOther || arg == symHero) ? 3 : 0, 0 });
            else if (op == 62 && arg == symTrueGuild && !st.empty() && st.back().first == 3) {   // Npc_GetTrueGuild(Held)
                st.pop_back();
                st.push_back({ 1, 0 });
            }
            else if (op <= 8 || (op >= 11 && op <= 18)) {   // zweistellige Operatoren mit Ergebnis (9, 19-22 sind Zuweisungen)
                if (st.size() >= 2) {
                    const auto b = st.back();
                    st.pop_back();
                    const auto a = st.back();
                    st.pop_back();
                    if ((op == 16 || op == 17) && ((a.first == 1 && b.first == 2) || (a.first == 2 && b.first == 1)))
                        found.insert(a.first == 2 ? a.second : b.second);
                }
                else
                    st.clear();
                st.push_back({ 0, 0 });
            }
            else if (op >= 30 && op <= 33) {   // einstellige
                if (!st.empty())
                    st.pop_back();
                st.push_back({ 0, 0 });
            }
            else   // Aufruf, Sprung, Zuweisung, Rueckgabe - neu anfangen
                st.clear();
        }
        found.erase(0);   // GIL_NONE allein: Weg in eine Gilde, gemeinsam
        out.assign(found.begin(), found.end());
        return out;
    }

    static std::vector<int> DlgGuildOfInfo(oCInfo* info) {
        return info ? DlgGuildCheck(info->pd.conditions) : std::vector<int>();
    }

    static std::string DlgGuildText(const std::vector<int>& g) {
        std::string s;
        for (int x : g)
            s += (s.empty() ? "" : "/") + std::to_string(x);
        return s.empty() ? "-" : s;
    }

    // einmal je Skriptstand: wie viele Infos zaehlen als Gilden-Infos (Pruefung der Erkennung im Log)
    static void DlgGuildSurvey() {
        static bool done = false;
        if (done || !ogame || !ogame->GetInfoManager() || !parser)
            return;
        done = true;
        int all = 0, guild = 0;
        std::string sample;
        for (auto* l = ogame->GetInfoManager()->infoList.GetNextInList(); l; l = l->GetNextInList()) {
            oCInfo* info = l->GetData();
            if (!info)
                continue;
            all++;
            const std::vector<int> g = DlgGuildOfInfo(info);
            if (g.empty())
                continue;
            guild++;
            if (sample.size() < 400)
                sample += (sample.empty() ? "" : ", ") + std::string(info->name.ToChar()) + " (" + DlgGuildText(g) + ")";
        }
        DialogLog("Gilden je Held (u85): %d von %d Infos fragen eine Gilde des Helden ab - die teilen nur Helden dieser Gilde; z. B. %s",
            guild, all, sample.empty() ? "-" : sample.c_str());
    }

    // u15 (CoopSaveSync.cpp, G2): Heldenwerte des eigenen Helden fuer COOPHERO.TXT - beim Uebernehmen eines fremden Stands kaemen
    // sonst dessen Werte (G2: PLAYER_TALENT_ALCHEMY/SMITH/RUNES/TAKEANIMALTROPHY/FOREIGNLANGUAGE/WISPDETECTOR ueber B_Teach*)
    void CoopHeroVarsCapture(std::vector<std::pair<std::string, int>>& out) {
        out.clear();
        if (!parser)
            return;
        if (!StoryHeroVarsBuilt)
            StoryBuildHeroVars();
        for (zCPar_Symbol* s : StoryHeroVars) {
            if (!s || s->type != zPAR_TYPE_INT)
                continue;
            const int ele = s->ele > 1 ? (int)s->ele : 1;
            for (int k = 0; k < ele && k < 256; k++) {
                int v = 0;
                s->GetValue(v, k);
                out.push_back({ ele > 1 ? std::string(s->name.ToChar()) + "[" + std::to_string(k) + "]" : std::string(s->name.ToChar()), v });
            }
        }
    }

    int CoopHeroVarsApply(const std::vector<std::pair<std::string, int>>& in) {
        if (!parser)
            return 0;
        int n = 0;
        for (auto const& e : in) {
            std::string nm = e.first;
            int k = 0;
            const size_t br = nm.find('[');
            if (br != std::string::npos) {
                k = atoi(nm.c_str() + br + 1);
                nm.erase(br);
            }
            zCPar_Symbol* s = parser->GetSymbol(zSTRING(nm.c_str()));
            const int ele = s && s->ele > 1 ? (int)s->ele : 1;
            if (!s || s->type != zPAR_TYPE_INT || k < 0 || k >= ele || !StoryIsHeroVar(s))   // nur, was hier auch Heldenwert ist
                continue;
            s->SetValue(e.second, k);
            n++;
        }
        return n;
    }

    // u11 (G2): Zustand dieses PCs, nie abgleichen - weder im Dialog-Fortschritt noch im Story-Takt noch beim Uebernehmen.
    // u13 (Testlauf u12, Schritt 59: "ZSTALKBUGFIX hier 1, Partner 0"): ZsTalkBugfix ist G2s Merker aus ZS_Talk_Loop
    // (ZsTalkBugfix == TRUE && InfoManager_HasFinished()) - gilt nur auf dem PC, auf dem das Gespraech laeuft.
    // u31 (P72; Testlauf u30: "ENTEROW_KAPITEL1: hier 1, Partner 0"): die Merker der Welt-Eintritts-Skripte (G2 B_Enter_OldWorld/
    // _NewWorld/_AddonWorld: EnterOW_Kapitel1-6, EnterNW_/EnterADW_Kapitel2-6, EnterDI_Kapitel6; Erstbetritt-Trigger
    // ENTER_OLDWORLD_/ENTER_ADDONWORLD_FIRSTTIME_TRIGGER_ONETIME) gehoeren zum Weltstand dieses PCs - sie schuetzen, was beim ersten
    // Betreten in DIESER Welt geschieht (B_KillNpc, B_RemoveNpc, Tagesablaeufe). Abgeglichen liefen die Skripte beim Partner nie, der
    // seine eigene Kopie der Welt erst spaeter betritt (seit u29 getrennte Welten).
    // u134 (P130, G1/Othello; Welten-Testlauf G1: "ENTEREDFREEMINE: hier 0, Partner 1"): dasselbe in Gothic 1 - STARTUP_OLDMINE und
    // STARTUP_FREEMINE setzen EnteredOldMine/EnteredFreeMine, wenn dieser PC die Mine zum ersten Mal laedt.
    // u140 (P139; Testlauf u136 + b74, Minental in Kapitel 4): Seit P88/P81 kommt die Weltdatei oft vom Partner, samt allem, was dessen
    // B_Enter_* dort eingesetzt hat - der eigene Merker stand aber auf 0, das Skript lief ein zweites Mal auf derselben Welt: zwei Sylvios am
    // selben Wegpunkt, 1111 statt 820 NPCs, und weil die Namen dadurch verschieden wurden, liefen auch diese NPCs nicht mehr im Abgleich.
    // Die Merker gehoeren also zur Datei: Wer die Weltdatei eines Partners nimmt, nimmt auch dessen Merker dieser Welt (CoopSaveSync.cpp
    // WxApply, im Slot COOPMERKER_<Welt>.TXT). Wer seine eigene Datei behaelt, behaelt seine eigenen.
    const char* CoopModWorldVar(const char* nm);   // u200 (P224): Mods\CoopMods.cpp - "worldVars" des Mod-Profils

    static const char* DlgWorldEntryVarWorld(const char* nm) {   // Welt wie WxWorldTag (ohne Pfad und Endung), NULL = kein Merker
        if (const char* w = CoopModWorldVar(nm))   // u200 (P224): reine Waechter aus Welt-Inits einer Mod (LoA: Goldmine, Wueste, Tempel)
            return w;
        static const struct { const char* name; const char* world; } list[] = {
            { "ENTEROW_KAPITEL", "OLDWORLD" }, { "ENTER_OLDWORLD_FIRSTTIME_TRIGGER_ONETIME", "OLDWORLD" }, { "ENTERNW_KAPITEL", "NEWWORLD" },
            { "ENTERADW_KAPITEL", "ADDONWORLD" }, { "ENTER_ADDONWORLD_FIRSTTIME_TRIGGER_ONETIME", "ADDONWORLD" }, { "ENTERDI_KAPITEL", "DRAGONISLAND" },
            { "ENTEREDOLDMINE", "OLDMINE" }, { "ENTEREDFREEMINE", "FREEMINE" } };
        for (auto& e : list)
            if (!strncmp(nm, e.name, strlen(e.name)))
                return e.world;
        return NULL;
    }

    static bool DlgWorldEntryVar(const char* nm) {
        return DlgWorldEntryVarWorld(nm) != NULL;
    }

    // u140 (P139): Merker einer Welt als [[Name, Wert], ...]; u141: je Sekunde gefragt (StoryEntryTick), darum die Liste nur einmal bilden
    static std::vector<std::pair<zCPar_Symbol*, const char*>> DlgEntrySyms;
    static int DlgEntrySymCount = -1;

    json CoopWorldEntryVarsGet(const std::string& world) {
        json out = json::array();
        const int cnt = parser ? parser->symtab.table.GetNum() : 0;
        if (cnt != DlgEntrySymCount) {
            DlgEntrySymCount = cnt;
            DlgEntrySyms.clear();
            for (int i = 0; i < cnt; i++) {
                zCPar_Symbol* s = parser->symtab.table[i];
                if (!s || s->type != zPAR_TYPE_INT || (s->flags & (zPAR_FLAG_CONST | zPAR_FLAG_CLASSVAR)) || s->ele > 1)
                    continue;
                if (const char* w = DlgWorldEntryVarWorld(s->name.ToChar()))
                    DlgEntrySyms.push_back(std::make_pair(s, w));
            }
        }
        for (auto& e : DlgEntrySyms)
            if (world == e.second) {
                int v = 0;
                e.first->GetValue(v, 0);
                out.push_back({ e.first->name.ToChar(), v });
            }
        return out;
    }

    // Anzahl geaenderter Merker; nur Merker dieser Welt. raiseOnly (u141): der Partner in derselben Welt - nur von 0 auf gesetzt
    int CoopWorldEntryVarsSet(const json& vars, const std::string& world, bool raiseOnly) {
        int n = 0;
        std::string names;
        if (parser && vars.is_array())
            for (auto& v : vars) {
                if (!v.is_array() || v.size() != 2 || !v.at(0).is_string() || !v.at(1).is_number_integer())
                    continue;
                const std::string nm = v.at(0).get<std::string>();
                const char* w = DlgWorldEntryVarWorld(nm.c_str());
                zCPar_Symbol* s = w && world == w ? parser->GetSymbol(zSTRING(nm.c_str())) : NULL;
                if (!s || s->type != zPAR_TYPE_INT || (s->flags & zPAR_FLAG_CONST))
                    continue;
                int old = 0;
                s->GetValue(old, 0);
                const int val = v.at(1).get<int>();
                if (old == val || (raiseOnly && val < old))
                    continue;
                s->SetValue(val, 0);
                n++;
                names += (names.empty() ? "" : ", ") + nm + "=" + std::to_string(val);
            }
        if (n)
            DialogLog("Eintritts-Merker von %s %s uebernommen: %s", world.c_str(), raiseOnly ? "vom Partner in derselben Welt" : "mit der Weltdatei", names.c_str());
        return n;
    }

    // u188 (P190): Ikarus und LeGo (viele Mods, z. B. Legend of Ahssun) halten in globalen Ganzzahlen Zeiger, Zaehler und den Zustand
    // des eigenen PCs. Betroffen sind interne Namen mit "_" (LeGo: _BIN_CRSR, _BIN_MODE, _BAR_SCREEN_X, _TIMER_PIM), Ikarus MEM_ und
    // MEMINT_ sowie die LeGo-Pakete Cursor (CURSOR_X ...) und Gamestate (GAMESTATE). Der Story-Abgleich schickte sie zum Partner
    // (LoA-Logs: "_BIN_CRSR=6873, GAMESTATE=3", "CURSOR_X=2"), die Pruefrunde meldete sie als abweichend. Die Regel gilt nur, wenn die
    // Skripte Ikarus oder LeGo enthalten (MEM_INITALL / LEGO_INIT). Die Original-Skripte haben keine solchen Ganzzahlen, nur
    // _STR_-Konstanten. Allgemein (alle Ikarus/LeGo-Mods).
    // u195 (P197): dazu die uebrigen Werte dieser Pakete und zwei weitere Bibliotheken, die viele Mods mitbringen (LoA-Logs u189-u194:
    // "GFA_BOWDRAWONSET" 237-mal zum Partner, Zeiger und Handles ohne grosse Werte rutschen am Zeiger-Filter vorbei). Je PC bleiben:
    //  - Ikarus: INSTRINT_ (Instrumentierung)
    //  - LeGo: NEXTHANDLE und PM_ (PermMem - der Partnerwert zerstoert die eigenen Handles), PRINT_ (Bildschirmmasse), BUFF_ und
    //    BUFFLIST_ (Buffs, Anzeigen), TRIA_ (Trialoge, NPC-Zeiger)
    //  - Gothic Free Aim (GFA_INIT): GFA_ - Zielen, Spannen, Mausbewegung, Zeitstempel
    //  - Spine (SPINE_INIT): SPINE_ - Funktionszeiger der Spine-DLL, Erfolgs-Anzeigen, lokaler Erfolgsstand
    // Allgemein (alle Mods mit diesen Paketen); Original-Skripte haben keine solchen Namen.
    static bool DlgScriptLibraryVar(const char* nm) {
        static zCParser* cached = NULL;
        static bool lib = false, lego = false, gfa = false, spine = false;
        if (cached != parser) {
            cached = parser;
            lego = parser && parser->GetIndex(zSTRING("LEGO_INIT")) >= 0;
            lib = lego || (parser && parser->GetIndex(zSTRING("MEM_INITALL")) >= 0);
            gfa = parser && parser->GetIndex(zSTRING("GFA_INIT")) >= 0;
            spine = parser && parser->GetIndex(zSTRING("SPINE_INIT")) >= 0;
            if (lib || gfa || spine)
                DialogLog("Skripte mit %s%s%s%s: deren Ganzzahlen bleiben je PC (_..., MEM_, MEMINT_, INSTRINT_, CURSOR_, GAMESTATE%s%s%s; P190, P197)",
                    lib ? "Ikarus" : "", lego ? "/LeGo" : "", gfa ? ", Gothic Free Aim" : "", spine ? ", Spine" : "",
                    lego ? ", NEXTHANDLE, PM_, PRINT_, BUFF_, BUFFLIST_, TRIA_" : "", gfa ? ", GFA_" : "", spine ? ", SPINE_" : "");
        }
        if (!nm)
            return false;
        if (lib && (nm[0] == '_' || !strncmp(nm, "MEM_", 4) || !strncmp(nm, "MEMINT_", 7) || !strncmp(nm, "INSTRINT_", 9) ||
            !strncmp(nm, "CURSOR_", 7) || !strcmp(nm, "GAMESTATE")))
            return true;
        if (lego && (!strcmp(nm, "NEXTHANDLE") || !strncmp(nm, "PM_", 3) || !strncmp(nm, "PRINT_", 6) || !strncmp(nm, "BUFF_", 5) ||
            !strncmp(nm, "BUFFLIST_", 9) || !strncmp(nm, "TRIA_", 5)))
            return true;
        return (gfa && !strncmp(nm, "GFA_", 4)) || (spine && !strncmp(nm, "SPINE_", 6));
    }

    bool CoopModNeverSync(const char* nm);   // Mods\CoopMods.cpp (u188, P190): Werte je PC, die nur eine Mod kennt
    bool CoopModDeltaVar(const char* nm);    // Mods\CoopMods.cpp (u199, P213): Zaehler, die als Aenderung abgeglichen werden

    // u199 (P213): Eintrag fuer den Abgleich - bei Zaehlern aus "deltaVars" mit dem alten Wert (der Empfaenger rechnet die Aenderung)
    static json DlgVarEntry(zCPar_Symbol* sym, int idx, int cur, int old) {
        if (CoopModDeltaVar(sym->name.ToChar()))
            return json::array({ sym->name.ToChar(), idx, cur, old });
        return json::array({ sym->name.ToChar(), idx, cur });
    }

    // u97: COOP_TRUHE_OEFFNEN - Merker "Coop-Truhe benutzt" (COOP_ITEMS.D) gilt nur auf diesem PC
    static bool DlgNeverSync(const char* nm) {
        return nm && (!strncmp(nm, "FUNL_", 5) /* u203: Fun-Modus, je PC */ || !strcmp(nm, "PLAYER_MOBSI_PRODUCTION") || !strcmp(nm, "CURRENTLEVEL") || !strcmp(nm, "HERO_HACKCHANCE")
            || !strcmp(nm, "ZSTALKBUGFIX") || !strcmp(nm, "COOP_TRUHE_OEFFNEN") || DlgWorldEntryVar(nm) || DlgScriptLibraryVar(nm) ||
            CoopModNeverSync(nm));
    }

    static void DlgBuildIntSlots() {
        const int cnt = parser ? parser->symtab.table.GetNum() : 0;
        if (cnt == DlgIntSymCount)
            return;
        DlgIntSlots.clear();
        DlgSlotIndex.clear();
        StoryReady = false;   // Platzliste neu -> Vergleichsstand neu aufnehmen
        for (int i = 0; i < cnt; i++) {
            zCPar_Symbol* sym = parser->symtab.table[i];
            if (!sym || sym->type != zPAR_TYPE_INT || (sym->flags & (zPAR_FLAG_CONST | zPAR_FLAG_CLASSVAR | zPAR_FLAG_EXTERNAL)))
                continue;
            const char* nm = sym->name.ToChar();
            if (!nm || !*nm || strchr(nm, '.'))
                continue;   // lokale Variablen (FUNKTION.NAME)
            if (StoryIsHeroVar(sym) || DlgNeverSync(nm))
                continue;   // v31: Zustand des eigenen Helden (Ausruestung, Boni); u11: je PC (G2)
            const int ele = sym->ele > 1 ? (int)sym->ele : 1;
            for (int k = 0; k < ele; k++) {
                DlgSlotIndex[std::make_pair(sym, k)] = (int)DlgIntSlots.size();
                DlgIntSlots.push_back({ sym, k });
            }
        }
        DlgIntSymCount = cnt;
        DialogLog("%u Skript-Ganzzahlen werden fuer den Dialog-Fortschritt verglichen", (unsigned)DlgIntSlots.size());
    }

    static void DlgSnapLog(std::vector<CoopDlgTopic>& out) {
        oCLogManager& lm = oCLogManager::GetLogManager();
        for (auto* it = lm.m_lstTopics.GetNextInList(); it; it = it->GetNextInList()) {
            oCLogTopic* t = it->GetData();
            if (!t)
                continue;
            CoopDlgTopic s;
            s.t = t->m_strDescription.ToChar();
            s.sec = (int)t->m_enuSection;
            s.st = (int)t->m_enuStatus;
            for (auto* e = t->m_lstEntries.GetNextInList(); e; e = e->GetNextInList())
                if (oCLogEntry* le = e->GetData())
                    s.e.push_back(le->m_strDescription.ToChar());
            out.push_back(s);
        }
    }

    static void DlgSnapshot(CoopDlgSnap& s) {
        DlgBuildIntSlots();
        s.ints.resize(DlgIntSlots.size());
        for (size_t i = 0; i < DlgIntSlots.size(); i++) {
            int v = 0;
            DlgIntSlots[i].sym->GetValue(v, DlgIntSlots[i].idx);
            s.ints[i] = v;
        }
        DlgSnapLog(s.log);
        s.exp = player ? (long long)player->experience_points : 0;
        s.guild = player ? player->guild : 0;
        if (player) {   // u85
            player->inventory2.UnpackAllItems();
#if ENGINE >= Engine_G2
            for (zCListSort<oCItem>* n = player->inventory2.inventory.next; n; n = n->next)
                if (n->data)
                    s.inv[n->data->GetInstanceName().ToChar()] += n->data->amount;
#else
            for (int c = 0; c < INV_MAX; c++)
                for (zCListSort<oCItem>* n = player->inventory2.inventory[c].next; n; n = n->next)
                    if (n->data)
                        s.inv[n->data->GetInstanceName().ToChar()] += n->data->amount;
#endif
        }
        for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l; l = l->next) {
            oCNpc* npc = l->data;
            if (!npc || npc == player || IsCoopPlayer(npc->GetObjectName()) || !NpcToUniqueNameList.count(npc))
                continue;
            CoopDlgNpc n;
            n.npc = npc;
            memcpy(n.aiv, npc->aiscriptvars, sizeof(n.aiv));
            n.att = npc->attitude;
            n.tatt = npc->tmp_attitude;
            n.rtn = npc->daily_routine;
            n.f = DlgNpcFields(npc);
            s.npcs.push_back(n);
        }
    }

    // Tagebuch-Thema vorher (oder NULL = neu) gegen jetzt; Unterschied als {t, c, s?, e[]}. AddEntry haengt hinten an:
    // Listenfolge = zeitliche Folge.
    static bool DlgTopicDiff(const CoopDlgTopic* before, const CoopDlgTopic& now, json& jt) {
        jt = json();
        jt["t"] = now.t;
        jt["c"] = now.sec;
        bool changed = !before;
        std::set<std::string> old;
        if (before)
            old.insert(before->e.begin(), before->e.end());
        if (!before || before->st != now.st) {
            jt["s"] = now.st;
            changed = true;
        }
        json e = json::array();
        for (auto& s : now.e)
            if (!old.count(s)) {
                e.push_back(s);
                changed = true;
            }
        jt["e"] = e;
        return changed;
    }

    static void DlgSendDiff(const CoopDlgSnap& a, const CoopDlgSnap& b, const std::string& info, const char* what, oCInfo* gInfo = NULL,
        const std::vector<int>* giTest = NULL) {
        // u85: Gilden-Info (Bedingung des Infos bzw. bei einer Auswahl des laufenden Infos), Aufnahme, Belohnung daraus.
        // u86: giTest - abgefragte Gilden vorgegeben (Coop-Testlauf, Schritte "Gilden je Held")
        const std::vector<int> gi = giTest ? *giTest : DlgGuildOfInfo(gInfo);
        const bool join = b.guild != a.guild;
        json items = json::array();
        if (!gi.empty() && !(gInfo && gInfo->pd.trade))
            for (auto& x : b.inv) {
                auto f = a.inv.find(x.first);
                const int got = x.second - (f == a.inv.end() ? 0 : f->second);
                if (got > 0)
                    items.push_back({ x.first, got });
            }
        if (!gi.empty() || join)   // ihre Variablen gelten je Held - nie im Story-Abgleich
            for (size_t i = 0; i < b.ints.size() && i < a.ints.size() && i < DlgIntSlots.size(); i++)
                if (a.ints[i] != b.ints[i]) {
                    DlgGuildVars.insert(DlgIntSlots[i].sym);
                    DlgGuildVarBase.emplace(std::make_pair(DlgIntSlots[i].sym, DlgIntSlots[i].idx), a.ints[i]);   // u154 (P159)
                }
        if (join && !info.empty())
            DlgGuildInfos.insert(info);
        json j;
        int nv = 0, nl = 0, np = 0;
        json v = json::array();
        for (size_t i = 0; i < b.ints.size() && i < a.ints.size(); i++)
            if (a.ints[i] != b.ints[i] && StoryValueOk(a.ints[i]) && StoryValueOk(b.ints[i])) {
                // u199 (P213): bei Zaehlern ab dem Story-Vergleichsstand - StoryAbsorb setzt ihn danach auf b, eine noch nicht gesendete
                // Aenderung vor dem Gespraech ginge sonst verloren
                v.push_back(DlgVarEntry(DlgIntSlots[i].sym, DlgIntSlots[i].idx, b.ints[i],
                    StoryReady && i < StoryBaseInts.size() && StoryBaseInts.size() == b.ints.size() ? StoryBaseInts[i] : a.ints[i]));
                nv++;
            }
        json l = json::array();
        std::map<std::string, const CoopDlgTopic*> before;
        for (auto& t : a.log)
            before[t.t] = &t;
        for (auto& t : b.log) {
            auto f = before.find(t.t);
            json jt;
            if (!DlgTopicDiff(f == before.end() ? NULL : f->second, t, jt))
                continue;
            if (!gi.empty() || join)
                DlgGuildTopics.insert(t.t);
            l.push_back(jt);
            nl++;
        }
        json p = json::array();
        std::map<oCNpc*, const CoopDlgNpc*> nb;
        for (auto& n : a.npcs)
            nb[n.npc] = &n;
        for (auto& n : b.npcs) {
            auto f = nb.find(n.npc);
            if (f == nb.end())
                continue;
            const CoopDlgNpc& o = *f->second;
            json jn;
            json av = json::array();
            for (int i = 0; i < COOP_AIV_MAX; i++)
                if (o.aiv[i] != n.aiv[i])
                    av.push_back({ i, n.aiv[i] });
            if (!av.empty())
                jn["a"] = av;
            if (o.att != n.att)
                jn["at"] = n.att;
            if (o.tatt != n.tatt)
                jn["tt"] = n.tatt;
            if (o.rtn != n.rtn) {
                zCPar_Symbol* rs = parser->GetSymbol(n.rtn);
                if (rs)
                    jn["r"] = rs->name.ToChar();
            }
            DlgNpcFieldsDiff(o.f, n.f, jn);
            if (jn.empty())
                continue;
            jn["n"] = DialogNpcName(n.npc);
            if (!gi.empty() || join) {   // u152 (P156), u154 (P159): mit dem Stand davor
                DlgGuildNpcNote(jn);
                DlgGuildNpcBaseKeep(jn, o.att, o.tatt, o.aiv);
            }
            p.push_back(jn);
            np++;
        }
        // v31: Quest-EP - was der eigene Held waehrend des Dialogskripts an Erfahrung bekam (Kampf-EP laufen nicht hier)
        const long long xp = b.exp > a.exp ? b.exp - a.exp : 0;
        json ni = json::array();   // u163 (P170): Inventar von Welt-NPCs aus dem Skript
        std::string niText;
        for (auto& x : DlgInvChanges)
            if (x.second) {
                ni.push_back({ x.first.first, x.first.second, x.second });
                if (niText.size() < 200)
                    niText += (niText.empty() ? "" : ", ") + x.first.first + " " + (x.second > 0 ? "+" : "") + std::to_string(x.second) + " " + x.first.second;
            }
        DlgInvChanges.clear();
        if (info.empty() && !nv && !nl && !np && !xp && items.empty() && !join && ni.empty())
            return;
        if (!info.empty())
            j["i"] = info;
        j["n"] = MyDialogNpc;
        if (nv)
            j["v"] = v;
        if (nl)
            j["l"] = l;
        if (np)
            j["p"] = p;
        if (xp > 0 && xp < 1000000)
            j["xp"] = (int)xp;
        j["hg"] = b.guild;   // u85: Gilde des Sprechers
        if (!gi.empty())
            j["gi"] = gi;
        if (join)
            j["join"] = b.guild;
        if (!items.empty())
            j["it"] = items;
        if (!ni.empty())
            j["ni"] = ni;
        DialogSend(j, SYNC_DIALOG_STATE);
        DialogLog("Fortschritt (%s %s): %d Variablen, %d Tagebuch-Themen, %d NPCs, %d EP%s%s%s%s -> Partner", what,
            info.empty() ? "-" : info.c_str(), nv, nl, np, (int)xp,
            gi.empty() ? "" : (" - Gilden-Info (Gilde " + DlgGuildText(gi) + ")").c_str(),
            join ? (" - Aufnahme in Gilde " + std::to_string(b.guild) + " (beim Partner nicht erzaehlt)").c_str() : "",
            items.empty() ? "" : (" - " + std::to_string(items.size()) + " Gegenstandsarten als Belohnung").c_str(),
            ni.empty() ? "" : (" - Inventar von NPCs (" + std::to_string(ni.size()) + "): " + niText).c_str());
    }

    static bool StoryNpcSkip(oCNpc* npc) {
        return !npc || npc == player || IsCoopPlayer(npc->GetObjectName());
    }

    static void StorySnapNpcs() {
        StoryBaseNpc.clear();
        for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l; l = l->next) {
            oCNpc* npc = l->data;
            if (StoryNpcSkip(npc))
                continue;
            const std::string n = DialogNpcName(npc);
            if (!n.empty())
                StoryBaseNpc[n] = { npc->daily_routine, npc->attitude, DlgNpcFields(npc) };
        }
    }

    // oCGuilds: Tabelle size x size Bytes, Eintrag (g1, g2) bei attitude[g2 * size + g1] (oCGuilds::SetAttitude 0x00663340;
    // Othello hat dort nur die Grenzpruefung "< 42" entfernt - mehr Gilden).
    static void StorySnapGuilds() {
        oCGuilds* g = ogame ? ogame->GetGuilds() : NULL;
        if (!g || !g->attitude || g->size <= 0 || g->size > 256) {
            StoryGuildSize = 0;
            StoryBaseGuilds.clear();
            return;
        }
        StoryGuildSize = g->size;
        StoryBaseGuilds.assign(g->attitude, g->attitude + g->size * g->size);
    }

    // Was der Dialog geaendert und schon gesendet hat, in den Story-Vergleichsstand uebernehmen (sonst schickte der
    // naechste Story-Takt es noch einmal). Nur die Aenderungen a -> b, damit Aenderungen davor weiter gesendet werden.
    static void StoryAbsorb(const CoopDlgSnap& a, const CoopDlgSnap& b) {
        if (!StoryReady || StoryBaseInts.size() != b.ints.size() || a.ints.size() != b.ints.size())
            return;
        std::map<oCNpc*, const CoopDlgNpc*> na;   // v31: NPC-Tagesablauf/Haltung aus dem Dialog
        for (auto& n : a.npcs)
            na[n.npc] = &n;
        for (auto& n : b.npcs) {
            auto f = na.find(n.npc);
            if (f == na.end() || (f->second->rtn == n.rtn && f->second->att == n.att && DlgNpcFieldsSame(f->second->f, n.f)))
                continue;
            const std::string nm = DialogNpcName(n.npc);
            if (!nm.empty())
                StoryBaseNpc[nm] = { n.rtn, n.att, n.f };
        }
        for (size_t i = 0; i < b.ints.size(); i++)
            if (a.ints[i] != b.ints[i])
                StoryBaseInts[i] = b.ints[i];
        std::map<std::string, const CoopDlgTopic*> before;
        for (auto& t : a.log)
            before[t.t] = &t;
        for (auto& t : b.log) {
            auto f = before.find(t.t);
            json jt;
            if (!DlgTopicDiff(f == before.end() ? NULL : f->second, t, jt))
                continue;
            auto bt = StoryBaseLog.find(t.t);
            if (bt == StoryBaseLog.end()) {
                StoryBaseLog[t.t] = t;
                continue;
            }
            if (jt.contains("s"))
                bt->second.st = t.st;
            std::set<std::string> have(bt->second.e.begin(), bt->second.e.end());
            for (auto& s : jt["e"])
                if (!have.count(s.get<std::string>()))
                    bt->second.e.push_back(s.get<std::string>());
        }
    }

    static bool DlgOwnDialog(oCInformationManager* im) {
        return im && im->Player == player && DialogSyncAktiv() && parser;
    }

    // --- Zuschauer-Seite ---------------------------------------------------------------------------

    static bool DialogDarfAnhalten(oCNpc* npc) {
        return npc && npc != MyDialogNpcPtr && npc != player && !npc->IsDead() && npc->GetWeaponMode() == NPC_WEAPON_NONE;
    }

    static void DialogFreezeStart(const std::string& n, const std::string& by) {
        oCNpc* npc = DialogNpcByName(n);
        if (!npc) {
            DialogLog("NPC %s hier nicht vorhanden - nur gesperrt", n.c_str());
            return;
        }
        if (!DialogDarfAnhalten(npc)) {
            DialogLog("NPC %s nicht angehalten (eigener Dialog, tot oder Waffe gezogen)", n.c_str());
            return;
        }
        oCNpc* fig = DialogFigureOf(by);
        DialogInjecting++;
        npc->ClearEM();
        // kein Gespraechspartner: EV_PlaySound waehlt sonst den NPC-NPC-Untertitel (Art 2) statt Umgebung (Art 5)
        npc->StopTalkingWith();
        if (fig && fig->GetTalkingWith() != player)
            fig->StopTalkingWith();
        if (fig)
            npc->GetEM()->OnMessage(new oCMsgMovement(oCMsgMovement::EV_TURNTOVOB, (zCVob*)fig), npc);
        DialogInjecting--;
        DialogFrozen.insert(npc);
    }

    // Zeile abspielen. Ziel bewusst NULL: EV_Output nimmt dann den Monolog-Weg (kein StartTalkingWith - der eigene
    // Held bleibt unberuehrt), und EV_PlaySound zeigt den Untertitel wie bei Umgebungsgespraechen (Art 5, Ansicht
    // ogame+0x44, Farbe orange-rot 0x8DB480) statt als NPC-NPC-Text (Art 2, weiss). Die Reihenfolge NPC/Held, die
    // sonst EV_Output ueber das Ziel herstellt, uebernimmt DialogLineQueue.
    static bool DialogInjectLine(const std::string& n, const CoopDialogQueuedLine& l) {
        oCNpc* npc = DialogNpcByName(n);
        oCNpc* fig = DialogFigureOf(l.by);
        oCNpc* speaker = l.s == "h" ? fig : npc;
        if (!speaker) {
            DialogLog("Zeile %s von %s: %s hier nicht vorhanden", l.o.c_str(), l.by.c_str(), !fig ? "Coop-Figur" : n.c_str());
            return false;
        }
        const zVEC3 d = speaker->GetPositionWorld() - player->GetPositionWorld();
        if (d.Length() > DIALOG_HEAR_RANGE)
            return false;
        oCMsgConversation* msg = new oCMsgConversation(l.svm ? oCMsgConversation::EV_OUTPUTSVM : oCMsgConversation::EV_OUTPUT, zSTRING(l.o.c_str()));
        msg->target = NULL;
        DialogInjecting++;
        speaker->GetEM()->OnMessage(msg, speaker);
        DialogInjecting--;
        return true;
    }

    // naechste wartende Zeile starten, sobald NPC und Figur still sind (und die vorige mindestens 300 ms lief -
    // die Ton-Nachricht der Ausgabe-Einheit erscheint erst nach EV_Output)
    static void DialogPumpLines(const std::string& n) {
        auto q = DialogLineQueue.find(n);
        if (q == DialogLineQueue.end() || q->second.empty())
            return;
        if (CurrentMs < DialogLastInjectMs[n] + 300)
            return;
        const CoopDialogQueuedLine& l = q->second.front();
        if (DialogSpeaking(DialogNpcByName(n)) || DialogSpeaking(DialogFigureOf(l.by)))
            return;
        const CoopDialogQueuedLine line = l;
        q->second.pop_front();
        if (DialogInjectLine(n, line))
            DialogLastInjectMs[n] = CurrentMs;
    }

    static void DialogPlayLine(const std::string& n, const std::string& by, const std::string& s, const std::string& o, bool svm) {
        DialogLineQueue[n].push_back({ by, s, o, svm });
        DialogPumpLines(n);
    }

    static void DialogCutLine(const std::string& n, const std::string& by, const std::string& s, const std::string& o) {
        // noch nicht gestartet? Dann einfach auslassen.
        auto q = DialogLineQueue.find(n);
        if (q != DialogLineQueue.end())
            for (auto it = q->second.begin(); it != q->second.end(); ++it)
                if (it->o == o && it->s == s) {
                    q->second.erase(it);
                    DialogLog("%s ueberspringt %s - hier ausgelassen (wartete noch)", by.c_str(), o.c_str());
                    return;
                }
        oCNpc* speaker = s == "h" ? DialogFigureOf(by) : DialogNpcByName(n);
        zCEventManager* em = speaker ? speaker->GetEM(0) : NULL;
        if (!em)
            return;
        int cut = 0;
        const int cnt = em->GetNumMessages();
        for (int i = 0; i < cnt; i++) {
            oCMsgConversation* m = zDYNAMIC_CAST<oCMsgConversation>(em->GetEventMessage(i));
            if (m && !m->IsDeleted() && DialogIsSoundMsg(m) && m->f_no > 0) {
                m->f_no = 0;   // Restzeit: die Nachricht endet im naechsten Bild
                cut++;
            }
        }
        if (cut)
            speaker->StopAllVoices();
        DialogLog("%s ueberspringt %s - hier %s", by.c_str(), o.c_str(), cut ? "abgebrochen" : "lief nicht (mehr)");
    }

    static void DialogRelease(const std::string& n, const std::string& by) {
        oCNpc* npc = DialogNpcByName(n);
        oCNpc* fig = DialogFigureOf(by);
        if (npc && DialogLocks.find(n) == DialogLocks.end()) {
            DialogFrozen.erase(npc);
            if (npc != MyDialogNpcPtr)
                npc->StopTalkingWith();
        }
        if (fig)
            fig->StopTalkingWith();
    }

    static void DialogDropEnd(const std::string& n) {
        for (auto it = DialogEnds.begin(); it != DialogEnds.end();) {
            if (it->n == n)
                it = DialogEnds.erase(it);
            else
                ++it;
        }
    }

    // --- Zuschauer-Seite: Fortschritt anwenden ------------------------------------------------------

    typedef int(__cdecl* CoopParserExternal)();

    // zCParser::DefineExternal (0x006F6840): SetOffset(Rueckgabetyp) - bei void also 0! - und SetStackPos(Funktion, 0)
    // (0x006F8520: mov [ecx+18h], Funktion). Der Funktionszeiger steht im Inhaltsfeld (+0x18), nicht in offset (v28;
    // v27 las offset und fand die LOG_*-Externals deshalb nie).
    static CoopParserExternal DialogExternal(const char* name) {
        zCPar_Symbol* s = parser ? parser->GetSymbol(zSTRING(name)) : NULL;
        if (!s || s->type != zPAR_TYPE_FUNC || !(s->flags & zPAR_FLAG_EXTERNAL) || !s->single_intdata)
            return NULL;
        return (CoopParserExternal)s->single_intdata;
    }

    static void DialogPushInt(int v) {
        parser->datastack.Push(v);
        parser->datastack.Push(0x40);   // zPAR_TOK_PUSHINT
    }

    static void DialogPushString(zSTRING* s) {
        parser->datastack.Push((int)s);
        parser->datastack.Push(0x41);   // zPAR_TOK_PUSHVAR (PopString nimmt nur den Zeiger)
    }

    // v30 (Wunsch des Nutzers): die Meldung "Neuer Tagebucheintrag" auch beim Partner. Sie steht nicht in der Engine, sondern
    // im Skript B_LogEntry(topic, entry) - Othello: Log_AddEntry + PrintScreen("Neuer Tagebucheintrag (<Thema>)", -1,
    // _YPOS_MESSAGE_LOGENTRY, "font_old_10_white.tga", 3) + Snd_Play("LogEntry"). Also das Skript selbst ausfuehren, wie
    // zCParser::CallFunc (0x006E9690) es tut: Parameter auf den Datenstapel ([zSTRING*, 0x41], das Skript holt sie im Prolog
    // selbst ab: PUSHVAR param; ASSIGNSTR), curfuncnr setzen, DoStack(Codeadresse = Inhaltsfeld des Symbols). CallFunc selbst
    // geht nicht: es erwartet Zeichenketten als ganze zSTRING-Objekte (0x14 Byte) in den variablen Argumenten.
    // B_LogEntry ruft PrintDebugNpc, das self.id/self.name liest -> self fuer den Aufruf auf den eigenen Helden setzen
    // (Instanzzeiger = offset des Symbols SELF, wie zCParser::SetInstance), danach zuruecksetzen.
    // Skriptfunktion ohne Rueckgabe ausfuehren (v31 verallgemeinert): Parameter in Skript-Reihenfolge, jeweils int oder string.
    // Prueft Typ, Parameterzahl und -typen (Symbole Index+1 ...), setzt self = eigener Held (wie oben begruendet).
    struct CoopScriptArg {
        bool str;
        int i;
        zSTRING* s;
    };

    // v92: auch Funktionen mit int-Rueckgabe (Othellos B_IncreaseRep) - der Wert bleibt nach DoStack auf dem Datenstapel; wie
    // zCParser::CallFunc (0x006E9957: Rueckgabetyp im Symbol +0x1C, bei int/float PopDataValue 0x006E8550) abholen
    static bool DialogRunScript(int idx, const std::vector<CoopScriptArg>& args) {
        zCPar_Symbol* f = (idx >= 0 && parser) ? parser->GetSymbol(idx) : NULL;
        if (!f || !player || f->type != zPAR_TYPE_FUNC || (f->flags & zPAR_FLAG_EXTERNAL)
            || ((f->flags & zPAR_FLAG_RETURN) && f->offset != zPAR_TYPE_INT && f->offset != zPAR_TYPE_FLOAT)
            || (int)f->ele != (int)args.size() || f->single_intdata <= 0 || zCParser::GetParser() != parser)
            return false;
        for (size_t k = 0; k < args.size(); k++) {
            zCPar_Symbol* p = parser->GetSymbol(idx + 1 + (int)k);
            if (!p || (int)p->type != (args[k].str ? zPAR_TYPE_STRING : zPAR_TYPE_INT))
                return false;
        }
        zCPar_Symbol* selfSym = parser->GetSymbol(zSTRING("SELF"));
        void* oldSelf = selfSym ? (void*)selfSym->offset : NULL;
        parser->SetInstance(zSTRING("SELF"), player);
        for (auto& a : args) {
            if (a.str)
                DialogPushString(a.s);
            else
                DialogPushInt(a.i);
        }
        const int oldFunc = parser->curfuncnr;
        parser->curfuncnr = idx;
        parser->DoStack(f->single_intdata);
        if (f->flags & zPAR_FLAG_RETURN)
            parser->PopDataValue();
        parser->curfuncnr = oldFunc;
        parser->SetInstance(zSTRING("SELF"), oldSelf);
        return true;
    }

    // --- v92 (nur Othello): Ruf und Spielstart-Bonus beim Partner --------------------------------------------------------
    //
    // Test v91: "Ruf bei Altem Lager nicht synchronisiert beim Client". Der Wert kam an (Spielstaende beider PCs: REPUTATIONOC = 1),
    // es fehlte aber Othellos Meldung "Ruf in dem Alten Lager + 1 = 1": B_IncreaseRep(lager, punkte) (REPUTATIONOC/NC/SC +=,
    // PrintScreenColored) laeuft nur im Dialogskript des Sprechers. Steigt ein Ruf-Wert beim Uebernehmen, ruft GT B_IncreaseRep
    // mit dem Unterschied auf (gleicher Wert, gleiche Meldung) und setzt danach den Wert des Partners.
    static int DialogRepCamp(zCPar_Symbol* sym) {
        if (!sym)
            return 0;
        const char* n = sym->name.ToChar();
        return !strcmp(n, "REPUTATIONOC") ? 1 : !strcmp(n, "REPUTATIONNC") ? 2 : !strcmp(n, "REPUTATIONSC") ? 3 : 0;
    }

    static bool DialogScriptIncreaseRep(int camp, int points) {
        static int idx = -2;
        if (idx == -2) {
            idx = parser->GetIndex(zSTRING("B_INCREASEREP"));
            DialogLog("Ruf: Skript B_INCREASEREP Symbol %d (Othello)", idx);
        }
        return idx >= 0 && DialogRunScript(idx, { { false, camp, NULL }, { false, points, NULL } });
    }

    // Othellos INFO_DIEGO_GAMESTART_INFO gibt dem Helden zuerst den Spielstart-Bonus: je nach DIFFICULTY_LEVEL B_AddBonus(hero, ...)
    // auf Staerke, Geschick, Intelligenz und Regeneration (+5 bzw. +10), HEROSTR... +=, Krit-Multiplikatoren 200, Sprint-Kosten,
    // Player_SetCurrentStamina, Ausdauer-Regeneration. Erst danach folgen die Dialogzeilen (AI_Output mit SELF) und
    // B_Kapitelwechsel(1). Das Gespraech fuehrt nur einer - der andere Held bekam den Bonus nie (Werte des Helden gleicht GT
    // absichtlich nicht ab, v31). Beim Partner laeuft deshalb genau dieser erste Teil: ein RET an den ersten "PUSHINST SELF" in
    // den Bytecode (parser->stack), DoStack ab Funktionsanfang, danach das Byte zurueck. Im Teil davor duerfen nur Spruenge
    // innerhalb des Teils, keine AI_*-Externals und als Skriptaufruf nur B_ADDBONUS stehen - sonst wird nichts ausgefuehrt.
    static bool DialogRunHeroPart(int funcIdx, const std::string& what) {
        zCPar_Symbol* f = (parser && funcIdx >= 0) ? parser->GetSymbol(funcIdx) : NULL;
        unsigned char* code = parser ? parser->stack.stack : NULL;
        const int size = parser ? parser->stack.stacksize : 0;
        if (!f || !player || !code || f->type != zPAR_TYPE_FUNC || (f->flags & (zPAR_FLAG_EXTERNAL | zPAR_FLAG_RETURN)) || f->ele != 0
            || f->single_intdata <= 0 || f->single_intdata >= size || zCParser::GetParser() != parser) {
            DialogLog("Spielstart-Bonus (%s): Funktion nicht nutzbar - nicht ausgefuehrt", what.c_str());
            return false;
        }
        const int start = f->single_intdata;
        const int selfIdx = parser->GetIndex(zSTRING("SELF"));
        zCPar_Symbol* addBonus = parser->GetSymbol(zSTRING("B_ADDBONUS"));
        int q = start, stop = -1, maxJump = start, bonusCalls = 0;
        const char* why = NULL;
        for (int n = 0; q < size && n < 4000 && !why; n++) {
            const unsigned char op = code[q];
            int arg = 0, len = 1;
            if (op == 61 || op == 62 || op == 64 || op == 65 || op == 67 || op == 75 || op == 76 || op == 80) {
                if (q + 5 > size) { why = "Code-Ende"; break; }
                arg = *(const int*)(code + q + 1);
                len = 5;
            }
            else if (op == 245)
                len = 6;
            if ((op == 67 && arg == selfIdx) || op == 60) {   // PUSHINST SELF (Dialogzeilen) bzw. RET
                stop = q;
                break;
            }
            if (op == 62) {
                zCPar_Symbol* x = parser->GetSymbol(arg);
                if (!x || !strncmp(x->name.ToChar(), "AI_", 3) || !strcmp(x->name.ToChar(), "INTRODUCECHAPTER"))
                    why = "Dialog-External vor den Dialogzeilen";
            }
            else if (op == 61) {
                if (!addBonus || addBonus->single_intdata != arg)
                    why = "anderer Skriptaufruf als B_ADDBONUS";
                else
                    bonusCalls++;
            }
            else if (op == 75 || op == 76)
                maxJump = arg > maxJump ? arg : maxJump;
            q += len;
        }
        if (!why && stop < 0)
            why = "kein Ende gefunden";
        if (!why && stop <= start)
            why = "kein Teil vor den Dialogzeilen";
        if (!why && maxJump > stop)
            why = "Sprung hinter den Teil";
        if (why) {
            DialogLog("Spielstart-Bonus (%s): %s - nicht ausgefuehrt", what.c_str(), why);
            return false;
        }
        const unsigned char saved = code[stop];
        code[stop] = 60;   // RET
        const int oldFunc = parser->curfuncnr;
        parser->curfuncnr = funcIdx;
        parser->DoStack(start);
        parser->curfuncnr = oldFunc;
        code[stop] = saved;
        DialogLog("Spielstart-Bonus (%s): Teil vor den Dialogzeilen fuer den eigenen Helden ausgefuehrt (%d Bytes, %d x B_AddBonus) - "
            "Staerke %d, Geschick %d", what.c_str(), stop - start, bonusCalls, player->GetAttribute(NPC_ATR_STRENGTH),
            player->GetAttribute(NPC_ATR_DEXTERITY));
        return true;
    }

    static int DialogLogEntryFunc = -2;

    static bool DialogScriptLogEntry(zSTRING& topic, zSTRING& entry) {
        if (DialogLogEntryFunc == -2) {
            DialogLogEntryFunc = parser->GetIndex(zSTRING("B_LOGENTRY"));
            DialogLog("Tagebuch: Skript B_LOGENTRY Symbol %d - wird fuer Meldung + Ton benutzt (Rueckfall: nur Eintrag)", DialogLogEntryFunc);
        }
        return DialogRunScript(DialogLogEntryFunc, { { true, 0, &topic }, { true, 0, &entry } });
    }

    // v31 (Nutzer: "Beide bekommen EP"): Quest-Erfahrung beim Partner ueber das Spielskript B_GiveXP - mit Meldung
    // "Erfahrung +X", Stufenaufstieg, Lernpunkten, Boni. Othello: B_GiveXP(add_xp, printColor), Vanilla G1: B_GiveXP(add_xp).
    // Erster Parameter = EP, weitere int-Parameter 0 (Othello: 0 = weisse Meldung wie im Normalfall). u11: G2 B_GivePlayerXP(add_xp).
    static bool DialogScriptGiveXP(int xp) {
        static int idx = -2;
        if (idx == -2) {
            const char* nm = "B_GIVEXP";
            idx = parser->GetIndex(zSTRING(nm));
            if (idx < 0) {
                nm = "B_GIVEPLAYERXP";
                idx = parser->GetIndex(zSTRING(nm));
            }
            DialogLog("Erfahrung: Skript %s Symbol %d", nm, idx);
        }
        zCPar_Symbol* f = idx >= 0 ? parser->GetSymbol(idx) : NULL;
        if (!f || f->ele < 1 || f->ele > 4)
            return false;
        std::vector<CoopScriptArg> args;
        for (int k = 0; k < (int)f->ele; k++)
            args.push_back({ false, k == 0 ? xp : 0, NULL });
        return DialogRunScript(idx, args);
    }

    static oCLogTopic* DialogFindTopic(const std::string& t) {
        oCLogManager& lm = oCLogManager::GetLogManager();
        for (auto* it = lm.m_lstTopics.GetNextInList(); it; it = it->GetNextInList()) {
            oCLogTopic* tp = it->GetData();
            if (tp && t == tp->m_strDescription.ToChar())
                return tp;
        }
        return NULL;
    }

    static int DialogApplyLog(json& l) {
        static CoopParserExternal create = NULL, status = NULL, add = NULL;
        if (!create || !status || !add) {   // bei Fehlschlag beim naechsten Mal neu suchen
            create = DialogExternal("LOG_CREATETOPIC");
            status = DialogExternal("LOG_SETTOPICSTATUS");
            add = DialogExternal("LOG_ADDENTRY");
            DialogLog("Tagebuch-Externals: LOG_CREATETOPIC %p, LOG_SETTOPICSTATUS %p, LOG_ADDENTRY %p", create, status, add);
        }
        if (!create || !status || !add) {
            DialogLog("Tagebuch-Externals nicht gefunden - Tagebuch nicht abgeglichen");
            return 0;
        }
        // Die Externals holen ihre Parameter ueber zCParser::GetParser() (cur_parser 0x008DDFD4); wir legen sie auf den
        // Stapel von parser (0x008DCE08). Im Spiel sind beide gleich (Speicherabbild) - sonst lieber nichts aufrufen.
        if (zCParser::GetParser() != parser) {
            DialogLog("Tagebuch: aktueller Parser %p ist nicht der Spiel-Parser %p - nicht abgeglichen", zCParser::GetParser(), parser);
            return 0;
        }
        int n = 0;
        for (auto& jt : l) {
            const std::string t = jt.at("t").get<std::string>();
            zSTRING topic(t.c_str());
            oCLogTopic* tp = DialogFindTopic(t);
            if (!tp) {
                DialogPushString(&topic);
                DialogPushInt(jt.contains("c") ? jt["c"].get<int>() : 0);
                create();
                tp = DialogFindTopic(t);
                n++;
            }
            if (!tp)
                continue;
            if (jt.contains("s") && jt["s"].get<int>() != (int)tp->m_enuStatus) {
                DialogPushString(&topic);
                DialogPushInt(jt["s"].get<int>());
                status();
                n++;
            }
            if (jt.contains("e")) {
                std::set<std::string> have;
                for (auto* e = tp->m_lstEntries.GetNextInList(); e; e = e->GetNextInList())
                    if (oCLogEntry* le = e->GetData())
                        have.insert(le->m_strDescription.ToChar());
                for (auto& je : jt["e"]) {
                    const std::string s = je.get<std::string>();
                    if (have.count(s))
                        continue;
                    zSTRING entry(s.c_str());
                    if (!DialogScriptLogEntry(topic, entry)) {   // v30: wie im Spiel mit Meldung + Ton
                        DialogPushString(&topic);
                        DialogPushString(&entry);
                        add();
                    }
                    have.insert(s);
                    n++;
                }
            }
        }
        return n;
    }

    static CoopDlgTopic StoryTopicNow(oCLogTopic* tp) {
        CoopDlgTopic s;
        s.t = tp->m_strDescription.ToChar();
        s.sec = (int)tp->m_enuSection;
        s.st = (int)tp->m_enuStatus;
        for (auto* e = tp->m_lstEntries.GetNextInList(); e; e = e->GetNextInList())
            if (oCLogEntry* le = e->GetData())
                s.e.push_back(le->m_strDescription.ToChar());
        return s;
    }

    // u150 (P154): Gildenfortschritt je Held auch beim Laden. Nutzer: "Wenn man einen Savegame laedt dann wird ja der vom Host geladen, aber das wuerde ja heissen, dass auch seine
    // Gildenquests etc. geladen werden". Beim gemeinsamen Laden uebernimmt der Partner den ganzen Stand des Hosts. Zurueck kamen bis u149 Gilde, Werte und Inventar, nicht aber Werte aus
    // Gilden-Infos, erzaehlte Gilden-Infos und deren Tagebuch-Themen: Trat der Host bei, galt die Aufnahme nach dem Laden beim Partner als erzaehlt, und er kam nicht mehr in die Gilde.
    // Jetzt stehen sie in COOPHERO.TXT ("gs=...") und gelten mit dem eigenen Helden. Staende ohne die Zeile "G 1" bleiben wie bisher. Allgemein (G1/G2).
    static std::string DlgGsText(std::string s) {
        for (char& c : s)
            if (c == '\r' || c == '\n')
                c = ' ';
        if (s.size() > 900)   // CoopHeroRead liest Zeilen bis 1024 Zeichen
            s.resize(900);
        return s;
    }

    void CoopHeroGuildCapture(std::vector<std::string>& out) {
        out.clear();
        if (!parser || !ogame || !ogame->GetInfoManager())
            return;
        out.push_back("G 1");
        DlgBuildIntSlots();
        for (auto& slot : DlgIntSlots)
            if (DlgGuildVars.count(slot.sym)) {
                int v = 0;
                slot.sym->GetValue(v, slot.idx);
                out.push_back(std::string("V ") + slot.sym->name.ToChar() + " " + std::to_string(slot.idx) + " " + std::to_string(v));
            }
        for (auto& b : DlgGuildVarBase)   // u154 (P159): B Name Index Wert vor dem ersten Gilden-Info
            if (b.first.first)
                out.push_back(std::string("B ") + b.first.first->name.ToChar() + " " + std::to_string(b.first.second) + " " + std::to_string(b.second));
        for (auto& n : DlgGuildInfos)
            out.push_back("J " + DlgGsText(n));
        for (auto* l = ogame->GetInfoManager()->infoList.GetNextInList(); l; l = l->GetNextInList()) {
            oCInfo* info = l->GetData();
            if (info && info->told && (!DlgGuildOfInfo(info).empty() || DlgGuildInfos.count(info->name.ToChar())))
                out.push_back(std::string("I ") + info->name.ToChar());
        }
        for (auto& n : DlgGuildTopics)
            out.push_back("N " + DlgGsText(n));
        for (auto& g : DlgGuildNpcs) {   // u152 (P156): Q Name Haltung Zwischenhaltung Merker:Wert,... bzw. R Name (NPC nicht in dieser Welt)
            oCNpc* npc = DialogNpcByName(g.first);
            if (!npc) {
                out.push_back("R " + g.first);
                continue;
            }
            std::string q = "Q " + g.first + " " + std::to_string(npc->attitude) + " " + std::to_string(npc->tmp_attitude) + " ";
            for (int i : g.second)
                if (i >= 0 && i < COOP_AIV_MAX)
                    q += std::to_string(i) + ":" + std::to_string(npc->aiscriptvars[i]) + ",";
            out.push_back(q);
        }
        for (auto& h : DlgGuildNpcBase) {   // u154 (P159): H Name Haltung Zwischenhaltung Merker:Wert,... vor dem ersten Gilden-Info
            std::string q = "H " + h.first + " " + std::to_string(h.second.att) + " " + std::to_string(h.second.tatt) + " ";
            for (auto& a : h.second.aiv)
                q += std::to_string(a.first) + ":" + std::to_string(a.second) + ",";
            out.push_back(q);
        }
        std::vector<CoopDlgTopic> log;
        DlgSnapLog(log);
        for (auto& t : log)
            if (DlgGuildTopics.count(t.t)) {
                out.push_back("T " + std::to_string(t.sec) + " " + std::to_string(t.st) + " " + DlgGsText(t.t));
                for (auto& e : t.e)
                    out.push_back("E " + DlgGsText(e));
            }
    }

    // Nach einem Neustart kennt GT die Werte je Held nur aus der Datei - sonst gingen sie wieder in den Story-Abgleich
    void CoopHeroGuildNote(const std::vector<std::string>& in) {
        if (!parser)
            return;
        for (auto& l : in) {
            if (l.size() < 3 || l[1] != ' ')
                continue;
            const std::string rest = l.substr(2);
            if (l[0] == 'V') {
                if (zCPar_Symbol* s = parser->GetSymbol(zSTRING(rest.substr(0, rest.find(' ')).c_str())))
                    DlgGuildVars.insert(s);
            }
            else if (l[0] == 'J')
                DlgGuildInfos.insert(rest);
            else if (l[0] == 'N')
                DlgGuildTopics.insert(rest);
            else if (l[0] == 'R')   // u152 (P156)
                DlgGuildNpcs[rest];
            else if (l[0] == 'Q') {
                std::set<int>& s = DlgGuildNpcs[rest.substr(0, rest.find(' '))];
                const size_t last = rest.rfind(' ');
                for (const char* c = last == std::string::npos ? "" : rest.c_str() + last + 1; *c;) {
                    s.insert(atoi(c));
                    c = strchr(c, ',');
                    if (!c)
                        break;
                    c++;
                }
            }
            else if (l[0] == 'B') {   // u154 (P159)
                char nm[256] = {};
                int k = 0, val = 0;
                if (sscanf(rest.c_str(), "%255s %d %d", nm, &k, &val) == 3)
                    if (zCPar_Symbol* s = parser->GetSymbol(zSTRING(nm)))
                        DlgGuildVarBase.emplace(std::make_pair(s, k), val);
            }
            else if (l[0] == 'H') {
                char nm[256] = {};
                int att = 0, tatt = 0, off = 0;
                if (sscanf(rest.c_str(), "%255s %d %d %n", nm, &att, &tatt, &off) < 3)
                    continue;
                auto r = DlgGuildNpcBase.emplace(nm, CoopGuildNpcBase());
                if (r.second) {
                    r.first->second.att = att;
                    r.first->second.tatt = tatt;
                }
                for (const char* c = off > 0 ? rest.c_str() + off : ""; *c;) {
                    int i = -1, v = 0;
                    if (sscanf(c, "%d:%d", &i, &v) == 2 && i >= 0 && i < COOP_AIV_MAX)
                        r.first->second.aiv.emplace(i, v);
                    c = strchr(c, ',');
                    if (!c)
                        break;
                    c++;
                }
            }
        }
    }

    void CoopHeroGuildBaseReset() {   // u154 (P159): vor dem Laden - danach gilt der Stand davor aus dem geladenen Stand
        DlgGuildVarBase.clear();
        DlgGuildNpcBase.clear();
    }

    // u154 (P159): Gildenfortschritt des Hosts, bei dem dieser Held nie dabei war (Liste 6h). Bis u153 kam er beim Uebernehmen des Host-Stands mit dessen Welt: Werte, Themen und
    // Haltungen aus Gilden-Infos des Hosts, deren Namen die eigene COOPHERO.TXT nicht kannte. Jetzt kommen die Namen aus der Datei des Hosts. Steht der eigene Held noch in seiner
    // laufenden Welt (fromWorld), gelten seine Werte von dort, sonst der Stand vor dem ersten Gilden-Info (B- und H-Zeilen des Hosts); ohne ihn (Staende von vor u154) bleibt es wie
    // beim Host. Gilden-Infos selbst galten schon bis u153 beim Partner als nicht erzaehlt. Allgemein (G1/G2).
    int CoopHeroGuildMerge(std::vector<std::string>& own, const std::vector<std::string>& host, bool fromWorld, std::string& text) {
        if (!parser || host.empty() || host[0] != "G 1")
            return 0;
        CoopHeroGuildNote(host);
        if (fromWorld) {
            CoopHeroGuildCapture(own);
            text = "eigene Werte aus der laufenden Welt neu erfasst";
            return 1;
        }
        if (own.empty() || own[0] != "G 1")
            return 0;   // eigener Stand von vor u150: bleibt, wie er war
        auto first = [](const std::string& s) { return s.substr(0, s.find(' ')); };
        auto two = [](const std::string& s) {
            const size_t a = s.find(' ');
            return s.substr(0, a == std::string::npos ? a : s.find(' ', a + 1));
        };
        std::set<std::string> ownVar, ownBase, ownTopic, ownInfo, ownNpc, ownNpcBase;
        for (auto& l : own) {
            if (l.size() < 3 || l[1] != ' ')
                continue;
            const std::string rest = l.substr(2);
            if (l[0] == 'V')
                ownVar.insert(two(rest));
            else if (l[0] == 'B')
                ownBase.insert(two(rest));
            else if (l[0] == 'N')
                ownTopic.insert(rest);
            else if (l[0] == 'J')
                ownInfo.insert(rest);
            else if (l[0] == 'Q' || l[0] == 'R')
                ownNpc.insert(first(rest));
            else if (l[0] == 'H')
                ownNpcBase.insert(first(rest));
        }
        std::map<std::string, std::string> base, npcBase;   // aus der Datei des Hosts: "Name Index" -> Wert, NPC -> "Haltung Zwischenhaltung Merker"
        for (auto& l : host) {
            if (l.size() < 3 || l[1] != ' ')
                continue;
            const std::string rest = l.substr(2);
            if (l[0] == 'B') {
                const std::string k = two(rest);
                if (rest.size() > k.size() + 1)
                    base[k] = rest.substr(k.size() + 1);
            }
            else if (l[0] == 'H') {
                const std::string n = first(rest);
                if (rest.size() > n.size() + 1)
                    npcBase[n] = rest.substr(n.size() + 1);
            }
        }
        int vars = 0, topics = 0, infos = 0, npcs = 0, unknown = 0;
        std::vector<std::string> add;
        for (auto& l : host) {
            if (l.size() < 3 || l[1] != ' ')
                continue;
            const std::string rest = l.substr(2);
            if (l[0] == 'V') {
                const std::string k = two(rest);
                if (ownVar.count(k))
                    continue;
                auto b = base.find(k);
                if (b == base.end()) {
                    unknown++;
                    continue;
                }
                add.push_back("V " + k + " " + b->second);
                ownVar.insert(k);
                vars++;
            }
            else if (l[0] == 'N' && ownTopic.insert(rest).second) {
                add.push_back(l);
                topics++;
            }
            else if (l[0] == 'J' && ownInfo.insert(rest).second) {
                add.push_back(l);
                infos++;
            }
            else if (l[0] == 'Q' || l[0] == 'R') {
                const std::string n = first(rest);
                if (ownNpc.count(n))
                    continue;
                auto h = npcBase.find(n);
                if (h == npcBase.end()) {
                    unknown++;
                    continue;
                }
                add.push_back("Q " + n + " " + h->second);
                ownNpc.insert(n);
                npcs++;
            }
            else if (l[0] == 'B' && ownBase.insert(two(rest)).second)
                add.push_back(l);   // der Stand davor gilt auch fuer spaetere Uebernahmen aus diesem Stand
            else if (l[0] == 'H' && ownNpcBase.insert(first(rest)).second)
                add.push_back(l);
        }
        own.insert(own.end(), add.begin(), add.end());
        text = std::to_string(vars) + " Werte, " + std::to_string(npcs) + " NPC-Haltungen auf den Stand davor, " + std::to_string(topics) + " Themen und "
            + std::to_string(infos) + " Aufnahme-Infos des Hosts nicht bei mir, " + std::to_string(unknown) + " ohne Stand davor (bleiben wie beim Host)";
        return vars + topics + infos + npcs + unknown;
    }

    // u152 (P156): Q-Zeilen des eigenen Helden. Der Held kommt im Ladevorgang zurueck, die NPC-Namen der Welt entstehen erst danach im Spieltakt (BuildGlobalNpcList) -
    // Testlauf: "0 NPC-Haltungen", obwohl die Zeile in COOPHERO.TXT stand. Darum hier warten, bis die Liste steht.
    static std::vector<std::string> DlgGuildNpcPending;

    static void DlgGuildNpcPendingApply() {
        if (DlgGuildNpcPending.empty() || NpcToUniqueNameList.empty())
            return;
        int set = 0, missing = 0;
        for (auto& rest : DlgGuildNpcPending) {
            char nm[256] = {};
            int att = 0, tatt = 0, off = 0;
            if (sscanf(rest.c_str(), "%255s %d %d %n", nm, &att, &tatt, &off) < 3)
                continue;
            oCNpc* npc = DialogNpcByName(nm);
            if (!npc) {
                missing++;
                continue;
            }
            bool changed = npc->attitude != att || npc->tmp_attitude != tatt;
            if (npc->attitude != att)
                npc->SetAttitude(att);
            if (npc->tmp_attitude != tatt)
                npc->SetTmpAttitude(tatt);
            for (const char* c = off > 0 ? rest.c_str() + off : ""; *c;) {
                int i = -1, v = 0;
                if (sscanf(c, "%d:%d", &i, &v) == 2 && i >= 0 && i < COOP_AIV_MAX && npc->aiscriptvars[i] != v) {
                    npc->aiscriptvars[i] = v;
                    changed = true;
                }
                c = strchr(c, ',');
                if (!c)
                    break;
                c++;
            }
            if (changed)
                set++;
            if (StoryReady)
                StoryBaseNpc[nm] = { npc->daily_routine, npc->attitude, DlgNpcFields(npc) };
        }
        DialogLog("Gilden je Held: %d NPC-Haltungen des eigenen Helden gesetzt (%u vorgemerkt, %d nicht in dieser Welt)", set,
            (unsigned)DlgGuildNpcPending.size(), missing);
        DlgGuildNpcPending.clear();
    }

    // u160 (P167): eigener Ladevorgang eines eigenen Stands - die Haltungen je Held (Q-Zeilen der eigenen COOPHERO.TXT) gelten wieder, sobald
    // die Namensliste steht, wie nach einer Uebernahme. Rueckgabe: vorgemerkte NPCs
    int CoopHeroGuildNpcsAgain(const std::vector<std::string>& in) {
        if (in.empty() || in[0] != "G 1")
            return 0;
        int n = 0;
        for (auto& l : in)
            if (l.size() > 2 && l[0] == 'Q' && l[1] == ' ') {
                DlgGuildNpcPending.push_back(l.substr(2));
                n++;
            }
        return n;
    }

    // u153 (P158): Gothic legt die Knoten seiner zCList in einem eigenen Speicher-Pool an (G1 0x00873640, G2A 0x008D8398) und gibt
    // sie dorthin zurueck. Das G1-SDK kannte den Pool nur an zList - DeleteList und Remove gaben die Knoten an den Heap, der
    // G1-Client stuerzte beim Laden mit eigenen Gilden-Themen ab (Testinstanz b150, 2.11.). Ohne die Angabe im SDK baut es nicht.
    static_assert(sizeof(static_cast<void (*)(void*)>(&zCList<oCLogTopic>::operator delete)) > 0, "zCList ohne Gothics Speicher-Pool");

    // Ohne Meldung und Ton: Thema anlegen, Status setzen, Eintraege ersetzen
    static bool DlgGsTopicSet(const CoopDlgTopic& t) {
        CoopParserExternal create = DialogExternal("LOG_CREATETOPIC"), status = DialogExternal("LOG_SETTOPICSTATUS"), add = DialogExternal("LOG_ADDENTRY");
        if (!create || !status || !add || zCParser::GetParser() != parser)
            return false;
        zSTRING topic(t.t.c_str());
        oCLogTopic* tp = DialogFindTopic(t.t);
        if (!tp) {
            DialogPushString(&topic);
            DialogPushInt(t.sec);
            create();
            tp = DialogFindTopic(t.t);
        }
        if (!tp)
            return false;
        if (t.st != (int)tp->m_enuStatus) {
            DialogPushString(&topic);
            DialogPushInt(t.st);
            status();
        }
        for (int pass = 0; pass < 2 && StoryTopicNow(tp).e != t.e; pass++) {   // Reihenfolge wie im Stand: legt die Engine vorn an, geht der zweite Durchgang rueckwaerts
            tp->m_lstEntries.DeleteList();
            std::vector<std::string> order = t.e;
            if (pass == 1)
                std::reverse(order.begin(), order.end());
            for (auto& s : order) {
                zSTRING entry(s.c_str());
                DialogPushString(&topic);
                DialogPushString(&entry);
                add();
            }
        }
        return true;
    }

    int CoopHeroGuildApply(const std::vector<std::string>& in, std::string& text) {
        if (!parser || !ogame || !ogame->GetInfoManager() || in.empty() || in[0] != "G 1")
            return -1;
        CoopHeroGuildNote(in);
        DlgBuildIntSlots();
        int vars = 0, infos = 0, topics = 0, gone = 0, npcs = 0;
        std::set<std::string> told, names;
        std::map<std::string, CoopDlgTopic> own;
        std::string cur;
        for (auto& l : in) {
            if (l.size() < 3 || l[1] != ' ')
                continue;
            const std::string rest = l.substr(2);
            if (l[0] == 'V') {
                char nm[256] = {};
                int k = 0, val = 0;
                if (sscanf(rest.c_str(), "%255s %d %d", nm, &k, &val) != 3)
                    continue;
                zCPar_Symbol* s = parser->GetSymbol(zSTRING(nm));
                const int ele = s && s->ele > 1 ? (int)s->ele : 1;
                if (!s || s->type != zPAR_TYPE_INT || (s->flags & (zPAR_FLAG_CONST | zPAR_FLAG_CLASSVAR)) || k < 0 || k >= ele)
                    continue;
                int old = 0;
                s->GetValue(old, k);
                if (old != val) {
                    s->SetValue(val, k);
                    vars++;
                }
                auto slot = DlgSlotIndex.find(std::make_pair(s, k));
                if (StoryReady && slot != DlgSlotIndex.end() && slot->second < (int)StoryBaseInts.size())
                    StoryBaseInts[slot->second] = val;
            }
            else if (l[0] == 'I')
                told.insert(rest);
            else if (l[0] == 'N')
                names.insert(rest);
            else if (l[0] == 'T') {
                int sec = 0, st = 0, off = 0;
                if (sscanf(rest.c_str(), "%d %d %n", &sec, &st, &off) >= 2 && off > 0) {
                    cur = rest.substr(off);
                    CoopDlgTopic& t = own[cur];
                    t.t = cur;
                    t.sec = sec;
                    t.st = st;
                }
            }
            else if (l[0] == 'E' && !cur.empty())
                own[cur].e.push_back(rest);
            else if (l[0] == 'Q') {   // u152 (P156): erst, wenn die Namensliste der Welt steht (CoopDialogSyncPulse)
                DlgGuildNpcPending.push_back(rest);
                npcs++;
            }
        }
        for (auto* l = ogame->GetInfoManager()->infoList.GetNextInList(); l; l = l->GetNextInList()) {
            oCInfo* info = l->GetData();
            if (!info || (DlgGuildOfInfo(info).empty() && !DlgGuildInfos.count(info->name.ToChar())))
                continue;
            const int want = told.count(info->name.ToChar()) ? TRUE : FALSE;
            if ((info->told != FALSE) != (want != FALSE)) {
                info->told = want;
                infos++;
            }
        }
        for (auto& n : names) {
            auto f = own.find(n);
            oCLogTopic* tp = DialogFindTopic(n);
            if (f != own.end()) {
                const bool same = tp && StoryTopicNow(tp).st == f->second.st && StoryTopicNow(tp).e == f->second.e;
                if (!same && DlgGsTopicSet(f->second))
                    topics++;
            }
            else if (tp) {   // Thema des Partners aus seinem Stand
                oCLogManager::GetLogManager().m_lstTopics.Remove(tp);
                gone++;
            }
            if (StoryReady) {
                tp = DialogFindTopic(n);
                if (tp)
                    StoryBaseLog[n] = StoryTopicNow(tp);
                else
                    StoryBaseLog.erase(n);
            }
        }
        text = std::to_string(vars) + " Werte, " + std::to_string(infos) + " Gespraeche, " + std::to_string(topics) + " Themen gesetzt, " + std::to_string(gone) + " Themen des Partners entfernt, "
            + std::to_string(npcs) + " NPC-Haltungen vorgemerkt";
        return vars + infos + topics + gone + npcs;
    }

    // v94: Kapitel-Bildschirm des Partners erst nach dessen Gespraech. Test v93: "ch" kam mitten in Diegos Begruessung
    // (INFO_DIEGO_GAMESTART laeuft nur beim Host) - beim Host zeigt Gothic ihn erst nach dem Dialog (CGameManager::Run 0x00424F7A
    // nur bei MenuEnabled 0x00429140, im Dialog aus), beim Mitspieler lief kein Dialog, er kam sofort. Darum warten, solange der
    // Absender hier eine Gespraechssperre hat (DialogLocks) oder seine letzte Zeile noch laeuft (DialogEnds); hoechstens 5 min.
    // Allgemein G1.
    struct CoopChapterPending {
        std::string by;
        json ch;
        long long since;
    };
    static std::vector<CoopChapterPending> ChapterPending;

    static bool DialogPartnerTalking(const std::string& by) {
        for (auto& l : DialogLocks)
            if (l.second.owner == by)
                return true;
        for (auto& d : DialogEnds)
            if (d.by == by)
                return true;
        return false;
    }

    // CGameManager::IntroduceChapter (0x00429A20, Eingang unveraendert) merkt Titel, Untertitel, Bild, Ton und Dauer nur vor;
    // Gothic zeigt ihn im naechsten Bild ohne Dialog
    // u28 (docs\G2-SKRIPTABGLEICH.md B4): Gothic 2 zeigt Kapitel 3 und 5 mit einem Bild der Gilde des Helden (B_Enter_NewWorld:
    // chapter3_MIL bei Miliz/Paladin, _KDF bei Feuermagiern, sonst _SLD; chapter5_PAL/_KDF/_DJG). Der Partner bekam das Bild der
    // Host-Gilde - jetzt das zur eigenen Gilde, nach derselben Regel. Andere Bilder bleiben. Allgemein (nur diese G2-Namen).
    static std::string DialogChapterTexForMe(const std::string& tex) {
        std::string up = tex;
        for (char& ch : up)
            ch = (char)toupper((unsigned char)ch);
        const bool k3 = up.compare(0, 9, "CHAPTER3_") == 0, k5 = up.compare(0, 9, "CHAPTER5_") == 0;
        if ((!k3 && !k5) || !player || !parser)
            return tex;
        auto gil = [](const char* n) {
            int v = -1;
            if (zCPar_Symbol* s = parser->GetSymbol(zSTRING(n)))
                s->GetValue(v, 0);
            return v;
        };
        const int g = player->GetGuild();
        const bool milPal = g == gil("GIL_MIL") || g == gil("GIL_PAL");
        const bool kdf = g == gil("GIL_KDF");
        const char* suffix = milPal ? (k3 ? "MIL" : "PAL") : kdf ? "KDF" : (k3 ? "SLD" : "DJG");
        return std::string(k3 ? "chapter3_" : "chapter5_") + suffix + ".tga";
    }

    static void DialogShowChapter(json& c, const std::string& by, const char* how) {
        if (!gameMan || !c.is_array() || c.size() != 5)
            return;
        const std::string t = c[0].is_string() ? c[0].get<std::string>() : std::string();
        const std::string texIn = c[2].is_string() ? c[2].get<std::string>() : std::string();
        const std::string tex = DialogChapterTexForMe(texIn);   // u28
        gameMan->IntroduceChapter(zSTRING(t.c_str()), zSTRING(c[1].is_string() ? c[1].get<std::string>().c_str() : ""),
            zSTRING(tex.c_str()), zSTRING(c[3].is_string() ? c[3].get<std::string>().c_str() : ""),
            c[4].is_number() ? c[4].get<int>() : 6000);
        // u182 (Nutzer zur Aufnahme mit b285: "wieso kam die kapitel 1 anzeige zu spaet beim client"): Gothic zeigt den vorgemerkten
        // Bildschirm erst ohne eigenes Gespraech (CGameManager::Run nur bei MenuEnabled). Diego sprach gerade mit der Stadtwache - Kapitel 1
        // kam 29 s nach dem Host. Seit die Zeilen in Aufnahmen ausklingen und der Client Ton hat, dauern solche Gespraeche viel laenger.
        // Jetzt im eigenen Gespraech gleich zeigen: derselbe Aufruf, den Gothic danach machte (IntroduceChapter ohne Werte, zeigt und
        // loescht die Vormerkung), von derselben Stelle wie das Video des Partners (DialogPlayVideo). Das Gespraech geht danach weiter.
        // Allgemein G1/G2.
        const bool sofort = MyDialogNpcPtr != NULL;
        if (sofort)
            gameMan->IntroduceChapter();
        DialogLog("Kapitel-Bildschirm von %s: %s%s%s%s", by.c_str(), t.c_str(), how,
            tex != texIn ? (" - Bild der eigenen Gilde: " + tex).c_str() : "", sofort ? " - sofort, mitten im eigenen Gespraech" : "");
    }

    // u28 (docs\G2-SKRIPTABGLEICH.md B5): Story-Videos auch beim Partner. Videos aus Dialogen und Ereignissen (G2: Intro_ADDON in
    // Xardas' erstem Gespraech, LOVESCENE, oreheap, ORCATTACK, DRAGONATTACK, SHIP, PORTAL_RAVEN, Extros; G1 ebenso aus Skripten)
    // liefen nur auf dem PC, dessen Skript sie startete - der zuhoerende Partner sah sie nie. Die Externals PLAYVIDEO(name) und
    // PLAYVIDEOEX(name, screenBlend, exitSession) sind umgeleitet (CoopExtPlayVideo unten): vor dem Abspielen geht "vid" an den
    // Partner (der Host gibt es weiter), der dasselbe Original mit denselben Werten abspielt - beide sehen es gleichzeitig. Nur im
    // laufenden Spiel (DialogSyncAktiv - Start-Videos beim Laden und Menue-Videos laufen wie bisher je PC) und mit Abgleich
    // "Quests". Allgemein G1/G2.
    // u55: Ueberspringen gilt fuer beide - Nummer des Videos ("vidno" neben "vid", die Liste bleibt fuer aeltere Partner gleich),
    // Abgleich in CoopNewGame.cpp
    typedef int(__cdecl* CoopVideoExternal)();
    static CoopVideoExternal OrigPlayVideo = NULL, OrigPlayVideoEx = NULL;
    static int VideoReplaying = 0;
    long CoopStoryVideoNewNo();
    void CoopStoryVideoBegin(long no);
    void CoopStoryVideoEnd();

    static void DialogPlayVideo(json& v, long no, const std::string& by) {
        if (!v.is_array() || v.size() != 4 || !v[0].is_string() || !parser || zCParser::GetParser() != parser)
            return;
        const bool ex = v[3].is_number() && v[3].get<int>() == 1;
        CoopVideoExternal orig = ex ? OrigPlayVideoEx : OrigPlayVideo;
        if (!orig)
            return;
        zSTRING name(v[0].get<std::string>().c_str());
        DialogPushString(&name);
        if (ex) {
            DialogPushInt(v[1].is_number() ? v[1].get<int>() : 0);
            DialogPushInt(v[2].is_number() ? v[2].get<int>() : 0);
        }
        DialogLog("Video von %s: %s - auch hier (Nr. %ld)", by.c_str(), name.ToChar(), no);
        VideoReplaying++;
        CoopStoryVideoBegin(no);
        orig();
        CoopStoryVideoEnd();
        VideoReplaying--;
    }

    // u147 (P149, Testlauf b112, 15:37, das Spiel durchgespielt): Der Client fuehrte das letzte Gespraech, B_Extro_Avi spielte die Videos auf beiden PCs, EXITSESSION lief aber nur bei ihm: Er stand im Hauptmenue,
    // der Host spielte weiter, und nach seinem naechsten Laden stuenden beide wieder vor dem Ende. Jetzt endet die Sitzung auch beim Partner (Externe unten umgeleitet). G1 und Othello kennen das nicht: DIA_Extro_Avi ruft
    // EXITGAME, das beendet das Programm; das bleibt je PC, dem Partner schliesst GT das Spiel nicht
    int CoopExitSessionSeen = 0;   // Testlauf

    static void DialogExitSession(const json& v, const std::string& by) {
#if ENGINE >= Engine_G2
        if (!gameMan)
            return;
        if (v.is_number() && v.get<int>() == 2) {   // Testlauf: ExitSession haelt das Spiel an, darum nur zaehlen
            CoopExitSessionSeen++;
            DialogLog("Spielende von %s: Testlauf, Sitzung bleibt", by.c_str());
            return;
        }
        DialogLog("Spielende von %s: Sitzung endet auch hier", by.c_str());
        gameMan->ExitSession();
#endif
    }

    static void DialogChapterPulse() {
        for (auto it = ChapterPending.begin(); it != ChapterPending.end();) {
            const bool late = CurrentMs > it->since + 300000;
            if (!late && DialogPartnerTalking(it->by)) {
                ++it;
                continue;
            }
            CoopChapterPending p = *it;
            it = ChapterPending.erase(it);
            DialogShowChapter(p.ch, p.by, late ? " (nach 5 min ohne Gespr\xE4" "chsende)" : " (nach seinem Gespr\xE4" "ch)");
        }
    }

    // u139 (P138): Skriptfelder des Partners; nur Abweichendes (Gesamtliste beim RESYNC)
    static void DialogApplyNpcFields(oCNpc* npc, const std::string& n, const json& jn) {
        const CoopNpcFields was = DlgNpcFields(npc);
        if (jn.contains("fl"))
            npc->variousFlags = jn["fl"].get<int>();
        if (jn.contains("gu"))
            npc->guild = jn["gu"].get<int>();
        if (jn.contains("gt") && was.guildTrue != jn["gt"].get<int>())
            npc->SetTrueGuild(jn["gt"].get<int>());
        if (jn.contains("nt"))
            npc->npcType = jn["nt"].get<int>();
#if ENGINE == Engine_G2A
        if (jn.contains("nf"))
            npc->noFocus = jn["nf"].get<int>();
#endif
        const CoopNpcFields now = DlgNpcFields(npc);
        static CoopDiagBudget budget = { 0, 0 };
        if (!DlgNpcFieldsSame(was, now) && CoopDiagAllow(budget, 20))
            DialogLog("Felder von %s wie beim Partner: Schutz %d -> %d, Gilde %d -> %d, wahre Gilde %d -> %d, Typ %d -> %d, ohne Fokus %d -> %d", n.c_str(),
                was.flags, now.flags, was.guild, now.guild, was.guildTrue, now.guildTrue, was.npcType, now.npcType, was.noFocus, now.noFocus);
    }

    // NPC-Zustand des Partners (aivar, Haltung, Tagesablauf, u139 Skriptfelder) anwenden; false = NPC hier (noch) unbekannt
    static bool DialogApplyNpcEntry(json& jn) {
        const std::string n = jn.at("n").get<std::string>();
        oCNpc* npc = DialogNpcByName(n);
        if (!npc || npc == player)
            return false;
        if (jn.contains("a"))
            for (auto& a : jn["a"]) {
                const int i = a.at(0).get<int>();
                if (i >= 0 && i < COOP_AIV_MAX)   // u3: G1 50, G2 100
                    npc->aiscriptvars[i] = a.at(1).get<int>();
            }
        const bool funNpc = n.compare(0, 4, "FUN_") == 0;   // u203: Fun-Modus - Haltung der Lager-NPCs gilt je Held (COOP_FUN.D)
        if (!funNpc && jn.contains("at") && npc->attitude != jn["at"].get<int>())   // v110: nur bei Abweichung (Gesamtliste beim RESYNC)
            npc->SetAttitude(jn["at"].get<int>());
        if (!funNpc && jn.contains("tt"))
            npc->SetTmpAttitude(jn["tt"].get<int>());
        int rtnNow = npc->daily_routine;
        if (jn.contains("r")) {
            const int idx = parser->GetIndex(zSTRING(jn["r"].get<std::string>().c_str()));
            if (idx > 0 && npc->daily_routine != idx) {
                static CoopDiagBudget budget = { 0, 0 };
                if (CoopDiagAllow(budget, 20)) {
                    zCPar_Symbol* old = parser->GetSymbol(npc->daily_routine);
                    DialogLog("Tagesablauf von %s: %s -> %s (wie beim Partner)", n.c_str(), old ? old->name.ToChar() : "-",
                        jn["r"].get<std::string>().c_str());
                }
                npc->state.ChangeRoutine(idx);
            }
            if (idx > 0)
                rtnNow = idx;
        }
        DialogApplyNpcFields(npc, n, jn);
        if (StoryReady)   // v31: kein Echo im Story-Takt
            StoryBaseNpc[n] = { rtnNow, npc->attitude, DlgNpcFields(npc) };
        return true;
    }

    // v110 (Test v109, gemeinsames neues Spiel): Diegos Startgespraech beim Host aenderte Bloodwyns Tagesablauf (RTN_PAY_233).
    // Beim Mitspieler kam der Fortschritt eine Sekunde, bevor seine NPC-Namensliste stand ("unbekannter NPC-Name", Namensliste
    // Lauf 1 danach) - "0 NPCs" uebernommen, der Eintrag still verworfen, Bloodwyn blieb hier bei RTN_START_233. Jetzt warten
    // Eintraege fuer noch unbekannte NPCs bis 2 min und werden angewendet, sobald der NPC hier einen Namen hat (gleiche Welt).
    // Allgemein GT.
    struct CoopPendingNpcState {
        json jn;
        std::string by, world;
        long long since;
    };
    static std::vector<CoopPendingNpcState> DialogPendingNpcs;
    static long long DialogPendingNextMs = 0;

    static void DialogDropPendingNpc(const std::string& n) {
        for (auto it = DialogPendingNpcs.begin(); it != DialogPendingNpcs.end();)
            it = it->jn.value("n", std::string()) == n ? DialogPendingNpcs.erase(it) : std::next(it);
    }

    static void DialogPendingNpcPulse() {
        if (DialogPendingNpcs.empty() || CurrentMs < DialogPendingNextMs || !parser || !player || IsLoadingLevel)
            return;
        DialogPendingNextMs = CurrentMs + 500;
        const std::string world = CoopWorldName();
        for (auto it = DialogPendingNpcs.begin(); it != DialogPendingNpcs.end();) {
            const std::string n = it->jn.value("n", std::string());
            if (it->world == world && DialogApplyNpcEntry(it->jn)) {
                DialogLog("NPC-Zustand von %s fuer %s nachgetragen (kam %lld ms vor seinem Namen)%s%s", it->by.c_str(), n.c_str(),
                    CurrentMs - it->since, it->jn.contains("r") ? " - Tagesablauf " : "",
                    it->jn.contains("r") ? it->jn["r"].get<std::string>().c_str() : "");
                it = DialogPendingNpcs.erase(it);
            }
            else if (CurrentMs - it->since > 120000) {
                DialogLog("NPC-Zustand von %s fuer %s verworfen - NPC hier nach 2 min nicht da (%s)", it->by.c_str(), n.c_str(),
                    it->world == world ? "gleiche Welt" : "andere Welt");
                it = DialogPendingNpcs.erase(it);
            }
            else
                ++it;
        }
    }

    // v110 (Test v109): ein frueher verlorener NPC-Zustand (Bloodwyn, s. o.) blieb im Spielstand verschieden - der Story-Takt schickt
    // nur Aenderungen. Host, auf das RESYNC eines Clients nach Laden/Verbinden (CoopSaveSync.cpp): Tagesablauf und dauerhafte Haltung
    // aller lebenden Welt-NPCs einmal ganz; der Client uebernimmt, was abweicht. Nur mit Abgleich "Quests" und "beim Verbinden
    // Host-Stand" (sonst behaelt der Client absichtlich seinen eigenen Stand). Allgemein GT.
    // u162 (P169, Liste 6o): Haltung je Held (aus Gilden-Infos und Aufnahmen, P156) geht nicht als Gesamtstand hinaus, sondern der Stand
    // davor - ohne ihn gar keine Haltung. Bis u161 ging die Haltung des Host-Helden mit; der Client streicht sie nur bei Namen, die er
    // kennt (DlgGuildNpcStrip). Gilden-Probe: Im Clientlauf stand Xardas in 6 von 47 Laeufen auf der Haltung des Host-Helden - das
    // RESYNC nach dem Laden kam beim Client erst an, nachdem der Schritt "Gildenfortschritt zurueck" den Namen dort geloescht hatte.
    // Allgemein (G1/G2).
    void CoopStorySendAllNpcs(const char* why) {
        if (!ServerThread || !parser || !ogame || !ogame->GetGameWorld() || !DialogSyncAktiv() || !CoopRuleQuests() || !CoopRuleTakeOnConnect())
            return;
        json p = json::array();
        int guild = 0;
        for (auto* li = CoopWorldNpcListFirst(ogame->GetGameWorld()); li; li = li->next) {
            oCNpc* npc = li->data;
            if (StoryNpcSkip(npc) || npc->IsDead())
                continue;
            const std::string name = DialogNpcName(npc);
            if (name.empty())
                continue;
            json jn;
            jn["n"] = name;
            if (npc->daily_routine > 0)
                if (zCPar_Symbol* rs = parser->GetSymbol(npc->daily_routine))
                    jn["r"] = rs->name.ToChar();
            if (!DlgGuildNpcHas(name))
                jn["at"] = npc->attitude;
            else {   // u162 (P169)
                auto b = DlgGuildNpcBase.find(name);
                if (b != DlgGuildNpcBase.end())
                    jn["at"] = b->second.att;
                guild++;
            }
            const CoopNpcFields f = DlgNpcFields(npc);   // u139 (P138)
            jn["fl"] = f.flags;
            jn["gu"] = f.guild;
            jn["gt"] = f.guildTrue;
            jn["nt"] = f.npcType;
            jn["nf"] = f.noFocus;
            p.push_back(jn);
        }
        if (p.empty())
            return;
        json j;
        j["q"] = 1;
        j["full"] = 1;
        j["p"] = p;
        DialogSend(j, SYNC_DIALOG_STATE);
        DialogLog("Story-Abgleich: Tagesablauf/Haltung/Felder aller %u NPCs an die Clients (%s)%s", (unsigned)p.size(), why,
            guild ? (", " + std::to_string(guild) + " mit Haltung je Held: Stand davor").c_str() : "");
    }

    // --- u96: Missions-Gegenstaende spiegeln ---------------------------------------------------------------------------------
    // Nutzer (28.10.2026, zum Quest-Inventar): "okay dann machen wir beides quest gegenstand mission gegenstaende spiegeln und Truhe
    // als Gegenstand". Missions-Gegenstaende (Flag ITM_FLAG_MI 1<<12, in den Skripten ITEM_MISSION - G2A 236, G1 74 Instanzen) hat
    // jeder Held gleich: bekommt einer einen (Dialog, Aufheben, Truhe, Pluendern), bekommt ihn der Partner auch; gibt einer einen ab
    // (Dialog, Skript, Fallenlassen), verliert ihn der Partner auch. Erkannt am Bestand des eigenen Helden (alle 0,3 s, gleich woher
    // die Aenderung kam), gemeldet als "mi" im Fortschritts-Paket (gilt auch, wenn der Partner in einer anderen Welt ist). Nicht
    // gemeldet: Laden und Uebernahme (danach erst neu zaehlen), GTs eigene Aenderungen (WorldSyncApplying) und das Gespiegelte selbst.
    // Nur mit Abgleich "Quests". Die Gilden-Belohnung (P110) uebergeht Missions-Gegenstaende - die kommen hierueber. Allgemein.
    static std::map<std::string, int> MiBase;   // Instanz -> Menge beim eigenen Helden (letzter Vergleich)
    static bool MiBaseKnown = false;
    static long long MiCheckMs = 0, MiQuietUntilMs = 0;

    // u104 (P126, Nutzer 29.10.: "danke das hat geklappt mit dem quest gegenstand. Jedoch müssen wir kennzeichnen dass diese Items
    // gespiegelt sind, also eigentlich nur ein mal verfügbar. Mache das optimal kenntlich"): solange gespiegelt wird (Mitspieler
    // verbunden, Abgleich "Quests" an), tragen die Missions-Gegenstaende des eigenen Helden Name und Beschreibung mit " (gespiegelt)"
    // und im Infofeld die Zeilen "Gespiegelt: gibt es nur einmal" / "Abgeben nimmt es beiden weg" - oCItemContainer::DrawItemInfo
    // (G2A 0x00706E40, G1 0x00667220) zeigt als Titel GetDescription (leer: GetName), darunter text[i]/count[i]; die Liste in G1
    // zeigt GetName. Jede Spiegelung meldet der Chat auf beiden Seiten. Im Coop-Inventar gibt es ihn nur dort - ohne Kennzeichnung;
    // ohne Spiegelung (getrennt, "Quests" aus) wieder die Skript-Texte. Gespeichert wird davon nichts: oCItem::Unarchive (G2A
    // 0x00713EB0, G1 0x00673370) liest nur Instanz, Menge und Flags und ruft InitByScript. Allgemein (G1/G2).
    // u106 (P128, Nutzer: "vielleicht brauchen wir es nicht als Systembenachrichtung jedes mal oben weil es sonst alles vollspammt. Wir
    // sollten auch einen anderen Namen finden als gespiegelt und die Beschreibung dementsprechend anpassen"): keine Chat-Meldungen mehr
    // (nur das Log), "gemeinsam" statt "gespiegelt" - wie beim Coop-Inventar ("Gemeinsames Inventar beider Helden").
    static const char* const MiKennName[2] = { " (gemeinsam)", " (shared)" };
    static const char* const MiKennZeile[2][2] = { { "Gemeinsamer Gegenstand beider Helden", "Nur einmal da - abgeben gilt f" "\xFC" "r beide" },
        { "Shared item of both heroes", "Exists only once - handing in counts for both" } };
    static bool MiKennAktiv = false;                     // gekennzeichnet - endet die Spiegelung, zurueck
    static long long MiKennMs = 0;

    // Text ohne die Kennzeichnung (beide Sprachen)
    static std::string MiOhneKenn(const char* s) {
        std::string t = s ? s : "";
        for (const char* k : MiKennName) {
            const size_t n = strlen(k);
            if (t.size() >= n && t.compare(t.size() - n, n, k) == 0)
                t.erase(t.size() - n);
        }
        return t;
    }

    static bool MiIstKennZeile(const char* s) {
        for (int l = 0; l < 2; l++)
            for (int i = 0; i < 2; i++)
                if (s && !strcmp(s, MiKennZeile[l][i]))
                    return true;
        return false;
    }

    // wird gerade gespiegelt: Mitspieler verbunden (Host: Clients da, Client: Verbindung steht) und Abgleich "Quests" an
    static bool MiSpiegelt() {
        if (!CoopRuleQuests() || (MyselfId == "_player_"))
            return false;
        return (ServerThread && CoopSaveSyncPeers() > 0) || (ClientThread && !ServerThread && CoopClientState == 2);
    }

    // Kennzeichnung herstellen (an, in der eingestellten Sprache) bzw. entfernen. Rueckgabe: etwas geaendert
    static bool MiKennSetzen(oCItem* it, bool an) {
        const int L = CoopLangEn ? 1 : 0;
        bool changed = false;
        zSTRING* felder[2] = { &it->name, &it->description };
        for (zSTRING* f : felder) {
            const std::string alt = f->ToChar();
            std::string neu = MiOhneKenn(alt.c_str());
            if (an && !neu.empty())
                neu += MiKennName[L];
            if (neu != alt) {
                *f = zSTRING(neu.c_str());
                changed = true;
            }
        }
        // Infozeilen: passen sie (beide da bzw. kein Platz fuer die zweite), bleibt alles; sonst eigene heraus und in freie Zeilen
        int p0 = -1, p1 = -1, frei = 0;
        bool fremd = false;
        for (int i = 0; i < ITM_TEXT_MAX; i++) {
            const char* t = it->text[i].ToChar();
            if (!MiIstKennZeile(t)) {
                if (!*t && !it->count[i])
                    frei++;
            }
            else if (p0 < 0 && !strcmp(t, MiKennZeile[L][0]))
                p0 = i;
            else if (p1 < 0 && !strcmp(t, MiKennZeile[L][1]))
                p1 = i;
            else
                fremd = true;   // andere Sprache bzw. doppelt
        }
        if (an ? (!fremd && p0 >= 0 && (p1 >= 0 || frei == 0)) : (p0 < 0 && p1 < 0 && !fremd))
            return changed;
        // u160 (P166): Sind alle Infozeilen belegt, passt keine Kennzeichnung hinein - bis u159 galt der Gegenstand dann bei jedem Takt als
        // neu gekennzeichnet (Testlauf b191, Gothic 1: zweimal je Sekunde "1 gekennzeichnet"). Jetzt zaehlt nur, was sich wirklich aendert.
        std::string vorText[ITM_TEXT_MAX];
        int vorCount[ITM_TEXT_MAX];
        for (int i = 0; i < ITM_TEXT_MAX; i++) {
            vorText[i] = it->text[i].ToChar();
            vorCount[i] = it->count[i];
        }
        for (int i = 0; i < ITM_TEXT_MAX; i++)
            if (MiIstKennZeile(it->text[i].ToChar())) {
                it->text[i] = zSTRING("");
                it->count[i] = 0;
            }
        int z = 0;
        for (int i = 0; an && z < 2 && i < ITM_TEXT_MAX; i++)
            if (!*it->text[i].ToChar() && !it->count[i])
                it->text[i] = zSTRING(MiKennZeile[L][z++]);
        if (an && !z) {
            static std::set<std::string> ohnePlatz;
            if (ohnePlatz.insert(it->GetInstanceName().ToChar()).second)
                DialogLog("Missions-Gegenstaende: %s hat keine freie Infozeile - gekennzeichnet nur im Namen", it->GetInstanceName().ToChar());
        }
        for (int i = 0; i < ITM_TEXT_MAX; i++)
            if (vorCount[i] != it->count[i] || vorText[i] != it->text[i].ToChar())
                changed = true;
        return changed;   // u160 (P166)
    }

    static void MiCount(std::map<std::string, int>& out) {
        out.clear();
        if (!player)
            return;
        player->inventory2.UnpackAllItems();
#if ENGINE >= Engine_G2
        for (zCListSort<oCItem>* n = player->inventory2.inventory.next; n; n = n->next)
            if (n->data && n->data->HasFlag(ITM_FLAG_MI))
                out[n->data->GetInstanceName().ToChar()] += CoopItemAmount(n->data);
#else
        for (int c = 0; c < INV_MAX; c++)
            for (zCListSort<oCItem>* n = player->inventory2.inventory[c].next; n; n = n->next)
                if (n->data && n->data->HasFlag(ITM_FLAG_MI))
                    out[n->data->GetInstanceName().ToChar()] += CoopItemAmount(n->data);
#endif
    }

    static oCItem* MiFind(const std::string& inst) {
        if (!player)
            return NULL;
#if ENGINE >= Engine_G2
        for (zCListSort<oCItem>* n = player->inventory2.inventory.next; n; n = n->next)
            if (n->data && n->data->HasFlag(ITM_FLAG_MI) && inst == n->data->GetInstanceName().ToChar())
                return n->data;
#else
        for (int c = 0; c < INV_MAX; c++)
            for (zCListSort<oCItem>* n = player->inventory2.inventory[c].next; n; n = n->next)
                if (n->data && n->data->HasFlag(ITM_FLAG_MI) && inst == n->data->GetInstanceName().ToChar())
                    return n->data;
#endif
        return NULL;
    }

    // u104: Kennzeichnung je 0,5 s bzw. sofort nach einer Spiegelung - Missions-Gegenstaende des eigenen Helden, solange gespiegelt
    // wird; die im Coop-Inventar nie. Laeuft auch ohne Coop (CoopDialogSyncPulse), dann nur einmal zurueck.
    static void MiKennPulse(bool sofort) {
        const long long now = GetCurrentMs();
        if ((!sofort && now < MiKennMs + 500) || !player || IsLoadingLevel)
            return;
        MiKennMs = now;
        const bool an = MiSpiegelt();
        if (!an && !MiKennAktiv)
            return;
        std::vector<oCItem*> its;
        player->inventory2.UnpackAllItems();
#if ENGINE >= Engine_G2
        for (zCListSort<oCItem>* n = player->inventory2.inventory.next; n; n = n->next)
            if (n->data && n->data->HasFlag(ITM_FLAG_MI))
                its.push_back(n->data);
#else
        for (int c = 0; c < INV_MAX; c++)
            for (zCListSort<oCItem>* n = player->inventory2.inventory[c].next; n; n = n->next)
                if (n->data && n->data->HasFlag(ITM_FLAG_MI))
                    its.push_back(n->data);
#endif
        int neu = 0, weg = 0;
        std::string namen;   // u160 (P166): welche
        for (oCItem* it : its)
            if (MiKennSetzen(it, an)) {
                (an ? neu : weg)++;
                if (namen.size() < 150)
                    namen += (namen.empty() ? "" : ", ") + std::string(it->GetInstanceName().ToChar());
            }
        if (CoopTruheObj)
            for (zCListSort<oCItem>* n = CoopTruheObj->containList.next; n; n = n->next)
                if (n->data && n->data->HasFlag(ITM_FLAG_MI) && MiKennSetzen(n->data, false))
                    weg++;
        if (neu)
            DialogLog("Missions-Gegenstaende: %d gekennzeichnet (gemeinsam): %s", neu, namen.c_str());
        if (weg)
            DialogLog("Missions-Gegenstaende: %d ohne Kennzeichnung (%s)", weg, an ? "im Coop-Inventar" : "keine Spiegelung");
        MiKennAktiv = an;
    }

    // nach dem Laden, einer Uebernahme bzw. eigenen Aenderungen: den Bestand erst nach quietMs neu aufnehmen (nichts melden)
    void CoopMissionReset(int quietMs) {
        MiBaseKnown = false;
        MiQuietUntilMs = (std::max)(MiQuietUntilMs, GetCurrentMs() + quietMs);
    }

    // u104 (Testlauf P126): Kennzeichnung des Gegenstands inst im eigenen Inventar - 1 vollstaendig (Name, Beschreibung soweit
    // vorhanden, erste Infozeile, eingestellte Sprache), 0 nicht bzw. nur teilweise, -1 nicht im Inventar
    int CoopMissionTestMark(const char* inst) {
        if (!player || !inst)
            return -1;
        oCItem* it = NULL;
        player->inventory2.UnpackAllItems();
#if ENGINE >= Engine_G2
        for (zCListSort<oCItem>* n = player->inventory2.inventory.next; n && !it; n = n->next)
            if (n->data && !strcmp(n->data->GetInstanceName().ToChar(), inst))
                it = n->data;
#else
        for (int c = 0; c < INV_MAX && !it; c++)
            for (zCListSort<oCItem>* n = player->inventory2.inventory[c].next; n && !it; n = n->next)
                if (n->data && !strcmp(n->data->GetInstanceName().ToChar(), inst))
                    it = n->data;
#endif
        if (!it)
            return -1;
        const int L = CoopLangEn ? 1 : 0;
        auto endsWith = [](const char* s, const char* k) {
            const size_t a = strlen(s), b = strlen(k);
            return a >= b && !strcmp(s + a - b, k);
        };
        const bool name = endsWith(it->name.ToChar(), MiKennName[L]);
        const bool desc = !*it->description.ToChar() || endsWith(it->description.ToChar(), MiKennName[L]);
        bool zeile = false;
        for (int i = 0; i < ITM_TEXT_MAX; i++)
            if (!strcmp(it->text[i].ToChar(), MiKennZeile[L][0]))
                zeile = true;
        return name && desc && zeile ? 1 : 0;
    }

    // u160 (P166, Testlauf): alle Infozeilen des Gegenstands inst belegen (kein Platz fuer die Kennzeichnung), dann dreimal kennzeichnen.
    // Rueckgabe: wie oft der zweite und dritte Durchgang noch eine Aenderung meldeten (soll 0), -1 nicht im Inventar. Danach wie vorher.
    int CoopMissionTestFullLines(const char* inst) {
        if (!player || !inst)
            return -1;
        oCItem* it = NULL;
        player->inventory2.UnpackAllItems();
#if ENGINE >= Engine_G2
        for (zCListSort<oCItem>* n = player->inventory2.inventory.next; n && !it; n = n->next)
            if (n->data && !strcmp(n->data->GetInstanceName().ToChar(), inst))
                it = n->data;
#else
        for (int c = 0; c < INV_MAX && !it; c++)
            for (zCListSort<oCItem>* n = player->inventory2.inventory[c].next; n && !it; n = n->next)
                if (n->data && !strcmp(n->data->GetInstanceName().ToChar(), inst))
                    it = n->data;
#endif
        if (!it)
            return -1;
        zSTRING text[ITM_TEXT_MAX];
        int count[ITM_TEXT_MAX];
        for (int i = 0; i < ITM_TEXT_MAX; i++) {
            text[i] = it->text[i];
            count[i] = it->count[i];
            it->text[i] = zSTRING(("Coop-Test " + std::to_string(i + 1)).c_str());
            it->count[i] = i + 1;
        }
        int n = 0;
        for (int k = 0; k < 3; k++)
            if (MiKennSetzen(it, true) && k > 0)
                n++;
        for (int i = 0; i < ITM_TEXT_MAX; i++) {
            it->text[i] = text[i];
            it->count[i] = count[i];
        }
        MiKennSetzen(it, MiSpiegelt());
        return n;
    }

    // u149 (P152): Spiegelungen des Partners, solange der Held verwandelt ist
    static std::vector<std::pair<json, std::string>> MiWaiting;
    static void MiApply(const json& d, const std::string& by);

    // Game_Loop (CoopDialogSyncPulse): Bestand vergleichen, Aenderungen an den Partner
    // u149 (P152, Lauf b118: "Missions-Gegenstaende: ALTESSCHWERT -4, ITAT_CRAWLERQUEEN -4, ITKE_FOCUS4 -1 ... - an den Partner gespiegelt", beim Host "gespiegelt: ALTESSCHWERT -4 ..."): Verwandelt ist player das Tier mit
    // leerem Inventar, das galt als Verlust aller Missions-Gegenstaende und nahm sie auch dem Partner. Solange nicht vergleichen; danach neu aufnehmen, der Held hat sein Inventar wieder
    static void CoopMissionPulse() {
        const long long now = GetCurrentMs();
        if (now < MiCheckMs + 300)
            return;
        MiCheckMs = now;
        if (!player || IsSavingGame || !CoopRuleQuests() || WorldSyncApplying || now < MiQuietUntilMs || CoopHeroSwapped()) {
            MiBaseKnown = false;
            return;
        }
        if (!MiWaiting.empty()) {
            std::vector<std::pair<json, std::string>> w;
            w.swap(MiWaiting);
            for (auto& x : w)
                MiApply(x.first, x.second);
        }
        std::map<std::string, int> cur;
        MiCount(cur);
        if (!MiBaseKnown) {
            MiBase = cur;
            MiBaseKnown = true;
            return;
        }
        json d = json::array();
        std::string shown;
        for (auto& kv : cur) {
            auto b = MiBase.find(kv.first);
            const int delta = kv.second - (b == MiBase.end() ? 0 : b->second);
            if (delta) {
                d.push_back(json::array({ kv.first, delta }));
                shown += (shown.empty() ? "" : ", ") + kv.first + (delta > 0 ? " +" : " ") + std::to_string(delta);
            }
        }
        for (auto& kv : MiBase)
            if (!cur.count(kv.first) && kv.second) {
                d.push_back(json::array({ kv.first, -kv.second }));
                shown += (shown.empty() ? "" : ", ") + kv.first + " " + std::to_string(-kv.second);
            }
        MiBase = cur;
        if (d.empty())
            return;
        json j;
        j["mi"] = d;
        DialogSend(j, SYNC_DIALOG_STATE);
        DialogLog("Missions-Gegenstaende: %s - an den Partner gespiegelt", shown.c_str());
        MiKennPulse(true);   // u104
    }

    // Paket "mi" des Partners: dieselbe Aenderung am eigenen Helden (nur Missions-Gegenstaende)
    static void MiApply(const json& d, const std::string& by) {
        if (!player || !parser || !d.is_array())
            return;
        if (CoopHeroSwapped()) {   // u149 (P152): Das Tier bekaeme es und naehme es mit - warten, bis der Held zurueck ist (CoopMissionPulse)
            MiWaiting.push_back(std::make_pair(d, by));
            DialogLog("Missions-Gegenstaende von %s: Held verwandelt - wartet (%d)", by.c_str(), (int)MiWaiting.size());
            return;
        }
        std::string shown;
        WorldSyncApplying++;
        for (auto& x : d) {
            if (!x.is_array() || x.size() < 2 || !x.at(0).is_string() || !x.at(1).is_number_integer())
                continue;
            const std::string inst = x.at(0).get<std::string>();
            const int delta = x.at(1).get<int>();
            const int idx = parser->GetIndex(zSTRING(inst.c_str()));
            if (idx < 0 || !delta || delta > 1000 || delta < -1000)
                continue;
            int done = 0;
            if (delta > 0) {
                int left = delta;
                while (left > 0) {
                    oCItem* it = CreateCoopItem(idx);
                    if (!it)
                        break;
                    if (!it->HasFlag(ITM_FLAG_MI)) {   // nur Missions-Gegenstaende
                        it->Release();
                        break;
                    }
                    const bool multi = (it->flags & ITM_FLAG_MULTI) != 0;
                    it->amount = multi ? left : 1;
                    left -= it->amount;
                    done += it->amount;
                    player->PutInInv(it);
                }
            }
            else {
                int left = -delta;
                while (left > 0) {
                    oCItem* have = MiFind(inst);
                    if (!have)
                        break;
                    const int n = (std::min)(left, CoopItemAmount(have));
                    oCItem* r = player->RemoveFromInv(have, n);
                    if (r)
                        ogame->GetGameWorld()->RemoveVob(r);
                    left -= n;
                    done -= n;
                }
            }
            if (done) {
                shown += (shown.empty() ? "" : ", ") + inst + (done > 0 ? " +" : " ") + std::to_string(done) +
                    (done != delta ? " (gemeldet " + std::to_string(delta) + ")" : std::string());
                if (MiBaseKnown)   // das Gespiegelte nicht zurueckmelden; eine eigene Aenderung im selben Moment bleibt sichtbar
                    MiBase[inst] += done;
            }
        }
        WorldSyncApplying--;
        if (!shown.empty()) {
            DialogLog("Missions-Gegenstaende von %s gespiegelt: %s", by.c_str(), shown.c_str());
            MiKennPulse(true);
        }
    }

    void CoopTruheReceive(const json& t, const std::string& by);   // u97: CoopTruhe.cpp

    // u163 (P170): Inventar-Aenderung aus dem Gespraech des Partners bei meiner Kopie des NPCs - anlegen wie CreateInvItems (oCNpc::CreateItems),
    // herausnehmen wie der Welt-Abgleich (NpcRemoveItems). Rueckgabe: geaenderte Stueck, Vorzeichen wie d
    static int DlgInvApply(oCNpc* npc, const std::string& inst, int d) {
        const int idx = parser->GetIndex(zSTRING(inst.c_str()));
        zCPar_Symbol* s = idx >= 0 ? parser->GetSymbol(idx) : NULL;
        if (!npc || !s || s->type != zPAR_TYPE_INSTANCE || !d || d > 100000 || d < -100000)
            return 0;
        if (d < 0)
            return -NpcRemoveItems(npc, inst, -d);
        WorldSyncApplying++;
        npc->CreateItems(idx, d);
        WorldSyncApplying--;
        return d;
    }

    static void DialogApplyState(json& ein, const std::string& by, bool sameWorld) {
        if (!parser)
            return;
        if (ein.contains("truhe") && ein["truhe"].is_object()) {   // u97: gemeinsame Coop-Truhe - eigenes Paket, sonst nichts darin
            CoopTruheReceive(ein["truhe"], by);
            return;
        }
        json e = ein;   // v75: Kopie - wird je nach Abgleich-Regel gefiltert, das Paket selbst bleibt (Weiterleiten)
        DlgBuildIntSlots();
        int told = 0, vars = 0, logs = 0, npcs = 0, pending = 0;
        // v75: Abgleich-Regeln des Hosts - "Quests" (erzaehlte Dialoge, Skript-Variablen, NPC-Zustaende, Gildenhaltungen, Quest-EP)
        // und "Tagebuch" einzeln. Was aus ist, wird hier nicht uebernommen.
        const bool quests = CoopRuleQuests(), diary = CoopRuleLog();
        if (!quests || !diary) {
            json f = json::object();
            for (auto it = e.begin(); it != e.end(); ++it) {
                const std::string k = it.key();
                if ((!quests && (k == "i" || k == "v" || k == "p" || k == "g" || k == "xp" || k == "ch" || k == "mi" || k == "we" || k == "ni")) || (!diary && k == "l"))
                    continue;
                f[k] = it.value();
            }
            static CoopDiagBudget budget = { 0, 0 };
            if (f.size() != e.size() && CoopDiagAllow(budget, 20))
                DialogLog("Fortschritt von %s: %s%s nicht uebernommen (Einstellung Abgleich)", by.c_str(), quests ? "" : "Quest-Teil ",
                    diary ? "" : "Tagebuch");
            e = f;
        }
        if (e.contains("we")) {   // u141 (P141): Eintritts-Merker des Partners - gelten nur in derselben Welt, eigenes Paket
            if (sameWorld && e.contains("wt") && e["wt"].is_string()) {
                const std::string w = e["wt"].get<std::string>();
                CoopWorldEntryVarsSet(e["we"], w, true);
                for (auto& v : e["we"])   // kein Echo im Story-Takt - nur die gemeldeten, eine eigene Aenderung im selben Moment geht noch hinaus
                    if (v.is_array() && v.size() == 2 && v.at(0).is_string() && v.at(1).is_number_integer())
                        StoryEntryBase[v.at(0).get<std::string>()] = v.at(1).get<int>();
            }
            return;
        }
        if (e.contains("mi"))   // u96: Missions-Gegenstaende des Partners
            MiApply(e["mi"], by);
        // u85 (P110): Gilden je Held (Variante C) - eine Gilden-Info gilt hier nur, wenn mein Held in einer der abgefragten Gilden ist
        // (dann samt Belohnung); sonst behaelt jeder seinen eigenen Fortschritt. Die Aufnahme des Partners gilt hier nie als erzaehlt -
        // ich trete selbst bei. Variablen aus beidem gelten je Held (kein Story-Abgleich mehr)
        std::vector<int> gi;
        if (e.contains("gi") && e["gi"].is_array())
            for (auto& x : e["gi"])
                if (x.is_number_integer())
                    gi.push_back(x.get<int>());
        const bool joinInfo = e.contains("join") && e["join"].is_number_integer();
        const bool mineGuild = !gi.empty() && player && std::find(gi.begin(), gi.end(), player->guild) != gi.end();
        if ((!gi.empty() || joinInfo) && e.contains("v") && e["v"].is_array())
            for (auto& v : e["v"])
                if (v.is_array() && !v.empty() && v.at(0).is_string())
                    if (zCPar_Symbol* s = parser->GetSymbol(zSTRING(v.at(0).get<std::string>().c_str()))) {
                        DlgGuildVars.insert(s);
                        const int k = v.size() > 1 && v.at(1).is_number_integer() ? v.at(1).get<int>() : -1;   // u154 (P159): hier steht noch der Wert davor
                        if (s->type == zPAR_TYPE_INT && k >= 0 && k < (s->ele > 1 ? (int)s->ele : 1)) {
                            int cur = 0;
                            s->GetValue(cur, k);
                            DlgGuildVarBase.emplace(std::make_pair(s, k), cur);
                        }
                    }
        if (joinInfo && e.contains("i") && e["i"].is_string())   // u150 (P154): gilt auch beim Laden je Held
            DlgGuildInfos.insert(e["i"].get<std::string>());
        if ((!gi.empty() || joinInfo) && e.contains("l") && e["l"].is_array())
            for (auto& jt : e["l"])
                if (jt.is_object() && jt.contains("t") && jt["t"].is_string())
                    DlgGuildTopics.insert(jt["t"].get<std::string>());
        if ((!gi.empty() || joinInfo) && e.contains("p") && e["p"].is_array())   // u152 (P156)
            for (auto& jn : e["p"]) {
                DlgGuildNpcNote(jn);
                if (oCNpc* npc = jn.is_object() && jn.contains("n") && jn["n"].is_string() ? DialogNpcByName(jn["n"].get<std::string>()) : NULL)   // u154 (P159)
                    DlgGuildNpcBaseKeep(jn, npc->attitude, npc->tmp_attitude, npc->aiscriptvars);
            }
        if (joinInfo || (!gi.empty() && !mineGuild)) {
            const std::string what = e.contains("i") && e["i"].is_string() ? e["i"].get<std::string>() : std::string("Auswahl");
            for (const char* k : { "i", "v", "l", "xp", "p", "it" })
                e.erase(k);
            static CoopDiagBudget gb = { 0, 0 };
            if (CoopDiagAllow(gb, 30)) {
                if (joinInfo)
                    DialogLog("Gilden je Held: %s trat in %s der Gilde %d bei - hier nicht erzaehlt, nicht uebernommen (eigener Beitritt)",
                        by.c_str(), what.c_str(), e["join"].get<int>());
                else
                    DialogLog("Gilden je Held: %s von %s fragt Gilde %s ab, mein Held ist in Gilde %d - eigener Fortschritt, nicht uebernommen",
                        what.c_str(), by.c_str(), DlgGuildText(gi).c_str(), player ? player->guild : -1);
            }
        }
        oCInfo* toldInfo = NULL;
        if (e.contains("i") && e["i"].is_string()) {
            const int idx = parser->GetIndex(zSTRING(e["i"].get<std::string>().c_str()));
            oCInfo* info = (idx >= 0 && ogame->GetInfoManager()) ? ogame->GetInfoManager()->GetInformation(idx) : NULL;
            if (info && !info->told) {
                info->told = TRUE;
                told = 1;
                toldInfo = info;
            }
        }
        std::string varNames;   // v92: Namen im Log (Test v91: welche Werte kamen an?)
        if (e.contains("v"))
            for (auto& v : e["v"]) {
                zCPar_Symbol* sym = parser->GetSymbol(zSTRING(v.at(0).get<std::string>().c_str()));
                const int k = v.at(1).get<int>();
                const int ele = sym && sym->ele > 1 ? (int)sym->ele : 1;
                const int val = v.at(2).get<int>();
                if (!sym || sym->type != zPAR_TYPE_INT || (sym->flags & (zPAR_FLAG_CONST | zPAR_FLAG_CLASSVAR)) || k < 0 || k >= ele
                    || !StoryValueOk(val) || StoryIsHeroVar(sym) || DlgNeverSync(sym->name.ToChar())   // v31: Heldenwerte nie uebernehmen (auch von aelteren Fassungen)
                    || (e.contains("q") && DlgGuildVars.count(sym)))   // u85: Werte aus Gilden-Infos nicht ueber den Story-Abgleich
                    continue;
                int old = 0;
                sym->GetValue(old, k);
                // u199 (P213): Zaehler aus "deltaVars" - die Aenderung des Absenders (alter Wert im Paket) zum eigenen Wert zaehlen, damit ein
                // eigener, noch nicht gesendeter Schritt erhalten bleibt; der Vergleichsstand rueckt nur um diese Aenderung (der eigene geht noch hinaus)
                const bool delta = v.size() >= 4 && v.at(3).is_number_integer() && CoopModDeltaVar(sym->name.ToChar());
                const int step = delta ? val - v.at(3).get<int>() : 0;
                const int now = delta ? old + step : val;
                if (delta && !StoryValueOk(now))
                    continue;
                const int camp = CoopProfileIsOthello() ? DialogRepCamp(sym) : 0;   // v92 (nur Othello): Ruf mit Othellos Meldung
                if (camp && k == 0 && now > old && DialogScriptIncreaseRep(camp, now - old))
                    DialogLog("Ruf: %s %d -> %d ueber B_IncreaseRep (Meldung wie beim Partner)", sym->name.ToChar(), old, now);
                sym->SetValue(now, k);
                vars++;
                if (varNames.size() < 300)
                    varNames += (varNames.empty() ? "" : ", ") + std::string(sym->name.ToChar()) + (ele > 1 ? "[" + std::to_string(k) + "]" : "")
                        + "=" + std::to_string(now) + (delta ? " (Zaehler " + std::string(step >= 0 ? "+" : "") + std::to_string(step) + ")" : "");
                auto slot = DlgSlotIndex.find(std::make_pair(sym, k));   // kein Echo im Story-Takt
                if ((StoryReady || StoryLevelChange) && slot != DlgSlotIndex.end() && slot->second < (int)StoryBaseInts.size()) {
                    if (delta)
                        StoryBaseInts[slot->second] += step;
                    else
                        StoryBaseInts[slot->second] = val;
                }
            }
        // v92: Kapitel-Bildschirm des Partners (IntroduceChapter, siehe CoopExtIntroduceChapter)
        // v94 (Test v93: "Kapitel 1 hat beim Client direkt getriggert"): erst, wenn das Gespraech des Absenders hier zu Ende ist
        if (e.contains("ch") && e["ch"].is_array() && e["ch"].size() == 5 && gameMan) {
            if (DialogPartnerTalking(by)) {
                ChapterPending.push_back({ by, e["ch"], CurrentMs });
                DialogLog("Kapitel-Bildschirm von %s: %s - erst nach seinem Gespr\xE4" "ch", by.c_str(),
                    e["ch"][0].is_string() ? e["ch"][0].get<std::string>().c_str() : "?");
            }
            else
                DialogShowChapter(e["ch"], by, "");
        }
        if (e.contains("vid") && CoopRuleQuests())   // u28 (B5); u55 mit Nummer fuers gemeinsame Ueberspringen
            DialogPlayVideo(e["vid"], e.contains("vidno") && e["vidno"].is_number_integer() ? (long)e["vidno"].get<long long>() : 0, by);
        if (e.contains("exses") && CoopRuleQuests())   // u147 (P149)
            DialogExitSession(e["exses"], by);
        if (e.contains("l")) {
            logs = DialogApplyLog(e["l"]);
            if (StoryReady || StoryLevelChange)
                for (auto& jt : e["l"]) {
                    const std::string t = jt.at("t").get<std::string>();
                    if (oCLogTopic* tp = DialogFindTopic(t))
                        StoryBaseLog[t] = StoryTopicNow(tp);
                }
        }
        if (e.contains("p") && sameWorld)
            for (auto& jn : e["p"]) {
                const std::string n = jn.at("n").get<std::string>();
                if (ServerThread)   // u199 (P217): AIV_PARTYMEMBER aus dem Paket eines Clients - Begleiter dieses Clients
                    PartyNoteEntry(jn, by);
                if (e.contains("q"))   // u152 (P156)
                    DlgGuildNpcStrip(jn);
                DialogDropPendingNpc(n);   // ein neuerer Stand ersetzt einen noch wartenden
                if (DialogApplyNpcEntry(jn))
                    npcs++;
                else if (n != DialogMe() && !IsCoopPlayer(n)) {
                    DialogPendingNpcs.push_back({ jn, by, CoopWorldName(), CurrentMs });
                    pending++;
                }
            }
        if (e.contains("ni") && e["ni"].is_array()) {   // u163 (P170): Inventar von Welt-NPCs aus dem Gespraech des Partners
            int done = 0, miss = 0;
            std::string text;
            for (auto& x : e["ni"]) {
                if (!sameWorld || !x.is_array() || x.size() != 3 || !x.at(0).is_string() || !x.at(1).is_string() || !x.at(2).is_number_integer())
                    continue;
                const std::string n = x.at(0).get<std::string>(), inst = x.at(1).get<std::string>();
                const int d = x.at(2).get<int>(), got = DlgInvApply(DialogNpcByName(n), inst, d);
                if (got)
                    done++;
                if (got != d)
                    miss++;
                if (text.size() < 200)
                    text += (text.empty() ? "" : ", ") + n + " " + (d > 0 ? "+" : "") + std::to_string(got) + "/" + std::to_string(d) + " " + inst;
            }
            DialogLog("Inventar von NPCs aus dem Gespr\xE4" "ch von %s: %s", by.c_str(), sameWorld ?
                (std::to_string(done) + " von " + std::to_string(e["ni"].size()) + " uebernommen" + (miss ? " (" + std::to_string(miss) + " nicht ganz)" : "") +
                    " - " + text).c_str() : "andere Welt - nicht uebernommen");
        }
        int xpGiven = 0;
        if (e.contains("xp") && e["xp"].is_number()) {   // v31: Quest-EP auch fuer den eigenen Helden
            const int xp = e["xp"].get<int>();
            if (xp > 0 && xp < 1000000) {
                if (DialogScriptGiveXP(xp))
                    xpGiven = xp;
                else if (player) {   // Rueckfall ohne Skript: nur die Erfahrung, ohne Stufenaufstieg/Meldung
                    player->experience_points += xp;
                    xpGiven = xp;
                    DialogLog("Erfahrung: B_GIVEXP nicht nutzbar - %d EP direkt gutgeschrieben (ohne Stufenaufstieg)", xp);
                }
            }
        }
        int gotItems = 0;   // u85: Belohnung aus einer Gilden-Quest meiner Gilde - der Partner bekam sie, ich auch
        if (mineGuild && player && e.contains("it") && e["it"].is_array())
            for (auto& x : e["it"]) {
                if (!x.is_array() || x.size() < 2 || !x.at(0).is_string() || !x.at(1).is_number_integer())
                    continue;
                const int idx = parser->GetIndex(zSTRING(x.at(0).get<std::string>().c_str()));
                int left = x.at(1).get<int>();
                if (idx < 0 || left <= 0 || left > 100000)
                    continue;
                while (left > 0) {
                    oCItem* it = CreateCoopItem(idx);
                    if (!it)
                        break;
                    if (it->HasFlag(ITM_FLAG_MI)) {   // u96: Missions-Gegenstaende kommen gespiegelt ("mi") - nicht noch einmal
                        it->Release();
                        break;
                    }
                    const bool multi = (it->flags & ITM_FLAG_MULTI) != 0;
                    it->amount = multi ? left : 1;
                    left -= it->amount;
                    gotItems += it->amount;
                    player->PutInInv(it);
                }
            }
        if (gotItems)
            DialogLog("Gilden je Held: Belohnung von %s uebernommen (gleiche Gilde %d): %d Stueck", by.c_str(), player->guild, gotItems);
        int guilds = 0;
        if (e.contains("g")) {   // v31: Gildenhaltungen (global)
            oCGuilds* g = ogame->GetGuilds();
            for (auto& x : e["g"]) {
                const int g1 = x.at(0).get<int>(), g2 = x.at(1).get<int>(), v = x.at(2).get<int>();
                if (!g || !g->attitude || g1 < 0 || g2 < 0 || g1 >= g->size || g2 >= g->size || v < 0 || v > 255)
                    continue;
                g->SetAttitude(g1, g2, (unsigned char)v);
                if (StoryReady && g->size == StoryGuildSize && (size_t)(g2 * g->size + g1) < StoryBaseGuilds.size())
                    StoryBaseGuilds[g2 * g->size + g1] = (unsigned char)v;
                guilds++;
            }
        }
        DialogLog("%s von %s uebernommen (%s): Info %s, %d Variablen, %d Tagebuch-Aenderungen, %d NPCs%s, %d Gildenhaltungen, %d EP%s%s",
            e.contains("q") ? "Story" : "Fortschritt", by.c_str(),
            e.contains("i") ? e["i"].get<std::string>().c_str() : "-", told ? "neu" : "-", vars, logs, npcs,
            pending ? (" (+" + std::to_string(pending) + " warten auf ihren Namen)").c_str() : "", guilds, xpGiven,
            varNames.empty() ? "" : " - ", varNames.c_str());
        // v92 (nur Othello): Diegos Spielstart - der eigene Held bekam den Bonus nicht (das Gespraech fuehrte der Partner).
        // u5: Gothic 1 selbst hat dieselbe Info ohne Bonus - dort nichts ausfuehren
        if (toldInfo && CoopProfileIsOthello() && !_stricmp(toldInfo->name.ToChar(), "INFO_DIEGO_GAMESTART"))
            DialogRunHeroPart(toldInfo->pd.information, "INFO_DIEGO_GAMESTART");
    }

    // --- Story-Abgleich ausserhalb von Dialogen (v28) ---------------------------------------------
    //
    // Jede Sekunde: globale Skript-Ganzzahlen und Tagebuch gegen den Vergleichsstand. Neue Aenderungen (Buch gelesen,
    // Trigger, Quest-NPC tot, Skript ...) gehen als DIALOG_STATE {q = 1, v, l} an den Partner. Variablen, die sich mehr als
    // STORY_NOISY_MAX mal in 30 s aendern (Hilfsvariablen der KI), sind fuer die Sitzung ausgeschlossen; ebenso Werte, die
    // wie Zeiger aussehen, und coopStoryIgnore aus der Konfiguration.

    static const int STORY_NOISY_MAX = 12;

    // u48: ausgeschlossen - coopStoryIgnore/fest (StoryReadConfig) und alle "..._RANDOMIZER": die Instanzfunktion eines Monsters
    // setzt sie beim Erzeugen per Hlp_Random (Aussehen/Waffe); jeder PC erzeugt eigene NPCs (Weltstart, Abgleich), die Werte sind
    // Zufall, keine Geschichte. Test u47: "Alle Skript-Variablen (ueber Welten)" FEHLER mit GOBLINGREEN_/GOBLINBLACK_/ORC_RANDOMIZER.
    // G2 (Skriptnamen aus G2 NotR), schadet in G1 nicht.
    static bool StoryIgnored(const std::string& nm) {
        static const char suffix[] = "_RANDOMIZER";
        const size_t n = sizeof(suffix) - 1;
        if (nm.size() > n && nm.compare(nm.size() - n, n, suffix) == 0)
            return true;
        if (nm.compare(0, 5, "FUNL_") == 0)   // u203: Fun-Modus - Variablen je PC
            return true;
        return StoryIgnore.count(nm) > 0;
    }

    static void StoryReadConfig() {
        if (StoryCfgRead)
            return;
        StoryCfgRead = true;
        // fest ausgeschlossen: beschreibt den eigenen Helden, nicht die Geschichte (Log v28: TALKING bei jedem Dialog)
        StoryIgnore.insert("TALKING");
        StoryIgnore.insert("MOVE_ENTRY");   // v30: Anzeige-Umschalter in B_LogEntry (wechselt bei jedem Eintrag, auch beim Anwenden)
        if (CoopConfig.contains("coopStorySync") && CoopConfig["coopStorySync"].is_boolean())
            StorySyncOn = CoopConfig["coopStorySync"].get<bool>();
        if (CoopConfig.contains("coopStoryIgnore") && CoopConfig["coopStoryIgnore"].is_array())
            for (auto const& v : CoopConfig["coopStoryIgnore"])
                if (v.is_string()) {
                    zSTRING s(v.get<std::string>().c_str());
                    s.Upper();
                    StoryIgnore.insert(s.ToChar());
                }
        DialogLog("Story-Abgleich %s, %u Variablen ausgeschlossen (coopStoryIgnore)", StorySyncOn ? "an" : "AUS",
            (unsigned)StoryIgnore.size());
    }

    static void StoryTakeBaseline() {
        DlgBuildIntSlots();
        StoryBaseInts.resize(DlgIntSlots.size());
        for (size_t i = 0; i < DlgIntSlots.size(); i++) {
            int v = 0;
            DlgIntSlots[i].sym->GetValue(v, DlgIntSlots[i].idx);
            StoryBaseInts[i] = v;
        }
        if (StoryNoisy.size() != DlgIntSlots.size()) {
            StoryNoisy.assign(DlgIntSlots.size(), 0);
            StoryChangeTimes.assign(DlgIntSlots.size(), std::deque<long long>());
        }
        StoryBaseLog.clear();
        std::vector<CoopDlgTopic> log;
        DlgSnapLog(log);
        for (auto& t : log)
            StoryBaseLog[t.t] = t;
        StorySnapNpcs();
        StorySnapGuilds();
        StoryEntryBase.clear();   // u141 (P141): im naechsten Takt gehen die gesetzten Merker dieser Welt hinaus
        StoryReady = true;
        DialogLog("Story-Abgleich: Vergleichsstand aufgenommen (%u Variablen, %u Tagebuch-Themen)",
            (unsigned)StoryBaseInts.size(), (unsigned)StoryBaseLog.size());
    }

    // Tagebuch gegen den Vergleichsstand, der Stand rueckt nach; Anzahl der Themen mit Unterschied
    static int StoryLogDiff(json& l) {
        int nl = 0;
        oCLogManager& lm = oCLogManager::GetLogManager();
        for (auto* it = lm.m_lstTopics.GetNextInList(); it; it = it->GetNextInList()) {
            oCLogTopic* tp = it->GetData();
            if (!tp)
                continue;
            const std::string name = tp->m_strDescription.ToChar();
            if (DlgGuildTopics.count(name))   // u150 (P154): gilt je Held wie die Werte aus Gilden-Infos
                continue;
            auto f = StoryBaseLog.find(name);
            if (f != StoryBaseLog.end() && f->second.st == (int)tp->m_enuStatus
                && (int)f->second.e.size() == tp->m_lstEntries.GetNumInList())
                continue;   // unveraendert (Status und Anzahl) - Eintraege nicht einzeln kopieren
            const CoopDlgTopic t = StoryTopicNow(tp);
            json jt;
            if (DlgTopicDiff(f == StoryBaseLog.end() ? NULL : &f->second, t, jt)) {
                l.push_back(jt);
                nl++;
            }
            StoryBaseLog[name] = t;
        }
        return nl;
    }

    // u141 (P141): Der Merker der Welt, in der ich stehe, gilt auch fuer den Partner in derselben Welt: Sie teilen ihren Stand. Kapitelwechsel im Gespraech: B_Kapitelwechsel
    // ruft B_Enter_* nur beim Sprechenden, die NPCs kommen ueber den Host zu beiden, der Merker des anderen blieb aber 0 - bei seinem naechsten Laden lief das Skript
    // dort noch einmal. Nur gesetzte Merker, der Empfaenger hebt nur an; ist der Partner in einer anderen Welt, verwirft er das Paket (P72, seine Kopie ist eine andere).
    static void StoryEntryTick() {
        if (!CoopRuleQuests())
            return;
        const std::string world = WxWorldTag(CoopWorldName());
        json ch = json::array();
        for (auto& v : CoopWorldEntryVarsGet(world)) {
            const std::string n = v.at(0).get<std::string>();
            const int val = v.at(1).get<int>();
            auto f = StoryEntryBase.find(n);
            if (f != StoryEntryBase.end() && f->second == val)
                continue;
            StoryEntryBase[n] = val;
            if (val)
                ch.push_back(v);
        }
        if (ch.empty())
            return;
        json j;
        j["q"] = 1;
        j["wt"] = world;
        j["we"] = ch;
        DialogSend(j, SYNC_DIALOG_STATE);
        DialogLog("Eintritts-Merker von %s -> Partner: %s", world.c_str(), ch.dump().c_str());
    }

    // u140 (P139; Pruefrunde b74: "ENGROMISGONE: hier 1, Partner 0", "SENGRATH_MISSING"): Der Vergleichsstand wird nach jedem Laden neu aufgenommen
    // und schluckt, was die Init-Skripte setzen. Beim Laden eines Spielstands ist das richtig, beim Weltwechsel gehen so echte Geschichtswerte
    // verloren: Was B_Enter_*/INIT_* beim Ersten setzen (ENGROMISGONE, KAPITEL, MIS_RESCUEBILGOT, B_CHAPTER4_ONETIME ...), kam beim Partner nie an, und
    // der Zweite setzte es selbst nicht mehr, weil er die Welt schon im Stand des Ersten fand. Jetzt geht beim Weltwechsel erst der Unterschied
    // zum Stand davor hinaus. Allgemein (G2A viele, G1 ENTEREDTEMPLE).
    static void StorySendLevelChange() {
        if (!StoryLevelChange)
            return;
        StoryLevelChange = false;
        DlgBuildIntSlots();
        if (StoryBaseInts.size() != DlgIntSlots.size())
            return;
        json v = json::array();
        std::string names;
        for (size_t i = 0; i < DlgIntSlots.size(); i++) {
            int cur = 0;
            DlgIntSlots[i].sym->GetValue(cur, DlgIntSlots[i].idx);
            const int old = StoryBaseInts[i];
            const char* nm = DlgIntSlots[i].sym->name.ToChar();
            if (cur == old || (i < StoryNoisy.size() && StoryNoisy[i]) || StoryIgnored(nm) || DlgGuildVars.count(DlgIntSlots[i].sym) ||
                !StoryValueOk(cur) || !StoryValueOk(old))
                continue;
            v.push_back(DlgVarEntry(DlgIntSlots[i].sym, DlgIntSlots[i].idx, cur, old));   // u199 (P213)
            if (names.size() < 300)
                names += (names.empty() ? "" : ", ") + std::string(nm) + "=" + std::to_string(cur);
        }
        json l = json::array();   // u141 (P141): auch das Tagebuch - der Zweite fuehrt das Einzugs-Skript seit P139 nicht mehr aus ("Die Drachenjaeger")
        const int nl = StoryLogDiff(l);
        if (v.empty() && !nl)
            return;
        json j;
        j["q"] = 1;
        if (!v.empty())
            j["v"] = v;
        if (nl)
            j["l"] = l;
        DialogSend(j, SYNC_DIALOG_STATE);
        DialogLog("Story-Abgleich: %u Variablen (%s), %d Tagebuch-Themen aus dem Weltwechsel -> Partner", (unsigned)v.size(), names.c_str(), nl);
    }

    // u140 (P140): Spielstaende von vor P138. Vom Test-Fenster (b74, 05:13): Der Client sprach mit dem Drachen, die gemeinsame Sicherung enthielt die Welt des
    // Hosts mit flags = 2, abgeglichen waren die Infos und DRAGONTALK_EXIT_FREE = 0. Nach dem Laden war der Drache auf beiden PCs unsterblich, ein Gespraech
    // nicht mehr moeglich, die Hauptgeschichte hing. Wer DIA_DRAGON_*_EXIT gehoert hat, hat den Schutz aufgehoben (das Skript setzt flags = 0) - steht er noch,
    // hebt GT ihn auf. Nach jedem Laden und Weltwechsel, nur fuer die NPCs dieser Infos. Allgemein (die Infos gibt es nur in G2).
    static int DlgDragonsHeal() {
        if (!parser || !ogame || !ogame->GetInfoManager() || !ogame->GetGameWorld())
            return 0;
        std::set<int> done;
        for (auto* l = ogame->GetInfoManager()->infoList.GetNextInList(); l; l = l->GetNextInList()) {
            oCInfo* info = l->GetData();
            if (!info || !info->told)
                continue;
            const char* nm = info->name.ToChar();
            const size_t len = strlen(nm);
            if (len > 16 && !strncmp(nm, "DIA_DRAGON_", 11) && !strcmp(nm + len - 5, "_EXIT"))   // Instanz aus dem Namen: pd.npc setzt erst ein Skript des Drachen
                done.insert(parser->GetIndex(zSTRING(std::string(nm + 4, len - 9).c_str())));
        }
        int n = 0;
        if (!done.empty())
            for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l; l = l->next) {
                oCNpc* npc = l->data;
                if (!npc || !(npc->variousFlags & NPC_FLAG_IMMORTAL) || !done.count(npc->GetInstance()))
                    continue;
                npc->variousFlags &= ~NPC_FLAG_IMMORTAL;
                n++;
                DialogLog("Drache %s: Abschluss-Gespraech gehoert, aber noch unsterblich - Schutz aufgehoben", npc->GetObjectName().ToChar());
            }
        return n;
    }

    // UnionHooks.cpp: Beginn eines Ladevorgangs - Weltwechsel (true) bzw. Spielstand oder neues Spiel (false)
    void CoopDialogSyncLoadKind(bool levelChange) {
        StoryLevelChange = levelChange && StoryReady && DialogSyncAktiv();
    }

    static void StoryTick() {
        if (!StoryReady) {
            StorySendLevelChange();   // u140 (P139)
            DlgDragonsHeal();         // u140 (P140): vor dem Vergleichsstand - jeder PC heilt selbst
            StoryTakeBaseline();
            return;
        }
        DlgBuildIntSlots();
        if (!StoryReady || StoryBaseInts.size() != DlgIntSlots.size()) {
            StoryTakeBaseline();
            return;
        }
        StoryEntryTick();   // u141 (P141)
        json v = json::array();
        int nv = 0;
        for (size_t i = 0; i < DlgIntSlots.size(); i++) {
            int cur = 0;
            DlgIntSlots[i].sym->GetValue(cur, DlgIntSlots[i].idx);
            const int old = StoryBaseInts[i];
            if (cur == old)
                continue;
            StoryBaseInts[i] = cur;
            if (StoryNoisy[i])
                continue;
            const char* nm = DlgIntSlots[i].sym->name.ToChar();
            if (StoryIgnored(nm) || DlgGuildVars.count(DlgIntSlots[i].sym))   // u85: Werte aus Gilden-Infos gelten je Held
                continue;
            auto& times = StoryChangeTimes[i];
            times.push_back(CurrentMs);
            while (!times.empty() && times.front() < CurrentMs - 30000)
                times.pop_front();
            if ((int)times.size() > STORY_NOISY_MAX && strncmp(nm, "FUN_", 4)) {   // u204: Fun-Modus-Werte (Schlacht) nie ausschliessen
                StoryNoisy[i] = 1;
                DialogLog("Story-Abgleich: %s aendert sich staendig - fuer diese Sitzung ausgeschlossen", nm);
                continue;
            }
            if (!StoryValueOk(cur) || !StoryValueOk(old)) {
                StoryNoisy[i] = 1;
                DialogLog("Story-Abgleich: %s haelt grosse Werte (%d) - vermutlich Zeiger, ausgeschlossen", nm, cur);
                continue;
            }
            v.push_back(DlgVarEntry(DlgIntSlots[i].sym, DlgIntSlots[i].idx, cur, old));   // u199 (P213)
            nv++;
        }
        json l = json::array();
        const int nl = StoryLogDiff(l);
        // v31: Tagesablauf und dauerhafte Haltung der Welt-NPCs (aendern nur Skripte: Npc_ExchangeRoutine, Npc_SetPermAttitude
        // - auch ausserhalb von Dialogen, z. B. B_Kapitelwechsel, B_CheckDeadMissionNPCs, Story-Funktionen)
        json p = json::array();
        int np = 0;
        std::string npcNames;
        for (auto* li = CoopWorldNpcListFirst(ogame->GetGameWorld()); li; li = li->next) {
            oCNpc* npc = li->data;
            if (StoryNpcSkip(npc))
                continue;
            const std::string name = DialogNpcName(npc);
            if (name.empty())
                continue;
            const int rtn = npc->daily_routine, att = npc->attitude;
            const CoopNpcFields fields = DlgNpcFields(npc);   // u139 (P138)
            auto f = StoryBaseNpc.find(name);
            if (f == StoryBaseNpc.end()) {   // neu in der Liste (z. B. gerade eingefuegt) - nur merken
                StoryBaseNpc[name] = { rtn, att, fields };
                continue;
            }
            if (f->second.rtn == rtn && f->second.att == att && DlgNpcFieldsSame(f->second.f, fields))
                continue;
            json jn;
            if (f->second.rtn != rtn)
                if (zCPar_Symbol* rs = parser->GetSymbol(rtn))
                    jn["r"] = rs->name.ToChar();
            if (f->second.att != att && !DlgGuildNpcHas(name))   // u152 (P156): Haltung je Held
                jn["at"] = att;
            DlgNpcFieldsDiff(f->second.f, fields, jn);
            f->second = { rtn, att, fields };
            if (jn.empty() || StoryNpcNoisy.count(name))
                continue;
            auto& times = StoryNpcTimes[name];
            times.push_back(CurrentMs);
            while (!times.empty() && times.front() < CurrentMs - 30000)
                times.pop_front();
            if (times.size() > 6) {
                StoryNpcNoisy.insert(name);
                DialogLog("Story-Abgleich: NPC %s wechselt Tagesablauf/Haltung staendig - fuer diese Sitzung ausgeschlossen", name.c_str());
                continue;
            }
            jn["n"] = name;
            p.push_back(jn);
            np++;
            if (npcNames.size() < 200)
                npcNames += (npcNames.empty() ? "" : ", ") + name;
        }
        // v31: Gildenhaltungen (B_SetGuildAttitude, B_InitGuildAttitudes bei Kapitelwechseln)
        json gl = json::array();
        int ng = 0;
        oCGuilds* gu = ogame->GetGuilds();
        if (gu && gu->attitude && gu->size == StoryGuildSize && StoryGuildSize > 0
            && StoryBaseGuilds.size() == (size_t)(StoryGuildSize * StoryGuildSize)) {
            for (int i = 0; i < StoryGuildSize * StoryGuildSize; i++)
                if (gu->attitude[i] != StoryBaseGuilds[i]) {
                    gl.push_back({ i % StoryGuildSize, i / StoryGuildSize, (int)gu->attitude[i] });
                    StoryBaseGuilds[i] = gu->attitude[i];
                    ng++;
                }
        }
        else
            StorySnapGuilds();
        if (!nv && !nl && !np && !ng)
            return;
        json j;
        j["q"] = 1;
        if (nv)
            j["v"] = v;
        if (nl)
            j["l"] = l;
        if (np)
            j["p"] = p;
        if (ng)
            j["g"] = gl;
        DialogSend(j, SYNC_DIALOG_STATE);
        std::string names;
        for (auto& x : v) {
            if (names.size() > 200)
                break;
            names += (names.empty() ? "" : ", ") + x.at(0).get<std::string>();
        }
        DialogLog("Story-Abgleich: %d Variablen (%s), %d Tagebuch-Themen, %d NPCs (%s), %d Gildenhaltungen -> Partner",
            nv, names.c_str(), nl, np, npcNames.c_str(), ng);
    }

    // --- Host-Ereignisse (v33): Spawns und Trigger laufen ueber den Host ----------------------------
    //
    // Nutzer: "ueber den Host natuerlich, aber wenn der Client solche Events durch Dialoge triggert, sollte es ueber den Host
    // laufen". Test v32: eine Fleischwanze des Hosts erschien beim Client nicht - GT gleicht nur NPCs ab, die auf beiden PCs mit
    // demselben Namen existieren; spaeter erzeugte heissen beim Host "<Objekt>-DYNAMIC-<Wegpunkt>-n" (Helpers.cpp) und waren
    // beim Client unbekannt (Log "unbekannter NPC-Name im Paket").
    // - Skript-Externals WLD_INSERTNPC, WLD_SENDTRIGGER, WLD_SENDUNTRIGGER: Funktionszeiger im Symbol (Inhaltsfeld +0x18)
    //   durch eigene ersetzt - zCParser::DoStack liest ihn bei jedem CALLEXTERN neu (GetStackPos -> call; 0x006E91ED).
    //   Client: Parameter wie das Original vom Stapel holen (GetParameter, letzter zuerst), Anfrage an den Host, NICHT selbst
    //   ausfuehren. Host: ausfuehren; Trigger gehen danach an alle Clients ("trigger"/"untrigger", dort Original ausfuehren).
    // - Neue NPCs beim Host (jede Quelle: Skript, Kapitel, Beschwoerung): GT-Namen, die nach dem Erstlauf von
    //   BuildGlobalNpcList entstehen, gehen als "spawn" {n, inst, Position} an die Clients; der Client legt den NPC an
    //   (CreateVob + spawnman->InsertNpc, wie GT bei der Coop-Figur) und gibt ihm genau diesen Namen. Alle 30 s wiederholt der
    //   Host die Liste (lebende): ein Client, der inzwischen einen Host-Spielstand geladen hat, hat denselben NPC unter einem
    //   anderen (Erstlauf-)Namen - er wird dann umbenannt (gleiche Instanz, hoechstens 3 m), sonst neu angelegt.
    typedef int(__cdecl* CoopParserExternal2)();
    static CoopParserExternal2 OrigWldInsertNpc = NULL, OrigWldSendTrigger = NULL, OrigWldSendUntrigger = NULL;
    static CoopParserExternal2 OrigWldInsertItem = NULL;   // u27 (D13d, aus Othello v111)
    static bool HostEvInstalled = false;
    static int HostEvApplying = 0;
    struct CoopSpawnInfo {
        oCNpc* npc;
        std::string inst;
    };
    static std::map<std::string, CoopSpawnInfo> SpawnDynamic;   // Host: nach dem Laden erzeugte NPCs
    static std::set<std::string> SpawnKnown;
    static std::set<std::string> SpawnFromHost;                 // Client: vom Host vergebene Namen
    static bool SpawnBaselineDone = false;
    static long long SpawnNextMs = 0, SpawnResendMs = 0;
    static int CoopTestTrigCount = 0;      // v107: Trigger/Untrigger vom Partner, hier ausgefuehrt (Coop-Testlauf, CoopSelfTest.cpp)
    static std::string CoopTestTrigLast;   // zuletzt "trigger:Name" bzw. "untrigger:Name"

    // u29 (P65): ist der Host in einer anderen Welt, verwirft er die Anfrage (gleichnamige Wegpunkte/NPCs waeren andere) - dann
    // fuehrt der Client Spawn, Trigger und Gegenstand selbst aus, wie ohne Coop. Grenze: eine Welt, in der nur der Client war,
    // entwickelt sich bei ihm eigen; kommt der Host dazu, holt der Client dessen Bestand (PacketProcessor.cpp).
    static bool HostEvForward() {
        return ClientThread && !ServerThread && !HostEvApplying && DialogSyncAktiv() && CoopPlayerInMyWorld("HOST");
    }

    static void HostEvSend(json& j) {
        DialogSend(j, SYNC_HOST_EVENT);
    }

    // u195 (P202): Laufende Skripte einer Mod (Frame-Funktionen, Schleifen; Legend of Ahssun: 166, docs\mod-analyse\LoA.md) laufen auf
    // beiden PCs. Was eine davon beim Client einsetzt, ausloest oder anlegt, geht als Anfrage zum Host - und der hat dasselbe aus
    // seiner eigenen Schleife schon getan oder tut es gleich: Monster, Gegenstaende doppelt, ein Trigger zweimal (ein Tor auf und wieder
    // zu). Der Host merkt sich je Ereignis (Art, Instanz/Name, Wegpunkt) die eigenen und die angefragten der letzten 3 s, die noch kein
    // Gegenstueck haben, und verrechnet sie paarweise: Steht einem Ereignis eines der anderen Seite gegenueber, faellt es weg. Dieselbe
    // Seite darf es beliebig oft (drei Fleischwanzen am selben Wegpunkt aus einem Skript). Allgemein.
    static std::map<std::string, std::deque<std::pair<long long, int>>> HostEvTwins;   // Schluessel -> offene (Zeit, Seite 0 Host / 1 Client)
    static int HostEvTwinDropped = 0;

    static std::string HostEvKey(const char* f, const std::string& a, const std::string& b = std::string()) {
        std::string k = std::string(f) + "|" + a + "|" + b;
        for (char& c : k)
            c = (char)toupper((unsigned char)c);
        return k;
    }

    static bool HostEvTwinAllow(const std::string& key, int side) {
        const long long now = GetCurrentMs();
        std::deque<std::pair<long long, int>>& open = HostEvTwins[key];
        while (!open.empty() && now - open.front().first > 3000)
            open.pop_front();
        for (auto it = open.begin(); it != open.end(); ++it)
            if (it->second != side) {
                open.erase(it);
                HostEvTwinDropped++;
                return false;
            }
        open.push_back(std::make_pair(now, side));
        if (HostEvTwins.size() > 512)
            for (auto i = HostEvTwins.begin(); i != HostEvTwins.end();) {
                while (!i->second.empty() && now - i->second.front().first > 3000)
                    i->second.pop_front();
                i = i->second.empty() ? HostEvTwins.erase(i) : std::next(i);
            }
        return true;
    }

    // u199 (P212, Durchsicht der Mod-Analyse von Legend of Ahssun): Skripte, die einen eben eingefuegten NPC oder Gegenstand sofort
    // weiterbenutzen, fanden ihn beim Client nicht - der Client fragte nur den Host an und legte selbst nichts an (D13, u27). LoA:
    // NESTAUSHEBEN_INSERTBLACKPOWDERBARRELANDRECIPE (Wld_InsertItem, dann MEM_SearchVobByName -> zCVob::SetCollDetDyn mit Nullzeiger),
    // SCHLEIFE_TOA (Wld_InsertNpc(SKELETON_LORD_LE), gleich danach SKELETON_LORD_LE.aivar[61] = FALSE), LOA_ARENA_ACTION (Wld_InsertNpc(
    // GNARBASH), dann B_Attack(GNARBASH, hero)) - Zugriff auf eine leere Instanz, Absturz beim Client. Jetzt legt der Client das Objekt
    // zusaetzlich zur Anfrage gleich selbst an und merkt es sich; die Meldung des Hosts ("spawn" bzw. "item") uebernimmt dann dieses
    // Objekt (NPC: umbenennen wie beim Host, Gegenstand: nicht noch einmal anlegen), statt ein zweites anzulegen. Allgemein (G1/G2).
    struct CoopPendingInsert {
        std::string inst, wp;
        void* vob;         // nur zum Wiederfinden (in der NPC-Liste der Welt gesucht), keine Referenz
        long long ms;
    };
    static std::vector<CoopPendingInsert> HostEvPendingNpc, HostEvPendingItem;
    static const long long HOST_EV_PENDING_MS = 30000;
    static int CoopTestPendingAdopted = 0;   // Coop-Testlauf: vom Host uebernommene eigene Objekte

    static void HostEvPendingExpire(std::vector<CoopPendingInsert>& v) {
        const long long now = GetCurrentMs();
        for (auto it = v.begin(); it != v.end();) {
            if (now - it->ms > HOST_EV_PENDING_MS) {
                DialogLog("Host-Ereignis: %s an %s hier angelegt, der Host meldete es nicht (P212) - bleibt nur hier", it->inst.c_str(), it->wp.c_str());
                it = v.erase(it);
            }
            else
                ++it;
        }
    }

    // Original hier ausfuehren (Parameter wieder auf den Stapel) und das neue Objekt merken: zCParser::CreateInstance setzt den Zeiger
    // im Instanz-Symbol, er wechselt also genau dann, wenn das Original etwas angelegt hat
    static void HostEvInsertHere(CoopParserExternal2 orig, int inst, zSTRING& wp, bool npc) {
        zCPar_Symbol* s = parser ? parser->GetSymbol(inst) : NULL;
        if (!orig || !s)
            return;
        const int before = s->offset;
        DialogPushInt(inst);
        DialogPushString(&wp);
        HostEvApplying++;
        orig();
        HostEvApplying--;
        if (s->offset && s->offset != before) {
            std::vector<CoopPendingInsert>& list = npc ? HostEvPendingNpc : HostEvPendingItem;
            HostEvPendingExpire(list);
            list.push_back({ s->name.ToChar(), wp.ToChar(), (void*)s->offset, GetCurrentMs() });
        }
    }

    zCListSort<oCItem>* CoopWorldItemListFirst(oCWorld* world);   // OthelloCompat.cpp

    // gemerkter Gegenstand noch frei in dieser Welt? (Der Welt-Abgleich des Clients koennte ihn entfernt haben, bevor der Host ihn kannte)
    static bool HostEvPendingItemAlive(void* p) {
        if (!p || !ogame || !ogame->GetGameWorld())
            return false;
        for (auto* l = CoopWorldItemListFirst(ogame->GetGameWorld()); l; l = l->next)
            if ((void*)l->data == p)
                return true;
        return false;
    }

    // gemerkter NPC noch in dieser Welt (lebend)? Nur dann gilt der Zeiger
    static oCNpc* HostEvPendingNpcAlive(void* p) {
        if (!p || !ogame || !ogame->GetGameWorld())
            return NULL;
        for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l; l = l->next)
            if ((void*)l->data == p)
                return l->data->IsDead() ? NULL : l->data;
        return NULL;
    }

    // Host: laeuft gerade ein eigenes Skript, dessen Ereignis gezaehlt wird (nicht Anfrage eines Clients, nicht beim Laden)?
    static bool HostEvOwnScript() {
        return ServerThread && !HostEvApplying && DialogSyncAktiv() && zCParser::GetParser() == parser;
    }

    // v41: Laeuft gerade ein Todesskript (SELF ist ein toter NPC, z. B. ZS_Dead)? Jeder Tod beim Client wird beim Host mit
    // eigenem ZS_Dead nachvollzogen (Angriffe, Verfolgungspunkt, Todesmeldung) - Spawns/Trigger daraus nicht noch einmal anfragen.
    static bool HostEvInDeathScript() {
        if (CoopReplayDeathDepth > 0)
            return true;
        zCPar_Symbol* s = parser ? parser->GetSymbol(zSTRING("SELF")) : NULL;
        oCNpc* self = s ? (oCNpc*)s->offset : NULL;
        return self && self != player && self->IsDead();
    }

    // u199 (P216, Durchsicht der Mod-Analyse von Legend of Ahssun): GT spielt den Zauber einer Figur beim Partner nach
    // (RemoteNpc::UpdateSpellCasts: Spell_Invest + Spell_Cast) - dabei liefen SPELL_LOGIC_*/SPELL_CAST_* dort noch einmal, mit SELF = Figur
    // (Npc_IsPlayer falsch) und HERO = Held des Partners. Gothic II: Beschwoerungen erzeugten beim Partner die feindliche Variante
    // (Npc_IsPlayer(self) falsch -> GOBBO_SKELETON statt SUMMONED_GOBBO_SKELETON); LoA: Schutzzauber-Untote doppelt, MANARUNE/HPRUNE
    // (der Partner regenerierte mit), Abklingzeit der Teleport-Zauber, Eisschutz beim Partner. Waehrend des Nachspielens sind die
    // Welt-Externals jetzt wirkungslos (Wld_InsertNpc/InsertItem/SpawnNpcRange/SendTrigger/RemoveNpc), und Skript-Ganzzahlen, die das
    // Skript dabei aendert, setzt GT danach zurueck - die Wirkung kommt vom PC des Zaubernden (Abgleich, Host-Ereignisse). Allgemein.
    static int CoopSpellReplayDepth = 0;
    static std::vector<std::pair<zCPar_Symbol*, int>> ReplayIntSlots;   // alle globalen Ganzzahlen (auch Heldenwerte und Werte je PC)
    static std::vector<int> ReplayIntVals;
    static int ReplayIntSymCount = -1;
    static int CoopTestReplaySwallowed = 0, CoopTestReplayRestored = 0;   // Coop-Testlauf

    void CoopSpellReplayBegin() {
        if (CoopSpellReplayDepth++ > 0 || !parser)
            return;
        const int cnt = parser->symtab.table.GetNum();
        if (cnt != ReplayIntSymCount) {
            ReplayIntSlots.clear();
            for (int i = 0; i < cnt; i++) {
                zCPar_Symbol* s = parser->symtab.table[i];
                if (!s || s->type != zPAR_TYPE_INT || (s->flags & (zPAR_FLAG_CONST | zPAR_FLAG_CLASSVAR | zPAR_FLAG_EXTERNAL)))
                    continue;
                const char* nm = s->name.ToChar();
                if (!nm || !*nm || strchr(nm, '.'))
                    continue;
                const int ele = s->ele > 1 ? (int)s->ele : 1;
                for (int k = 0; k < ele; k++)
                    ReplayIntSlots.push_back(std::make_pair(s, k));
            }
            ReplayIntSymCount = cnt;
        }
        ReplayIntVals.resize(ReplayIntSlots.size());
        for (size_t i = 0; i < ReplayIntSlots.size(); i++) {
            int v = 0;
            ReplayIntSlots[i].first->GetValue(v, ReplayIntSlots[i].second);
            ReplayIntVals[i] = v;
        }
    }

    void CoopSpellReplayEnd(const char* spell) {
        if (CoopSpellReplayDepth <= 0)
            return;
        if (--CoopSpellReplayDepth > 0 || !parser)
            return;
        int n = 0;
        std::string names;
        for (size_t i = 0; i < ReplayIntSlots.size() && i < ReplayIntVals.size(); i++) {
            int v = 0;
            ReplayIntSlots[i].first->GetValue(v, ReplayIntSlots[i].second);
            if (v == ReplayIntVals[i])
                continue;
            ReplayIntSlots[i].first->SetValue(ReplayIntVals[i], ReplayIntSlots[i].second);
            n++;
            if (names.size() < 200)
                names += (names.empty() ? "" : ", ") + std::string(ReplayIntSlots[i].first->name.ToChar()) + "=" + std::to_string(v) + "->" +
                    std::to_string(ReplayIntVals[i]);
        }
        if (n) {
            CoopTestReplayRestored += n;
            static CoopDiagBudget budget = { 0, 0 };
            if (CoopDiagAllow(budget, 20))
                DialogLog("Zauber %s der Figur nachgespielt: %d Skript-Werte zurueckgesetzt (P216): %s", spell ? spell : "?", n, names.c_str());
        }
    }

    // Nachspielen eines Zaubers: das External wirkungslos machen (Parameter vom Stapel nehmen). Bei true sofort mit 0 zurueck
    static bool HostEvReplaySwallow(const char* ext) {
        if (CoopSpellReplayDepth <= 0 || zCParser::GetParser() != parser)
            return false;
        zCParser* p = zCParser::GetParser();
        zSTRING s;
        int i = 0;
        float f = 0.f;
        if (!strcmp(ext, "WLD_INSERTNPC") || !strcmp(ext, "WLD_INSERTITEM")) {
            p->GetParameter(s);
            p->GetParameter(i);
        }
        else if (!strcmp(ext, "WLD_SENDTRIGGER") || !strcmp(ext, "WLD_SENDUNTRIGGER"))
            p->GetParameter(s);
        else if (!strcmp(ext, "WLD_REMOVENPC"))
            p->GetParameter(i);
        else if (!strcmp(ext, "WLD_SPAWNNPCRANGE")) {
            p->GetParameter(f);
            p->GetParameter(i);
            p->GetParameter(i);
            p->GetInstance();
        }
        else
            return false;
        CoopTestReplaySwallowed++;
        static CoopDiagBudget budget = { 0, 0 };
        if (CoopDiagAllow(budget, 20))
            DialogLog("Zauber der Figur nachgespielt: %s(%s) ohne Wirkung (P216 - wirkt beim Zaubernden)", ext, s.IsEmpty() ? "" : s.ToChar());
        return true;
    }

    static int __cdecl CoopExtWldInsertNpc() {
        if (HostEvReplaySwallow("WLD_INSERTNPC"))   // u199 (P216)
            return 0;
        if (!HostEvForward()) {
            if (!HostEvOwnScript() || HostEvInDeathScript())
                return OrigWldInsertNpc ? OrigWldInsertNpc() : 0;
            // u195 (P202): eigenes Skript des Hosts - Gegenstueck des Clients? Die Zeichenkette muss leben, bis das Original sie gelesen hat
            zCParser* p = zCParser::GetParser();
            zSTRING wp;
            int inst = 0;
            p->GetParameter(wp);   // letzter Parameter zuerst
            p->GetParameter(inst);
            zCPar_Symbol* s = p->GetSymbol(inst);
            // u199 (P212): Schluessel ohne Wegpunkt - Schleifen auf beiden PCs wuerfeln den Wegpunkt oft selbst (LoA RESET_MAGUS_POSITIONS:
            // Hlp_Random je PC), dieselbe Instanz von beiden Seiten binnen 3 s ist dasselbe Ereignis
            if (!HostEvTwinAllow(HostEvKey("spawn", s ? s->name.ToChar() : "?"), 0)) {
                DialogLog("Host-Ereignis: Wld_InsertNpc(%s, %s) hat der Client eben angefragt und der Host ausgefuehrt - hier nicht "
                    "noch einmal (P202)", s ? s->name.ToChar() : "?", wp.ToChar());
                return 0;
            }
            DialogPushInt(inst);   // wieder hinlegen, das Original holt sie selbst
            DialogPushString(&wp);
            return OrigWldInsertNpc ? OrigWldInsertNpc() : 0;
        }
        zCParser* p = zCParser::GetParser();
        zSTRING wp;
        int inst = 0;
        p->GetParameter(wp);   // letzter Parameter zuerst
        p->GetParameter(inst);
        zCPar_Symbol* s = p->GetSymbol(inst);
        if (HostEvInDeathScript()) {   // v41: Todesskript - der Host fuehrt diesen Spawn mit seinem eigenen ZS_Dead aus und meldet ihn
            DialogLog("Host-Ereignis: Wld_InsertNpc(%s, %s) aus einem Todesskript - nicht angefragt (der Host spawnt selbst)",
                s ? s->name.ToChar() : "?", wp.ToChar());
            return 0;
        }
        json j;
        j["f"] = "spawnreq";
        j["inst"] = s ? s->name.ToChar() : "";
        j["wp"] = wp.ToChar();
        HostEvSend(j);
        HostEvInsertHere(OrigWldInsertNpc, inst, wp, true);   // u199 (P212): gleich hier, die Meldung des Hosts uebernimmt ihn
        DialogLog("Host-Ereignis: Wld_InsertNpc(%s, %s) -> Anfrage an den Host, hier gleich angelegt (P212)",
            s ? s->name.ToChar() : "?", wp.ToChar());
        return 0;
    }

    static int CoopHostEvTrigger(CoopParserExternal2 orig, const char* f) {
        if (HostEvReplaySwallow(f[0] == 't' ? "WLD_SENDTRIGGER" : "WLD_SENDUNTRIGGER"))   // u199 (P216)
            return 0;
        if (HostEvForward()) {
            zSTRING v;
            zCParser::GetParser()->GetParameter(v);
            if (HostEvInDeathScript()) {   // v41: Todesskript - der Host loest den Trigger mit seinem eigenen ZS_Dead aus und verteilt ihn
                DialogLog("Host-Ereignis: Wld_Send%s(%s) aus einem Todesskript - nicht angefragt (der Host loest selbst aus)", f[0] == 't' ? "Trigger" : "Untrigger", v.ToChar());
                return 0;
            }
            json j;
            j["f"] = std::string(f) + "req";
            j["s"] = v.ToChar();
            HostEvSend(j);
            DialogLog("Host-Ereignis: Wld_Send%s(%s) -> Anfrage an den Host", f[0] == 't' ? "Trigger" : "Untrigger", v.ToChar());
            return 0;
        }
        if (ServerThread && !HostEvApplying && DialogSyncAktiv() && zCParser::GetParser() == parser) {
            zSTRING v;
            parser->GetParameter(v);
            if (!HostEvInDeathScript() && !HostEvTwinAllow(HostEvKey(f, v.ToChar()), 0)) {   // u195 (P202)
                DialogLog("Host-Ereignis: Wld_Send%s(%s) hat der Client eben angefragt und der Host ausgeloest - nicht noch einmal (P202)",
                    f[0] == 't' ? "Trigger" : "Untrigger", v.ToChar());
                return 0;
            }
            DialogPushString(&v);   // wieder hinlegen, das Original holt ihn selbst
            const int r = orig ? orig() : 0;
            json j;
            j["f"] = f;
            j["s"] = v.ToChar();
            HostEvSend(j);
            DialogLog("Host-Ereignis: Wld_Send%s(%s) ausgefuehrt und an die Clients", f[0] == 't' ? "Trigger" : "Untrigger", v.ToChar());
            return r;
        }
        return orig ? orig() : 0;
    }

    static int __cdecl CoopExtWldSendTrigger() {
        return CoopHostEvTrigger(OrigWldSendTrigger, "trigger");
    }

    static int __cdecl CoopExtWldSendUntrigger() {
        return CoopHostEvTrigger(OrigWldSendUntrigger, "untrigger");
    }

    // u27 (D13d, aus Othello-Coop v111 uebernommen; Nutzer, Test u26: "Insert Script: Wenn in die Welt ein Item eingefuegt wird,
    // passiert das gerade nur bei einem"): Wld_InsertItem(Instanz, Wegpunkt) lief nur auf dem PC, dessen Skript es ausfuehrte - beim
    // Host ausgeloest lag der Gegenstand nur dort (der Welt-Abgleich legt beim Client nichts an, er entfernt nur), beim Client
    // ausgeloest nur beim Client (Aufheben fand der Host nicht, der naechste Welt-Abgleich entfernte ihn). Jetzt wie Wld_InsertNpc:
    // Client fragt den Host ("itemreq", legt selbst nichts an), der Host fuehrt das Original aus und meldet allen "item" {inst, wp};
    // jeder Client fuehrt das Original mit denselben Werten aus - Gothic legt den Gegenstand an die Lage des Wegpunkts bzw. des
    // gleichnamigen Vobs, auf allen PCs dieselbe Stelle; danach gilt der Gegenstands-Abgleich (Aufheben ueber den Host). Nur mit
    // Abgleich "Gegenstaende/Truhen"; aus Todesskripten fragt der Client nicht an (der Host fuehrt sie mit seinem eigenen ZS_Dead
    // aus); beim Laden (Start-Skripte der Welt) laeuft es wie bisher lokal (DialogSyncAktiv aus). Grenze wie bei Wld_InsertNpc:
    // loest dasselbe Skript auf beiden PCs aus, entsteht der Gegenstand doppelt. Allgemein G1/G2.
    static int __cdecl CoopExtWldInsertItem() {
        if (HostEvReplaySwallow("WLD_INSERTITEM"))   // u199 (P216)
            return 0;
        zCParser* p = zCParser::GetParser();
        const bool world = CoopRuleWorld();
        if (HostEvForward() && world && p == parser) {
            zSTRING wp;
            int inst = 0;
            p->GetParameter(wp);   // letzter Parameter zuerst
            p->GetParameter(inst);
            zCPar_Symbol* s = p->GetSymbol(inst);
            if (HostEvInDeathScript()) {
                DialogLog("Host-Ereignis: Wld_InsertItem(%s, %s) aus einem Todesskript - nicht angefragt (der Host legt selbst an)",
                    s ? s->name.ToChar() : "?", wp.ToChar());
                return 0;
            }
            json j;
            j["f"] = "itemreq";
            j["inst"] = s ? s->name.ToChar() : "";
            j["wp"] = wp.ToChar();
            HostEvSend(j);
            HostEvInsertHere(OrigWldInsertItem, inst, wp, false);   // u199 (P212): gleich hier, die Meldung des Hosts legt ihn nicht noch einmal an
            DialogLog("Host-Ereignis: Wld_InsertItem(%s, %s) -> Anfrage an den Host, hier gleich angelegt (P212)",
                s ? s->name.ToChar() : "?", wp.ToChar());
            return 0;
        }
        if (ServerThread && world && !HostEvApplying && DialogSyncAktiv() && p == parser) {
            zSTRING wp;
            int inst = 0;
            p->GetParameter(wp);
            p->GetParameter(inst);
            if (!HostEvInDeathScript()) {   // u195 (P202)
                zCPar_Symbol* is = p->GetSymbol(inst);
                if (!HostEvTwinAllow(HostEvKey("item", is ? is->name.ToChar() : "?", wp.ToChar()), 0)) {
                    DialogLog("Host-Ereignis: Wld_InsertItem(%s, %s) hat der Client eben angefragt und der Host angelegt - nicht noch "
                        "einmal (P202)", is ? is->name.ToChar() : "?", wp.ToChar());
                    return 0;
                }
            }
            DialogPushInt(inst);   // wieder hinlegen, das Original holt sie selbst
            DialogPushString(&wp);
            const int r = OrigWldInsertItem ? OrigWldInsertItem() : 0;
            if (zCPar_Symbol* s = parser->GetSymbol(inst)) {
                json j;
                j["f"] = "item";
                j["inst"] = s->name.ToChar();
                j["wp"] = wp.ToChar();
                HostEvSend(j);
                DialogLog("Host-Ereignis: Wld_InsertItem(%s, %s) ausgefuehrt und an die Clients", s->name.ToChar(), wp.ToChar());
            }
            return r;
        }
        return OrigWldInsertItem ? OrigWldInsertItem() : 0;
    }

    // u195 (P200): Ereignisse aus Dialogen und Schleifen einer Mod, die einen NPC des Hosts betreffen, liefen beim Client nur dort - der
    // Host fuehrt den NPC und setzte ihn zurueck (Teleport) bzw. belebte ihn wieder (P155, Skript-Tod). Legend of Ahssun startet aus
    // Dialogen 219 solcher Ereignisse (docs\mod-analyse\LoA.md: AI_Teleport 84, Npc_ChangeAttribute 21, B_KillNpc 12, Wld_RemoveNpc 3);
    // in Gothic II tun es einzelne Dialoge selbst.
    //  - AI_Teleport(npc, wp): Der Client fuehrt es aus und meldet es dem Host ("telereq"), der fuehrt es ueber das External aus.
    //    CoopTeleport.cpp leitet AI_TELEPORT fuer die Rune um und ruft dort CoopHostEvNpcTeleportPeek.
    //  - Npc_ChangeAttribute(npc, ATR_HITPOINTS, ...), das den NPC toetet (B_KillNpc, B_RemoveNpc): Der Client fuehrt es aus und meldet
    //    den Tod ("killreq"), der Host toetet den NPC ohne EP (CoopKillNoXp); der Tod geht wie jeder an die Clients.
    //  - Wld_RemoveNpc(Instanz) wie Wld_InsertNpc: Der Client fragt an ("removereq"), der Host entfernt und meldet es allen ("remove");
    //    entfernt ein Skript des Hosts, gilt es ebenso fuer alle (bisher nur beim Host).
    // Nicht aus Todesskripten (der Host spielt den Tod selbst nach), nur mit Host in derselben Welt (HostEvForward). Allgemein.
    static CoopParserExternal2 OrigWldRemoveNpc = NULL, OrigNpcChangeAttribute = NULL;

    // NPC-Parameter, ohne ihn vom Stapel zu nehmen: Symbolnummer `below` Plaetze unter dem obersten; nur Welt-NPCs mit GT-Namen
    static oCNpc* HostEvPeekNpc(int below) {
        zCParser* p = zCParser::GetParser();
        if (!p)
            return NULL;
        const int* st = p->datastack.stack;
        const int sp = p->datastack.sptr;
        const int spMax = (int)(sizeof(p->datastack.stack) / sizeof(p->datastack.stack[0]));
        if (sp < below + 1 || sp > spMax)
            return NULL;
        const int idx = st[sp - 1 - below];
        zCPar_Symbol* ns = idx > 0 ? p->GetSymbol(idx) : NULL;
        oCNpc* npc = ns && ns->type == zPAR_TYPE_INSTANCE ? (oCNpc*)ns->offset : NULL;
        if (!npc || npc == player || IsCoopPlayer(npc->GetObjectName()) || !NpcToUniqueNameList.count(npc))
            return NULL;
        return npc;
    }

    void CoopHostEvNpcTeleportPeek() {
        zCParser* p = zCParser::GetParser();
        if (!HostEvForward() || HostEvInDeathScript() || !p || p != parser)
            return;
        const int* st = p->datastack.stack;
        const int sp = p->datastack.sptr;
        if (sp < 3 || sp > (int)(sizeof(p->datastack.stack) / sizeof(p->datastack.stack[0])) || st[sp - 1] != 0x41 || !st[sp - 2])
            return;
        const zSTRING* wp = (const zSTRING*)st[sp - 2];
        oCNpc* npc = HostEvPeekNpc(2);
        if (!npc)
            return;
        json j;
        j["f"] = "telereq";
        j["n"] = NpcToUniqueNameList[npc].ToChar();
        j["wp"] = wp->ToChar();
        HostEvSend(j);
        DialogLog("Host-Ereignis: AI_Teleport(%s, %s) beim Client -> auch beim Host (P200)", NpcToUniqueNameList[npc].ToChar(), wp->ToChar());
    }

    static int __cdecl CoopExtNpcChangeAttribute() {
        oCNpc* npc = NULL;
        if (HostEvForward() && !HostEvInDeathScript() && zCParser::GetParser() == parser) {
            const int* st = parser->datastack.stack;
            const int sp = parser->datastack.sptr;
            if (sp >= 5 && sp <= (int)(sizeof(parser->datastack.stack) / sizeof(parser->datastack.stack[0]))) {
                const int tok = st[sp - 3], v = st[sp - 4];   // zweiter Parameter: Attribut
                const int atr = tok == 0x40 ? v : (tok == 0x41 && v) ? *(const int*)v : -1;
                if (atr == NPC_ATR_HITPOINTS) {
                    npc = HostEvPeekNpc(4);
                    if (npc && npc->IsDead())
                        npc = NULL;
                }
            }
        }
        const int r = OrigNpcChangeAttribute ? OrigNpcChangeAttribute() : 0;
        if (npc && npc->GetAttribute(NPC_ATR_HITPOINTS) <= 0) {
            json j;
            j["f"] = "killreq";
            j["n"] = NpcToUniqueNameList[npc].ToChar();
            HostEvSend(j);
            DialogLog("Host-Ereignis: ein Skript toetet %s beim Client (Npc_ChangeAttribute) -> auch beim Host (P200)",
                NpcToUniqueNameList[npc].ToChar());
        }
        return r;
    }

    static void HostEvRunRemoveNpc(const std::string& inst) {
        const int idx = parser ? parser->GetIndex(zSTRING(inst.c_str())) : -1;
        if (idx < 0 || !OrigWldRemoveNpc || zCParser::GetParser() != parser) {
            DialogLog("Host-Ereignis: Wld_RemoveNpc(%s) nicht moeglich", inst.c_str());
            return;
        }
        DialogPushInt(idx);
        HostEvApplying++;
        OrigWldRemoveNpc();
        HostEvApplying--;
    }

    static int __cdecl CoopExtWldRemoveNpc() {
        if (HostEvReplaySwallow("WLD_REMOVENPC"))   // u199 (P216)
            return 0;
        zCParser* p = zCParser::GetParser();
        const bool forward = HostEvForward() && p == parser && !HostEvInDeathScript();
        if (!forward && !(HostEvOwnScript() && !HostEvInDeathScript()))
            return OrigWldRemoveNpc ? OrigWldRemoveNpc() : 0;
        int inst = 0;
        p->GetParameter(inst);
        zCPar_Symbol* s = p->GetSymbol(inst);
        const std::string nm = s ? s->name.ToChar() : "";
        json j;
        j["inst"] = nm;
        if (forward) {
            j["f"] = "removereq";
            HostEvSend(j);
            DialogLog("Host-Ereignis: Wld_RemoveNpc(%s) -> Anfrage an den Host (P200)", nm.c_str());
            return 0;
        }
        if (!HostEvTwinAllow(HostEvKey("remove", nm), 0)) {
            DialogLog("Host-Ereignis: Wld_RemoveNpc(%s) hat der Client eben angefragt und der Host ausgefuehrt - nicht noch einmal (P202)", nm.c_str());
            return 0;
        }
        DialogPushInt(inst);   // wieder hinlegen, das Original holt sie selbst
        const int r = OrigWldRemoveNpc ? OrigWldRemoveNpc() : 0;
        j["f"] = "remove";
        HostEvSend(j);
        DialogLog("Host-Ereignis: Wld_RemoveNpc(%s) ausgefuehrt und an die Clients (P200)", nm.c_str());
        return r;
    }

    // u199 (P215, Durchsicht der Mod-Analyse von Legend of Ahssun: 28 Orkgraeber, Tempelsaeulen, Ring-Schalter, Boss-Angriffe,
    // Herausforderungs-Horn, Kaefer-Eier; Gothic II: Beschwoerungen): Wld_SpawnNpcRange(npc, instanz, anzahl, lebenszeit) lief nur auf dem
    // PC des Skripts - beim Client entstanden die NPCs nur dort, der Host kannte sie nicht, der Partner sah sie nie. Jetzt wie Wld_InsertNpc
    // (P212): Der Client legt sie gleich selbst an (das Skript kann sie weiterbenutzen), merkt sie sich und bittet den Host
    // ("spawnrangereq"); der Host spawnt um dieselbe Figur bzw. denselben NPC und meldet die neuen NPCs wie jeden Spawn - der Client
    // uebernimmt seine eigenen (naechster gleicher Instanz, P212). Aus Todesskripten fragt der Client nicht und legt nichts an (der Host
    // spawnt mit seinem eigenen ZS_Dead). Gleiches von beiden Seiten binnen 3 s fuehrt der Host einmal aus (P202). Allgemein.
    static CoopParserExternal2 OrigWldSpawnNpcRange = NULL;
    bool CoopCallNpcExternal(const char* ext, oCNpc* npc, zSTRING* s, const int* ints, int nInts);   // weiter unten

    static void HostEvRunSpawnRange(const std::string& inst, const std::string& ref, int count, float life) {
        const int idx = parser ? parser->GetIndex(zSTRING(inst.c_str())) : -1;
        oCNpc* at = NULL;
        if (!ref.empty() && ogame && ogame->GetGameWorld()) {
            auto it = UniqueNameToNpcList.find(string(ref.c_str()));
            if (it != UniqueNameToNpcList.end() && it->second)
                at = it->second;
            for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l && !at; l = l->next)   // Held des Clients -> seine Figur hier
                if (l->data && !_stricmp(l->data->GetObjectName().ToChar(), ref.c_str()))
                    at = l->data;
        }
        if (idx < 0 || !at || count < 1 || count > 20) {
            DialogLog("Host-Ereignis: Wld_SpawnNpcRange(%s, %s, %d) des Clients nicht moeglich (P215)", ref.c_str(), inst.c_str(), count);
            return;
        }
        const int ints[3] = { idx, count, *(const int*)&life };
        std::set<oCNpc*> before;
        for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l; l = l->next)
            before.insert(l->data);
        HostEvApplying++;
        const bool ok = CoopCallNpcExternal("WLD_SPAWNNPCRANGE", at, NULL, ints, 3);
        HostEvApplying--;
        // u199 (P217): Beschwoerungen des Clients (AIV_PARTYMEMBER aus der Instanz) folgen seiner Figur
        const int aiv = PartyAiv();
        if (ok && aiv >= 0 && IsCoopPlayer(ref))
            for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l; l = l->next)
                if (l->data && !before.count(l->data) && l->data->aiscriptvars[aiv])
                    PartyNote(l->data, ref, "Beschwoerung des Clients");
        DialogLog("Host-Ereignis: Wld_SpawnNpcRange(%s, %s, %d) des Clients %s (P215)", ref.c_str(), inst.c_str(), count, ok ? "ausgefuehrt" : "nicht moeglich");
    }

    static int __cdecl CoopExtWldSpawnNpcRange() {
        if (HostEvReplaySwallow("WLD_SPAWNNPCRANGE"))   // P216
            return 0;
        zCParser* p = zCParser::GetParser();
        const bool forward = HostEvForward() && p == parser;
        const bool own = !forward && HostEvOwnScript() && !HostEvInDeathScript();
        if (!forward && !own)
            return OrigWldSpawnNpcRange ? OrigWldSpawnNpcRange() : 0;
        float life = 0.f;
        int count = 0, inst = 0, refSym = 0;
        p->GetParameter(life);   // letzter Parameter zuerst
        p->GetParameter(count);
        p->GetParameter(inst);
        if (p->datastack.sptr >= 1)   // oben liegt jetzt die Symbolnummer der Instanz (G1 kennt GetInstanceAndIndex nicht)
            refSym = p->datastack.stack[p->datastack.sptr - 1];
        oCNpc* ref = (oCNpc*)p->GetInstance();
        zCPar_Symbol* is = p->GetSymbol(inst);
        const std::string instName = is ? is->name.ToChar() : "?";
        auto pushBack = [&]() {   // wieder hinlegen, das Original holt sie selbst
            p->datastack.Push(refSym);
            DialogPushInt(inst);
            DialogPushInt(count);
            DialogPushInt(*(const int*)&life);
        };
        if (own) {   // Host, eigenes Skript: Gegenstueck einer Anfrage des Clients (Schleife auf beiden PCs)? (P202)
            if (!HostEvTwinAllow(HostEvKey("spawnrange", instName), 0)) {
                DialogLog("Host-Ereignis: Wld_SpawnNpcRange(%s) hat der Client eben angefragt und der Host ausgefuehrt - nicht noch einmal (P202)",
                    instName.c_str());
                return 0;
            }
            pushBack();
            return OrigWldSpawnNpcRange ? OrigWldSpawnNpcRange() : 0;
        }
        if (HostEvInDeathScript()) {
            DialogLog("Host-Ereignis: Wld_SpawnNpcRange(%s) aus einem Todesskript - nicht angefragt (der Host spawnt selbst, P215)", instName.c_str());
            return 0;
        }
        // Bezug: eigener Held -> meine Figur beim Host; sonst der NPC unter seinem GT-Namen
        std::string refName;
        if (ref == player || !ref)
            refName = DialogMe();
        else {
            auto nm = NpcToUniqueNameList.find(ref);
            refName = nm != NpcToUniqueNameList.end() ? std::string(nm->second.ToChar()) : DialogMe();
        }
        std::set<oCNpc*> before;
        if (ogame && ogame->GetGameWorld())
            for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l; l = l->next)
                before.insert(l->data);
        pushBack();
        HostEvApplying++;
        const int r = OrigWldSpawnNpcRange ? OrigWldSpawnNpcRange() : 0;
        HostEvApplying--;
        int made = 0;
        if (ogame && ogame->GetGameWorld()) {
            HostEvPendingExpire(HostEvPendingNpc);
            for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l; l = l->next)
                if (l->data && !before.count(l->data) && l->data->GetInstance() == inst) {
                    HostEvPendingNpc.push_back({ instName, std::string(), (void*)l->data, GetCurrentMs() });
                    made++;
                }
        }
        json j;
        j["f"] = "spawnrangereq";
        j["inst"] = instName;
        j["ref"] = refName;
        j["n"] = count;
        j["life"] = life;
        HostEvSend(j);
        DialogLog("Host-Ereignis: Wld_SpawnNpcRange(%s, %s, %d) -> Anfrage an den Host, hier %d gleich angelegt (P215)", refName.c_str(),
            instName.c_str(), count, made);
        return r;
    }

    // u195 (P200): ein External mit einem NPC als erstem Parameter so aufrufen, wie ein Skript es tut (Instanz ueber OTHER, danach
    // zurueck) - fuer den Host (Anfragen der Clients) und den Selbsttest
    bool CoopCallNpcExternal(const char* ext, oCNpc* npc, zSTRING* s, const int* ints, int nInts) {
        zCPar_Symbol* e = parser ? parser->GetSymbol(zSTRING(ext)) : NULL;
        const int oi = parser ? parser->GetIndex(zSTRING("OTHER")) : -1;
        zCPar_Symbol* other = oi >= 0 ? parser->GetSymbol(oi) : NULL;
        if (!npc || !e || !other || e->type != zPAR_TYPE_FUNC || !(e->flags & zPAR_FLAG_EXTERNAL) || !e->single_intdata ||
            zCParser::GetParser() != parser)
            return false;
        void* old = (void*)other->offset;
        parser->SetInstance(zSTRING("OTHER"), npc);
        parser->datastack.Push(oi);
        if (s)
            DialogPushString(s);
        for (int i = 0; i < nInts; i++)
            DialogPushInt(ints[i]);
        ((CoopParserExternal2)e->single_intdata)();
        parser->SetInstance(zSTRING("OTHER"), old);
        return true;
    }

    static void HostEvRunTeleport(const std::string& n, const std::string& wpName) {
        auto it = UniqueNameToNpcList.find(string(n.c_str()));
        oCNpc* npc = it != UniqueNameToNpcList.end() ? it->second : NULL;
        zSTRING wp(wpName.c_str());
        HostEvApplying++;
        const bool ok = npc && npc != player && CoopCallNpcExternal("AI_TELEPORT", npc, &wp, NULL, 0);
        HostEvApplying--;
        DialogLog("Host-Ereignis: AI_Teleport(%s, %s) des Clients %s (P200)", n.c_str(), wpName.c_str(), ok ? "ausgefuehrt" : "nicht moeglich (NPC unbekannt)");
    }

    static void HostEvRunKill(const std::string& n) {
        auto it = UniqueNameToNpcList.find(string(n.c_str()));
        oCNpc* npc = it != UniqueNameToNpcList.end() ? it->second : NULL;
        if (!npc || npc == player || IsCoopPlayer(npc->GetObjectName())) {
            DialogLog("Host-Ereignis: Skript-Tod von %s beim Client - NPC hier unbekannt (P200)", n.c_str());
            return;
        }
        if (npc->IsDead())
            return;
        CoopKillNoXp(npc, NULL, "Skript beim Client (P200)");
        DialogLog("Host-Ereignis: %s per Skript beim Client getoetet - hier auch (P200)", n.c_str());
    }

    // u163 (P170): CreateInvItem(s) und Npc_RemoveInvItem(s) im eigenen Dialogskript (siehe DlgInvChanges). Parameter ansehen wie CheckInfoPeek, ohne sie
    // vom Stapel zu nehmen: oben n int-Parameter (letzter zuerst, [Wert, 0x40] bzw. [Adresse, 0x41]), darunter die Symbolnummer des NPCs; die Instanz ist
    // der erste. Die Umleitungen der Coop-Truhe (CoopTruhe.cpp, nur fuer den eigenen Helden) liegen davor oder dahinter - jede ruft die andere als Original.
    static CoopParserExternal2 OrigCreateInvItem = NULL, OrigCreateInvItems = NULL, OrigRemoveInvItem = NULL, OrigRemoveInvItems = NULL;

    static int DlgInvExt(CoopParserExternal2 orig, int n) {
        zCParser* p = zCParser::GetParser();
        if (!DlgInvDepth || !orig || p != parser)
            return orig ? orig() : 0;
        const int* st = p->datastack.stack;
        const int sp = p->datastack.sptr;
        const int spMax = (int)(sizeof(p->datastack.stack) / sizeof(p->datastack.stack[0]));
        if (sp < 2 * n + 1 || sp > spMax)
            return orig();
        const int tok = st[sp + 1 - 2 * n], v = st[sp - 2 * n], idx = st[sp - 1 - 2 * n];
        const int inst = tok == 0x40 ? v : (tok == 0x41 && v) ? *(const int*)v : -1;
        zCPar_Symbol* ns = idx > 0 ? p->GetSymbol(idx) : NULL;
        zCPar_Symbol* is = inst > 0 ? p->GetSymbol(inst) : NULL;
        oCNpc* npc = ns && ns->type == zPAR_TYPE_INSTANCE ? (oCNpc*)ns->offset : NULL;
        if (!npc || npc == player || !NpcToUniqueNameList.count(npc) || !is || is->type != zPAR_TYPE_INSTANCE || IsCoopPlayer(npc->GetObjectName()))
            return orig();
        const int before = npc->inventory2.GetAmount(inst);
        const int r = orig();
        const int d = npc->inventory2.GetAmount(inst) - before;
        if (d)
            DlgInvChanges[std::make_pair(DialogNpcName(npc), std::string(is->name.ToChar()))] += d;
        return r;
    }

    static int __cdecl CoopExtCreateInvItem() { return DlgInvExt(OrigCreateInvItem, 1); }
    static int __cdecl CoopExtCreateInvItems() { return DlgInvExt(OrigCreateInvItems, 2); }
    static int __cdecl CoopExtRemoveInvItem() { return DlgInvExt(OrigRemoveInvItem, 1); }
    static int __cdecl CoopExtRemoveInvItems() { return DlgInvExt(OrigRemoveInvItems, 2); }

    // v92 (Test v91: "Kapitel 1 wird nicht angezeigt" beim Client): Kapitel-Bildschirme kommen aus Skripten - B_Kapitelwechsel ruft
    // IntroduceChapter(titel, untertitel, bild, ton, ms); Kapitel 1 z. B. aus Diegos Begruessung (INFO_DIEGO_GAMESTART_INFO), die nur
    // beim Host laeuft. Das External (Engine 0x0065E610 -> CGameManager::IntroduceChapter 0x00429A20, merkt nur vor) wird umgeleitet:
    // Parameter ansehen (letzter zuerst holen, wieder hinlegen), Original aufrufen, als DIALOG_STATE "ch" an den Partner (der Host
    // gibt es wie jeden Fortschritt weiter). Allgemein G1 (IntroduceChapter ist Gothics External).
    static CoopParserExternal2 OrigIntroduceChapter = NULL;

    static int __cdecl CoopExtIntroduceChapter() {
        zCParser* p = zCParser::GetParser();
        if (!p || p != parser || !DialogSyncAktiv() || !CoopRuleQuests())
            return OrigIntroduceChapter ? OrigIntroduceChapter() : 0;
        int ms = 0;
        zSTRING snd, tex, sub, title;
        p->GetParameter(ms);   // letzter Parameter zuerst
        p->GetParameter(snd);
        p->GetParameter(tex);
        p->GetParameter(sub);
        p->GetParameter(title);
        DialogPushString(&title);   // wieder hinlegen, das Original holt sie selbst
        DialogPushString(&sub);
        DialogPushString(&tex);
        DialogPushString(&snd);
        DialogPushInt(ms);
        const int r = OrigIntroduceChapter ? OrigIntroduceChapter() : 0;
        json j;
        j["ch"] = json::array({ title.ToChar(), sub.ToChar(), tex.ToChar(), snd.ToChar(), ms });
        DialogSend(j, SYNC_DIALOG_STATE);
        DialogLog("Kapitel-Bildschirm %s (%s) - auch beim Partner", title.ToChar(), sub.ToChar());
        return r;
    }

    // u28 (B5, siehe DialogPlayVideo): Video vor dem Abspielen an den Partner melden
    static int CoopVideoForward(bool ex) {
        zCParser* p = zCParser::GetParser();
        CoopVideoExternal orig = ex ? OrigPlayVideoEx : OrigPlayVideo;
        if (!p || p != parser || VideoReplaying || !DialogSyncAktiv() || !CoopRuleQuests())
            return orig ? orig() : 0;
        int exitSession = 0, blend = 0;
        zSTRING name;
        if (ex) {
            p->GetParameter(exitSession);   // letzter Parameter zuerst
            p->GetParameter(blend);
        }
        p->GetParameter(name);
        DialogPushString(&name);   // wieder hinlegen, das Original holt sie selbst
        if (ex) {
            DialogPushInt(blend);
            DialogPushInt(exitSession);
        }
        const long no = CoopStoryVideoNewNo();
        json j;
        j["vid"] = json::array({ name.ToChar(), blend, exitSession, ex ? 1 : 0 });
        j["vidno"] = no;   // u55
        DialogSend(j, SYNC_DIALOG_STATE);
        DialogLog("Video %s - auch beim Partner (Nr. %ld)", name.ToChar(), no);
        CoopStoryVideoBegin(no);
        const int r = orig ? orig() : 0;
        CoopStoryVideoEnd();
        return r;
    }

    static int __cdecl CoopExtPlayVideo() {
        return CoopVideoForward(false);
    }

    // u55 (Coop-Testlauf, "Story-Video: Ueberspringen gilt fuer beide"): Video wie aus einem Skript (PLAYVIDEO) beim Partner und hier
    // abspielen, hier nach stopMs wie mit Esc beendet (CoopNewGame.cpp). Rueckgabe: gespielt (no = Nummer), sonst Grund in why.
    void CoopStoryVideoTestStopAfter(int ms);
    bool CoopDialogTestVideo(const std::string& file, int stopMs, long& no, std::string& why) {
        if (!OrigPlayVideo || !parser || zCParser::GetParser() != parser) {
            why = "PLAYVIDEO nicht umgeleitet";
            return false;
        }
        if (!DialogSyncAktiv() || !CoopRuleQuests()) {
            why = "Video-Abgleich aus (Abgleich \"Quests\")";
            return false;
        }
        no = CoopStoryVideoNewNo();
        json j;
        j["vid"] = json::array({ file, 0, 0, 0 });
        j["vidno"] = no;
        DialogSend(j, SYNC_DIALOG_STATE);
        DialogLog("Testlauf: Video %s - auch beim Partner (Nr. %ld)", file.c_str(), no);
        zSTRING name(file.c_str());
        DialogPushString(&name);
        CoopStoryVideoTestStopAfter(stopMs);
        CoopStoryVideoBegin(no);
        OrigPlayVideo();
        CoopStoryVideoEnd();
        return true;
    }

    static int __cdecl CoopExtPlayVideoEx() {
        return CoopVideoForward(true);
    }

    // u147 (P149, siehe DialogExitSession): Die Videos gehen vorher einzeln hinueber, das Sitzungsende kommt also danach an
    static void DialogSendExitSession(int mode) {
        json j;
        j["exses"] = mode;
        DialogSend(j, SYNC_DIALOG_STATE);
    }

    void CoopDialogTestExit() {
        DialogSendExitSession(2);
    }

#if ENGINE >= Engine_G2
    static CoopVideoExternal OrigExitSession = NULL;

    static int __cdecl CoopExtExitSession() {
        if (zCParser::GetParser() == parser && DialogSyncAktiv() && CoopRuleQuests()) {
            DialogSendExitSession(1);
            DialogLog("Spielende: Sitzung endet - auch beim Partner");
        }
        return OrigExitSession ? OrigExitSession() : 0;
    }
#endif

    // v49: Npc_CheckInfo(self, important) aus einer Wahrnehmung, die von der Figur eines Mitspielers kommt (OTHER = Figur), meldet
    // "keine Info". Othellos B_InterceptAssessDamage (PERC_ASSESSDAMAGE in vielen Tagesablaeufen) prueft zuerst
    // Npc_CheckInfo(self, 1) und startet bei einer wichtigen Info sofort das Gespraech mit hero (hero.aivar[22] = TRUE,
    // AI_StartState(self, ZS_Talk, 1, "")) statt ZS_ReactToDamage. Trifft der Mitspieler so einen NPC, lief der zum eigenen
    // Helden, um zu reden ("sucht den Helden") - oder brach ab und machte im Tagesablauf weiter ("reagiert nicht"; Log Host:
    // VLK_10024_BUDDLER blieb in ZS_SAW). Mit "keine Info" geht er wie bei jedem menschlichen Angreifer in ZS_ReactToDamage ->
    // ZS_AssessEnemy -> Npc_SetTarget(self, other). Parameter wie das Original vom Stapel (letzter zuerst), Rueckgabe 0.
    static CoopParserExternal2 OrigNpcCheckInfo = NULL;
    static zCPar_Symbol* CheckInfoOtherSym = NULL;
    static zCParser* CheckInfoOtherParser = NULL;

    // v91: Parameter von Npc_CheckInfo(npc, important) ansehen, ohne sie vom Stapel zu nehmen. Datenstapel zCParser +0x58:
    // int[0x400], Stapelzeiger (Index) +0x1000 (zCPar_DataStack::Pop 0x006FB510). Oben liegt important als [Wert, 0x40] bzw.
    // [Adresse, 0x41] (PopDataValue 0x006E8550 ueber GetParameter 0x006F6DF0), darunter die Symbolnummer der Instanz
    // (GetInstance 0x006F6F80: ein Wert, Symbol +0x1C = Instanzzeiger). Im Speicherabbild alle unveraendert.
    static bool CheckInfoPeek(zCParser* p, oCNpc*& self, int& important) {
        // u3: SDK-Felder - G2A hat einen doppelt so grossen Stapel (int[2048], sptr +0x2000 statt +0x1000)
        const int* st = p->datastack.stack;
        const int sp = p->datastack.sptr;
        const int spMax = (int)(sizeof(p->datastack.stack) / sizeof(p->datastack.stack[0]));
        if (sp < 3 || sp > spMax)
            return false;
        const int tok = st[sp - 1], v = st[sp - 2];
        if (tok == 0x40)
            important = v;
        else if (tok == 0x41 && v)
            important = *(const int*)v;
        else
            return false;
        const int idx = st[sp - 3];
        zCPar_Symbol* s = idx > 0 ? p->GetSymbol(idx) : NULL;
        self = s ? (oCNpc*)s->offset : NULL;
        return true;
    }

    static int __cdecl CoopExtNpcCheckInfo() {
        zCParser* p = zCParser::GetParser();
        if (p != parser || !p)
            return OrigNpcCheckInfo ? OrigNpcCheckInfo() : 0;
        if (CheckInfoOtherParser != parser) {
            CheckInfoOtherParser = parser;
            CheckInfoOtherSym = parser->GetSymbol(zSTRING("OTHER"));
        }
        oCNpc* other = CheckInfoOtherSym ? (oCNpc*)CheckInfoOtherSym->offset : NULL;
        // v91: eigener Held - keine wichtige Info, wenn der NPC gerade mit einem Mitspieler spricht (allgemein, "einer je NPC") oder
        // nach einem gemeinsamen neuen Spiel der Host noch nicht gesprochen hat (Diego geht zum Host, der Client sieht zu)
        if (other && other == player) {
            oCNpc* self = NULL;
            int important = 0;
            if (CheckInfoPeek(p, self, important) && important) {
                const bool busy = self && CoopDialogNpcBusy(self);
                if (busy || CoopNewGameInfoBlocked()) {
                    p->GetParameter(important);   // wie das Original vom Stapel nehmen (letzter zuerst)
                    p->GetInstance();
                    p->SetReturn(0);
                    static unsigned long ownLines = 0;
                    if (ownLines++ < 40)
                        DialogLog("Npc_CheckInfo(%s, 1) -> keine Info (%s)", self ? self->GetObjectName().ToChar() : "?",
                            busy ? "spricht gerade mit einem Mitspieler" : "neues Spiel: der Host spricht zuerst");
                    return 0;
                }
            }
            return OrigNpcCheckInfo ? OrigNpcCheckInfo() : 0;
        }
        if (!other || !PlayerNpcs.count(other))
            return OrigNpcCheckInfo ? OrigNpcCheckInfo() : 0;
        int important = 0;
        p->GetParameter(important);   // letzter Parameter zuerst
        oCNpc* self = (oCNpc*)p->GetInstance();
        p->SetReturn(0);
        static unsigned long lines = 0;
        if (lines++ < 40)
            DialogLog("Npc_CheckInfo(%s, %d) bei Wahrnehmung von %s -> keine Info (sonst ginge der NPC zum eigenen Helden reden)",
                self ? self->GetObjectName().ToChar() : "?", important, other->GetObjectName().ToChar());
        return 0;
    }

    static void HostEvInstallOne(const char* name, CoopParserExternal2& orig, CoopParserExternal2 mine) {
        zCPar_Symbol* s = parser->GetSymbol(zSTRING(name));
        if (!s || s->type != zPAR_TYPE_FUNC || !(s->flags & zPAR_FLAG_EXTERNAL) || !s->single_intdata) {
            DialogLog("Host-Ereignis: External %s nicht gefunden - nicht umgeleitet", name);
            return;
        }
        if ((CoopParserExternal2)s->single_intdata == mine)
            return;
        orig = (CoopParserExternal2)s->single_intdata;
        s->single_intdata = (int)mine;
        DialogLog("Host-Ereignis: External %s umgeleitet (Original %p)", name, orig);
    }

    static void HostEvInstall() {
        if (HostEvInstalled || !parser)
            return;
        HostEvInstalled = true;
        HostEvInstallOne("WLD_INSERTNPC", OrigWldInsertNpc, &CoopExtWldInsertNpc);
        HostEvInstallOne("WLD_SENDTRIGGER", OrigWldSendTrigger, &CoopExtWldSendTrigger);
        HostEvInstallOne("WLD_SENDUNTRIGGER", OrigWldSendUntrigger, &CoopExtWldSendUntrigger);
        HostEvInstallOne("NPC_CHECKINFO", OrigNpcCheckInfo, &CoopExtNpcCheckInfo);   // v49
        HostEvInstallOne("INTRODUCECHAPTER", OrigIntroduceChapter, &CoopExtIntroduceChapter);   // v92
        HostEvInstallOne("WLD_INSERTITEM", OrigWldInsertItem, &CoopExtWldInsertItem);   // u27 (D13d)
        HostEvInstallOne("PLAYVIDEO", OrigPlayVideo, &CoopExtPlayVideo);                // u28 (B5)
        HostEvInstallOne("PLAYVIDEOEX", OrigPlayVideoEx, &CoopExtPlayVideoEx);
        HostEvInstallOne("CREATEINVITEM", OrigCreateInvItem, &CoopExtCreateInvItem);           // u163 (P170)
        HostEvInstallOne("CREATEINVITEMS", OrigCreateInvItems, &CoopExtCreateInvItems);
        HostEvInstallOne("NPC_REMOVEINVITEM", OrigRemoveInvItem, &CoopExtRemoveInvItem);
        HostEvInstallOne("NPC_REMOVEINVITEMS", OrigRemoveInvItems, &CoopExtRemoveInvItems);
        HostEvInstallOne("NPC_CHANGEATTRIBUTE", OrigNpcChangeAttribute, &CoopExtNpcChangeAttribute);   // u195 (P200)
        HostEvInstallOne("WLD_REMOVENPC", OrigWldRemoveNpc, &CoopExtWldRemoveNpc);
        HostEvInstallOne("WLD_SPAWNNPCRANGE", OrigWldSpawnNpcRange, &CoopExtWldSpawnNpcRange);   // u199 (P215)
#if ENGINE >= Engine_G2
        HostEvInstallOne("EXITSESSION", OrigExitSession, &CoopExtExitSession);          // u147 (P149)
#endif
    }

    // Host: ein Original-External mit Parametern ausfuehren (Anfrage eines Clients)
    static void HostEvRunInsertNpc(const std::string& inst, const std::string& wp) {
        const int idx = parser->GetIndex(zSTRING(inst.c_str()));
        if (idx < 0 || !OrigWldInsertNpc || zCParser::GetParser() != parser) {
            DialogLog("Host-Ereignis: Spawn %s an %s nicht moeglich", inst.c_str(), wp.c_str());
            return;
        }
        zSTRING w(wp.c_str());
        DialogPushInt(idx);
        DialogPushString(&w);
        HostEvApplying++;
        OrigWldInsertNpc();
        HostEvApplying--;
    }

    // u27 (D13d): Wld_InsertItem mit Parametern ausfuehren (Host: Anfrage eines Clients, Client: Meldung des Hosts)
    static bool HostEvRunInsertItem(const std::string& inst, const std::string& wp) {
        const int idx = parser->GetIndex(zSTRING(inst.c_str()));
        if (idx < 0 || !OrigWldInsertItem || zCParser::GetParser() != parser) {
            DialogLog("Host-Ereignis: Gegenstand %s an %s nicht moeglich", inst.c_str(), wp.c_str());
            return false;
        }
        zSTRING w(wp.c_str());
        DialogPushInt(idx);
        DialogPushString(&w);
        HostEvApplying++;
        OrigWldInsertItem();
        HostEvApplying--;
        return true;
    }

    static void HostEvRunTrigger(CoopParserExternal2 orig, const std::string& s) {
        if (!orig || zCParser::GetParser() != parser)
            return;
        zSTRING v(s.c_str());
        DialogPushString(&v);
        HostEvApplying++;
        orig();
        HostEvApplying--;
    }

    bool CoopSpawnListPos(oCNpc* npc, zVEC3& pos);                          // v108: CoopFarSync.cpp
    bool CoopSpawnListMove(oCNpc* npc, const zVEC3& pos, const char* why);

    static void SpawnSend(const std::string& n, oCNpc* npc, const std::string& inst, bool repeat) {
        zVEC3 pos = npc->GetPositionWorld();
        // v108: noch nicht in der Welt (Spawn-Liste) - dann die Lage aus dem Eintrag statt der Lage ausserhalb der Welt
        if (npc->vobLeafList.GetNum() == 0)
            CoopSpawnListPos(npc, pos);
        json j;
        j["f"] = "spawn";
        j["n"] = n;
        j["inst"] = inst;
        j["x"] = pos[0];
        j["y"] = pos[1];
        j["z"] = pos[2];
        if (repeat)
            j["r"] = 1;
        HostEvSend(j);
    }

    // Host, je Sekunde: neue GT-Namen = neue NPCs; alle 30 s die Liste wiederholen
    static void SpawnPulse() {
        if (!ServerThread || CurrentMs < SpawnNextMs)
            return;
        SpawnNextMs = CurrentMs + 1000;
        if (!SpawnBaselineDone) {
            if (NpcToUniqueNameList.empty())
                return;
            for (auto& p : NpcToUniqueNameList)
                SpawnKnown.insert(p.second.ToChar());
            SpawnBaselineDone = true;
            SpawnResendMs = CurrentMs + 30000;
            DialogLog("Host-Ereignis: %u NPCs beim Laden - spaeter erzeugte gehen an die Clients", (unsigned)SpawnKnown.size());
            return;
        }
        for (auto& p : NpcToUniqueNameList) {
            const std::string n = p.second.ToChar();
            if (n.empty() || !SpawnKnown.insert(n).second)   // u51 (Befund 3): nie einen leeren Namen melden
                continue;
            oCNpc* npc = p.first;
            if (!npc || npc == player || IsCoopPlayer(npc->GetObjectName()))
                continue;
            const std::string inst = npc->GetInstanceName().ToChar();
            SpawnDynamic[n] = { npc, inst };
            SpawnSend(n, npc, inst, false);
            // v108 (Test v108): sandte der Host den NPC schon vor dieser Meldung (UpdateVisibleNpc alle 0,5 s, die Meldung hier
            // je Sekunde), verwarf der Client die Pakete ("unbekannter NPC-Name im Paket") - darunter das einzige HP-Paket (HP gehen
            // nur bei Aenderung hinaus): Molerat beim Client 127/127 statt 191/191. Jetzt danach alles noch einmal senden.
            auto b = BroadcastNpcs.find(string(n.c_str()));
            if (b != BroadcastNpcs.end() && b->second)
                b->second->Reinit();
            DialogLog("Host-Ereignis: neuer NPC %s (%s) -> Clients%s", n.c_str(), inst.c_str(),
                b != BroadcastNpcs.end() ? " (wurde schon gesendet - Stand folgt noch einmal)" : "");
        }
        if (CurrentMs >= SpawnResendMs && !SpawnDynamic.empty()) {
            SpawnResendMs = CurrentMs + 30000;
            for (auto it = SpawnDynamic.begin(); it != SpawnDynamic.end();) {
                auto u = UniqueNameToNpcList.find(string(it->first.c_str()));
                if (u == UniqueNameToNpcList.end() || u->second != it->second.npc) {   // nicht mehr da
                    it = SpawnDynamic.erase(it);
                    continue;
                }
                if (!it->second.npc->IsDead())
                    SpawnSend(it->first, it->second.npc, it->second.inst, true);
                ++it;
            }
        }
    }

    // Client: NPC des Hosts anlegen oder einen vorhandenen passenden umbenennen
    static void SpawnApply(json& e) {
        const std::string n = e.at("n").get<std::string>();
        const std::string inst = e.at("inst").get<std::string>();
        const zVEC3 pos(e.at("x").get<float>(), e.at("y").get<float>(), e.at("z").get<float>());
        if (n.empty()) {   // u51 (Befund 3): ein Host bis u50 meldete einen unbenannten NPC als "" - nicht anlegen
            DialogLog("Host-Ereignis: NPC %s ohne Namen gemeldet - nicht angelegt", inst.c_str());
            return;
        }
        auto haveIt = UniqueNameToNpcList.find(string(n.c_str()));
        if (haveIt != UniqueNameToNpcList.end() && !haveIt->second) {
            // u51 (Befund 4): NULL-Eintrag (bis u50 aus RemoteNpc::UpdateAttacks fuer ein unbekanntes Ziel) - gilt als unbekannt
            UniqueNameToNpcList.erase(haveIt);
            haveIt = UniqueNameToNpcList.end();
        }
        if (haveIt != UniqueNameToNpcList.end()) {
            SpawnFromHost.insert(n);
            // u199 (P212): ein hier eben eingefuegter NPC, der zufaellig schon so heisst wie beim Host - gilt als uebernommen
            for (auto it = HostEvPendingNpc.begin(); it != HostEvPendingNpc.end(); ++it)
                if (it->vob == (void*)haveIt->second) {
                    HostEvPendingNpc.erase(it);
                    CoopTestPendingAdopted++;
                    DialogLog("Host-Ereignis: NPC %s (hier eben eingefuegt) heisst schon wie beim Host (P212)", n.c_str());
                    break;
                }
            // v108: schon da, aber nur in der Spawn-Liste - deren Lage an die Meldung angleichen (Wiederholung alle 30 s)
            oCNpc* have = haveIt->second;
            if (have && have->vobLeafList.GetNum() == 0 && !have->IsDead() && pos.LengthApprox() > 1.f)
                CoopSpawnListMove(have, pos, "Meldung des Hosts");
            return;   // schon da (gleicher Name)
        }
        // u199 (P212): eigenes Gegenstueck - diesen NPC hat ein Skript hier eben selbst eingefuegt (und den Host angefragt). Nur diese
        // gemerkten NPCs werden uebernommen, nie ein beliebiger gleicher Instanz in der Naehe (v34)
        // Naechster gemerkter derselben Instanz bis 30 m: Schleifen auf beiden PCs wuerfeln Wegpunkte selbst, Wld_SpawnNpcRange setzt
        // zufaellig um die Figur (P215) - die Lage kommt danach vom Host
        HostEvPendingExpire(HostEvPendingNpc);
        auto bestIt = HostEvPendingNpc.end();
        float pendD = 3000.f;
        for (auto it = HostEvPendingNpc.begin(); it != HostEvPendingNpc.end(); ++it) {
            oCNpc* cand = it->inst == inst ? HostEvPendingNpcAlive(it->vob) : NULL;
            const float d = cand ? (cand->GetPositionWorld() - pos).Length() : 1e9f;
            if (cand && d < pendD) {
                pendD = d;
                bestIt = it;
            }
        }
        for (auto it = bestIt; it != HostEvPendingNpc.end(); it = HostEvPendingNpc.end()) {
            oCNpc* mine = HostEvPendingNpcAlive(it->vob);
            auto old = NpcToUniqueNameList.find(mine);
            const std::string oldName = old != NpcToUniqueNameList.end() ? old->second.ToChar() : std::string();
            if (!oldName.empty())
                UniqueNameToNpcList.erase(string(oldName.c_str()));
            NpcToUniqueNameList[mine] = string(n.c_str());
            UniqueNameToNpcList[string(n.c_str())] = mine;
            SpawnFromHost.insert(n);
            DialogLog("Host-Ereignis: NPC %s (%s, hier eben eingefuegt) heisst jetzt %s wie beim Host (P212)", oldName.empty() ? "ohne Namen" : oldName.c_str(),
                inst.c_str(), n.c_str());
            HostEvPendingNpc.erase(it);
            CoopTestPendingAdopted++;
            return;
        }
        // Nur bei der Wiederholung (r): vorhandener NPC gleicher Instanz in der Naehe, der nach dem Laden eines Host-Stands hier
        // anders heisst. v34: Test v33 zeigte, dass eine frische Meldung eine ANDERE, schon vorhandene Fleischwanze umbenannte
        // ("MEATBUG-OCR_LADDER_TOP_01-1 heisst hier jetzt ...") - frische Meldungen legen deshalb immer neu an, und NPCs, fuer
        // die der Host Pakete schickt (CoopHostActiveNames, CoopDiag.cpp), gehoeren ihm unter ihrem Namen und sind tabu.
        oCNpc* best = NULL;
        float bestD = 300.f;
        for (auto* l = e.contains("r") ? CoopWorldNpcListFirst(ogame->GetGameWorld()) : NULL; l; l = l->next) {
            oCNpc* npc = l->data;
            if (StoryNpcSkip(npc) || npc->IsDead() || inst != npc->GetInstanceName().ToChar())
                continue;
            auto nm = NpcToUniqueNameList.find(npc);
            if (nm != NpcToUniqueNameList.end() && (SpawnFromHost.count(nm->second.ToChar()) || CoopHostActiveNames.count(nm->second.ToChar())))
                continue;
            const zVEC3 d = npc->GetPositionWorld() - pos;
            if (d.Length() < bestD) {
                bestD = d.Length();
                best = npc;
            }
        }
        if (best) {
            auto old = NpcToUniqueNameList.find(best);
            const std::string oldName = old != NpcToUniqueNameList.end() ? old->second.ToChar() : std::string();
            if (!oldName.empty())
                UniqueNameToNpcList.erase(string(oldName.c_str()));
            NpcToUniqueNameList[best] = string(n.c_str());
            UniqueNameToNpcList[string(n.c_str())] = best;
            SpawnFromHost.insert(n);
            DialogLog("Host-Ereignis: NPC %s heisst hier jetzt %s (wie beim Host)", oldName.empty() ? "?" : oldName.c_str(), n.c_str());
            return;
        }
        if (e.contains("r"))
            return;   // Wiederholung: nur umbenennen, nicht nachtraeglich erzeugen (z. B. hier gestorben/entfernt)
        const int idx = parser->GetIndex(zSTRING(inst.c_str()));
        if (idx < 0) {
            DialogLog("Host-Ereignis: Instanz %s unbekannt - %s nicht angelegt", inst.c_str(), n.c_str());
            return;
        }
        oCNpc* npc = dynamic_cast<oCNpc*>(ogame->GetGameWorld()->CreateVob(zTVobType::zVOB_TYPE_NSC, idx));
        if (!npc) {
            DialogLog("Host-Ereignis: CreateVob(%s) lieferte keinen NPC", inst.c_str());
            return;
        }
        zVEC3 p = pos;
        // v43: InsertNpc prueft den Abstand zu camPos (eigener Held) und setzt weit weg nichts ein - Test v42: Molerat 80 m vom
        // Client "da, nicht in der Welt", danach nie gefuehrt. Im Umkreis eines Mitspielers wie die Figur einsetzen
        // (CoopSpawnInsertAt), sonst in die Spawn-Liste (SpawnNpc 0x006D0710, GD3D11 ruft das Original zuerst) - dann erscheint
        // er, sobald jemand in die Naehe kommt.
        const char* how = "eingesetzt";
        bool inWorld = CoopFollowActive() && CoopFollowNear(p, (float)BROADCAST_DISTANCE) && CoopSpawnInsertAt(npc, p);
        if (inWorld)
            how = "beim Mitspieler eingesetzt";
        else
            inWorld = ogame->spawnman->InsertNpc(npc, p) != 0;
        if (!inWorld) {
            ogame->spawnman->SpawnNpc(npc, p, 0.f);
            how = "weit weg - in der Spawn-Liste";
        }
        NpcToUniqueNameList[npc] = string(n.c_str());
        UniqueNameToNpcList[string(n.c_str())] = npc;
        SpawnFromHost.insert(n);
        DialogLog("Host-Ereignis: NPC %s (%s) vom Host angelegt (%s)", n.c_str(), inst.c_str(), how);
    }

    static void HostEvReceive(json& e, const std::string& by, bool relay) {
        const std::string f = e.contains("f") && e["f"].is_string() ? e["f"].get<std::string>() : std::string();
        if (ServerThread && !relay) {   // Anfrage eines Clients
            // u195 (P202): Gegenstueck eines eigenen Ereignisses der letzten 3 s (Schleife auf beiden PCs) - nicht noch einmal
            auto twin = [&](const std::string& key) {
                if (HostEvTwinAllow(key, 1))
                    return true;
                DialogLog("Host-Ereignis: Anfrage %s von %s hat der Host eben selbst ausgefuehrt - nicht noch einmal (P202)", key.c_str(), by.c_str());
                return false;
            };
            if (f == "spawnreq") {
                const std::string inst = e.at("inst").get<std::string>(), wp = e.at("wp").get<std::string>();
                if (!twin(HostEvKey("spawn", inst)))   // u199 (P212): ohne Wegpunkt wie beim eigenen Skript
                    return;
                HostEvRunInsertNpc(inst, wp);
            }
            else if (f == "itemreq") {   // u27 (D13d): Gegenstand anlegen und allen melden (auch dem Anfragenden)
                const std::string inst = e.at("inst").get<std::string>(), wp = e.at("wp").get<std::string>();
                if (!twin(HostEvKey("item", inst, wp)))
                    return;
                if (CoopRuleWorld() && HostEvRunInsertItem(inst, wp)) {
                    json j;
                    j["f"] = "item";
                    j["inst"] = inst;
                    j["wp"] = wp;
                    HostEvSend(j);
                }
            }
            else if (f == "triggerreq" || f == "untriggerreq") {
                const std::string s = e.at("s").get<std::string>();
                const bool trig = f == "triggerreq";
                if (!twin(HostEvKey(trig ? "trigger" : "untrigger", s)))
                    return;
                HostEvRunTrigger(trig ? OrigWldSendTrigger : OrigWldSendUntrigger, s);
                CoopTestTrigCount++;
                CoopTestTrigLast = std::string(trig ? "trigger:" : "untrigger:") + s;
                json j;
                j["f"] = trig ? "trigger" : "untrigger";
                j["s"] = s;
                HostEvSend(j);
            }
            else if (f == "spawnrangereq") {   // u199 (P215)
                const std::string inst = e.value("inst", std::string());
                if (!twin(HostEvKey("spawnrange", inst)))
                    return;
                HostEvRunSpawnRange(inst, e.value("ref", by), e.value("n", 1), e.value("life", 0.f));
            }
            else if (f == "telereq")   // u195 (P200)
                HostEvRunTeleport(e.value("n", std::string()), e.value("wp", std::string()));
            else if (f == "killreq")
                HostEvRunKill(e.value("n", std::string()));
            else if (f == "removereq") {
                const std::string inst = e.value("inst", std::string());
                if (!twin(HostEvKey("remove", inst)))
                    return;
                HostEvRunRemoveNpc(inst);
                json j;
                j["f"] = "remove";
                j["inst"] = inst;
                HostEvSend(j);
            }
            DialogLog("Host-Ereignis: Anfrage %s von %s ausgefuehrt", f.c_str(), by.c_str());
            return;
        }
        if (ServerThread)
            return;
        if (f == "spawn")
            SpawnApply(e);
        else if (f == "item") {   // u27 (D13d): Gegenstand des Hosts am selben Wegpunkt anlegen
            const std::string inst = e.at("inst").get<std::string>(), wp = e.at("wp").get<std::string>();
            // u199 (P212): hat ein Skript ihn hier eben selbst angelegt (und den Host angefragt), ist er schon da
            HostEvPendingExpire(HostEvPendingItem);
            for (auto it = HostEvPendingItem.begin(); it != HostEvPendingItem.end(); ++it)
                if (it->inst == inst && !_stricmp(it->wp.c_str(), wp.c_str())) {
                    const bool alive = HostEvPendingItemAlive(it->vob);
                    HostEvPendingItem.erase(it);
                    if (!alive) {   // inzwischen weg (Welt-Abgleich vor der Meldung) - dann doch wie die Meldung anlegen
                        DialogLog("Host-Ereignis: Gegenstand %s an %s war hier angelegt, ist aber weg - lege ihn wie beim Host an (P212)", inst.c_str(), wp.c_str());
                        break;
                    }
                    CoopTestPendingAdopted++;
                    DialogLog("Host-Ereignis: Gegenstand %s an %s hat ein Skript hier schon angelegt - nicht noch einmal (P212)", inst.c_str(), wp.c_str());
                    return;
                }
            if (HostEvRunInsertItem(inst, wp))
                DialogLog("Host-Ereignis: Gegenstand %s an %s vom Host angelegt", inst.c_str(), wp.c_str());
        }
        else if (f == "trigger" || f == "untrigger") {
            const std::string s = e.at("s").get<std::string>();
            HostEvRunTrigger(f == "trigger" ? OrigWldSendTrigger : OrigWldSendUntrigger, s);
            CoopTestTrigCount++;
            CoopTestTrigLast = f + ":" + s;
        }
        else if (f == "remove") {   // u195 (P200): Wld_RemoveNpc des Hosts auch hier
            const std::string inst = e.value("inst", std::string());
            HostEvRunRemoveNpc(inst);
            DialogLog("Host-Ereignis: Wld_RemoveNpc(%s) vom Host - hier auch (P200)", inst.c_str());
        }
    }

    // --- Pakete ------------------------------------------------------------------------------------

    bool CoopDialogSyncHandles(int type) {
        return type >= SYNC_DIALOG_START && type <= SYNC_HOST_EVENT;
    }

    void CoopDialogSyncReceive(json& e, const std::string& id) {
        const int type = e["type"].get<int>();
        try {
            if (!DialogSyncAktiv())
                return;
            // Client-Pakete kommen ohne "by"; der Host verteilt sie mit "by". Die automatisch weitergeleitete
            // Client-Fassung (ohne "by") ignorieren die anderen Clients.
            const bool relay = e.contains("by") && e["by"].is_string();
            const std::string by = relay ? e["by"].get<std::string>() : id;
            if (!ServerThread && !relay)
                return;
            if (by == DialogMe())
                return;
            const bool sameWorld = !(e.contains("w") && e["w"].is_string() && e["w"].get<std::string>() != CoopWorldName());
            if (type == SYNC_HOST_EVENT) {   // v33: Anfragen nicht weiterverteilen - der Host handelt und verteilt das Ergebnis
                if (sameWorld)
                    HostEvReceive(e, by, relay);
                return;
            }
            if (ServerThread && !relay) {
                json j = e;
                j["by"] = id;
                j["id"] = MyselfId.ToChar();
                CoopTraceCount(TRACE_SENT, type);
                ReadyToSendJsons.enqueue(j);
            }
            // Partner in einer anderen Welt - gleichnamige NPCs waeren andere. Das Ende gilt immer (es hebt nur eine
            // vorhandene Sperre auf), der Fortschritt bis auf den NPC-Teil auch (Skriptvariablen/Tagebuch sind global).
            if (!sameWorld && type != SYNC_DIALOG_END && type != SYNC_DIALOG_STATE)
                return;
            const std::string n = e.contains("n") && e["n"].is_string() ? e["n"].get<std::string>() : std::string();
            switch (type) {
            case SYNC_DIALOG_START:
            {
                DialogLocks[n] = { by, CurrentMs };
                DialogDropEnd(n);
                DialogLineQueue.erase(n);
                DialogFreezeStart(n, by);
                DialogLog("%s spricht mit %s - gesperrt, NPC angehalten", by.c_str(), n.c_str());
                break;
            }
            case SYNC_DIALOG_LINE:
            {
                const std::string s = e.at("s").get<std::string>();
                const std::string o = e.at("o").get<std::string>();
                const bool svm = e.contains("svm") && e["svm"].is_number() && e["svm"].get<int>() != 0;
                DialogPlayLine(n, by, s, o, svm);
                break;
            }
            case SYNC_DIALOG_SKIP:
            {
                DialogCutLine(n, by, e.at("s").get<std::string>(), e.at("o").get<std::string>());
                break;
            }
            case SYNC_DIALOG_END:
            {
                auto f = DialogLocks.find(n);
                if (f == DialogLocks.end() || f->second.owner != by)
                    break;
                DialogLocks.erase(f);
                DialogDropEnd(n);
                DialogEnds.push_back({ n, by, CurrentMs });
                DialogLog("%s beendet den Dialog mit %s - frei", by.c_str(), n.c_str());
                CoopNewGameDialogEnded(by, n);   // v91: erstes Gespraech des Hosts nach dem gemeinsamen Start
                break;
            }
            case SYNC_DIALOG_STATE:
            {
                DialogApplyState(e, by, sameWorld);
                break;
            }
            }
        }
        catch (std::exception& ex) {
            CoopErrorLog("Dialog-Sync", ex.what(), CoopUpdateTypeName(type));
        }
    }

    void CoopDialogSyncPeerGone(const std::string& who) {
        for (auto it = DialogLocks.begin(); it != DialogLocks.end();) {
            if (it->second.owner == who) {
                const std::string n = it->first;
                it = DialogLocks.erase(it);
                DialogRelease(n, who);
                DialogLog("%s getrennt - Sperre fuer %s aufgehoben", who.c_str(), n.c_str());
            }
            else
                ++it;
        }
    }

    void CoopDialogSyncWorldLoaded() {
        if (!MyDialogNpc.empty() && (ServerThread || ClientThread)) {   // mitten im Dialog geladen: Sperre beim Partner aufheben
            json j;
            j["n"] = MyDialogNpc;
            DialogSend(j, SYNC_DIALOG_END);
        }
        DialogLocks.clear();
        DialogEnds.clear();
        DialogFrozen.clear();
        ChapterPending.clear();   // v94: nach dem Laden gilt der Bildschirm nicht mehr
        DialogLineQueue.clear();
        DialogLastInjectMs.clear();
        MyDialogNpcPtr = NULL;
        MyDialogNpc.clear();
        LastLineMsg.clear();
        TrackHero = CoopDialogLineTrack();
        TrackNpc = CoopDialogLineTrack();
        StoryReady = false;   // neuer Vergleichsstand nach dem Laden (Init-Skripte abwarten)
        StoryNextMs = GetCurrentMs() + 3000;
        SpawnKnown.clear();   // v33: neue Bestandsaufnahme nach dem Erstlauf von BuildGlobalNpcList
        SpawnDynamic.clear();
        SpawnFromHost.clear();
        HostEvPendingNpc.clear();    // u199 (P212): nach dem Laden gehoeren sie zu keiner Anfrage mehr
        HostEvPendingItem.clear();
        PartyLeaderClear();          // u199 (P217): neue NPC-Zeiger nach dem Laden
        HeroStateClear();            // u199 (P221): ebenso
        CoopHostActiveNames.clear();
        SpawnBaselineDone = false;
        SpawnNextMs = GetCurrentMs() + 2500;
        CoopMissionReset(8000);   // u96: der Bestand kommt aus dem Spielstand (dazu die Uebernahme) - nicht als Aenderung melden
        MiWaiting.clear();        // u149 (P152)
    }

    // --- Coop-Test per Taste (v32, Wunsch des Nutzers: "Simulation mit einem Hotkey") ---------------------
    //
    // Shift + CoopSimKey (Standard F11; F10/F12 = Schnellspeichern/-laden). v32-v36: vier Einzelschritte reihum. Seit v37 ein
    // ganzer Testlauf mit 26 Schritten und Rueckmeldung des Partners (CoopSelfTest.cpp, D12b).
    void CoopSelfTestToggle(bool worldsOnly);   // CoopSelfTest.cpp (u44: Shift+F11 Welten-Testlauf, mit Strg der volle Lauf)
    static int CoopSimKey = 0;
    static bool CoopSimKeyWas = true;
    static int CoopSimStep = 0;

    static bool CoopSimShiftDown() {
        if (zinput->KeyPressed(KEY_LSHIFT) || zinput->KeyPressed(KEY_RSHIFT))
            return true;
        HWND fg = GetForegroundWindow();
        DWORD pid = 0;
        if (fg)
            GetWindowThreadProcessId(fg, &pid);
        return pid == GetCurrentProcessId() && (GetAsyncKeyState(VK_SHIFT) & 0x8000);
    }

    // u44: Strg dazu = voller Testlauf (144 Schritte); ohne Strg nur der Welten-Testlauf (CoopSelfTest.cpp CTInRun) - Nutzer:
    // "die ersten 100 tests etwa sind überflüssig", "hast du die alten bestandenen tests entfernt?"
    static bool CoopSimCtrlDown() {
        if (zinput->KeyPressed(KEY_LCONTROL) || zinput->KeyPressed(KEY_RCONTROL))
            return true;
        HWND fg = GetForegroundWindow();
        DWORD pid = 0;
        if (fg)
            GetWindowThreadProcessId(fg, &pid);
        return pid == GetCurrentProcessId() && (GetAsyncKeyState(VK_CONTROL) & 0x8000);
    }

    // u190 (P193): Die Instanz des eigenen Helden (PC_HERO) und HERO zeigen auf den eigenen Helden. Manche Mods holen den Helden selbst:
    // Legend of Ahssun setzt hero = Hlp_GetNpc(PC_HERO) in SCHLEIFE_ALL und INIT_GLOBAL, Gothic II tut das nie. Hlp_GetNpc liefert den
    // NPC, auf den das Instanz-Symbol zeigt. Beim Client von LoA war das nicht der eigene Held, also gingen EP und Gegenstaende aus
    // Skripten an einen anderen NPC (voller Coop-Test u189: "Quest-EP +10 (Dialog)" ohne EP, Npc_HasItems(Held, Apfel) = 0). GT prueft
    // das jede Sekunde und stellt es zurueck; das Log nennt, worauf es zeigte. Allgemein.
    static long long CoopHeroSymbolNext = 0;

    static void CoopHeroSymbolPulse() {
        if (!player || !parser || !(ServerThread || ClientThread) || IsLoadingLevel || CurrentMs < CoopHeroSymbolNext)
            return;
        CoopHeroSymbolNext = CurrentMs + 1000;
        static CoopDiagBudget budget = { 0, 0 };
        auto fix = [&](zCPar_Symbol* s) {
            if (!s || s->type != zPAR_TYPE_INSTANCE || (oCNpc*)s->offset == player)
                return;
            oCNpc* was = (oCNpc*)s->offset;
            std::string wasName = "nichts";
            if (was) {
                auto pn = PlayerNpcs.find(was);
                auto un = NpcToUniqueNameList.find(was);
                wasName = pn != PlayerNpcs.end() ? std::string("Figur ") + pn->second.ToChar() :
                    un != NpcToUniqueNameList.end() ? std::string(un->second.ToChar()) : std::string("unbekannt");
            }
            const std::string nm = s->name.ToChar();
            parser->SetInstance(zSTRING(nm.c_str()), player);
            if (CoopDiagAllow(budget, 10))
                DialogLog("Instanz %s zeigte auf %s (%p) statt auf den eigenen Helden - zurueckgestellt (P193)", nm.c_str(), wasName.c_str(), was);
        };
        fix(parser->GetSymbol(player->GetInstance()));
        fix(parser->GetSymbol(zSTRING("HERO")));
    }

    // u195 (P201): gleich nach dem Laden pruefen, nicht erst bis zu 1 s spaeter (Plugin.cpp LoadEnd, nach dem Entfernen fremder Helden
    // und nach dem Einsetzen des eigenen). Legend of Ahssun holt den Helden in Frame-Funktionen ueber Hlp_GetNpc(PC_HERO)
    // (LOA_CHANGEFOCUSBAR, SCHLEIFE_ALL - docs\mod-analyse\LoA.md); dazwischen konnte PC_HERO auf einen entfernten Helden zeigen.
    void CoopHeroSymbolFixNow() {
        CoopHeroSymbolNext = 0;
        CoopHeroSymbolPulse();
    }

    void CoopDialogSyncPulse() {
        CoopHeroSymbolPulse();   // u190 (P193)
        MiKennPulse(false);   // u104: Kennzeichnung gespiegelter Missions-Gegenstaende (ohne Coop nur zurueck)
        DlgGuildNpcPendingApply();   // u152 (P156)
        if (!DialogSyncAktiv())
            return;
        CoopMissionPulse();   // u96: Missions-Gegenstaende spiegeln
        if (!CoopSimKey)
            CoopSimKey = ReadConfigKey("CoopSimKey", "KEY_F11");
        if (CoopSimKey && CoopKeyEdge(CoopSimKey, CoopSimKey == KEY_F11 ? VK_F11 : 0, CoopSimKeyWas) && CoopSimShiftDown()
            && !MyDialogNpcPtr) {
            try {
                CoopSelfTestToggle(!CoopSimCtrlDown());
            }
            catch (std::exception& ex) {
                CoopErrorLog("Coop-Test", ex.what(), "Schritt");
            }
        }
        HostEvInstall();   // v33
        try {
            SpawnPulse();
        }
        catch (std::exception& ex) {
            CoopErrorLog("Host-Ereignis", ex.what(), "Spawn");
        }
        StoryReadConfig();
        // v75: Quests und Tagebuch einzeln (Einstellungen -> COOP -> Abgleich, Host gibt vor); coopStorySync aus der json belegt
        // die beiden Menue-Werte nur beim ersten Start vor
        if ((CoopRuleQuests() || CoopRuleLog()) && parser && CurrentMs >= StoryNextMs) {
            StoryNextMs = CurrentMs + 1000;
            try {
                StoryTick();
            }
            catch (std::exception& ex) {
                CoopErrorLog("Story-Abgleich", ex.what(), "Takt");
            }
        }
        TrackOwnDialog();
        if (MyDialogNpcPtr && !MyDialogNpc.empty())
            DialogCheckSkips();
        for (auto& q : DialogLineQueue)
            DialogPumpLines(q.first);
        // beendete Dialoge: NPC freigeben, sobald er (und die Figur) nicht mehr spricht und keine Zeile mehr wartet
        for (auto it = DialogEnds.begin(); it != DialogEnds.end();) {
            oCNpc* npc = DialogNpcByName(it->n);
            oCNpc* fig = DialogFigureOf(it->by);
            auto q = DialogLineQueue.find(it->n);
            const bool waiting = q != DialogLineQueue.end() && !q->second.empty();
            if (CurrentMs > it->since + 15000 || (!waiting && !DialogSpeaking(npc) && !DialogSpeaking(fig))) {
                const CoopDialogEnd end = *it;
                it = DialogEnds.erase(it);
                DialogLineQueue.erase(end.n);
                DialogRelease(end.n, end.by);
            }
            else
                ++it;
        }
        // veraltete Sperren (10 min ohne Ende) aufheben
        for (auto it = DialogLocks.begin(); it != DialogLocks.end();) {
            if (CurrentMs > it->second.since + 600000) {
                const std::string n = it->first, owner = it->second.owner;
                DialogLog("Sperre fuer %s (von %s) veraltet - aufgehoben", n.c_str(), owner.c_str());
                it = DialogLocks.erase(it);
                DialogRelease(n, owner);
                continue;
            }
            ++it;
        }
        if (DialogLocks.empty() && DialogEnds.empty() && !DialogFrozen.empty())
            DialogFrozen.clear();
        DialogChapterPulse();   // v94
        DialogPendingNpcPulse();   // v110
    }

    // --- Hooks -------------------------------------------------------------------------------------

    int __fastcall oCNpc_EV_Output_Coop(oCNpc* _this, void* vtable, oCMsgConversation* msg);
    CInvoke<int(__thiscall*)(oCNpc*, oCMsgConversation*)> Ivk_oCNpc_EV_Output_Coop(CoopAddr::oCNpc_EV_Output, &oCNpc_EV_Output_Coop,
        COOP_IVK(Dialog));
    int __fastcall oCNpc_EV_Output_Coop(oCNpc* _this, void* vtable, oCMsgConversation* msg) {
        const int r = Ivk_oCNpc_EV_Output_Coop(_this, msg);
        if (r)   // v28: erst wenn die Zeile startet - solange das Gegenueber noch spricht, liefert EV_Output 0 (wartet)
            ReportLine(_this, msg, false);
        return r;
    }

    int __fastcall oCNpc_EV_OutputSVM_Coop(oCNpc* _this, void* vtable, oCMsgConversation* msg);
    CInvoke<int(__thiscall*)(oCNpc*, oCMsgConversation*)> Ivk_oCNpc_EV_OutputSVM_Coop(CoopAddr::oCNpc_EV_OutputSVM, &oCNpc_EV_OutputSVM_Coop,
        COOP_IVK(Dialog));
    int __fastcall oCNpc_EV_OutputSVM_Coop(oCNpc* _this, void* vtable, oCMsgConversation* msg) {
        const int r = Ivk_oCNpc_EV_OutputSVM_Coop(_this, msg);
        if (r)
            ReportLine(_this, msg, true);
        return r;
    }

#if COOP_BUILD(HooksExt)
    bool CoopPercPuppetHere(oCNpc* npc);   // Hooks.cpp (u188, P189)
    int CoopPercCount(oCNpc* npc);
#endif

    // Spricht ein Mitspieler gerade mit diesem NPC, darf der eigene Held ihn nicht ansprechen.
    int __fastcall oCNpc_AssessTalk_S_Coop(oCNpc* _this, void* vtable, oCNpc* other);
    CInvoke<int(__thiscall*)(oCNpc*, oCNpc*)> Ivk_oCNpc_AssessTalk_S_Coop(CoopAddr::oCNpc_AssessTalk_S, &oCNpc_AssessTalk_S_Coop,
        COOP_IVK(Dialog));
    int __fastcall oCNpc_AssessTalk_S_Coop(oCNpc* _this, void* vtable, oCNpc* other) {
        if (other && other == player && _this && !DialogLocks.empty() && DialogSyncAktiv()) {
            auto f = DialogLocks.find(DialogNpcName(_this));
            if (f != DialogLocks.end() && f->second.owner != DialogMe()) {
                if (CurrentMs > DialogBusyMsgMs + 3000) {
                    DialogBusyMsgMs = CurrentMs;
                    ChatLog(string::Combine(CoopTr("%s spricht gerade mit %s.", "%s is talking to %s."), string(f->second.owner.c_str()), string(f->first.c_str())));
                }
                return 0;
            }
        }
        int r = Ivk_oCNpc_AssessTalk_S_Coop(_this, other);
#if COOP_BUILD(HooksExt)
        // u188 (P189): Rest der Taubheit beim Client. Hat ein NPC, den der Host fuehrt, gar keine Wahrnehmung mehr, nimmt er kein
        // Gespraech an. Ursache war eine gesperrte Reaktion vor u188 oder ein anderer Weg. Dann die Gespraechs-Wahrnehmung
        // einschalten wie das Skript (Npc_PercEnable(self, PERC_ASSESSTALK, B_AssessTalk)) und noch einmal ansprechen.
        // die Testinstanz macht es seit b19 fuer sich selbst.
        if (!r && other && other == player && _this && CoopPercPuppetHere(_this) && !_this->IsDead() && !_this->IsUnconscious() &&
            _this->GetWeaponMode() == NPC_WEAPON_NONE && !CoopDialogNpcBusy(_this) && CoopPercCount(_this) == 0 && parser) {
            static zCParser* fParser = NULL;
            static int f = -1;
            if (fParser != parser) {
                fParser = parser;
                f = parser->GetIndex(zSTRING("B_ASSESSTALK"));
            }
            if (f >= 0) {
                _this->EnablePerception(NPC_PERC_ASSESSTALK, f);
                r = Ivk_oCNpc_AssessTalk_S_Coop(_this, other);
                DialogLog("%s hatte beim Client keine Wahrnehmung - Gespraechs-Wahrnehmung eingeschaltet, Ansprechen %s",
                    _this->GetObjectName().ToChar(), r ? "klappt" : "weiter abgelehnt");
            }
        }
#endif
        return r;
    }

    // u199 (P217, Durchsicht der Mod-Analyse von Legend of Ahssun): Die KI der Welt-NPCs laeuft beim Host, und Begleiter-Zustaende folgen
    // HERO (ZS_FOLLOW_PLAYER*: AI_GotoNpc(self, hero)) - dort ist das der Host-Held. Begleiter, die ein Client angeworben hat (LoA: Lupia,
    // die Banditen, Ajax/Oric auf der Expedition) oder beschworen (P215), liefen darum immer zum Host. Jetzt merkt sich der Host, von wem
    // AIV_PARTYMEMBER eines NPCs kam (Gespraechs- und Story-Pakete eines Clients, dessen Beschwoerungen), und setzt HERO/PC_HERO waehrend
    // des Zustands dieses NPCs auf die Figur des Clients. Faellt AIV_PARTYMEMBER weg, gilt wieder der Host. Allgemein (G1/G2).
    static std::map<oCNpc*, std::string> PartyLeader;   // Host: Begleiter -> Name des Clients (FRIEND_n)

    static int PartyAiv() {
        static zCParser* pp = NULL;
        static int idx = -1;
        if (pp != parser) {
            pp = parser;
            int v = COOP_ENGINE_SWITCH(36, 36, 15, 15);
            if (zCPar_Symbol* s = parser ? parser->GetSymbol(zSTRING("AIV_PARTYMEMBER")) : NULL)
                s->GetValue(v, 0);
            idx = (v >= 0 && v < COOP_AIV_MAX) ? v : -1;
        }
        return idx;
    }

    static oCNpc* PartyFigureByName(const std::string& name) {
        if (!ogame || !ogame->GetGameWorld())
            return NULL;
        for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l; l = l->next)
            if (l->data && !_stricmp(l->data->GetObjectName().ToChar(), name.c_str()))
                return l->data;
        return NULL;
    }

    static oCNpc* PartyLeaderFigure(oCNpc* npc) {
        auto it = PartyLeader.find(npc);
        if (it == PartyLeader.end())
            return NULL;
        const int aiv = PartyAiv();
        if (aiv < 0 || !npc->aiscriptvars[aiv] || npc->IsDead()) {
            DialogLog("Begleiter %s folgt wieder dem Host (kein Partymitglied mehr) (P217)", DialogNpcName(npc).c_str());
            PartyLeader.erase(it);
            return NULL;
        }
        oCNpc* fig = PartyFigureByName(it->second);
        return fig && fig != npc && !fig->IsDead() ? fig : NULL;
    }

    static void PartyNote(oCNpc* npc, const std::string& client, const char* why) {
        if (!npc || client.empty() || !IsCoopPlayer(client))
            return;
        auto it = PartyLeader.find(npc);
        if (it != PartyLeader.end() && it->second == client)
            return;
        PartyLeader[npc] = client;
        DialogLog("Begleiter %s gehoert zu %s - folgt beim Host dessen Figur (%s, P217)", DialogNpcName(npc).c_str(), client.c_str(), why);
    }

    // Eintrag eines NPCs aus dem Paket eines Clients: AIV_PARTYMEMBER gesetzt -> Begleiter dieses Clients, geloescht -> wieder vom Host
    static void PartyNoteEntry(const json& jn, const std::string& by) {
        const int aiv = PartyAiv();
        if (aiv < 0 || !jn.is_object() || !jn.contains("a") || !jn["a"].is_array() || !jn.contains("n") || !jn["n"].is_string())
            return;
        for (auto& x : jn["a"])
            if (x.is_array() && x.size() >= 2 && x.at(0).is_number_integer() && x.at(0).get<int>() == aiv && x.at(1).is_number_integer()) {
                auto f = UniqueNameToNpcList.find(string(jn["n"].get<std::string>().c_str()));
                oCNpc* npc = f != UniqueNameToNpcList.end() ? f->second : NULL;
                if (!npc)
                    return;
                if (x.at(1).get<int>())
                    PartyNote(npc, by, "Gespraech/Skript des Clients");
                else if (PartyLeader.erase(npc))
                    DialogLog("Begleiter %s: %s hat ihn entlassen - folgt wieder dem Host (P217)", jn["n"].get<std::string>().c_str(), by.c_str());
                return;
            }
    }

    static void PartyLeaderClear() {
        PartyLeader.clear();
    }

    struct CoopHeroSwap {   // HERO und PC_HERO zeigen fuer die Dauer auf einen anderen NPC (Instanz-Zeiger im Symbol)
        zCPar_Symbol* h = NULL;
        zCPar_Symbol* pc = NULL;
        int oh = 0, opc = 0;
        explicit CoopHeroSwap(oCNpc* to) {
            static zCParser* pp = NULL;
            static zCPar_Symbol* hs = NULL;
            static zCPar_Symbol* ps = NULL;
            if (pp != parser) {
                pp = parser;
                hs = parser ? parser->GetSymbol(zSTRING("HERO")) : NULL;
                ps = parser ? parser->GetSymbol(zSTRING("PC_HERO")) : NULL;
            }
            if (hs && hs->type == zPAR_TYPE_INSTANCE) {
                h = hs;
                oh = h->offset;
                h->offset = (int)to;
            }
            if (ps && ps->type == zPAR_TYPE_INSTANCE) {
                pc = ps;
                opc = pc->offset;
                pc->offset = (int)to;
            }
        }
        ~CoopHeroSwap() {
            if (h)
                h->offset = oh;
            if (pc)
                pc->offset = opc;
        }
    };

    // u199 (P221, Durchsicht der Mod-Analyse von Legend of Ahssun, Liste Nr. 11): Zustaende aus "heroStates" des Mod-Profils meinen mit
    // HERO den Spieler dort - LoA: Beschwoerung bei SUMPF_155 (ZS_CIRCLE_LOA: Wld_SpawnNpcRange(HERO, ...)), Hinrichtung (ZS_KILL_HERO:
    // AI_GotoNpc(self, hero)), Faustkampf-Arena und Kastor/Parcival (ZS_ATTACK: AI_RemoveWeapon(hero), Npc_GetDistToNpc(hero, ...)).
    // Kampf-Zustaende laufen nur beim Host, die anderen auf beiden PCs - HERO war dort jeweils der eigene Held: die Zombies erschienen
    // um den Host-Helden, auch wenn nur der Client beim Ritual stand. Jetzt zeigt HERO waehrend eines gelisteten Zustands auf den
    // Spieler, gegen den der NPC kaempft (enemy), sonst auf den naechsten Spieler in dieser Welt (eigener Held oder Figur). Auf jedem PC
    // dieselbe Regel, damit beide Schleifen um denselben Spieler wirken (P202 fasst die Ereignisse zusammen). Die Wahl bleibt, bis ein
    // anderer Spieler 3 m naeher ist. Ohne Profil-Eintrag aendert sich nichts.
    bool CoopModHeroStatesAny();   // Mods\CoopMods.cpp
    bool CoopModHeroState(const char* zs);
    static std::map<oCNpc*, oCNpc*> HeroStateTarget;   // NPC -> zuletzt gewaehlter Spieler
    static std::map<oCNpc*, oCNpc*> HeroStateTold;     // NPC -> Spieler der letzten Logzeile
    oCNpc* CoopHeroStateTestNpc = NULL;    // Testlauf (CoopSelfTest.cpp): dieser NPC gilt in jedem Zustand als gelistet
    oCNpc* CoopHeroStateTestForce = NULL;  // Testlauf: Ziel fuer ihn vorgegeben (prueft den Haken unabhaengig von den Abstaenden)
    oCNpc* CoopHeroStateTestSeen = NULL;   // Testlauf: Spieler, auf den HERO in seinem letzten DoAIState zeigte
    int CoopHeroStateTestHero = 0;         // Testlauf: HERO-Zeiger waehrend dieses Aufrufs

    static bool HeroStateCandidate(oCNpc* c) {   // erst die Listen, dann den Zeiger anfassen (ein alter Eintrag kann frei sein)
        return c && (c == player || PlayerNpcs.count(c)) && !c->IsDead();
    }

    oCNpc* CoopHeroStatePick(oCNpc* npc) {
        if (!npc || !player)
            return NULL;
        if (npc->enemy && npc->enemy != npc && HeroStateCandidate(npc->enemy))
            return HeroStateTarget[npc] = npc->enemy;
        auto it = HeroStateTarget.find(npc);
        oCNpc* prev = it != HeroStateTarget.end() ? it->second : NULL;
        const zVEC3 at = npc->GetPositionWorld();
        oCNpc* best = NULL;
        float bestD = 1e30f, prevD = -1.f;
        auto consider = [&](oCNpc* c) {
            if (c == npc || !HeroStateCandidate(c))
                return;
            const float d = (c->GetPositionWorld() - at).LengthApprox();
            if (c == prev)
                prevD = d;
            if (d < bestD) {
                bestD = d;
                best = c;
            }
        };
        consider(player);
        for (auto& f : PlayerNpcs)
            consider(f.first);
        if (prev && prevD >= 0.f && prevD <= bestD + 300.f)
            best = prev;
        HeroStateTarget[npc] = best;
        return best;
    }

    // u200 (P223): Gruppenmitglieder (AIV_PARTYMEMBER, Gothic 1 auch AIV_MM_PARTYMEMBER) folgen ihrem Spieler - die des Hosts HERO,
    // die eines Clients seiner Figur (P217). Die Regel "naechster Spieler" liesse eine Beschwoerung des Hosts zum Client laufen, sobald
    // der naeher steht (LoA: Irrlicht, Begleit-Tiere in ZS_MM_RTN_FOLLOW_*)
    static bool HeroStatePartyMember(oCNpc* npc) {
        const int a = PartyAiv();
        if (a >= 0 && npc->aiscriptvars[a])
            return true;
        static zCParser* pp = NULL;
        static int mm = -1;
        if (pp != parser) {
            pp = parser;
            mm = -1;
            if (zCPar_Symbol* s = parser ? parser->GetSymbol(zSTRING("AIV_MM_PARTYMEMBER")) : NULL)
                s->GetValue(mm, 0);
            if (mm < 0 || mm >= COOP_AIV_MAX)
                mm = -1;
        }
        return mm >= 0 && npc->aiscriptvars[mm];
    }

    static void HeroStateNote(oCNpc* npc, oCNpc* t, const char* zs) {
        auto it = HeroStateTold.find(npc);
        if (it != HeroStateTold.end() && it->second == t)
            return;
        HeroStateTold[npc] = t;
        static CoopDiagBudget budget = { 0, 0 };
        if (CoopDiagAllow(budget, 40))
            DialogLog("HERO fuer %s in %s: %s (%s, P221)", DialogNpcName(npc).c_str(), zs && *zs ? zs : "?",
                t == player ? "eigener Held" : PlayerNpcs.count(t) ? PlayerNpcs[t].ToChar() : "?", npc->enemy == t ? "sein Gegner" : "naechster Spieler");
    }

    static void HeroStateClear() {
        HeroStateTarget.clear();
        HeroStateTold.clear();
        CoopHeroStateTestNpc = NULL;
        CoopHeroStateTestForce = NULL;
        CoopHeroStateTestSeen = NULL;
    }

    // NPC im Dialog eines Mitspielers: ZS-Schleife (Tagesablauf) aussetzen, Warteschlange laeuft weiter.
    // v108 (Test v108, Kampf-Uebergabe C18): ebenso beim Host fuer NPCs, die gerade ein Client im Kampf fuehrt. Deren Tagesablauf
    // lief beim Host weiter (Fleischwanze in ZS_MM_RTN_WUSEL) und drehte die Puppe in die eigene Richtung - beim Partner 138 Grad,
    // beim fuehrenden Client 38 Grad, ueber 8 s. Die Puppe bewegt allein der Client (Lage, Blickrichtung, Animationen).
    bool CoopLeadIsRemote(oCNpc* npc);   // CoopCombatLead.cpp

    int __fastcall oCNpc_States_DoAIState_Coop(oCNpc_States* _this, void* vtable);
    CInvoke<int(__thiscall*)(oCNpc_States*)> Ivk_oCNpc_States_DoAIState_Coop(CoopAddr::oCNpc_States_DoAIState, &oCNpc_States_DoAIState_Coop,
        COOP_IVK(Dialog));
    int __fastcall oCNpc_States_DoAIState_Coop(oCNpc_States* _this, void* vtable) {
        if (!DialogFrozen.empty() && _this) {
            oCNpc* npc = _this->npc;
            if (npc && DialogFrozen.count(npc) && !npc->IsDead() && npc->GetWeaponMode() == NPC_WEAPON_NONE)
                return 0;
        }
        if (ServerThread && _this && _this->npc && CoopLeadIsRemote(_this->npc) && !_this->npc->IsDead())
            return 0;
        // u199 (P217): Begleiter eines Clients - waehrend ihres Zustands zeigen HERO und PC_HERO auf seine Figur
        if (ServerThread && _this && _this->npc && !PartyLeader.empty())
            if (oCNpc* fig = PartyLeaderFigure(_this->npc)) {
                CoopHeroSwap swap(fig);
                return Ivk_oCNpc_States_DoAIState_Coop(_this);
            }
        // u199 (P221): Zustand aus "heroStates" - HERO zeigt auf den Gegner bzw. naechsten Spieler
        if (_this && _this->npc && (CoopHeroStateTestNpc || CoopModHeroStatesAny()) && _this->npc != player && !PlayerNpcs.count(_this->npc)) {
            oCNpc* npc = _this->npc;
            const char* zs = _this->curState.name.ToChar();
            bool listed = npc == CoopHeroStateTestNpc;
            if (!listed && CoopModHeroStatesAny()) {
                listed = CoopModHeroState(zs);
                if (!listed && _this->nextState.valid && CoopModHeroState(_this->nextState.name.ToChar())) {
                    listed = true;
                    zs = _this->nextState.name.ToChar();
                }
            }
            if (listed && !npc->IsDead() && (npc == CoopHeroStateTestNpc || !HeroStatePartyMember(npc)))   // u200 (P223)
                if (oCNpc* t = npc == CoopHeroStateTestNpc && HeroStateCandidate(CoopHeroStateTestForce) ? CoopHeroStateTestForce : CoopHeroStatePick(npc))
                    if (t != player) {
                        HeroStateNote(npc, t, zs);
                        CoopHeroSwap swap(t);
                        if (npc == CoopHeroStateTestNpc) {
                            CoopHeroStateTestSeen = t;
                            CoopHeroStateTestHero = swap.h ? swap.h->offset : 0;
                        }
                        return Ivk_oCNpc_States_DoAIState_Coop(_this);
                    }
        }
        return Ivk_oCNpc_States_DoAIState_Coop(_this);
    }

    // Fortschritt: das Dialogskript laeuft synchron in OnInfo / OnChoice.
    void __fastcall oCInformationManager_OnInfo_Coop(oCInformationManager* _this, oCInfo* info);
    CInvoke<void(__fastcall*)(oCInformationManager*, oCInfo*)> Ivk_oCInformationManager_OnInfo_Coop(CoopAddr::oCInformationManager_OnInfo, &oCInformationManager_OnInfo_Coop,
        COOP_IVK(Dialog));
    void __fastcall oCInformationManager_OnInfo_Coop(oCInformationManager* _this, oCInfo* info) {
        if (!info || !DlgOwnDialog(_this)) {
            Ivk_oCInformationManager_OnInfo_Coop(_this, info);
            return;
        }
        if (!MyDialogNpcPtr)
            TrackOwnDialog();
        DlgGuildSurvey();   // u85: einmal - wie viele Infos zaehlen als Gilden-Infos
        CoopDlgSnap a, b;
        DlgSnapshot(a);
        const std::string name = info->name.ToChar();
        DlgInvChanges.clear();   // u163 (P170)
        DlgInvDepth++;
        Ivk_oCInformationManager_OnInfo_Coop(_this, info);
        DlgInvDepth--;
        try {
            DlgSnapshot(b);
            DlgSendDiff(a, b, name, "Info", info);
            StoryAbsorb(a, b);
        }
        catch (std::exception& ex) {
            CoopErrorLog("Dialog-Fortschritt", ex.what(), name.c_str());
        }
    }

    void __fastcall oCInformationManager_OnChoice_Coop(oCInformationManager* _this, oCInfoChoice* choice);
    CInvoke<void(__fastcall*)(oCInformationManager*, oCInfoChoice*)> Ivk_oCInformationManager_OnChoice_Coop(CoopAddr::oCInformationManager_OnChoice, &oCInformationManager_OnChoice_Coop,
        COOP_IVK(Dialog));
    void __fastcall oCInformationManager_OnChoice_Coop(oCInformationManager* _this, oCInfoChoice* choice) {
        if (!choice || !DlgOwnDialog(_this)) {
            Ivk_oCInformationManager_OnChoice_Coop(_this, choice);
            return;
        }
        CoopDlgSnap a, b;
        DlgSnapshot(a);
        oCInfo* cur = _this ? _this->Info : NULL;   // u85: die Auswahl gehoert zum laufenden Info (Gilden-Regel)
        DlgInvChanges.clear();   // u163 (P170)
        DlgInvDepth++;
        Ivk_oCInformationManager_OnChoice_Coop(_this, choice);
        DlgInvDepth--;
        try {
            DlgSnapshot(b);
            DlgSendDiff(a, b, std::string(), "Auswahl", cur);
            StoryAbsorb(a, b);
        }
        catch (std::exception& ex) {
            CoopErrorLog("Dialog-Fortschritt", ex.what(), "Auswahl");
        }
    }

#else   // Modul in dieser Engine nicht freigegeben (CoopModulesReport)
    void CoopHeroVarsCapture(std::vector<std::pair<std::string, int>>& out) { out.clear(); }   // u15
    int CoopHeroVarsApply(const std::vector<std::pair<std::string, int>>&) { return 0; }
    void CoopHeroGuildCapture(std::vector<std::string>& out) { out.clear(); }   // u150
    void CoopHeroGuildNote(const std::vector<std::string>&) {}
    int CoopHeroGuildNpcsAgain(const std::vector<std::string>&) { return 0; }   // u160
    int CoopHeroGuildApply(const std::vector<std::string>&, std::string&) { return -1; }
    void CoopHeroGuildBaseReset() {}   // u154
    int CoopHeroGuildMerge(std::vector<std::string>&, const std::vector<std::string>&, bool, std::string&) { return 0; }
    bool CoopDialogNpcBusy(oCNpc*) { return false; }
    bool CoopDialogSyncHandles(int) { return false; }
    void CoopDialogSyncReceive(json&, const std::string&) {}
    void CoopDialogSyncPeerGone(const std::string&) {}
    void CoopDialogSyncWorldLoaded() {}
    void CoopDialogSyncPulse() {}
    void CoopStorySendAllNpcs(const char*) {}
    void CoopDialogSyncLoadKind(bool) {}   // u140
    json CoopWorldEntryVarsGet(const std::string&) { return json::array(); }
    int CoopWorldEntryVarsSet(const json&, const std::string&, bool) { return 0; }
    void CoopMissionReset(int) {}
    int CoopMissionTestMark(const char*) { return -1; }   // u104
    int CoopMissionTestFullLines(const char*) { return -1; }   // u160
#endif
}
