;;; early-init.el --- macOS-specific Emacs settings  -*- lexical-binding: t; -*-

;; Deployed by macos/emacs/setup-emacs.sh. Emacs 27+ loads this automatically
;; before init.el, which keeps the fbielejec/emacs.d repo platform-neutral.
;;
;; Everything here is guarded on darwin so the file is harmless if it ever
;; ends up on the Linux machine.

;;; Code:

(when (eq system-type 'darwin)

  ;; Modifier keys.
  ;;
  ;; These are the ns-* names, not mac-*. emacs-plus builds GNU Emacs against
  ;; the NeXTstep port, where ns-command-modifier and friends are the real
  ;; variables; the mac-* names belong to the separate emacs-mac port and are
  ;; at best obsolete aliases here.
  ;;
  ;; Option must stay Meta or every M- binding in a lifetime of muscle memory
  ;; stops working. Command becomes super, which Emacs binds almost nothing to
  ;; by default — that is what lets cmd participate in the AeroSpace modifier
  ;; chord without Emacs and the window manager fighting over the same keys.
  ;;
  ;; If you type Polish diacritics (ą ć ę ł ń ó ś ź ż) with Option, set
  ;; ns-right-option-modifier to 'none so the right Option key still composes
  ;; them while the left one stays Meta.
  (setq ns-command-modifier 'super
        ns-option-modifier 'meta
        ns-right-option-modifier 'meta)

  ;; Fonts. DejaVu Sans Mono is not present on macOS; Menlo ships with the OS.
  ;; The 13 here is points — 1/10pt is the unit of the :height face attribute,
  ;; not of an XLFD-style font string.
  (add-to-list 'default-frame-alist '(font . "Menlo-13"))

  ;; Native fullscreen puts the frame in its own macOS Space, which sits
  ;; outside AeroSpace's tiling tree. Disabling it keeps Emacs tiled.
  (setq ns-use-native-fullscreen nil))

;; Deliberately NOT here:
;;
;;   (exec-path-from-shell-initialize) — the package is not loaded yet at
;;   early-init time. init.el already handles it, which is why macOS GUI
;;   Emacs can see brew, nvm, cargo and pyenv despite launchd handing it a
;;   minimal PATH.
;;
;;   (menu-bar-mode 1) — init.el disables the menu bar afterwards, so setting
;;   it here has no effect. Change it in init.el if you want it on macOS,
;;   where the menu bar costs no frame space.

;;; early-init.el ends here
