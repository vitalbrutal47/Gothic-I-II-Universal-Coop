// Supported with union (c) 2020 Union team
// Union SOURCE file

namespace GOTHIC_ENGINE {

    // --- u29 (P65): getrennte Welten - allgemein (G1/G2, auch Othello) ------------------------------------------------------
    //
    // docs\G2-UMSETZUNGSPLAN.md Schritt 2 (Nutzer: "Und dann die Welt-Synchronisation angehen"). GTs Grundpakete (LocalNpc:
    // Lage, Blickrichtung, Animation, INIT_NPC ...) trugen keine Welt. Wechselte einer die Welt (G2: Pass ins Minental, Portal
    // nach Jharkendar, Schiff nach Irdorath; G1: Minen, Orktempel), setzte der andere die Figur des Partners an dessen
    // Koordinaten in seine eigene Welt (RemoteNpc behaelt die Figuren der Spieler ueber das Laden und setzt sie wieder ein),
    // und der Host schickte die NPCs seiner Welt auch an einen Client in einer anderen - gleichnamige NPCs (eindeutige Namen aus
    // Objektname und Tagesablauf-Wegpunkt) bekamen dort fremde Lagen, Treffer und Tode.
    // Jetzt:
    //  - Jedes LocalNpc-Paket traegt "wk" = Schluessel der eigenen Welt (FNV-1a des Dateinamens, 0 = unbekannt bzw. laedt),
    //    INIT_NPC dazu "wn" = Dateiname der Welt.
    //  - Empfang (PacketProcessor.cpp): ein Paket aus einer anderen Welt wird nicht angewendet (die Uhrzeit ausgenommen - sie
    //    gilt ueberall). Der Host leitet es trotzdem an die anderen Clients weiter. Pakete ohne "wk" gelten als gleiche Welt.
    //  - Tabelle Spieler -> zuletzt gemeldete Welt. Die Figur eines Spielers in einer anderen Welt nimmt RemoteNpc aus der
    //    eigenen Welt (LeaveWorld) - auch gleich nach dem eigenen Weltwechsel, statt sie an alten Koordinaten neu einzusetzen.
    //    Kommt er in die eigene Welt, schickt GT ihm den eigenen Stand neu (Myself->Reinit, Host: auch seine NPCs), damit er die
    //    Figur sofort anlegt, auch wenn man selbst still steht (Lage geht nur bei Bewegung hinaus).
    //  - Chat und Log: "<Name> ist in einer anderen Welt: <Welt>" / "<Name> ist wieder in deiner Welt"; Teleport-Rune und
    //    Zuschau-Fenster nennen die Welt statt "kein Mitspieler", die Markierung zeigt oben "Name: Welt".
    //  - Abschalten: GothicCoopConfig.json "coopSeparateWorlds": false - dann gilt jedes Paket wie bis u28.
    // Dialoge, Welt- und Todesabgleich trugen die Welt schon ("w", seit v13/v26/v41) und bleiben, wie sie sind.

    static bool CoopWorldsOn() {
        static int on = -1;
        if (on < 0) {
            on = 1;
            if (CoopConfig.contains("coopSeparateWorlds") && CoopConfig["coopSeparateWorlds"].is_boolean())
                on = CoopConfig["coopSeparateWorlds"].get<bool>() ? 1 : 0;
        }
        return on == 1;
    }

    static void CoopWorldsLog(const char* fmt, ...) {
        char buf[600];
        va_list ap;
        va_start(ap, fmt);
        _vsnprintf(buf, sizeof(buf), fmt, ap);
        va_end(ap);
        buf[sizeof(buf) - 1] = 0;
        OthelloCompatLog("[%lld s, %s] Welten: %s", DiagSeconds(), DiagRole(), buf);
    }

    static int CoopWorldKeyMine = 0;          // 0 = noch nicht bestimmt (nach dem Laden neu)
    static int CoopWorldLoads = 0;            // u30: abgeschlossene Ladevorgaenge (Spielstand, Weltwechsel, neues Spiel) - Testlauf
    static int CoopWorldKeyAnnounced = 0;     // Welt, fuer die die Lage der anderen zuletzt gemeldet wurde
    static unsigned long CoopWorldsDropped = 0;

    static int CoopWorldKeyOf(const std::string& file) {
        unsigned int h = 2166136261u;
        for (unsigned char c : file) {
            h ^= (unsigned char)toupper(c);
            h *= 16777619u;
        }
        h &= 0x7FFFFFFFu;   // positiv (json-Zahl)
        return h ? (int)h : 1;
    }

    // Schluessel der eigenen Welt; 0 waehrend des Ladens
    int CoopWorldKey() {
        if (IsLoadingLevel)
            return 0;
        if (!CoopWorldKeyMine) {
            const std::string w = CoopWorldName();
            if (!w.empty())
                CoopWorldKeyMine = CoopWorldKeyOf(w);
        }
        return CoopWorldKeyMine;
    }

