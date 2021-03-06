;;; emacspeak-setup.el --- Setup Emacspeak environment --loaded to start Emacspeak  -*- lexical-binding: t; -*-
;;; $Id$
;;; $Author: tv.raman.tv $
;;; Description:  File for setting up and starting Emacspeak
;;; Keywords: Emacspeak, Setup, Spoken Output
;;{{{  LCD Archive entry:
;;; LCD Archive Entry:
;;; emacspeak| T. V. Raman |raman@cs.cornell.edu
;;; A speech interface to Emacs |
;;; $Date: 2008-06-06 19:00:23 -0700 (Fri, 06 Jun 2008) $ |
;;;  $Revision: 4532 $ |
;;; Location undetermined
;;;

;;}}}
;;{{{  Copyright:

;;;Copyright (C) 1995 -- 2017, T. V. Raman
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
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Emacs; see the file COPYING.  If not, write to
;;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;}}}
;;{{{ Introduction

;;; Commentary:
;;; Entry point for Emacspeak.
;;; The simplest and most basic way to start emacspeak is:
;;; emacs -q -l <emacspeak-dir>/lisp/emacspeak-setup.el
;;; The above starts a vanilla Emacs with just Emacspeak loaded.
;;; Once the above has been verified to work,
;;; You can  add
;;; (load-library "emacspeak-setup")
;;; To your .emacs file.
;;; See tvr/emacs-startup.el in the Emacspeak Git repository for  my setup.

;;; Code:

;;}}}
;;{{{ Required Modules

(require 'cl-lib)
(cl-declaim  (optimize  (safety 0) (speed 3)))
(require 'custom)

;;}}}
;;{{{  Define locations

;;;###autoload
(defvar emacspeak-directory
  (expand-file-name "../" (file-name-directory load-file-name))
  "Directory where emacspeak is installed. ")

;;;###autoload
(defvar emacspeak-lisp-directory
  (expand-file-name  "lisp/" emacspeak-directory)
  "Directory where emacspeak lisp files are  installed. ")

;;;###autoload
(defvar emacspeak-sounds-directory
  (expand-file-name  "sounds/" emacspeak-directory)
  "Directory containing auditory icons for Emacspeak.")

;;;###autoload
(defvar emacspeak-xslt-directory
  (expand-file-name "xsl/" emacspeak-directory)
  "Directory holding XSL transformations.")

;;;###autoload
(defvar emacspeak-etc-directory
  (expand-file-name  "etc/" emacspeak-directory)
  "Directory containing miscellaneous files  for Emacspeak.")

;;;###autoload
(defvar emacspeak-servers-directory
  (expand-file-name  "servers/" emacspeak-directory)
  "Directory containing speech servers  for Emacspeak.")

;;;###autoload
(defvar emacspeak-info-directory
  (expand-file-name  "info/" emacspeak-directory)
  "Directory containing  Emacspeak info files.")

;;;###autoload
(defvar emacspeak-resource-directory (expand-file-name "~/.emacspeak/")
  "Directory where Emacspeak resource files
such as pronunciation dictionaries are stored. ")

;;;###autoload
(defvar emacspeak-readme-file
  (expand-file-name "README" emacspeak-directory)
  "README file from where we get Git  revision number.")

;;;###autoload
(defvar emacspeak-media-extensions
  (let
      ((ext
        '("mov" "wma" "wmv" "flv" "m4a" "m4b"  "flac" "aiff" "aac" "opus ""mkv"
          "ogv" "oga""ogg" "mp3"  "mp4" "webm" "wav")))
    (concat
     "\\."
     (regexp-opt
      (nconc ext (mapcar #'upcase ext))
      'parens)
     "$"))
  "Extensions that match media files.")

(defvar  emacspeak-m-player-playlist-pattern
  (concat
   (regexp-opt
    (list ".m3u" ".asx" ".pls" ".rpm" ".ram"))
   "$")
  "Pattern for matching playlists.")

;;}}}
;;{{{ Hooks

(push emacspeak-lisp-directory load-path)
(push (expand-file-name "g-client" emacspeak-lisp-directory) load-path)

(let ((file-name-handler-alist nil)
      (load-source-file-function  nil))
  (load (expand-file-name "emacspeak.elc" emacspeak-lisp-directory)))

;;;###autoload
(defcustom dtk-startup-hook
  '(emacspeak-tts-startup-hook emacspeak-tts-notify-hook)
  "List of hooks to be run after starting up the speech server.
Set things like speech rate, punctuation mode etc in this
hook."
  :type 'hook
  :group 'tts)

;;;###autoload
(defun emacspeak-tts-startup-hook ()
  "Default hook function run after TTS is started."
  (cl-declare (special dtk-program))
  (tts-configure-synthesis-setup dtk-program))


;;;###autoload
(defcustom tts-notification-device
  (cl-first (split-string (shell-command-to-string  "aplay -L 2>/dev/null | grep mono")))
  "Virtual ALSA device to use for notifications stream."
  :type 'string
  :group 'tts)

;;;###autoload
(defun emacspeak-tts-multistream-p (tts-engine)
  "Checks if this tts-engine can support multiple streams."
  (and
   (member tts-engine '("outloud" "32-outloud" "cloud-outloud"))
   (not (string= (dtk-get-notify-alsa-device) "default"))))

(defcustom emacspeak-tts-use-notify-stream
  (when (emacspeak-tts-multistream-p dtk-program) t)
  "Set to true to use a separate TTS stream for notifications."
  :type 'boolean
  :group 'emacspeak)

(defun emacspeak-tts-use-notify-stream-p ()
  "Predicate to check if we use a separate notify stream."
  (cl-declare (special emacspeak-tts-use-notify-stream))
  emacspeak-tts-use-notify-stream)

(defun emacspeak-tts-notify-hook ()
  "Starts up a notification stream if current synth supports  multiple invocations.
TTS engine should use ALSA for this to be usable."
  (cl-declare (special dtk-program dtk-notify-process
                       emacspeak-tts-use-notify-stream))
  (when (process-live-p dtk-notify-process) (delete-process dtk-notify-process))
  (when (and emacspeak-tts-use-notify-stream (emacspeak-tts-multistream-p dtk-program))
    (dtk-notify-initialize)))

;;;###autoload
(defun emacspeak-setup-header-line ()
  "Set up Emacspeak to speak a default header line."
  (cl-declare (special emacspeak-use-header-line
                       header-line-format emacspeak-header-line-format))
  (when emacspeak-use-header-line
    (setq header-line-format emacspeak-header-line-format)))

(defun emacspeak-turn-off-visual-line-mode ()
  "This function turns off visual line mode globally.
It's placed by default on customizable option `emacspeak-startup-hook'."
  (global-visual-line-mode -1))
;;;###autoload
(defcustom emacspeak-startup-hook
  '(emacspeak-setup-header-line emacspeak-turn-off-visual-line-mode)
  "Hook run after Emacspeak is started."
  :type 'hook
  :group 'emacspeak)

(defvar emacspeak-info-already-loaded nil
  "Track info support load.")

(add-hook
 'Info-mode-hook
 #'(lambda ()
     (let ((file-name-handler-alist nil)
           (load-source-file-function  nil))
       (unless emacspeak-info-already-loaded
         (load-library "emacspeak-info"))
       (setq emacspeak-info-already-loaded t))))

;;}}}

(emacspeak)

(provide 'emacspeak-setup)
;;{{{  emacs local variables

;;; local variables:
;;; mode: emacs-lisp
;;; folded-file: t
;;; end:

;;}}}
