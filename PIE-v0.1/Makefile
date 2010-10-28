# license type: free of charge license for academic and research purpose
# see license.txt
# author: Bertrand Ducourthial
# revision: 7/10/2010

# Makefile de la distribution airplug
# niveau 3 specifique tk, adapte pour 'pie'

OUTPUT = "pie"

# Repertoire (herite du Makefile pere)
DIR = PIE

# Repertoire d'installation de la distribution
export DIR_INSTALL = ../..

# Pour eviter d'eventuels problemes provenant de l'heritage de
# variables SHELL depuis l'environnement :
SHELL = /bin/bash

# SOURCES designe tous les .tk du repertoire.
# wildcard realise l'expansion immediate
SOURCES = $(wildcard pie*.tk) rc-pie.tk

# Liste des fichiers pour l'archive 'publique'
TGZ_PUB = $(SOURCES) \
	Makefile \
	license.txt \
	README.pub \
	tgz-history.txt \
	apg-icon-$(OUTPUT).ppm \
	apg-appicon-$(OUTPUT).ppm

# Liste des fichiers pour l'archive 'developpement'
TGZ_DEV = $(TGZ_PUB) \
	README.dev \
	apg-icon-$(OUTPUT).obj \
	apg-appicon-$(OUTPUT).obj

# Liste des fichiers pour l'archive 'distribution squelette'
TGZ_SKL = $(TGZ_PUB)

MAKE = make
# options pour make
# -s : silent, -e : predominance des variables exportees ici sur celles
# initialisees par defaut dans les sous-makefiles
MFLAGS = -s -e

# pour eviter d'eventuels problemes si un fichier a le nom d'une regle
.PHONY: build clean depend files-tgz-dev files-tgz-pub files-tgz-skl \
	help icon incr install list reset tgz-dev tgz-pub tgz-skl version

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
	@echo "     make tgz-pub : archivage des sources pour la version publique";
	@echo "     make tgz-dev : archivage des sources pour la version developpement";
	@echo "     make tgz-skl : archivage des sources pour la distribution squelette";
	@echo "     make version : affichage de la version, de la license et des auteurs";

# absence de compilation donc build et depend sans effet.
# version sans effet dans un Makefile de niveau 3.
build depend incr version:
	@echo "  ++ $(OUTPUT) : regle $@ => sans effet ici"

# absence d'executable donc clean=reset
clean reset:
	@echo "  ++ $(OUTPUT) : regle $@" ;
	@echo "     suppression des *~ *bak *tgz files-tgz-*.txt" ;
	@rm -f *~ *bak *tgz files-tgz-*.txt

list:
	@echo "   + $(OUTPUT) : regle $@"
	@echo "     Sources : $(SOURCES)"

files-tgz-dev:
	@echo "  ++ $(OUTPUT) : regle $@" ;
	@if [ -e ./files-tgz-dev.txt ] ; then \
		rm ./files-tgz-dev.txt ; \
	fi
	@for F in $(TGZ_DEV) ; do \
		echo $$F >> ./files-tgz-dev.txt ; \
	done ;

files-tgz-pub:
	@echo "  ++ $(OUTPUT) : regle $@" ;
	@if [ -e ./files-tgz-pub.txt ] ; then \
		rm ./files-tgz-pub.txt ; \
	fi
	@for F in $(TGZ_PUB) ; do \
		echo $$F >> ./files-tgz-pub.txt ; \
	done ;

files-tgz-skl:
	@echo "  ++ $(OUTPUT) : regle $@" ;
	@if [ -e ./files-tgz-skl.txt ] ; then \
		rm ./files-tgz-skl.txt ; \
	fi
	@for F in $(TGZ_SKL) ; do \
		echo $$F >> ./files-tgz-skl.txt ; \
	done ;

