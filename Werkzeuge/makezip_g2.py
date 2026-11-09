"""ZIP einer Fassung fuer Gothic 2 Die Nacht des Raben ohne Mod bauen: builds\\zip\\Gothic-I-II-Universal-Coop Gothic II uNN.zip (bis u61 "Gothic Union Coop G2 uNN.zip").

Inhalt (Ordner wie im Spielordner, zum Entpacken in den Gothic-2-Ordner):
  system/Autorun/Gothic2Coop.dll        GT-DLL der Fassung (builds\\uNN\\Gothic2Coop-uNN.dll, G2A MD Release)
  system/Autorun/COOP_MENU.D            Menue-Skript (scripts\\g2, tools\\skripte_g2.py)
  system/Autorun/PC_MULTIPLAYER_HERO.D  Coop-Figur   (scripts\\g2)
  system/Autorun/COOP_ITEMS.D           Merker des Testlaufs (ab u12), Teleport-Rune (ab u17)
  system/GothicCoopConfig.json          Vorgaben - ohne sie beendet GT das Spiel beim Start (Plugin.cpp)
  system/GothicCoopMod.vorlage.json     Vorlage fuer ein Mod-Profil (ab u194, inaktiv - Mods\\CoopModProfile.h)
  system/steam_api.dll                  Steam API mit SteamAPI_InitFlat (assets\\steam, wie Gothic 1)
  system/steam_appid.txt                39510 = Gothic II Gold Edition auf Steam (assets\\steam\\g2)
  GothicCoop-LIESMICH.txt               kurze Anleitung mit dem Stand der Freigaben
  GothicCoop-LIESMICH-<Mod>.txt         u195: Anleitung je Mod mit eigenem Profil (makezip_mod.MODS, z. B. LoA)
  system/GothicCoop/Skripte/g2/         u195 (P204): Skriptsatz der Gothic-2-Engine - Quelle der Skript-Weiche (CoopCore.cpp)
  system/GD3D11/Bin/g2a_avx2.dll        Coop-Renderer (ab u10, --renderer)
  Data/Union.vdf, system/Union.patch ... die sieben Dateien von Union 1.0m (ab u62, --union-dir; geprueft gegen
                                        installer_bau.UNION_FILES) - Nutzer: "die Dateien von Union werden direkt reingepackt"
Bis u61 installierte der Nutzer Union (mit zParserExtender) selbst.

Aufruf (aus dem Repo):  python tools\\makezip_g2.py u8 [--force]
"""
import argparse, hashlib, os, sys, time, zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pfade   # u62: Pfade im Repo (oeffentlicher Export: eigener Aufbau)

