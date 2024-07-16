# Nombre del archivo fuente (sin extensión)
TARGET = main

# Directorios y archivos fuente
SRC_DIR = Appl
TEST_DIR = Testing
EXT_DIR = .ext
DEPLOY_DIR = deploy
SRC = $(SRC_DIR)/$(TARGET).c
TEST_SRC = $(TEST_DIR)/$(TARGET)_ut.c

# Archivos de salida
HEX = $(DEPLOY_DIR)/$(TARGET).hex
BIN = $(DEPLOY_DIR)/$(TARGET).bin
ELF = $(DEPLOY_DIR)/$(TARGET).elf
MAP = $(DEPLOY_DIR)/$(TARGET).map

# Configuración del microcontrolador y la velocidad de reloj
MCU = atmega328p
F_CPU = 16000000UL

# Compilador y cargador
CC = avr-gcc
CFLAGS = -mmcu=$(MCU) -DF_CPU=$(F_CPU) -Os -Wall
OBJcopy = avr-objcopy
AVRDUDE = avrdude
AVRDUDEFLAGS = -c arduino -p $(MCU) -P /dev/ttyACM0 -b 115200 -D

# Compilador y enlaces para pruebas
GTEST_DIR = $(EXT_DIR)/googletest/googletest
GMOCK_DIR = $(EXT_DIR)/googletest/googlemock
CXX = g++
CXXFLAGS = -I$(GTEST_DIR)/include -I$(GMOCK_DIR)/include -pthread

# Reglas
all: build test

build: $(HEX) size

$(HEX): $(ELF)
	$(OBJcopy) -O ihex -R .eeprom $(ELF) $(HEX)

$(BIN): $(ELF)
	$(OBJcopy) -O binary -j .text -j .data $(ELF) $(BIN)

$(ELF): $(SRC)
	$(CC) $(CFLAGS) -o $(ELF) $(SRC) -Wl,-Map,$(MAP)

size: $(ELF)
	@echo "Información de la memoria del linker script:"
	@avr-size -C --mcu=$(MCU) $(ELF)
	@echo ""
	@echo "Secciones de memoria ocupadas:"
	@if [ -f $(MAP) ]; then \
		grep -A 10 "Memory Configuration" $(MAP) || true; \
	else \
		echo "Error: No se encontró el archivo $(MAP)"; \
	fi

upload: $(BIN)
	$(AVRDUDE) $(AVRDUDEFLAGS) -U flash:w:$(BIN):i

clean:
	rm -f $(DEPLOY_DIR)/$(TARGET).elf $(DEPLOY_DIR)/$(TARGET).hex $(DEPLOY_DIR)/$(TARGET).bin runTests $(DEPLOY_DIR)/$(TARGET).map

map: 
	avr-gcc -mmcu=atmega328p -DF_CPU=16000000UL -Os -Wall -o deploy/main.elf Appl/main.c -Wl,-Map=deploy/main.map

test: runTests
	./runTests

runTests: $(TEST_SRC) $(EXT_DIR)/lib/libgtest.a $(EXT_DIR)/lib/libgmock.a
	$(CXX) $(CXXFLAGS) -o runTests $(TEST_SRC) $(GTEST_DIR)/lib/libgtest.a $(GMOCK_DIR)/lib/libgmock.a -lpthread
	
$(EXT_DIR)/lib/libgtest.a:
	cd $(GTEST_DIR) && sudo cmake . && sudo make

$(EXT_DIR)/lib/libgmock.a:
	cd $(GMOCK_DIR) && sudo cmake . && sudo make

.PHONY: all clean upload test runTests build
