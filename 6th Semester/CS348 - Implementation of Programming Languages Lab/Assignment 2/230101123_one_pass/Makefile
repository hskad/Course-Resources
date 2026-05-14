# Compiler
CC = gcc

# Compiler flags
# -g: Debug info
# -w: Suppress warnings
CFLAGS = -g -w

# Directories
SRC_DIR = src
TEXT_DIR = text

# The final executable name
TARGET = assembler

# Source files (explicitly pointing to files in src folder)
SRCS = $(SRC_DIR)/main.c $(SRC_DIR)/optab.c $(SRC_DIR)/symtab.c $(SRC_DIR)/machine_code.c

# Object files (generated from the source list)
OBJS = $(SRCS:.c=.o)

# Default target
all: $(TARGET)

# Link the object files to create the executable
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)

# Compile .c files to .o files
# $< represents the source file, $@ represents the target .o file
.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

# Run the assembler from the root directory
run: $(TARGET)
	./$(TARGET)

# Clean up build artifacts and output files
clean:
	rm -f $(SRC_DIR)/*.o $(TARGET)
	rm -f $(TEXT_DIR)/output.txt
