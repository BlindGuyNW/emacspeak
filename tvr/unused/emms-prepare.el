;; -*- lexical-binding: t; -*-
(require 'cl-lib)
(define-prefix-command 'emms-prefix-command  'emms-prefix-map "EMMS")
(global-set-key (kbd "C-; .") 'emms-prefix-command)
(global-set-key (kbd "C-x @ h .") 'emms-prefix-command)
(use-package emms
  :commands  (emms-browser)
  :config 
  (require 'emms-setup)
  (setq emms-player-list'(emms-player-mplayer-playlist emms-player-mplayer))
  (emms-all)
  (emms-default-players)
  (setq emms-source-file-default-directory "~/mp3")
  )
(cl-loop for key in
      '(
	("b" emms-browser)
        ("<left>" emms-seek-backward)
        ("<right>" ems-seek-forward)
        ("\C-b" emms-seek-backward)
        ("\C-f" emms-seek-forward)
        ("q" emms-stop)
        ("s" emms-start)
        ("." emms-pause)
        ("n" emms-next)
        ("p" emms-previous)
        ("S" emms-shuffle)
        ("d" emms-play-directory)
        ("D" emms-play-directory-tree)
        ("l" emms-locate)
        ("f" emms-play-find)
        ("g" emms-playlist-mode-go)
        ("j" emms-seek)
        ("J" emms-seek-to)
        ("r" emms-random)
        ("i" emms-show)
        (";" emms-streams)
        ("a" emms-add-find)
        )
      do
    (emacspeak-keymap-update emms-prefix-map key))