LIESMICH = """GothicCoop {f} - Gothic 2 Die Nacht des Raben ohne Mod (Union-Coop, erste Fassung fuer Gothic 2)

Voraussetzung: Gothic 2 Die Nacht des Raben (Fassung 2.6). Union 1.0m (mit zParserExtender) liegt bei.
Beide PCs brauchen dieselbe GothicCoop-Fassung ({f}).

Installation: den Inhalt dieser ZIP in den Gothic-2-Ordner entpacken (den Ordner, in dem "system" liegt) und
vorhandene Dateien ersetzen. War Union noch nicht installiert: danach system\\dinput.dll entfernen (der Lader von
SystemPack - Union laedt SystemPack selbst). Bequemer und rueckgaengig machbar: der Installer.
  Data\\Union.vdf, system\\Union.patch, Shw32.dll, Vdfs32g.dll, stdhost.exe, msvcp100.dll, msvcr100.dll   Union 1.0m
  system\\Autorun\\              GothicCoop-DLL und drei Skripte
  system\\GothicCoopConfig.json  Vorgaben (Name, Adresse, Aussehen - im Spiel unter COOP aenderbar)
  system\\GothicCoopMod.vorlage.json  Vorlage fuer ein Mod-Profil (so benannt nicht aktiv, siehe unten)
  system\\steam_api.dll und steam_appid.txt (39510)   fuer "Coop ueber Steam" (Steam muss laufen)
  system\\GD3D11\\Bin\\g2a_avx2.dll  Coop-Renderer (GD3D11 v17.9.7 + coop9) - nur wirksam, wenn GD3D11 installiert ist
                                  (3D-Vorschau der Figur, Zuschau-Fenster beim Mitspieler, eigenes Log im Weltprozess,
                                  ab coop8 das Bild des Weltprozesses im Zuschau-Fenster)

Stand: In Gothic 2 laufen GTs Grundabgleich (Spieler, NPCs in der Naehe), das COOP-Menue (Figur, Verbinden, Steam),
die Maus in den Menues, das gemeinsame neue Spiel (Intro fuer beide ueberspringen, Mitspieler neben dem Host),
3D-Vorschau und Zuschau-Fenster (Shift+F5, automatisch ab 45 m), Dialoge (einer spricht mit einem NPC, der andere hoert
zu; Fortschritt, Tagebuch und Quest-EP fuer beide), der Fern-Abgleich (Partner und NPCs um ihn bleiben auch weit weg in
der Welt), Truhen, Gegenstaende und Pluendern (ab u13), gemeinsame Spielstaende mit Vorschau (ab u15), Kampf mit
Treffer-Hoheit, Kampf-Uebergabe, Absturzschutz und COOP-Schwierigkeit (ab u16), der Coop-Testlauf (Shift+F11,
100 Schritte - Schritte noch fehlender Teile melden "--"), die Teleport-Rune zum Mitspieler (ab u17, jeder bekommt sie
nach dem Laden), die Markierung des Partners (Name ueber dem Kopf, Pfeil am Bildrand, ab u18), im Esc-Menue
"Spielstand waehlen" und "Hauptmenue" (zurueck zum Startbildschirm ohne Neustart, ab u19) sowie Diagnose und
Selbstpruefung der Engine-Eingriffe (ab u20, system\\GothicCoopAudit.log). Ab u21: Eintraege nur fuer das Spiel bzw.
nur fuer den Start sind im jeweils anderen Menue ausgeblendet, Tagebuch-Themen direkt mit der Maus waehlbar, eigenes
Aussehen der Teleport-Rune, Mauszeiger = Spielerpfeil der Karte. Ab u22: markierter Eintrag gruen statt leuchtend
(Gothic.ini [GOTHICCOOP] coopMenuGreen=0 schaltet es ab), Zeiger etwas kleiner mit dunklem Rand. Ab u23: kraeftigeres
Gruen (coopMenuGreenColor = "R G B"), Auswahlfelder mit "<" und ">" (coopMenuArrows=0 schaltet es ab). Ab u24:
"Aussehen wie NPC" findet die NPCs von Gothic 2 (z. B. Xardas, Lares). Ab u25: Esc-Menue ohne "Gothic II starten",
"Intro abspielen" und "Weiterspielen" (Esc fuehrt zurueck ins Spiel), "Hauptmenue" ueber "Gothic II beenden". Ab u26
(Abgleich mit dem G2-Modkit): G2-Kampfzustaende beim Client gesperrt wie die von G1; Boni aus Gegenstaenden und
Lesepulten, Rezepte, eigene Karte und Besessenheit gelten je Held. Ab u27: der Zeiger im Esc-Menue folgt der Maus,
Gegenstaende aus Skripten (Wld_InsertItem) erscheinen bei beiden. Ab u28: Zuschau-Fenster zeichnet jedes Bild
(Gothic.ini [GOTHICCOOP] camWindowEveryNth), Kapitelbild der eigenen Gilde, Story-Videos auch beim Partner, Partner als
roter Pfeil auf der Karte. Ab u29: jeder kann in einer anderen Welt sein (Khorinis, Minental, Jharkendar, Irdorath) -
der Chat meldet, wer wo ist; die Figur des Partners steht nur in derselben Welt, ohne den Host fuehrt der Client die NPCs
seiner Welt selbst (GothicCoopConfig.json "coopSeparateWorlds": false schaltet die Trennung ab). Ab u30: der Testlauf
(Shift+F11, jetzt 110 Schritte) laeuft auch, wenn der Partner in einer anderen Welt ist, und prueft am Ende gemeinsames
Speichern und Laden (er legt dafuer eine Sicherung in einem der Auto-Slots an und laedt sie). Ab u31: wer beim gemeinsamen
Speichern in einer anderen Welt war, laedt dort wieder (eigener Stand, eigene Lage). Ab u32: gemeinsamer Weltwechsel -
wer durch einen Uebergang geht (z. B. den Pass ins Minental), bestaetigt mit Enter oder J (Ruecktaste oder N = bleiben),
die Mitspieler kommen nach 2 s mit. Einstellungen > COOP > Abgleich > Weltwechsel "getrennt" = jeder wechselt allein
(wie u29-u31); der Host gibt vor. Ab u33: die Abfrage bricht erst ab, wenn man 15 m vom Uebergang weg ist. Neu
(Versuch, nur Host): Shift+F12 startet den Weltprozess - ein zweites Gothic auf dem PC des Hosts laedt die Welt eines
Mitspielers, der in einer anderen Welt ist (Weltwechsel "getrennt"), und zeigt ihn dort; das Fenster "Gothic II - Coop-
Weltprozess" liegt minimiert in der Taskleiste. Shift+F12 erneut beendet ihn. Er laedt den neuesten Spielstand des Hosts
(Kopie in Saves_CoopWelt, der eigene Stand bleibt unberuehrt), Protokoll system\\GothicCoopWelt.log. Ab u34 laeuft er aus
einem eigenen Spielordner CoopWelt im Gothic-2-Ordner (legt GT beim ersten Shift+F12 an: Verknuepfungen auf Spieldateien und
Archive, kein zusaetzlicher Platz; braucht ein NTFS-Laufwerk) - Protokolle dort in CoopWelt\\system, die letzten Zeilen auch
im Coop-Log des Hosts. Den Ordner Saves_CoopWelt aus u33 braucht es nicht mehr. Ab u35 schreibt der Weltprozess jede
Fehlermeldung und jedes Beenden mit Aufrufer in sein Protokoll (Fehlersuche). Ab u36 liegt sein Ordner neben dem
Gothic-2-Ordner (z. B. "Gothic II_CoopWelt"); den alten Ordner CoopWelt im Gothic-2-Ordner entfernt GT beim Start selbst.
Ab u37 startet er auch, waehrend das Hauptspiel laeuft (Gothics Sperre gegen ein zweites Spiel gilt fuer ihn nicht).
Ab u38 (Host und Client, Renderer coop8 auf beiden PCs): der Weltprozess startet von selbst, sobald Coop laeuft, und wartet
im Hintergrund. Ist ein Mitspieler in einer anderen Welt (durch einen Uebergang gegangen oder dort einen Spielstand
geladen), laedt er den neuesten eigenen Spielstand und jene Welt; ist er bereit, zeigt das Zuschau-Fenster (Shift+F5,
blauer Rahmen; bei "Kamera: automatisch" von selbst) den Mitspieler dort. Kommt der Mitspieler zurueck, ruht er in seiner
Welt bis zum naechsten Mal. Ein Spielstand muss vorhanden sein. Shift+F12 beendet ihn (startet erst wieder mit Shift+F12),
GothicCoopConfig.json "coopWorldProcessAuto": false schaltet den Vorstart ab.
Ab u39: der Weltprozess startet schon im COOP-Menue und laeuft unsichtbar auf einem eigenen Windows-Desktop (kein Fenster,
keine Taskleiste; "coopWorldProcessVisible": true zeigt ihn minimiert wie bisher). Speichern beide gemeinsam in verschiedenen
Welten, bekommt jeder die Weltdatei der Welt des anderen in seinen Spielstand (wer in einer Welt ist, fuehrt deren Stand). Die
Teleport-Rune bringt einen auch in eine andere Welt zum Mitspieler. Der Coop-Testlauf (Shift+F11, jetzt 125 Schritte) holt den
Partner selbst in die eigene Welt, statt Schritte zu ueberspringen, und prueft am Ende getrennte Welten, Weltprozess,
Speichern/Laden in verschiedenen Welten und den Teleport ueber Welten (dauert 6-8 Minuten).
Ab u40 prueft der Testlauf (144 Schritte) auch den Abgleich ueber Welten: Uhrzeit, Story, Tagebuch, Skript-Variablen, Gilden,
Kapitel und Quest-EP, waehrend der Partner in der anderen Welt ist. Toetet der Host einen NPC, den gerade der Client fuehrt,
bekommt der Client seinen EP-Anteil (vorher ging er manchmal verloren).
Ab u41 liegt der Ordner des Weltprozesses im Gothic-2-Ordner (z. B. "Gothic II\\Gothic II_CoopWelt") statt daneben; GT
verschiebt den alten Ordner beim ersten Start selbst dorthin. Die Union-Plugins darin benennt GT um (*.dll.welt), damit das
Hauptspiel sie nicht statt seiner eigenen laedt. u42 bringt den Weltprozess auch nach Gothic 1 (fuer Gothic 2 unveraendert).
Ab u44: Shift+F11 startet nur noch den Welten-Testlauf (Verbindung, Partner herholen, dann getrennte Welten, Abgleich ueber
Welten, Weltprozess, Speichern/Laden, Teleport - 39 Schritte, ab u45 als 01/39 ... 39/39 gezaehlt); Strg+Shift+F11 = alle
144 Schritte wie bisher. Ab u45: zeigt der Weltprozess beim Start eine Meldungsbox (er laeuft unsichtbar), schreibt GT ihren
Text ins Protokoll und bestaetigt sie, statt 3 Minuten zu warten.
Ab u46: im Zuschau-Fenster des Weltprozesses bewegen, kaempfen und sterben die NPCs so wie bei dem, der in jener Welt ist (der
Weltprozess rechnet sie nicht mehr selbst). Dafuer schickt ein Client, der ohne Host in seiner Welt ist, die NPCs um sich mit
("coopWorldProcessMirror": false schaltet das ab). Beide PCs brauchen u46.
Ab u47: betritt man eine Welt, in der der Mitspieler gerade ist oder zuletzt war, gilt sein Stand dieser Welt (getoetete NPCs,
Truhen, Gegenstaende): GT haelt den Weltwechsel kurz an, speichert gemeinsam ("Coop-Weltwechsel" in einem Auto-Slot), holt seine
Weltdatei und wechselt dann ("coopEnterTakeState": false schaltet das ab). Der Welten-Testlauf (Shift+F11) prueft das in
beide Richtungen (Partner markiert seine Welt, ich betrete sie; ich markiere meine, er kommt per Teleport). Beide PCs brauchen u47.
Ab u48: kein Absturz mehr, wenn man beim Betreten genau an der Stelle des Mitspielers landet (der zweite Held aus seiner Weltdatei
wird entfernt, der eigene Held behielt dessen Modell als Boden). Der Teleport ueber Welten setzt einen gleich beim Laden neben die
letzte Lage des Mitspielers (vorher erst am Startpunkt der Welt - Gothic raeumte in der Zeit Tote neben ihm weg). Im Zuschau-
Fenster bekommt der Held des Mitspielers nach jedem Laden sofort Ruestung, Waffen, Overlays und seine laufende Animation.
Ab u49: der erste Start des Weltprozesses haengt nicht mehr - Unions SystemPack zeigt beim ersten Start einer neuen Gothic-Kopie
das Fenster "First start!", GT bestaetigt es jetzt mit dem richtigen Knopf (vorher erst nach 60 s Neustart). Fuer Entwickler:
"Gothic2.exe -cooptest:host:<Slot>" laesst Host und Client auf einem PC den Welten-Testlauf ausfuehren.
Ab u51 (Durchsicht aller Haken): der Spieltag kommt mit der Uhrzeit vom Host (bisher nur Stunde/Minute - nach Mitternacht lief
der Client oft einen Tag vor); frisch erschienene NPCs (Beschwoerungen, Skript-Spawns), die man sofort trifft, bekommen trotzdem
ihren Namen und werden abgeglichen; ein NPC des Hosts, der zuerst als Angriffsziel ankommt, wird beim Client trotzdem angelegt;
der Weltprozess bestimmt nach seinem Weltwechsel den Boden neu. Beide PCs brauchen u51 (sonst fehlt der Tag).
Ab u52: ein Zugriffsfehler im Coop-Code beendet das Spiel nicht mehr - er steht als "FEHLER abgefangen" im Protokoll
(system\\GothicCoop.log), das Spiel laeuft weiter. Bitte solche Zeilen melden.
Ab u53 gibt es statt dieser ZIP auch einen Installer ("Gothic Union Coop Setup u53.exe"): Spiel waehlen (Gothic 1, Gothic 2,
Othello), Ordner waehlen, Installieren - fehlt GD3D11, bringt er es mit; Ersetztes kommt nach CoopBackup, rueckgaengig moeglich.
Ab u54 prueft der Installer das Spiel genau (Gothic 2 Die Nacht des Raben 2.6, Gothic 1 1.08k, Othello vollstaendig - auch Reste
von Othello in einem Gothic 1) und installiert in einen falschen Ordner nichts; fehlt Union bei Gothic 1/2, startet er das
mitgelieferte Union-Setup. Am Ende meldet er "fertig installiert", OK schliesst ihn.
Ab u55: ueberspringt einer ein Story-Video (z. B. Xardas am Anfang), endet es bei beiden. Nach jeder gemeinsamen Sicherung
bekommt jeder den Stand des anderen als Sicherung (Archiv: <Kennung>__von_<PC>); fehlt einem beim Laden sein eigener Stand
(Saves verloren), holt er ihn samt Helden vom Partner zurueck. Beide PCs brauchen u55.
Ab u62 (Projekt Gothic-I-II-Universal-Coop 0.2.0, Quelltext: https://github.com/corshaegar/Gothic-I-II-Universal-Coop):
Union 1.0m liegt als Dateien bei; der Installer installiert sie mit, wenn Union fehlt (statt das Union-Setup zu starten),
und nimmt sie beim Rueckgaengig wieder heraus.
Ab u85: Gilden gelten je Held - Gilden-Dialoge teilen nur Helden derselben Gilde. Ab u96: Missions-Gegenstaende sind gemeinsam:
bekommt einer einen, hat ihn der Partner auch; gibt einer ihn ab, verliert ihn der Partner (Name "... (gemeinsam)"). Ab u97:
Coop-Inventar - eine gemeinsame Truhe; die Taste (Vorgabe I, Einstellungen > COOP) oeffnet sie ohne Bewegung, beide koennen sie
gleichzeitig offen haben, der Inhalt liegt beim Host und im Spielstand, Gegenstaende daraus zaehlen bei Quests. Ab u105: Auto-Sicherung
auch alle 3 Minuten. Ab u135 (Renderer coop9): kein Absturz mehr beim Speichern mit offenem Zuschau-Fenster, wenn in den
GD3D11-Einstellungen AtmosphericScattering aus ist; das Zuschau-Fenster zeigt dann statt des Himmels die Nebelfarbe.
Ab u194: Mod-Profil als Datei - eine Mod, die der Coop nicht kennt, bekommt ihre Anpassungen (Skriptwerte, die je PC bleiben,
Vorgaben fuer Coop-Schalter, Hinweise) ohne neue DLL ueber system\\GothicCoopMod-<Ini>.json (<Ini> = Spiel-Ini der Mod ohne
".ini", z. B. GothicCoopMod-LoA.json). Vorlage mit Erklaerung: system\\GothicCoopMod.vorlage.json. Beide PCs brauchen dieselbe
Datei; das Log nennt beim Start, was gelesen wurde ("Mod-Profil ...").
Ab u195: ein Paket fuer Gothic 2 und jede Mod darin (Legend of Ahssun, Gothic II Classic, ...): der Coop erkennt beim Start, was
laeuft (Log: "Profil"), die Skripte liegen zusaetzlich in system\\GothicCoop\\Skripte\\g2 (die Skript-Weiche ergaenzt fehlende).
Anleitung fuer Legend of Ahssun: GothicCoop-LIESMICH-LoA.txt.

Spielen: Hauptmenue > COOP > Figur waehlen > "Weiter: Verbinden" > "Spiel hosten" bzw. "Ueber IP beitreten"
(Port 9955) oder ueber Steam. Protokoll: system\\GothicCoop.log.
Testlauf: Shift+F11 erst am Host, nach dessen Ende am Client - nur auf einem Test-Spielstand (Uhrzeit +30 min, zwei
Test-NPCs, Tagebuch-Thema "Coop-Test" und eine Sicherung "Coop-Test" in einem Auto-Slot bleiben). Ergebnis im Chat und in
system\\GothicCoop.log (Zeilen "Coop-Test"), am Ende je Bereich OK/FEHLER/--.
"""


