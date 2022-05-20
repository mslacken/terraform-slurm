#!/bin/bash
TMPDIR=/var/tmp
if [ $# -ne 1 ] ; then
  cat << EOF
Usage: ./$0 distribution 
Distributions are:
EOF
  for dist in $(find -type f -name config.xml | sed 's/\.\///') ; do
    echo $(dirname $dist)
  done
  exit 0
fi
DISTRO=$1
kiwicmd="--profile Disk system build"
if [ $DISTRO == "tw" ] ; then 
  kiwicmd="--type oem system build"
fi
if [ $DISTRO == "sles12sp2" ] ; then 
  kiwicmd="--type vmx system build"
fi

sudo rm -rf $TMPDIR/JeOS-${DISTRO}*
mkdir -vp ${TMPDIR}/JeOS-${DISTRO}-$(date  +%Y%m%d)/config
cp -vr assets/* ${TMPDIR}/JeOS-${DISTRO}-$(date  +%Y%m%d)/config
cp -vr ${DISTRO}/* ${TMPDIR}/JeOS-${DISTRO}-$(date  +%Y%m%d)/config
sed -i "s@#LOCAL#@${TMPDIR}/JeOS-${DISTRO}-$(date  +%Y%m%d)/config/local@" ${TMPDIR}/JeOS-${DISTRO}-$(date  +%Y%m%d)/config/config.xml
sudo /usr/bin/kiwi \
  $kiwicmd \
  --description  ${TMPDIR}/JeOS-${DISTRO}-$(date  +%Y%m%d)/config \
  --target-dir $TMPDIR/JeOS-${DISTRO}-$(date  +%Y%m%d)
rm $TMPDIR/${DISTRO}-current
ln -s $TMPDIR/JeOS-${DISTRO}-$(date  +%Y%m%d) /var/tmp/${DISTRO}-current
if [ ! -e assets/root/root/.ssh/authorized_keys ] ; then
  cat << EOF

Yoy might want to add your ssh key to the vm roots with
mkdir -p assets/root/root/.ssh/
cat ~/.ssh/*pub >> assets/root/root/.ssh/authorized_keys
EOF
fi
cat <<EOF

In order to start the kvm cluster, use:
sudo terraform apply -var="image=$(ls /var/tmp/${DISTRO}-current/*qcow2)"
EOF

