#!/usr/bin/make -f
#
# Debian Installer system makefile.
# Copyright 2001-2003 by Joey Hess <joeyh@debian.org> and the d-i team.
# Licensed under the terms of the GPL.
#
# This makefile builds a debian-installer system and bootable images from 
# a collection of udebs which it downloads from a Debian archive. See
# README for details.
#
#
# General layout of our build directory hierarchy
#
# build/config/[<subarch>/][<medium>/][<flavour>/]<leaf-config>
# build/tmp/[<subarch>/][<medium>/][<flavour>/]<build-area>
# build/dest/[<subarch>/][<medium>/][<flavour>-]<images>
#
# Items in brackets can be left out if they are superfluous.
#
# These following <image> names are conventional.
#
# For small changeable media (floppies and the like):
# - boot.img, root.img, driver.img
#
# For single bootable images (e.g. tftp boot images):
# - boot.img
#
# For compressed single bootable images (harddisk or hd emulation):
# - boot.img.gz
#
# If those are not bootable:
# - root.img.gz
#
# Raw kernel images:
# - vmlinux or vmlinuz
#
# Example:
#
# dest/
# |-- cdrom-boot.img
# |-- floppy
# |   |-- access
# |   |   |-- boot.img
# |   |   |-- drivers.img
# |   |   `-- root.img
# |   |-- boot.img
# |   |-- cd-drivers.img
# |   |-- net-drivers.img
# |   `-- root.img
# |-- hd-media-boot.img.gz
# `-- netboot
#     |-- initrd.gz
#     `-- vmlinuz
#

# Temporary workaround for #823881:
export MTOOLS_SKIP_CHECK=1

# Add to PATH so dpkg will always work, and so local programs will be found.
PATH := util:$(PATH):/usr/sbin:/sbin
EATMYDATA = $(shell which eatmydata 2>/dev/null)
gzip = $(shell which pigz >/dev/null 2>&1 && echo "pigz -n -T" || echo "gzip -n")

# We don't want this to be run each time we re-enter.
ifndef DEB_HOST_ARCH
DEB_HOST_ARCH = $(shell dpkg-architecture -qDEB_HOST_ARCH)
DEB_HOST_ARCH_OS = $(shell dpkg-architecture -qDEB_HOST_ARCH_OS)
DEB_HOST_GNU_CPU = $(shell dpkg-architecture -qDEB_HOST_GNU_CPU)
DEB_HOST_GNU_SYSTEM = $(shell dpkg-architecture -qDEB_HOST_GNU_SYSTEM)
DEB_HOST_MULTIARCH = $(shell dpkg-architecture -qDEB_HOST_MULTIARCH)
export DEB_HOST_ARCH DEB_HOST_ARCH_OS DEB_HOST_GNU_CPU DEB_HOST_GNU_SYSTEM DEB_HOST_MULTIARCH
endif

define drop_lang
	@echo "Dropping languages: $(1)"
	@set -e; \
	for FILE in $$(find $(TREE)/var/lib/dpkg -name "*.templates"); do \
		perl -e 'my $$status=0; my $$drop=shift; while (<>) { if (/^[A-Z]/ || /^$$/) { if (/^(Choices|Description|Indices|Default)-($$drop)/ && ! /^Choices-C:/) { $$status = 0 } else { $$status = 1 } } print if ($$status); }' $(1) < $$FILE > temp; \
		mv temp $$FILE; \
	done
endef

# We loop over all needed combinations of ARCH, SUBARCH, MEDIUM, FLAVOUR
# via recursive make calls. ARCH is constant, we don't support
# crosscompiling.
ARCH = $(DEB_HOST_ARCH)

# By default, we just advertise what we can do.
.PHONY: all
all: list

# Globally useful variables.
targetstring = $(patsubst _%,%,$(if $(SUBARCH),_$(SUBARCH),)$(if $(MEDIUM),_$(MEDIUM),)$(if $(FLAVOUR),_$(FLAVOUR),))
targetdirs = $(subst _,/,$(targetstring))

# Overridden in config/hurd.cfg
define genext2fs
  genext2fs -d $(TREE) -b `expr $$(du -s $(TREE) | cut -f 1) + $$(expr $$(find $(TREE) | wc -l) \* 2)` -m 0
endef

# Configurations for the varying ARCH, SUBARCH, MEDIUM, FLAVOUR.
# For simplicity, we use a similiar tree layout for config/, tmp/
# and dest/.
#
# Cheap trick: if one of the variables isn't defined, we run in
# a non-existing file and ignore it.
include config/common
include config/dir
-include config/$(ARCH).cfg
-include config/$(ARCH)/$(SUBARCH).cfg
-include config/$(ARCH)/$(SUBARCH)/$(MEDIUM).cfg
-include config/$(ARCH)/$(SUBARCH)/$(MEDIUM)/$(FLAVOUR).cfg
-include config/local

export KEYRING
export KERNELVERSION
export LOCALUDEBDIR
export SOURCE_DATE_EPOCH

ifneq ($(shell id -u),0)
  ROOTCMD ?= fakeroot
endif

# Useful command sequences
define submake
  $(ROOTCMD) $(MAKE) --no-print-directory -j1
endef

define recurse_once
  @set -e; $(submake) $(1)_$(2)
endef

define recurse_many
  @set -e; $(foreach var,$($(1)_SUPPORTED) $(if $(RECURSE_EXTRA),$($(1)_SUPPORTED_EXTRA)),$(submake) $(2)_$(3) $(1)=$(var);)
endef

define recurse
  $(if $($(1)_SUPPORTED)$(if $(RECURSE_EXTRA),$($(1)_SUPPORTED_EXTRA)),$(call recurse_many,$(1),$(2),$(3)),$(call recurse_once,$(2),$(3)))
endef

define mkinitramfs
  (cd $(TREE) && find . | sort | cpio --reproducible --quiet -o -H newc) >
endef

define clamp_mtimes
  find $(1) -newermt "@$(SOURCE_DATE_EPOCH)" -print0 | xargs -0r touch --no-dereference --date="@$(SOURCE_DATE_EPOCH)"
endef

define normalise_permissions
  find $(1) -type d -print0 | xargs -0r chmod $(DIR_MODE)
  find $(1) -not -type d -and -not -type l -print0 | xargs -0r chmod $(FILE_MODE)
endef

# Limit on mfsroot size. It is determined by NKPT (in <machine/pmap.h).
# On amd64, it can be increased by increasing this variable.  On i386,
# this is a hard limit due to constraints of 4 GiB VM space.
ifeq ($(DEB_HOST_ARCH),kfreebsd-i386)
MFSROOT_LIMIT := 42m
else ifeq ($(DEB_HOST_ARCH),kfreebsd-amd64)
# See Bug#783773 for derivation.
MFSROOT_LIMIT := 78m
endif

