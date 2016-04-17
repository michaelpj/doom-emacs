;;; module-web.el

(define-company-backend! sass-mode (css))
(define-company-backend! scss-mode (css))
(define-docset! scss-mode "sass,bourbon")
(add-hook! (sass-mode scss-mode less-css-mode)
  '(flycheck-mode narf|hl-line-off hs-minor-mode))

(push '("css" "scss" "sass" "less") projectile-other-file-alist)

(use-package less-css-mode :mode "\\.less$"
  :config (push '("less" "css") projectile-other-file-alist))

(use-package sass-mode :mode "\\.sass$"
  :config (push '("sass" "css") projectile-other-file-alist))

(use-package scss-mode
  :mode "\\.scss$"
  :preface (require 'css-mode)
  :init (setq scss-compile-at-save nil)
  :config
  (push '("scss" "css") projectile-other-file-alist)
  (sp-local-pair 'scss-mode "/*" "*/" :post-handlers '(("[d-3]||\n[i]" "RET") ("| " "SPC")))

  (map! :map scss-mode-map
        :n "M-r" 'narf/web-refresh-browser
        (:localleader :nv ";" 'narf/append-semicolon)
        (:leader
          :n ";" 'helm-css-scss
          :n ":" 'helm-css-scss-multi))

  (after! web-beautify
    (add-hook! scss-mode (setenv "jsbeautify_indent_size" "2"))
    (map! :map scss-mode-map :m "gQ" 'web-beautify-css))

  (after! emr
    (emr-declare-command 'narf/scss-toggle-inline-or-block
      :title "toggle inline/block"
      :modes 'scss-mode
      :predicate (lambda () (not (use-region-p))))))

(use-package web-beautify
  :commands (web-beautify-js web-beautify-css web-beautify-html)
  :init
  (after! css-mode
    (add-hook! css-mode (setenv "jsbeautify_indent_size" "2"))
    (map! :map css-mode-map :m "gQ" 'web-beautify-css)))

(use-package jaded-mode
  :mode "\\.jade$"
  :config
  (map! :map jaded-mode-map
        :i [tab] 'narf/dumb-indent
        :i [backtab] 'narf/dumb-dedent))

(use-package web-mode
  :mode ("\\.\\(p\\)?htm\\(l\\)?$"
         "\\.\\(tpl\\|blade\\)\\(\\.php\\)?$"
         "\\.erb$"
         "wp-content/themes/.+/.+\\.php$")
  :init
  ;; smartparens handles this
  (setq web-mode-enable-auto-pairing nil
        web-mode-enable-auto-quoting nil)
  :config
  (sp-with-modes '(web-mode)
    (sp-local-pair "{{!--" "--}}" :post-handlers '(("||\n[i]" "RET") ("| " "SPC")))
    (sp-local-pair "{{--"  "--}}" :post-handlers '(("||\n[i]" "RET") ("| " "SPC")))
    (sp-local-pair "<%" "%>"      :post-handlers '(("||\n[i]" "RET") ("| " "SPC")))
    (sp-local-pair "{!!" "!!}"    :post-handlers '(("||\n[i]" "RET") ("| " "SPC")))
    (sp-local-pair "{#" "#}"      :post-handlers '(("||\n[i]" "RET") ("| " "SPC"))))

  (after! web-beautify
    (add-hook! web-mode (setenv "jsbeautify_indent_size" "4"))
    (map! :map web-mode-map :m "gQ" 'web-beautify-html))

  (after! nlinum
    ;; Fix blank line numbers after unfolding
    (advice-add 'web-mode-fold-or-unfold :after 'nlinum--flush))

  (map! :map web-mode-map
        "M-/" 'web-mode-comment-or-uncomment

        :n  "za" 'web-mode-fold-or-unfold
        (:localleader :n "t" 'web-mode-element-rename)

        :n  "M-r" 'narf/web-refresh-browser

        :nv "]a" 'web-mode-attribute-next
        :nv "[a" 'web-mode-attribute-previous
        :nv "]t" 'web-mode-tag-next
        :nv "[t" 'web-mode-tag-previous
        :nv "]T" 'web-mode-element-child
        :nv "[T" 'web-mode-element-parent))

(use-package emmet-mode
  :commands (emmet-mode)
  :init
  (add-hook! (scss-mode web-mode html-mode haml-mode nxml-mode) 'emmet-mode)
  (defvar emmet-mode-keymap (make-sparse-keymap))
  :config
  (setq emmet-move-cursor-between-quotes t)
  (map! :map emmet-mode-keymap
        :v "M-e" 'emmet-wrap-with-markup
        :i "M-e" 'emmet-expand-yas
        :i "M-E" 'emmet-expand-line))

;;
(define-project-type! jekyll ":{"
  :modes (web-mode scss-mode html-mode markdown-mode yaml-mode)
  :match "/\\(\\(css\\|_\\(layouts\\|posts\\|sass\\)\\)/.+\\|.+.html\\)$"
  :files ("config.yml" "_layouts/")
  (add-hook! it
    (when (eq major-mode 'web-mode)
      (web-mode-set-engine "django"))))

(define-project-type! wordpress "wp"
  :modes (php-mode web-mode css-mode scss-mode sass-mode)
  :match "/wp-\\(\\(content\\|admin\\|includes\\)/\\)?.+$"
  :files ("wp-config.php" "wp-content/"))

;; TODO Add stylus-mode

(provide 'module-web)
;;; module-web.el ends here
