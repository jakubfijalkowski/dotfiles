"Stock"       "root=PARTUUID=$PARTUUID rw add_efi_memmap i915.enable_fbc=1 i915.enable_psr=1 i915.disable_power_well=0 i915.enable_guc=2 acpi_rev_override=5 scsi_mod.use_blk_mq=y pci=noaer pcie_aspm=force nmi_watchdog=0 nvme_core.default_ps_max_latency_us=180000 quiet initrd=/intel-ucode.img initrd=/initramfs-linux-zen.img"
"Stock - min" "root=PARTUUID=$PARTUUID rw add_efi_memmap acpi_rev_override=1"
"Fall"        "root=PARTUUID=$PARTUUID rw add_efi_memmap initrd=/initramfs-linux-fallback.img"
"Min"         "root=PARTUUID=$PARTUUID rw add_efi_memmap systemd.unit=multi-user.target"