define mkfs.ufs1
  sh -c 'makefs -t ffs -T $(SOURCE_DATE_EPOCH) -s $(MFSROOT_LIMIT) -f 3000 -o minfree=0,version=1 $$0 ${TREE}'
endef

define e2fsck
  e2fsck -fy
endef

# Define MKFS_JFFS2 in the config file for your target.
# For example: MKFS_JFFS2 = mkfs.jffs2 -f -p -b -e 0x20000
define mkjffs2
  $(MKFS_JFFS2) -d $(TREE) -o
endef

# A generic recursion rule
.PHONY: all_%
all_%:
	@install -d $(STAMPS)
	$(call recurse,SUBARCH,subarch,$*)

.PHONY: subarch_%
subarch_%:
	$(call recurse,MEDIUM,medium,$*)

.PHONY: medium_%
medium_%:
	$(call recurse,FLAVOUR,flavour,$*)

.PHONY: flavour_%
flavour_%:
	$(if $(targetstring),@$(submake) _$*)

# Validate a targetstring, echo env variables for valid ones
.PHONY: validate_%
validate_%:
	@set -e; \
	SUBARCH= var='$(subst _, ,$(subst validate_,,$@))'; \
	tmp=$$(echo $$var |sed 's/[ ].*$$//'); \
	[ -z '$(SUBARCH_SUPPORTED)$(SUBARCH_SUPPORTED_EXTRA)' ] || [ -z "$$tmp" ] || [ -z "$$(echo $(SUBARCH_SUPPORTED) $(SUBARCH_SUPPORTED_EXTRA) |grep -w $$tmp)" ] || SUBARCH=$$tmp; \
	$(submake) medium_validate SUBARCH=$$SUBARCH var="$$var"

.PHONY: medium_validate
medium_validate:
	@set -e; \
	MEDIUM= var="$(strip $(patsubst $(SUBARCH)%,%,$(var)))"; \
	tmp=$$(echo $$var |sed 's/[ ].*$$//'); \
	[ -z '$(MEDIUM_SUPPORTED)$(MEDIUM_SUPPORTED_EXTRA)' ] || [ -z "$$tmp" ] || [ -z "$$(echo $(MEDIUM_SUPPORTED) $(MEDIUM_SUPPORTED_EXTRA) |grep -w $$tmp)" ] || MEDIUM=$$tmp; \
	$(submake) flavour_validate MEDIUM=$$MEDIUM var="$$var"

.PHONY: flavour_validate
flavour_validate:
	@set -e; \
	FLAVOUR= var="$(strip $(patsubst $(MEDIUM)%,%,$(var)))"; \
	tmp=$$(echo $$var |sed 's/[ ].*$$//'); \
	[ -z '$(FLAVOUR_SUPPORTED)$(FLAVOUR_SUPPORTED_EXTRA)' ] || [ -z "$$tmp" ] || [ -z "$$(echo $(FLAVOUR_SUPPORTED) $(FLAVOUR_SUPPORTED_EXTRA) | grep -w $$tmp)" ] || FLAVOUR=$$tmp; \
	$(submake) finish_validate FLAVOUR=$$FLAVOUR var="$$var"

.PHONY: finish_validate
finish_validate:
	@set -e; \
	var="$(strip $(patsubst $(FLAVOUR)%,%,$(var)))"; \
	if [ -z "$$var" ]; then \
		echo SUBARCH=$$SUBARCH MEDIUM=$$MEDIUM FLAVOUR=$$FLAVOUR; \
	else \
		echo SUBARCH= MEDIUM= FLAVOUR=; \
	fi;


# List all targets useful for direct invocation.
.PHONY: list
list:
	@echo "Useful targets:"
	@echo
	@echo "list"
	@echo "all_build"
	@echo "all_rebuild"
	@echo "stats"
	@echo "all_clean"
	@echo "reallyclean"
	@echo
	@$(submake) all_list RECURSE_EXTRA=1

.PHONY: _list
_list:
	@set -e; \
	echo build_$(targetstring); \
	echo stats_$(targetstring); \
	$(if $(findstring $(MEDIUM),$(WRITE_MEDIA)),echo write_$(targetstring);) \
	echo clean_$(targetstring); \
	echo rebuild_$(targetstring); \
	echo demo_$(targetstring); \
	echo shell_$(targetstring); \
	echo uml_$(targetstring); \
	echo qemu_$(targetstring); \
	echo