    // "NEWWORLD\NEWWORLD.ZEN" -> "Khorinis" (bekannte Welten), sonst der Dateiname ohne Pfad
    static std::string CoopWorldShow(const std::string& file) {
        std::string f = file;
        const size_t s = f.find_last_of("\\/");
        if (s != std::string::npos)
            f = f.substr(s + 1);
        for (char& c : f)
            c = (char)toupper((unsigned char)c);
        static const struct { const char* file; const char* de; const char* en; } known[] = {
#if ENGINE >= Engine_G2
            { "NEWWORLD.ZEN", "Khorinis", "Khorinis" },
            { "OLDWORLD.ZEN", "Minental", "Valley of Mines" },
            { "ADDONWORLD.ZEN", "Jharkendar", "Jharkendar" },
            { "DRAGONISLAND.ZEN", "Irdorath", "Irdorath" },
#else
            { "WORLD.ZEN", "Kolonie", "Colony" },
            { "OLDMINE.ZEN", "Alte Mine", "Old Mine" },
            { "FREEMINE.ZEN", "Freie Mine", "Free Mine" },
            { "ORCGRAVEYARD.ZEN", "Orkfriedhof", "Orc Graveyard" },
            { "ORCTEMPEL.ZEN", "Schl\xE4" "fertempel", "Sleeper Temple" },
#endif
        };
        for (auto& k : known)
            if (f == k.file)
                return CoopTr(k.de, k.en);
        return f.empty() ? std::string(CoopTr("unbekannte Welt", "unknown world")) : f;
    }

    struct CoopPeerWorld {
        int key = 0;
        std::string file;            // Dateiname der Welt (kommt mit INIT_NPC)
        std::string nick;            // Name im Spiel (INIT_NPC)
        long long changedMs = 0;
        long long lastMs = 0;        // u38: letztes Paket mit Weltschluessel (laedt er gerade, kommt keins)
        bool announce = false;       // Meldung offen
        bool hasPos = false;         // u39: letzte Lage aus SYNC_POS/INIT_NPC - auch aus einer anderen Welt (Teleport ueber Welten)
        float pos[3] = { 0.f, 0.f, 0.f };
    };
    static std::map<std::string, CoopPeerWorld> CoopPeerWorlds;   // Spieler (HOST, FRIEND_n) -> zuletzt gemeldete Welt

    // Spieler in meiner Welt? Unbekannt (noch kein Paket mit Welt) oder eigene Welt unbekannt = ja
    bool CoopPlayerInMyWorld(const std::string& id) {
        if (!CoopWorldsOn())
            return true;
        auto it = CoopPeerWorlds.find(id);
        const int mine = CoopWorldKey();
        return it == CoopPeerWorlds.end() || !it->second.key || !mine || it->second.key == mine;
    }

    // Client ohne Host in seiner Welt? Dann spielt er sie selbst wie ohne Coop: eigene NPC-KI, -Animationen und -Kampfwerte,
    // Treffer der NPCs auf den eigenen Helden, "Leben der Gegner" selbst gesetzt. Bis u28 galten NPCs beim Client immer als
    // Puppen des Hosts (Hooks.cpp: StartAni, StartAIState, OnDamage_Hit, StandActions; CoopDifficulty.cpp) - allein in einer
    // anderen Welt stand dort jeder NPC still, und kein NPC konnte den Helden verletzen.
    bool CoopClientAlone() {
        return ClientThread && !ServerThread && !CoopPlayerInMyWorld("HOST");
    }

    // Welt, die ein Spieler zuletzt gemeldet hat (0 = unbekannt) - Testlauf
    int CoopPeerWorldKey(const std::string& id) {
        auto it = CoopPeerWorlds.find(id);
        return it == CoopPeerWorlds.end() ? 0 : it->second.key;
    }

    // PacketProcessor: Paket mit Weltschluessel ("wk"). false = aus einer anderen Welt, nicht anwenden. cameIn = der Spieler ist
    // gerade in meine Welt gekommen (eigenen Stand neu schicken); leftMe (u31) = er hat meine Welt eben verlassen (seine NPCs hier
    // nicht mehr als von ihm gefuehrt behandeln).
    bool CoopWorldsAccept(json& e, const std::string& id, int type, bool& cameIn, bool& leftMe) {
        cameIn = false;
        leftMe = false;
        if (!CoopWorldsOn() || !e.contains("wk") || !e["wk"].is_number_integer())
            return true;
        const int wk = e["wk"].get<int>();
        const int mine = CoopWorldKey();
        if (wk && IsCoopPlayer(id)) {
            CoopPeerWorld& p = CoopPeerWorlds[id];
            p.lastMs = CurrentMs;
            const bool known = p.key != 0;
            if (p.key != wk) {
                leftMe = known && mine && p.key == mine && wk != mine;
                p.key = wk;
                p.changedMs = CurrentMs;
                p.file.clear();   // der Name kommt mit dem naechsten INIT_NPC
                p.hasPos = false;   // u39: Lage aus der alten Welt gilt nicht mehr
                p.announce = known || (mine && wk != mine);
                cameIn = known && mine && wk == mine;
            }
            if (type == INIT_NPC) {
                if (e.contains("wn") && e["wn"].is_string())
                    p.file = e["wn"].get<std::string>();
                if (e.contains("nickname") && e["nickname"].is_string() && !e["nickname"].get<std::string>().empty())
                    p.nick = e["nickname"].get<std::string>();
            }
            if ((type == SYNC_POS || type == INIT_NPC) && e.contains("x") && e["x"].is_number() && e.contains("y") && e["y"].is_number() &&
                e.contains("z") && e["z"].is_number()) {   // u39: fuer den Teleport ueber Welten
                p.pos[0] = e["x"].get<float>();
                p.pos[1] = e["y"].get<float>();
                p.pos[2] = e["z"].get<float>();
                p.hasPos = true;
            }
            if (cameIn)
                CoopWorldsLog("%s ist in meine Welt gekommen - eigener Stand geht neu hinaus", id.c_str());
        }
        if (type == SYNC_TIME)
            return true;   // Uhrzeit des Hosts gilt in jeder Welt
        if (!wk || !mine || wk == mine)
            return true;
        if (CoopWorldsDropped++ % 500 == 0)
            CoopWorldsLog("Paket %d von %s aus einer anderen Welt verworfen (%lu bisher)", type, id.c_str(), CoopWorldsDropped);
        return false;
    }

