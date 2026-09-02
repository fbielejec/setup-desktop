# QMK keymap changes for the macOS setup

## The one required change

Put this on the Caps Lock position:

```c
LAG_T(KC_ESC)
```

If your QMK version lacks the `LAG_T` alias, the explicit form is identical:

```c
MT(MOD_LALT | MOD_LGUI, KC_ESC)
```

- **Held** → `LALT | LGUI` = Option+Command. This is `SETUP_MOD`, the AeroSpace
  modifier.
- **Tapped** → Escape. Standard Emacs-friendly Caps Lock treatment.

## Why Alt+Cmd rather than Hyper

The point is that **both keyboards produce the same chord**. The built-in
MacBook keyboard can make Option+Command with a thumb roll; it cannot make a
Hyper chord at all, and macOS's native modifier remapping only maps Caps Lock to
a *single* modifier, never a combination.

So if the QMK board sent Hyper, you would have two different gestures for every
window-manager action — Caps Lock on one keyboard, a thumb chord on the other.
One binding set and one gesture is worth more than a marginally cleaner
collision profile.

What the QMK board buys you is comfort, not capability: one key where the
laptop needs two thumbs.

### What this costs

`alt-cmd` is a two-modifier chord, so it shadows a few macOS shortcuts.
AeroSpace grabs bound chords globally, before any app sees them. In practice
one matters:

- **`Cmd+Option+H` (Hide Others)** stops working — `alt-cmd-h` is bound to
  `layout h_tiles`, mirroring i3's `$mod+h` split.

`Cmd+Option+D` (Dock) and `Cmd+Option+Esc` (Force Quit) are unaffected: neither
`d` nor `esc` is bound in main mode.

### If you later want Hyper anyway

Change the keymap to `LCAG_T(KC_ESC)` (`LCTL|LALT|LGUI`) and set in
`macos/config.sh`:

```sh
SETUP_MOD="ctrl-alt-cmd"
SETUP_MOD_FALLBACK="alt-cmd"    # so the built-in keyboard still works
SETUP_QMK_HYPER="true"
```

`setup-aerospace.sh` then renders the binding block twice, once per modifier.
Note `LCAG`, not QMK's `HYPR` — `HYPR` is `LCTL|LSFT|LALT|LGUI` and includes
Shift, which would make the `+Shift` variant of every binding unexpressible.

## The bottom row: PC and Mac disagree

This bites everyone once. The physical order of the two modifiers left of the
spacebar is reversed between the two conventions:

| | left of space, outward |
|---|---|
| PC layout | `Ctrl` `GUI(Win)` `Alt` `Space` |
| Mac layout | `Ctrl` `Alt(Option)` `GUI(Cmd)` `Space` |

So a PC-layout board plugged into a Mac puts Alt where your thumb expects Cmd,
and every `Cmd+C` / `Cmd+V` lands wrong. Three fixes, in order of preference:

1. **A Mac layer in firmware** with `KC_LALT` and `KC_LGUI` swapped on the
   bottom row. Travels with the keyboard, works on any machine.
2. **`AG_SWAP`** — QMK's built-in Alt/GUI swap (`AG_NORM` to undo, `AG_TOGG` to
   toggle). One keycode, but a global toggle whose state you must track.
3. **macOS per-device remapping** — System Settings → Keyboard → Modifier
   Keys, then pick the external keyboard from the dropdown. Per-device, so it
   leaves the built-in keyboard alone. Does not travel with the keyboard.

This does **not** affect `LAG_T(KC_ESC)`: that sends both modifiers at once, so
their physical positions are irrelevant.

## Flashing from the work machine

Flashing needs a USB connection and, depending on the bootloader, `dfu-util` or
`avrdude` — and entering bootloader mode makes the keyboard enumerate as a new
USB device. On a managed laptop with USB device controls that may be blocked or
logged.

If it is, flash from the Linux desktop instead. The firmware is identical; only
the machine doing the flashing differs. `macos/qmk/setup-qmk.sh` installs the
toolchain but is off by default for this reason.
