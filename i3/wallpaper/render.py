#!/usr/bin/env python3
"""Render shortcuts.tsv into the wallpaper HTML.

Called by generate-wallpaper.sh. The TSV is the authority for which chords
exist (generate-wallpaper.sh cross-checks it against i3/config/config); this
script only decides how they are displayed.
"""
import html
import re
import sys
from collections import OrderedDict

tsv_path, html_path, mod = sys.argv[1], sys.argv[2], sys.argv[3]

# --- chord formatting --------------------------------------------------------
MOD_NAME = {"$mod": mod.lower(), "mod4": "super", "mod1": "alt",
            "control": "ctrl"}
MOD_ORDER = ["super", "ctrl", "alt", "shift"]
MOD_LABEL = {"super": "Super", "ctrl": "Ctrl", "alt": "Alt", "shift": "Shift"}
KEY_SYMBOL = {"left": "←", "down": "↓", "up": "↑", "right": "→",
              "tab": "Tab", "space": "Space", "grave": "`", "print": "PrtSc",
              "pause": "Pause", "xf86audiomute": "Mute",
              "xf86monbrightnessup": "Bright+",
              "xf86monbrightnessdown": "Bright−"}


def canonical(chord):
    """(mods in display order, key) — the same identity the cross-check uses."""
    mods, key = set(), ""
    for part in chord.split("+"):
        p = MOD_NAME.get(part.lower(), part.lower())
        p = MOD_NAME.get(p, p)
        if p in MOD_LABEL:
            mods.add(p)
        else:
            key = p
    return [m for m in MOD_ORDER if m in mods], key


def format_chord(chord):
    mods, key = canonical(chord)
    return (" ".join(MOD_LABEL[m] for m in mods),
            KEY_SYMBOL.get(key, key.upper()))


# --- display collapsing ------------------------------------------------------
# Families of near-identical bindings are shown as one row, matched on the
# canonical "mods+key" form. The TSV still lists every member so the
# cross-check stays exact.
ARROW = r"(left|down|up|right)"
COLLAPSE = [
    (rf"^super\+{ARROW}$", "Super", "←↓↑→", "focus window"),
    (rf"^super shift\+{ARROW}$", "Super Shift", "←↓↑→", "move window"),
    (rf"^super ctrl\+{ARROW}$", "Super Ctrl", "←↓↑→", "resize window"),
    (r"^super\+([1-9]|10)$", "Super", "1–10", "switch to workspace"),
    (r"^super shift\+([1-9]|10)$", "Super Shift", "1–10", "send to workspace"),
    (r"^alt ctrl\+(left|right)$", "Ctrl Alt", "← →", "prev / next workspace"),
]


def collapse(rows):
    out, consumed = [], set()
    for chord, desc in rows:
        mods, key = canonical(chord)
        # Match against a stable "super alt ctrl shift" ordering so patterns
        # above are unambiguous regardless of how the TSV spells the chord.
        ident = " ".join(m for m in ["super", "alt", "ctrl", "shift"] if m in mods) + "+" + key
        for i, (pat, m, k, label) in enumerate(COLLAPSE):
            if re.match(pat, ident):
                if i not in consumed:
                    consumed.add(i)
                    out.append((m, k, label))
                break
        else:
            m, k = format_chord(chord)
            out.append((m, k, desc))
    return out


sections = OrderedDict()
with open(tsv_path) as fh:
    for line in fh:
        line = line.rstrip("\n")
        if not line or line.startswith("#"):
            continue
        cols = line.split("\t")
        if len(cols) != 3:
            continue
        sections.setdefault(cols[0], []).append((cols[1], cols[2]))

# Emacs rows are literal text in Emacs notation, so they bypass formatting.
rendered = OrderedDict()
for name, rows in sections.items():
    if name.startswith("EMACS"):
        rendered[name] = [("", c, d) for c, d in rows]
    else:
        rendered[name] = collapse(rows)

TITLES = {
    "FOCUS": "Focus", "MOVE": "Move", "WINDOW": "Window", "LAYOUT": "Layout",
    "WORKSPACE": "Workspaces", "LAUNCH": "Launch", "NOTIFY": "Notifications",
    "SYSTEM": "System",
    "EMACS": "Emacs", "EMACS-ORG": "Emacs · Org", "EMACS-RUST": "Emacs · Rust",
    "EMACS-TS": "Emacs · TypeScript", "EMACS-GO": "Emacs · Go",
}
# Balanced by row count, not by topic.
COLUMNS = [["FOCUS", "MOVE", "WINDOW", "LAYOUT"],
           ["WORKSPACE", "LAUNCH", "NOTIFY"],
           ["SYSTEM"],
           ["EMACS", "EMACS-ORG"],
           ["EMACS-RUST", "EMACS-TS", "EMACS-GO"]]