    // Name fuer Meldungen: Name im Spiel, sonst die Kennung
    static std::string CoopWorldsWho(const std::string& id, const CoopPeerWorld& p) {
        return p.nick.empty() ? id : p.nick;
    }

    // Spieler in einer anderen Welt, je Eintrag "Name: Welt" (Markierung, Teleport, Zuschau-Fenster)
    std::vector<std::string> CoopWorldsElsewhere() {
        std::vector<std::string> out;
        if (!CoopWorldsOn())
            return out;
        const int mine = CoopWorldKey();
        if (!mine)
            return out;
        for (auto& kv : CoopPeerWorlds)
            if (kv.second.key && kv.second.key != mine)
                out.push_back(CoopWorldsWho(kv.first, kv.second) + ": " +
                    (kv.second.file.empty() ? std::string(CoopTr("andere Welt", "other world")) : CoopWorldShow(kv.second.file)));
        return out;
    }

    void CoopWorldsPeerGone(const std::string& id) {
        CoopPeerWorlds.erase(id);
    }

    // u201 (3 Spieler, 08.11.2026): Beim Ende/Start einer Verbindung alle gemerkten Mitspieler vergessen. Bisher nahm nur
    // PLAYER_DISCONNECT einen Eintrag heraus - trennte sich ein Client selbst (oder der Host ging), bevor die Meldung fuer
    // einen anderen Client kam, blieb dessen alte Kennung (z. B. FRIEND_2) samt Lage stehen. Nach dem Wiederverbinden mit neuer
    // Kennung galt sie als "Mitspieler ohne Figur" (CoopFollowPoints) - ein dritter Verfolgungspunkt 190 m weg, an dem NPCs
    // eingesetzt wurden, die der Host nie fuehrte ("ohne Abgleich - stehen hier still"). Log FRIEND_5, Punkt 3 bei 11613/1495/-10827.
    void CoopWorldsResetPeers(const char* why) {
        if (CoopPeerWorlds.empty())
            return;
        CoopWorldsLog("%u gemerkte Mitspieler vergessen (%s)", (unsigned)CoopPeerWorlds.size(), why);
        CoopPeerWorlds.clear();
    }

    // u201 (3 Spieler, 08.11.2026): Hinweis im Chat, wenn der Host viele NPCs schickt, die es in der eigenen Welt nicht gibt.
    // Ursache im Test: "Spielstaende getrennt" - ein Client lud seinen eigenen Stand (Tag 47, 554 NPCs), der Host spielte ein
    // neues Spiel (Tag 0, 1055 NPCs). Die NPCs des Hosts fehlten bei ihm, die vorhandenen passten nicht ("NPCs laden nicht").
    static int UnknownHintLoads = -1;
    static size_t UnknownHintBase = 0;
    static bool UnknownHintShown = false;
    static void CoopUnknownNpcHintPulse() {
        if (!ClientThread || ServerThread || IsLoadingLevel || !player)
            return;
        if (UnknownHintLoads != CoopWorldLoads) {   // je Ladevorgang neu zaehlen
            UnknownHintLoads = CoopWorldLoads;
            UnknownHintBase = DiagUnknownIds.size();
            UnknownHintShown = false;
            return;
        }
        if (UnknownHintShown || DiagUnknownIds.size() < UnknownHintBase + 15)
            return;
        UnknownHintShown = true;
        const int fresh = (int)(DiagUnknownIds.size() - UnknownHintBase);
        CoopWorldsLog("%d NPC-Namen des Hosts gibt es hier nicht - anderer Spielstand als der Host? (Hinweis im Chat)", fresh);
        ChatLog(string::Combine(CoopTr(
            "Mindestens %i NPCs des Hosts gibt es in deiner Welt nicht - du spielst wohl einen anderen Spielstand als der Host. "
            "Tritt dem Spiel des Hosts bei (COOP > Abgleich: Spielst\xE4nde gemeinsam), dann laden die NPCs.",
            "At least %i of the host's NPCs do not exist in your world - you are probably playing a different savegame than the host. "
            "Join the host's game (COOP > Sync: shared savegames) so the NPCs load."), fresh), zCOLOR(255, 200, 80, 255));
    }

    // Plugin.cpp LoadBegin/LoadEnd: eigener Schluessel neu
    void CoopWorldsLoadBegin() {
        CoopWorldKeyMine = 0;
    }

