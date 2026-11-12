;;; -*- lexical-binding: t -*-

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(inhibit-startup-screen t)
 '(menu-bar-mode t)
 '(package-selected-packages
   '(ace-window cape consult consult-org-roam corfu embark embark-consult
		iedit magit marginalia org-appear org-bullets org-roam
		org-roam-ui paredit plantuml-mode rust-mode simpleclip
		vertico wgrep zenburn-theme))
 '(scroll-bar-mode nil)
 '(search-invisible nil)
 '(tool-bar-mode nil)
 '(visible-bell t)
 '(window-divider-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;; Used Modules
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
;; (package-install-selected-packages)
;; (package-upgrade-all)

;; (add-to-list 'load-path "~/.emacs.d/own-libs")

(require 'iedit)
(require 'wgrep)
(require 'simpleclip)
(require 'ace-window)

;;; Apperance
(cond
 ((eq system-type 'windows-nt) (set-frame-font "Consolas 14" nil t))
 ((eq system-type 'gnu/linux)  (set-frame-font "-GOOG-Cousine-regular-normal-normal-*-*-*-*-*-m-0-iso10646-1" nil t))
 )
(load-theme 'zenburn t)
(add-hook 'text-mode-hook 'visual-line-mode)
(global-yascroll-bar-mode 1)

;; paredit
(use-package paredit
  :ensure t
  :hook ((emacs-lisp-mode     . paredit-mode)
         (lisp-mode           . paredit-mode)
         (scheme-mode         . paredit-mode)
         (clojure-mode        . paredit-mode)
         (clojure-script-mode . paredit-mode)))

;;; Global settings

;; Workaround (https://www.reddit.com/r/emacs/comments/1hayavx/invalid_function_orgelementwithdisabledcache/)
(setq native-comp-jit-compilation-deny-list '(".*org-element.*"))

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(setq backup-directory-alist `(("." . "~/.saves")))
;; (add-hook 'dired-mode-hook 'dired-hide-details-mode)

(defun my/trailing-whitespace-handling ()
  "Ensure empty line at end of buffer"
  (interactive)
  (save-excursion
    (save-window-excursion
      (save-restriction
        (save-match-data
          (delete-trailing-whitespace)
          (end-of-buffer)
          (if (eq ?\n (char-before))
              (progn
                (backward-char)
                (unless (eq ?\n (char-before))
                  (insert-char ?\n)))
            (insert-char ?\n 2)))))))

(add-hook 'write-file-hooks 'my/trailing-whitespace-handling)
(put 'narrow-to-region 'disabled nil)
(delete-selection-mode t)
(simpleclip-mode t)

;; Org
                                        ; Modes
(require 'org)
(require 'ol)
(require 'org-appear)
(require 'org-bullets)
(require 'org-indent)
(require 'org-roam)
(require 'org-roam-ui)

(add-hook 'org-mode-hook 'org-appear-mode)
(add-hook 'org-mode-hook 'org-indent-mode)
(add-hook 'org-mode-hook 'org-bullets-mode)
(add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images)

                                        ; Faces
(set-face-attribute 'org-ellipsis nil :underline nil)
(set-face-attribute 'org-drawer nil :foreground "LightSkyBlue" :height 0.8)
(set-face-attribute 'org-document-title nil :height 1.2)
(set-face-attribute 'org-level-1 nil :foreground "NavajoWhite1")
(set-face-attribute 'org-level-2 nil :foreground "honeydew1")
(set-face-attribute 'org-level-3 nil :foreground "LavenderBlush1")
(set-face-attribute 'org-level-4 nil :foreground "NavajoWhite2")
(set-face-attribute 'org-level-5 nil :foreground "honeydew2")
(set-face-attribute 'org-level-6 nil :foreground "LavenderBlush2")
(set-face-attribute 'org-block nil :background "gray21")

(setq org-hide-emphasis-markers t)
(setq org-ellipsis (format " %c" 9660))
(setq org-hide-leading-stars t)
(setq org-bullets-bullet-list '("▣" "▶" "◉" "▪" "▸" "◦"))
(setq org-pretty-entities nil)

                                        ; Variables
(setq org-startup-folded 'nofold)
(setq org-cycle-hide-block-startup t)
(setq org-return-follows-link t)

(setq org-file-apps
      '(("\\.pdf\\'" . system)
        (directory . emacs)
        ("\\.x?html\\'" . system)
        ("\\.jpe?g\\'" . system)
        ("\\.png\\'" . system)
        ("\\.xls[xm]\\'" . system)
        ("\\.bat\\'" . system)
        (auto-mode . emacs)))

(setq org-special-ctrl-a/e t)

(with-eval-after-load 'org
  (org-babel-do-load-languages 'org-babel-load-languages
                               '((emacs-lisp . t) (C . t) (plantuml . t))))
(setq org-confirm-babel-evaluate nil)
(setq org-src-fontify-natively t
      org-src-tab-acts-natively t
      org-edit-src-content-indentation 1)

(setq org-todo-keywords
      '((sequence "TODO(t)" "|" "DONE(d)")
        (sequence "OPEN(o)" "WAIT(z)" "WORK(w)" "VIEW(v)" "|" "FNSH(f)")))
(setq org-todo-keyword-faces
      '(("INFO" . "lavender blush")
        ("TODO" . org-todo)
        ("OPEN" . "lavender blush")
        ("WORK" . org-todo)
        ("WAIT" . "light sky blue")
        ("VIEW" . "light goldenrod")))
(setq org-enforce-todo-dependencies t)
(setq org-log-done 'time)
(setq org-hierarchical-todo-statistics nil)
(setq org-use-fast-todo-selection 'expert)

(setq org-tags-column -90)
(setq org-auto-align-tags t)

(setq org-priority-default 69)
(setq org-priority-faces
      '((65 . "red")
        (66 . "dark orange")
        (67 . "gold")
        (68 . "khaki")
        (69 . "dark khaki")))
(setq org-priority-lowest 69)

                                        ; Functions
(setf (cdr (assoc 'file org-link-frame-setup)) 'find-file)

(defun my/org-cycle-hide-blocks (state)
  "Re-hide all blocks after a visibility state change."
  (when (derived-mode-p 'org-mode)
    (org-fold-hide-block-all)))
(add-hook 'org-cycle-hook 'org-cycle-hide-drawers)
(add-hook 'org-cycle-hook 'my/org-cycle-hide-blocks)

(defun my/org-link-copy ()
  "Extract URL from org-mode link and add it to kill ring."
  (interactive)
  (let* ((link (org-element-lineage (org-element-context) '(link) t))
         (type (org-element-property :type link))
         (path (org-element-property :path link))
         (url (concat type ":" path)))
    (cond
     ((not type) (message "No link."))
     (t (kill-new url)
	(simpleclip-set-contents (substring-no-properties (car kill-ring)))
	(message "Copied URL.")))))

(defun my/org-link-copy-mouse (ev)
  (interactive "e")
  (mouse-set-point ev)
  (my/org-link-copy))

(define-key org-mode-map (kbd "C-x C-l") 'my/org-link-copy)
(setq mouse-1-follows-link nil)
(setq org-mouse-1-follows-link nil)
(org-defkey org-mouse-map [mouse-2] #'ignore)
(org-defkey org-mouse-map [down-mouse-2] 'my/org-link-copy-mouse)
(org-defkey org-mouse-map [mouse-3] #'org-open-at-mouse)
(global-set-key (kbd "C-c l") #'org-store-link)

(org-link-set-parameters "alm"
                         :follow (lambda (label) (browse-url (concat "alm:" label))))

(define-key org-mode-map (kbd "M-n") #'org-next-link)
(define-key org-mode-map (kbd "M-p") #'org-previous-link)

(setq org-default-notes-file "~/notes.org")
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline org-default-notes-file "Schnellnotizen")
         "* TODO %?\n  %U\n  %a")))
;; We don't need this file right now
;; (global-set-key (kbd "C-c c") (lambda () (interactive (org-capture nil "t"))))
;; (global-set-key (kbd "C-c n n") (lambda() (interactive)(find-file org-default-notes-file)))

(defun my/create-link-name (str)
  (let ((ending (replace-regexp-in-string "[\?#].*$" "" (replace-regexp-in-string "^.*/" "" str))))
    (cond
     ((string-match "merge_requests" str) (concat "MR" ending))
     (t ending))))

(defun my/insert-link (start end)
  (interactive "r")
  (let* ((link (simpleclip-get-contents))
	 (link-name
	  (cond
	   ((use-region-p) (buffer-substring start end))
	   (t (my/create-link-name link)))))
    (org-insert-link nil link link-name)))

(define-key org-mode-map (kbd "C-c i l") #'my/insert-link)

(defvar my/org-toggle-blocks nil)
(defun my/org-toggle-blocks ()
  (interactive)
  (setq my/org-toggle-blocks (not my/org-toggle-blocks))
  (if my/org-toggle-blocks
      (progn
        (org-fold-hide-block-all)
        (org-fold-hide-drawer-all))
    (progn
      (org-fold-show-all)
      (org-fold-hide-drawer-all))))

(defvar my/org-toggle-inline-images nil)
(defun my/org-toggle-inline-images ()
  (interactive)
  (setq my/org-toggle-inline-images (not my/org-toggle-inline-images))
  (if my/org-toggle-inline-images
      (org-remove-inline-images)
    (org-display-inline-images)))

(define-key org-mode-map (kbd "<f5>") 'my/org-toggle-blocks)
(define-key org-mode-map (kbd "<f6>") 'my/org-toggle-inline-images)

(define-key org-mode-map (kbd "C-c 6") '(lambda () (interactive) (mark-whole-buffer) (org-sort-entries nil ?o nil nil nil nil)))
(global-set-key (kbd "<f9>") '(lambda () (interactive) (org-roam-node-open (org-roam-node-from-title-or-alias "Hirn"))))

;; org-roam
(setq org-roam-directory (file-truename "~/orghirn"))
(setq org-roam-completion-everywhere t)

(setq org-roam-capture-templates
      '(("d" "default" plain "%?"
         :target (file+head "%<%Y%m%d>-${slug}.org"
                            "#+title: ${title}\n#+category: ${title}")
         :unnarrowed t)))

(global-set-key (kbd "C-c n l") 'org-roam-buffer-toggle)
(global-set-key (kbd "C-c n i") 'org-roam-node-insert)
(global-set-key (kbd "C-c n c") 'org-roam-capture)
(global-set-key (kbd "C-c n w") 'org-roam-ui-mode)
(global-set-key (kbd "C-c n e") 'org-roam-extract-subtree)

(org-roam-db-autosync-mode)

;; Projekt "Tagesknoten"
(setq org-roam-dailies-directory "tagesknoten/")
(global-set-key (kbd "C-c n d") org-roam-dailies-map)

(setq org-roam-dailies-capture-templates
      '(("d" "default" plain "* TODO %?"
         :target (file+head "%<%Y-%m-%d>-Tagesknoten.org"
                            "#+title: Tagesknoten vom %<%A den %d. %b %Y>\n#+category: Tagesknoten vom %<%Y-%m-%d>\n"))))

(global-set-key (kbd "C-c c") 'org-roam-dailies-capture-today)

(defun my/org-roam-dailies-goto-today ()
  "Go to today, or create if non existent."
  (interactive)
  (let* ((dailies (org-roam-dailies--list-files))
         (position
          (cl-position-if (lambda (candidate)
                            (string-match-p (format-time-string "%Y-%m-%d") candidate))
                          dailies))
         note)
    (if position
        (progn
          (setq note (nth position dailies))
          (find-file note))
      (org-roam-dailies-goto-today))))

(defun my/org-roam-dailies-goto-previous-note ()
  "Go to previous dailies note"
  (interactive)
  (if (and (buffer-file-name) (org-roam-dailies--daily-note-p))
      (org-roam-dailies-goto-previous-note)
    (my/org-roam-dailies-goto-today)))

(defun my/org-roam-dailies-goto-next-note ()
  "Go to previous dailies note"
  (interactive)
  (if (and (buffer-file-name) (org-roam-dailies--daily-note-p))
      (org-roam-dailies-goto-next-note)
    (my/org-roam-dailies-goto-today)))

(global-set-key (kbd "<f7>") 'my/org-roam-dailies-goto-previous-note)
(global-set-key (kbd "<f8>") 'my/org-roam-dailies-goto-next-note)
(global-set-key (kbd "M-<f7>") 'my/org-roam-dailies-goto-today)
(global-set-key (kbd "M-<f8>") 'my/org-roam-dailies-goto-today)

(defun my/org-roam-node-find-no-dailies ()
  "Like org-roam-node-find but hies nodes tagged :tagesknoten:"
  (interactive)
  (org-roam-node-find
   nil ;; OTHER-WINDOW
   nil ;; INITIAL-INPUT
   (lambda (node)
     (not (org-roam-dailies--daily-note-p (org-roam-node-file node))))))

(global-set-key (kbd "C-c n f") 'my/org-roam-node-find-no-dailies)


(defun my/pred-org-roam-dailies (filename)
  "Check if the FILENAME qualifies for inclusion."
  (let ((fname (file-name-sans-extension (file-name-nondirectory filename))))
    (string-match "\\(.*\\)-Tagesknoten" fname)
    (let ((fname-date (match-string 1 fname)))
          ;; if the date corresponding to the name of the file falls above date-min,
          ;; return the (complete) filename
          (when (string< date-min fname-date)
            filename))))

;; org agenda
(defun my/filter-org-roam-dailies (dir date-min)
  "Filter the list of files in DIR that have a `.org' suffix. They are all
 supposed to have names of the form \"YYYY-MM-DD-Tagesknoten.org\". We only
 accept those whose names have a date part that are after `START-DATE' (inklusive)."

  (cl-flet ((my/pred-org-roam-dailies (filename)
              "Check if the FILENAME qualifies for inclusion."
              (save-match-data
                (let* ((fname (file-name-sans-extension (file-name-nondirectory filename)))
                       (_ (string-match "\\(.*\\)-Tagesknoten" fname))
                       (fname-date (match-string 1 fname)))
                  ;; if the date corresponding to the name of the file falls above date-min,
                  ;; return the (complete) filename
                  (when (or (string= date-min fname-date) (string< date-min fname-date))
                    filename)))))
    (delq nil
          (mapcar #'my/pred-org-roam-dailies (directory-files dir t "\\.org\\'")))))

(setq org-agenda-files (cons "~/orghirn" (my/filter-org-roam-dailies "~/orghirn/tagesknoten" "2026-02-04")))
(global-set-key (kbd "C-c a") #'org-agenda)

(setq org-agenda-prefix-format
      (quote
       ((agenda . "%-30c%?-30t% s")
        (timeline . "% s")
        (todo . "%-30c")
        (tags . "%-30c")
        (search . "%-30c"))))

(setq org-agenda-deadline-leaders (quote ("!D!: " "D%2d: " "")))
(setq org-agenda-scheduled-leaders (quote ("" "S%3d: ")))

(setq org-agenda-custom-commands
      '(("c" todo "TODO") ;; (1) (3) (4)
        ;; ...other commands here
        ))

;; PlantUML
(require 'plantuml-mode)
(add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
(plantuml-set-output-type "svg")

(setq plantuml-default-exec-mode 'jar)
(setq plantuml-jar-path (expand-file-name "~/plantuml.jar"))
(setq org-plantuml-jar-path (expand-file-name "~/plantuml.jar"))
(define-key org-mode-map (kbd "C-c i p") 'my/insert-plantuml-block)

;;; Global Keys
(defvar linez-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-<up>") 'my/move-line-up)
    (define-key map (kbd "C-<down>") 'my/move-line-down)
    (define-key map (kbd "C-S-<up>") 'my/duplicate-line-up)
    (define-key map (kbd "C-S-<down>") 'my/duplicate-line-down)
    (define-key map (kbd "M-k") 'kill-whole-line)
    map)
  "linez-minor-mode keymap.")

(define-minor-mode linez-minor-mode
  "A minor mode so that my key settings override annoying major modes."
  :init-value t
  :lighter " linez")

(linez-minor-mode t)

; Deactivate stupid agenda cycle keys
(eval-after-load 'org
  '(progn
     (define-key org-mode-map (kbd "C-,") nil)
     (define-key org-mode-map (kbd "C-'") nil)))

(global-set-key (kbd "C-x ,") (lambda() (interactive)(find-file user-init-file)))

(global-set-key (kbd "M-o") 'ace-window)
(global-set-key (kbd "M-i") 'iedit-mode)
(global-set-key (kbd "C-;") 'comment-line)
(global-set-key (kbd "C-c w") 'my/kill-whitespace)
(global-set-key (kbd "C-c d") 'my/browse-file-directory)

(global-set-key (kbd "C-S-n") (lambda() (interactive)(next-line 10)))
(global-set-key (kbd "C-S-p") (lambda() (interactive)(previous-line 10)))

(global-set-key (kbd "C-c b") 'my/add-outer-box)
(global-set-key (kbd "C-c m l") #'display-line-numbers-mode)
(global-set-key (kbd "C-c m w") #'whitespace-mode)

;; avy
(define-key global-map (kbd "M-j") 'avy-goto-char-timer)


;; Minad/Iceberg stack https://lambdaland.org/posts/2024-05-30_top_emacs_packages/
;; Vertico + Consult + Orderless + Marginalia + Corfu + Cape + Embark

;; Vertico
(use-package vertico
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode)
  ;; (vertico-reverse-mode)
  )

;; consult
(define-key global-map (kbd "C-x b") 'consult-buffer)
(define-key global-map (kbd "C-c r") 'consult-ripgrep)

(use-package consult-org-roam
   :ensure t
   :after org-roam
   :custom
   (consult-org-roam-grep-func #'consult-ripgrep)
   (consult-org-roam-buffer-narrow-key ?r)
   (consult-org-roam-buffer-after-buffers t)
   :config
   (consult-customize
    consult-org-roam-forward-links
    :preview-key "M-.")
   (consult-org-roam-mode 1)
   :bind
   ("C-c n b" . consult-org-roam-backlinks)
   ("C-c n l" . consult-org-roam-forward-links)
   ("C-c n r" . consult-org-roam-search))

;; orderless
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil)
  (completion-pcm-leading-wildcard t))

;; marginalia
(use-package marginalia
  :custom
  (marginalia-align 'right)
  :bind
  (:map minibuffer-local-map
        ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

;; corfu
;; Corfu Konfiguration
(setq tab-always-indent 'complete)
(use-package corfu
  :custom
  (corfu-cycle t)                ; Durch Kandidaten durchschleifen
  (corfu-separator ?\s)          ; Trennzeichen für Orderless (optional)
  (corfu-preview-current nil)
  (corfu-quit-no-match t)
  (corfu-quit-at-boundary t)
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode))

;; Use Dabbrev with Corfu!
(use-package dabbrev
  ;; Swap M-/ and C-M-/
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand))
  :config
  (add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
  (add-to-list 'dabbrev-ignored-buffer-modes 'authinfo-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'doc-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'pdf-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'tags-table-mode))

;; cape
(use-package cape
  :bind ("C-c p" . cape-prefix-map)
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev 20)
  (add-hook 'completion-at-point-functions #'cape-file 20)
  ;; (add-hook 'completion-at-point-functions #'cape-history)
  ;; ...
  )

;; embark
(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
;   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t)

;;; Fancy Cursor Movements
(defun my/move-line (n)
  "Move the current line up or down by N lines."
  (interactive "p")
  (setq col (current-column))
  (beginning-of-line) (setq start (point))
  (end-of-line) (forward-char) (setq end (point))
  (let ((line-text (delete-and-extract-region start end)))
    (forward-line n)
    (insert line-text)
    ;; restore point to original column in moved line
    (forward-line -1)
    (forward-char col)))

(defun my/move-line-up (n)
  "Move the current line up by N lines."
  (interactive "p")
  (my/move-line (if (null n) -1 (- n))))

(defun my/move-line-down (n)
  "Move the current line down by N lines."
  (interactive "p")
  (my/move-line (if (null n) 1 n)))

(defun my/duplicate-line (n)
  "Duplicate the current line up or down by N lines."
  (interactive "p")
  (setq col (current-column))
  (beginning-of-line) (setq start (point))
  (end-of-line)
  (if (eobp) (insert-char ?\n) (forward-char))
  (setq end (point))
  (let ((line-text (delete-and-extract-region start end)))
    (insert line-text)
    (dotimes (i (abs n))
      (when (< n 0) (forward-line -1))
      (insert line-text))
    ;; restore point to original column in moved line
    (forward-line -1)
    (forward-char col)))

(defun my/duplicate-line-up (n)
  "Duplicate the current line up by N lines."
  (interactive "p")
  (my/duplicate-line (if (null n) -1 (- n))))

(defun my/duplicate-line-down (n)
  "Duplicate the current line down by N lines."
  (interactive "p")
  (my/duplicate-line (if (null n) 1 n)))


;;; Custom functions
(defun my/kill-whitespace ()
  "Kill the whitespace between two non-whitespace characters"
  (interactive "*")
  (save-excursion
    (save-restriction
      (save-match-data
        (progn
          (re-search-backward "[^ \t\r\n]" nil t)
          (re-search-forward "[ \t\r\n]+" nil t)
          (replace-match "" nil nil))))))

(defun my/browse-file-directory ()
  "Open the current file's directory however the OS would."
  (interactive)
  (if default-directory
      (browse-url (expand-file-name default-directory))
    (error "No `default-directory' to open")))

(defun my/insert-plantuml-block (x)
  "Insert a prefilled plantuml code block"
  (interactive "sInsert planuml block with name: ")
  (insert (replace-regexp-in-string "%s" x "\
#+NAME: %s
#+begin_src plantuml :file %s.svg
  @startuml
  !theme crt-amber
  skinparam packageStyle frame
  scale 1.5

  agent A #DarkSlateGray
  agent B #Navy
  agent C #Maroon

  A --> B : 1:1
  B .> C
  A *-- C

  @enduml
#+end_src"))
  (newline))

(defun my/add-outer-box ()
  "Adds square brackets around thing at point"
  (interactive "*")
  (save-excursion
    (save-restriction
      (save-match-data
        (let* ((start (progn (skip-chars-backward "^\s(){}\n") (point)))
               (end   (progn (skip-chars-forward "^\s(){}\n") (point)))
               (text  (buffer-substring-no-properties start end)))
          (when text
            (goto-char start)
            (insert "[")
            (goto-char (+ end 1))
            (insert "]")))))))

;;; Programming
(defun my/code-executor ()
  "Compile & Execute the currently open source code buffer"
  (interactive)
  (save-buffer)
  (let* ((file (buffer-name))
         (filename (file-name-sans-extension file))
         (filetype (file-name-extension file)))
    (cond
     ((string-match-p (regexp-quote "rs") filetype)
      (async-shell-command (format "cargo run"))))))

(global-set-key (kbd "C-c C-r") #'my/code-executor)

;;; git
(defun my/magit-full-commit ()
  "Stage all tracked and untracked files"
  (interactive)
  (save-some-buffers t)
  (let ((current-prefix-arg t))
    (command-execute 'magit-stage-modified))
  (sleep-for 2)
  (command-execute 'magit-commit-create)
  )

(global-set-key (kbd "C-c v") 'my/magit-full-commit)

;; Insert files
(defun my/insert-files-of-folder ()
  (interactive)
  (let ((dir (read-directory-name "Directory to insert: ")))
    (mapc #'(lambda (file)
              (let ((file-full (concat dir file)))
                (insert-file-contents file-full)))
          (cddr (directory-files dir)))))

;;; Startup functions
(defun my/orghirn-fn (switch)
  (desktop-read "~/.emacs.d/")
  ;; (command-execute 'magit-pull-from-upstream)
  )

;; CLI parsing
(add-to-list 'command-switch-alist '("-orghirn" . my/orghirn-fn))

