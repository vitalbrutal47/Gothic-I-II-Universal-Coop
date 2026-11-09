// Supported with union (c) 2020 Union team
// Union SOURCE file

namespace GOTHIC_ENGINE {

    // --- v91: gemeinsames neues Spiel (22.10.2026) ----------------------------------------------------------------------
    //
    // Nutzer: "Meine Idee ist es, dass der Host mit Diego redet, waehrend der Client zuschaut und auch schon rumlaufen kann. Wenn
    // der Host das Intro skipt, wird dieses auch beim Client geskippt." / "Der Client kann entweder das Intro nicht skippen, oder
    // wenn dieser es doch kann, wird es auch bei beiden geskippt." Plan: gt-fix\PLAN-NEUES-SPIEL.md. Start im Hauptmenue:
    // CoopMenuLobby.cpp (Othellos Schwierigkeit, dann MENU_COOP_NG, LOBBY newgame).
    //
    // Intro (allgemein G1): Othellos STARTUP_WORLD ruft PlayVideo("INTRO.BIK") im Ladevorgang. zCVideoPlayer::Play (0x004694F0)
    // fragt in jedem Bild IsPlaying ueber vtable +0x24 ab - bei oCBinkPlayer (vtable 0x007D0FDC) der Platz 0x007D1000; der
    // Renderer GD3D11 (zBinkPlayer.cpp) legt dort seine Funktion ab (im Speicherabbild 0x718E7A90, in der Datei 0x0043C9B0). Esc ruft
    // vtable +0x20 = zCVideoPlayer::Stop (0x004696A0, unveraendert: Feld +0x20 = 0, Rueckgabe 1). Beim natuerlichen Ende bleibt
    // das Feld 1, nur das Bild-Ende meldet 0. GT legt sich um den vtable-Platz:
    //  - meldet er "zu Ende", obwohl er eben noch lief, und ist Feld +0x20 = 0, wurde abgebrochen -> LOBBY introskip an den Partner.
    //  - kam introskip vom Partner (CoopIntroSkipPeek im Netzfaden - der Hauptfaden steht im Video, Pakete verarbeitet er erst
    //    danach), stoppt GT das Video ueber vtable +0x20. Kommt der Abbruch vor dem Video, endet es gleich beim ersten Bild.
    //  - Der Host gibt einen Abbruch eines Mitspielers an alle weiter.
    // Gilt nur vom gemeinsamen Start bis 5 s nach LoadEnd (das Video blockiert den Spieltakt; danach laeuft Game_Loop).
    //
    // u11 (Test u10, Nutzer: "das Intro wird komplett geskippt statt nur der erste Teil. Es kommt ja noch diese Schrift am Ende"):
    // G2 NotR spielt beim neuen Spiel zwei Videos nacheinander (INTRO.BIK, danach Addon_Title.BIK mit dem Schriftzug - Startup.d;
    // u26 berichtigt, bis dahin hier "Intro_Addon.bik": das ist das Video aus Xardas' erstem Gespraech). Bis
    // u10 blieb der Abbruch des Partners gesetzt und beendete auch das zweite Video. Jetzt zaehlt GT die Videos seit dem
    // gemeinsamen Start; introskip traegt die Nummer ("introskip2"), beendet wird hier nur das Video mit dieser Nummer (oder ein
    // frueheres) - wie Esc im Einzelspieler. Allgemein (G1 spielt nur ein Video).
    //
    // Danach (nur Client): im ersten Spielbild neben den Host (CoopSaveSyncPlaceBesideStart - beide beginnen an Othellos
    // Startpunkt). Diego: 3 Minuten lang melden NPCs dem eigenen Helden keine wichtige Info (Npc_CheckInfo(npc, 1),
    // CoopDialogSync.cpp), bis der Host sein erstes Gespraech beendet hat - Diego geht zum Host, der Client sieht zu.