    void CoopWorldsLoadEnd() {
        CoopWorldKeyMine = 0;
        CoopWorldLoads++;
        if (CoopWorldKey())
            CoopWorldsLog("eigene Welt %s (%s, Schluessel %08X)", CoopWorldShow(CoopWorldName()).c_str(), CoopWorldName().c_str(),
                (unsigned)CoopWorldKeyMine);
    }

    // Game_Loop: Meldungen im Chat (wer ist wo)
    void CoopWorldsPulse() {
        CoopUnknownNpcHintPulse();   // u201
        if (!CoopWorldsOn() || (!ServerThread && !ClientThread) || IsLoadingLevel || !player)
            return;
        const int mine = CoopWorldKey();
        if (!mine)
            return;
        if (mine != CoopWorldKeyAnnounced) {   // eigener Weltwechsel: alle bekannten Spieler neu melden
            const bool first = CoopWorldKeyAnnounced == 0;
            CoopWorldKeyAnnounced = mine;
            for (auto& kv : CoopPeerWorlds)
                if (kv.second.key && (kv.second.key != mine || !first))
                    kv.second.announce = true;
        }
        for (auto& kv : CoopPeerWorlds) {
            CoopPeerWorld& p = kv.second;
            if (!p.announce || !p.key || (p.file.empty() && CurrentMs - p.changedMs < 3000))
                continue;   // auf den Namen der Welt (INIT_NPC) bis zu 3 s warten
            p.announce = false;
            const std::string who = CoopWorldsWho(kv.first, p);
            const std::string where = p.file.empty() ? std::string(CoopTr("einer anderen Welt", "another world")) : CoopWorldShow(p.file);
            if (p.key == mine) {
                ChatLog(string::Combine(CoopTr("%s ist in deiner Welt (%s).", "%s is in your world (%s)."), string(who.c_str()),
                    string(CoopWorldShow(CoopWorldName()).c_str())), zCOLOR(160, 230, 160, 255));
                CoopWorldsLog("%s (%s) in meiner Welt %s", who.c_str(), kv.first.c_str(), CoopWorldName().c_str());
            }
            else {
                ChatLog(string::Combine(CoopTr("%s ist in einer anderen Welt: %s.", "%s is in another world: %s."), string(who.c_str()),
                    string(where.c_str())), zCOLOR(255, 200, 80, 255));
                CoopWorldsLog("%s (%s) in %s (%s), ich in %s - Figur und NPC-Pakete getrennt", who.c_str(), kv.first.c_str(), where.c_str(),
                    p.file.empty() ? "Name noch unbekannt" : p.file.c_str(), CoopWorldName().c_str());
            }
        }
    }

    // --- u32 (P73): gemeinsamer Weltwechsel mit Bestaetigung ---------------------------------------------------------------
    //
    // Nutzer: "Beide werden in eine Welt zusammen gespawnt, sobald einer durchschreitet, und es erscheint eine Meldung vorher, die
    // derjenige dann bestaetigen muss, der durchschreitet - dann sind beide in der neuen Welt." Als Einstellung neben "getrennt"
    // (Einstellungen > COOP > Abgleich > Weltwechsel, Gothic.ini coopWorldChange, der Host gibt vor - CoopDifficulty.cpp).
    // Engine: oCTriggerChangeLevel::TriggerTarget (G2A 0x0043BE20) reagiert nur auf den eigenen Helden (cmp edi, oCNpc::player,
    // 0x0043BE58 - die Figur des Partners loest bei mir nichts aus) und ruft oCGame::TriggerChangeLevel(Welt, Startpunkt) (G2A
    // 0x006C7AF0, G1 0x0063D480). Die merkt den Wechsel nur vor (oCGame+0xD0 = 1, Namen) - gewechselt wird im naechsten Bild.
    // GT hakt TriggerChangeLevel ein:
    //  - Gemeinsam, verbunden, ein Mitspieler da: erst fragen (Bildmitte: "Weltwechsel nach Minental - alle kommen mit",
    //    [Enter]/[J] wechseln, [Ruecktaste]/[N] bleiben; nach 30 s oder 15 m (u33, vorher 5 m) weg vom Uebergang: bleiben). Ja: WORLD_CHANGE {Welt,
    //    Startpunkt} an alle (der Host leitet weiter), dann der Wechsel wie von Gothic.
    //  - Die anderen: Meldung "<Name> wechselt nach <Welt> - du kommst mit", nach 2 s derselbe Aufruf mit Welt und Startpunkt -
    //    sobald kein Menue offen ist und nach einem Dialog (spaetestens nach 15 s beendet GT ihn wie vor einem Ladevorgang). Wer schon
    //    in der Zielwelt ist, bleibt.
    //  - Getrennt bzw. ohne Mitspieler: wie Gothic (u29-u31).
    bool CoopRuleWorldTogether();   // CoopDifficulty.cpp

    struct CoopWcAsk {
        bool on = false;
        std::string level, start;
        zVEC3 at;
        long long since = 0;
    };
    struct CoopWcFollow {
        bool on = false;
        std::string level, start, by;
        long long since = 0, dialogSince = 0, exitMs = 0;
    };
    static CoopWcAsk CoopWcAskNow;
    static CoopWcFollow CoopWcFollowNow;
    static int CoopWcPass = 0;   // eigener Aufruf (nach Ja bzw. beim Nachholen) - nicht noch einmal fragen
    static bool CoopWcEnterWas = false, CoopWcJWas = false, CoopWcBackWas = false, CoopWcNWas = false;

