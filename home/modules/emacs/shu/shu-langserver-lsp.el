;;; shu-langserver-lsp --- lsp-mode config
;;; Commentary:
"Lsp-mode config."
;;; Code:

(use-package lsp-mode
:ensure t
:init
;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
(setq lsp-keymap-prefix "C-c l"
      lsp-file-watch-threshold 500)
:commands (lsp lsp-deferred)
:config
(setq lsp-completion-provider :none) ;; 阻止 lsp 重新设置 company-backend 而覆盖我们 yasnippet 的设置
(setq lsp-headerline-breadcrumb-enable t)
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
            lsp-lens-enable t))

(provide 'shu-langserver-lsp)
;;; shu-langserver-lsp.el ends here.
