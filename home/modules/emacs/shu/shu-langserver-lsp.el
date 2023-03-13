;;; shu-langserver-lsp --- lsp-mode config
;;; Commentary:
"Lsp-mode config."
;;; Code:

(add-to-list 'load-path (expand-file-name "lib/lsp-mode" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "lib/lsp-mode/clients" user-emacs-directory))

(use-package lsp-mode
      :commands (lsp lsp-deferred)
      :hook (prog-mode . lsp)
      :init
      (setq lsp-auto-configure t
            lsp-auto-guess-root t
            lsp-idle-delay 0.500
            lsp-keymap-prefix "C-c l"
	          lsp-file-watch-threshold 500
            lsp-session-file "~/.emacs/.cache/lsp-sessions")
      :custom
      (lsp-enable-snippet t)
      (lsp-keep-workspace-alive t)
      (lsp-enable-xref t)
      (lsp-enable-imenu t)
      (lsp-enable-completion-at-point nil)
      :config
      (setq lsp-completion-provider :none) ;; 阻止 lsp 重新设置 company-backend 而覆盖我们 yasnippet 的设置
      (setq lsp-headerline-breadcrumb-enable t)
      (add-hook 'go-mode-hook #'lsp)
      (add-hook 'python-mode-hook #'lsp)
      (add-hook 'c++-mode-hook #'lsp)
      (add-hook 'c-mode-hook #'lsp)
      (add-hook 'rust-mode-hook #'lsp)
      (add-hook 'html-mode-hook #'lsp)
      (add-hook 'js-mode-hook #'lsp)
      (add-hook 'typescript-mode-hook #'lsp)
      (add-hook 'json-mode-hook #'lsp)
      (add-hook 'yaml-mode-hook #'lsp)
      (add-hook 'dockerfile-mode-hook #'lsp)
      (add-hook 'shell-mode-hook #'lsp)
      (add-hook 'css-mode-hook #'lsp)
      :bind
      ("C-c l s" . lsp-ivy-workspace-symbol)) ;; 可快速搜索工作区内的符号（类名、函数名、变量名等）
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
            lsp-lens-enable t
            lsp-ui-doc-include-signature t
            lsp-enable-snippet nil
            lsp-ui-sideline-enable nil
            lsp-ui-peek-enable nil
            lsp-ui-doc-position 'top
            lsp-ui-doc-header                nil
            lsp-ui-doc-border                "white"
            lsp-ui-sideline-update-mode      'point
            lsp-ui-sideline-delay            1
            lsp-ui-sideline-ignore-duplicate t
            lsp-ui-peek-always-show          t
            lsp-ui-flycheck-enable           nil
            )
      :config
      (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
      (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
      (setq lsp-ui-sideline-ignore-duplicate t))

(setq lsp-prefer-capf t)

(use-package yasnippet
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
  :after yasnippet)

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

(use-package treemacs
  :ensure t
  :defer t
  :config
  ;; (treemacs-tag-follow-mode)
  (treemacs-project-follow-mode)
  :bind
  (:map global-map
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
  :after (treemacs lsp)
  :config
  (setq lsp-treemacs-sync-mode 1)
  )

(provide 'shu-langserver-lsp)
;;; shu-langserver-lsp.el ends here.