    static std::string CoopWcBase(std::string s) {
        const size_t p = s.find_last_of("\\/");
        if (p != std::string::npos)
            s = s.substr(p + 1);
        for (char& c : s)
            c = (char)toupper((unsigned char)c);
        return s;
    }

    static bool CoopWcInTarget(const std::string& level) {
        return !level.empty() && CoopWcBase(level) == CoopWcBase(CoopWorldName());
    }

    // gemeinsamer Weltwechsel gilt: Regel des Hosts, Coop laeuft, ein Mitspieler (hier oder in einer anderen Welt)
    static bool CoopWcWanted() {
        return CoopRuleWorldTogether() && (ServerThread || ClientThread) && !IsCoopPaused && !(MyselfId == "_player_") && player &&
            !IsLoadingLevel && (!PlayerNpcs.empty() || !CoopPeerWorlds.empty());
    }

    static void CoopWcGo(const std::string& level, const std::string& start) {
        CoopWcPass++;
        ogame->TriggerChangeLevel(zSTRING(level.c_str()), zSTRING(start.c_str()));
        CoopWcPass--;
    }

    // --- u47 (P88): Betreten - der Stand dessen gilt, der dort ist bzw. zuletzt dort war ---------------------------------------
    //
    // Nutzer: "beim Betreten soll der Stand dessen gelten, der dort war bzw. zuletzt dort war". Bis u46 lud jeder eine Welt aus
    // seiner eigenen Datei (Saves\current) - was der andere dort getan hatte, fehlte bis zur naechsten gemeinsamen Sicherung, und kam
    // der Host in die Welt eines Clients, ueberschrieb sein aelterer Stand den des Clients (der Host fuehrt den Bestand).
    // Jetzt merkt sich jeder PC je Welt, wann welcher Spieler zuletzt dort war (CoopWorldSeen, aus der eigenen Welt und den Welten
    // der Mitspieler, jede Sekunde). Betritt man eine Welt, in der ein verbundener Mitspieler mehr als 10 s spaeter war als man selbst
    // (oder gerade ist), haelt GT den Wechsel an: gemeinsame Sicherung (Art "weltwechsel", reservierter Slot wie die Auto-Sicherung),
    // der Weltstand-Tausch (P81) holt die Datei jener Welt aus der Kopie des Mitspielers nach Saves\current, erst dann der Wechsel -
    // Gothic laedt die Welt aus dessen Stand. Ist er dort, gleicht danach wie bisher der Host ab, nun auf beiden Seiten vom selben
    // Stand. Dauert es zu lange (bis 2,5 min) oder geht die Sicherung nicht, wechselt GT mit dem eigenen Stand. Gilt fuer jeden
    // Wechsel ueber oCGame::TriggerChangeLevel (Uebergang, Mitkommen, Testlauf, Teleport ueber Welten), nicht im Weltprozess.
    // Abschaltbar: GothicCoopConfig.json "coopEnterTakeState": false. Merkliste nach jedem Laden eines Spielstands leer.
    int CoopSaveSyncEnterSave(const std::string& world, const std::string& from, std::string& why);   // CoopSaveSync.cpp
    int CoopSaveSyncEnterState(std::string& note);

    struct CoopSeen {
        long long ms = 0;
        std::string file;   // Dateiname der Welt wie CoopWorldName (Weltdateien im Spielstand: CoopWorldSaveFiles)
    };
    static std::map<std::string, std::map<std::string, CoopSeen>> CoopWorldSeen;   // Welt (CoopWcBase) -> Spieler ("" = ich) -> zuletzt dort
    static long long CoopWorldSeenMs = 0;

    void CoopWorldSeenReset(const char* why) {
        if (!CoopWorldSeen.empty())
            CoopWorldsLog("Merkliste \"wer war zuletzt wo\" geleert (%s)", why);
        CoopWorldSeen.clear();
    }

    static void CoopWorldSeenPulse() {
        if (CurrentMs < CoopWorldSeenMs + 1000 || IsLoadingLevel)
            return;
        CoopWorldSeenMs = CurrentMs;
        if (CoopWorldKey()) {
            const std::string w = CoopWorldName();
            CoopSeen& s = CoopWorldSeen[CoopWcBase(w)][""];
            s.ms = CurrentMs;
            s.file = w;
        }
        for (auto& kv : CoopPeerWorlds)   // zuletzt gemeldete Welt gilt, bis er wechselt (auch wenn er still steht und nichts sendet)
            if (kv.second.key && !kv.second.file.empty()) {
                CoopSeen& s = CoopWorldSeen[CoopWcBase(kv.second.file)][kv.first];
                s.ms = CurrentMs;
                s.file = kv.second.file;
            }
    }

    static bool CoopEnterConfig() {
        return !(CoopConfig.contains("coopEnterTakeState") && CoopConfig["coopEnterTakeState"].is_boolean() &&
            !CoopConfig["coopEnterTakeState"].get<bool>());
    }

    struct CoopEnter {
        bool on = false;
        std::string level, start, from, who, file;
        bool there = false;
        long long since = 0;
    };
    static CoopEnter CoopEnterNow;
    static int CoopEnterPass = 0;

