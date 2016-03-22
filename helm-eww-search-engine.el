;;; helm-eww-search-engine -*- lexical-binding: t; coding: utf-8; -*-

;;; Code:

(require 'cl-lib)
(require 'seq)
(require 'helm)

(defcustom helm-eww-search-engine-engines-list
  `(("DuckDuckGo" .  "https://duckduckgo.com/html/?q=")
    ("Google" .  "https://www.google.com/search?q=")
    ("Yahoo" . "https://search.yahoo.com/search?p=")
    ("Bing" . "http://www.bing.com/search?q=")
    ("Yandex" . "http://www.yandex.com/yandsearch?text=")
    ("Baidu" . "http://www.baidu.com/s?wd=")
    ("Github" . "https://github.com/search?ref=reposearch&q="))
  "helm eww search engine engines list"
  :type 'list
  :group 'helm)

(cl-defun helm-eww-search-engine-longest (strs)
  (seq-reduce
   (lambda (a b)
     (cl-letf* ((al (string-width a))
                (bl (string-width b)))
       (if (< al bl)  b a)))
   strs ""))

(cl-defun helm-eww-search-engine-padding (str num)
  (cl-letf ((pad-num (number-to-string num)))
    (format (seq-concatenate 'string
                             "%-" pad-num
                             "."
                             pad-num
                             "s")
            str)))

(cl-defun helm-eww-search-engine-action-search (candidate)
  (cl-letf ((eww-search-prefix candidate))
    (call-interactively #'eww)))

(cl-defun helm-eww-search-engine-create-candidates ()
  (cl-letf* ((longest-width (string-width
                             (helm-eww-search-engine-longest
                              (seq-map
                               #'car
                               helm-eww-search-engine-engines-list)))))
    (seq-map
     (pcase-lambda (`(,name . ,engine))
         `(,(seq-concatenate 'string
                             (helm-eww-search-engine-padding name
                                                             longest-width)
                             "  "
                             engine)
           . ,engine))
     helm-eww-search-engine-engines-list)))

(defvar helm-eww-search-engine-candidates nil)

(cl-defun helm-eww-search-engine-init ()
  (setq helm-eww-search-engine-candidates
        (helm-eww-search-engine-create-candidates)))

(defclass helm-eww-search-engine-source (helm-source-sync)
  ((init :initform #'helm-eww-search-engine-init)
   (candidates :initform helm-eww-search-engine-candidates)
   (action :initform
           (helm-make-actions
            "Search" #'helm-eww-search-engine-action-search))))

(defvar helm-source-eww-search-engine
  (helm-make-source "Search-Engine"
      'helm-eww-search-engine-source))

;;;###autoload
(cl-defun helm-eww-search-engine ()
  "helm source for eww search engines"
  (interactive)
  (helm :sources '(helm-source-eww-search-engine)
        :buffer "*helm eww search engine*"
        :prompt "Search with: "))


(provide 'helm-eww-search-engine)

;;; helm-eww-search-engine.el ends here
