// Supported with union (c) 2020 Union team
// Union SOURCE file

namespace GOTHIC_ENGINE {

    // --- v41: Abgleich ausserhalb der Reichweite - Verfolgungspunkt beim Mitspieler (19.10.2026) -----------------------------
    //
    // Nutzer: "wenn der Mitspieler unseren Radius verlaesst, soll es weiterhin synchronisiert bleiben - NPCs, die er toetet,
    // Quests, die er erledigt, und Monster. Fuer Quests bekommt man die EP, aber nicht fuer die Kills." Idee des Nutzers:
    // "einen Verfolgungspunkt aktivieren wie eine zweite Instanz, die dem Mitspieler folgt".
    //
    // Bisher: Der Host sendet nur NPCs im Umkreis seines eigenen Helden (GetVisibleNpcs, BROADCAST_DISTANCE 4500). Ist die
    // Figur eines Clients weiter weg, loeschte der Host sie (RespawnOrDestroyBasedOnDistance), seine Treffer verwarf
    // UpdateAttacks ("if (!hasModel) return") - Kills weit weg kamen beim Host nie an, die NPCs dort liefen beim Client nur lokal.
    // Und der Spawn-Manager des Hosts nimmt NPCs weit weg vom eigenen Helden ganz aus der Welt.
    //
    // Jetzt (Host und Client - Nutzer: "umgekehrt muss der Client auch den Host mit der Instanz verfolgen"; abschaltbar mit
    // "coopFollowPartner": false):
    // - Verfolgungspunkt: oCSpawnManager::CheckInsertNpcs (0x006CF9A0, je Spawn-Takt 1000 ms; setzt camPos +0x10 auf den Helden
    //   und springt nach CheckInsertNpc 0x006CFDE0) wird abgefangen. Nach jedem Takt laeuft CheckInsertNpc noch einmal mit camPos =
    //   Lage jeder weit entfernten Figur - InsertNpc (0x006D0250) prueft den Abstand selbst gegen camPos (insertRange 4500,
    //   0x00850FB4). Die Wartezeiten der Knoten (+0x10) zaehlt CheckInsertNpc herunter (Hauptschleife und Othellos Anhang ab
    //   +0x409); sie werden um den zusaetzlichen Durchlauf gesichert und zurueckgesetzt.
    // - oCSpawnManager::CheckRemoveNpc (0x006D0A80, je NPC aus der Menschen-KI, 1 = entfernt) wird abgefangen: NPCs im
    //   removeRange (5000, 0x00850FB8) einer Figur und die Figuren selbst bleiben in der Welt.
    // - Eingefuegte NPCs laufen voll (zCVob::DoFrameActivity: Schlafmodus 1 = KI + Animation; nichts schaltet NPCs nach
    //   Kameraabstand auf "nur KI" - gesucht im Speicherabbild). Othellos Eingriff in oCNpc::ProcessNpc gilt nur dem Helden.
    // - Senden: GetVisibleNpcs (Host) nimmt NPCs im Umkreis jeder Figur mit (Helpers.cpp); die Figuren bleiben auf beiden Seiten
    //   immer in der Welt (RemoteNpc.cpp) - damit gelten Treffer, Kaempfe und Tode dort wie in der Naehe. Beim Client halten
    //   dieselben Haken die NPCs um die Host-Figur aktiv, und deren RemoteNpc wird nicht mehr nach 1,5 x Reichweite verworfen.
    // - EP: Kills ausserhalb der Reichweite ohne EP fuer den anderen (CoopKillNoXp: Othellos ZS_Dead gibt EP nur, wenn der Taeter
    //   Spieler ist oder AIV_PARTYMEMBER (36) bzw. AIV_MM_PARTYMEMBER (23) traegt - die Merker des Taeters stehen dabei kurz auf 0).
    //   Quest-EP aus Dialogen bekommen beide wie bisher (D11). In der Naehe bleibt es bei geteilten Kill-EP.
    // - Todesabgleich als Netz: Der Host meldet jeden Tod eines benannten NPCs (Takt 1 s, Paket 51 NPC_DEATH), beim RESYNC die
    //   ganze Liste; der Client toetet ihn ohne EP, falls er bei ihm noch lebt (auch Tode, die er nie gesehen hat).

#if COOP_BUILD(FarSync)   // u3: bis u2 nur G1 - Freigabe je Engine in CoopCore.cpp

    static bool FarCfgRead = false;
    static bool FarFollow = true;
    static long long FarNextScanMs = 0, FarNextLogMs = 0;
    static std::map<oCNpc*, std::string> FarAlive;      // Host: zuletzt lebend gesehene benannte NPCs
    static bool FarScanReady = false;
    static std::set<std::string> FarKnownDead;          // Client: vom Host als tot gemeldet
    static std::map<std::string, long long> FarPending; // Client: Name -> bis wann noch versuchen
    static std::map<std::string, long long> FarPendingAt; // u40: Client: Name -> wann die Meldung kam (erst nach 1 s anwenden, s. FarApplyPending)
    static unsigned long FarInsertedSinceLog = 0, FarKeptSinceLog = 0, FarDeathsSent = 0, FarDeathsApplied = 0;
    static unsigned long FarLedInsertedSinceLog = 0;    // v43: Client - vom Host gefuehrte NPCs an seiner Lage eingesetzt
    static std::map<oCNpc*, zVEC3> FarMoveProbe;        // Lage der NPCs um die Figur beim letzten Bericht
    static std::map<oCNpc*, zVEC3> FarMoveProbeMe;      // v43: dasselbe um den eigenen Helden (Vergleichswert)