    // true = jetzt wechseln; false = angehalten (CoopEnterPulse wechselt, sobald der Stand da ist)
    static bool CoopEnterGate(const std::string& level, const std::string& start) {
        if (CoopEnterPass > 0 || CoopWpIsWorld() || !CoopEnterConfig() || !(ServerThread || ClientThread) || IsCoopPaused || IsLoadingLevel ||
            !player || MyselfId == "_player_" || level.empty() || CoopWcInTarget(level))
            return true;
        if (CoopEnterNow.on)
            return false;
        const std::string base = CoopWcBase(level);
        auto w = CoopWorldSeen.find(base);
        if (w == CoopWorldSeen.end())
            return true;
        const long long mine = w->second.count("") ? w->second[""].ms : 0;
        std::string best, bestFile;
        long long bestMs = 0;
        for (auto& s : w->second) {
            if (s.first.empty() || s.second.ms <= mine + 10000 || s.second.ms <= bestMs)
                continue;
            if (!CoopPeerWorlds.count(s.first))
                continue;   // nicht (mehr) verbunden (CoopWorldsPeerGone nimmt ihn beim Trennen heraus)
            best = s.first;
            bestMs = s.second.ms;
            bestFile = s.second.file;
        }
        if (best.empty())
            return true;
        auto p = CoopPeerWorlds.find(best);
        const bool there = p != CoopPeerWorlds.end() && p->second.key && CoopWcBase(p->second.file) == base;
        const std::string who = p != CoopPeerWorlds.end() ? CoopWorldsWho(best, p->second) : best;
        const std::string file = bestFile.empty() ? level : bestFile;
        std::string why;
        const int slot = CoopSaveSyncEnterSave(file, best, why);
        if (slot < 0) {
            CoopWorldsLog("Betreten %s: %s %s - gemeinsame Sicherung jetzt nicht (%s), eigener Stand gilt", file.c_str(), who.c_str(),
                there ? "ist dort" : "war zuletzt dort", why.c_str());
            return true;
        }
        CoopEnterNow = CoopEnter();
        CoopEnterNow.on = true;
        CoopEnterNow.level = level;
        CoopEnterNow.start = start;
        CoopEnterNow.from = best;
        CoopEnterNow.who = who;
        CoopEnterNow.file = file;
        CoopEnterNow.there = there;
        CoopEnterNow.since = CurrentMs;
        ChatLog(string::Combine(there ? CoopTr("%s ist in %s - hole erst seinen Stand dieser Welt (gemeinsame Sicherung) ...",
            "%s is in %s - fetching their state of this world first (shared save) ...") :
            CoopTr("%s war zuletzt in %s - hole erst seinen Stand dieser Welt (gemeinsame Sicherung) ...",
                "%s was in %s last - fetching their state of this world first (shared save) ..."), string(who.c_str()),
            string(CoopWorldShow(file).c_str())), zCOLOR(255, 220, 120, 255));
        char after[48];   // u48: war ich nie dort (mine 0), keine Zeitspanne (u47 schrieb "1792953911 s nach mir")
        if (mine > 0)
            sprintf_s(after, "%.0f s nach mir", (bestMs - mine) / 1000.0);
        else
            strcpy_s(after, "ich war nie dort");
        CoopWorldsLog("Betreten %s: %s (%s) %s (%s) - Wechsel angehalten, gemeinsame Sicherung in Slot %d, dann seine Weltdatei",
            file.c_str(), who.c_str(), best.c_str(), there ? "ist dort" : "war zuletzt dort", after, slot);
        return false;
    }

    static void CoopEnterPulse() {
        CoopEnter& e = CoopEnterNow;
        if (!e.on)
            return;
        std::string note;
        const int st = CoopSaveSyncEnterState(note);
        if (st == 0 && CurrentMs < e.since + 150000) {
            zSTRING font = screen->GetFontName();
            const zCOLOR color = screen->fontColor;
            screen->SetFont(zSTRING("Font_Old_10_White_Hi.TGA"));
            zSTRING t((std::string(CoopTr("Weltwechsel nach ", "World change to ")) + CoopWorldShow(e.file) + ": " + note + " ...").c_str());
            screen->SetFontColor(zCOLOR(255, 230, 150, 255));
            screen->Print(4096 - screen->FontSize(t) / 2, 600, t);
            screen->SetFont(font);
            screen->SetFontColor(color);
            return;
        }
        e.on = false;
        if (st == 1) {
            CoopWorldSeen[CoopWcBase(e.file)][""].ms = CurrentMs;   // jetzt habe ich den neuesten Stand
            CoopWorldsLog("Betreten %s: Stand von %s geholt nach %.1f s - wechsle", e.file.c_str(), e.who.c_str(), (CurrentMs - e.since) / 1000.0);
        }
        else {
            CoopWorldsLog("Betreten %s: Stand von %s NICHT geholt (%s) - wechsle mit dem eigenen Stand", e.file.c_str(), e.who.c_str(),
                st == 0 ? "Zeit um" : note.c_str());
            ChatLog(string::Combine(CoopTr("Stand von %s nicht geholt - du betrittst die Welt mit deinem eigenen Stand.",
                "Could not fetch %s's state - you enter the world with your own state."), string(e.who.c_str())), zCOLOR(255, 200, 80, 255));
        }
        CoopEnterPass++;
        CoopWcPass++;
        ogame->TriggerChangeLevel(zSTRING(e.level.c_str()), zSTRING(e.start.c_str()));
        CoopWcPass--;
        CoopEnterPass--;
    }

