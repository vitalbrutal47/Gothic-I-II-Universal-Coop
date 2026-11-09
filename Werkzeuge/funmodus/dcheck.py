#!/usr/bin/env python3
"""Kleiner Daedalus-Pruefer: Syntax, unbekannte Namen, Anzahl der Argumente, Klassenfelder.

Benutzung: dcheck.py <src-Datei> [--extra datei.d ...] [--check datei.d ...]
Die .src-Datei liefert die Grundmenge (alle Original-Skripte). --extra legt weitere Dateien dazu (z. B. COOP_ITEMS.D),
--check prueft Dateien gegen alles; Fehler werden mit Datei:Zeile ausgegeben. Gross-/Kleinschreibung zaehlt nicht.
"""
import re, sys, os, glob

KEYWORDS = {"const", "var", "func", "class", "prototype", "instance", "if", "else", "return", "int", "float", "string",
            "void", "meta"}
TOK = re.compile(r"""
 (?P<ws>\s+) | (?P<lc>//[^\n]*) | (?P<bc>/\*.*?\*/) |
 (?P<str>"[^"\n]*") | (?P<float>\d+\.\d*(?:[eE][+-]?\d+)?|\.\d+) | (?P<int>\d+) |
 (?P<id>[A-Za-z_À-ÿ][A-Za-z0-9_À-ÿ\^@]*) |
 (?P<op>\|\||&&|==|!=|<=|>=|<<|>>|\+=|-=|\*=|/=|[-+*/%<>!~&|=(){}\[\];,.:])
""", re.S | re.X)


IMPLICIT = {}   # Engine-Funktionen, die nur benutzt, nie deklariert werden: Name -> Argumentzahlen


class DErr(Exception):
    pass


def tokenize(text, fname):
    toks, pos, line = [], 0, 1
    while pos < len(text):
        m = TOK.match(text, pos)
        if not m:
            raise DErr(f"{fname}:{line}: unbekanntes Zeichen {text[pos]!r}")
        k = m.lastgroup
        v = m.group(k)
        if k not in ("ws", "lc", "bc"):
            toks.append((k, v, line))
        line += v.count("\n")
        pos = m.end()
    toks.append(("eof", "", line))
    return toks


class Sym:
    def __init__(self, kind, name, typ=None, params=None, cls=None, size=1, fname="", line=0):
        self.kind, self.name, self.typ, self.params, self.cls, self.size = kind, name, typ, params, cls, size
        self.fname, self.line = fname, line


