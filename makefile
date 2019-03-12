
ARMGNU ?= arm-none-eabi

INCLUDEPATH ?= "./h"

COPS = -Wall -g -O0 -nostdlib -nostartfiles -ffreestanding  -march=armv7-a -mtune=cortex-a7 -mfloat-abi=hard -mfpu=neon-vfpv4 -I $(INCLUDEPATH) -I "./bsp" -D RPI2
AOPS = -Wall -g -O0 -nostdlib -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -D RPI2

gcc : kernel7.img

OBJS = build/startup.o

OBJS += build/rpi_aux.o
OBJS += build/rpi_gpio.o
OBJS += build/rpi_i2c.o
OBJS += build/rpi_irq.o
OBJS += build/rpi_systimer.o

OBJS += build/OS_Cpu_a.o
OBJS += build/OS_Cpu_c.o

OBJS += build/ucos_ii.o

OBJS += build/main.o
OBJS += build/userApp.o

LIBGCC = $(abspath $(shell $(ARMGNU)-gcc -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard -print-libgcc-file-name))
LIBC = $(abspath $(shell $(ARMGNU)-gcc -march=armv7-a -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -print-file-name=libc.a))

clean :
	rm -f build/*.o
	rm -f *.bin
	rm -f *.hex
	rm -f *.elf
	rm -f *.list
	rm -f *.img
	rm -f build/*.bc

build/%.o : port/%.s
	$(ARMGNU)-gcc $(COPS) -D__ASSEMBLY__ -c -o $@ $<
	
build/%.o : init/%.s
	$(ARMGNU)-gcc $(AOPS) -D__ASSEMBLY__ -c -o $@ $<
	
build/%.o : port/%.c
	$(ARMGNU)-gcc $(COPS)  -c -o $@ $<
		
build/%.o : bsp/%.c
	$(ARMGNU)-gcc $(COPS)  -c -o $@ $<
	
build/%.o : usrApp/%.c
	$(ARMGNU)-gcc $(COPS)  -c -o $@ $<

build/ucos_ii.o : ucos/ucos_ii.c
	$(ARMGNU)-gcc $(COPS) ucos/ucos_ii.c -c -o build/ucos_ii.o

kernel7.img : raspberrypi.ld $(OBJS)
	$(ARMGNU)-ld $(OBJS) $(LIBC) $(LIBGCC) -T raspberrypi.ld -o ucos_bcm2835.elf 
	$(ARMGNU)-objdump -D ucos_bcm2835.elf > ucos_bcm2835.list
	$(ARMGNU)-objcopy ucos_bcm2835.elf -O ihex ucos_bcm2835.hex
	$(ARMGNU)-objcopy ucos_bcm2835.elf -O binary ucos_bcm2835.bin
	$(ARMGNU)-objcopy ucos_bcm2835.elf -O binary kernel7.img
