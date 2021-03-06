include ./Makefile.common

# Sources
SRCS = buttons.c lcdfront.c math_utils.c relay.c uart.c buzzer.c logger.c led.c numpad.c rotary.c version.c delay.c lst_handler.c queue.c vs1033.c lcd.c main.c rdm630.c system_stm32f4xx.c stm32f4xx_it.c syscalls.c usb_bsp.c usbh_usr.c audio.c

# Project name
PROJ_NAME=stm32F4_jukebox
OUTPATH=build

CFLAGS += -T./linker/stm32_flash.ld  -nostartfiles
CFLAGS += -DUSE_STDPERIPH_DRIVER -DSTM32F40XX -DUSE_STM32_DISCOVERY -DHSE_VALUE=8000000

vpath %.c src
vpath %.a lib

ROOT=$(shell pwd)

# Includes
CFLAGS += -Iinc -Ilib/CMSIS/Include -Ilib/CMSIS/Device/ST/STM32F4xx/Include
CFLAGS += -Ilib/conf

# Library paths
LIBPATHS = -Llib/STM32F4xx_StdPeriph_Driver 
LIBPATHS += -Llib/USB_OTG
LIBPATHS += -Llib/USB_Host/Core -Llib/USB_Host/Class/MSC
LIBPATHS += -Llib/fat_fs

# Libraries to link
LIBS = -lm -lfatfs -lstdperiph -lusbhostcore -lusbhostmsc -lusbcore

# Extra includes
CFLAGS += -Ilib/STM32F4xx_StdPeriph_Driver/inc
CFLAGS += -Ilib/USB_OTG/inc
CFLAGS += -Ilib/USB_Host/Core/inc
CFLAGS += -Ilib/USB_Host/Class/MSC/inc
CFLAGS += -Ilib/fat_fs/inc

# add startup file to build
SRCS += lib/startup_stm32f40xx.s

OBJS = $(SRCS:.c=.o)

###################################################

.PHONY: lib proj

all: lib proj 
	$(SIZE) $(OUTPATH)/$(PROJ_NAME).elf

lib:
	$(MAKE) -C lib FLOAT_TYPE=$(FLOAT_TYPE)

proj: prepare $(OUTPATH)/$(PROJ_NAME).elf
	

$(OUTPATH)/$(PROJ_NAME).elf: $(SRCS)
	mkdir -p $(OUTPATH)	
	bash ./scripts/setbuildid.script
	$(CC) $(CFLAGS) $^ -o $@ $(LIBPATHS) $(LIBS)
	$(OBJCOPY) -O ihex $(OUTPATH)/$(PROJ_NAME).elf $(OUTPATH)/$(PROJ_NAME).hex
	$(OBJCOPY) -O binary $(OUTPATH)/$(PROJ_NAME).elf $(OUTPATH)/$(PROJ_NAME).bin

flash: all
	$(FLASH_EXEC) $(OUTPATH)/$(PROJ_NAME).hex 0x8000000

cleanlibs:
	$(MAKE) clean -C lib # Remove this line if you don't want to clean the libs as well

prepare:
	rm -f $(OUTPATH)/$(PROJ_NAME).elf
	rm -f $(OUTPATH)/$(PROJ_NAME).hex
	rm -f $(OUTPATH)/$(PROJ_NAME).bin
	
clean:
	rm -f *.o
	rm -f $(OUTPATH)/$(PROJ_NAME).elf
	rm -f $(OUTPATH)/$(PROJ_NAME).hex
	rm -f $(OUTPATH)/$(PROJ_NAME).bin