GROUPS = [("i3", COLUMNS[:3]), ("Emacs", COLUMNS[3:])]

missing = [n for n in rendered if not any(n in c for c in COLUMNS)]
if missing:
    sys.exit(f"render.py: sections not placed in COLUMNS: {', '.join(missing)}")


def block(name):
    rows = rendered.get(name)
    if not rows:
        return ""
    items = "".join(
        f'<tr><td class="c"><span class="m">{html.escape(m)}</span> '
        f'<span class="k">{html.escape(k)}</span></td>'
        f'<td class="d">{html.escape(d)}</td></tr>'
        for m, k, d in rows)
    return (f'<section><h2>{TITLES.get(name, name)}</h2>'
            f'<table>{items}</table></section>')


def column(names):
    return f'<div class="col">{"".join(block(n) for n in names)}</div>'


groups = "".join(
    f'<div class="group"><div class="cols">{"".join(column(c) for c in cols)}</div></div>'
    for _, cols in GROUPS)

mod_label = format_chord(mod + "+x")[0]

HTML = f"""<!doctype html>
<meta charset="utf-8">
<style>
  /* Tomorrow Night — same palette as macos/wallpaper, so both desks match. */
  :root {{
    --bg:#1d1f21; --bg2:#242628; --fg:#c5c8c6; --dim:#8a8f8c;
    --key:#81a2be; --mod:#b294bb; --rule:#33373a; --head:#f0c674;
  }}
  * {{ margin:0; padding:0; box-sizing:border-box; }}
  html {{ width:100%; height:100%; background:var(--bg); overflow:hidden; }}
  body {{
    width:100%; height:100%;
    background:
      radial-gradient(120% 90% at 8% 0%, var(--bg2) 0%, var(--bg) 62%);
    color:var(--fg);
    font-family:"DejaVu Sans Mono",monospace;
    font-size:0.7vw; line-height:1.66;
    padding:2.6vw 3vw 3.4vw 3.4vw;
    display:flex; flex-direction:column; justify-content:center;
    -webkit-font-smoothing:antialiased;
  }}
  header {{ margin-bottom:1.8vw; }}
  h1 {{ font-size:1.5em; font-weight:700; letter-spacing:.22em;
       text-transform:uppercase; }}
  .sub {{ font-size:.95em; color:var(--dim); margin-top:.5em; letter-spacing:.06em; }}
  .sub b {{ color:var(--mod); font-weight:400; }}
  .groups {{ display:flex; gap:3vw; align-items:flex-start; }}
  .group:first-child {{ flex:3; }}
  .group:last-child {{ flex:2; padding-left:3vw;
                       border-left:1px solid var(--rule); }}
  .cols {{ display:flex; gap:2.6vw; align-items:flex-start; }}
  .col {{ flex:1; }}
  section {{ margin-bottom:1.5vw; }}
  section:last-child {{ margin-bottom:0; }}
  h2 {{ font-size:.92em; font-weight:700; letter-spacing:.3em;
       color:var(--head); text-transform:uppercase;
       padding-bottom:.45em; margin-bottom:.7em;
       border-bottom:1px solid var(--rule); }}
  table {{ width:100%; border-collapse:collapse; }}
  td {{ padding:.08em 0; vertical-align:baseline; white-space:nowrap; }}
  .c {{ padding-right:1.3em; width:1%; }}
  .m {{ color:var(--mod); }}
  .k {{ color:var(--key); font-weight:700; letter-spacing:.04em; }}
  .d {{ color:var(--dim); }}
  footer {{ margin-top:2.2vw; font-size:.88em; color:#5a6063;
           letter-spacing:.1em; line-height:2; }}
</style>
<header>
  <h1>Keyboard</h1>
  <div class="sub">i3 &middot; modifier <b>{mod_label}</b> &nbsp;&middot;&nbsp;
    Emacs &middot; custom bindings from emacs.d</div>
</header>
<div class="groups">{groups}</div>
<footer>
  resize mode: {mod_label} R then &larr;&darr;&uarr;&rarr; or J K L M &middot; esc / enter to exit<br>
  system mode: {mod_label} Pause then L lock &middot; E logout &middot; S suspend &middot; H hibernate &middot; R reboot &middot; Shift S shutdown
</footer>
"""

with open(html_path, "w") as fh:
    fh.write(HTML)
print(f"wrote {html_path}")
