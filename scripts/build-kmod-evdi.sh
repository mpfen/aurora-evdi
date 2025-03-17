#!/bin/bash

# source: https://github.com/ublue-os/akmods/blob/main/build_files/extra/build-kmod-evdi.sh

set -eoux pipefail

ARCH="$(rpm -E '%_arch')"
KERNEL="$(rpm -q "kernel" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
RELEASE="$(rpm -E '%fedora')"

rm /etc/yum.repos.d/negativo17-fedora-multimedia.repo
dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo

set -e pipefail

### BUILD evdi (succeed or fail-fast with debug output)
export CFLAGS="-fno-pie -no-pie"
dnf install -y \
  kmod-evdi*.fc"${RELEASE}.${ARCH}" akmod-evdi-*.fc"${RELEASE}.${ARCH}"
akmods --force --kernels "${KERNEL}" --kmod evdi
modinfo /usr/lib/modules/"${KERNEL}"/extra/evdi/evdi.ko.xz >/dev/null ||
  (find /var/cache/akmods/evdi/ -name \*.log -print -exec cat {} \; && exit 1)

rm -f /etc/yum.repos.d/negativo17-fedora-multimedia.repo
unset CFLAGS