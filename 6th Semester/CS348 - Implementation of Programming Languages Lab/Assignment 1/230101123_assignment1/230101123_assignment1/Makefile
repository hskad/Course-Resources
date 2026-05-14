# Tools and Flags
ASM = nasm
ASMFLAGS = -f elf32
CC = gcc
CFLAGS = -m32 -no-pie
LD = ld
LDFLAGS = -m elf_i386

# File Names
FILE_A  = 230101123_seta
FILE_B1 = 230101123_setb1
FILE_B2 = 230101123_setb2

# Targets (Executables)
TARGET_A  = seta
TARGET_B1 = setb1
TARGET_B2 = setb2

# Default: Build all executables
all: $(TARGET_A) $(TARGET_B1) $(TARGET_B2)

# ==========================================
# Build Rules
# ==========================================

# 1. Set A: Pure Assembly (Linked with ld)
$(TARGET_A): $(FILE_A).o
	$(LD) $(LDFLAGS) $(FILE_A).o -o $(TARGET_A)

# 2. Set B1: Linked with C Library (gcc)
$(TARGET_B1): $(FILE_B1).o
	$(CC) $(CFLAGS) $(FILE_B1).o -o $(TARGET_B1)

# 3. Set B2: Linked with C Library (gcc)
$(TARGET_B2): $(FILE_B2).o
	$(CC) $(CFLAGS) $(FILE_B2).o -o $(TARGET_B2)

# Generic rule to assemble any .asm file into .o
%.o: %.asm
	$(ASM) $(ASMFLAGS) $< -o $@

# ==========================================
# Run Commands
# ==========================================

run_a: $(TARGET_A)
	./$(TARGET_A)

run_b1: $(TARGET_B1)
	./$(TARGET_B1)

run_b2: $(TARGET_B2)
	./$(TARGET_B2)

# ==========================================
# Clean Up
# ==========================================
clean:
	rm -f *.o $(TARGET_A) $(TARGET_B1) $(TARGET_B2)

.PHONY: all clean run_a run_b1 run_b2
