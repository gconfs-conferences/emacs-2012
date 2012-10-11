;;
;; emacs configuration
;;
;; Made by mefyl <mefyl@lrde.epita.fr>
;; Updated by pelleg_c@epita.fr & mercie_d@epita.fr
;;
;; Based on Nicolas Despres <despre_n@lrde.epita.fr> configuration
;; Thanks go to Micha <micha@lrde.epita.fr> for his help

;; Load local distribution configuration file
(add-to-list 'load-path "~/.emacs.d/")


(autoload 'make-regexp "make-regexp"
  "Return a regexp to match a string item in STRINGS.")

(autoload 'make-regexps "make-regexp"
   "Return a regexp to REGEXPS.")

;; tiger mode
(autoload 'tiger-mode "tiger" "Load tiger-mode" t)
(add-to-list 'auto-mode-alist '("\\.ti[gh]$" . tiger-mode))
(autoload 'flex-mode "flex-mode" "Load flex" t)
(add-to-list 'auto-mode-alist '("\\.ll$" . flex-mode))

(add-to-list 'load-path "~/.emacs.d/text-mode")
(require 'yasnippet-bundle)

;;flymake - realtime compilation checking
(require 'flymake)
(setq flymake-log-level 3)
(require 'flymake-cursor)

;; auto complete param
(require 'auto-complete-config)

(ac-config-default)
(ac-set-trigger-key "M-q")
(define-key ac-mode-map  [M-q] 'auto-complete)
(defun my-ac-config ()
  (setq-default ac-sources '(ac-source-abbrev ac-source-dictionary ac-source-words-in-same-mode-buffers))
  (add-hook 'emacs-lisp-mode-hook 'ac-emacs-lisp-mode-setup)
  (add-hook 'c-mode-common-hook 'ac-cc-mode-setup)
  (add-hook 'ruby-mode-hook 'ac-ruby-mode-setup)
  (add-hook 'css-mode-hook 'ac-css-mode-setup)
  (add-hook 'auto-complete-mode-hook 'ac-common-setup)
  (global-auto-complete-mode t))
(defun my-ac-cc-mode-setup ()
  (setq ac-sources (append '(ac-source-yasnippet) ac-sources)))
(add-hook 'c-mode-common-hook 'my-ac-cc-mode-setup)
;; ac-source-gtags
(my-ac-config)


;; Version detection

(defconst xemacs (string-match "XEmacs" emacs-version)
  "non-nil iff XEmacs, nil otherwise")

(defconst emacs22 (string-match "^22." emacs-version)
  "non-nil iff Emacs 22, nil otherwise")

;; CUSTOM FUNCTIONS

;; Reload conf

(defun reload ()
  (interactive)
  (load-file "~/.emacs"))

;; Compilation

(defvar cpu-number 1
  "Number of parallel processing units on this system")

(setq compile-command "")

;; Edition

(defun c-switch-hh-cc ()
  (interactive)
  (let ((other
         (let ((file (buffer-file-name)))
           (if (string-match "\\.hh$" file)
               (replace-regexp-in-string "\\.hh$" ".cc" file)
             (replace-regexp-in-string "\\.cc$" ".hh" file)))))
    (find-file other)))

(defun count-word (start end)
  (let ((begin (min start end))(end (max start end)))
    (save-excursion
      (goto-char begin)
      (re-search-forward "\\W*") ; skip blank
      (setq i 0)
      (while (< (point) end)
        (re-search-forward "\\w+")
        (when (<= (point) end)
          (setq i (+ 1 i)))
        (re-search-forward "\\W*"))))
  i)

(defun stat-region (start end)
  (interactive "r")
  (let
      ((words (count-word start end)) (lines (count-lines start end)))
    (message
     (concat "Lines: "
             (int-to-string lines)
             "  Words: "
             (int-to-string words)))
    )
  )

(defun ruby-command (cmd &optional output-buffer error-buffer)
  "Like shell-command, but using ruby."
  (interactive (list (read-from-minibuffer "Ruby command: "
					   nil nil nil 'ruby-command-history)
		     current-prefix-arg
		     shell-command-default-error-buffer))
  (shell-command (concat "ruby -e '" cmd "'") output-buffer error-buffer))

;; Shebangs

(defun insert-shebang (bin)
  (interactive "sBin: ")
  (save-excursion
    (goto-char (point-min))
    (insert "#!" bin "\n\n")))

(defun insert-shebang-if-empty (bin)
  (when (buffer-empty-p)
    (insert-shebang bin)))

;; C/C++

;; Comment boxing

(defun insert-header-guard ()
  (interactive)
  (save-excursion
    (when (buffer-file-name)
        (let*
            ((name (file-name-nondirectory buffer-file-name))
             (macro (replace-regexp-in-string
                     "\\." "_"
                     (replace-regexp-in-string
                      "-" "_"
                      (upcase name)))))
          (goto-char (point-min))
         (insert "#ifndef " macro "_\n")
          (insert "# define " macro "_\n\n")
          (goto-char (point-max))
          (insert "\n#endif /* !" macro "_ */\n")))))

(defun insert-header-inclusion ()
  (interactive)
  (when (buffer-file-name)
    (let
        ((name
          (replace-regexp-in-string ".c$" ".h"
            (replace-regexp-in-string ".cc$" ".hh"
              (file-name-nondirectory buffer-file-name)))))
      (insert "#include \"" name "\"\n\n"))))

;; FIXME toujours utile ???
(defun sandbox ()
  "Opens a C++ sandbox in current window."
  (interactive)
  (cd "/tmp")
  (let ((file (make-temp-file "/tmp/" nil ".cc")))
    (find-file file)
    (insert "int main()\n{\n\n}\n")
    (line-move -2)
    (save-buffer)
    (compile (concat "g++ -Wextra -Wall " file " && ./a.out"))))

(defun c-insert-debug (&optional msg)
  (interactive)
  (when (not (looking-at "\\W*$"))
    (beginning-of-line)
    (insert "\n")
    (line-move -1))
  (c-indent-line)
  (insert "std::cerr << \"\" << std::endl;")
  (backward-char 15))

;; OPTIONS

(setq inhibit-startup-message t)        ; don't show the GNU splash screen
(setq frame-title-format "%b")          ; titlebar shows buffer's name
(global-font-lock-mode t)               ; syntax highlighting
(setq font-lock-maximum-decoration t)   ; max decoration for all modes
(setq transient-mark-mode 't)          ; highlight selection
(setq line-number-mode 't)              ; line number
(setq column-number-mode 't)            ; column number
(when (display-graphic-p)
  (progn
    (scroll-bar-mode -1)                ; no scroll bar
    (menu-bar-mode -1)                  ; no menu bar
    (tool-bar-mode -1)                  ; no tool bar
    (mouse-wheel-mode t)))              ; enable mouse wheel


(setq delete-auto-save-files t)         ; delete unnecessary autosave files
(setq delete-old-versions t)            ; delete oldversion file
(fset 'yes-or-no-p 'y-or-n-p)           ; 'y or n' instead of 'yes or no'
(setq default-major-mode 'text-mode)    ; change default major mode to text
(setq ring-bell-function 'ignore)       ; turn the alarm totally off
(setq make-backup-files nil)            ; no backupfile

;; FIXME: wanted 99.9% of the time, but can cause your death 0.1% of
;; the time =). Todo: save buffer before reverting
;(global-auto-revert-mode t)            ; auto revert modified files

;;(pc-selection-mode)                    ; selection with shift < deprecated
(delete-selection-mode)

(auto-image-file-mode)                  ; to see picture in emacs
(dynamic-completion-mode)              ; dynamic completion
(show-paren-mode t)			; match parenthesis
(setq-default indent-tabs-mode nil)	; don't use fucking tabs to indent

;; HOOKS

; Delete trailing whitespaces on save
(add-hook 'write-file-hooks 'delete-trailing-whitespace)
; Auto insert C/C++ header guard
(add-hook 'find-file-hooks
	  (lambda ()
	    (when (and (memq major-mode '(c-mode c++-mode)) (equal (point-min) (point-max)) (string-match ".*\\.hh?" (buffer-file-name)))
	      (insert-header-guard)
	      (goto-line 3)
	      (insert "\n"))))
(add-hook 'find-file-hooks
	  (lambda ()
	    (when (and (memq major-mode '(c-mode c++-mode)) (equal (point-min) (point-max)) (string-match ".*\\.cc?" (buffer-file-name)))
	      (insert-header-inclusion))))

(add-hook 'sh-mode-hook
	  (lambda ()
            (insert-shebang-if-empty "/bin/sh")))

(add-hook 'ruby-mode-hook
	  (lambda ()
            (insert-shebang-if-empty "/usr/bin/ruby")))


; Start code folding mode in C/C++ mode
(add-hook 'c-mode-common-hook (lambda () (hs-minor-mode 1)))

;; file extensions
(add-to-list 'auto-mode-alist '("\\.l$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.y$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.ll$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.yy$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.xcc$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.xhh$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.pro$" . sh-mode)) ; Qt .pro files
(add-to-list 'auto-mode-alist '("configure$" . sh-mode))
(add-to-list 'auto-mode-alist '("Drakefile$" . c++-mode))
(add-to-list 'auto-mode-alist '("COMMIT_EDITMSG" . change-log-mode))

;; Ido

(defconst has-ido emacs22)

(when has-ido
  (ido-mode t)

;; tab means tab, i.e. complete. Not "open this file", stupid.
  (setq ido-confirm-unique-completion t)
;; If the file doesn't exist, do try to invent one from a transplanar
;; directory. I just want a new file.
  (setq ido-auto-merge-work-directories-length -1)

;; Don't switch to GDB-mode buffers
  (add-to-list 'ido-ignore-buffers "locals"))


;; BINDINGS :: windows

(global-unset-key [(control s)])
(global-set-key [(control s) (v)] 'split-window-horizontally)
(global-set-key [(control s) (h)] 'split-window-vertically)
(global-set-key [(control s) (d)] 'delete-window)
(global-set-key [(control s) (o)] 'delete-other-windows)
;; BINDINGS :: ido

(when has-ido
  (global-set-key [(control b)] 'ido-switch-buffer))

;; BINDINGS :: isearch
(global-set-key [(control f)] 'isearch-forward-regexp)  ; search regexp with ctrl f
(global-set-key [(control r)] 'query-replace-regexp)    ; replace regexp

(define-key
  isearch-mode-map
  [(control n)]
  'isearch-repeat-forward)                              ; next occurence
(define-key
  isearch-mode-map
  [(control p)]
  'isearch-repeat-backward)                             ; previous occurence
(define-key
  isearch-mode-map
  [(control z)]
  'isearch-cancel)                                      ; quit and go back to start point
(define-key
  isearch-mode-map
  [(control f)]
  'isearch-exit)                                        ; abort
(define-key
  isearch-mode-map
  [(control r)]
  'isearch-query-replace)                               ; switch to replace mode
(define-key
  isearch-mode-map
  [S-insert]
  'isearch-yank-kill)                                   ; paste
(define-key
  isearch-mode-map
  [(control e)]
  'isearch-toggle-regexp)                               ; toggle regexp
(define-key
  isearch-mode-map
  [(control l)]
  'isearch-yank-line)                                   ; yank line from buffer
(define-key
  isearch-mode-map
  [(control w)]
  'isearch-yank-word)                                   ; yank word from buffer
(define-key
  isearch-mode-map
  [(control c)]
  'isearch-yank-char)                                   ; yank char from buffer

;; BINDINGS :: Lisp

(define-key
  lisp-mode-map
  [(control c) (control f)]
  'insert-fixme)                                      ; insert fixme

;; BINDINGS :: C/C++

(require 'cc-mode)

(define-key
  c-mode-base-map
  [(control c) (w)]
  'c-switch-hh-cc)                                      ; switch between .hh and .cc
(define-key
  c-mode-base-map
  [(control c) (f)]
  'hs-hide-block)                                       ; fold code
(define-key
  c-mode-base-map
  [(control c) (s)]
  'hs-show-block)                                       ; unfold code
(define-key
  c-mode-base-map
  [(control c) (control f)]
  'insert-fixme)                                      ; insert fixme
(define-key
  c-mode-base-map
  [(control c) (control d)]
  'c-insert-debug)                                      ; insert debug


(global-set-key [(meta =)]
                'stat-region) ; count lines / words

(if (display-graphic-p)
    (global-set-key [(control z)] 'undo)                ; undo only in graphic mode
)

(global-set-key [home] 'beginning-of-buffer)          ; go to the beginning of buffer
(global-set-key [end] 'end-of-buffer)                 ; go to the end of buffer
(global-set-key [(meta g)] 'goto-line)                  ; goto line #
(global-set-key [M-left] 'windmove-left)                ; move to left windnow
(global-set-key [M-right] 'windmove-right)              ; move to right window
(global-set-key [M-up] 'windmove-up)                    ; move to upper window
(global-set-key [M-down] 'windmove-down)
(global-set-key [(control c) right] 'shrink-window-horizontally) ; shrink buffer
(global-set-key [(control c) left] 'enlarge-window-horizontally) ; enlarge buffer
(global-set-key [(control c) down] 'shrink-window)
(global-set-key [(control c) up] 'enlarge-window)

(global-set-key [(control c) (c)] 'recompile)
(global-set-key [(control c) (e)] 'next-error)
(global-set-key [(control tab)] 'other-window)          ; Ctrl-Tab = Next buffer
(global-set-key [C-S-iso-lefttab]
                '(lambda () (interactive)
                   (other-window -1)))                  ; Ctrl-Shift-Tab = Previous buffer
(global-set-key [(control delete)]
                'kill-word)                             ; kill word forward
(global-set-key [(meta ~)] 'ruby-command)               ; run ruby command

;;lisp mode

(require 'lisp-mode)

(define-key
  lisp-mode-shared-map
  [(control c) (control c)]
  'comment-region)                                      ; comment


;; C / C++ mode

(require 'cc-mode)
(add-to-list 'c-style-alist
             '("epita"
               (c-basic-offset . 2)
               (c-comment-only-line-offset . 0)
               (c-hanging-braces-alist     . ((substatement-open before after)))
               (c-offsets-alist . ((topmost-intro        . 0)
                                   (substatement         . +)
                                   (substatement-open    . 0)
                                   (case-label           . +)
                                   (access-label         . -)
                                   (inclass              . ++)
                                   (inline-open          . 0)))))

(setq c-default-style "epita")

;; Compilation

(setq compilation-window-height 14)
(setq compilation-scroll-output t)

;; make C-Q RET insert a \n, not a ^M

(defadvice insert-and-inherit (before ENCULAY activate)
  (when (eq (car args) ?
)
    (setcar args ?\n)))




(when has-ido
  (custom-set-variables
   '(ido-auto-merge-work-directories-length -1)
   '(ido-confirm-unique-completion t)
   '(ido-create-new-buffer (quote always))
   '(ido-everywhere t)
   '(ido-ignore-buffers (quote ("\\`\\*breakpoints of.*\\*\\'" "\\`\\*stack frames of.*\\*\\'" "\\`\\*gud\\*\\'" "\\`\\*locals of.*\\*\\'" "\\` ")))
   '(ido-mode (quote both) nil (ido))))

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(after-save-hook (quote (executable-make-buffer-file-executable-if-script-p)))
 '(gdb-max-frames 1024)
 '(ido-auto-merge-work-directories-length -1)
 '(ido-confirm-unique-completion t)
 '(ido-create-new-buffer (quote always))
 '(ido-everywhere t)
 '(ido-ignore-buffers (quote ("\\`\\*breakpoints of.*\\*\\'" "\\`\\*stack frames of.*\\*\\'" "\\`\\*gud\\*\\'" "\\`\\*locals of.*\\*\\'" "\\` ")))
 '(ido-mode (quote both) nil (ido))
 '(python-indent 2)
 '(require-final-newline t)
 '(speedbar-frame-parameters (quote ((minibuffer . t) (width . 20) (border-width . 0) (menu-bar-lines . 0) (tool-bar-lines . 0) (unsplittable . t) (left-fringe . 0)))))

(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

(setq-default ispell-program-name "aspell")

(setq-default gdb-many-windows t)

;; Recognize test suite output

(require 'compile)
(add-to-list 'compilation-error-regexp-alist '("^\\(PASS\\|SKIP\\|XFAIL\\|TFAIL\\): \\(.*\\)$" 2 () () 0 2))
(add-to-list 'compilation-error-regexp-alist '("^\\(FAIL\\|XPASS\\): \\(.*\\)$" 2 () () 2 2))

;; Save and restore window layout

(defvar winconf-ring ())

(defun push-winconf ()
  (interactive)
  (window-configuration-to-register ?%)
  (push (get-register ?%) winconf-ring))

(defun pop-winconf ()
  (interactive)
  (set-register ?% (pop winconf-ring))
  (jump-to-register ?%))

(defun restore-winconf ()
  (interactive)
  (set-register ?% (car winconf-ring))
  (jump-to-register ?%))

(setq default-tab-width 8) ;; set tab to 8 spaces

(prefer-coding-system 'utf-8)
(setq normal-erase-is-backspace-mode t)

(defun eightycols nil
  (defface line-overflow
    '((t (:background "red" :foreground "black")))
    "Face to use for `hl-line-face'.")
  (highlight-regexp "^.\\{80,\\}$" 'line-overflow)
)
(add-hook 'find-file-hook 'eightycols)    ;; highlight when > 80 cols

(delete-selection-mode 1)

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
(setq scroll-step 1) ;; keyboard scroll one line at a time
