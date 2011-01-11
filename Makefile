# license type: free of charge license for academic and research purpose
# see license.txt
# author: Bertrand Ducourthial
# revision : 6/12/2010

# Makefile de la distribution airplug
# niveau 2 generique pour skl
# presence de sous-repertoires

# Pour eviter d'eventuels problemes provenant de l'heritage de
# variables SHELL depuis l'environnement :
SHELL = /bin/bash

# Repertoire d'installation de la distribution airplug
DIR_INSTALL = ..

# Liste des fichiers pour l'archive 'publique'
TGZ_PUB = Makefile tgz-history.txt license.txt README.pub

# Liste des fichiers pour l'archive 'developpement'
TGZ_DEV = $(TGZ_PUB) README.dev

# Liste des fichiers pour l'archive 'distribution squelette'
TGZ_SKL = $(TGZ_PUB)

# Export de la variable pour les sous-makefiles
export DIR=$(shell pwd | rev | cut -d'/' -f 1 | rev)

VERSION=$(shell ls -l | grep -e "->" | cut -d'>' -f 2 | cut -d '-' -f 2 | cut -d'/' -f1)

MAKE = make
# options pour make
# -s : silent, -e : predominance des variables initialisees ici sur celles
# initialisees par defaut dans les sous-makefiles
MFLAGS = -e -s


# pour eviter d'eventuels problemes si un fichier a le nom d'une regle
.PHONY: build clean depend files-tgz-dev files-tgz-skl files-tgz-pub \
	help icon incr install list reset tgz-pub tgz-dev tgz-skl version

# premiere regle = regle par defaut (help)
help:
	@echo " +++ $(OUTPUT) : aide" ;
	@echo "     make build   : compilation" ;
	@echo "     make clean   : suppression des fichiers temporaires" ;
	@echo "     make depend  : calcul des dependances (avant compilation)" ;
	@echo "     make icon    : creation de l'icone de l'application";
	@echo "     make incr    : incrementation du numero de version";
	@echo "     make install : installation du programme (apres compilation)" ;
	@echo "     make list    : liste des fichiers" ;
	@echo "     make reset   : clean + suppression des executables compiles" ;
	@echo "     make tgz-pub : archivage des sources pour distribution publique";
	@echo "     make tgz-dev : archivage des sources pour distribution de developpement";
	@echo "     make tgz-skl : archivage des sources pour embryon de distribution";
	@echo "     make version : affichage de la version, de la license et des auteurs";


build depend icon instal install list reset:
	@echo " +++ $(DIR) : regle $@" ;
	@if [ -e $(DIR)/Makefile ]; then \
		$(MAKE) $@ $(MFLAGS) -C $(DIR) ; \
	else \
		echo " !   $(DIR) : absence de Makefile dans $(DIR)/$(DIR)" ; \
	fi;

clean:
	@echo " +++ $(DIR) : regle $@" ;
	@echo "     suppression des *~ *bak *tgz files-tgz-*.txt" ;
	@rm -f *~ *bak *tgz files-tgz-*.txt ;
	@if [ -e $(DIR)/Makefile ]; then \
		$(MAKE) $@ $(MFLAGS) -C $(DIR) ; \
	else \
		echo " !   $(DIR) : absence de Makefile dans $(DIR)/$(DIR)" ; \
	fi;

incr:
	@echo " +++ $(DIR) : regle $@" ;
	@echo "     passage de la version $(VERSION) a `$(DIR_INSTALL)/bin/incr_version.sh $(VERSION)`" ;
	@cp -r $(DIR)-$(VERSION) $(DIR)-`$(DIR_INSTALL)/bin/incr_version.sh $(VERSION)` ;
	@rm $(DIR)
	@ln -s $(DIR)-`$(DIR_INSTALL)/bin/incr_version.sh $(VERSION)` $(DIR)

files-tgz-dev:
	@echo " +++ $(DIR) : regle $@" ;
	@if [ -e ./files-tgz-dev.txt ] ; then \
		rm ./files-tgz-dev.txt ; \
	fi ;
	@for F in $(TGZ_DEV) ; do \
		if [ -e $$F ]; then \
			echo $$F >> ./files-tgz-dev.txt ; \
		else \
			echo "! $(DIR) : $$F manquant" ; \
		fi; \
	done ;
	@echo "$(DIR)" >> ./files-tgz-dev.txt ;
	@echo "$(DIR)-$(VERSION)" >> ./files-tgz-dev.txt ;
	@if [ -e $(DIR)/Makefile ]; then \
		$(MAKE) $@ $(MFLAGS) -C $(DIR) ; \
		for F in `cat $(DIR)/files-tgz-dev.txt` ; do \
			echo "$(DIR)-$(VERSION)/$$F" >> ./files-tgz-dev.txt ; \
		done ; \
	else \
		echo " !   $(DIR) : absence de Makefile dans $(DIR)/$(DIR)" ; \
	fi;

