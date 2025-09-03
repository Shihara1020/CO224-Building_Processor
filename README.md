# CO224 Computer Architecture Lab Repository 🖥️

![Computer Architecture](https://img.shields.io/badge/Computer-Architecture-blue) 
![Verilog](https://img.shields.io/badge/Verilog-HDL-orange) 


This repository contains my implementations for the **CO224 Computer Architecture labs** (Lab 5 and Lab 6) from the Department of Computer Engineering, University of Peradeniya. The labs focus on building a simple 8-bit single-cycle processor and adding a memory hierarchy to it.

## 🛠️ Lab 5 - Building a Simple Processor

### 📝 Description
Design an 8-bit single-cycle processor with:
- **ALU**: Supports operations like `add`, `sub`, `and`, `or`, `mov`, and `loadi`
- **Register File**: 8×8 register file with synchronous write & async read
- **Control Logic**: Integrates ALU and register file
- **Flow Control**: Supports `j` (jump) and `beq` (branch) instructions

### 🧩 Tasks
| Part | Task | Files |
|------|------|-------|
| 1 | Implement ALU (FORWARD, ADD, AND, OR) | [`alu.v`](Lab5/Part1/alu.v) |
| 2 | Build register file | [`reg_file.v`](Lab5/Part2/reg_file.v) |
| 3 | Integrate CPU components | [`cpu.v`](Lab5/Part3/cpu.v) |
| 4 | Add flow control instructions | [`cpu_upgraded.v`](Lab5/Part4/cpu_upgraded.v) |
| 5* | Bonus: Extended instructions | [`cpu_extended.v`](Lab5/Part5/cpu_extended.v) |

*Bonus instructions: `mult`, `sll`, `srl`, etc.

## 🧠 Lab 6 - Memory Hierarchy

### 📝 Description
Extend the processor with:
- **Data Memory**: For storing/loading data
- **Data Cache**: 32-byte direct-mapped cache (write-back)
- **Instruction Cache**: 128-byte direct-mapped cache

### 🧩 Tasks
| Part | Task | Files |
|------|------|-------|
| 1 | Connect data memory (`lwd`, `lwi`, `swd`, `swi`) | [`data_memory.v`](Lab6/Part1/data_memory.v) |
| 2 | Implement data cache | [`data_cache.v`](Lab6/Part2/data_cache.v) |
| 3 | Add instruction cache | [`instruction_cache.v`](Lab6/Part3/instruction_cache.v) |

## 📂 Repository Structure
```text
CO224-Computer-Architecture-Labs/
├── Lab5/
│   ├── Part[1-5]/               # Each part has Verilog files + testbenches
│   │   ├── *.v                  # Verilog modules
│   │   ├── testbench_*.v        # Testbenches
│   │   └── timing_diagrams/     # Screenshots
├── Lab6/
│   ├── Part[1-3]/               # Memory hierarchy components
│   │   ├── *.v                  # Verilog modules
│   │   ├── testbench_*.v        # Testbenches
│   │   └── report/              # Performance analysis
└── README.md

🚀 Usage
Clone the repository:

bash
git clone https://github.com/yourusername/CO224-Computer-Architecture-Labs.git
cd CO224-Computer-Architecture-Labs
Simulate any module (example for ALU):

bash
iverilog -o testbench testbench_alu.v alu.v
vvp testbench
View waveforms:

bash
gtkwave waveform.vcd
🛠️ Tools Used
Verilog HDL - Hardware design

Icarus Verilog - Simulation

GTKWave - Waveform visualization

Git - Version control

📜 Report & Analysis
Performance comparison reports available in:

Lab5/Part5/report/

Lab6/Part2/report/

✍️ Author
Your Name
🎓 Department of Computer Engineering, University of Peradeniya
📧 your.email@email.com

🙏 Acknowledgments
Course instructors and TAs for guidance

Fellow students for collaborative discussions

⭐ Happy coding! May the pipeline always be full! ⭐

text

### Key Improvements:
1. **Visual Appeal**: Added badges, emojis, and clear section headers
2. **Better Organization**: Structured tables for tasks and clean directory tree
3. **Enhanced Readability**: Consistent formatting with code blocks
4. **Interactive Elements**: Linked files in the directory structure
5. **Professional Yet Fun**: Balanced academic tone with playful elements (like the pipeline joke)

You can copy this directly into your `README.md` file! The markdown will render beautifully on GitHub/GitLab.