    // vom Menue bzw. Netzfaden
    void CoopNewGameBegin(bool host, const std::string& run);
    void CoopSaveSyncSetRun(const std::string& run, const char* why);   // CoopSaveSync.cpp (v93)
    void CoopIntroSkipPeek(const ENetEvent& ev);
    // CoopDialogSync.cpp
    bool CoopNewGameInfoBlocked();
    void CoopNewGameDialogEnded(const std::string& by, const std::string& npc);
    // CoopPlace.cpp (u10; bis u9 CoopSaveSyncPlaceBesideStart in CoopSaveSync.cpp)
    void CoopPlaceBesideStart();
    void CoopMoveResetPulse();

#if COOP_BUILD(NewGame)   // u3: bis u2 nur G1 - Freigabe je Engine in CoopCore.cpp

    typedef int(__thiscall* CoopVideoFn)(void*);

    static const DWORD INTRO_VT_ISPLAYING = CoopAddr::vt_oCBinkPlayer() + 0x24;   // oCBinkPlayer-vtable (G1 0x007D0FDC) + 0x24
    static const DWORD INTRO_VT_STOP = CoopAddr::vt_oCBinkPlayer() + 0x20;        // + 0x20, zCVideoPlayer::Stop
    static const DWORD INTRO_STOP_FUNC = CoopAddr::zCVideoPlayer_Stop;

    static CoopVideoFn IntroOrigIsPlaying = NULL;
    static volatile LONG IntroSyncOn = 0;       // gemeinsamer Start bis kurz nach LoadEnd (Netzfaden liest mit)
    static volatile LONG IntroRemoteSkip = 0;   // u11: hoechste Videonummer, die ein Partner abgebrochen hat (vom Netzfaden gesetzt)
    static bool IntroWasPlaying = false;
    static int IntroSkipSent = 0;               // u11: hoechste gemeldete Videonummer
    static int IntroVideoNo = 0;                // u11: Videos seit dem gemeinsamen Start (G2: INTRO.BIK, Addon_Title.BIK)
    static void* IntroStoppedPlayer = NULL;     // u11: Video-Spieler, den GT eben beendet hat (nur Vergleich)

    // u55: Story-Videos (CoopDialogSync.cpp, u28 "vid": Xardas' erstes Gespraech mit Intro_Addon.bik, Extros ...) - Nutzer:
    // "Außerdem werden Videos nciht geskippt wenn einer sie Skippt (Xardas Dialog)". Der Intro-Abgleich galt nur vom gemeinsamen
    // Start bis kurz nach dem Laden. Jetzt traegt jedes gemeinsame Story-Video eine Nummer vom PC, der es startete ("vidno" neben
    // "vid"); beide spielen es unter dieser Nummer (CoopStoryVideoBegin/End um das Original). Esc hier -> LOBBY "vidskip<Nummer>"
    // an den Partner, der Host gibt es an alle weiter; kommt es an (Netzfaden, wie introskip), beendet GT das Video mit dieser
    // Nummer wie Esc - auch wenn es hier erst danach anfaengt (dann im ersten Bild). Allgemein G1/G2.
    static volatile LONG StoryVideoNo = 0;          // Nummer des laufenden gemeinsamen Story-Videos (0 = keins)
    static volatile LONG StoryRemoteSkip[8] = {};   // zuletzt vom Partner abgebrochene Nummern (Ring, vom Netzfaden gesetzt)
    static volatile LONG StoryRemoteSkipPos = 0;
    static LONG StorySkipSent[8] = {};              // schon gemeldete Nummern (Ring)
    static int StorySkipSentPos = 0;
    static bool StoryWasPlaying = false;
    static void* StoryStoppedPlayer = NULL;
    static LONG StoryLastBegun = 0, StoryLastRemoteStopped = 0, StoryLastSkipSent = 0;   // fuer den Coop-Testlauf
    static long long StoryBeganMs = 0;
    static volatile LONG StoryTestStopMs = 0;   // Coop-Testlauf: Video nach so vielen ms wie mit Esc beenden (0 = aus)

