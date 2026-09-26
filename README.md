# mikuri-kernel

Kernel personalizado para **Intel i3-6100 (Skylake, 2C/4T)** — OptiPlex con chipset Q270, Intel HD 530, ethernet I219-LM, audio Realtek ALC269 (HDA), SSD SATA ext4, **Void Linux**.

Base: **CachyOS linux 7.1.5** (`cachyos-7.1.5-1`) + **BORE Scheduler 6.8.0** (firelzrd) + parche de fusión BORE↔CACHY.

## Contenido

| Archivo | Qué es |
|---|---|
| `config-mikuri` | `.config` final validada (la que compila CI) |
| `config-fragment-mikuri` | Fragmento con las decisiones propias (se fusiona sobre la config base) |
| `prune_families.py` | Podador de familias de drivers no usadas |
| `patches/0001-bore-scheduler.patch` | BORE 6.8.0 upstream (firelzrd, linux-7.1.5) |
| `patches/0002-bore-cachy-merge.patch` | Resuelve el rechazo de 0001 contra el árbol CachyOS + coexistencia con sched_ext |
| `.github/workflows/build.yml` | Compila en GitHub Actions y publica un release |
| `install.sh` | Instalador para Void Linux |

## Decisiones de configuración

- **Scheduler**: BORE + tweaks CachyOS, PREEMPT (full), PREEMPT_DYNAMIC, HZ_1000
- **CPU**: x86-64-v3 (Skylake: AVX2/BMI2/FMA), NR_CPUS=4, sin NUMA, NO_HZ_IDLE
- **Solo drivers del hardware real**: i915, HDA Intel (ALC269 + HDMI), e1000e, AHCI/xHCI, KVM/vfio/vhost (máquinas virtuales)
- **Eliminado**: SND_SOC completo (snd_hda_intel no lo necesita), WiFi/Bluetooth (no hay hardware), drivers de red de otros vendors, DVB/tuners, Xen/HyperV/VMware *guest*, staging, watchdogs, PCMCIA/FireWire/IDE/parport, SELinux/Smack/Tomoyo/AppArmor, casi todo el debug/instrumentación (debugfs, ftrace, kprobes quedan como mínimos no, off)
- **Conservado como módulos** por si acaso: NTFS3, exFAT, UDF, squashfs, overlayfs, BTRFS/XFS/F2FS, NFS/CIFS, USB storage/UAS, UVC (webcam)
- Mitigaciones de CPU: se gestionan por cmdline (`mitigations=off` ya está en GRUB)
- ~2.780 módulos vs ~6.280 del kernel CachyOS genérico (-56 %)

## Instalar (Void Linux)

1. Descarga `mikuri-kernel-7.1.5-mikuri.tar.gz` (y su `.sha256`) del [último release](../../releases)
2. Verifica: `sha256sum -c mikuri-kernel-7.1.5-mikuri.tar.gz.sha256`
3. Corre:

```sh
sudo ./install.sh mikuri-kernel-7.1.5-mikuri.tar.gz
```

que hace: `tar -xvpzf ... -C /` → `dracut --force /boot/initramfs-7.1.5-mikuri.img 7.1.5-mikuri` → `update-grub`

El kernel anterior queda intacto como fallback en GRUB. No desinstales `linux-cachy-void` hasta validar que el nuevo arranca bien.

## Recompilar tras cambiar la config

1. Edita `config-fragment-mikuri` (o directamente `config-mikuri`)
2. Push a `master` — el workflow compila y publica un release nuevo
3. También se puede disparar a mano: Actions → Build mikuri-kernel → Run workflow

## Notas

- Sin paquete de headers: no hay módulos DKMS en el sistema (GPU Intel, sin NVIDIA/ZFS). Si algún día hacen falta, el workflow habría que extenderlo.
- Secure Boot desactivado en la máquina → módulos sin firmar OK.
