(set-face-attribute 'default nil :height 150)
(require 'package)
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(setq visible-bell 1)
(setq-default indent-tabs-mode nil)


(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))


(menu-bar-mode -1)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(solidity-flycheck solidity-mode ag projectile company tide)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(require 'flycheck)
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (setq typescript-indent-level
      (or (plist-get (tide-tsfmt-options) ':indentSize) 4))
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving

(add-hook 'typescript-mode-hook #'setup-tide-mode)
(add-hook 'javascript-mode-hook #'setup-tide-mode)
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode))

(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "tsx" (file-name-extension buffer-file-name))
              (setup-tide-mode))))
(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "jsx" (file-name-extension buffer-file-name))
              (setup-tide-mode))))

(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "js" (file-name-extension buffer-file-name))
              (setup-tide-mode))))

(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
  (web-mode-set-content-type "jsx")
)
(add-hook 'web-mode-hook  'my-web-mode-hook)
;; enable typescript-tslint checker
(flycheck-add-mode 'typescript-tslint 'web-mode)
(flycheck-add-mode 'javascript-eslint 'web-mode)


(setq exec-path (append exec-path '("C:/Users/amanm/AppData/Local/nvs/")))
(setq exec-path (append exec-path '("C:/Users/amanm/AppData/Local/nvs/node/14.10.1/x64/")))


(require 'highlight-parentheses)

(define-globalized-minor-mode global-highlight-parentheses-mode highlight-parentheses-mode
  (lambda nil (highlight-parentheses-mode t)))

(global-highlight-parentheses-mode t)
(put 'upcase-region 'disabled nil)
(setq backup-directory-alist
`((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
`((".*" ,temporary-file-directory t)))
(put 'downcase-region 'disabled nil)

(setq js-indent-level 2)


(use-package web-mode
  :custom
  (web-mode-markup-indent-offset 4)
  (web-mode-css-indent-offset 4)
  (web-mode-code-indent-offset 4))


(require 'solidity-mode)
(define-key solidity-mode-map (kbd "C-c C-g") 'solidity-estimate-gas-at-point)
(setq solidity-flycheck-solc-checker-active t)

(use-package copilot
  :straight (:host github :repo "zerolfx/copilot.el" :files ("dist" "*.el"))
  :ensure t)

(add-hook 'prog-mode-hook 'copilot-mode)
(with-eval-after-load 'company
  ;; disable inline previews
  (delq 'company-preview-if-just-one-frontend company-frontends))
  
(define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)
(define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion)
(require 'rust-mode)

(helm-mode 1)

(setq ffip-use-rust-fd t)
(when (eq system-type 'windows-nt)
  (setq ffip-find-executable "fd"))
(setq ffip-prune-patterns '("*/dist" "*/.git" "*/.svn" "*/build" "*/node_modules"))

(global-set-key (kbd "C-x p f") 'find-file-in-project)

(unless (package-installed-p 'rg)
  (package-refresh-contents)
  (package-install 'rg))

(unless (package-installed-p 'ivy)
  (package-refresh-contents)
  (package-install 'ivy))
(unless (package-installed-p 'counsel)
  (package-refresh-contents)
  (package-install 'counsel))
(require 'rg)

(use-package projectile
  :ensure t
  :config
  (projectile-mode 1))

(defun my-rg-search-in-project (search-string)
  "Search for the given SEARCH-STRING using ripgrep (rg) in the current project."
  (interactive "sSearch in project: ")
  (let ((default-directory (projectile-project-root)))
    (unless (executable-find "rg")
      (error "ripgrep (rg) is not installed."))
    (let ((command (format "rg --color=never --smart-case --no-heading --line-number --ignore-case --hidden  %s ." search-string)))
      (compilation-start command 'rg-mode))))

(require 'counsel)

(setq counsel-rg-base-command "rg --color=never --smart-case --no-heading --line-number --ignore-case --hidden  %s .")
(setq counsel-rg-extra-rg-args '("--sort" "path"))

(global-set-key (kbd "C-x p s") 'counsel-rg)

;;(global-set-key (kbd "C-x p s") 'my-rg-search-in-project)