    static bool NewGameActive = false;
    static bool NewGameHost = false;
    static long long NewGameBeginMs = 0;
    static long long NewGameLoadEndMs = 0;
    static bool NewGamePlacePending = false;
    static long long NewGameInfoUntil = 0;   // Client: bis dahin keine wichtige Info fuer den eigenen Helden (0 = aus)

    static void NewGameLog(const char* fmt, ...) {
        char buf[1024];
        va_list ap;
        va_start(ap, fmt);
        _vsnprintf(buf, sizeof(buf), fmt, ap);
        va_end(ap);
        buf[sizeof(buf) - 1] = 0;
        OthelloCompatLog("[%lld s, %s] Neues Spiel: %s", DiagSeconds(), DiagRole(), buf);
    }

    static void IntroSendSkip(int no, const char* why) {
        if (no <= IntroSkipSent || (!ServerThread && !ClientThread))
            return;
        IntroSkipSent = no;
        json j;
        j["type"] = SYNC_LOBBY;
        j["id"] = MyselfId.ToChar();
        j["op"] = "introskip" + std::to_string(no);   // u11: Nummer im Wert selbst - der Netzfaden liest das Paket nur roh
        CoopTraceCount(TRACE_SENT, SYNC_LOBBY);
        ReadyToSendJsons.enqueue(j);
        NewGameLog("Video %d %s - Partner auch", no, why);
    }

    static bool StoryRemoteSkipped(LONG no) {
        for (int k = 0; k < 8; k++)
            if (no && StoryRemoteSkip[k] == no)
                return true;
        return false;
    }

    static void StorySendSkip(LONG no, const char* why) {
        if (!no || (!ServerThread && !ClientThread))
            return;
        for (int k = 0; k < 8; k++)
            if (StorySkipSent[k] == no)
                return;
        StorySkipSent[StorySkipSentPos] = no;
        StorySkipSentPos = (StorySkipSentPos + 1) % 8;
        json j;
        j["type"] = SYNC_LOBBY;
        j["id"] = MyselfId.ToChar();
        j["op"] = "vidskip" + std::to_string(no);   // Nummer im Wert selbst - der Netzfaden liest das Paket nur roh
        CoopTraceCount(TRACE_SENT, SYNC_LOBBY);
        ReadyToSendJsons.enqueue(j);
        NewGameLog("Story-Video %ld %s - Partner auch", (long)no, why);
    }

    // Host: Abbrueche eines Mitspielers an alle weitergeben (auch der Absender bekommt es zurueck - dort ist es schon vorbei)
    static void StoryRelaySkips() {
        if (!ServerThread)
            return;
        for (int k = 0; k < 8; k++)
            if (const LONG no = StoryRemoteSkip[k])
                StorySendSkip(no, "eines Mitspielers an alle weitergegeben");
    }

    // u185 (Nutzer: "ich hatte das video beendet", auf die Frage, ob Esc in Aufnahmen wieder fuer beide gelten soll: "Ja, wieder
    // erlauben"): Esc beendet ein gemeinsames Story-Video auch in Aufnahmen fuer beide. u184 hatte dort die Tasten gesperrt (P185) - der
    // Abbruch in b287 kam aber vom Nutzer selbst, kein Fehler. Allgemein G1/G2.
    static int StoryIsPlaying(void* self, int r) {
        const LONG no = StoryVideoNo;
        StoryRelaySkips();
        if (r && self == StoryStoppedPlayer && ((zCVideoPlayer*)self)->mPlaying == 0)
            return 0;   // eben von GT beendet
        if (r && StoryRemoteSkipped(no)) {
            ((CoopVideoFn)(*(DWORD**)self)[0x20 / 4])(self);   // Stop wie Esc
            StoryWasPlaying = false;
            StoryStoppedPlayer = self;
            StoryLastRemoteStopped = no;
            NewGameLog("Story-Video %ld (%s) vom Partner " "\xFC" "bersprungen - hier auch beendet", (long)no, ((zCVideoPlayer*)self)->mVideoFilename.ToChar());
            return 0;
        }
        if (r && StoryTestStopMs > 0 && GetCurrentMs() >= StoryBeganMs + StoryTestStopMs) {   // Coop-Testlauf: wie Esc
            NewGameLog("Testlauf: Story-Video %ld nach %ld ms wie mit Esc beendet", (long)no, (long)StoryTestStopMs);
            InterlockedExchange(&StoryTestStopMs, 0);
            ((CoopVideoFn)(*(DWORD**)self)[0x20 / 4])(self);
            r = 0;   // weiter wie nach Esc: unten "hier uebersprungen"
        }
        if (StoryWasPlaying && !r) {
            if (((zCVideoPlayer*)self)->mPlaying == 0) {   // Stop ohne GT: Esc
                StorySendSkip(no, "hier " "\xFC" "bersprungen (Esc)");
                StoryLastSkipSent = no;
            }
            else
                NewGameLog("Story-Video %ld zu Ende gelaufen", (long)no);
        }
        StoryWasPlaying = r != 0;
        return r;
    }

