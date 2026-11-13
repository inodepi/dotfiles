# SDDM greeter on this machine

- The greeter must run on Wayland. `kwin-wayland` must be installed, otherwise SDDM silently falls back to `DisplayServer=x11-user`.
- That fallback makes the session VT switch block for 30 s (kernel `VT_TIMEOUT`). sddm-helper then logs `Session started false` and kills the session 60 s later. Upstream: sddm/sddm#2129 (variant #2225).
- Debian's sddm 0.21.0 also needs the VT_AUTO patch for Wayland user sessions (upstream PR #2204). The package is currently `apt-mark hold sddm` against a locally rebuilt version.

## Install greeter config

```bash
sudo install -Dm644 greeter.conf /etc/sddm.conf.d/10-wayland.conf
```

## Rebuild sddm with the VT_AUTO patch

```bash
apt-get source sddm
patch -p1 -d sddm-*/ < patches/0001-vt-auto-for-wayland-user-sessions.patch
cd sddm-* && dpkg-buildpackage -b -us -uc
sudo dpkg -i ../sddm_*.deb
sudo apt-mark hold sddm
```

Verify: `journalctl -b -u sddm | grep -E "falling back|Session started"` — expect no `falling back` and no `Session started false`.
