;;; Locate A Window -*- lexical-binding: t; -*-
(defun loc (&optional corners)
  "describe location"
  (interactive "P")
  (or corners (setq corners (window-edges)))
  (let*
      ((fw (frame-width))
       (fh (1- (frame-height)))
       (tr 0)
       (mr (/ (frame-height) 2))
       (br fh)
       (lc 0)
       (mc (/ (frame-width) 2))
       (rc fw))
    (dtk-speak 
     (cond
      ((equal corners `(,lc ,tr ,mc ,br))
       (sox-multiwindow)
       'left-half)
      ((equal corners `(,mc ,tr ,rc, br))
       (sox-multiwindow 'swap)
       'right-half)
      ((equal corners `(,lc ,tr ,rc ,mr))
       (sox-multiwindow  nil 2.5)
       'top-half)
      ((equal corners `(,lc ,mr ,rc ,br))
       (sox-multiwindow nil 1.5)
       'bottom-half)
      ((equal corners `(,lc ,tr ,mc ,mr)) 
       (sox-multiwindow nil 2.5)
       'top-left)
      ((equal corners `(,mc ,tr ,rc ,mr))
       (sox-multiwindow t 2.5)
       'top-right)
      ((equal corners `(,lc ,mr ,mc ,br))
       (sox-multiwindow nil 1.5)
       'bottom-left)
      ((equal corners `(,mc ,mr ,rc ,br))
       (sox-multiwindow t 1.5)
       'bottom-right)
      (t 'no-match)))))



