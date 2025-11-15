# Makefile for Vending Machine Controller
# Supports both Mealy and Moore FSM implementations

# Compiler
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Directories
SRC_DIR = src
TB_DIR = tb
BUILD_DIR = build

# Source files
MEALY_SRC = $(SRC_DIR)/vending_machine_mealy.v
MOORE_SRC = $(SRC_DIR)/vending_machine_moore.v
MEALY_TB = $(TB_DIR)/tb_vending_machine_mealy.v
MOORE_TB = $(TB_DIR)/tb_vending_machine_moore.v

# Output files
MEALY_OUT = $(BUILD_DIR)/mealy_sim
MOORE_OUT = $(BUILD_DIR)/moore_sim
MEALY_VCD = $(BUILD_DIR)/tb_vending_machine_mealy.vcd
MOORE_VCD = $(BUILD_DIR)/tb_vending_machine_moore.vcd

# Compiler flags
IVERILOG_FLAGS = -g2012 -Wall

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[1;33m
NC = \033[0m # No Color

# Default target
.PHONY: all
all: mealy moore

# Create build directory
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Compile Mealy FSM
.PHONY: compile-mealy
compile-mealy: $(BUILD_DIR)
	@echo "$(YELLOW)Compiling Mealy FSM...$(NC)"
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(MEALY_OUT) $(MEALY_SRC) $(MEALY_TB)
	@echo "$(GREEN)Mealy FSM compiled successfully!$(NC)"

# Compile Moore FSM
.PHONY: compile-moore
compile-moore: $(BUILD_DIR)
	@echo "$(YELLOW)Compiling Moore FSM...$(NC)"
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(MOORE_OUT) $(MOORE_SRC) $(MOORE_TB)
	@echo "$(GREEN)Moore FSM compiled successfully!$(NC)"

# Run Mealy FSM simulation
.PHONY: sim-mealy
sim-mealy: compile-mealy
	@echo "$(YELLOW)Running Mealy FSM simulation...$(NC)"
	cd $(BUILD_DIR) && $(VVP) mealy_sim
	@echo "$(GREEN)Mealy FSM simulation completed!$(NC)"

# Run Moore FSM simulation
.PHONY: sim-moore
sim-moore: compile-moore
	@echo "$(YELLOW)Running Moore FSM simulation...$(NC)"
	cd $(BUILD_DIR) && $(VVP) moore_sim
	@echo "$(GREEN)Moore FSM simulation completed!$(NC)"

# Compile and run Mealy
.PHONY: mealy
mealy: sim-mealy

# Compile and run Moore
.PHONY: moore
moore: sim-moore

# Run both simulations
.PHONY: test
test: sim-mealy sim-moore
	@echo "$(GREEN)All simulations completed!$(NC)"

# View Mealy waveform
.PHONY: wave-mealy
wave-mealy:
	@if [ -f $(MEALY_VCD) ]; then \
		echo "$(YELLOW)Opening Mealy FSM waveform...$(NC)"; \
		$(GTKWAVE) $(MEALY_VCD) scripts/mealy_wave.gtkw 2>/dev/null || $(GTKWAVE) $(MEALY_VCD); \
	else \
		echo "$(YELLOW)VCD file not found. Run 'make sim-mealy' first.$(NC)"; \
	fi

# View Moore waveform
.PHONY: wave-moore
wave-moore:
	@if [ -f $(MOORE_VCD) ]; then \
		echo "$(YELLOW)Opening Moore FSM waveform...$(NC)"; \
		$(GTKWAVE) $(MOORE_VCD) scripts/moore_wave.gtkw 2>/dev/null || $(GTKWAVE) $(MOORE_VCD); \
	else \
		echo "$(YELLOW)VCD file not found. Run 'make sim-moore' first.$(NC)"; \
	fi

# Clean build artifacts
.PHONY: clean
clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	rm -rf $(BUILD_DIR)
	@echo "$(GREEN)Clean completed!$(NC)"

# Show help
.PHONY: help
help:
	@echo "Vending Machine Controller - Build System"
	@echo "=========================================="
	@echo ""
	@echo "Available targets:"
	@echo "  make all          - Compile and run both Mealy and Moore FSMs"
	@echo "  make mealy        - Compile and run Mealy FSM"
	@echo "  make moore        - Compile and run Moore FSM"
	@echo "  make test         - Run all simulations"
	@echo "  make compile-mealy - Compile Mealy FSM only"
	@echo "  make compile-moore - Compile Moore FSM only"
	@echo "  make sim-mealy    - Run Mealy FSM simulation"
	@echo "  make sim-moore    - Run Moore FSM simulation"
	@echo "  make wave-mealy   - View Mealy FSM waveform in GTKWave"
	@echo "  make wave-moore   - View Moore FSM waveform in GTKWave"
	@echo "  make clean        - Remove build artifacts"
	@echo "  make help         - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make mealy && make wave-mealy    - Run and view Mealy FSM"
	@echo "  make test                        - Run all tests"
	@echo ""