    static void FarLog(const char* fmt, ...) {
        char buf[1024];
        va_list ap;
        va_start(ap, fmt);
        _vsnprintf(buf, sizeof(buf), fmt, ap);
        va_end(ap);
        buf[sizeof(buf) - 1] = 0;
        OthelloCompatLog("[%lld s, %s] Fern-Abgleich: %s", DiagSeconds(), DiagRole(), buf);
    }

    static void FarReadConfig() {
        if (FarCfgRead)
            return;
        FarCfgRead = true;
        if (CoopConfig.contains("coopFollowPartner") && CoopConfig["coopFollowPartner"].is_boolean())
            FarFollow = CoopConfig["coopFollowPartner"].get<bool>();
        FarLog("Verfolgungspunkt beim Mitspieler %s (coopFollowPartner)", FarFollow ? "an" : "aus");
    }

    // Verfolgungspunkt an (Host und Client - Nutzer: "umgekehrt muss der Client auch den Host mit der Instanz verfolgen"),
    // verbunden, Welt geladen.
    bool CoopFollowActive() {
        FarReadConfig();
        return FarFollow && (ServerThread || (ClientThread && !IsCoopPaused)) && !(MyselfId == "_player_") && !IsLoadingLevel
            && !WorldEditMode && player && ogame && ogame->GetGameWorld();
    }

    static float FarDist(const zVEC3& a, const zVEC3& b) {
        const float dx = a.n[0] - b.n[0], dy = a.n[1] - b.n[1], dz = a.n[2] - b.n[2];
        return sqrtf(dx * dx + dy * dy + dz * dz);
    }

    // Lage der Figuren der anderen Spieler (Host: alle Clients; Client: Host und weitere Clients). Bevorzugt die zuletzt
    // gemeldete Lage.
    int CoopFollowPoints(zVEC3* out, int max) {
        if (!CoopFollowActive())
            return 0;
        int n = 0;
        for (auto& kv : PlayerNpcs) {
            if (n >= max)
                break;
            oCNpc* f = kv.first;
            if (!f)
                continue;
            auto it = SyncNpcs.find(kv.second);
            if (it != SyncNpcs.end() && it->second && it->second->lastPositionFromServer)
                out[n++] = *it->second->lastPositionFromServer;
            else
                out[n++] = f->GetPositionWorld();
        }
        // u48 (P90): Mitspieler in meiner Welt, dessen Figur (noch) fehlt - die ersten Sekunden nach einem Weltwechsel, bis sein
        // INIT_NPC kommt. Seine zuletzt gemeldete Lage zaehlt mit (CoopPeerWorlds, CoopWorlds.cpp). Test u47: Teleport ueber Welten
        // setzt mich erst an den Startpunkt der Welt, Gothics Spawn-Manager raeumte in der Zeit die Leiche einer Wld_InsertNpc-
        // Fleischwanze neben dem Partner weg (bei ihm lag sie noch). Allgemein (G1/G2).
        const int mine = CoopWorldKey();
        for (auto& kv : CoopPeerWorlds) {
            if (n >= max)
                break;
            const CoopPeerWorld& pw = kv.second;
            if (kv.first == MyselfId.ToChar() || !pw.hasPos || !pw.key || pw.key != mine || PlayerNameToNpc.count(string(kv.first.c_str())))
                continue;
            // u201 (3 Spieler): nur fuer die ersten Sekunden nach einem Weltwechsel gedacht - wer seit 30 s nichts geschickt hat,
            // ist kein Verfolgungspunkt (alte Kennung eines getrennten Spielers stand sonst dauerhaft als Punkt 3 in der Welt).
            if (CurrentMs - pw.lastMs > 30000)
                continue;
            out[n++] = zVEC3(pw.pos[0], pw.pos[1], pw.pos[2]);
        }
        return n;
    }

    bool CoopFollowNear(const zVEC3& p, float range) {
        zVEC3 pts[8];
        const int n = CoopFollowPoints(pts, 8);
        for (int i = 0; i < n; i++)
            if (FarDist(pts[i], p) < range)
                return true;
        return false;
    }

    // Figur/NPC ausserhalb der eigenen Reichweite (fuer die EP-Regel bei Kills). v67: Reichweite aus dem Schwierigkeitsgrad
    // (CoopDifficulty.cpp, Vorgabe 45 m = BROADCAST_DISTANCE wie bisher; "ueberall" = nie zu weit).
    float CoopDiffXpRangeCm();
    bool CoopFarFromMe(oCNpc* npc) {
        if (!npc || !player)
            return false;
        const float range = CoopDiffXpRangeCm();
        if (range < 0.f)
            return false;
        return FarDist(npc->GetPositionWorld(), player->GetPositionWorld()) > range;
    }

    static bool FarActiveInWorld(oCNpc* npc) {
        return npc && npc->GetHomeWorld() && npc->vobLeafList.GetNum() > 0 && npc->GetModel();
    }

    // Figur an pos in die Welt setzen, auch weit weg vom eigenen Helden. InsertNpc (0x006D0250) prueft den Abstand gegen camPos
    // und setzt nur ein, wenn oCNpc::spawnInRange (+0x79C Bit 0x2000, 0x006D0301) gesetzt ist - sonst setzt es das Bit und
    // liefert 0. Darum camPos = pos und das Bit vorher setzen.
    bool CoopSpawnInsertAt(oCNpc* npc, const zVEC3& pos) {
        oCSpawnManager* sm = ogame ? ogame->spawnman : NULL;
        if (!sm || !npc)
            return false;
        const zVEC3 cam = sm->camPos;
        sm->camPos = pos;
        npc->spawnInRange = 1;   // u3: SDK-Bitfeld (G1 +0x79C Bit 0x2000; G2A im Wort nach effectList)
        const int ok = sm->InsertNpc(npc, pos);
        sm->camPos = cam;
        return ok != 0;
    }

