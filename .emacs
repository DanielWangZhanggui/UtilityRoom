
(setq x-select-enable-clipboard t) ; as above
(setq interprogram-paste-function 'x-cut-buffer-or-selection-value)
(put 'erase-buffer 'disabled nil)
(add-to-list 'default-frame-alist '(foreground-color . "green"))
(add-to-list 'default-frame-alist '(background-color . "black"))
(add-to-list 'default-frame-alist '(cursor-color . "coral"))

;disable backup
;(setq backup-inhibited t)
(setq backup-directory-alist `(("." . "~/.saves")))
(defvar *linum-mdown-line* nil)

(defun line-at-click ()
  (save-excursion
	(let ((click-y (cdr (cdr (mouse-position))))
		  (line-move-visual-store line-move-visual))
	  (setq line-move-visual t)
	  (goto-char (window-start))
	  (next-line (1- click-y))
	  (setq line-move-visual line-move-visual-store)
	  ;; If you are using tabbar substitute the next line with
	  ;; (line-number-at-pos))))
	  (1+ (line-number-at-pos)))))

(defun md-select-linum ()
  (interactive)
  (goto-line (line-at-click))
  (set-mark (point))
  (setq *linum-mdown-line*
		(line-number-at-pos)))

(defun mu-select-linum ()
  (interactive)
  (when *linum-mdown-line*
	(let (mu-line)
	  ;; (goto-line (line-at-click))
	  (setq mu-line (line-at-click))
	  (goto-line (max *linum-mdown-line* mu-line))
	  (set-mark (line-end-position))
	  (goto-line (min *linum-mdown-line* mu-line))
	  (setq *linum-mdown*
			nil))))


(global-set-key (kbd "<left-margin> <down-mouse-1>") 'md-select-linum)
(global-set-key (kbd "<left-margin> <mouse-1>") 'mu-select-linum)
(global-set-key (kbd "<left-margin> <drag-mouse-1>") 'mu-select-linum)


(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/auto-complete")
(require 'auto-complete)
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/auto-complete/ac-dict")
(ac-config-default)
(local-set-key (kbd "M-/") 'semantic-complete-analyze-inline)
(local-set-key "." 'semantic-complete-self-insert)
(local-set-key ">" 'semantic-complete-self-insert)


;(require 'go-autocomplete)
;(require 'auto-complete-config)
;(require 'go-mode-load)
;(require 'speedbar)
;(require 'speedbar-extension)
;(require 'sr-speedbar)
;(speedbar-add-supported-extension ".go")


;; golang mode
(require 'go-mode-load)
(require 'go-autocomplete)
;; speedbar
(speedbar 1)
(speedbar-add-supported-extension ".go")
(add-hook
'go-mode-hook
'(lambda ()
    ;; gocode
    (auto-complete-mode 1)
    (setq ac-sources '(ac-source-go))
    ;; Imenu & Speedbar
    (setq imenu-generic-expression
        '(("type" "^type *\\([^ \t\n\r\f]*\\)" 1)
        ("func" "^func *\\(.*\\) {" 1)))
    (imenu-add-to-menubar "Index")
    ;; Outline mode
    (make-local-variable 'outline-regexp)
    (setq outline-regexp "//\\.\\|//[^\r\n\f][^\r\n\f]\\|pack\\|func\\|impo\\|cons\\|var.\\|type\\|\t\t*....")
    (outline-minor-mode 1)
    (local-set-key "\M-a" 'outline-previous-visible-heading)
    (local-set-key "\M-e" 'outline-next-visible-heading)
    ;; Menu bar
    (require 'easymenu)
    (defconst go-hooked-menu
        '("Go tools"
        ["Go run buffer" go t]
        ["Go reformat buffer" go-fmt-buffer t]
        ["Go check buffer" go-fix-buffer t]))
    (easy-menu-define
        go-added-menu
        (current-local-map)
        "Go tools"
        go-hooked-menu)

    ;; Other
    (setq show-trailing-whitespace t)
    ))
;; helper function
(defun go ()
    "run current buffer"
    (interactive)
    (compile (concat "go run " (buffer-file-name))))

;; helper function
(defun go-fmt-buffer ()
    "run gofmt on current buffer"
    (interactive)
    (if buffer-read-only
    (progn
        (ding)
        (message "Buffer is read only"))
    (let ((p (line-number-at-pos))
    (filename (buffer-file-name))
    (old-max-mini-window-height max-mini-window-height))
        (show-all)
        (if (get-buffer "*Go Reformat Errors*")
    (progn
        (delete-windows-on "*Go Reformat Errors*")
        (kill-buffer "*Go Reformat Errors*")))
        (setq max-mini-window-height 1)
        (if (= 0 (shell-command-on-region (point-min) (point-max) "gofmt" "*Go Reformat Output*" nil "*Go Reformat Errors*" t))
    (progn
        (erase-buffer)
        (insert-buffer-substring "*Go Reformat Output*")
        (goto-char (point-min))
        (forward-line (1- p)))
    (with-current-buffer "*Go Reformat Errors*"
    (progn
        (goto-char (point-min))
        (while (re-search-forward "<standard input>" nil t)
        (replace-match filename))
        (goto-char (point-min))
        (compilation-mode))))
        (setq max-mini-window-height old-max-mini-window-height)
        (delete-windows-on "*Go Reformat Output*")
        (kill-buffer "*Go Reformat Output*"))))
;; helper function
(defun go-fix-buffer ()
    "run gofix on current buffer"
    (interactive)
    (show-all)
    (shell-command-on-region (point-min) (point-max) "go tool fix -diff"))