    void __fastcall oCGame_TriggerChangeLevel_Coop(oCGame* _this, void* vtable, zSTRING const& level, zSTRING const& start);
    CInvoke<void(__thiscall*)(oCGame*, zSTRING const&, zSTRING const&)> Ivk_oCGame_TriggerChangeLevel_Coop(CoopAddr::oCGame_TriggerChangeLevel,
        &oCGame_TriggerChangeLevel_Coop);
    void __fastcall oCGame_TriggerChangeLevel_Coop(oCGame* _this, void* vtable, zSTRING const& level, zSTRING const& start) {
        if (CoopEnterNow.on && CoopEnterPass == 0)
            return;   // u47: ein Wechsel wartet schon auf den Stand des Mitspielers (Uebergang erneut beruehrt u. ae.)
        if (CoopWcPass > 0 || !CoopWcWanted()) {
            if (!CoopEnterGate(std::string(level.ToChar()), std::string(start.ToChar())))
                return;   // u47 (P88): erst den Stand dessen holen, der dort ist bzw. zuletzt dort war
            Ivk_oCGame_TriggerChangeLevel_Coop(_this, level, start);
            return;
        }
        if (CoopWcAskNow.on)
            return;   // laeuft schon (der Ausloeser meldet sich erneut)
        CoopWcAskNow.on = true;
        CoopWcAskNow.level = level.ToChar();
        CoopWcAskNow.start = start.ToChar();
        CoopWcAskNow.at = player->GetPositionWorld();
        CoopWcAskNow.since = CurrentMs;
        CoopWcEnterWas = CoopWcJWas = CoopWcBackWas = CoopWcNWas = true;   // erst nach dem Loslassen zaehlt ein Druck
        CoopWorldsLog("Weltwechsel nach %s (Startpunkt %s) - frage, ob alle mitkommen", CoopWcAskNow.level.c_str(), CoopWcAskNow.start.c_str());
    }

    // PacketProcessor.cpp: Mitspieler wechselt die Welt (gemeinsam)
    void CoopWorldChangeReceive(json& e, const std::string& id) {
        CoopTraceCount(TRACE_RECV, SYNC_WORLD_CHANGE);
        const std::string level = e.contains("lvl") && e["lvl"].is_string() ? e["lvl"].get<std::string>() : std::string();
        const std::string start = e.contains("sp") && e["sp"].is_string() ? e["sp"].get<std::string>() : std::string();
        // u33 (Test u32: beide hiessen "Spieler" - "Spieler wechselt nach ..." sagte nicht, wer): Name und Kennung
        std::string nick = e.contains("nick") && e["nick"].is_string() && !e["nick"].get<std::string>().empty() ? e["nick"].get<std::string>() : id;
        if (nick != id)
            nick += " (" + id + ")";
        if (level.empty() || !player || !CoopRuleWorldTogether())
            return;
        if (CoopWcInTarget(level)) {
            CoopWorldsLog("%s wechselt nach %s - ich bin schon dort", nick.c_str(), level.c_str());
            ChatLog(string::Combine(CoopTr("%s kommt nach %s - du bist schon dort.", "%s is coming to %s - you are already there."),
                string(nick.c_str()), string(CoopWorldShow(level).c_str())), zCOLOR(160, 230, 160, 255));
            return;
        }
        if (CoopWcAskNow.on) {
            CoopWcAskNow.on = false;   // eigene Abfrage hinfaellig - es geht mit ihm
            CoopWorldsLog("eigene Abfrage verworfen - %s wechselt zuerst", nick.c_str());
        }
        CoopWcFollowNow = CoopWcFollow();
        CoopWcFollowNow.on = true;
        CoopWcFollowNow.level = level;
        CoopWcFollowNow.start = start;
        CoopWcFollowNow.by = nick;
        CoopWcFollowNow.since = CurrentMs;
        ChatLog(string::Combine(CoopTr("%s wechselt nach %s - du kommst gleich mit.", "%s is going to %s - you will follow shortly."),
            string(nick.c_str()), string(CoopWorldShow(level).c_str())), zCOLOR(255, 220, 120, 255));
        CoopWorldsLog("%s wechselt nach %s (Startpunkt %s) - komme mit", nick.c_str(), level.c_str(), start.c_str());
    }

    static void CoopWcPrint(int y, const std::string& text, const zCOLOR& c) {
        zSTRING t(text.c_str());
        screen->SetFontColor(c);
        screen->Print(4096 - screen->FontSize(t) / 2, y, t);
    }