class Parser:
    def __init__(self, toks, fname, db, check):
        self.t, self.i, self.f, self.db, self.check = toks, 0, fname, db, check
        self.errors = []
        self.locals = None
        self.cls_ctx = None   # Klasse fuer implizite Felder (instance/prototype-Rumpf)

    # --- Hilfen
    def peek(self, k=0):
        return self.t[self.i + k]

    def next(self):
        x = self.t[self.i]
        self.i += 1
        return x

    def at(self, v):
        return self.peek()[1].lower() == v

    def expect(self, v):
        x = self.next()
        if x[1].lower() != v:
            raise DErr(f"{self.f}:{x[2]}: erwartet {v!r}, gefunden {x[1]!r}")
        return x

    def ident(self):
        x = self.next()
        if x[0] != "id":
            raise DErr(f"{self.f}:{x[2]}: Name erwartet, gefunden {x[1]!r}")
        return x

    def err(self, line, msg):
        if self.check:
            self.errors.append(f"{self.f}:{line}: {msg}")

    # --- Deklarationen
    def file(self):
        while self.peek()[0] != "eof":
            if self.at("meta"):
                self.next(); self.expect("{")
                while not self.at("}"):
                    self.next()
                self.expect("}"); self.expect(";")
                continue
            self.decl(top=True)
            while self.at(";"):
                self.next()

    def typename(self):
        x = self.ident()
        return x[1].lower()

    def decl(self, top=False):
        kw = self.next()
        k = kw[1].lower()
        if k == "const":
            typ = self.typename()
            name = self.ident()
            size = 1
            if self.at("["):
                self.next(); size = self.const_index(); self.expect("]")
            self.expect("=")
            if self.at("{"):
                self.next()
                n = 0
                while True:
                    self.expr(); n += 1
                    if self.at(","):
                        self.next(); continue
                    break
                self.expect("}")
            else:
                self.expr()
            self.expect(";")
            self.define(Sym("const", name[1], typ, size=size, line=name[2]), top)
        elif k == "var":
            typ = self.typename()
            while True:
                name = self.ident()
                size = 1
                if self.at("["):
                    self.next(); size = self.const_index(); self.expect("]")
                self.define(Sym("var", name[1], typ, size=size, line=name[2]), top)
                if self.at(","):
                    self.next()
                    if self.at("var"):
                        self.next(); typ = self.typename()
                    continue
                break
            self.expect(";")
        elif k == "func":
            rtyp = self.typename()
            name = self.ident()
            self.expect("(")
            params = []
            locs = {}
            while not self.at(")"):
                self.expect("var")
                pt = self.typename()
                pn = self.ident()
                params.append(pt)
                locs[pn[1].lower()] = Sym("var", pn[1], pt)
                if self.at(","):
                    self.next()
            self.expect(")")
            s = Sym("func", name[1], rtyp, params=params, line=name[2])
            self.define(s, top)
            if self.at(";"):   # Deklaration ohne Rumpf (Externals.d)
                return
            self.locals = locs
            self.block()
            self.locals = None
        elif k == "class":
            name = self.ident()
            self.expect("{")
            members = {}
            while not self.at("}"):
                self.expect("var")
                typ = self.typename()
                while True:
                    mn = self.ident()
                    size = 1
                    if self.at("["):
                        self.next(); size = self.const_index(); self.expect("]")
                    members[mn[1].lower()] = Sym("var", mn[1], typ, size=size)
                    if self.at(","):
                        self.next(); continue
                    break
                self.expect(";")
            self.expect("}")
            s = Sym("class", name[1], line=name[2])
            s.members = members
            self.define(s, top)
        elif k in ("prototype", "instance"):
            names = [self.ident()]
            while self.at(","):
                self.next(); names.append(self.ident())
            self.expect("(")
            parent = self.ident()
            self.expect(")")
            cls = self.class_of(parent[1], parent[2])
            for n in names:
                self.define(Sym(k, n[1], cls=cls, line=n[2]), top)
            if self.at("{"):
                self.locals = {}
                self.cls_ctx = cls
                self.block()
                self.cls_ctx = None
                self.locals = None
        else:
            raise DErr(f"{self.f}:{kw[2]}: Deklaration erwartet, gefunden {kw[1]!r}")

    def class_of(self, parent, line):
        s = self.db.get(parent.lower())
        if not s:
            self.err(line, f"unbekannte Klasse/Prototyp {parent}")
            return None
        if s.kind == "class":
            return s.name.lower()
        if s.kind == "prototype":
            return s.cls
        self.err(line, f"{parent} ist weder Klasse noch Prototyp")
        return None

    def define(self, s, top):
        key = s.name.lower()
        s.fname = self.f
        if top:
            old = self.db.get(key)
            if old and self.check and old.kind != "func_ext":
                self.err(s.line, f"{s.name} schon definiert ({old.fname}:{old.line})")
            self.db[key] = s
        else:
            self.locals[key] = s

    def const_index(self):
        x = self.next()
        if x[0] == "int":
            return int(x[1])
        if x[0] == "id":
            s = self.lookup(x[1], x[2])
            return getattr(s, "value", 1) if s else 1
        raise DErr(f"{self.f}:{x[2]}: Feldgroesse erwartet")

    # --- Anweisungen
    def block(self):
        self.expect("{")
        while not self.at("}"):
            self.stmt()
        self.expect("}")

    def stmt(self):
        if self.at(";"):
            self.next(); return
        if self.at("var") or self.at("const"):
            self.decl(top=False)
            return
        if self.at("if"):
            self.next()
            self.expr()
            self.block()
            while self.at("else"):
                self.next()
                if self.at("if"):
                    self.next(); self.expr(); self.block()
                else:
                    self.block(); break
            if self.at(";"):
                self.next()
            return
        if self.at("return"):
            self.next()
            if not self.at(";"):
                self.expr()
            self.expect(";")
            return
        if self.at("{"):
            self.block()
            return
        # Zuweisung oder Ausdruck
        self.expr(stmt=True)
        if self.peek()[1] in ("=", "+=", "-=", "*=", "/="):
            self.next()
            self.expr()
        self.expect(";")

    # --- Ausdruecke
    BIN = [["||"], ["&&"], ["|"], ["&"], ["==", "!="], ["<", ">", "<=", ">="], ["<<", ">>"], ["+", "-"], ["*", "/", "%"]]

    def expr(self, lvl=0, stmt=False):
        if lvl == len(self.BIN):
            return self.unary()
        self.expr(lvl + 1)
        while self.peek()[1] in self.BIN[lvl]:
            self.next()
            self.expr(lvl + 1)

    def unary(self):
        if self.peek()[1] in ("-", "!", "~", "+"):
            self.next()
            return self.unary()
        return self.primary()

    def lookup(self, name, line):
        k = name.lower()
        if self.locals is not None and k in self.locals:
            return self.locals[k]
        if self.cls_ctx:
            c = self.db.get(self.cls_ctx)
            if c and k in c.members:
                return c.members[k]
        s = self.db.get(k)
        if not s:
            self.err(line, f"unbekannter Name {name}")
        return s

    def member_check(self, obj, mem, line):
        if not obj or not self.check:
            return
        typ = obj.typ if obj.kind in ("var", "const") else obj.cls if obj.kind in ("instance", "prototype") else None
        if obj.kind == "func":
            typ = obj.typ
        c = self.db.get(typ or "")
        if not c or c.kind != "class":
            self.err(line, f"{obj.name} hat keine Felder (Typ {typ})")
            return
        if mem.lower() not in c.members:
            self.err(line, f"Klasse {c.name} hat kein Feld {mem}")

    def primary(self):
        x = self.next()
        if x[0] in ("int", "float", "str"):
            return
        if x[1] == "(":
            self.expr(); self.expect(")"); return
        if x[0] != "id":
            raise DErr(f"{self.f}:{x[2]}: Ausdruck erwartet, gefunden {x[1]!r}")
        if self.at("("):
            self.next()
            n = 0
            while not self.at(")"):
                self.expr(); n += 1
                if self.at(","):
                    self.next()
            self.expect(")")
            if not self.check and x[1].lower() not in self.db and (self.locals is None or x[1].lower() not in self.locals):
                IMPLICIT.setdefault(x[1].lower(), set()).add(n)
                return
            if self.check and x[1].lower() in IMPLICIT and x[1].lower() not in self.db:
                if n not in IMPLICIT[x[1].lower()]:
                    self.err(x[2], f"{x[1]} (Engine-Funktion) wird sonst mit {sorted(IMPLICIT[x[1].lower()])} Argumenten gerufen, hier {n}")
                return
            s = self.lookup(x[1], x[2])
            if s and self.check:
                if s.kind not in ("func", "func_ext"):
                    self.err(x[2], f"{x[1]} ist keine Funktion")
                elif s.params is not None and len(s.params) != n:
                    self.err(x[2], f"{x[1]} erwartet {len(s.params)} Argumente, bekommt {n}")
            return
        s = self.lookup(x[1], x[2])
        if self.at("["):
            self.next(); self.expr(); self.expect("]")
        if self.at("."):
            self.next()
            m = self.ident()
            self.member_check(s, m[1], m[2])
            if self.at("["):
                self.next(); self.expr(); self.expect("]")


