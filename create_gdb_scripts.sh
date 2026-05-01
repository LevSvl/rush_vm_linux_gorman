#!/bin/bash
# create_gdb_scripts.sh

#
# Set KSRC_DIR value with path/to/your/kernel
#
KSRC_DIR=/home/svetl/Projects/gorman_linux/linux-2.6.32.40

#
# Set GDB_SCRIPT_PATH with your path
#
GDB_SCRIPT_PATH=/home/svetl/Projects/gorman_linux/build/.gdbinit

# Create .gdbinit (без кавычек, чтобы переменные раскрылись)
cat > $GDB_SCRIPT_PATH << EOF
set auto-load safe-path /
set substitute-path /kernel/linux-2.6.32.40 $KSRC_DIR
directory $KSRC_DIR
directory $KSRC_DIR/mm
directory $KSRC_DIR/kernel
directory $KSRC_DIR/arch/x86/kernel
directory $KSRC_DIR/arch/x86/mm
set print asm-demangle on
set disassembly-flavor intel
set pagination off
set print pretty on
EOF

echo "✓ Created $GDB_SCRIPT_PATH"
