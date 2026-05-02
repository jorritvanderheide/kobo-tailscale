#!/bin/sh

set -e

# Set what version of tailscale you would like to install here.
# You can find the latest version at https://pkgs.tailscale.com/stable/#static
export TAILSCALE_VERSION=1.96.4

echo
echo "Installing tailscale ${TAILSCALE_VERSION}!"
uname -a
echo

echo "Installing iptables into /sbin and /lib ..."
cp binaries/iptables/sbin/* /sbin
cp binaries/iptables/lib/* /lib

ln -sf /sbin/xtables-multi /sbin/iptables
ln -sf /lib/libxtables.so.10.0.0 /lib/libxtables.so.10
ln -sf /lib/libip4tc.so.0.1.0 /lib/libip4tc.so.0
ln -sf /lib/libip6tc.so.0.1.0 /lib/libip6tc.so.0

echo "Downloading tailscale_${TAILSCALE_VERSION}_arm.tgz from pkgs.tailscale.com ..."
wget https://pkgs.tailscale.com/stable/tailscale_${TAILSCALE_VERSION}_arm.tgz
wget -O tailscale_${TAILSCALE_VERSION}_arm.tgz.sha256 https://pkgs.tailscale.com/stable/tailscale_${TAILSCALE_VERSION}_arm.tgz.sha256

echo "Verifying tarball checksum ..."
expected_sha=$(cat tailscale_${TAILSCALE_VERSION}_arm.tgz.sha256)
actual_sha=$(sha256sum tailscale_${TAILSCALE_VERSION}_arm.tgz | awk '{print $1}')
if [ "$expected_sha" != "$actual_sha" ]; then
  echo "SHA256 mismatch! expected=$expected_sha actual=$actual_sha"
  rm -f tailscale_${TAILSCALE_VERSION}_arm.tgz tailscale_${TAILSCALE_VERSION}_arm.tgz.sha256
  exit 1
fi

tar -xvf tailscale_${TAILSCALE_VERSION}_arm.tgz

echo "Installing tailscale binaries into /mnt/onboard/tailscale and symlinking them into /usr/bin ..."
mkdir -p /mnt/onboard/tailscale
mv tailscale_${TAILSCALE_VERSION}_arm/tailscale /mnt/onboard/tailscale
mv tailscale_${TAILSCALE_VERSION}_arm/tailscaled /mnt/onboard/tailscale

# Symlink tailscale binaries to /usr/bin
ln -sf /mnt/onboard/tailscale/tailscale /usr/bin/tailscale
ln -sf /mnt/onboard/tailscale/tailscaled /usr/bin/tailscaled

echo "Cleaning up tarball ..."
rm -rf tailscale_${TAILSCALE_VERSION}_arm
rm -f tailscale_${TAILSCALE_VERSION}_arm.tgz tailscale_${TAILSCALE_VERSION}_arm.tgz.sha256

echo "Installing tailscale boot and load scripts into /usr/local/tailscale ..."
mkdir -p /usr/local/tailscale
cp scripts/* /usr/local/tailscale

echo "Installing tailscale udev rule into /etc/udev/rules.d ..."
cp rules/* /etc/udev/rules.d

echo
echo "Installation complete! Attempting to boot tailscale daemon ..."
/usr/local/tailscale/boot.sh
echo

echo "If no errors were reported, tailscale should be installed!"
echo "You can now configure tailscale by running 'tailscale up' and following the instructions."
echo "The tailscale binaries are located in /mnt/onboard/tailscale."
echo