def sha16(data):
    return hashlib.sha256(data).hexdigest()[:16].upper()


def union_entries(folder):
    """u62: die sieben Union-Dateien als (Pfad in der ZIP, Quelle) - geprueft wie im Installer (installer_bau.union_files)"""
    import installer_bau
    folder = folder or pfade.union_vorlage(ROOT)
    installer_bau.union_files(folder)   # beendet bei einer fremden Datei
    return [(rel, os.path.join(folder, *rel.split('/'))) for rel, _, _ in installer_bau.UNION_FILES]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('fassung')
    ap.add_argument('--dll', help='Vorgabe builds\\<fassung>\\Gothic2Coop-<fassung>.dll')
    ap.add_argument('--scripts', default=pfade.SKRIPTE['g2'])
    ap.add_argument('--renderer', default=pfade.RENDERER['g2'], help='"-" = weglassen (ab u10; u33: coop7, u38: coop8, u135: coop9)')
    ap.add_argument('--union-dir', help='Spielordner mit Union 1.0m (Vorgabe wie installer_bau.py), "-" = weglassen')
    ap.add_argument('--name', help='Dateiname der ZIP (Vorgabe "Gothic-I-II-Universal-Coop Gothic II <fassung>.zip")')
    ap.add_argument('--force', action='store_true', help='vorhandene ZIP ersetzen')
    a = ap.parse_args()
    dll = a.dll or pfade.dll(a.fassung, 'g2')

    out = os.path.join(ROOT, pfade.zip_ziel(a.name or 'Gothic-I-II-Universal-Coop Gothic II %s.zip' % a.fassung))
    if os.path.exists(out) and not a.force:
        sys.exit('%s gibt es schon - mit --force ersetzen' % out)

    entries = [
        ('system/Autorun/Gothic2Coop.dll', dll),
        ('system/Autorun/COOP_MENU.D', os.path.join(a.scripts, 'COOP_MENU.D')),
        ('system/Autorun/PC_MULTIPLAYER_HERO.D', os.path.join(a.scripts, 'PC_MULTIPLAYER_HERO.D')),
        ('system/Autorun/COOP_ITEMS.D', os.path.join(a.scripts, 'COOP_ITEMS.D')),   # u12
        ('system/Autorun/COOP_FUN.D', os.path.join(a.scripts, 'COOP_FUN.D')),       # u203: Fun-Modus
        ('system/GothicCoopConfig.json', os.path.join(a.scripts, 'GothicCoopConfig.json')),
        ('system/GothicCoopMod.vorlage.json', os.path.join(a.scripts, 'GothicCoopMod.vorlage.json')),   # u194 (P196)
        ('system/steam_api.dll', pfade.STEAM_API),
        ('system/steam_appid.txt', pfade.STEAM_APPID['g2']),
    ]
    if a.renderer != '-':
        entries.append(('system/GD3D11/Bin/g2a_avx2.dll', a.renderer))
    if a.union_dir != '-':   # u62: Union 1.0m dazu (geprueft)
        entries += union_entries(a.union_dir)
    import makezip_g1, makezip_mod
    entries += makezip_g1.store_entries(('g2',))   # u195 (P204): Quelle der Skript-Weiche
    readme = LIESMICH.format(f=a.fassung).replace('\n', '\r\n').encode('cp1252')
    # u195: Anleitungen der Mods mit eigenem Profil (makezip_mod.MODS) - dasselbe Paket gilt fuer sie
    extra = [('GothicCoop-LIESMICH-%s.txt' % m['kurz'], m['liesmich'].format(f=a.fassung).replace('\n', '\r\n').encode('cp1252', errors='replace'))
             for m in makezip_mod.MODS.values() if m['basis'] == 'Gothic II']
    texts = dict([('GothicCoop-LIESMICH.txt', readme)] + extra)

    os.makedirs(os.path.dirname(out), exist_ok=True)
    tmp = out + '.part'
    with zipfile.ZipFile(tmp, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for arc, src in entries:
            path = os.path.join(ROOT, src)
            info = zipfile.ZipInfo(arc, time.localtime(os.path.getmtime(path))[:6])
            info.compress_type = zipfile.ZIP_DEFLATED
            z.writestr(info, open(path, 'rb').read())
        for arc, data in texts.items():
            info = zipfile.ZipInfo(arc, time.localtime()[:6])
            info.compress_type = zipfile.ZIP_DEFLATED
            z.writestr(info, data)

    with zipfile.ZipFile(tmp) as z:
        bad = z.testzip()
        if bad:
            sys.exit('ZIP fehlerhaft bei %s' % bad)
        for arc, src in entries + [(n, None) for n in texts]:
            got = z.read(arc)
            want = texts[arc] if src is None else open(os.path.join(ROOT, src), 'rb').read()
            print('%-42s %9d  %s  %s' % (arc, len(got), sha16(got), 'gleich' if got == want else 'ABWEICHUNG'))
            if got != want:
                sys.exit('Inhalt weicht ab: %s' % arc)
    os.replace(tmp, out)
    print('%s  %d Bytes  SHA-256 %s' % (out, os.path.getsize(out), sha16(open(out, 'rb').read())))


if __name__ == '__main__':
    main()
