# Nombre del archivo fuente (sin extensión)
TARGET = main

# Nombre del archivo .c
SRC = $(TARGET).c

# Nombre del archivo .hex
HEX = $(TARGET).hex

# Nombre del archivo binario
BIN = $(TARGET).bin

# Configuración del microcontrolador y la velocidad de reloj
MCU = atmega328p
F_CPU = 16000000UL

# Compilador y cargador
CC = avr-gcc
CFLAGS = -mmcu=$(MCU) -DF_CPU=$(F_CPU) -Os -Wall
OBJcopy = avr-objcopy
AVRDUDE = avrdude
AVRDUDEFLAGS = -c arduino -p $(MCU) -P /dev/ttyACM0 -b 115200 -D

# Dirección de inicio y tamaño de la sección a grabar
SECTION_ADDR = 0x1000
SECTION_SIZE = 0x2000

# Reglas
all: $(HEX) size

$(HEX): $(TARGET).elf
	$(OBJcopy) -O ihex -R .eeprom $(TARGET).elf $(HEX)

$(BIN): $(TARGET).elf
	$(OBJcopy) -O binary -j .text -j .data $(TARGET).elf $(BIN)

$(TARGET).elf: $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET).elf $(SRC)

size: $(TARGET).elf
	@echo "Información de la memoria del linker script:"
	@avr-size -C --mcu=$(MCU) $(TARGET).elf
	@echo ""
	@echo "Secciones de memoria ocupadas:"
	@if [ -f $(TARGET).map ]; then \
		grep -A 10 "Memory Configuration" $(TARGET).map || true; \
	else \
		echo "Error: No se encontró el archivo $(TARGET).map"; \
	fi

upload: $(BIN)
	$(AVRDUDE) $(AVRDUDEFLAGS) -U flash:w:$(BIN):i -U flash:w:$(BIN):$(SECTION_ADDR):eeprom

map:$(TARGET).elf
	avr-gcc -mmcu=atmega328p -o main.elf main.c -Wl,-Map=main.map
clean:
	rm -f $(TARGET).elf $(HEX) $(BIN)

.PHONY: all clean upload

