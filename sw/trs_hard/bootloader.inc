
#define PROTEUS_SIMULATOR	0

#if PROTEUS_SIMULATOR == 1
#define EEPROM_CRC_ADDR		0xFE
#else
#define EEPROM_CRC_ADDR		0x3FE
#endif

#define FLASH_CRC_ADDR		0xFFFE

#define BOOTLOADER_MAJOR	0x1
#define BOOTLOADER_MINOR	0x2

#define BOOTLOADER_END		0x7FF
#define APP_STARTUP		0x800
#define APP_LO_INT		0x806
#define APP_HI_INT		0x80C
#define APP_HI_INT2		0x900
