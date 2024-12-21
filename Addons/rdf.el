;;; rdf.el --- Some hacks to convert auctex/reftex equations to rdfref style equations

;; Copyright (C) 2024 Uwe Brauer

;; Author: Uwe Brauer oub@mat.ucm.es
;; Maintainer: Uwe Brauer oub@mat.ucm.es
;; Created: 19 Dec 2024
;; Version: 1.0
;; Keywords:

 
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; A copy of the GNU General Public License can be obtained from this
;; program's author (send electronic mail to oub@mat.ucm.es) or from
;; the Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA
;; 02139, USA.

;;; Code:


(defun LaTeX-modify-latex-equation-environment ()
  "Modify a LaTeX \\begin{equation} environment in the current buffer.
Replace \\label with an optional argument and comment out the
original \\label."
  (interactive)
  (save-excursion
    ;; Start from the beginning of the buffer
    (goto-char (point-min))
    ;; Search for the \\begin{equation} block
    (while (re-search-forward "\\\\begin{equation}\\(\\[.*?\\]\\)?" nil t)
      (let ((start (match-beginning 0))) ;; Save position of \begin{equation}
        ;; Search for the \label inside the environment
        (when (re-search-forward "\\\\label{\\(.*?\\)}" nil t)
          (let ((label (match-string 1))) ;; Extract the label text
            ;; Modify the \begin{equation} line
            (goto-char start)
            (re-search-forward "\\\\begin{equation}\\(\\[.*?\\]\\)?" nil t)
            (replace-match (format "\\\\begin{equation}[%s]" label) nil nil)
            ;; Comment out the \label line
            (re-search-forward (format "\\\\label{%s}" label) nil t)
            (replace-match (format "%%\\\\label{%s}" label) nil nil)))))))


(defun LaTeX-restore-latex-equation-environment ()
  "Restore a LaTeX \\begin{equation} environment in the current
 buffer. Remove the optional argument and uncomment the \\label."
  (interactive)
  (save-excursion
    ;; Start from the beginning of the buffer
    (goto-char (point-min))
    ;; Search for the \\begin{equation} block with an optional argument
    (while (re-search-forward "\\\\begin{equation}\\[\\(.*?\\)\\]" nil t)
      (let ((label (match-string 1))) ;; Extract the optional argument (label)
        ;; Modify the \\begin{equation} line
        (replace-match "\\\\begin{equation}" nil nil)
        ;; Search for the commented \\label line corresponding to the optional argument
        (when (re-search-forward (format "%%\\\\label{%s}" label) nil t)
          ;; Uncomment the \\label line
          (replace-match (format "\\\\label{%s}" label) nil nil))))))



(defun my-select-modify-or-restore-equation ()
  "This function allows to switch between modify or restore"
  (interactive)
  (with-output-to-temp-buffer "latex-list-buffer"
    (princ "List of functions\n")
    (princ "1: LaTeX-modify-latex-equation-environment\n")
    (princ "2: LaTeX-restore-latex-equation-environment\n"))
  (let  ((ch (string-to-char (read-string "Which choice: 1: 2: "))))
    (call-interactively (cond ((eql ch ?1) #'LaTeX-modify-latex-equation-environment)
			      ((eql ch ?2) #'LaTeX-restore-latex-equation-environment)
			      (t (error 'args-out-of-range '(1 2 ch))))))
  (kill-buffer "latex-list-buffer"))

(defun LaTeX-modify-latex-equation-environment-local ()
  "Modify the current LaTeX \\begin{equation} environment where
 the cursor is located. Replace \\label with an optional argument
and comment out the original \\label."
  (interactive)
  (save-excursion
    ;; Search backward for the start of the current equation environment
    (when (re-search-backward "\\\\begin{equation}\\(\\[.*?\\]\\)?" nil t)
      (let ((start (match-beginning 0))) ;; Save position of \begin{equation}
        ;; Search forward for \label within the current environment
        (when (re-search-forward "\\\\label{\\(.*?\\)}"
                                 (save-excursion (re-search-forward "\\\\end{equation}" nil t)) t)
          (let ((label (match-string 1))) ;; Extract the label text
            ;; Modify the \begin{equation} line
            (goto-char start)
            (re-search-forward "\\\\begin{equation}\\(\\[.*?\\]\\)?" nil t)
            (replace-match (format "\\\\begin{equation}[%s]" label) nil nil)
            ;; Comment out the \label line
            (re-search-forward (format "\\\\label{%s}" label) nil t)
            (replace-match (format "%%\\\\label{%s}" label) nil nil)))))))




(defun LaTeX-restore-latex-equation-environment-local ()
  "Restore the current LaTeX \\begin{equation} environment where
 the cursor is located.
Remove the optional argument and uncomment the \\label."
  (interactive)
  (save-excursion
    ;; Search backward for the start of the current equation environment
    (when (re-search-backward "\\\\begin{equation}\\[\\(.*?\\)\\]" nil t)
      (let ((label (match-string 1))) ;; Extract the optional argument (label)
        ;; Modify the \\begin{equation} line
        (replace-match "\\\\begin{equation}" nil nil)
        ;; Search forward for the commented \\label line within the current environment
        (when (re-search-forward (format "%%\\\\label{%s}" label)
                                 (save-excursion (re-search-forward "\\\\end{equation}" nil t)) t)
          ;; Uncomment the \\label line
          (replace-match (format "\\\\label{%s}" label) nil nil))))))


(defun my-select-modify-or-restore-equation-local ()
  "This function allows to switch between modify or restore"
  (interactive)
  (with-output-to-temp-buffer "latex-list-buffer"
    (princ "List of functions\n")
    (princ "1: LaTeX-modify-latex-equation-environment-local\n")
    (princ "2: LaTeX-restore-latex-equation-environment-local\n"))
  (let  ((ch (string-to-char (read-string "Which choice: 1: 2: "))))
    (call-interactively (cond ((eql ch ?1) #'LaTeX-modify-latex-equation-environment-local)
			      ((eql ch ?2) #'LaTeX-restore-latex-equation-environment-local)
			      (t (error 'args-out-of-range '(1 2 ch))))))
  (kill-buffer "latex-list-buffer"))


;; keybinding for AUCTEX

(add-hook 'LaTeX-mode-hook 'my-latex-mode-key)

(defun my-latex-mode-key ()
  (interactive)
  (local-set-key "\C-c\C-g" 'my-select-modify-or-restore-equation)
  (local-set-key "\C-c\C-h" 'my-select-modify-or-restore-equation-local))



(provide 'rdf)

;;; rdf.el ends here
