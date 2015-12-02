;;; ladspa.el --- Ladspa Tools For Emacs
;;; $Author: tv.raman.tv $
;;; Description:  Expose Ladspa Plugins to Emacs/Emacspeak
;;; Keywords: Emacspeak,  Audio Desktop Ladspa
;;{{{  LCD Archive entry:

;;; LCD Archive Entry:
;;; emacspeak| T. V. Raman |raman@cs.cornell.edu
;;; A speech interface to Emacs |
;;; $Date: 2007-05-03 18:13:44 -0700 (Thu, 03 May 2007) $ |
;;;  $Revision: 4532 $ |
;;; Location undetermined
;;;

;;}}}
;;{{{  Copyright:
;;;Copyright (C) 1995 -- 2015, T. V. Raman
;;; Copyright (c) 1994, 1995 by Digital Equipment Corporation.
;;; All Rights Reserved.
;;;
;;; This file is not part of GNU Emacs, but the same permissions apply.
;;;
;;; GNU Emacs is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2, or (at your option)
;;; any later version.
;;;
;;; GNU Emacs is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNSOX FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Emacs; see the file COPYING.  If not, write to
;;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;{{{  introduction

;;; Commentary:

;;; This module  uses tools from the Ladspa SDK  to expose
;;; Ladspa plugins in a consistent way to elisp.
;;; The goal is to make it easy to inspect Ladspa Plugins,
;;; And invoke them easily from within Ladspa host applications such as MPlayer.

;;; Code:

;;}}}
;;{{{  Required modules

(require 'cl-lib)
(declaim  (optimize  (safety 0) (speed 3)))
(require 'subr-x)
(require 'derived)
;;}}}
;;{{{ Structures:

(cl-defstruct ladspa-control
  desc
  min max default
  value )

(cl-defstruct ladspa-plugin
  desc library label controls)

;;}}}
;;{{{ Ladspa Setup:

(defconst ladspa-home
  (or (getenv "LADSPA_PATH") "/usr/lib/ladspa")
  "Instalation location for Ladspa plugins.")

(defconst ladspa-analyse
  (executable-find "analyseplugin")
  "Analyse plugins tool from Ladspa SDK.")

(defvar ladspa-libs  nil
  "List of installed Ladspa libraries.")

(defun ladspa-libs (&optional refresh)
  "Return list of installed Ladspa libs."
  (declare (special ladspa-libs))
  (unless (file-exists-p ladspa-home)
    (error "Ladspa not installed or not configured."))
  (unless ladspa-analyse (error "Ladspa SDK not installed."))
  (cond
   ((and ladspa-libs (null refresh)) ladspa-libs)
   (t
    (loop
     for d in (split-string ladspa-home ":" t) do
     (setq ladspa-libs (nconc ladspa-libs (directory-files d  nil "\\.so$"))))
    ladspa-libs)))

;;}}}
;;{{{ Ladspa Plugins:

(defvar ladspa-plugins nil
  "List of installed plugins with their metadata.")

(defun ladspa-control (c-str)
  "Construct a ladspa control instance from c-str."
  (assert (stringp c-str) nil "Error: c-str is not a string.")
  (let* ((fields (split-string c-str "," 'omit-null))
         (desc (first fields))
         (range
          (when (>= (length fields) 3)
          (split-string (third fields) " " 'omit)))
         (default
           (when (>= (length fields) 4)
           (split-string (fourth fields) " " 'omit)))
        (result (make-ladspa-control)))
    (when (string-match "^Ports:" desc)
      (setq desc (substring desc  7)))
    (setf (ladspa-control-desc result) desc
     (ladspa-control-min result) (first range)
          (ladspa-control-max result) (third range)
          (ladspa-control-default result)(second default))
    result))

(defun ladspa-analyse-label (library summary)
  "Analyse Ladspa effect and return a parsed metadata structure."
  (let* ((label  (substring  summary 0 (string-match " " summary)))
         (desc (string-trim (substring  summary (string-match " " summary))))
         (controls nil)
         (lines (split-string
                 (shell-command-to-string
                  (format "analyseplugin   %s %s | grep  control " library label))
                 "\n" 'omit-null))
         (result (make-ladspa-plugin :library library :label label :desc desc)))
    (loop for c in lines do
          (push (ladspa-control c) controls))
    (setf (ladspa-plugin-controls result) controls)
    result))

(defun ladspa-analyse-library (library )
  "Analyse Ladspa library and return a 
list of parsed ladspa-plugin structures, one per label."
  (let ((result nil)
        (labels
          (split-string
           (shell-command-to-string (format "analyseplugin -l %s" library))
           "\n" 'omit-null)))
    (loop for label in labels  do
          (push (ladspa-analyse-label library label) result))
    result))

(defun ladspa-plugins (&optional refresh)
  "Return list of installed Ladspa plugins."
  (declare (special ladspa-plugins))
  (cond
   ((and ladspa-plugins (null refresh)) ladspa-plugins)
   (t
    (loop
     for library in (ladspa-libs) do
     (setq ladspa-plugins
           (nconc ladspa-plugins (ladspa-analyse-library library))))
    (nreverse ladspa-plugins))))

;;}}}
;;{{{ Ladspa Mode:
(defconst ladspa-header-line-format
  '((:eval
     (format
      "%s"
      (propertize "Ladspa Workbench" 'face 'bold))))
      
  "Header line format for SoX buffers.")

(defun ladspa-draw-plugin (p)
  "Draw plugin at point."
  (let ((start (point)))
    (insert (ladspa-plugin-desc p))
    (put-text-property start (point)
                       'ladspa p))
  (insert "\n"))

(defun  ladspa-init ()
  "Initialize Ladspa."
  (let ((inhibit-read-only  t)
        (plugins (ladspa-plugins)))
    (erase-buffer)
    (loop for  p in plugins do
          (ladspa-draw-plugin p))))

(define-derived-mode ladspa-mode special-mode
                     "Interactively manipulate Ladspa filters."
"A Ladspa workbench for the Emacspeak desktop."
  (ladspa-init)
  (setq tab-width 8)
  (setq buffer-read-only t)
  (setq header-line-format ladspa-header-line-format))
;;;###autoload
(defun ladspa ()
  "Launch Ladspa workbench."
  (interactive)
  (let ((buffer (get-buffer-create "*Ladspa*")))
    (save-current-buffer
      (set-buffer "*Ladspa*")
      (ladspa-mode))
    (switch-to-buffer buffer)))
;;}}}
(provide 'ladspa)
;;{{{ end of file

;;; local variables:
;;; folded-file: t
;;; byte-compile-dynamic: t
;;; end:

;;}}}
