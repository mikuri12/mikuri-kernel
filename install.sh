#!/bin/sh
# Instalador de mikuri-kernel para Void Linux
# uso: sudo ./install.sh mikuri-kernel-<version>.tar.gz
set -eu

TARBALL="${1:-}"
[ -n "$TARBALL" ] || { echo "uso: sudo ./install.sh mikuri-kernel-<version>.tar.gz"; exit 1; }
[ -f "$TARBALL" ] || { echo "no existe: $TARBALL"; exit 1; }

case "$TARBALL" in
  */mikuri-kernel-*.tar.gz) ;;
  mikuri-kernel-*.tar.gz) ;;
  *) echo "nombre inesperado: $TARBALL (se espera mikuri-kernel-<version>.tar.gz)"; exit 1 ;;
esac
BASE=$(basename "$TARBALL")
KREL="${BASE#mikuri-kernel-}"
KREL="${KREL%.tar.gz}"

if [ "$(id -u)" -ne 0 ]; then
  exec sudo "$0" "$TARBALL"
fi

echo "==> Instalando mikuri-kernel ($KREL)"
tar -xvpzf "$TARBALL" -C / --numeric-owner

echo "==> Generando initramfs (dracut)"
dracut --force "/boot/initramfs-${KREL}.img" "$KREL"

echo "==> Actualizando GRUB"
update-grub

echo
echo "OK. Reinicia y elige '${KREL}' en GRUB."
echo "El kernel anterior queda como respaldo; no lo quites hasta validar el nuevo."