    // Toeten ohne EP fuer den eigenen Helden: Taeter = killer (oder das Opfer selbst), seine Partei-Merker kurz 0.
    void CoopKillNoXp(oCNpc* npc, oCNpc* killer, const char* why) {
        if (!npc || npc->IsDead() || npc == player)
            return;
        static int pm = -2, mmpm = -2;
        if (pm == -2) {
            pm = GetPartyMemberID();
            zCPar_Symbol* s = parser->GetSymbol("AIV_MM_PARTYMEMBER");
            mmpm = -1;
            if (s)
                s->GetValue(mmpm, 0);
            FarLog("EP-Merker: AIV_PARTYMEMBER %d, AIV_MM_PARTYMEMBER %d", pm, mmpm);
        }
        oCNpc* k = killer ? killer : npc;
        const int savePm = (pm >= 0 && pm < COOP_AIV_MAX) ? k->aiscriptvars[pm] : 0;
        const int saveMm = (mmpm >= 0 && mmpm < COOP_AIV_MAX) ? k->aiscriptvars[mmpm] : 0;
        if (pm >= 0 && pm < COOP_AIV_MAX)
            k->aiscriptvars[pm] = 0;
        if (mmpm >= 0 && mmpm < COOP_AIV_MAX)
            k->aiscriptvars[mmpm] = 0;
        const bool active = FarActiveInWorld(npc);
        const bool replay = ClientThread && !ServerThread;   // der Host hat diesen Tod (und sein ZS_Dead) schon ausgefuehrt
        npc->SetAttribute(NPC_ATR_HITPOINTS, 0);
        if (replay)
            CoopReplayDeathDepth++;
        if (active)
            npc->DoDie(k);   // vtable -> OTHELLO_ABI+0x7C3F0 (wie C7); ohne aktive Welt reicht HP 0 (CheckInsertNpc setzt Tote nicht ein)
        if (replay)
            CoopReplayDeathDepth--;
        if (pm >= 0 && pm < COOP_AIV_MAX)
            k->aiscriptvars[pm] = savePm;
        if (mmpm >= 0 && mmpm < COOP_AIV_MAX)
            k->aiscriptvars[mmpm] = saveMm;
        FarDeathsApplied++;
        static unsigned long logged = 0;
        if (logged++ < 60) {
            auto it = NpcToUniqueNameList.find(npc);
            FarLog("%s tot ohne EP (%s, %s)", it != NpcToUniqueNameList.end() ? it->second.ToChar() : npc->GetObjectName().ToChar(),
                why, active ? "in der Welt: DoDie" : "nicht in der Welt: HP 0");
        }
    }

    bool CoopFarKnownDead(const std::string& name) {
        return FarKnownDead.count(name) != 0;
    }

    // v43: steht der NPC in der Spawn-Liste (dann setzt der Spawn-Manager ihn selbst ein)?
    bool CoopSpawnListHas(oCNpc* npc) {
        oCSpawnManager* sm = ogame ? ogame->spawnman : NULL;
        if (!sm || !npc)
            return false;
        for (int k = 0; k < sm->spawnList.GetNum(); k++)
            if (oCSpawnManager::oSSpawnNode* node = sm->spawnList[k])
                if (node->npc == npc)
                    return true;
        return false;
    }

    // v108 (Test v107): Lage im Spawn-Listen-Eintrag (fuer NPCs ausserhalb der Welt)
    bool CoopSpawnListPos(oCNpc* npc, zVEC3& pos) {
        oCSpawnManager* sm = ogame ? ogame->spawnman : NULL;
        if (!sm || !npc)
            return false;
        for (int k = 0; k < sm->spawnList.GetNum(); k++)
            if (oCSpawnManager::oSSpawnNode* node = sm->spawnList[k])
                if (node->npc == npc) {
                    pos = node->spawnPos;
                    return true;
                }
        return false;
    }

    // v108 (Test v107): eine Fleischwanze des Hosts stand beim Client mit falscher Lage in der Spawn-Liste ("weit weg") - der
    // Host fuehrte sie neben dem Mitspieler, der Spawn-Manager setzte sie hier aber nie ein (er prueft die Lage im Eintrag), und
    // RemoteNpc liess Eintraege der Spawn-Liste in Ruhe. Jetzt den Eintrag an die Lage des Hosts legen (Zeitgeber 0): der
    // Spawn-Manager setzt ihn beim naechsten Durchlauf am Verfolgungspunkt ein. true = verlegt.
    bool CoopSpawnListMove(oCNpc* npc, const zVEC3& pos, const char* why) {
        oCSpawnManager* sm = ogame ? ogame->spawnman : NULL;
        if (!sm || !npc)
            return false;
        for (int k = 0; k < sm->spawnList.GetNum(); k++) {
            oCSpawnManager::oSSpawnNode* node = sm->spawnList[k];
            if (!node || node->npc != npc)
                continue;
            if (FarDist(node->spawnPos, pos) < 300.f)
                return false;
            static CoopDiagBudget budget = { 0, 0 };
            if (CoopDiagAllow(budget, 20))
                FarLog("Spawn-Liste: %s von %.0f/%.0f/%.0f an die Lage des Hosts %.0f/%.0f/%.0f verlegt (%s)",
                    npc->GetObjectName().ToChar(), node->spawnPos.n[0], node->spawnPos.n[1], node->spawnPos.n[2], pos.n[0], pos.n[1],
                    pos.n[2], why);
            node->spawnPos = pos;
            node->timer = 0.f;
            return true;
        }
        return false;
    }

