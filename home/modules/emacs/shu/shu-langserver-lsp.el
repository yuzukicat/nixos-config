;;; shu-langserver-lsp --- lsp-mode config
;;; Commentary:
"Lsp-mode config."
;;; Code:
(if (eq shu-lsp 'lsp-mode)
    ((use-package lsp-mode
       :commands (lsp lsp-deferred)
       :hook (prog-mode . lsp)
       :config
       (setq lsp-completion-provider :none) ;; 阻止 lsp 重新设置 company-backend 而覆盖我们 yasnippet 的设置
       (setq lsp-headerline-breadcrumb-enable t)
       :init
       (setq lsp-auto-configure t
             lsp-auto-guess-root t
             lsp-idle-delay 0.500
             lsp-session-file "~/.emacs/.cache/lsp-sessions"
             lsp-keymap-prefix "C-c l"))
     (use-package lsp-ivy
       :diminish
       :after lsp-mode)
     (use-package lsp-ui
       :after (lsp-mode)
       :diminish
       :commands (lsp-ui-mode)
       :bind
       (:map lsp-ui-mode-map
             ("M-?" . lsp-ui-peek-find-references)
             ("M-." . lsp-ui-peek-find-definitions)
             ("C-c u" . lsp-ui-imenu))
       :hook (lsp-mode . lsp-ui-mode)
       :init
       ;; https://github.com/emacs-lsp/lsp-mode/blob/master/docs/tutorials/how-to-turn-off.md
       (setq lsp-enable-symbol-highlighting t
             lsp-ui-doc-enable t
             lsp-lens-enable t))))
    (use-package projectile
       :ensure t
       :bind (("C-c p" . projectile-command-map))
       :config
       (setq projectile-mode-line "Projectile")
       (setq projectile-track-known-projects-automatically nil))
    (use-package counsel-projectile
       :ensure t
       :after (projectile)
       :init (counsel-projectile-mode))
    ((use-package treemacs
       :ensure t
       :defer t
       :config
       (treemacs-tag-follow-mode)
       :bind
       :map global-map
              ("M-0"       . treemacs-select-window)
              ("C-x t 1"   . treemacs-delete-other-windows)
              ("C-x t t"   . treemacs)
              ("C-x t B"   . treemacs-bookmark)
              ;; ("C-x t C-t" . treemacs-find-file)
              ("C-x t M-t" . treemacs-find-tag))
       (:map treemacs-mode-map
              ("/" . treemacs-advanced-helpful-hydra)))
    (use-package treemacs-projectile
       :ensure t
       :after (treemacs projectile))
    (use-package lsp-treemacs
       :ensure t
       :after (treemacs lsp))
       ;; Go - lsp-mode
       ;; Set up before-save hooks to format buffer and add/delete imports.
    (use-package treemacs-icons-dired
       :hook (dired-mode . treemacs-icons-dired-enable-once)
       :ensure t)
    (use-package treemacs-tab-bar ;;treemacs-tab-bar if you use tab-bar-mode
       :after (treemacs)
       :ensure t
       :config (treemacs-set-scope-type 'Tabs))
    (use-package yasnippet
       :ensure t
       :hook
       (prog-mode . yas-minor-mode)
       :config
       (yas-reload-all)
       ;; add company-yasnippet to company-backends
       (defun company-mode/backend-with-yas (backend)
              (if (and (listp backend) (member 'company-yasnippet backend))
                            backend
              (append (if (consp backend) backend (list backend))
                            '(:with company-yasnippet))))
       (setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))
       ;; unbind <TAB> completion
       (define-key yas-minor-mode-map [(tab)]        nil)
       (define-key yas-minor-mode-map (kbd "TAB")    nil)
       (define-key yas-minor-mode-map (kbd "<tab>")  nil)
       :bind
       (:map yas-minor-mode-map ("S-<tab>" . yas-expand)))
    (use-package yasnippet-snippets
       :ensure t
       :after yasnippet)
    (defun lsp-go-install-save-hooks ()
       (add-hook 'before-save-hook #'lsp-format-buffer t t)
       (add-hook 'before-save-hook #'lsp-organize-imports t t))
    (add-hook 'go-mode-hook #'lsp-go-install-save-hooks)
    ;; Start LSP Mode and YASnippet mode
    (add-hook 'go-mode-hook #'lsp-deferred)
    (add-hook 'go-mode-hook #'yas-minor-mode)

(provide 'shu-langserver-lsp)
;;; shu-langserver-lsp.el ends here.
