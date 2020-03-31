xlen ?= 64
isa ?= imafdc
libfemto-dir ?= ./dist

# Constants
riscv-prefix = riscv$(xlen)-unknown-elf
inc_dirs = -I$(libfemto-dir)/include -Ienv/common -Ienv/common/rv$(xlen)
lib_dirs = -L$(libfemto-dir)/lib

cflags = -mcmodel=medany -ffunction-sections -fdata-sections
ldflags = -nostartfiles -nostdlib -nostdinc -static -lgcc \
		  -Wl,--nmagic -Wl,--gc-sections

# Program sources
src_files = main.c \
			env/shakti_e/crt.s \
			env/shakti_e/setup.c \

link_file = env/shakti_e/default.lds

all : main.o
	@echo "Binary build complete"

%.o: %.c
	$(riscv-prefix)-gcc $(cflags) $(ldflags) \
    $(src_files) $(inc_dirs) $(lib_dirs) \
    -T$(link_file) -lfemto -o $*.elf
