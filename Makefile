# $Author: tv.raman.tv $
# Description:  Makefile for Emacspeak
# Keywords: Emacspeak,  TTS,Makefile
# {{{ LCD Entry:

# LCD Archive Entry:
# emacspeak| T. V. Raman |raman@cs.cornell.edu
# A speech interface to Emacs |
# Location undetermined
#

# }}}
# {{{ Copyright:

#Copyright (C) 1995 -- 2015, T. V. Raman

# Copyright (c) 1994, 1995 by Digital Equipment Corporation.
# All Rights Reserved.
#
# This file is not part of GNU Emacs, but the same permissions apply.
#
# GNU Emacs is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# GNU Emacs is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GNU Emacs; see the file COPYING.  If not, write to
# the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

# }}}
# {{{ Configuration

MAKE=make
prefix = /usr
SRC = $(shell pwd)

# }}}
# {{{ setup distribution

# source files to distribute
README = README

# }}}
# {{{  User level targets emacspeak info 

emacspeak:
	test -f  lisp/emacspeak-loaddefs.el || ${MAKE} config
	cd lisp; $(MAKE)
	touch   $(README)
	chmod 644 $(README)
	@echo "See the NEWS file for a  summary of new features --control e cap n in Emacs"
	@echo "See Emacspeak Customizations for customizations -- control e cap C in Emacs"
	@echo "Use C-h p in Emacs for a package overview"
	@echo "Make sure you read the Emacs info pages"

info:
	cd info; $(MAKE) -k

outloud: 
	cd servers/linux-outloud; $(MAKE) || echo "Cant build Outloud server!"

espeak: 
	cd servers/linux-espeak; $(MAKE) || echo "Cant build espeak server!"

# }}}
# {{{  Maintainance targets   dist

GITVERSION=$(shell git show HEAD | head -1  | cut -b 8- )
README: 
	@rm -f README
	@echo "Emacspeak  Revision $(GITVERSION)" > $(README)
	@echo "Distribution created by `whoami` on `hostname`" >> $(README)
	@echo "Unpack the  distribution And type make config " >> $(README)
	@echo "Then type make" >> $(README)
EXCLUDES=-X .excludes
dist:
	make ${README}
	tar cvf  emacspeak.tar $(EXCLUDES) .

# }}}
# {{{ User level target--  config

config:
	cd etc &&   $(MAKE) config  
	cd lisp && $(MAKE) config
	@echo "Configured emacspeak in directory $(SRC). Now type make emacspeak"

# }}}
# {{{  complete build

all: emacspeak

#clean, config and build
q:
	make clean
	make config 
	make 

# }}}
# {{{  user level target-- clean

clean:
	cd lisp; $(MAKE) clean

# }}}
# {{{ labeling releases

#label  releases when ready
LABEL=#version number
MSG="Releasing ${LABEL}"
release: #supply LABEL=NN.NN
	git tag -a -s ${LABEL} -m "Tagging release with ${LABEL}"
	git push --tags
	$(MAKE) dist
	mkdir emacspeak-${LABEL}; \
cd emacspeak-${LABEL} ;\
	tar xvf ../emacspeak.tar ; \
	rm -f ../emacspeak.tar ; \
cd .. ;\
	tar cvfj emacspeak-${LABEL}.tar.bz2 emacspeak-$(LABEL); \
	/bin/rm -rf emacspeak-${LABEL} ;\
	echo "Prepared release in emacspeak-${LABEL}.tar.bz2"
	./utils/emacspeak-ghr ${LABEL} "emacspeak-${LABEL}.tar.bz2"

# }}}
# {{{Install: Not Supported

install:
	@echo "Install is not supported by the source distribution."

# }}}
# {{{ end of file

#local variables:
#major-mode: makefile-mode
#eval:  (fold-set-marks "# {{{" "# }}}")
#fill-column: 90
#folded-file: t
#end:

# }}}
