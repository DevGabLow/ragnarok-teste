

HAVE_MYSQL=yes
OMAP=map-server
ifeq ($(HAVE_MYSQL),yes)
	ALL_DEPENDS=server tools
	SERVER_DEPENDS=common login char map web import
	COMMON_DEPENDS=libconfig rapidyaml yaml-cpp
	LOGIN_DEPENDS=libconfig common
	CHAR_DEPENDS=libconfig common rapidyaml
	MAP_DEPENDS=libconfig common rapidyaml
	WEB_DEPENDS=libconfig common yaml-cpp httplib
else
	ALL_DEPENDS=needs_mysql
	SERVER_DEPENDS=needs_mysql
	COMMON_DEPENDS=needs_mysql
	LOGIN_DEPENDS=needs_mysql
	CHAR_DEPENDS=needs_mysql
	MAP_DEPENDS=needs_mysql
	WEB_DEPENDS=needs_mysql
endif


#####################################################################
.PHONY: all server sql \
	common \
	login \
	char \
	map \
	web \
	tools \
	import \
	clean help \
	install uninstall bin-clean \

all: $(ALL_DEPENDS)

sql: $(SERVER_DEPENDS)
	@echo "-!- 'make sql' is now deprecated. Please run 'make server' to continue. -!-"

server: $(SERVER_DEPENDS)

common: $(COMMON_DEPENDS)
	@$(MAKE) -C src/common server

login: $(LOGIN_DEPENDS)
	@$(MAKE) -C src/login server

char: $(CHAR_DEPENDS)
	@$(MAKE) -C src/char

map: $(MAP_DEPENDS)
	@$(MAKE) -C src/map server

web: $(WEB_DEPENDS)
	@$(MAKE) -C src/web server

libconfig:
	@$(MAKE) -C 3rdparty/libconfig

tools:
	@$(MAKE) -C src/tool
	@$(MAKE) -C src/map tools

rapidyaml:
	@$(MAKE) -C 3rdparty/rapidyaml

yaml-cpp:
	@$(MAKE) -C 3rdparty/yaml-cpp

httplib:
	@$(MAKE) -C 3rdparty/httplib

import:
# 1) create conf/import folder
# 2) add missing files
# 3) remove remaining .svn folder
	@echo "building conf/import, conf/msg_conf/import and db/import folder..."
	@if test ! -d conf/import ; then mkdir conf/import ; fi
	@for f in $$(ls conf/import-tmpl) ; do if test ! -e conf/import/$$f ; then cp conf/import-tmpl/$$f conf/import ; fi ; done
	@rm -rf conf/import/.svn
	@if test ! -d conf/msg_conf/import ; then mkdir conf/msg_conf/import ; fi
	@for f in $$(ls conf/msg_conf/import-tmpl) ; do if test ! -e conf/msg_conf/import/$$f ; then cp conf/msg_conf/import-tmpl/$$f conf/msg_conf/import ; fi ; done
	@rm -rf conf/msg_conf/import/.svn
	@if test ! -d db/import ; then mkdir db/import ; fi
	@for f in $$(ls db/import-tmpl) ; do if test ! -e db/import/$$f ; then cp db/import-tmpl/$$f db/import ; fi ; done
	@rm -rf db/import/.svn

clean:
	@$(MAKE) -C src/common $@
	@$(MAKE) -C 3rdparty/libconfig $@
	@$(MAKE) -C 3rdparty/rapidyaml $@
	@$(MAKE) -C 3rdparty/yaml-cpp $@
	@$(MAKE) -C 3rdparty/httplib $@
	@$(MAKE) -C src/login $@
	@$(MAKE) -C src/char $@
	@$(MAKE) -C src/map $@
	@$(MAKE) -C src/web $@
	@$(MAKE) -C src/tool $@

help:
	@echo "most common targets are 'all' 'server' 'conf' 'clean' 'help'"
	@echo "possible targets are:"
	@echo "'common'      - builds object files used for the three servers"
	@echo "'libconfig'   - builds object files of libconfig"
	@echo "'rapidyaml'   - builds object files of rapidyaml"
	@echo "'yaml-cpp'    - builds object files of yaml-cpp"
	@echo "'httplib'     - builds object files of httplib"
	@echo "'login'       - builds login server"
	@echo "'char'        - builds char server"
	@echo "'map'         - builds map server"
	@echo "'web'         - builds web server"
	@echo "'tools'       - builds all the tools in src/tools"
	@echo "'import'      - builds conf/import, conf/msg_conf/import and db/import folders from their template folders (x-tmpl)"
	@echo "'all'         - builds all the above targets"
	@echo "'server'      - builds servers (targets 'common' 'login' 'char' 'map' and 'import')"
	@echo "'clean'       - cleans builds and objects"
	@echo "'install'     - run installer which sets up rathena in /opt/"
	@echo "'bin-clean'   - deletes installed binaries"
	@echo "'uninstall'   - run uninstaller which erases all installation changes"
	@echo "'help'        - outputs this message"

needs_mysql:
	@echo "MySQL not found or disabled by the configure script"
	@exit 1

install:
	@sh ./install.sh

bin-clean:
	@sh ./uninstall.sh bin

uninstall:
	@sh ./uninstall.sh all

#####################################################################