    // u170: Autotest mit neuem Spiel bzw. Beitritt aus dem Hauptmenue (CoopAutoTest.cpp) - jedes Video gleich beim ersten IsPlaying wie
    // mit Esc beenden, bevor ein Bild gezeigt wird. Legend of Ahssun im Fenster: das Intro des neuen Spiels hing in GD3D11
    // (zCVideoPlayer::Play -> zMouseFix -> g2a_avx2.dll, Warten auf eine Sperre); im Test bringt ein Video ohnehin nichts
    static volatile LONG IntroAutotestSkip = 0;

    // vtable-Platz IsPlaying (thiscall ohne Argumente: this in ecx, fastcall mit unbenutztem edx passt)
    // u182 (Nutzer zur Aufnahme mit b285: "das video kam auch nicht" beim Client): in Aufnahmen (-coopaufnahme) ein gemeinsames Story-Video
    // nicht gleich beenden. Der Client beendete Xardas' Intro_ADDON im ersten Bild, der Host zeigte es - so in jeder Aufnahme seit u171.
    // Jetzt laeuft es bei beiden, Ueberspringen gilt wie sonst fuer beide (StoryIsPlaying). Andere Videos (Intro des neuen Spiels) bleiben
    // im Autotest aus. Allgemein G1/G2.
    static int __fastcall IntroIsPlaying(void* self, void*) {
        int r = IntroOrigIsPlaying ? IntroOrigIsPlaying(self) : 0;
        if (r && self && IntroAutotestSkip && StoryTestStopMs <= 0 && !(StoryVideoNo && CoopRecordMode())) {   // u170, u182
            ((CoopVideoFn)(*(DWORD**)self)[0x20 / 4])(self);   // Stop wie Esc
            NewGameLog("Autotest: Video %s gleich beendet (Testlauf ohne Videos)", ((zCVideoPlayer*)self)->mVideoFilename.ToChar());
            return 0;
        }
        if (self && StoryVideoNo)   // u55: gemeinsames Story-Video
            return StoryIsPlaying(self, r);
        if (!IntroSyncOn || !self)
            return r;
        if (r && self == IntroStoppedPlayer && ((zCVideoPlayer*)self)->mPlaying == 0)
            return 0;   // u11: eben von GT beendet (Stop setzt das Feld auf 0) - kein neues Video
        if (r && !IntroWasPlaying) {   // u11: naechstes Video
            IntroVideoNo++;
            IntroStoppedPlayer = NULL;
            if (IntroVideoNo <= 8)
                NewGameLog("Video %d l" "\xE4" "uft: %s (Video-Spieler %p)", IntroVideoNo, ((zCVideoPlayer*)self)->mVideoFilename.ToChar(), self);
        }
        if (ServerThread && IntroRemoteSkip > IntroSkipSent)   // Host: Abbruch eines Mitspielers an alle (auch wenn hier schon vorbei)
            IntroSendSkip(IntroRemoteSkip, "eines Mitspielers an alle weitergegeben");
        if (r && IntroVideoNo <= IntroRemoteSkip) {
            ((CoopVideoFn)(*(DWORD**)self)[0x20 / 4])(self);   // Stop wie Esc
            IntroWasPlaying = false;
            IntroStoppedPlayer = self;
            NewGameLog("Video %d vom Partner " "\xFC" "bersprungen - hier auch beendet", IntroVideoNo);
            return 0;
        }
        if (IntroWasPlaying && !r) {
            if (((zCVideoPlayer*)self)->mPlaying == 0)   // u3: SDK-Feld (+0x20, in allen Engines gleich)
                IntroSendSkip(IntroVideoNo, "hier " "\xFC" "bersprungen (Esc)");
            else
                NewGameLog("Video %d zu Ende gelaufen", IntroVideoNo);
        }
        IntroWasPlaying = r != 0;
        return r;
    }