def read(path):
    with open(path, "rb") as f:
        return f.read().decode("cp1252")


def src_files(src):
    base = os.path.dirname(src)
    out = []
    for ln in read(src).splitlines():
        ln = ln.strip()
        if not ln or ln.startswith("//"):
            continue
        p = os.path.join(base, ln.replace("\\", "/"))
        hits = sorted(glob.glob(p, recursive=False))
        if not hits:   # Gross-/Kleinschreibung des Dateisystems
            parts = ln.replace("\\", "/").split("/")
            cur = base
            for part in parts:
                rx = re.compile("^" + re.escape(part).replace(r"\*", ".*") + "$", re.I)
                cand = [c for c in (os.listdir(cur) if os.path.isdir(cur) else []) if rx.match(c)]
                if not cand:
                    cur = None; break
                if part is parts[-1]:
                    hits = sorted(os.path.join(cur, c) for c in cand)
                else:
                    cur = os.path.join(cur, cand[0])
        out += hits
    return out


def load(db, path, check, errors):
    p = Parser(tokenize(read(path), path), path, db, check)
    try:
        p.file()
    except DErr as e:
        errors.append(str(e))
    errors += p.errors


def externals(db, path):
    """Externals.d: nur Deklarationen (Rumpf {} oder ;)."""
    txt = read(path)
    for m in re.finditer(r"(?im)^\s*func\s+(\w+)\s+(\w+)\s*\(([^)]*)\)", txt):
        params = [p.split()[1].lower() for p in m.group(3).split(",") if p.strip()] if m.group(3).strip() else []
        db[m.group(2).lower()] = Sym("func_ext", m.group(2), m.group(1).lower(), params=params, fname=path)