    void CoopFarCountLedInsert() {
        FarLedInsertedSinceLog++;
    }

    // --- Haken auf den Spawn-Manager (Host) -----------------------------------------------------------------------------------

    void __fastcall oCSpawnManager_CheckInsertNpcs_Coop(oCSpawnManager* _this, void* vtable);
    CInvoke<void(__thiscall*)(oCSpawnManager*)> Ivk_oCSpawnManager_CheckInsertNpcs_Coop(CoopAddr::oCSpawnManager_CheckInsertNpcs, &oCSpawnManager_CheckInsertNpcs_Coop,
        COOP_IVK(FarSync));
    void __fastcall oCSpawnManager_CheckInsertNpcs_Coop(oCSpawnManager* _this, void* vtable) {
        const float before = _this->insertTime;
        Ivk_oCSpawnManager_CheckInsertNpcs_Coop(_this);
        if (!_this->spawningEnabled || !(_this->insertTime < before))
            return;   // kein Spawn-Takt in diesem Bild
        try {
            zVEC3 pts[9];
            int n = CoopFollowPoints(pts, 8);
            // v44: Kamera beim Mitspieler - der Spawn-Manager nimmt die Kamera als Mittelpunkt (camVob, +0x36), also den
            // eigenen Helden als weiteren Punkt (CoopCamera.cpp)
            if (CoopCamWatching() && player)
                pts[n++] = player->GetPositionWorld();
            if (n <= 0)
                return;
            const zVEC3 cam = _this->camPos;
            const float ins = oCSpawnManager::GetInsertRange();
            for (int i = 0; i < n; i++) {
                if (FarDist(pts[i], cam) < ins)
                    continue;   // Figur in der Naehe: der normale Durchlauf deckt sie ab
                std::map<oCSpawnManager::oSSpawnNode*, float> timers;
                for (int k = 0; k < _this->spawnList.GetNum(); k++)
                    if (oCSpawnManager::oSSpawnNode* node = _this->spawnList[k])
                        timers[node] = node->timer;
                const int nodesBefore = _this->spawnList.GetNum();
                _this->camPos = pts[i];
                _this->CheckInsertNpc();
                _this->camPos = cam;
                for (int k = 0; k < _this->spawnList.GetNum(); k++) {
                    oCSpawnManager::oSSpawnNode* node = _this->spawnList[k];
                    auto t = node ? timers.find(node) : timers.end();
                    if (t != timers.end())
                        node->timer = t->second;
                }
                if (nodesBefore > _this->spawnList.GetNum())
                    FarInsertedSinceLog += nodesBefore - _this->spawnList.GetNum();
            }
        }
        catch (...) {
            CoopErrorLog("Fern-Abgleich", "Ausnahme", "CheckInsertNpcs");
        }
    }

    int __fastcall oCSpawnManager_CheckRemoveNpc_Coop(oCSpawnManager* _this, void* vtable, oCNpc* npc);
    CInvoke<int(__thiscall*)(oCSpawnManager*, oCNpc*)> Ivk_oCSpawnManager_CheckRemoveNpc_Coop(CoopAddr::oCSpawnManager_CheckRemoveNpc, &oCSpawnManager_CheckRemoveNpc_Coop,
        COOP_IVK(FarSync));
    // u7 (Testlauf u6, Host 341 m entfernt): bis u6 galt das nur fuer lebende NPCs. Toetete der Host einen NPC neben sich, wendete
    // der ferne Client den Tod an (DoDie) und raeumte die Leiche 1 s spaeter weg (Gothic entfernt Tote nach dem Abstand zur eigenen
    // Kamera, ein Wld_InsertNpc-NPC ist dann ganz weg) - beim Host lag sie noch und war pluenderbar. Jetzt bleiben auch Tote im
    // Umkreis einer Figur bzw. des eigenen Helden; entfernt werden sie, wenn niemand mehr in der Naehe ist - wie bei Gothic selbst.
    // Allgemein GT (v41; unter Othello nah beieinander getestet, daher unbemerkt).
    static std::set<oCNpc*> FarKeptDeadLogged;   // je Leiche eine Logzeile (hoechstens 20 je Sitzung)

    int __fastcall oCSpawnManager_CheckRemoveNpc_Coop(oCSpawnManager* _this, void* vtable, oCNpc* npc) {
        // v44: Kamera beim Mitspieler - der Mittelpunkt ist dann die Kamera (camVob, CheckRemoveNpc +0x64); NPCs um den eigenen
        // Helden bleiben trotzdem
        if (npc && npc != player && player && CoopCamWatching() &&
            FarDist(npc->GetPositionWorld(), player->GetPositionWorld()) < oCSpawnManager::GetRemoveRange()) {
            FarKeptSinceLog++;
            return 0;
        }
        if (npc && npc != player && CoopFollowActive()) {
            if (PlayerNpcs.count(npc))
                return 0;   // Figur eines Mitspielers: immer in der Welt lassen
            if (CoopFollowNear(npc->GetPositionWorld(), oCSpawnManager::GetRemoveRange())) {
                FarKeptSinceLog++;
                if (npc->IsDead() && FarKeptDeadLogged.size() < 20 && FarKeptDeadLogged.insert(npc).second) {
                    auto it = NpcToUniqueNameList.find(npc);
                    FarLog("Leiche von %s bleibt in der Welt (im Umkreis eines Mitspielers)",
                        it != NpcToUniqueNameList.end() ? it->second.ToChar() : npc->GetObjectName().ToChar());
                }
                return 0;   // im Umkreis eines Mitspielers: nicht entfernen (u7: auch Tote)
            }
        }
        return Ivk_oCSpawnManager_CheckRemoveNpc_Coop(_this, npc);
    }

