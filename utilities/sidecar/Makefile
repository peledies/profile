PROFILE_DIR := $(shell cd "$(dir $(abspath $(lastword $(MAKEFILE_LIST))))/../.." && pwd)
BIN_DIR     := $(PROFILE_DIR)/bin
TARGET      := $(BIN_DIR)/sidecar_toggle
SOURCE      := sidecar_toggle.swift

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(SOURCE)
	swiftc $(SOURCE) -o $(TARGET)

clean:
	rm -f $(TARGET)
