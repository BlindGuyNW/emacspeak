;;; Configuring Emacs to send GMail:
;;; Auth credentials are taken from .authinfo.gpg

(require 'smtpmail)

(setq
 send-mail-function 'smtpmail-send-it
 smtpmail-smtp-server "smtp.gmail.com"
 smtpmail-smtp-service 587)

(when (locate-library "smtpmail-async")
  (require 'smtpmail-async)
  (setq send-mail-function 'async-smtpmail-send-it
        message-send-mail-function 'async-smtpmail-send-it))
(provide 'gm-smtp)
