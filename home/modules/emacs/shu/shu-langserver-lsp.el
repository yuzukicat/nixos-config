;;; shu-langserver-lsp --- lsp-mode config
;;; Commentary:
"Lsp-mode config."
;;; Code:
(if (eq shu-lsp 'lsp-mode)
    ((use-package lsp-mode
       :commands (lsp)
       :hook (prog-mode . lsp))
     (use-package lsp-ivy
       :diminish
       :after lsp-mode)
     (use-package lsp-ui
       :after (lsp-mode)
       :diminish
       :commands (lsp-ui-mode)
       :hook (lsp-mode . lsp-ui-mode)
       :init
       ;; https://github.com/emacs-lsp/lsp-mode/blob/master/docs/tutorials/how-to-turn-off.md
       (setq lsp-enable-symbol-highlighting t
             lsp-ui-doc-enable t
             lsp-lens-enable t))))

(provide 'shu-langserver-lsp)
;;; shu-langserver-lsp.el ends here.
