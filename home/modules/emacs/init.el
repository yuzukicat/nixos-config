;;; init --- Init file of emacs
;;; Commentary:
"The shu init file of emacs and exwm."
;;; Code:

(package-initialize)
(setq use-package-always-ensure t)
(setq backup-directory-alist '(("." . "~/.backups")))
(add-to-list 'load-path (expand-file-name "shu" user-emacs-directory))

(defgroup shu ()
  "Shu EMACS config."
  :tag "Shu"
  :prefix "shu-"
  :group 'applications)
(defcustom shu-lsp nil
  "Set which LSP to use."
  :tag "LSP config"
  :group 'shu
  :type `(choice
          (const :tag "disabled" ,nil)
          (const :tag "lsp-mode" lsp-mode)
          (const :tag "eglot" eglot)))
(setq shu-lsp 'lsp-mode)
(require 'shu-langserver-lsp)
(require 'shu-langserver-eglot)
(require 'shu-c)
(require 'shu-tex)

(setq confirm-kill-emacs #'yes-or-no-p)      ;; 在关闭 Emacs 前询问是否确认关闭，防止误触
(electric-pair-mode t)                       ;; 自动补全括号
(column-number-mode t)                       ;; 在 Mode line 上显示列号
(global-auto-revert-mode t)                  ;; 当另一程序修改了文件时，让 Emacs 及时刷新 Buffer
(setq make-backup-files nil)                 ;; 关闭文件自动备份
(add-hook 'prog-mode-hook #'hs-minor-mode)   ;; 编程模式下，可以折叠代码块
(global-display-line-numbers-mode 1)         ;; 在 Window 显示行号
(setq display-line-numbers-type 'relative)   ;; （可选）显示相对行号

(global-set-key (kbd "C-z") 'undo)
(global-unset-key (kbd "C-x C-z"))
(global-set-key (kbd "C-M-z") 'linum-mode)
(global-set-key (kbd "C-M-/") 'comment-or-uncomment-region)
(global-set-key (kbd "C-<tab>") 'find-file-at-point)
(define-key global-map (kbd "<mouse-8>") (kbd "M-w"))
(define-key global-map (kbd "<mouse-9>") (kbd "C-y"))
(tool-bar-mode 0) (menu-bar-mode 0) (scroll-bar-mode 0)
(fringe-mode '(10 . 10))
(setq-default cursor-type 'bar
              blink-cursor-interval 0.7
              blink-cursor-blinks 8)

(defalias 'yes-or-no-p 'y-or-n-p)
;; (desktop-save-mode 1) ;; auto save window
(setq inhibit-splash-screen t ;; hide welcome screen
      mouse-drag-copy-region nil)
(setq-default indent-tabs-mode -1)
(setq backward-delete-char-untabify-method nil)
(define-minor-mode show-trailing-whitespace-mode "Show trailing whitespace."
  :init-value nil
  :lighter nil
  (progn (setq show-trailing-whitespace show-trailing-whitespace-mode)))
(define-minor-mode require-final-newline-mode "Require final newline."
  :init-value nil
  :lighter nil
  (progn (setq require-final-newline require-final-newline-mode)))
(add-hook 'prog-mode-hook 'show-trailing-whitespace-mode)
(add-hook 'prog-mode-hook 'require-final-newline-mode)
(add-hook 'prog-mode-hook #'(lambda () (indent-tabs-mode -1)))

(use-package ligature
  :diminish ligature-mode
  :config
  (ligature-set-ligatures 't '("www"))
  (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                                       ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                                       "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                                       "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                                       "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                                       "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                                       "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                                       "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                                       ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                                       "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                                       "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                                       "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                                       "\\\\" "://"))
  (global-ligature-mode t))

(use-package diminish
  :config
  (diminish 'eldoc-mode)) ;; other configs are in use-package :diminish

(use-package magit
  :bind (("C-x g g" . magit-status)
         ("C-x g b" . magit-blame)
         ("C-x g d" . magit-diff-buffer-file)))

;; Window Management
(use-package winum
  :config (winum-mode))

;; hydra
(use-package hydra)

(use-package use-package-hydra
  :after hydra)

;; multiple-cursors
(use-package multiple-cursors
  :ensure t
  :after hydra
  :bind
  (("C-x C-h m" . hydra-multiple-cursors/body)
   ("C-S-<mouse-1>" . mc/toggle-cursor-on-click))
  :hydra (hydra-multiple-cursors
		  (:hint nil)
		  "
Up^^             Down^^           Miscellaneous           % 2(mc/num-cursors) cursor%s(if (> (mc/num-cursors) 1) \"s\" \"\")
------------------------------------------------------------------
 [_p_]   Prev     [_n_]   Next     [_l_] Edit lines  [_0_] Insert numbers
 [_P_]   Skip     [_N_]   Skip     [_a_] Mark all    [_A_] Insert letters
 [_M-p_] Unmark   [_M-n_] Unmark   [_s_] Search      [_q_] Quit
 [_|_] Align with input CHAR       [Click] Cursor at point"
		  ("l" mc/edit-lines :exit t)
		  ("a" mc/mark-all-like-this :exit t)
		  ("n" mc/mark-next-like-this)
		  ("N" mc/skip-to-next-like-this)
		  ("M-n" mc/unmark-next-like-this)
		  ("p" mc/mark-previous-like-this)
		  ("P" mc/skip-to-previous-like-this)
		  ("M-p" mc/unmark-previous-like-this)
		  ("|" mc/vertical-align)
		  ("s" mc/mark-all-in-region-regexp :exit t)
		  ("0" mc/insert-numbers :exit t)
		  ("A" mc/insert-letters :exit t)
		  ("<mouse-1>" mc/add-cursor-on-click)
		  ;; Help with click recognition in this hydra
		  ("<down-mouse-1>" ignore)
		  ("<drag-mouse-1>" ignore)
		  ("q" nil)))

;; Ivy tool set
(use-package ivy
  :diminish ivy-mode
  :init
  (ivy-mode 1)
  (counsel-mode 1)
  :config
  (ivy-mode)
  (define-key global-map (kbd "C-x b") 'ivy-switch-buffer)
  (define-key global-map (kbd "C-c v") 'ivy-push-view)
  (define-key global-map (kbd "C-c V") 'ivy-pop-view))
(use-package counsel
  :config
  (define-key global-map (kbd "M-x") 'counsel-M-x)
  (define-key global-map (kbd "C-x C-f") 'counsel-find-file)
  (define-key global-map (kbd "M-y") 'counsel-yank-pop)
  (define-key global-map (kbd "<f1> f") 'counsel-describe-function)
  (define-key global-map (kbd "<f1> v") 'counsel-describe-variable)
  (define-key global-map (kbd "<f1> l") 'counsel-find-library)
  (define-key global-map (kbd "<f2> i") 'counsel-info-lookup-symbol)
  (define-key global-map (kbd "<f2> u") 'counsel-unicode-char)
  (define-key global-map (kbd "<f2> j") 'counsel-set-variable))
(use-package swiper
  :config (define-key global-map (kbd "C-s") 'swiper-isearch))

;; Zoxide find file
(use-package zoxide
  :hook ((find-file
          counsel-find-file) . zoxide-add))
(use-package fzf
  :bind (("C-c f" . fzf-directory)
         ("C-c s" . fzf-grep)
         ("C-c S-f" . fzf-git)
         ("C-c S-s" . fzf-git-grep)))

;; Regex replace
(use-package anzu
  :bind ("C-r" . anzu-query-replace-regexp))

;; Spell check and auto fill
(use-package flycheck
  :config
  (setq truncate-lines nil) ;; 如果单行信息很长会自动换行
  :hook
  (prog-mode . flycheck-mode))
(use-package company
  :diminish company-mode
  :hook (after-init . global-company-mode)
  :bind ("M-<tab>". company-complete-selection)
  :config
  (setq company-tooltip-align-annotations t
        company-tooltip-limit 10
        company-show-quick-access t
        company-show-numbers t ;; 给选项编号 (按快捷键 M-1、M-2 等等来进行选择).
        company-selection-wrap-around t
        company-idle-delay 0
        company-tooltip-idle-delay 0
        company-transformers '(company-sort-by-occurrence) ;; 根据选择的频率进行排序
        company-minimum-prefix-length 1)) ;; 只需敲 1 个字母就开始进行自动补全
(use-package company-box
  :if window-system
  :hook (company-mode . company-box-mode))
(global-set-key (kbd "M-/") 'hippie-expand)

;; Theme
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)

  ;; FIXME: These below are now global. We should patch doom
  ;;        themes to let them display correctly in terminal.
  ;; (defun new-frame-setup (frame)
  ;;   (if (display-graphic-p frame)
  (load-theme 'doom-tomorrow-day t)
  ;;     (disable-theme 'doom-tomorrow-day)))
  ;; (mapc 'new-frame-setup (frame-list))
  ;; (add-hook 'after-make-frame-functions 'new-frame-setup)
  )
;; (add-to-list 'load-path "~/.emacs.d/awesome-tray")
;; (require 'awesome-tray)
;; (setq awesome-tray-mode-line-inactive-color "#d6d4d4"
;;       awesome-tray-mode-line-active-color "#8abeb7"
;;       awesome-tray-mode-line-height 0.1)
;; (awesome-tray-mode 1)


;; Parentheses and highlight TODO
(add-hook 'prog-mode-hook #'show-paren-mode) ;; 编程模式下，光标在括号上时高亮另一个括号
(setq show-paren-style 'parenthesis)
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))
(use-package hl-todo
  :hook (prog-mode . hl-todo-mode)
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold)
          ("DEBUG"      error bold))))

;; Language modes
(use-package nix-mode)
(use-package markdown-mode)
(use-package yaml-mode)
(use-package rust-mode)
(use-package elixir-mode)
(use-package cargo)

;; Dired
(use-package dired-single
  :config
  (defun my-dired-init ()
    "Bunch of stuff to run for dired, either immediately or when it's
   loaded."
    ;; <add other stuff here>
    (define-key dired-mode-map [remap dired-find-file]
                'dired-single-buffer)
    (define-key dired-mode-map [remap dired-mouse-find-file-other-window]
                'dired-single-buffer-mouse)
    (define-key dired-mode-map [remap dired-up-directory]
                'dired-single-up-directory))

  ;; if dired's already loaded, then the keymap will be bound
  (if (boundp 'dired-mode-map)
      ;; we're good to go; just add our bindings
      (my-dired-init)
    ;; it's not loaded yet, so add our bindings to the load-hook
    (with-eval-after-load 'dired-mode (my-dired-init))))
(use-package dirvish
  :config (dirvish-override-dired-mode))

;; PDF
(use-package pdf-tools
  :config
  (pdf-tools-install)
  ;; Pdf and swiper does not work together
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward-regexp))

;; To live on the tree “Shēnghuó zài shù shàng”
(use-package tree-sitter
  :hook (tree-sitter-mode . tree-sitter-hl-mode)
  :config (global-tree-sitter-mode)
  (diminish 'tree-sitter-mode " 🌲"))
(use-package tree-sitter-langs
  :config
  (add-to-list 'tree-sitter-major-mode-language-alist '(markdown-mode . markdown))
  (add-to-list 'tree-sitter-major-mode-language-alist '(yaml-mode . yaml)))

;; mwim
(use-package mwim
  :config
  :bind
  ("C-a" . mwim-beginning-of-code-or-line)
  ("C-e" . mwim-end-of-code-or-line))

;; Undo tree
(use-package undo-tree
  :delight
  :diminish undo-tree-mode
  :config
  (setq undo-tree-visualizer-timestamps t
        undo-tree-visualizer-diff t
        undo-tree-auto-save-history nil
        ;; undo-tree-history-directory-alist `(("." . ,(expand-file-name ".cache/undo-tree/" user-emacs-directory)))
        )
  (global-undo-tree-mode))

(use-package good-scroll
  :if window-system          ;; 在图形化界面时才使用这个插件
  :init (good-scroll-mode))

(use-package toggle-one-window
  :bind ("C-c 1" . toggle-one-window))

;; Lsp-bridge
;; (use-package posframe)
;; (use-package markdown-mode)
;; (use-package yasnippet)
;; (add-to-list 'load-path "~/.emacs.d/lsp-bridge")
;; (require 'lsp-bridge)
;; (yas-global-mode 1)
;; (global-lsp-bridge-mode)
;; (setq lsp-bridge-enable-hover-diagnostic t
;;       lsp-bridge-enable-auto-format-code t
;;       acm-enable-doc t
;;       acm-enable-icon t
;;       acm-enable-quick-access t)

(provide 'init)
;;; init.el ends here
