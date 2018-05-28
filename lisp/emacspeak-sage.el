;;; emacspeak-sage.el --- Speech-enable SAGE  -*- lexical-binding: t; -*-
;;; $Author: tv.raman.tv $
;;; Description:  Speech-enable SAGE An Emacs Interface to sage
;;; Keywords: Emacspeak,  Audio Desktop sage
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
;;;Copyright (C) 1995 -- 2007, 2011, T. V. Raman
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
;;; MERCHANTABILITY or FITNSAGE FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Emacs; see the file COPYING.  If not, write to
;;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;{{{  introduction

;;; Commentary:
;;; Speech-enable @code{sage-shell-mode}.
;;; This is a major mode for interacting with @code{sage},
;;;  @url{http://www.sagemath.org/}
;;; An Open-source  Mathematical Software System.

;;; Code:

;;}}}
;;{{{  Required modules

(require 'cl-lib)
(cl-declaim  (optimize  (safety 0) (speed 3)))
(require 'emacspeak-preamble)

;;}}}
;;{{{ Interactive Commands:

'(
  sage-mode

sage-shell-blocks:backward
sage-shell-blocks:forward
sage-shell-blocks:pull-next
sage-shell-blocks:send-current

sage-shell-info
sage-shell-info-send-doctest
sage-shell-menu
sage-shell-mode
sage-shell-pdb:input-continue
sage-shell-pdb:input-down
sage-shell-pdb:input-help
sage-shell-pdb:input-next
sage-shell-pdb:input-quit
sage-shell-pdb:input-run
sage-shell-pdb:input-step
sage-shell-pdb:input-until
sage-shell-pdb:input-up
sage-shell-pdb:input-where
sage-shell-pdb:set-break-point-at-point
sage-shell-sagetex:compile-current-file
sage-shell-sagetex:compile-file
sage-shell-sagetex:error-mode
sage-shell-sagetex:load-current-file
sage-shell-sagetex:load-file
sage-shell-sagetex:run-latex-and-load-current-file
sage-shell-sagetex:run-latex-and-load-file
sage-shell-sagetex:send-environment
sage-shell-tab-command
sage-shell-view
sage-shell-view-enable-inline-output
sage-shell-view-enable-inline-plots
sage-shell-view-mode
sage-shell-view-toggle-inline-output
sage-shell-view-toggle-inline-plots
sage-shell:attach-file
sage-shell:check-ipython-version
sage-shell:clear-current-buffer
sage-shell:comint-send-input
sage-shell:complete
sage-shell:copy-previous-output-to-kill-ring
sage-shell:define-alias
sage-shell:delchar-or-maybe-eof
sage-shell:delete-output


sage-shell:ido-input-history
sage-shell:interrupt-subjob
sage-shell:list-outputs
sage-shell:list-outputs-mode
sage-shell:load-file
sage-shell:next-input
sage-shell:output-backward
sage-shell:output-forward
sage-shell:restart-sage
sage-shell:run-new-sage
sage-shell:run-sage
sage-shell:sage-mode
sage-shell:sagetex-load-file
sage-shell:send-all-doctests
sage-shell:send-doctest
sage-shell:send-eof
sage-shell:send-input
sage-shell:set-process-buffer
)

;;}}}
;;{{{ Advice Help:
(defadvice sage-shell-help:describe-symbol (after emacspeak pre act comp)
  "Provide auditory feedback."
  (with-current-buffer (window-buffer (selected-window))
    (emacspeak-auditory-icon 'help) (emacspeak-speak-buffer)))

(cl-loop
 for f in 
 '(
   sage-shell-help:forward-history sage-shell-help:backward-history
   sage-shell:help )
 do
 (eval
  `(defadvice ,f (after emacspeak pre act comp )
     "Provide auditory feedback."
     (when (ems-interactive-p)
       (emacspeak-auditory-icon 'help)
       (emacspeak-speak-buffer)))))

(emacspeak-auditory-icon 'help)

;;}}}
;;{{{ Advice sage-edit:

(cl-loop
 for f in 
 '(
   sage-shell-edit:load-current-file
   sage-shell-edit:load-current-file-and-go
   sage-shell-edit:load-file
   sage-shell-edit:load-file-and-go
   sage-shell-edit:pop-to-process-buffer
   sage-shell-edit:send--buffer
   sage-shell-edit:send--buffer-and-go
   sage-shell-edit:send-buffer
   sage-shell-edit:send-buffer-and-go
   sage-shell-edit:send-defun
   sage-shell-edit:send-defun-and-go
   sage-shell-edit:send-line
   sage-shell-edit:send-line*
   sage-shell-edit:send-line-and-go
   sage-shell-edit:send-region
   sage-shell-edit:send-region-and-go)
 do
 (eval
  `(defadvice ,f (after emacspeak pre act comp)
     "Provide auditory feedback."
     (when (ems-interactive-p)
       (emacspeak-auditory-icon 'task-done)
       (emacspeak-speak-mode-line)))))

;;}}}
(provide 'emacspeak-sage)
;;{{{ comint interaction:

(defadvice sage-shell:send-input (around emacspeak pre act comp)
  "Provide auditory feedback."
  (cond
   ((ems-interactive-p)
    (emacspeak-auditory-icon 'close-object)
    (let ((orig (line-beginning-position)))
      ad-do-it
      (emacspeak-speak-region orig (point))))
(t ad-do-it))
  ad-return-value)

;;}}}
;;{{{ end of file

;;; local variables:
;;; folded-file: t
;;; byte-compile-dynamic: t
;;; end:

;;}}}