    static void CoopWcAskPulse() {
        CoopWcAsk& a = CoopWcAskNow;
        if (!a.on)
            return;
        const zVEC3 p = player->GetPositionWorld();
        const float dx = p.n[0] - a.at.n[0], dz = p.n[2] - a.at.n[2];
        const bool yes = CoopKeyEdge(KEY_RETURN, VK_RETURN, CoopWcEnterWas) | CoopKeyEdge(KEY_J, 'J', CoopWcJWas);
        const bool no = CoopKeyEdge(KEY_BACK, VK_BACK, CoopWcBackWas) | CoopKeyEdge(KEY_N, 'N', CoopWcNWas);
        const char* why = NULL;
        if (no)
            why = "abgelehnt";
        else if (CurrentMs > a.since + 30000)
            why = "keine Antwort in 30 s";
        else if (dx * dx + dz * dz > 1500.f * 1500.f)   // u33: 15 m (Test u32: bei 5 m nach 1 s abgebrochen - man laeuft weiter)
            why = "vom Uebergang weggegangen";
        else if (!CoopWcWanted())
            why = "Coop nicht mehr gemeinsam";
        if (why) {
            a.on = false;
            ChatLog(CoopTr("Weltwechsel abgebrochen - du bleibst hier.", "World change cancelled - you stay here."), zCOLOR(255, 200, 80, 255));
            CoopWorldsLog("Weltwechsel nach %s nicht ausgefuehrt (%s)", a.level.c_str(), why);
            return;
        }
        if (yes) {
            a.on = false;
            json j;
            j["type"] = SYNC_WORLD_CHANGE;
            j["id"] = MyselfId.ToChar();
            j["lvl"] = a.level;
            j["sp"] = a.start;
            j["nick"] = std::string(MyNickname.ToChar());
            CoopTraceCount(TRACE_SENT, SYNC_WORLD_CHANGE);
            ReadyToSendJsons.enqueue(j);
            CoopWorldsLog("Weltwechsel nach %s bestaetigt - Mitspieler kommen mit", a.level.c_str());
            CoopWcGo(a.level, a.start);
            return;
        }
        // Abfrage in der Bildmitte
        zSTRING font = screen->GetFontName();
        const zCOLOR color = screen->fontColor;
        screen->SetFont(zSTRING("Font_Old_20_White.TGA"));
        const int fy = screen->FontY();
        CoopWcPrint(3000, std::string(CoopTr("Weltwechsel nach ", "World change to ")) + CoopWorldShow(a.level) +
            CoopTr(" - alle Mitspieler kommen mit", " - all players come along"), zCOLOR(255, 230, 150, 255));
        CoopWcPrint(3000 + fy + 100, CoopTr("[Enter] / [J] wechseln     [R\xFC" "cktaste] / [N] bleiben", "[Enter] / [J] change     [Backspace] / [N] stay"),
            zCOLOR(255, 255, 255, 255));
        screen->SetFont(font);
        screen->SetFontColor(color);
    }

    static void CoopWcFollowPulse() {
        CoopWcFollow& f = CoopWcFollowNow;
        if (!f.on || IsSavingGame)
            return;
        if (CurrentMs > f.since + 120000) {
            f.on = false;
            ChatLog(CoopTr("Weltwechsel zum Mitspieler nicht moeglich - du bleibst hier.", "Could not follow your partner - you stay here."), zCOLOR(255, 80, 80, 255));
            CoopWorldsLog("Weltwechsel nach %s nach 120 s aufgegeben", f.level.c_str());
            return;
        }
        if (CoopWcInTarget(f.level)) {
            f.on = false;   // inzwischen dort (z. B. selbst hindurchgegangen)
            return;
        }
        const bool menu = zCMenu::GetActive() != NULL;
        oCInformationManager& im = oCInformationManager::GetInformationManager();
        const bool dialog = !im.IsDone || IsPlayerTalkingWithAnybody();
        if (CurrentMs < f.since + 2000 || menu || dialog || player->IsDead() || (f.exitMs && CurrentMs < f.exitMs + 700)) {
            if (dialog && !f.dialogSince)
                f.dialogSince = CurrentMs;
            else if (dialog && !f.exitMs && CurrentMs > f.dialogSince + 15000) {
                im.Exit();   // wie vor einem Ladevorgang (CoopSaveSync.cpp, v90)
                f.exitMs = CurrentMs;
                CoopWorldsLog("Weltwechsel: Dialog nach 15 s beendet");
            }
            zSTRING font = screen->GetFontName();
            const zCOLOR color = screen->fontColor;
            screen->SetFont(zSTRING("Font_Old_10_White_Hi.TGA"));
            CoopWcPrint(600, f.by + CoopTr(" wechselt nach ", " is going to ") + CoopWorldShow(f.level) + CoopTr(" - du kommst mit", " - you follow"),
                zCOLOR(255, 230, 150, 255));
            screen->SetFont(font);
            screen->SetFontColor(color);
            return;
        }
        f.on = false;
        CoopWorldsLog("Weltwechsel nach %s (Startpunkt %s) - mit %s", f.level.c_str(), f.start.c_str(), f.by.c_str());
        CoopWcGo(f.level, f.start);
    }

    // Plugin.cpp Game_Loop
    void CoopWorldChangePulse() {
        if (!player || !ogame || IsLoadingLevel || !screen)
            return;
        CoopWorldSeenPulse();   // u47
        CoopEnterPulse();       // u47
        CoopWcAskPulse();
        CoopWcFollowPulse();
    }

    // Plugin.cpp LoadBegin: offene Abfrage/Nachholen gelten nicht fuer die neue Welt
    void CoopWorldChangeLoadBegin() {
        CoopWcAskNow.on = false;
        CoopWcFollowNow.on = false;
        CoopEnterNow.on = false;   // u47
    }
}
