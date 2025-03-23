# Визначення шляху до інструментів компіляції
# Дозволяє задавати власне розташування тулчейну, якщо потрібно.
SDK_PREFIX?=~/ak3/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-

# Визначення компілятора, лінкера та допоміжних утиліт
CC = $(SDK_PREFIX)gcc  # GNU C-компілятор для ARM
LD = $(SDK_PREFIX)ld  # GNU лінкер
SIZE = $(SDK_PREFIX)size  # Утиліта для перегляду розміру бінарного файлу
OBJCOPY = $(SDK_PREFIX)objcopy  # Утиліта для конвертації об'єктних файлів
QEMU = qemu-system-gnuarmeclipse  # Емулятор для ARM Cortex-M

# Визначення плати та мікроконтролера
BOARD ?= STM32F4-Discovery  # Плата за замовчуванням
MCU = STM32F407VG  # Конкретна модель мікроконтролера
TARGET = firmware  # Ім'я вихідного файлу

# Визначення архітектури процесора
CPU_CC = cortex-m4  # Ядро ARM Cortex-M4

# Визначення порту GDB для відлагодження
TCP_ADDR = 1234  # TCP-порт для дистанційного налагодження

# Список залежностей (файл з вихідним кодом та лінкерний скрипт)
deps = start.S lscript.ld

# Основна ціль для компіляції
all: target

target:
	# Асемблюємо стартовий файл
	$(CC) -x assembler-with-cpp -c -O0 -g3 -mcpu=$(CPU_CC) -mthumb -Wall start.S -o start.o
	# Лінкуємо об'єктний файл у виконуваний ELF
	$(CC) start.o -mcpu=$(CPU_CC) -mthumb -Wall --specs=nosys.specs -nostdlib -lgcc -T lscript.ld -o $(TARGET).elf
	# Конвертуємо ELF у бінарний формат (для запису у флеш-пам'ять МК)
	$(OBJCOPY) -O binary -F elf32-littlearm $(TARGET).elf $(TARGET).bin

# Запуск QEMU для емуляції прошивки
qemu:
	# Запускаємо QEMU з налагодженням та заданою платою та МК
	$(QEMU) --verbose --verbose --board $(BOARD) --mcu $(MCU) -d unimp,guest_errors --image $(TARGET).bin --semihosting-config enable=on,target=native -gdb tcp::$(TCP_ADDR) -S

# Очищення згенерованих файлів
clean:
	# Видаляємо всі створені під час компіляції файли
	rm -f *.o
	rm -f *.elf
	rm -f *.bin
