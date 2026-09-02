#!/usr/bin/env python3
"""Render shortcuts.tsv into the wallpaper HTML.

Called by generate-wallpaper.sh. The TSV is the authority for which chords
exist (generate-wallpaper.sh cross-checks it against the real keymap); this
script only decides how they are displayed.
"""
import re
import sys
from collections import OrderedDict

tsv_path, html_path, mod = sys.argv[1], sys.argv[2], sys.argv[3]

# --- chord formatting --------------------------------------------------------
# macOS renders modifiers in a fixed order: Control, Option, Shift, Command.
MOD_SYMBOL = OrderedDict([("ctrl", "⌃"), ("alt", "⌥"),
                          ("shift", "⇧"), ("cmd", "⌘")])
KEY_SYMBOL = {"left": "←", "down": "↓", "up": "↑",
              "right": "→", "tab": "⇥", "space": "␣",
              "esc": "esc", "enter": "⏎"}


def format_chord(chord):
    parts = chord.split("-")
    mods = [p for p in parts if p in MOD_SYMBOL]
    keys = [p for p in parts if p not in MOD_SYMBOL]
    out = "".join(sym for name, sym in MOD_SYMBOL.items() if name in mods)
    key = "".join(KEY_SYMBOL.get(k, k.upper()) for k in keys)
    return out, key


# --- display collapsing ------------------------------------------------------
# Families of near-identical bindings are shown as one row. The TSV still lists
# every member so the cross-check stays exact.
COLLAPSE = [
    (r"^alt-cmd-(left|down|up|right)$", "⌥⌘", "←↓↑→", "focus window"),
    (r"^alt-cmd-shift-(left|down|up|right)$", "⌥⇧⌘", "←↓↑→", "move window"),
    (r"^alt-cmd-[1-9]$", "⌥⌘", "1–9", "switch to workspace"),
    (r"^alt-cmd-shift-[1-9]$", "⌥⇧⌘", "1–9", "send window to workspace"),
    (r"^alt-cmd-shift-(c|r)$", "⌥⇧⌘", "C / R", "reload config"),
]


def collapse(rows):
    """Replace each COLLAPSE family with a single row, keeping order."""
    out, consumed = [], set()
    for chord, desc in rows:
        matched = False
        for i, (pat, mods, key, label) in enumerate(COLLAPSE):
            if re.match(pat, chord):
                matched = True
                if i not in consumed:
                    consumed.add(i)
                    out.append((mods, key, label))
                break
        if not matched:
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

# Emacs rows are literal text, not AeroSpace chords, so they bypass formatting.
LITERAL = {"EMACS", "EMACS-MAC"}
rendered = OrderedDict()
for name, rows in sections.items():
    if name in LITERAL:
        rendered[name] = [("", c, d) for c, d in rows]
    else:
        rendered[name] = collapse(rows)

TITLES = {
    "FOCUS": "Focus", "MOVE": "Move", "LAYOUT": "Layout", "WINDOW": "Window",
    "WORKSPACE": "Workspaces", "SYSTEM": "System",
    "EMACS": "Emacs", "EMACS-MAC": "Emacs on macOS",
}
# Balanced by row count, not by topic: EMACS alone is as long as FOCUS, MOVE,
# WINDOW and WORKSPACE together.
COLUMNS = [["FOCUS", "MOVE", "WINDOW", "WORKSPACE"],
           ["LAYOUT", "SYSTEM"],
           ["EMACS", "EMACS-MAC"]]


def block(name):
    rows = rendered.get(name)
    if not rows:
        return ""
    items = "".join(
        f'<tr><td class="m">{m}</td><td class="k">{k}</td>'
        f'<td class="d">{d}</td></tr>'
        for m, k, d in rows)
    return (f'<section><h2>{TITLES.get(name, name)}</h2>'
            f'<table>{items}</table></section>')


columns = "".join(f'<div class="col">{"".join(block(n) for n in c)}</div>'
                  for c in COLUMNS)

mod_sym, _ = format_chord(mod)

HTML = f"""<!doctype html>
<meta charset="utf-8">
<style>
  /* Tomorrow Night — the palette already referenced in bash/alacritty.toml's
     upstream template, and close to the i3 client colours. */
  :root {{
    --bg:#1d1f21; --bg2:#242628; --fg:#c5c8c6; --dim:#8a8f8c;
    --key:#81a2be; --mod:#b294bb; --rule:#33373a; --head:#f0c674;
  }}
  * {{ margin:0; padding:0; box-sizing:border-box; }}
  /* Background on html as well as body: body alone leaves an unpainted strip
     when the content box is shorter than the viewport. */
  html {{ width:100%; height:100%; background:var(--bg); overflow:hidden; }}
  body {{
    width:100%; height:100%;
    background:
      radial-gradient(120% 90% at 8% 0%, var(--bg2) 0%, var(--bg) 62%);
    color:var(--fg);
    font-family:"DejaVu Sans Mono","Menlo",monospace;
    font-size:0.78vw; line-height:1.72;
    padding:3.4vw 3.2vw 2.6vw 4vw;
    display:flex; flex-direction:column; justify-content:center;
    -webkit-font-smoothing:antialiased;
  }}
  header {{ margin-bottom:2.1vw; }}
  h1 {{ font-size:1.5em; font-weight:700; letter-spacing:.22em;
       color:var(--fg); text-transform:uppercase; }}
  .sub {{ font-size:.95em; color:var(--dim); margin-top:.5em; letter-spacing:.06em; }}
  .sub b {{ color:var(--mod); font-weight:400; }}
  /* Right third stays clear: macOS stacks desktop icons from the top-right. */
  .cols {{ display:flex; gap:3.2vw; width:80%; align-items:flex-start; }}
  .col {{ flex:1; }}
  section {{ margin-bottom:1.7vw; break-inside:avoid; }}
  section:last-child {{ margin-bottom:0; }}
  h2 {{ font-size:.92em; font-weight:700; letter-spacing:.3em;
       color:var(--head); text-transform:uppercase;
       padding-bottom:.45em; margin-bottom:.7em;
       border-bottom:1px solid var(--rule); }}
  table {{ width:100%; border-collapse:collapse; }}
  td {{ padding:.1em 0; vertical-align:baseline; white-space:nowrap; }}
  .m {{ color:var(--mod); text-align:right; padding-right:.55em;
       font-size:1.2em; width:1%; }}
  .k {{ color:var(--key); padding-right:1.1em; font-weight:700; width:1%;
       letter-spacing:.06em; }}
  .d {{ color:var(--dim); width:98%; white-space:normal; }}
  footer {{ margin-top:2.4vw; font-size:.88em; color:#5a6063;
           letter-spacing:.12em; }}
</style>
<header>
  <h1>Window Manager</h1>
  <div class="sub">AeroSpace &middot; modifier <b>{mod_sym}</b>
    &mdash; Caps Lock on the QMK board, Option+Command on the built-in keyboard</div>
</header>
<div class="cols">{columns}</div>
<footer>resize mode: {mod_sym}R then &larr;&darr;&uarr;&rarr; or J K L M &middot; esc to exit</footer>
"""

with open(html_path, "w") as fh:
    fh.write(HTML)
print(f"wrote {html_path}")