icon: 
	@echo "  ++ $(OUTPUT) : regle $@" ;
	@echo "     creation des icones apg-icon-$(OUTPUT).ppm et apg-appicon-$(OUTPUT).ppm" ;
	@sed -e "s/APP/$(DIR)/g" < $(DIR_INSTALL)/icons/apg-icon-default.obj > apg-icon-$(OUTPUT).obj
	@sed -e "s/APP/$(DIR)/g" < $(DIR_INSTALL)/icons/apg-appicon-default.obj > apg-appicon-$(OUTPUT).obj
	@tgif -print -ppm apg-icon-$(OUTPUT).obj
	@tgif -print -ppm apg-appicon-$(OUTPUT).obj

instal install:
	@echo "  ++ $(OUTPUT) : regle $@" ;
	@echo "     repertoire de la distribution : $(DIR_INSTALL)" ;
	@echo "     repertoire des sources : $(DIR)" ;
	@echo "     lien vers $(OUTPUT).tk dans $(DIR_INSTALL)/bin" ;
	@ln -sf --target-directory $(DIR_INSTALL)/bin ../$(DIR)/$(DIR)/$(OUTPUT).tk ;
	@echo "     lien vers apg-appicon-$(OUTPUT).ppm dans $(DIR_INSTALL)/icons (Window Maker)" ;
	@ln -sf --target-directory $(DIR_INSTALL)/icons ../$(DIR)/$(DIR)/apg-appicon-$(OUTPUT).ppm ;
	@echo "     lien vers apg-icon-$(OUTPUT).ppm dans $(DIR_INSTALL)/icons" ;
	@ln -sf --target-directory $(DIR_INSTALL)/icons ../$(DIR)/$(DIR)/apg-icon-$(OUTPUT).ppm ;
	@if [ -e ~/GNUstep/Library/Icons ] ; then \
		echo "     lien vers apg-icon-$(OUTPUT).ppm dans ~/GNUstep/Library/Icons (Window Maker)" ; \
		ln -sf --target-directory ~/GNUstep/Library/Icons `pwd`/apg-icon-$(OUTPUT).ppm ;\
	fi ;

tgz-dev: files-tgz-dev
	@echo "  ++ $(OUTPUT) : regle $@" ;
	@echo "     fabrication de l'archive airplug-$(OUTPUT)-dev-`hostname`-`date +%d"-"%m"-"%Y`.tgz" ;
	@if  ! [ -e tgz-history.txt ] ; then \
		touch tgz-history.txt ; \
	fi ;
	@echo "$@ dans `pwd` sur `hostname` le `date +%A" "%d" "%B" "%Y" a "%k"h"%M":"%S`" >> tgz-history.txt
	@tar --no-recursion -czf airplug-$(OUTPUT)-dev-`hostname`-`date +%d"-"%m"-"%Y`.tgz `cat files-tgz-dev.txt` ;

tgz-pub: files-tgz-pub
	@echo "  ++ $(OUTPUT) : regle $@" ;
	@echo "     fabrication de l'archive airplug-$(OUTPUT)-pub-`hostname`-`date +%d"-"%m"-"%Y`.tgz" ;
	@if  ! [ -e tgz-history.txt ] ; then \
		touch tgz-history.txt ; \
	fi ;
	@echo "$@ dans `pwd` sur `hostname` le `date +%A" "%d" "%B" "%Y" a "%k"h"%M":"%S`" >> tgz-history.txt
	@tar --no-recursion -czf airplug-$(OUTPUT)-pub-`hostname`-`date +%d"-"%m"-"%Y`.tgz `cat files-tgz-pub.txt` ;

tgz-skl: files-tgz-skl
	@echo "  ++ $(OUTPUT) : regle $@" ;
	@echo "     fabrication de l'archive airplug-$(OUTPUT)-skl-`hostname`-`date +%d"-"%m"-"%Y`.tgz" ;
	@if  ! [ -e tgz-history.txt ] ; then \
		touch tgz-history.txt ; \
	fi ;
	@echo "$@ dans `pwd` sur `hostname` le `date +%A" "%d" "%B" "%Y" a "%k"h"%M":"%S`" >> tgz-history.txt
	@tar --no-recursion -czf airplug-$(OUTPUT)-skl-`hostname`-`date +%d"-"%m"-"%Y`.tgz `cat files-tgz-skl.txt` ;
