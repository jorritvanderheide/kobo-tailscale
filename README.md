# kobo-tailscale

Install scripts for getting [Tailscale](https://tailscale.com) running on Kobo e-readers and persisting through reboots.

## Supported devices

- *Kobo Clara BW*
- *Kobo Clara Color*

Both devices share the same userland and kernel TUN support, so a single set of scripts and binaries covers both.

## Installation

> [!NOTE]
> The version of Tailscale to install can be chosen by editing the `TAILSCALE_VERSION` variable in `install-tailscale.sh`. The install script verifies the downloaded tarball's SHA256 against the checksum published on `pkgs.tailscale.com`.

1. Download this repo onto your Kobo e-reader's onboard storage.
2. Run `install-tailscale.sh` from the repo root.
3. Run `tailscale up` and follow the instructions to authenticate your e-reader!

## Uninstallation

Simply run `uninstall-tailscale.sh` from the repo root.

## Bundled iptables

Tailscale requires the `iptables` binary and shared libraries, which are not present in the stock Kobo image. Pre-built binaries are bundled in `binaries/` and were pulled from the [July 5th 2017 build of Raspbian](http://downloads.raspberrypi.org/raspbian/images/raspbian-2017-07-05) (which also bundles the source code) to match the glibc version used in the Clara firmware.

## DNS

Tailscale's MagicDNS is disabled by default in the wlan-up hook (`--accept-dns=false`). When there's no DNS manager
on the system, Tailscale would otherwise [overwrite resolv.conf](https://tailscale.com/kb/1235/resolv-conf/) to point
at a tailnet-side resolver, which on Kobo breaks system DNS in two common ways: stale `resolv.conf` after wifi cycles,
and TLS verification failures against DoH upstreams (e.g. NextDNS) because the Kobo's CA bundle doesn't trust the
required roots. The LAN router's DNS is sufficient since tailnet hostnames published in public DNS still route via
`tailscale0`.

If you want MagicDNS, edit `scripts/on-wlan-up.sh` and remove the `--accept-dns=false` flag.

## Acknowledgements

[Dylan Staley for initial work and scripts on the Kobo Sage](https://dstaley.com/posts/tailscale-on-kobo-sage)

[jmacindoe for documenting kernel module compilation on Kobo readers](https://github.com/jmacindoe/kobo-kernel-modules)

[videah for the install scripts](https://github.com/videah/kobo-tailscale)