# Clean all targets.
.PHONY: reallyclean
reallyclean: all_clean
	for png in $(shell awk -F= '/^SPLASH_PNG=/ {print $$2}' config/*.cfg); do if [ -f $${png%%.png}.svg ]; then rm -f $$png; fi; done
	rm -rf $(APTDIR) $(APTDIR).udeb $(APTDIR).deb $(BASE_DEST) $(BASE_TMP) $(SOURCEDIR) $(DEBUGUDEBDIR)
	rm -f sources.list sources.list.udeb $(LOCALUDEBDIR)/Packages.gz $(LOCALUDEBDIR)/Packages
	rm -rf $(UDEBDIR) $(STAMPS)

# For manual invocation, we provide a generic clean rule.
.PHONY: clean_%
clean_%:
	@$(submake) _clean $(shell $(submake) $(subst clean_,validate_,$@))
	update-manifest

# The general clean rule.
.PHONY: _clean
_clean: tree_umount
	@[ -n "$(SUBARCH) $(MEDIUM) $(FLAVOUR)" ] || { echo "invalid target"; false; }
	-rm -f $(STAMPS)tree-unpack-$(targetstring)-stamp $(STAMPS)tree-$(targetstring)-stamp $(STAMPS)extra-$(targetstring)-stamp $(STAMPS)get_udebs-$(targetstring)-stamp
	rm -f $(TEMP)/diskusage.txt
	rm -f $(TEMP)/all.utf
	rm -f $(TEMP)/unifont.bdf $(TREE)/lib/unifont.bgf
	rm -f pkg-lists/standard-udebs pkg-lists/kernel-module-udebs
	rm -rf $(TARGET)
	rm -rf $(TEMP)

# all_build is provided automagically, but for manual invocation
# we provide a generic build rule.
.PHONY: build_%
build_%:
	@install -d $(STAMPS)
	@$(submake) _build $(shell $(submake) $(subst build_,validate_,$@))

# The general build rule.
.PHONY: _build
_build:
	@[ -n "$(SUBARCH) $(MEDIUM) $(FLAVOUR)" ] || { echo "invalid target"; false; }
	@$(submake) tree_umount $(EXTRATARGETS) $(TARGET)
	# Ensure build results have reproducible mtimes
	@$(clamp_mtimes) $(BASE_DEST)

# Convenience rules to clean and build.
.PHONY: rebuild_%
rebuild_%:
	@$(submake) clean_$(subst rebuild_,,$@) build_$(subst rebuild_,,$@)

.PHONY: _rebuild
_rebuild:
	@$(submake) _clean _build

# Run before releasing built files.
release:
	egrep '^[[:space:]]' $(BASE_DEST)/MANIFEST.udebs | \
		sed 's/^[[:space:]]*//' | sort | uniq > $(BASE_DEST)/udeb.list
	rm -f $(BASE_DEST)/MD5SUMS $(BASE_DEST)/SHA256SUMS
	cd $(BASE_DEST) && md5sum `find -L . -type f | sort` > MD5SUMS # XXX remove this
	cd $(BASE_DEST) && sha256sum `find -L . -type f | sort` > SHA256SUMS
	# We have just modified files
	$(clamp_mtimes) $(BASE_DEST)
	$(normalise_permissions) $(BASE_DEST)

# The general tree target.
$(STAMPS)tree-unpack-$(targetstring)-stamp: $(STAMPS)get_udebs-$(targetstring)-stamp
	dh_testroot
	@[ -d ../debian ] || { echo "directory '../debian' not found; complete source of 'debian-installer' package is required"; false; }
	cd .. && dpkg-checkbuilddeps
	@rm -f $@

	# This build cannot be restarted, because dpkg gets confused.
	rm -rf $(TREE)
	# Set up the basic files [u]dpkg needs.
	mkdir -p $(DPKGDIR)/info
	touch $(DPKGDIR)/status
	# Create a tmp tree
	mkdir -p $(TREE)/tmp
	# Only dpkg needs this stuff, so it can be removed later.
	mkdir -p $(DPKGDIR)/updates/
	touch $(DPKGDIR)/available

ifdef TRANSSTATUS
	# Include translation status file; warn if older than 2 weeks.
	# Do this first to make possible warnings more visible.
	@echo; \
	if [ -f "$(TRANSSTATUS)" ]; then \
		if [ "$(USE_PROPOSED_UPDATES)" != 1 ]; then \
			olddate=$$(grep "^# Generated on:" $(TRANSSTATUS) | sed "s/.*: //"); \
			if [ "$$olddate" ]; then \
				if [ $$(( $$(date -u "+%s") - \
				          $$(date -d "$$olddate" "+%s") \
				       )) -gt 1209600 ]; then \
					echo "WARNING: The data in '$(TRANSSTATUS)' is older than 2 weeks."; \
					echo "         Should it maybe be updated?"; \
					sleep 15; \
				fi; \
			else \
				echo "WARNING: no timestamp found in $(TRANSSTATUS)."; \
				sleep 15; \
			fi; \
		fi; \
		mkdir -p $(TREE)/usr/share/localechooser; \
		cp $(TRANSSTATUS) $(TREE)/usr/share/localechooser/translation-status; \
	else \
		echo "WARNING: the file $(TRANSSTATUS) does not exist."; \
		sleep 5; \
	fi
endif

	# Unpack the udebs with dpkg. This command must run as root
	# or fakeroot.
	echo -n > $(TEMP)/diskusage.txt
	set -e; \
	oldsize=0; oldblocks=0; oldcount=0; for udeb in $(UDEBDIR)/*.udeb ; do \
		if [ -f "$$udeb" ]; then \
			pkg=`basename $$udeb` ; \
			$(EATMYDATA) dpkg $(DPKG_UNPACK_OPTIONS) --path-include='*' --log=/dev/null --root=$(TREE) --unpack $$udeb ; \
			newsize=`du -bs $(TREE) | awk '{print $$1}'` ; \
			newblocks=`du -s $(TREE) | awk '{print $$1}'` ; \
			newcount=`find $(TREE) -type f | wc -l | awk '{print $$1}'` ; \
			usedsize=`echo $$newsize - $$oldsize | bc`; \
			usedblocks=`echo $$newblocks - $$oldblocks | bc`; \
			usedcount=`echo $$newcount - $$oldcount | bc`; \
			version=`dpkg-deb --info $$udeb | sed -n 's/^ Version: //p' | sed 's/+b[0-9]*$$//g'` ; \
			source=`dpkg-deb --info $$udeb | sed -n 's/^ Source: //p'` ; \
			if [ -z "$$source" ]; then \
				source=`dpkg-deb --info $$udeb | awk '/ Package: / { print $$2 }'` ; \
				source_version="$$source (= $$version)" ; \
			elif echo "$$source" | grep -qs '^linux-signed'; then \
				source_version="linux (= $$version)" ; \
			elif echo "$$source" | grep -qs '(.*)'; then \
				source_version=`echo $$source|sed 's/(/(= /'`; \
			else \
				source_version="$$source (= $$version)" ; \
			fi ; \
			echo " $$usedsize B - $$usedblocks blocks - $$usedcount files from $$pkg (version $$version)" >>$(TEMP)/diskusage.txt;\
			echo "$$source_version" >>$(TEMP)/built-using.txt;\
			oldsize=$$newsize ; \
			oldblocks=$$newblocks ; \
			oldcount=$$newcount ; \
		fi; \
	done
	sort -u < $(TEMP)/built-using.txt > $(TEMP)/built-using.txt.new && \
		mv $(TEMP)/built-using.txt.new $(TEMP)/built-using.txt
	sort -n < $(TEMP)/diskusage.txt > $(TEMP)/diskusage.txt.new && \
		mv $(TEMP)/diskusage.txt.new $(TEMP)/diskusage.txt
	grep-dctrl -nsPackage,Version,Architecture '' $(TREE)/var/lib/dpkg/status | \
		perl -nle '$$p = $$_; $$v = <>; chomp $$v; $$a = <>; chomp $$a; <>; print "$$p $$v $$a"' | \
		sort > $(TEMP_UDEB_LIST)

	# Clean up after dpkg.
	rm -rf $(DPKGDIR)/updates
	rm -f $(DPKGDIR)/available $(DPKGDIR)/*-old $(DPKGDIR)/lock

ifdef EXTRAFILES
	# Copy in any extra files.
	set -e; \
	for file in $(EXTRAFILES); do \
		mkdir -p $(TREE)/`dirname $$file`; \
		cp -a $$file $(TREE)/$$file; \
	done
endif

ifdef SSL_CERTS
	# Copy in any SSL certificates.
	mkdir -p $(TREE)/etc/ssl/certs
	cp -a $(SSL_CERTS) $(TREE)/etc/ssl/certs/
	openssl rehash $(TREE)/etc/ssl/certs
	mkdir -p $(TREE)/usr/lib/ssl
	ln -nsf ../../../etc/ssl/certs $(TREE)/usr/lib/ssl/certs
endif

ifeq ($(DEB_HOST_ARCH_OS),linux)
ifdef KERNELVERSION
	# Set up modules.dep, ensure there is at least one standard dir (kernel
	# in this case), so depmod will use its prune list for archs with no
	# modules.
	set -e; \
	$(foreach VERSION,$(KERNELVERSION), \
		sysmap_name=; sysmap_opt=; \
		if [ -n "$(VERSIONED_SYSTEM_MAP)" ]; then \
			[ ! -e $(TREE)/boot/System.map-$(VERSION) ] || sysmap_name="$(TREE)/boot/System.map-$(VERSION)"; \
		else \
			[ ! -e $(TREE)/boot/System.map ] || sysmap_name="$(TREE)/boot/System.map"; \
		fi; \
		[ -z "$$sysmap_name" ] || sysmap_opt="-F $$sysmap_name"; \
		if [ -d $(TREE)/lib/modules/$(VERSION) ] && [ -z "$(OMIT_DEPMOD)" ]; then \
			mkdir -p $(TREE)/lib/modules/$(VERSION)/kernel; \
			$(shell choose-subarch-env $(VERSION)) depmod $$sysmap_opt -q -a -b $(TREE)/ $(VERSION); \
		fi; \
		[ -z "$$sysmap_name" ] || mv $$sysmap_name $(TEMP);)

	# These files depmod makes are used by udev.
	find $(TREE)/lib/modules/ -maxdepth 2 -name 'modules*.bin' \
		-not -name 'modules.builtin.bin' \
		-not -type d | while read f; do rm -f $${f%.bin}; done

	# These files are used to build special kernel images for some
	# subarchitectures. Move them out of the way.
	$(foreach VERSION,$(KERNELVERSION), \
		if [ -d $(TREE)/usr/lib/kernel-image-$(VERSION) ]; then \
			mv $(TREE)/usr/lib/kernel-image-$(VERSION) \
				$(TEMP)/lib; \
		fi; \
		if [ -d $(TREE)/usr/lib/linux-image-$(VERSION) ]; then \
			mv $(TREE)/usr/lib/linux-image-$(VERSION) \
				$(TEMP)/lib; \
		fi;)
endif
endif

ifdef KERNELNAME
	# Move the kernel image out of the way.
	$(foreach name,$(KERNELNAME), \
		mv -f $(TREE)/boot/$(name) $(TEMP)/$(name);)
	test -e $(TREE)/boot/zfs || rmdir $(TREE)/boot/
endif

ifdef PRESEED
	# Copy in preseed file.
	cp -a $(PRESEED) $(TREE)/preseed.cfg
endif

ifndef OMIT_LSB
	# Create an lsb release file.
	if [ ! -e $(TREE)/etc/lsb-release ]; then \
		set -e; \
		mkdir -p $(TREE)/etc; \
		echo 'DISTRIB_ID=$(LSB_DISTRIB_ID)' > $(TREE)/etc/lsb-release; \
		echo 'DISTRIB_DESCRIPTION=$(LSB_DISTRIB_DESCRIPTION)' >> $(TREE)/etc/lsb-release; \
		echo 'DISTRIB_RELEASE=$(LSB_DISTRIB_RELEASE)' >> $(TREE)/etc/lsb-release; \
		echo 'X_INSTALLATION_MEDIUM=$(MEDIUM)' >> $(TREE)/etc/lsb-release; \
	fi
endif

	@touch $@


$(STAMPS)tree-$(targetstring)-stamp: $(STAMPS)tree-unpack-$(targetstring)-stamp
ifndef OMIT_RELEASE_INFO
	# Add release info
	mkdir -p $(TREE)/etc/
	echo $(DEBIAN_RELEASE) >$(TREE)/etc/default-release
	echo $(USE_UDEBS_FROM) >$(TREE)/etc/udebs-source
endif

	# Create a dev tree.
	mkdir -p $(TREE)/dev
ifneq ($(DEB_HOST_ARCH_OS),hurd)
	# Always needed, in case udev is not mounted on boot.
	mknod $(TREE)/dev/console c 5 1
	mknod $(TREE)/dev/null c 1 3
endif

	mkdir -p $(EXTRAUDEBSDIR)
	mkdir -p $(EXTRAUDEBSDPKGDIR)/info $(EXTRAUDEBSDPKGDIR)/updates
	touch $(EXTRAUDEBSDPKGDIR)/status $(EXTRAUDEBSDPKGDIR)/available

ifdef EXTRADRIVERS
	# Unpack the udebs of additional driver disks, so mklibs runs on them too.
	dpkg $(DPKG_UNPACK_OPTIONS) --log=/dev/null --root=$(EXTRAUDEBSDIR) --unpack \
		$(wildcard $(foreach dir,$(EXTRADRIVERS),$(dir)/*.udeb))
endif
ifdef EXTRAUDEBS
	# Get and unpack extra udebs too.
	get-packages udeb $(EXTRAUDEBS)
	dpkg $(DPKG_UNPACK_OPTIONS) --log=/dev/null --root=$(EXTRAUDEBSDIR) --unpack \
		$(foreach udeb,$(EXTRAUDEBS),$(UDEBDIR)/$(udeb).udeb)
endif

	# Library reduction. Existing libs from udebs are put in the udeblibs
	# directory and mklibs is made to use those in preference to the
	# system libs.
	rm -rf $(TEMP)/udeblibs
ifndef ONLY_KLIBC
	mkdir -p $(TEMP)/udeblibs
	find $(EXTRAUDEBSDIR)/lib \( -name '*.so.*' -o -name '*.so' \) -print0 | \
		xargs -0r cp -a -t $(TEMP)/udeblibs
	find $(TREE)/lib \( -name '*.so.*' -o -name '*.so' \) -print0 | \
		xargs -0r cp -a -t $(TEMP)/udeblibs
	mkdir -p $(TREE)/lib
	# HACK ALERT: X.Org modules are excluded from the scan as mklibs
	# is unable to find symbols provided by the /usr/bin/Xorg binary
	$(MKLIBS) -L $(TREE)/usr/lib -L $(TREE)/usr/lib/$(DEB_HOST_MULTIARCH) \
		-L $(TEMP)/udeblibs -v -d $(TREE)/lib --root=$(TREE) \
		-L $(TREE)/usr/lib/cdebconf/frontend \
		$(addprefix -l,$(notdir $(wildcard $(TREE)/usr/lib/cdebconf/frontend/*.so))) \
		`find $(TEMP) -type f -a \( -perm /0111 -o -name '*.so' -o -name '*.so.*' \) | \
		 grep -v udeblibs | grep -v 'usr/lib/xorg/modules/.*\.so'`

ifeq ($(DEB_HOST_ARCH_OS),hurd)
	# On Hurd the SONAME for the dynamic linker is ld.so.1, but binaries
	# have the ld.so symlink as the interpreter. Ideally mklibs should
	# be copying it along with the libraries.
	ln -sf ld.so.1 $(TREE)/lib/ld.so

	# We need /servers/exec and startup at boot time
	touch $(TREE)/servers/exec
	touch $(TREE)/servers/startup
endif
endif

	# Add missing symlinks for libraries
	ldconfig -n $(TREE)/lib $(TREE)/usr/lib

	# Remove any libraries that are present in both usr/lib and lib,
	# from lib. These were unnecessarily copied in by mklibs, and
	# we want to use the ones in usr/lib instead since they came 
	# from udebs. Only libdebconfclient0 has this problem so far.
	set -e; \
	for lib in `find $(TREE)/usr/lib/ -name "lib*" -type f -printf "%f\n" | cut -d . -f 1 | sort | uniq`; do \
		rm -f $(TREE)/lib/$$lib.*; \
	done

	# Reduce status file to contain only the elements we care about.
	egrep -i '^((Status|Provides|Depends|Package|Version|Description|installer-menu-item|Description-..):|$$)' \
		$(DPKGDIR)/status > $(DPKGDIR)/status.new
	mv $(DPKGDIR)/status.new $(DPKGDIR)/status

	# Add a dummy entry for the debian installer itself to the status
	# file, giving the overall version of this build.
	echo "Package: debian-installer" >> $(DPKGDIR)/status
	echo "Status: install ok installed" >> $(DPKGDIR)/status
	echo "Version: $(subst _,-,$(targetstring))-$(BUILD_DATE)" >> $(DPKGDIR)/status
	echo "Description: debian installation image" >> $(DPKGDIR)/status
	echo >> $(DPKGDIR)/status

ifeq ($(DEB_HOST_ARCH_OS),hurd)
        # There is a dependency loop which prevents d-i from being able to
        # configure these.  Since there is actually nothing to do to configure
        # them, they can as well be just marked installed already.
	sed -i -e '/Package: hurd-libs/,+1s/install ok unpacked/install ok installed/' $(DPKGDIR)/status
	sed -i -e '/Package: libparted/,+1s/install ok unpacked/install ok installed/' $(DPKGDIR)/status
endif

ifdef OMIT_DPKG
	rm -rf $(DPKGDIR)
endif

ifndef KEEP_GI_LANGS
	# It makes no sense to include languages only supported by the
	# graphical installer in regular images. This will also ensure
	# their glyphs don't get included a bit lower down.
	$(call drop_lang,$(GI_LANGS))
endif

ifdef DROP_LANG
	# Remove selected languages from the templates.
	# Not ideal, but useful if you're very tight on space.
	$(call drop_lang,$(DROP_LANG))
endif

	# Collect the used UTF-8 strings, to know which glyphs to include in
	# the font.
	cat needed-characters/*.utf > $(TEMP)/all.utf
	if [ -n "`find $(EXTRAUDEBSDPKGDIR)/info/ -name \\*.templates`" ]; then \
		cat $(EXTRAUDEBSDPKGDIR)/info/*.templates >> $(TEMP)/all.utf; \
	fi
	if [ -n "`find $(DPKGDIR)/info/ -name \\*.templates`" ]; then \
		cat $(DPKGDIR)/info/*.templates >> $(TEMP)/all.utf; \
	fi
	if [ -f $(TREE)/usr/share/localechooser/languagelist.data.gz ]; then \
		zcat $(TREE)/usr/share/localechooser/languagelist.data.gz >> $(TEMP)/all.utf; \
	fi

	# Keep the original rendering for the graphical installer, reverting
	# changes in defaults for fontconfig and freetype, until they have
	# been further discussed/analysed, see #873462:
	if [ -L "$(TREE)/etc/fonts/conf.d/10-hinting-slight.conf" ]; then \
		ln -sf /usr/share/fontconfig/conf.avail/10-hinting-full.conf \
			"$(TREE)/etc/fonts/conf.d/10-hinting-slight.conf"; \
		echo 'export FREETYPE_PROPERTIES="truetype:interpreter-version=35"' \
			> "$(TREE)/lib/debian-installer.d/S63freetype-workaround"; \
	fi

	# Run fc-cache if needed, to avoid having to generate UUIDs
	# at runtime, which can be hard because of missing entropy
	# (#898468). Beware, fc-cache insists on having a directory
	# under /usr/local:
	if [ -e "$(TREE)/etc/fonts" ] || [ -e "$(TREE)/usr/share/fonts" ]; then \
		mkdir -p "$(TREE)/usr/local/share/fonts"; \
		fc-cache -s -y "$(TREE)"; \
	fi

	# Remove some unnecessary dpkg files.
	set -e; \
	for file in `find $(TREE)/var/lib/dpkg/info -name '*.md5sums' -o \
	    -name '*.postrm' -o -name '*.prerm' -o -name '*.preinst' -o \
	    -name '*.list' | sort`; do \
		if echo $$file | grep -qv '\.list'; then \
			echo "** Removing unnecessary control file $$file"; \
		fi; \
		rm $$file; \
	done
	rm -rf $(TREE)/var/lib/dpkg/triggers

	# Remove extra udebs now that we're done with them.
	rm -rf $(EXTRAUDEBSDIR)

	# Clamp timestamps to be no later than SOURCE_DATE_EPOCH and normalise
	# file modes before they get added to media.
	$(clamp_mtimes) $(TREE)
	$(normalise_permissions) $(TREE)

	# Tree target ends here. Whew!
	@touch $@

# Get the list of udebs to install.
# HACK Alert: pkg-lists/ is still sorted by TYPE instead of a dir hierarchy.
UDEBS = $(shell set -e; get-packages udeb update >&2; pkg-list $(TYPE) "$(DRIVER_FOR)" $(KERNEL_FLAVOUR) $(KERNELMAJOR) "$(SUBARCH)" $(KERNELVERSION)) $(EXTRAS)

# Get all required udebs and put them in UDEBDIR.
$(STAMPS)get_udebs-$(targetstring)-stamp: sources.list.udeb
	dh_testroot
	@rm -f $@

	get-packages udeb $(UDEBS)
	@touch $@

# Auto-generate sources.list.udeb
sources.list.udeb:
	@(set -e; \
	echo "# This file is automatically generated, edit $@.local instead."; \
	echo "deb [trusted=yes] copy:$(shell pwd)/ $(LOCALUDEBDIR)/"; \
	if [ "$(MIRROR)x" != "x" ]; then \
		echo "deb $(MIRROR) $(USE_UDEBS_FROM) $(UDEB_COMPONENTS)"; \
		if [ "$(USE_UNRELEASED)" = 1 ]; then \
			echo "deb $(MIRROR) unreleased $(UDEB_COMPONENTS)"; \
		fi \
	else \
		gen-sources.list.udeb "$(SYSTEM_SOURCES_LIST)" $(USE_UDEBS_FROM) $(UDEB_COMPONENTS) $(USE_PROPOSED_UPDATES); \
		if [ "$(USE_UNRELEASED)" = 1 ]; then \
			gen-sources.list.udeb "$(SYSTEM_SOURCES_LIST)" unreleased $(UDEB_COMPONENTS); \
		fi \
	fi) > $@
	@if [ -e $@.local ]; then \
		echo "Using $@.local:"; \
		sed -n "/^[^#]/ s/^/   /p" $@.local; \
	else \
		echo "Using generated $@:"; \
		sed -n "/^[^#]/ s/^/   /p" $@; \
	fi
	@if [ "$(USE_PROPOSED_UPDATES)" = 1 ] && ! grep -q proposed-updates $@; then \
		echo "ERROR: no valid source for $(USE_UDEBS_FROM)-proposed-updates"; \
		exit 1; \
	fi

# Font generation.
#
# Use the UTF-8 locale in installation-locale. This target shouldn't
# be called when it is not present anyway.
# The locale must be generated after installing the package locales
$(TEMP)/unifont.bdf: $(TEMP)/all.utf
	@set -e; \
	CHARMAP=`LOCPATH=$(LOCALE_PATH) LC_ALL=C.UTF-8 locale charmap`; \
            if [ UTF-8 != "$$CHARMAP" ]; then \
	        echo "error: Trying to build unifont.bgf without installation-locale!"; \
		echo "(Alternatively, installation-locale may have been built against"; \
		echo "a version of glibc with a different locale data format.)"; \
	        exit 1; \
	    fi
	LOCPATH=$(LOCALE_PATH) LC_ALL=C.UTF-8 reduce-font /usr/src/unifont.bdf < $(TEMP)/all.utf > $@.tmp
	mv $@.tmp $@

$(TREE)/lib/unifont.bgf: $(TEMP)/unifont.bdf
	bdftobogl -b $< > $@.tmp
	mv $@.tmp $@

# The Hurd console uses BDF fonts instead
$(TREE)/lib/unifont.bdf: $(TEMP)/unifont.bdf
	mkdir -p $(dir $@)
	cp $< $@.tmp
	mv $@.tmp $@

# Create a compressed image of the root filesystem.
$(TEMP_INITRD): $(STAMPS)tree-$(targetstring)-stamp arch_tree
ifneq ($(DEB_HOST_ARCH_OS),hurd)
	# Check for lost file attributes
	@if [ -e $(TREE)/dev/console ] && \
	    ! ls -l $(TREE)/dev/console | grep -q "^c"; then \
		echo "Error: incorrect file attributes detected in initrd tree."; \
		echo "Did you restart a (failed) fakeroot build?"; \
		echo "See fakeroot(1) ('-s' and '-i' options) for additional information."; \
		exit 1; \
	fi
endif

	# Only build the font if we have installation-locale
ifeq ($(DEB_HOST_ARCH_OS),linux)
	if [ -d "$(LOCALE_PATH)/C.UTF-8" ] && [ -e /usr/src/unifont.bdf ]; then \
		$(submake) $(TREE)/lib/unifont.bgf; \
	fi
endif
ifeq ($(DEB_HOST_ARCH_OS),hurd)
	# The hurd console uses a BDF font
	if [ -d "$(LOCALE_PATH)/C.UTF-8" ] && [ -e /usr/src/unifont.bdf ]; then \
		$(submake) $(TREE)/lib/unifont.bdf; \
	fi
endif

	# We may have modified $(TREE)/lib, so re-clamp and normalise before
	# placing these files into archives.
	$(clamp_mtimes) $(TREE)/lib
	$(normalise_permissions) $(TREE)/lib

	install -d $(TEMP)

	set -e; \
	case $(INITRD_FS) in \
	ext2) \
		$(genext2fs) $(TEMP)/initrd; \
		$(e2fsck) $(TEMP)/initrd || true; \
		$(gzip) -v9f $(TEMP)/initrd; \
	;; \
	initramfs) \
		$(mkinitramfs) $(TEMP)/initrd; \
		$(gzip) -v9f $(TEMP)/initrd; \
	;; \
	jffs2) \
		$(mkjffs2) $(TEMP_INITRD); \
	;; \
	ufs1) \
		$(mkfs.ufs1) $(TEMP)/initrd; \
		$(gzip) -v9f $(TEMP)/initrd; \
	;; \
	*) \
		echo "Unsupported filesystem type"; \
		exit 1 ;; \
	esac

# Create the images for dest/. Those are the targets called from config.

ifeq ($(SYMLINK_INITRD),)
$(INITRD): $(TEMP_INITRD)
	install -m 644 -D $< $@
	update-manifest $@ $(MANIFEST-INITRD) $(UDEB_LISTS)
else
$(INITRD): $(realpath $(dir $(INITRD))/$(SYMLINK_INITRD))
	mkdir -p $(dir $(INITRD))
	ln -s $(SYMLINK_INITRD) $@
	update-manifest $@ $(MANIFEST-INITRD) $(UDEB_LISTS)
endif

$(RAMDISK): $(TEMP_INITRD)
	install -m 644 -D $< $@
	update-manifest $@ $(MANIFEST-RAMDISK) $(UDEB_LISTS)

# raw kernel images
ifeq ($(SYMLINK_KERNEL),)
$(KERNEL): TEMP_REAL_KERNEL = $(TEMP)/$(shell echo ./$@ |sed 's,$(SOME_DEST)/$(EXTRANAME),,')
$(KERNEL):
	@$(MAKE) $(STAMPS)tree-unpack-$(targetstring)-stamp $(TEMP_REAL_KERNEL)
	install -m 644 -D $(TEMP_REAL_KERNEL) $@
	update-manifest $@ $(MANIFEST-KERNEL)
else
$(KERNEL): $(realpath $(dir $(KERNEL))/$(SYMLINK_KERNEL))
	mkdir -p $(dir $(KERNEL))
	ln -s $(SYMLINK_KERNEL) $@
	update-manifest $@ $(MANIFEST-KERNEL)
endif

$(DTBS): $(TEMP_KERNEL)
	mkdir -p $(SOME_DEST)/$(EXTRANAME)
	set -ex ; for dtb in $$(find $(TEMP_DTBS)/ -name *.dtb) ; do \
		dir=$(SOME_DEST)/$(EXTRANAME)$$(dirname $${dtb#$(TEMP_DTBS)/}); \
		tgt=$$dir/$$(basename $$dtb); \
		mkdir -p $$dir ; \
		cp $$dtb $$tgt ; \
		update-manifest $$tgt "Device Tree Blob: $$(basename $$dtb)";\
	done
	cp boot/README.device-tree $@
	update-manifest $@ "Device Tree Blobs README"

# bootable images
$(BOOT): $(TEMP_BOOT)
	install -m 644 -D $(TEMP_BOOT)$(GZIPPED) $@
	update-manifest $@ $(MANIFEST-BOOT) $(UDEB_LISTS)

$(TEMP_KERNEL): $(STAMPS)tree-unpack-$(targetstring)-stamp

$(TEMP_BOOT): $(TEMP_INITRD) $(TEMP_KERNEL) $(TEMP_BOOT_SCREENS) arch_boot

# non-bootable root images
$(ROOT): $(TEMP_ROOT)
	install -m 644 -D $(TEMP_ROOT)$(GZIPPED) $@
	update-manifest $@ $(MANIFEST-ROOT) $(UDEB_LISTS)

$(TEMP_ROOT): $(TEMP_INITRD) arch_root

# miniature ISOs with only a boot image
$(MINIISO): $(TEMP_MINIISO)
	install -m 644 -D $(TEMP_MINIISO) $@
	update-manifest $@ $(MANIFEST-MINIISO) $(UDEB_LISTS)

$(TEMP_MINIISO): $(TEMP_BOOT_SCREENS) arch_miniiso

# various kinds of information, for use on debian-cd isos
$(DEBIAN_CD_INFO): $(TEMP_BOOT_SCREENS) $(TEMP_CD_INFO_DIR)
	gen-tarball $(TEMP_CD_INFO_DIR) $@
	update-manifest $@ $(MANIFEST-DEBIAN_CD_INFO)

# a directory full of files for netbooting
$(NETBOOT_DIR): $(NETBOOT_DIR_TARGETS) $(TEMP_BOOT_SCREENS) $(TEMP_NETBOOT_DIR)
	rm -rf $(SOME_DEST)/$(EXTRANAME)/$(NETBOOT_DI_DIR)
	mkdir -p $(SOME_DEST)/$(EXTRANAME)/$(NETBOOT_DI_DIR)
	cp -a $(TEMP_NETBOOT_DIR)/$(NETBOOT_DI_DIR)/* $@
	$(foreach link,$(NETBOOT_DIR_LINKS), \
		rm -f $@/../$(link); \
		cp -a $(TEMP_NETBOOT_DIR)/$(link) $@/..; \
	)
	update-manifest $@ $(MANIFEST-NETBOOT_DIR) $(UDEB_LISTS)

# a tarball for netbooting
$(NETBOOT_TAR): $(TEMP_NETBOOT_DIR)
	# Create an version info file.
	echo 'Debian version:  $(DEBIAN_VERSION)' > $(TEMP_NETBOOT_DIR)/version.info
	echo 'Installer build: $(BUILD_DATE)' >> $(TEMP_NETBOOT_DIR)/version.info
	gen-tarball $(TEMP_NETBOOT_DIR) $@
	update-manifest $@ $(MANIFEST-NETBOOT_TAR) $(UDEB_LISTS)

$(TEMP_BOOT_SCREENS): arch_boot_screens
$(TEMP_CD_INFO_DIR): arch_cd_info_dir
$(TEMP_NETBOOT_DIR): arch_netboot_dir

$(MISC): TEMP_REAL_MISC = $(shell echo ./$@ |sed 's,$(SOME_DEST)/$(EXTRANAME),,')
$(MISC): 
	install -m 644 $(TEMP_REAL_MISC) $(SOME_DEST)/$(EXTRANAME)
	update-manifest \
		$(SOME_DEST)/$(EXTRANAME)$(shell basename $(TEMP_REAL_MISC)) \
		$(MANIFEST-MISC)

# Other images, e.g. driver floppies. Those are simply handled as flavours
$(EXTRA): $(TEMP_EXTRA)
	install -m 644 -D $(TEMP_EXTRA)$(GZIPPED) $@
	update-manifest $@ $(MANIFEST-EXTRA) $(UDEB_LISTS)

$(TEMP_EXTRA): $(STAMPS)extra-$(targetstring)-stamp
	install -d $(shell dirname $@)
	install -d $(TREE)
	set -e; case $(INITRD_FS) in \
	ext2) \
		genext2fs -d $(TREE) -b $(IMAGE_SIZE) -m 0 $@ ; \
		$(e2fsck) $@ || true ;; \
	*) \
		echo "Unsupported filesystem type"; \
		exit 1 ;; \
	esac
	$(if $(GZIPPED),$(gzip) -v9f $(TEMP_EXTRA))

$(STAMPS)extra-$(targetstring)-stamp: $(STAMPS)get_udebs-$(targetstring)-stamp
	@rm -f $@
	mkdir -p $(TREE)
	echo -n > $(TEMP)/diskusage.txt
	echo -n > $(TEMP_UDEB_LIST)

	set -e; \
	for file in $(UDEBS); do \
		cp $(UDEBDIR)/$$file* $(TREE) ; \
	done
	for udeb in $(TREE)/*.udeb ; do \
		if [ -f "$$udeb" ]; then \
			pkg=`basename $$udeb .udeb` ; \
			usedsize=`du -bs $$udeb | awk '{print $$1}'` ; \
			usedblocks=`du -s $$udeb | awk '{print $$1}'` ; \
			usedcount=1 ; \
			version=`dpkg-deb --info $$udeb | grep '^ *Version:' | awk '{print $$2}'` ; \
			arch=`dpkg-deb --info $$udeb | grep '^ *Architecture:' | awk '{print $$2}'` ; \
			echo " $$usedsize B - $$usedblocks blocks - $$usedcount files used by pkg $$pkg (version $$version)" >>$(TEMP)/diskusage.txt; \
			echo "$$pkg $$version $$arch" >> $(TEMP_UDEB_LIST); \
		fi; \
	done
	sort -n < $(TEMP)/diskusage.txt > $(TEMP)/diskusage.txt.new && \
		mv $(TEMP)/diskusage.txt.new $(TEMP)/diskusage.txt
	echo $(UDEBS) > $(TREE)/udeb_include
	makelabel $(DISK_LABEL) $(BUILD_DATE) > $(TREE)/disk.lbl
	@touch $@

# Get a list of all the standard priority udebs, excluding kernel stuff.
pkg-lists/standard-udebs:
	get-packages udeb update
	grep-dctrl -sPackage -FPriority -e 'required|standard|important' \
		$(if $(SUBARCH),-a \( -! -FSubarchitecture -r . -o -FSubarchitecture -e '(^| )$(SUBARCH)( |$$)' \)) \
		apt.udeb/state/lists/*_Packages* | \
		grep -v kernel-image | grep -v -- -modules | \
		cut -d " " -f 2 > $@

# Get a list of all kernel modules matching the kernel version.
pkg-lists/kernel-module-udebs:
	get-packages udeb update
	> $@
	$(foreach VERSION,$(KERNELVERSION), \
		grep-dctrl -P -e '.*-modules-$(VERSION)-$(KERNEL_FLAVOUR)' \
			-sPackage apt.udeb/state/lists/*_Packages* | \
			cut -d " " -f 2 >> $@;)

# The kernel version changes from build to build, so always regen the file.
.PHONY: pkg-lists/kernel-module-udebs

# Write (floppy) images
.PHONY: write_%
write_%:
	@install -d $(STAMPS)
	@$(submake) _write $(shell $(submake) $(subst write_,validate_,$@))

.PHONY: _write
_write: _build
	sudo dd if=$(TARGET) of=$(FLOPPYDEV) bs=$(FLOPPY_SIZE)k

# If you're paranoid (or things are mysteriously breaking..),
# you can check the floppy to make sure it wrote properly.
.PHONY: checkedwrite_%
checkedwrite_%:
	@install -d $(STAMPS)
	@$(submake) _checkedwrite $(shell $(submake) $(subst checkedwrite_,validate_,$@))

.PHONY: _checkedwrite
_checkedwrite: _write
	sudo cmp $(FLOPPYDEV) $(TARGET)


# Generate statistics for all previously built images.
.PHONY: stats
stats:
	@echo "Image size stats"
	@echo
	$(submake) all_stats

# For manual invocation we provide a generic stats rule.
.PHONY: stats_%
stats_%:
	@$(submake) _stats $(shell $(submake) $(subst stats_,validate_,$@))

.PHONY: _stats
_stats: 
	@[ ! -f $(TEMP)/diskusage.txt ] || $(submake) general-stats

TOTAL_SZ = $(shell expr $(shell du -bs $(TREE) | cut -f 1) / 1024)
LIBS_SZ = $(shell [ -d $(TREE)/lib ] && du -hs --exclude=modules $(TREE)/lib |cut -f 1)
MODULES_SZ = $(shell [ -d $(TREE)/lib/modules ] && du -hs $(TREE)/lib/modules |cut -f 1)
ifeq ($(TEMP_INITRD),)
INITRD_SZ = 0
else
INITRD_SZ = $(shell expr \( $(shell [ -f $(TEMP_INITRD) ] && du -bs $(TEMP_INITRD) |cut -f 1) + 0 \) / 1024)
endif
ifeq ($(TEMP_KERNEL),)
KERNEL_SZ = 0
else
KERNEL_SZ = $(shell expr \( $(foreach kern,$(TEMP_KERNEL),$(shell [ -f $(kern) ] && du -bs $(kern) |cut -f 1)) + 0 \) / 1024)
endif
ifeq ($(TARGET),$(ROOT))
# image without a kernel
KERNEL_SZ = 0
endif
.PHONY: general-stats
general-stats:
	@echo "System stats for $(targetstring)"
	@echo "-------------------------"
	@printf "Total system size: $(TOTAL_SZ)k"
ifneq ($(LIBS_SZ)$(MODULES_SZ),)
	@echo " ($(LIBS_SZ) libs, $(MODULES_SZ) kernel modules)"
else
	@echo
endif
	@echo "Initrd size: $(INITRD_SZ)k"
	@echo "Kernel size: $(KERNEL_SZ)k"
ifdef FLOPPY_SIZE
ifneq ($(INITRD_SZ),0)
	@echo "Free space: $(shell expr $(FLOPPY_SIZE) - $(KERNEL_SZ) - $(INITRD_SZ))k"
else
	@echo "Free space: $(shell expr $(FLOPPY_SIZE) - $(KERNEL_SZ) - $(TOTAL_SZ))k"
endif
endif
	@echo "Disk usage per package:"
	@sed 's/^/  /' < $(TEMP)/diskusage.txt

.PHONY: tree_mount
tree_mount: $(STAMPS)tree-$(targetstring)-stamp
	-@sudo /bin/mount -t proc proc $(TREE)/proc
	-@if [ -e $(TREE)/usr/bin/update-dev ]; then \
		sudo chroot $(TREE) /usr/bin/update-dev; \
	elif [ ! -d $(TREE)/etc/udev ]; then \
		sudo /bin/mount -t devfs dev $(TREE)/dev; \
	fi

.PHONY: tree_umount
tree_umount:
	-@[ ! -L $(TREE)/proc/self ] || sudo /bin/umount $(TREE)/proc

# For manual invocation, we provide a demo rule. This starts the
# d-i demo from the tree in tmp.
.PHONY: demo_%
demo_%:
	@set -e; \
	export SUBARCH=; \
	export FLAVOUR=; \
	export MEDIUM=$(subst demo_,,$@); \
	$(submake) _demo

.PHONY: _demo
_demo: $(TARGET)
	@$(submake) tree_mount; \
	[ -f questions.dat ] && cp -f questions.dat $(TREE)/var/lib/cdebconf/ ; \
	: >$(TREE)/var/lib/UTF-8 ; \
	sudo chroot $(TREE) bin/sh -c "export DEBCONF_DEBUG=5; export LANG=C.UTF-8; export TERM_UTF8=yes; /usr/bin/debconf-loadtemplate debian /var/lib/dpkg/info/*.templates; exec /usr/share/debconf/frontend /usr/bin/main-menu" ; \
	rm -f $(TREE)/var/lib/UTF-8 ; \
	$(submake) tree_umount

# For a shell into a d-i chroot.
.PHONY: shell_%
shell_%:
	@export SUBARCH=; \
	export FLAVOUR=; \
	export MEDIUM=$(subst shell_,,$@); \
	$(submake) _shell

.PHONY: _shell
_shell: $(TREE)
	@$(submake) tree_mount; \
	sudo chroot $(TREE) bin/sh; \
	$(submake) tree_umount

# For running a d-i image in UML.
.PHONY: uml_%
uml_%:
	@set -e; \
	export SUBARCH=; \
	export FLAVOUR=; \
	export MEDIUM=$(subst uml_,,$@); \
	$(submake) _uml

.PHONY: _uml
_uml: $(TARGET)
	-linux initrd=$(INITRD) root=/dev/rd/0 ramdisk_size=8192 con=fd:0,fd:1 devfs=mount

# For running a d-i image in qemu.
.PHONY: qemu_%
qemu_%:
	@set -e; \
	export SUBARCH=; \
	export FLAVOUR=; \
	export MEDIUM=$(subst qemu_,,$@); \
	$(submake) _qemu $(shell $(submake) $(subst qemu_,validate_,$@))

.PHONY: _qemu
_qemu: $(TARGET)
	@case "$(MEDIA_TYPE)" in \
	floppy) \
		$(QEMU) -fda $(BOOT); \
	;; \
	CD-ROM) \
		$(QEMU) -cdrom $(BOOT); \
	;; \
	*) \
		echo "Sorry, don't know how to handle media type '$(MEDIA_TYPE)'" >&2; \
		exit 1; \
	esac

# For running a d-i image in a subhurd
.PHONY: subhurd_%
subhurd_%:
	@set -e; \
	export SUBARCH=; \
	export FLAVOUR=; \
	export MEDIUM=$(subst subhurd_,,$@); \
	$(submake) _subhurd

.PHONY: _subhurd
_subhurd: $(TEMP_INITRD)
	settrans -cfga $(BASE_TMP)/rd0 /hurd/storeio -r -T file initrd.gz
	-boot -I -f rd0=$(BASE_TMP)/rd0 -c "TERM=vt100 root=gunzip:device:rd0" /boot/servers.boot $(BASE_TMP)/rd0

