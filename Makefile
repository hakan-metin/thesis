TEX      := pdflatex
TEXFLAGS := -halt-on-error -interaction nonstopmode
BIB      := bibtex
BIBFLAGS := -terse
VIEW     := evince

NAME     := thesis
DATA     := data/
OBJ      := obj/
PDF      := pdf/
GTEX     := gtex/
SCRIPT   := script/

MAKEFLAGS += -rR --no-print-directory

V ?= 1

ifeq ($(V),1)
  define print
    @echo '$(1)'
  endef
endif
ifneq ($(V),2)
  TEX := ! $(TEX)
  S   := | grep -A 10 '^!'
  W   := | grep  -e "LaTeX Warning.*" \
                 -e "LaTeX Error.*" \
                 -e "I couldn't open file.*" || true
  Q   := @
endif

default: all
all: $(NAME).pdf
view: $(NAME).pdf
	$(call print,  VIEW    $<)
	$(Q)$(VIEW) $< 2>/dev/null

daemon:
	$(call print,  DAEMON)
	$(Q)+$(MAKE) all
	$(Q)+$(MAKE) view &
	$(Q)while true ; do $(MAKE) V=$(V) update ; sleep 1 ; done

update: all | silent
silent:
	+@:

main.pdf: $(wildcard *.tex) $(wildcard fig/*.tex) main.bib
	$(call print,  TEX(1)  $@)
	$(Q)$(TEX) $(TEXFLAGS) main.tex $(S)
	$(call print,  BIBTEX  $@)
	$(Q)$(BIB) $(BIBFLAGS) main
	$(call print,  TEX(2)  $@)
	$(Q)$(TEX) $(TEXFLAGS) main.tex $(S)
	$(call print,  TEX(3)  $@)
	$(Q)$(TEX) $(TEXFLAGS) main.tex $(W)

$(NAME).pdf: main.pdf
	$(call print,  CP      $@)
	$(Q)cp $< $@

$(PDF) $(OBJ) $(GTEX):
	$(call print,  MKDIR   $@)
	$(Q)mkdir $@

clean:
	$(call print,  CLEAN)
	$(Q)-rm -rf *~ *.aux *.log *.nav *.out *.toc *.snm *.bbl *.blg *.gz \
             *.dvi *.lof *.lot $(PDF) $(OBJ) $(GTEX) $(NAME).pdf main.pdf \
             img/logo-upmc-eps-converted-to.pdf 2>/dev/null || true
