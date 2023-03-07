;; Just enough to load the "real" init file
(require 'use-package)
(setq use-package-verbose t
      tool-bar-mode -1
      scroll-bar-mode -1)
(when (not (window-system))
  (menu-bar-mode -1))

(setq-default debug-on-error t)