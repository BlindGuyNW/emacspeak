;;; emacspeak-threes.el --- Speech-enable THREES
;;; $Author: tv.raman.tv $
;;; Description:  Speech-enable THREES An Emacs Interface to threes
;;; Keywords: Emacspeak,  Audio Desktop threes
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
;;; MERCHANTABILITY or FITNTHREES FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Emacs; see the file COPYING.  If not, write to
;;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;{{{  introduction

;;; Commentary:
;;; THREES ==  threes game.
;;; Speech-enable the game.

;;; Code:

;;}}}
;;{{{  Required modules

(require 'cl)
(declaim  (optimize  (safety 0) (speed 3)))
(require 'emacspeak-preamble)

;;}}}
;;{{{ Advice interactive commands:
(defun emacspeak-threes-speak-board ()
  "Speak the board."
  (interactive)
  (declare (special threes-cells threes-game-over-p))
(tts-with-punctuations 'some (dtk-speak-list   threes-cells 4))
(emacspeak-auditory-icon 'item))

(defun emacspeak-threes-setup ()
  "Set up additional key-bindings."
  (declare (special threes-mode-map))
  (define-key threes-mode-map "g" 'threes)
  (define-key threes-mode-map " " 'emacspeak-threes-speak-board)
  (define-key threes-mode-map "." 'emacspeak-threes-score)
  (define-key threes-mode-map "n" 'threes-down)
  (define-key threes-mode-map "p" 'threes-up)
  (define-key threes-mode-map "f" 'threes-right)
  (define-key threes-mode-map "b" 'threes-left)
  )
(defadvice threes (after emacspeak pre act comp)
  "Provide auditory feedback."
  (when (ems-interactive-p)
    (emacspeak-auditory-icon 'open-object)
    (emacspeak-threes-speak-board)))

(eval-when '(load) (emacspeak-threes-setup))
(defun emacspeak-threes-score ()
  "Speak the score."
  (interactive)
(message (format "Score: %s" (number-to-string (threes-cells-score)))))

(loop
 for f in
 '(threes-up threes-down threes-left threes-right)
 do
 (eval
  `(defadvice ,f (after emacspeak pre act comp)
     "Provide auditory feedback"
     (when (ems-interactive-p)
       (emacspeak-threes-speak-board)))))

;;}}}
(provide 'emacspeak-threes)
;;{{{ end of file

;;; local variables:
;;; folded-file: t
;;; byte-compile-dynamic: t
;;; end:

;;}}}
