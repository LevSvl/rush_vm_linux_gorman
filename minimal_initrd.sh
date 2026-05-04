#!/bin/bash
# minimal_initrd.sh

set -e

# Pass ROOTFS_DIR and INITRD_TARGET_PATH as arguments
if [ -z "$1" ]; then
    echo "Error: you forgot to pass path to rootfs"
    echo "Usage: $0 path/to/rootfs target/path/to/initrd"
    exit 1
fi
ROOTFS_DIR=$1
if [ -z "$2" ]; then
    echo "Error: you forgot to pass path to target initrd image"
    echo "Usage: $0 path/to/rootfs target/path/to/initrd"
    exit 1
fi
INITRD_TARGET_PATH=$2

echo "rootfs: $ROOTFS_DIR"
echo "initrd image: $INITRD_TARGET_PATH"

cd "$ROOTFS_DIR"

# Create minimal init script
cat > init << 'EOF'
#!/bin/sh
/bin/busybox mount -t proc none /proc
/bin/busybox mount -t sysfs none /sys
exec /bin/sh
EOF

chmod +x init

# Create compressed image
find . | cpio -o --format=newc | gzip -9 > $INITRD_TARGET_PATH

echo "$0 done OK"
