;;; yuzuki-langserver-eglot --- Eglot integration
;;; Commentary:
"Eglot integration"
;;; Code:

(if (eq yuzuki-lsp 'eglot)
    (use-package eglot
      :config
      (add-to-list 'eglot-server-programs '((c++-mode c-mode) . ("clangd")))
      (add-to-list 'eglot-server-programs '(python-mode . ("pyright")))
      (add-to-list 'eglot-server-programs '(elixir-mode . ("elixir-ls")))
      (add-to-list 'eglot-server-programs '(nix-mode . ("nil")))
      :hook
      ((c-mode c++-mode ;; -> see ./yuzuki-c.el
	python-mode
	ruby-mode
	rust-mode
	haskell-mode
	nix-mode
	yaml-mode
	elixir-mode
        tex-mode context-mode texinfo-mode bibtex-mode ;; -> see ./yuzuki-tex.el
        ) . eglot-ensure)))

(provide 'yuzuki-langserver-eglot)
;;; yuzuki-langserver-eglot.el ends here
