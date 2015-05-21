;;; emacspeak-librivox.el --- Speech-enabled  LIBRIVOX API client
;;; $Id: emacspeak-librivox.el 4797 2007-07-16 23:31:22Z tv.raman.tv $
;;; $Author: tv.raman.tv $
;;; Description:  Speech-enable LIBRIVOX An Emacs Interface to Free Audio Books
;;; Keywords: Emacspeak,  Audio Desktop librivox
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
;;; MERCHANTABILITY or fitness FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Emacs; see the file COPYING.  If not, write to
;;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;{{{  introduction

;;; Commentary:
;;; LIBRIVOX == http://wwwlibrivox.org Free Audio Books
;;; API Info: https://librivox.org/api/info
;;; It provides a simple Web  API
;;; This module implements an Emacspeak Librivox client.

;;; Code:

;;}}}
;;{{{  Required modules

(require 'cl)
(declaim  (optimize  (safety 0) (speed 3)))
(require 'emacspeak-preamble)
(require 'g-utils)

;;}}}
;;{{{ Customizations

(defgroup emacspeak-librivox nil
  "Librivox Access on the Complete Audio Desktop."
  :group 'emacspeak)

(defcustom emacspeak-librivox-directory
  (expand-file-name "librivox"
                    emacspeak-resource-directory)
  "Location where we cache  librivox data.")

(defvar emacspeak-librivox-catalog-location
  (expand-file-name "catalog.csv" emacspeak-librivox-directory)
  "Location where we cache the Librivox catalog.")

;;}}}
;;{{{ Variables:

(defvar emacspeak-librivox-buffer-name
  "*Librivox Interaction*"
  "Name of Librivox interaction buffer.")

;;}}}
;;{{{ API:

(defvar emacspeak-librivox-api-base
  "https://librivox.org/api/feed/"
  "Base REST end-point for Librivox API  access.")

;;; audiobooks:
;;; Params from API Documentation:

;; * id - fetches a single record
;; * since - takes a UNIX timestamp; returns all projects cataloged since that time
;; * author - all records by that author last name
;; * title - all matching titles
;; * genre - all projects of the matching genre
;; * extended - =1 will return the full set of data about the project
;; * limit (default is 50)
;;   * offset

(defsubst emacspeak-librivox-audiobooks-uri (pattern)
  "Search URI for audiobooks."
  (declare (special emacspeak-librivox-api-base))
  (concat emacspeak-librivox-api-base "audiobooks?format=json&" pattern))

;;; Audio Tracks API:
;;; Params:
;; * id - of track itself
;; * project_id - all tracks for project

(defsubst emacspeak-librivox-audiotracks-base (pattern)
  "Base URI for audiotracks."
  (declare (special emacspeak-librivox-api-base))
  (concat emacspeak-librivox-api-base "audiotracks?format=json&" pattern))

;;; Simple Authors API:
;;; Params:
;; * id - of author
;; * last_name - exact match

(defsubst emacspeak-librivox-authors-base ()
  "Base URI for authors."
  (declare (special emacspeak-librivox-api-base))
  (concat emacspeak-librivox-api-base "authors"))

;;}}}
;;{{{ Search Commands:

(defsubst emacspeak-librivox-display-author (author)
  "Display single author."
  (insert 
            (format "%s, " (g-json-get 'last_name author))
            (format "%s " (g-json-get 'first_name author))
            (format "(%s -- %s \n" (g-json-get 'dob author) (g-json-get 'dod author))
            "<br/>"))

(defun emacspeak-librivox-display-authors (authors)
  "Display authors."
  (insert "\n\n<p>\n")
  (cond
   ((= (length authors)1)
    (emacspeak-librivox-display-author (aref authors 0)))
   (t
    (loop
     for a across authors
     do
     (emacspeak-librivox-display-author a))))
  (insert "</p>\n\n"))

(defun emacspeak-librivox-display-book (book)
  "Render book results."
  (insert "<h1>" (g-json-get 'title book) "</h1>\n")
  (insert "<table><tr>\n")
  (insert
   (format "<td><a href='%s'>Listen (RSS)</a></td>\n"
           (g-json-get 'url_rss book)))
  (insert
   (format "<td><a href='%s'>Download</a></td>\n"
           (g-json-get 'url_download book)))
  (insert "</tr></table>\n\n")
  (emacspeak-librivox-display-authors (g-json-get 'authors book))
  (insert "<p>"
          (g-json-get 'description book)
          "</p>\n\n")
  )

(defun emacspeak-librivox-search-by-author (author)
  "Search by author.
Both exact and partial matches for `author'."
  (interactive "sAuthor: ")
  (let* ((url 
          (emacspeak-librivox-audiobooks-uri
           (format "author=%s"
                   (emacspeak-url-encode author))))
         (result (g-json-get-result
                  (format
                   "%s  %s '%s'"
                   g-curl-program g-curl-common-options url)))
         (books (g-json-get 'books result)))
    (when books
      (with-temp-buffer
        (insert "<title>Author Search For " author "</title>")
                
        (loop
         for b across books
         do
         (emacspeak-librivox-display-book b))
        (browse-url-of-buffer)))))

;;}}}


(provide 'emacspeak-librivox)
;;{{{ end of file

;;; local variables:
;;; folded-file: t
;;; byte-compile-dynamic: nil
;;; end:

;;}}}
