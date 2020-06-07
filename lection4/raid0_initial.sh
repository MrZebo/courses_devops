#!bin/bash
sudo -S yum install mdadm -y
sleep 5
sudo -S mdadm --create --verbose /dev/md0 --level=0 --raid-device=3 /dev/xvdb /dev/xvdc /dev/xvdd
sudo mkfs.ext4 -F /dev/md0
sudo -S mount -t ext4 /dev/md0 /mnt