def main(argv):
    src = argv[1]
    extra, chk, ext = [], [], []
    mode = None
    for a in argv[2:]:
        if a in ("--extra", "--check", "--ext"):
            mode = a; continue
        {"--extra": extra, "--check": chk, "--ext": ext}[mode].append(a)
    db = {}
    for c in ("int", "float", "string", "func", "void", "instance"):
        db[c] = Sym("type", c)
    for e in ext:
        externals(db, e)
    base_err = []
    # zwei Durchlaeufe: erst alle Namen sammeln, dann pruefen ist hier nicht noetig - Daedalus kennt Vorwaertsverweise
    # (Funktionen nach Gebrauch definiert). Darum: Grundmenge ohne Pruefung, eigene Dateien mit Pruefung.
    for f in src_files(src) + extra:
        load(db, f, False, base_err)
    if base_err:
        print("Fehler in der Grundmenge (Pruefer-Grenze?):")
        for e in base_err[:30]:
            print("  ", e)
    errs = []
    # Vorwaertsverweise in den eigenen Dateien: erst ohne Pruefung laden, dann mit
    snap = dict(db)
    for f in chk:
        load(db, f, False, [])
    for f in chk:
        d2 = dict(db)
        for k, v in list(d2.items()):
            if v.fname == f:
                pass
        p = Parser(tokenize(read(f), f), f, db, True)
        # doppelte Definition gegen sich selbst vermeiden: Namen aus f vorher entfernen
        for k in [k for k, v in db.items() if v.fname == f]:
            if k in snap:
                db[k] = snap[k]
            else:
                del db[k]
        p.db = db
        # erneut alle Namen der Datei ohne Pruefung, damit Vorwaertsverweise gelten
        pre = Parser(tokenize(read(f), f), f, {}, False)
        pre.db = {}
        try:
            pre.db = dict(db); pre.file()
        except DErr:
            pass
        names = {k: v for k, v in pre.db.items() if v.fname == f}
        merge = re.search(r"(?is)^\s*meta\s*\{[^}]*mergemode\s*=\s*(1|true)", read(f)) is not None
        for k, v in names.items():
            if k in db and db[k].fname != f and db[k].kind != "func_ext":
                if merge and db[k].kind == v.kind:   # zParserExtender MergeMode: Original bleibt als <Name>_old
                    db[k + "_old"] = db[k]
                    print(f"Hinweis {f}:{v.line}: {v.name} ersetzt das Original ({db[k].fname}:{db[k].line}), Original als {v.name}_Old")
                else:
                    errs.append(f"{f}:{v.line}: {v.name} schon definiert ({db[k].fname}:{db[k].line})")
        db.update(names)
        p.check = True
        # beim Pruefen keine Doppel-Meldung der eigenen Namen
        orig_define = p.define

        def define(s, top, p=p, orig=orig_define):
            if top:
                s.fname = p.f
                p.db[s.name.lower()] = s
            else:
                orig(s, top)
        p.define = define
        try:
            p.file()
        except DErr as e:
            errs.append(str(e))
        errs += p.errors
    for e in errs:
        print(e)
    print(f"{len(errs)} Fehler")
    return 1 if errs else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
