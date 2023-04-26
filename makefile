SHELL=/bin/sh
RELEASE ?= latest

ifeq ($(origin RELEASE),file)
	ARCHNOG_PATH=./ArchNog-$(RELEASE).sh
	OLD_RELEASES="Using latest"
else
	OLD_RELEASES=$(subst archives/,,$(dir $(wildcard archives/*/)))
	ifneq (,$(findstring $(RELEASE),$(OLD_RELEASES)))
		ARCHNOG_PATH=./archive/$(RELEASE)/ArchNog.sh
	endif
endif

.PHONY: default  

default: run

run:
ifneq ($(origin ARCHNOG_PATH),file)
	@echo Unset ARCHNOG_PATH to continue
	exit 72
endif
ifneq ($(origin OLD_RELEASES),file)
	@echo Unset OLD_RELEASES to continue
	exit 71
endif

	bash $(ARCHNOG_PATH)