    // --- Todesabgleich ---------------------------------------------------------------------------------------------------

    static void FarSendDeaths(const std::vector<std::string>& names, bool all) {
        if (names.empty() && !all)
            return;
        json j;
        j["type"] = SYNC_NPC_DEATH;
        j["id"] = MyselfId.ToChar();
        j["w"] = CoopWorldName();
        j["d"] = names;
        if (all)
            j["all"] = 1;
        CoopTraceCount(TRACE_SENT, SYNC_NPC_DEATH);
        ReadyToSendJsons.enqueue(j);
        FarDeathsSent += (unsigned long)names.size();
    }

    // Host: beim RESYNC eines Clients alle toten benannten NPCs.
    void CoopFarSyncSendAllDead() {
        if (!ServerThread || !ogame || !ogame->GetGameWorld())
            return;
        std::vector<std::string> dead;
        for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l; l = l->next) {
            oCNpc* npc = l->data;
            if (!npc || npc == player || PlayerNpcs.count(npc) || !npc->IsDead())
                continue;
            auto it = NpcToUniqueNameList.find(npc);
            if (it != NpcToUniqueNameList.end())
                dead.push_back(std::string(it->second.ToChar()));
        }
        FarSendDeaths(dead, true);
        FarLog("Host: volle Todesliste an die Clients (%u NPCs)", (unsigned)dead.size());
    }

    static void FarScanDeaths() {
        std::map<oCNpc*, std::string> alive;
        std::vector<std::string> died;
        for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l; l = l->next) {
            oCNpc* npc = l->data;
            if (!npc || npc == player || PlayerNpcs.count(npc))
                continue;
            auto it = NpcToUniqueNameList.find(npc);
            if (it == NpcToUniqueNameList.end())
                continue;
            const std::string name = it->second.ToChar();
            if (!npc->IsDead())
                alive[npc] = name;
            else if (FarScanReady) {
                auto was = FarAlive.find(npc);
                if (was != FarAlive.end() && was->second == name)
                    died.push_back(name);
            }
        }
        FarAlive.swap(alive);
        FarScanReady = true;
        if (!died.empty()) {
            FarSendDeaths(died, false);
            FarLog("%u Tod(e) gemeldet (z. B. %s)%s", (unsigned)died.size(), died[0].c_str(),
                ServerThread ? "" : " - Client ohne Host in seiner Welt, fuer den Weltprozess des Hosts (u46)");
        }
    }

    bool CoopWpMirrorSendOn();   // u46: CoopWorldProcess.cpp - Client ohne Host in seiner Welt sendet seine NPCs
    bool CoopWpMirroring();      // u46: CoopWorldProcess.cpp - Weltprozess spiegelt gerade die Welt eines Mitspielers
    static bool FarAloneWas = false;

    // u40 (C23; Test u39, Host-Lauf Schritt 72 "Test-NPC toeten + EP-Regel": Partner-EP 40 -> 40, Abstand 9 m bei 20 m EP-Reichweite):
    // die Todesmeldung des Hosts (FarScanDeaths, gleich im Bild des Kills) wurde beim Client sofort beim Empfang angewendet - ohne EP
    // (CoopKillNoXp). Der nachgespielte toedliche Treffer des Hosts (RemoteNpc::UpdateAttacks, mit EP-Anteil Partner) kam im selben
    // Bild erst danach und fand den NPC schon tot. Bisher ging es meist gut, weil der Treffer ein Bild frueher ankam; hier fuehrte der
    // Client den Molerat (Kampf-Uebergabe). Jetzt: NPCs, die hier in der Welt stehen, erst 1 s nach der Meldung toeten - kommt der
    // Treffer, toetet er mit EP und die Meldung entfaellt (schon tot). Fern (nicht in der Welt): sofort, wie bisher. Allgemein.
    static void FarApplyPending() {
        const long long now = GetCurrentMs();
        for (auto it = FarPending.begin(); it != FarPending.end();) {
            auto n = UniqueNameToNpcList.find(string(it->first.c_str()));
            oCNpc* npc = n != UniqueNameToNpcList.end() ? n->second : NULL;
            if (npc && npc->IsDead()) {
                FarPendingAt.erase(it->first);
                it = FarPending.erase(it);
                continue;
            }
            auto at = FarPendingAt.find(it->first);
            if (npc && FarActiveInWorld(npc) && at != FarPendingAt.end() && now < at->second + 1000) {
                ++it;   // u40: dem nachgespielten Treffer (mit EP) den Vortritt lassen
                continue;
            }
            if (npc && !IsPlayerTalkingWithNpc(npc)) {
                CoopKillNoXp(npc, NULL, "vom Host gemeldet");
                FarPendingAt.erase(it->first);
                it = FarPending.erase(it);
                continue;
            }
            if (now > it->second) {
                FarLog("Client: gemeldeten Tod von %s nicht angewendet (%s)", it->first.c_str(), npc ? "Dialog" : "hier unbekannt");
                FarPendingAt.erase(it->first);
                it = FarPending.erase(it);
                continue;
            }
            ++it;
        }
    }

    // u151 (P155): Falsche Tote aus Staenden von vor P153. Auswertung der Testlaeufe (Othello, u149): MEATBUG-OW_PATH_MOUNTAINS_05-1 lebt beim Host, beim Client ist er tot, die Pakete des Hosts
    // schieben die Leiche. Die Todesliste des Hosts sagt nur "tot", nie "lebt", so blieb das in jedem weiteren Stand. Jetzt fragt der Client nach der vollen Liste fuer seine Toten, die nicht
    // darauf stehen, und der Host nennt, wer bei ihm lebt: Er fuehrt die Welt. Steht der NPC nicht in der Welt, reichen die Leben (CheckInsertNpc setzt ihn dann ein). Eine Leiche geht den Weg
    // des Spawn-Managers (Disable, SpawnNpc), Enable setzt dabei die Animationen zurueck. Allgemein.
    static void FarRevive(oCNpc* npc, const std::string& name, const char* why) {
        const bool active = FarActiveInWorld(npc);
        const int hpMax = npc->GetAttribute(NPC_ATR_HITPOINTSMAX);
        const zVEC3 pos = npc->GetPositionWorld();
        if (active)
            npc->Disable();
        npc->state.ClearAIState();
        npc->ClearEM();
        npc->SetAttribute(NPC_ATR_HITPOINTS, hpMax > 0 ? hpMax : 1);
        npc->SetBodyState(BS_STAND);
        if (!CoopSpawnListHas(npc) && ogame->spawnman)
            ogame->spawnman->SpawnNpc(npc, pos, 0.f);
        FarKnownDead.erase(name);
        FarPending.erase(name);
        FarPendingAt.erase(name);
        KilledByPlayerNpcNames.erase(string(name.c_str()));
        static CoopDiagBudget budget = { 0, 0 };
        if (CoopDiagAllow(budget, 40))
            FarLog("Client: %s %s - wieder lebendig (%s)", name.c_str(), why, active ? "Leiche in der Welt" : "nicht in der Welt");
    }

    // u152 (P157): Leiche mit Leben. Testlauf Othello, u146 bis u151: ORG_825_ORGANISATOR-1 lag beim Client in ZS_DEAD (Koerperzustand 23), die HP-Pakete des Hosts gaben ihm Leben zurueck
    // (RemoteNpc::UpdateHp), also galt er nicht als tot, und die Nachfrage aus P155 erfasste ihn nicht; die Lage-Pakete schoben die Leiche in jeder Sitzung. Steht ein NPC des Hosts hier 10 s mit
    // Leben im Todeszustand, steht er auf wie in P155. Die Wartezeit laesst einem gerade getoeteten NPC Zeit fuer die Todesmeldung des Hosts. Allgemein.
    static std::map<oCNpc*, long long> FarZombieSince;

    static void FarZombieScan() {
        if (!ClientThread || ServerThread || CoopWpMirroring() || !ogame || !ogame->GetGameWorld())
            return;
        const long long now = GetCurrentMs();
        std::map<oCNpc*, long long> seen;
        std::vector<std::pair<oCNpc*, std::string>> todo;
        for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l; l = l->next) {
            oCNpc* npc = l->data;
            // Koerperzustand tot oder KI noch in ZS_DEAD: Spielt das Paket des Hosts eine Laufanimation, steht der Koerperzustand wieder auf 0 (Testschritt), die KI bleibt tot
            if (!npc || npc == player || PlayerNpcs.count(npc) || npc->IsDead() ||
                (npc->GetBodyState() != BS_DEAD && strcmp(npc->state.curState.name.ToChar(), "ZS_DEAD") != 0))
                continue;
            auto it = NpcToUniqueNameList.find(npc);
            if (it == NpcToUniqueNameList.end())
                continue;
            auto was = FarZombieSince.find(npc);
            const long long since = was != FarZombieSince.end() ? was->second : now;
            if (now - since >= 10000)
                todo.push_back({ npc, std::string(it->second.ToChar()) });
            else
                seen[npc] = since;
        }
        FarZombieSince.swap(seen);
        for (auto& t : todo)
            FarRevive(t.first, t.second, "liegt mit Leben als Leiche da");
    }

    // Client: nach der vollen Todesliste die eigenen Toten, die nicht darauf stehen
    void CoopFarHealAsk() {
        if (!ClientThread || ServerThread || !ogame || !ogame->GetGameWorld())
            return;
        std::vector<std::string> names;
        for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l; l = l->next) {
            oCNpc* npc = l->data;
            if (!npc || npc == player || PlayerNpcs.count(npc) || !npc->IsDead())
                continue;
            auto it = NpcToUniqueNameList.find(npc);
            if (it != NpcToUniqueNameList.end() && !FarKnownDead.count(it->second.ToChar()))
                names.push_back(std::string(it->second.ToChar()));
        }
        if (names.empty())
            return;
        json j;
        j["type"] = SYNC_NPC_DEATH;
        j["id"] = MyselfId.ToChar();
        j["w"] = CoopWorldName();
        j["ask"] = names;
        CoopTraceCount(TRACE_SENT, SYNC_NPC_DEATH);
        ReadyToSendJsons.enqueue(j);
        FarLog("Client: %u Tote hier stehen nicht auf der Liste des Hosts - frage nach", (unsigned)names.size());
    }

    // Host: welche davon leben hier? Die Weltliste statt der Namensliste: Dort kann noch ein Zeiger auf einen weggeraeumten NPC stehen
    static void FarHealAnswer(json& e) {
        const std::string w = e.contains("w") && e["w"].is_string() ? e["w"].get<std::string>() : std::string();
        if (w != CoopWorldName() || !e["ask"].is_array() || !ogame || !ogame->GetGameWorld())
            return;
        std::set<std::string> asked;
        for (auto& d : e["ask"])
            if (d.is_string())
                asked.insert(d.get<std::string>());
        std::vector<std::string> alive;
        for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l; l = l->next) {
            oCNpc* npc = l->data;
            if (!npc || npc->IsDead())
                continue;
            auto it = NpcToUniqueNameList.find(npc);
            if (it != NpcToUniqueNameList.end() && asked.count(it->second.ToChar()))
                alive.push_back(std::string(it->second.ToChar()));
        }
        FarLog("Host: Client fragt nach %u Toten, %u leben hier", (unsigned)asked.size(), (unsigned)alive.size());
        if (alive.empty())
            return;
        json j;
        j["type"] = SYNC_NPC_DEATH;
        j["id"] = MyselfId.ToChar();
        j["w"] = w;
        j["alive"] = alive;
        CoopTraceCount(TRACE_SENT, SYNC_NPC_DEATH);
        ReadyToSendJsons.enqueue(j);
    }

    static void FarHealApply(json& e) {
        if (!e["alive"].is_array() || !ogame || !ogame->GetGameWorld())
            return;
        std::set<std::string> alive;
        for (auto& d : e["alive"])
            if (d.is_string())
                alive.insert(d.get<std::string>());
        std::vector<std::pair<oCNpc*, std::string>> todo;
        for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l; l = l->next) {
            oCNpc* npc = l->data;
            if (!npc || npc == player || PlayerNpcs.count(npc) || !npc->IsDead())
                continue;
            auto it = NpcToUniqueNameList.find(npc);
            if (it != NpcToUniqueNameList.end() && alive.count(it->second.ToChar()))
                todo.push_back({ npc, std::string(it->second.ToChar()) });
        }
        for (auto& t : todo)
            FarRevive(t.first, t.second, "lebt beim Host - hier tot");
    }

    void CoopFarSyncReceive(json& e, const std::string& id) {
        CoopTraceCount(TRACE_RECV, SYNC_NPC_DEATH);
        if (e.contains("ask")) {   // u151 (P155)
            if (ServerThread && !IsLoadingLevel)
                FarHealAnswer(e);
            return;
        }
        if (ServerThread || (!ClientThread && !CoopWpMirroring()) || IsLoadingLevel)
            return;   // der Host (bzw. ein Client allein in seiner Welt) meldet; Clients und der Weltprozess (u46) wenden an
        const std::string w = e.contains("w") && e["w"].is_string() ? e["w"].get<std::string>() : std::string();
        if (w != CoopWorldName())
            return;
        if (e.contains("alive")) {   // u151 (P155)
            if (!CoopWpMirroring())
                FarHealApply(e);
            return;
        }
        if (!e.contains("d") || !e["d"].is_array())
            return;
        const long long until = GetCurrentMs() + 15000;
        int n = 0;
        for (auto& d : e["d"]) {
            if (!d.is_string())
                continue;
            const std::string name = d.get<std::string>();
            FarKnownDead.insert(name);
            FarPending[name] = until;
            if (!FarPendingAt.count(name))
                FarPendingAt[name] = GetCurrentMs();   // u40
            n++;
        }
        FarApplyPending();
        if (!e.contains("all") || n)
            FarLog("Client: %d Tod(e) vom Host%s", n, e.contains("all") ? " (volle Liste)" : "");
        if (e.contains("all") && !CoopWpMirroring())   // u151 (P155)
            CoopFarHealAsk();
    }

    // Gerade abgeglichen? Host: wird gesendet. Client: vom Host gefuehrt (RemoteNpc mit Modell) - sonst sperrt der
    // StartAni-Haken (Hooks.cpp) beim Client jede eigene Animation, der NPC steht dann still.
    static bool FarIsLed(oCNpc* npc) {
        auto nm = NpcToUniqueNameList.find(npc);
        if (nm == NpcToUniqueNameList.end())
            return false;
        if (ServerThread)
            return BroadcastNpcs.count(nm->second) != 0;
        auto it = SyncNpcs.find(nm->second);
        return it != SyncNpcs.end() && it->second && !it->second->destroyed && it->second->hasModel;
    }

    // Aktive NPCs um c: wie viele, wie viele seit dem letzten Bericht bewegt (> 50 cm), wie viele ohne Abgleich.
    static void FarProbe(const zVEC3& c, std::map<oCNpc*, zVEC3>& last, int& active, int& moved, int& notLed) {
        active = moved = notLed = 0;
        std::map<oCNpc*, zVEC3> probe;
        for (auto* l = CoopWorldNpcListFirst(ogame->GetGameWorld()); l; l = l->next) {
            oCNpc* npc = l->data;
            if (!npc || npc == player || PlayerNpcs.count(npc) || npc->vobLeafList.GetNum() == 0 || npc->IsDead())
                continue;
            const zVEC3 p = npc->GetPositionWorld();
            if (FarDist(p, c) >= (float)BROADCAST_DISTANCE)
                continue;
            active++;
            auto was = last.find(npc);
            if (was != last.end() && FarDist(was->second, p) > 50.f)
                moved++;
            if (!FarIsLed(npc))
                notLed++;
            probe[npc] = p;
        }
        last.swap(probe);
    }

    static void FarReport() {
        if (!CoopFollowActive())
            return;
        zVEC3 pts[8];
        const int n = CoopFollowPoints(pts, 8);
        const zVEC3 me = player->GetPositionWorld();
        int meAct = 0, meMoved = 0, meNotLed = 0;   // v43: Vergleichswert um den eigenen Helden
        FarProbe(me, FarMoveProbeMe, meAct, meMoved, meNotLed);
        for (int i = 0; i < n; i++) {
            const float d = FarDist(pts[i], me);
            int active = 0, moved = 0, notLed = 0;
            FarProbe(pts[i], FarMoveProbe, active, moved, notLed);
            int synced = 0;   // Client: vom Host gefuehrte NPCs (RemoteNpc) - auch um die Host-Figur
            for (auto& s : SyncNpcs)
                if (s.second && !s.second->destroyed && s.second->hasModel)
                    synced++;
            FarLog("Verfolgungspunkt %d bei %.0f/%.0f/%.0f, %.0f m von mir - %d NPCs aktiv in seinem Umkreis, %d davon bewegt seit dem"
                " letzten Bericht, %d ohne Abgleich (%s); bei mir %d aktiv, %d bewegt, %d ohne Abgleich; eingesetzt %lu, behalten %lu,"
                " vom Host gefuehrte nachgesetzt %lu; gesendet %u, vom Host gefuehrt %d NPCs; Tode gemeldet %lu, angewendet %lu",
                i + 1, pts[i].n[0], pts[i].n[1], pts[i].n[2], d / 100.f, active, moved, notLed,
                ServerThread ? "nicht gesendet" : "nicht vom Host gefuehrt - stehen hier still", meAct, meMoved, meNotLed,
                FarInsertedSinceLog, FarKeptSinceLog, FarLedInsertedSinceLog, (unsigned)BroadcastNpcs.size(), synced,
                FarDeathsSent, FarDeathsApplied);
        }
        FarInsertedSinceLog = FarKeptSinceLog = FarLedInsertedSinceLog = 0;
    }

    // Aus Game_Loop (nach BuildGlobalNpcList).
    void CoopFarSyncPulse() {
        FarReadConfig();
        if (!(ServerThread || ClientThread) || IsLoadingLevel || !player || !ogame || !ogame->GetGameWorld() || MyselfId == "_player_")
            return;
        const long long now = GetCurrentMs();
        if (now >= FarNextScanMs) {
            FarNextScanMs = now + 1000;
            // u46: ein Client ohne Host in seiner Welt meldet die Tode dort (fuer den Weltprozess des Hosts); beim Wechsel neu aufsetzen
            const bool alone = !ServerThread && CoopWpMirrorSendOn();
            if (alone != FarAloneWas) {
                FarAloneWas = alone;
                FarAlive.clear();
                FarScanReady = false;
            }
            if (ServerThread || alone)
                FarScanDeaths();
            else {
                if (!FarPending.empty())
                    FarApplyPending();
                FarZombieScan();   // u152 (P157)
            }
        }
        if (now >= FarNextLogMs) {
            FarNextLogMs = now + 30000;
            if (!PlayerNpcs.empty())
                FarReport();
        }
    }

    // u46: Weltprozess (CoopWorldProcess.cpp, statt Game_Loop) - gemeldete Tode der gespiegelten Welt nachtragen
    void CoopFarSyncMirrorPulse() {
        static long long next = 0;
        const long long now = GetCurrentMs();
        if (now < next || IsLoadingLevel || !player || !ogame || FarPending.empty())
            return;
        next = now + 1000;
        FarApplyPending();
    }

    // Aus LoadEnd: neue Welt.
    void CoopFarSyncWorldLoaded() {
        FarAlive.clear();
        FarScanReady = false;
        FarKnownDead.clear();
        FarPending.clear();
        FarPendingAt.clear();   // u40
        FarMoveProbe.clear();
        FarMoveProbeMe.clear();
        FarZombieSince.clear();   // u152 (P157)
    }

