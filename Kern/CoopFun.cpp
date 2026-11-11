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

    // u203b (Nutzer: "wenn man stirbt soll man nach 30 sec in der basis wieder spawnen"): Tod des eigenen Helden im Fun-Spiel -
    // nach 30 s wieder aufstehen (volle Lebenspunkte, wie die Coop-Wiederbelebung RemoteNpc::UpdateRevived) am Startpunkt des
    // eigenen Lagers. Bewusstlos (Nahkampf zwischen Menschen) bleibt wie im Spiel.
    static long long CoopFunDeadSince = 0;
    static int CoopFunDeadShown = -1;

    static const char* CoopFunBaseWp(int guild) {
        switch (guild) {
        case 2: return "NW_CITY_HABOUR_KASERN_CENTRE_01";    // GIL_MIL
        case 7: return "NW_BIGFARM_HOUSE_OUT_05";            // GIL_SLD
        case 5: return "NW_MONASTERY_PLACE_03";              // GIL_NOV
        case 9: return "NW_CASTLEMINE_TOWER_CAMPFIRE_01";    // GIL_BDT
        default: return NULL;
        }
    }

    static void CoopFunPrint(const char* text) {
        if (!screen)
            return;
        zCOLOR col(255, 220, 120, 255);
        screen->PrintTimedCX(2600, zSTRING(text), 4500.0f, &col);
    }

    static void CoopFunRespawnPulse(long long now) {
        if (!player->IsDead()) {
            CoopFunDeadSince = 0;
            CoopFunDeadShown = -1;
            return;
        }
        if (!CoopFunDeadSince) {
            CoopFunDeadSince = now;
            FunLog("eigener Held tot - Wiederbeleben im Lager in 30 s");
        }
        const int left = 30 - (int)((now - CoopFunDeadSince) / 1000);
        if (left > 0) {
            const int step = left > 5 ? (left + 4) / 5 * 5 : left;   // 30, 25, ... 10, 5, 4, 3, 2, 1
            if (step != CoopFunDeadShown) {
                CoopFunDeadShown = step;
                char b[120];
                _snprintf(b, sizeof(b), "Du bist gefallen - in %d Sekunden stehst du im Lager wieder auf.", left);
                b[sizeof(b) - 1] = 0;
                CoopFunPrint(b);
            }
            return;
        }
        CoopFunDeadSince = 0;
        CoopFunDeadShown = -1;
        zVEC3 pos = player->GetPositionWorld();
        const char* wpName = CoopFunBaseWp(player->guild);
        zCWorld* w = ogame->GetGameWorld();
        zCWaypoint* wp = (wpName && w && w->wayNet) ? w->wayNet->GetWaypoint(zSTRING(wpName)) : NULL;
        if (wp)
            pos = wp->GetPositionWorld();
        player->StopFaceAni("T_HURT");
        player->SetWeaponMode2(NPC_WEAPON_NONE);
        player->SetAttribute(NPC_ATR_HITPOINTS, player->GetAttribute(NPC_ATR_HITPOINTSMAX));
        CoopResetPosSafe(player, pos);
        player->SetBodyState(0);   // BS_STAND
        FunCall("FUN_HELD_NACH_TOD");   // Startwerte (u203d)
        player->SetAttribute(NPC_ATR_HITPOINTS, player->GetAttribute(NPC_ATR_HITPOINTSMAX));
        CoopFunPrint("Du bist wieder im Lager.");
        FunLog("Held wiederbelebt bei %s", wp ? wpName : "der Leiche (kein Lager-Wegpunkt)");
    }

    // --- u203d (Nutzer: "fuege freies zielen mit bogen und armbrust hinzu, die reichweite fuer bogen und armbrust soll 150m gehen
    // eventuell durch mehr geschick noch weiter"): im Fun-Spiel fliegt der Pfeil/Bolzen des eigenen Helden dorthin, wohin die Kamera
    // blickt (Fadenkreuz in der Bildmitte), statt zum anvisierten Ziel. Reichweite 150 m, ab Geschick 30 je Punkt 1 m mehr (hoechstens
    // 300 m). Der Schuss selbst bleibt Gothics (Munition, Animation, Schaden beim Aufprall); nur Richtung, Tempo und Flugzeit des
    // Geschosses werden nach oCNpc::DoShootArrow gesetzt (CoopWorldSync.cpp merkt das Geschoss in oCAIArrow::SetupAIVob).
    static float CoopFunRangedRange() {
        int dex = player ? player->GetAttribute(NPC_ATR_DEXTERITY) : 30;
        float r = 15000.0f + (dex > 30 ? (float)(dex - 30) * 100.0f : 0.0f);
        return r > 30000.0f ? 30000.0f : r;
    }

    static bool CoopFunAiming() {
        return player && (player->fmode == 5 || player->fmode == 6);   // Bogen / Armbrust gezogen
    }

    void CoopFunFreeAim(oCItem* arrow, oCAIArrow* ai) {
#if ENGINE == Engine_G2A
        static int logged = 0;
        if (!arrow || !player || !CoopFunActive() || !ogame || !zCCamera::activeCam || !zCCamera::activeCam->connectedVob)
            return;
        zCVob* cam = zCCamera::activeCam->connectedVob;
        zVEC3 from = cam->GetPositionWorld();
        zVEC3 dir = cam->GetAtVectorWorld();
        const float dl = sqrtf(dir.n[0] * dir.n[0] + dir.n[1] * dir.n[1] + dir.n[2] * dir.n[2]);
        if (dl < 0.001f)
            return;
        dir.n[0] /= dl; dir.n[1] /= dl; dir.n[2] /= dl;
        const float range = CoopFunRangedRange();
        zVEC3 ray(dir.n[0] * range, dir.n[1] * range, dir.n[2] * range);
        zVEC3 target(from.n[0] + ray.n[0], from.n[1] + ray.n[1], from.n[2] + ray.n[2]);
        zCVob* hitVob = NULL;
        // u203f: kein Erfassen mehr - immer zum Fadenkreuz (Nutzer: "ich ziele selber")
        if (zCWorld* w = ogame->GetGameWorld()) {
            // Strahl ab der Kamera; Held und Geschoss ignorieren (der Held steht vor der Kamera)
            const int flags = zTRACERAY_STAT_POLY | zTRACERAY_VOB_BBOX | zTRACERAY_VOB_IGNORE_NO_CD_DYN | zTRACERAY_POLY_IGNORE_TRANSP;
            zVEC3 f2(from.n[0] + dir.n[0] * 150.0f, from.n[1] + dir.n[1] * 150.0f, from.n[2] + dir.n[2] * 150.0f);
            if (w->TraceRayNearestHit(f2, ray, (zCVob*)player, flags) && w->traceRayReport.foundHit) {
                target = w->traceRayReport.foundIntersection;
                hitVob = w->traceRayReport.foundVob;
                if (hitVob == arrow)
                    hitVob = NULL;
            }
        }
        zVEC3 start = arrow->GetPositionWorld();
        zVEC3 d(target.n[0] - start.n[0], target.n[1] - start.n[1], target.n[2] - start.n[2]);
        const float len = sqrtf(d.n[0] * d.n[0] + d.n[1] * d.n[1] + d.n[2] * d.n[2]);
        if (len < 1.0f)
            return;
        d.n[0] /= len; d.n[1] /= len; d.n[2] /= len;
        float speed = 0.0f;
        zCRigidBody* rb = arrow->GetRigidBody();
        if (rb)
            speed = sqrtf(rb->v.n[0] * rb->v.n[0] + rb->v.n[1] * rb->v.n[1] + rb->v.n[2] * rb->v.n[2]);
        if (speed < 6000.0f)
            speed = 6000.0f;   // 60 m/s - 150 m in 2,5 s
        arrow->SetHeadingAtWorld(d);
        if (rb) {
            rb->gravityOn = FALSE;   // gerade Flugbahn bis zur Reichweite
            rb->SetVelocity(zVEC3(d.n[0] * speed, d.n[1] * speed, d.n[2] * speed));
        }
        if (ai) {
            const float t = range / speed + 0.5f;
            if (ai->timeLeft < t)
                ai->timeLeft = t;
            oCNpc* hitNpc = hitVob ? zDYNAMIC_CAST<oCNpc>(hitVob) : NULL;
            ai->targetNPC = hitNpc;   // Ziel nur, wenn das Fadenkreuz auf einem NPC liegt
        }
        if (logged++ < 30)
            FunLog("freies Zielen: Schuss auf %.0f m (Reichweite %.0f m, Tempo %.0f m/s)%s%s", len / 100.0f, range / 100.0f, speed / 100.0f,
                hitVob ? " - Treffer auf " : "", hitVob ? hitVob->GetObjectName().ToChar() : "");
#endif
    }

    // --- u203f (Nutzer: "das mit anvisieren meinte, dass ich ihn selber anvisiere, er soll nicht automatisch anvisieren, und das
    // freie Bewegen beim Zielen geht nicht - kannst du einstellen, dass man mit Rechtsklick zielt und Linksklick schiesst?"):
    // Solange im Fun-Spiel Bogen oder Armbrust gezogen sind, legt GT die Tasten um (zCInput::Bind; beim Wegstecken, Laden und
    // ausserhalb des Fun-Spiels wieder Gothics Belegung):
    //  - rechte Maustaste = Gothics Aktionstaste (gedrueckt halten = zielen), linke Maustaste = "vor" (im Zielen: Schuss) - in
    //    Gothic schiesst "Aktion halten + vor". Die linke Maustaste ist dabei keine Aktionstaste mehr; die rechte loest sonst nichts aus.
    //  - Kein automatisches Erfassen: Reichweite der Fernkampf-Zielerfassung (Focus_Ranged) 0 - der Pfeil fliegt zum Fadenkreuz.
    //  - Waehrend die rechte Maustaste gehalten wird, gehoeren die Lauftasten (vor/zurueck/links/rechts/seitwaerts, Tastatur) nicht
    //    Gothic: GT schiebt den Helden damit (vor 1,8 m/s, sonst 1,4 m/s; Waende halten auf, Boden wird nachgefuehrt, Stufen bis
    //    60 cm). Drehen mit der Maus wie sonst.
    static const int FUN_BIND_MAX = 40;
    static std::vector<unsigned short> FunBindOrig[FUN_BIND_MAX];
    static int FunBindMode = 0;   // 0 Gothic, 1 Bogen gezogen, 2 Bogen + rechte Maustaste
    static float FunFocusOrig = -1.0f;

    static bool FunIsMoveKey(int l) {
        return l == GAME_UP || l == GAME_DOWN || l == GAME_LEFT || l == GAME_RIGHT || l == GAME_STRAFELEFT || l == GAME_STRAFERIGHT;
    }

    static void FunBindApply(int mode) {
#if ENGINE == Engine_G2A
        if (!zinput || mode == FunBindMode)
            return;
        if (FunBindMode == 0) {   // Gothics Belegung merken
            for (int l = 1; l < FUN_BIND_MAX; l++) {
                zCArray<unsigned short> a;
                zinput->GetBinding((unsigned short)l, a);
                FunBindOrig[l].clear();
                for (int i = 0; i < a.GetNum(); i++)
                    FunBindOrig[l].push_back(a[i]);
            }
        }
        for (int l = 1; l < FUN_BIND_MAX; l++) {
            zCArray<unsigned short> a;
            for (unsigned short c : FunBindOrig[l]) {
                if (mode == 0) {
                    a.Insert(c);
                    continue;
                }
                if (c == MOUSE_BUTTONLEFT || c == MOUSE_BUTTONRIGHT)
                    continue;
                if (mode == 2 && FunIsMoveKey(l) && c < MIN_MOUSE_BTNS_AND_CODES)
                    continue;   // Lauftasten schiebt GT
                a.Insert(c);
            }
            if (mode != 0 && l == GAME_ACTION)
                a.Insert(MOUSE_BUTTONRIGHT);
            if (mode != 0 && l == GAME_UP)
                a.Insert(MOUSE_BUTTONLEFT);
            zinput->Bind((unsigned short)l, a);
        }
        FunLog("Tasten: %s", mode == 0 ? "Gothics Belegung" : mode == 1 ? "Bogen gezogen (rechts = zielen, links = schiessen)"
            : "Zielen - Lauftasten bewegen");
        FunBindMode = mode;
#endif
    }

    // u203-fun7: Zielerfassung nur ueber oCNpcFocus::focus (aktueller Modus, Zeiger-Variable). fun6 las oCNpcFocus::focuslist
    // jedes Bild - das ist in Gothic ein Feld, kein Zeiger: Zugriffsfehler in GameLoop_End. Jetzt nur bei Zustandswechsel,
    // nur solange der Bogen gezogen ist (dann ist focus der Fernkampf-Modus), abgesichert gegen Zugriffsfehler.
    static oCNpcFocus* FunFocusObj = NULL;
    static bool FunFocusIsOff = false;

    static bool FunFocusSet(oCNpcFocus* f, float v, float* old) {
        __try {
            if (old)
                *old = f->n_range2;
            f->n_range2 = v;
            return true;
        }
        __except (EXCEPTION_EXECUTE_HANDLER) {
            return false;
        }
    }

    static void CoopFunFocusOff(bool off) {
#if ENGINE == Engine_G2A
        if (off == FunFocusIsOff)
            return;
        if (off) {
            oCNpcFocus* f = oCNpcFocus::focus;
            if (!f)
                return;
            float old = 0.0f;
            if (!FunFocusSet(f, 1.0f, &old)) {
                FunLog("Zielerfassung: Zugriff fehlgeschlagen - bleibt an");
                FunFocusIsOff = true;   // nicht jedes Bild neu versuchen
                FunFocusObj = NULL;
                return;
            }
            FunFocusObj = f;
            FunFocusOrig = old > 1.0f ? old : 3500.0f;
            FunFocusIsOff = true;
            FunLog("Zielerfassung aus (vorher %.0f cm)", FunFocusOrig);
        }
        else {
            if (FunFocusObj && FunFocusOrig > 1.0f)
                FunFocusSet(FunFocusObj, FunFocusOrig, NULL);
            FunFocusObj = NULL;
            FunFocusIsOff = false;
        }
#endif
    }

    // Beim Laden/Weltwechsel und ohne Fun-Spiel: Gothics Belegung und Zielerfassung zurueck
    void CoopFunInputRestore() {
        FunBindApply(0);
        CoopFunFocusOff(false);
    }

    static bool FunKeyHeld(int l) {
        for (unsigned short c : FunBindOrig[l])
            if (c < MIN_MOUSE_BTNS_AND_CODES && zinput->KeyPressed(c))
                return true;
        return false;
    }

    static bool CoopFunAimHeld() {
        return FunBindMode == 2;
    }

    static void CoopFunAimMove() {
#if ENGINE == Engine_G2A
        if (FunBindMode != 2 || !zinput || !ztimer || !ogame)
            return;
        float fwd = 0.0f, side = 0.0f;
        if (FunKeyHeld(GAME_UP))
            fwd += 1.0f;
        if (FunKeyHeld(GAME_DOWN))
            fwd -= 1.0f;
        if (FunKeyHeld(GAME_STRAFELEFT) || FunKeyHeld(GAME_LEFT))
            side -= 1.0f;
        if (FunKeyHeld(GAME_STRAFERIGHT) || FunKeyHeld(GAME_RIGHT))
            side += 1.0f;
        if (fwd == 0.0f && side == 0.0f)
            return;
        float dt = ztimer->frameTimeFloat / 1000.0f;
        if (dt <= 0.0f)
            return;
        if (dt > 0.1f)
            dt = 0.1f;
        zCWorld* w = ogame->GetGameWorld();
        if (!w)
            return;
        zVEC3 at = player->GetAtVectorWorld();
        zVEC3 rt = player->GetRightVectorWorld();
        zVEC3 mv(at.n[0] * fwd + rt.n[0] * side, 0.0f, at.n[2] * fwd + rt.n[2] * side);
        const float ml = sqrtf(mv.n[0] * mv.n[0] + mv.n[2] * mv.n[2]);
        if (ml < 0.001f)
            return;
        const float speed = fwd > 0.0f && side == 0.0f ? 180.0f : 140.0f;
        const float ux = mv.n[0] / ml, uz = mv.n[2] / ml;
        mv.n[0] = ux * speed * dt;
        mv.n[2] = uz * speed * dt;
        const int flags = zTRACERAY_STAT_POLY | zTRACERAY_VOB_IGNORE | zTRACERAY_POLY_IGNORE_TRANSP;
        const zVEC3 pos = player->GetPositionWorld();
        static int logged = 0;
        const zVEC3 chest(pos.n[0], pos.n[1] + 40.0f, pos.n[2]);
        const zVEC3 probe(ux * 40.0f + mv.n[0], 0.0f, uz * 40.0f + mv.n[2]);
        if (w->TraceRayNearestHit(chest, probe, (zCVob*)player, flags) && w->traceRayReport.foundHit) {
            if (logged++ < 10)
                FunLog("Zielen: Wand voraus - stehen bleiben");
            return;
        }
        const zVEC3 down(0.0f, -500.0f, 0.0f);
        const zVEC3 top0(pos.n[0], pos.n[1] + 60.0f, pos.n[2]);
        const zVEC3 top1(pos.n[0] + mv.n[0], pos.n[1] + 60.0f, pos.n[2] + mv.n[2]);
        float floor0 = 0.0f, floor1 = 0.0f;
        const bool f0 = w->TraceRayNearestHit(top0, down, (zCVob*)player, flags) && w->traceRayReport.foundHit;
        if (f0)
            floor0 = w->traceRayReport.foundIntersection.n[1];
        const bool f1 = w->TraceRayNearestHit(top1, down, (zCVob*)player, flags) && w->traceRayReport.foundHit;
        if (f1)
            floor1 = w->traceRayReport.foundIntersection.n[1];
        float dy = 0.0f;
        if (f0 && f1) {
            dy = floor1 - floor0;
            if (dy > 60.0f || dy < -150.0f) {
                if (logged++ < 10)
                    FunLog("Zielen: Stufe %.0f cm - stehen bleiben", dy);
                return;
            }
        }
        player->SetPositionWorld(zVEC3(pos.n[0] + mv.n[0], pos.n[1] + dy, pos.n[2] + mv.n[2]));
        if (logged++ < 10)
            FunLog("Zielen: bewegt um %.0f/%.0f cm (Boden %s)", mv.n[0], mv.n[2], f0 && f1 ? "gefunden" : "nicht gefunden");
#endif
    }

    // Jedes Bild: Belegung nach Zustand (Bogen gezogen? rechte Maustaste?), Zielerfassung aus
    static void CoopFunRangedControls(bool active) {
#if ENGINE == Engine_G2A
        const bool bow = active && player && !player->IsDead() && CoopFunAiming() && !player->inventory2.IsOpen();
        int mode = 0;
        if (bow)
            mode = zinput && zinput->GetMouseButtonPressedRight() ? 2 : 1;
        FunBindApply(mode);
        CoopFunFocusOff(bow);
#endif
    }

    // Fadenkreuz in der Bildmitte, solange Bogen oder Armbrust gezogen sind
    static void CoopFunCrosshair() {
        if (!screen || !CoopFunAiming() || !CoopFunAimHeld())
            return;
        static zSTRING plus("+");
        const int w = screen->FontSize(plus);
        const int h = screen->FontY();
        screen->Print(4096 - w / 2, 4096 - h / 2, plus);
    }

    // --- u203d (Nutzer: "nach dem man stirbt und respawn sollten staerke etc. zurueckgesetzt werden" - gewaehlt: auf Startwerte,
    // ausgegebene Lernpunkte verloren): COOP_FUN.D FUN_HELD_NACH_TOD setzt Staerke, Geschick, Leben und Mana auf die Startwerte.

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
        if (!active) {
            CoopFunRangedControls(false);
            return;
        }
        const long long now = GetCurrentMs();
        CoopFunRespawnPulse(now);
        CoopFunRangedControls(true);
        CoopFunAimMove();
        CoopFunCrosshair();
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
        CoopFunInputRestore();   // u203f: Gothics Tastenbelegung, bis wieder ein Bogen gezogen ist
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
