;; mime-diff.el -*- lexical-binding:t -*-
;;; Add diff patch highlighting to mime-view
(require 'diff-mode)
(eval-when-compile (require 'mime-view))

(defun mime-display-font-lock-diff ()
  (let ((font-lock-defaults diff-font-lock-defaults)
        (diff-buffer-type 'git))
    (font-lock-ensure)))

(defun mime-display-conditional-enable-diff ()
  (goto-char (point-min))
  (while (re-search-forward
          "^--- .*\n\\+\\+\\+ .*\n\\([-+ ].*\n\\|@@ .* @@.*\n\\)+" nil t)
    (save-restriction
      (narrow-to-region (match-beginning 0) (match-end 0))
      (mime-display-font-lock-diff)
      (goto-char (point-max)))))

(add-hook 'mime-display-text/plain-hook #'mime-display-conditional-enable-diff)

(defun mime-display-text/x-diff (entity _situation)
  (save-restriction
    (narrow-to-region (point-max)(point-max))
    (when (mime-display-insert-text-content entity)
      (remove-text-properties (point-min) (point-max) '(face nil))
      (mime-display-font-lock-diff))))

(defalias 'mime-display-text/x-patch #'mime-display-text/x-diff)
(defalias 'mime-display-application/x-patch #'mime-display-text/x-diff)

(ctree-set-calist-strictly
 'mime-preview-condition
 '((type . text)(subtype . x-diff)
   (body . visible)
   (body-presentation-method . mime-display-text/x-diff)))

(ctree-set-calist-strictly
 'mime-preview-condition
 '((type . text)(subtype . x-patch)
   (body . visible)
   (body-presentation-method . mime-display-text/x-patch)))

(ctree-set-calist-strictly
 'mime-preview-condition
 '((type . application)(subtype . x-patch)
   (body . visible)
   (body-presentation-method . mime-display-application/x-patch)))

(provide 'mime-diff)