#else   // Modul in dieser Engine nicht freigegeben (CoopModulesReport)
    bool CoopFollowActive() { return false; }
    int CoopFollowPoints(zVEC3*, int) { return 0; }
    bool CoopFollowNear(const zVEC3&, float) { return false; }
    bool CoopFarFromMe(oCNpc*) { return false; }
    bool CoopSpawnInsertAt(oCNpc*, const zVEC3&) { return false; }
    void CoopKillNoXp(oCNpc* npc, oCNpc*, const char*) { if (npc) npc->SetAttribute(NPC_ATR_HITPOINTS, 0); }
    bool CoopFarKnownDead(const std::string&) { return false; }
    bool CoopSpawnListHas(oCNpc*) { return false; }
    bool CoopSpawnListPos(oCNpc*, zVEC3&) { return false; }
    bool CoopSpawnListMove(oCNpc*, const zVEC3&, const char*) { return false; }
    void CoopFarCountLedInsert() {}
    void CoopFarSyncSendAllDead() {}
    void CoopFarHealAsk() {}   // u151
    void CoopFarSyncReceive(json&, const std::string&) {}
    void CoopFarSyncPulse() {}
    void CoopFarSyncMirrorPulse() {}
    void CoopFarSyncWorldLoaded() {}
#endif
}