files-tgz-pub:
	@echo " +++ $(DIR) : regle $@" ;
	@if [ -e ./files-tgz-pub.txt ] ; then \
		rm ./files-tgz-pub.txt ; \
	fi ;
	@for F in $(TGZ_PUB) ; do \
		if [ -e $$F ]; then \
			echo $$F >> ./files-tgz-pub.txt ; \
		else \
			echo "! $(DIR) : $$F manquant" ; \
		fi; \
	done ;
	@echo "$(DIR)" >> ./files-tgz-pub.txt ;
	@echo "$(DIR)-$(VERSION)" >> ./files-tgz-pub.txt ;
	@if [ -e $(DIR)/Makefile ]; then \
		$(MAKE) $@ $(MFLAGS) -C $(DIR) ; \
		for F in `cat $(DIR)/files-tgz-pub.txt` ; do \
			echo "$(DIR)/$$F" >> ./files-tgz-pub.txt ; \
		done ; \
	else \
		echo " !   $(DIR) : absence de Makefile dans $(DIR)/$(DIR)" ; \
	fi;

files-tgz-skl:
	@echo " +++ $(DIR) : regle $@" ;
	@if [ -e ./files-tgz-skl.txt ] ; then \
		rm ./files-tgz-skl.txt ; \
	fi ;
	@for F in $(TGZ_SKL) ; do \
		if [ -e $$F ]; then \
			echo $$F >> ./files-tgz-skl.txt ; \
		else \
			echo "! $(DIR) : $$F manquant" ; \
		fi; \
	done ;
	@echo "$(DIR)" >> ./files-tgz-skl.txt ;
	@echo "$(DIR)-$(VERSION)" >> ./files-tgz-skl.txt ;
	@if [ -e $(DIR)/Makefile ]; then \
		$(MAKE) $@ $(MFLAGS) -C $(DIR) ; \
		for F in `cat $(DIR)/files-tgz-skl.txt` ; do \
			echo "$(DIR)-$(VERSION)/$$F" >> ./files-tgz-skl.txt ; \
		done ; \
	else \
		echo " !   $(DIR) : absence de Makefile dans $(DIR)/$(DIR)" ; \
	fi;

tgz-pub: files-tgz-pub
	@echo " +++ $(DIR) : regle $@" ;
	@echo "     fabrication de l'archive airplug-$(DIR)-$(VERSION)-pub-`hostname`-`date +%Y"-"%m"-"%d`.tgz" ;
	@if  ! [ -e tgz-history.txt ] ; then \
		touch tgz-history.txt ; \
	fi ;
	@echo "$@ dans `pwd` sur `hostname` le `date +%A" "%d" "%B" "%Y" a "%k"h"%M":"%S`" >> tgz-history.txt
	@tar --no-recursion -czf airplug-$(DIR)-$(VERSION)-pub-`hostname`-`date +%Y"-"%m"-"%d`.tgz `cat files-tgz-pub.txt` ;


tgz-dev: files-tgz-dev
	@echo " +++ $(DIR) : regle $@" ;
	@echo "     fabrication de l'archive airplug-$(DIR)-$(VERSION)-dev-`hostname`-`date +%Y"-"%m"-"%d`.tgz" ;
	@if  ! [ -e tgz-history.txt ] ; then \
		touch tgz-history.txt ; \
	fi ;
	@echo "$@ dans `pwd` sur `hostname` le `date +%A" "%d" "%B" "%Y" a "%k"h"%M":"%S`" >> tgz-history.txt
	@tar --no-recursion -czf airplug-$(DIR)-$(VERSION)-dev-`hostname`-`date +%Y"-"%m"-"%d`.tgz `cat files-tgz-dev.txt` ;


tgz-skl: files-tgz-skl
	@echo " +++ $(DIR) : regle $@" ;
	@echo "     fabrication de l'archive airplug-$(DIR)-$(VERSION)-skl-`hostname`-`date +%Y"-"%m"-"%d`.tgz" ;
	@if  ! [ -e tgz-history.txt ] ; then \
		touch tgz-history.txt ; \
	fi ;
	@echo "$@ dans `pwd` sur `hostname` le `date +%A" "%d" "%B" "%Y" a "%k"h"%M":"%S`" >> tgz-history.txt
	@tar --no-recursion -czf airplug-$(DIR)-$(VERSION)-skl-`hostname`-`date +%Y"-"%m"-"%d`.tgz `cat files-tgz-skl.txt` ;

version:
	@echo " +++ $(DIR) : regle $@";
	@echo "     repertoire d'installation = $(DIR_INSTALL)" ;
	@echo "     version utilisee = $(VERSION)" ;
	@echo "     license   =`cat license.txt | grep "license type:" | cut -d':' -f2`" ;
	@echo "     auteur(s) =`cat license.txt | grep "software author(s):" | cut -d':' -f2`" ;
