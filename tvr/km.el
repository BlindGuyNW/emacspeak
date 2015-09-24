;;; Move emacspeak-hyper-keys etc from a list of conses to a list of lists

(defun emacspeak-wizards-migrate-keymap (km)
  "Migrate emacspeak keymaps like hyper to new format."
  (let ((l nil)
        (k (copy-sequence km)))
    (loop for p in k do
          (push (list (car p) (cdr p)) l))
(setq km (copy-sequence l))))


(setq emacspeak-alt-keys (emacspeak-wizards-migrate-keymap emacspeak-alt-keys))
(setq emacspeak-super-keys (emacspeak-wizards-migrate-keymap emacspeak-super-keys))
(setq emacspeak-personal-keys (emacspeak-wizards-migrate-keymap emacspeak-personal-keys))
(setq emacspeak-personal-ctlx-keys (emacspeak-wizards-migrate-keymap emacspeak-personal-ctlx-keys))
