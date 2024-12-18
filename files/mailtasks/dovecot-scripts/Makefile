
# helper tools
AWK ?= gawk
SED ?= sed
EINFO ?= echo
CUT ?= cut

# executables
PREFIX := /usr
BINDIR := $(PREFIX)/bin
SBINDIR := $(PREFIX)/sbin

# set default build options if missing
TYPE ?= standard
DIRECT_INITRC ?= n
QUIET ?= y

ifeq ($(QUIET),y)
	verbose := @
endif

local_layers := $(filter-out tmp,$(shell find * -maxdepth 0 -type d))


local_sieve := $(wildcard *.sieve)
detected_sieve := $(local_sieve) $(foreach layer,$(local_layers),$(wildcard $(layer)/*.sieve))

all_svbin := $(notdir $(detected_sieve:.sieve=.svbin))

vpath %.sieve $(local_layers)

.PHONY: clean all 
.SUFFIXES:
.SUFFIXES: .svbin

########################################
#
# Main targets
#

all: $(all_svbin)

########################################
#
# Build svbin
#
%.svbin: %.sieve
	sievec $< $@

########################################
#
# Clean the environment
#

clean:
	rm -f *.svbin