    static void IntroHookInstall() {
        DWORD* slot = (DWORD*)INTRO_VT_ISPLAYING;
        if (*slot == (DWORD)&IntroIsPlaying)
            return;
        if (*(DWORD*)INTRO_VT_STOP != INTRO_STOP_FUNC) {   // nicht die erwartete vtable - nichts anfassen
            NewGameLog("Intro-Abgleich aus: vtable-Platz 0x%08X ist nicht zCVideoPlayer::Stop (%08X)", INTRO_VT_STOP, *(DWORD*)INTRO_VT_STOP);
            return;
        }
        DWORD old = 0;
        if (!VirtualProtect(slot, 4, PAGE_EXECUTE_READWRITE, &old)) {
            NewGameLog("Intro-Abgleich aus: VirtualProtect fehlgeschlagen (%lu)", GetLastError());
            return;
        }
        IntroOrigIsPlaying = (CoopVideoFn)*slot;
        *slot = (DWORD)&IntroIsPlaying;
        VirtualProtect(slot, 4, old, &old);
        NewGameLog("Intro-Abgleich: vtable-Platz 0x%08X (IsPlaying) umgelegt, vorher %p", INTRO_VT_ISPLAYING, (void*)IntroOrigIsPlaying);
    }

    void CoopIntroSkipPeek(const ENetEvent& ev) {
        if (ev.type != ENET_EVENT_TYPE_RECEIVE || !ev.packet || ev.packet->dataLength > 200)
            return;
        // BSON speichert Zeichenketten roh - "introskip" (Wert von op) genuegt, voll gelesen wird das Paket im Spieltakt
        const char* d = (const char*)ev.packet->data;
        const size_t n = ev.packet->dataLength;
        for (size_t i = 0; i + 7 <= n; i++)   // u55: Story-Video ("vidskip<Nummer>") - immer
            if (memcmp(d + i, "vidskip", 7) == 0) {
                // u87 (Gilden-Testlauf u86: Video 1326503426 des Hosts lief beim Client ganz durch): bis u86 las die Schleife hoechstens
                // 9 Ziffern, die Nummern haben aber bis zu 10 (u55-u86 bis 0x5FFFFFFF) - dann galt das Ueberspringen beim Partner nie
                long long no = 0;
                for (size_t k = i + 7; k < n && d[k] >= '0' && d[k] <= '9' && no <= 0x7FFFFFFF; k++)
                    no = no * 10 + (d[k] - '0');
                if (no > 0 && no <= 0x7FFFFFFF && !StoryRemoteSkipped((LONG)no)) {
                    const LONG pos = InterlockedIncrement(&StoryRemoteSkipPos) & 7;
                    InterlockedExchange(&StoryRemoteSkip[pos], (LONG)no);
                }
                return;
            }
        if (!IntroSyncOn)
            return;
        for (size_t i = 0; i + 9 <= n; i++)
            if (memcmp(d + i, "introskip", 9) == 0) {
                // u11: Videonummer dahinter ("introskip2"); ohne Nummer (bis u10) das erste Video. Die hoechste gilt.
                LONG no = 0;
                for (size_t k = i + 9; k < n && d[k] >= '0' && d[k] <= '9' && no < 1000; k++)
                    no = no * 10 + (d[k] - '0');
                if (no <= 0)
                    no = 1;
                for (LONG cur = IntroRemoteSkip; cur < no; cur = IntroRemoteSkip)
                    if (InterlockedCompareExchange(&IntroRemoteSkip, no, cur) == cur)
                        break;
                return;
            }
    }

