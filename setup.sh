#!/bin/sh

ANSWER_FILE_URL=https://raw.githubusercontent.com/sfkd/alpine-setup/master/answer
PUBKEY_URL=https://github.com/sfkd.keys

# execute setup alpine with answer
SWAP_SIZE=0
wget -q -O - ${ANSWER_FILE_URL} | setup-alpine -f -

# mount new environment
mount /dev/sda2 /mnt
mount -t sysfs sysfs /mnt/sys
mount -t devtmpfs devtmpfs /mnt/dev
mount -t proc proc /mnt/proc
mount -t devpts devpts /mnt/dev/pts
mount -t tmpfs shm /mnt/dev/shm
mount -t tmpfs tmpfs /mnt/run
mount -t mqueue mqueue /mnt/dev/mqueue
mount -t securityfs securityfs /mnt/sys/kernel/security
mount -t debugfs debugfs /mnt/sys/kernel/debug
mount -t pstore pstore /mnt/sys/fs/pstore
mount -t tracefs tracefs /mnt/sys/kernel/debug/tracing
mount /dev/sda1 /mnt/boot
mount -t tmpfs tmpfs /mnt/tmp

# exec setup command using new environment
cat << __EOF__ | chroot /mnt /bin/sh
adduser alpine
cd ~alpine
mkdir .ssh
wget -q -O - ${PUBKEY_URL} > .ssh/authorized_keys
chown -R alpine:alpine .ssh
chmod 700 .ssh
chmod 600 .ssh/authorized_keys
apk add --update --no-cache doas
echo 'permit nopass alpine' >> /etc/doas.d/doas.conf
__EOF__
