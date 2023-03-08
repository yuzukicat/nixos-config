;;; shu-langserver-lsp --- lsp-mode config
;;; Commentary:
"Lsp-mode config."
;;; Code:
(if (eq shu-lsp 'lsp-mode)
    ((use-package lsp-mode
       :commands (lsp)
       :hook (prog-mode . lsp)
       :init
       (setq lsp-auto-configure t
             lsp-auto-guess-root t
             lsp-idle-delay 0.500
             lsp-session-file "~/.emacs/.cache/lsp-sessions"))
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
             lsp-lens-enable t))
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
       (define-key yas-minor-mode-map (kbd "S-<tab>") 'yas-expand)
     (use-package yasnippet-snippets
       :after yasnippet)))

(provide 'shu-langserver-lsp)
;;; shu-langserver-lsp.el ends here.