    // u55: gemeinsames Story-Video (CoopDialogSync.cpp) - Nummer fuer ein neues Video, Beginn/Ende um das Original
    long CoopStoryVideoNewNo() {
        static LONG last = 0;
        // u87: hoechstens 9 Stellen (bis u86 & 0x5FFFFFFF - mit Bit 30, das bei unter 12 Tagen Laufzeit des PCs Bit 10 der
        // Prozesskennung ist, hatte jede zweite Spielsitzung nur 10-stellige Nummern; Partner bis u86 lesen 9 Ziffern)
        LONG no = (LONG)((GetTickCount() ^ ((DWORD)GetCurrentProcessId() << 20)) & 0x1FFFFFFF);
        if (no == 0 || no == last)
            no = last + 1;
        last = no;
        return no;
    }

    void CoopVideoSkipForAutotest() {   // u170 (siehe IntroIsPlaying)
        IntroHookInstall();
        if (!InterlockedExchange(&IntroAutotestSkip, 1))
            NewGameLog("Autotest: Videos werden gleich beendet (IsPlaying)");
    }

    void CoopStoryVideoBegin(long no) {
        if (no <= 0)
            return;
        IntroHookInstall();   // einmal; legt sich neu um den Platz, falls der Renderer ihn inzwischen ersetzt hat
        StoryWasPlaying = false;
        StoryStoppedPlayer = NULL;
        StoryLastBegun = no;
        StoryBeganMs = GetCurrentMs();
        InterlockedExchange(&StoryVideoNo, no);
        if (StoryRemoteSkipped(no))
            NewGameLog("Story-Video %ld: Partner hat es schon abgebrochen - endet im ersten Bild", no);
    }

    void CoopStoryVideoEnd() {
        InterlockedExchange(&StoryVideoNo, 0);
        InterlockedExchange(&StoryTestStopMs, 0);
        StoryWasPlaying = false;
        StoryRelaySkips();
    }

    // Coop-Testlauf (CoopSelfTest.cpp, "Story-Video: Ueberspringen gilt fuer beide")
    void CoopStoryVideoTestStopAfter(int ms) {
        InterlockedExchange(&StoryTestStopMs, ms > 0 ? ms : 0);
    }

    void CoopStoryVideoState(long& begun, long& remoteStopped, long& skipSent) {
        begun = StoryLastBegun;
        remoteStopped = StoryLastRemoteStopped;
        skipSent = StoryLastSkipSent;
    }

    static std::string NewGameRun;   // v93: Durchlauf des gemeinsamen Spiels (vom Host), gilt ab LoadEnd

    void CoopNewGameBegin(bool host, const std::string& run) {
        NewGameRun = run;
        IntroHookInstall();
        IntroWasPlaying = false;
        IntroSkipSent = IntroVideoNo = 0;
        IntroStoppedPlayer = NULL;
        InterlockedExchange(&IntroRemoteSkip, 0);
        InterlockedExchange(&IntroSyncOn, 1);
        NewGameActive = true;
        NewGameHost = host;
        NewGameBeginMs = GetCurrentMs();
        NewGameLoadEndMs = 0;
        NewGamePlacePending = false;
        NewGameInfoUntil = 0;
        NewGameLog("gemeinsamer Start als %s - Intro-Abgleich an", host ? "Host" : "Mitspieler");
    }

