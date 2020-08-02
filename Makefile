#!/bin/bash

LOADER				:=	bin/R^3.swf
LOADER_SOURCE		:=	src/MainLoader.as

MAIN_SHELL			:=	bin/R^3Game.swf
MAIN_SHELL_SOURCE	:=	src/MainShell.as

PRODUCTD:=	bin/r3.swf
PRODUCTR:=	bin/Game.swf
SOURCE	:=	src/Main.as
SOURCES	:=	src
LIBS	:=	src/assets/Assets.swc
DEPS	:=	bin/makedeps.in
FLASH	:=	flashplayerdebugger

export FLEX_HOME=/opt/flex3

MXMLC	:=	$(FLEX_HOME)/bin/mxmlc

FLAGS	:=	-target-player 10 \
			-default-size=780,480 \
			-default-background-color=\#000000 \
			-default-frame-rate=60 \
			-static-link-runtime-shared-libraries=true \
			-compiler.source-path+=src
DEFINES	:=	CONFIG::timeStamp,\'$(shell date +%m/%d/%Y)\' \
			CONFIG::air,false \
			CONFIG::desktop,false \
			PLAYER::target,9
DEFINESD:=	CONFIG::debug,true CONFIG::release,false
DEFINESR:=	CONFIG::debug,false CONFIG::release,true

# arcnmx
FLAGS	:=	$(FLAGS) \
			-compiler.define+=CONFIG::arc_mp,true

FLAGS	:=	$(FLAGS) \
			$(foreach def,$(DEFINES),-compiler.define+=$(def)) \
			$(foreach src,$(SOURCES),-compiler.source-path+=$(src)) \
			$(foreach lib,$(LIBS),-compiler.library-path+=$(lib))

FLAGSD	:=	$(FLAGS) \
			$(foreach def,$(DEFINESD),-compiler.define+=$(def)) \
			-debug=true \
			-incremental=true
FLAGSR	:=	$(FLAGS) \
			$(foreach def,$(DEFINESR),-compiler.define+=$(def)) \
			-compiler.optimize=true \
			-debug=false \
			-incremental=false

all: $(PRODUCTD)
shell: $(MAIN_SHELL)
loader: $(LOADER)
release: $(PRODUCTR)


run: $(PRODUCTD)
	$(FLASH) $(PRODUCTD)

$(PRODUCTD):
	$(MXMLC) $(FLAGSD) $(SOURCE) -output=$(PRODUCTD)

$(PRODUCTR):
	$(MXMLC) $(FLAGSR) $(SOURCE) -output=$(PRODUCTR)

$(MAIN_SHELL): $(PRODUCTR) $(MAIN_SHELL_SOURCE)
	$(MXMLC) $(FLAGSR) $(MAIN_SHELL_SOURCE) -output=$(MAIN_SHELL)

$(LOADER): $(LOADER_SOURCE)
	$(MXMLC) $(FLAGSR) $(LOADER_SOURCE) -output=$(LOADER)

PRODUCTD_SED	:=	$(subst /,\/,$(PRODUCTD))
PRODUCTR_SED	:=	$(subst /,\/,$(PRODUCTR))
gendeps:
	find $(SOURCES) -name '*.as' | sed 's/^src\//$(PRODUCTD_SED): src\//' > $(DEPS)
	find $(SOURCES) -name '*.as' | sed 's/^src\//$(PRODUCTR_SED): src\//' >> $(DEPS)

-include $(DEPS)

.PHONY: all run gendeps shell loader release
