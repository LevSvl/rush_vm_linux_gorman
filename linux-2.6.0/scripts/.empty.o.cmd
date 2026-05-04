cmd_scripts/empty.o := gcc -Wp,-MD,scripts/.empty.o.d -nostdinc -iwithprefix include -D__KERNEL__ -Iinclude  -D__KERNEL__ -Iinclude  -Wall -Wstrict-prototypes -Wno-trigraphs -O2 -fno-strict-aliasing -fno-common -mno-red-zone -mcmodel=kernel -pipe -fno-reorder-blocks	 -Wno-sign-compare -fno-asynchronous-unwind-tables -Wdeclaration-after-statement    -DKBUILD_BASENAME=empty -DKBUILD_MODNAME=empty -c -o scripts/empty.o scripts/empty.c

deps_scripts/empty.o := \
  scripts/empty.c \

scripts/empty.o: $(deps_scripts/empty.o)

$(deps_scripts/empty.o):