    // UnionHooks: Game_LoadEnd_NewGame (nach LoadEnd)
    void CoopNewGameLoadEnd() {
        if (!NewGameActive)
            return;
        NewGameLoadEndMs = GetCurrentMs();
        if (!NewGameRun.empty())   // v93: Game_LoadBegin_NewGame hat den Durchlauf geleert - jetzt der gemeinsame
            CoopSaveSyncSetRun(NewGameRun, "gemeinsames neues Spiel");
        const bool client = ClientThread && !ServerThread;
        if (!NewGameHost && client && !CoopFunArmed) {   // u203: im Fun-Spiel startet jeder in seinem Lager (COOP_FUN.D)
            NewGamePlacePending = true;
            NewGameInfoUntil = NewGameLoadEndMs + 180000;
        }
        NewGameLog("Welt geladen nach %lld s%s", (NewGameLoadEndMs - NewGameBeginMs) / 1000,
            NewGamePlacePending ? " - setze mich neben den Host, 3 Minuten keine wichtigen Infos (der Host spricht zuerst)" : "");
    }

    // UnionHooks: Game_Loop
    void CoopNewGamePulse() {
        StoryRelaySkips();   // u55: Abbruch kam, als hier kein Story-Video lief
        if (!NewGameActive)
            return;
        const long long now = GetCurrentMs();
        if (IntroSyncOn && ServerThread && IntroRemoteSkip > IntroSkipSent)   // u11: Abbruch kam, als hier kein Video mehr lief
            IntroSendSkip(IntroRemoteSkip, "eines Mitspielers an alle weitergegeben");
        if (IntroSyncOn && NewGameLoadEndMs && now > NewGameLoadEndMs + 5000) {
            InterlockedExchange(&IntroSyncOn, 0);
            InterlockedExchange(&IntroRemoteSkip, 0);
            NewGameLog("Intro-Abgleich aus (%d Video%s)", IntroVideoNo, IntroVideoNo == 1 ? "" : "s");
        }
        if (NewGamePlacePending && player && !IsLoadingLevel) {
            NewGamePlacePending = false;
            CoopPlaceBesideStart();
        }
        else
            CoopMoveResetPulse();   // u10: Bewegung im Bild danach zuruecksetzen - auch ohne Speichern-Modul (G2A)
        if (NewGameInfoUntil && now >= NewGameInfoUntil) {
            NewGameInfoUntil = 0;
            NewGameLog("3 Minuten vorbei - NPCs melden dem eigenen Helden wieder wichtige Infos");
        }
        if (!IntroSyncOn && !NewGamePlacePending && !NewGameInfoUntil && !PendingMoveReset)
            NewGameActive = false;
    }

    bool CoopNewGameInfoBlocked() {
        if (!NewGameInfoUntil)
            return false;
        if (!ClientThread || ServerThread) {   // Verbindung weg - nicht mehr warten
            NewGameInfoUntil = 0;
            return false;
        }
        return GetCurrentMs() < NewGameInfoUntil;
    }

    void CoopNewGameDialogEnded(const std::string& by, const std::string& npc) {
        if (!NewGameInfoUntil)
            return;
        NewGameInfoUntil = 0;
        NewGameLog("%s hat das erste Gespr" "\xE4" "ch beendet (%s) - NPCs melden dem eigenen Helden wieder wichtige Infos", by.c_str(), npc.c_str());
    }

#else   // Modul in dieser Engine nicht freigegeben (CoopModulesReport)
    void CoopNewGameBegin(bool, const std::string&) {}
    void CoopIntroSkipPeek(const ENetEvent&) {}
    long CoopStoryVideoNewNo() { return 0; }
    void CoopStoryVideoBegin(long) {}
    void CoopStoryVideoEnd() {}
    void CoopStoryVideoTestStopAfter(int) {}
    void CoopStoryVideoState(long& begun, long& remoteStopped, long& skipSent) { begun = remoteStopped = skipSent = 0; }
    void CoopNewGameLoadEnd() {}
    void CoopNewGamePulse() {}
    bool CoopNewGameInfoBlocked() { return false; }
    void CoopNewGameDialogEnded(const std::string&, const std::string&) {}
    void CoopVideoSkipForAutotest() {}   // u170
#endif
}
