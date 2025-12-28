# Ten Point Half

A digital circuit design project implemented on **FPGA** using Verilog HDL. This project features a complete design flow including the main module, testbench for verification, and lookup table components.

## Project Overview

Ten Point Half is an FPGA-based digital design that demonstrates hardware description and simulation techniques. The project is structured with modular Verilog components and includes comprehensive testing infrastructure.

## Repository Structure

- **`tenthirty.v`**: Main design module implementing the Ten Point Half logic
- **`tb_tenthirty.v`**: Testbench file for simulating and verifying `tenthirty.v`
- **`LUT.v`**: Lookup Table (LUT) module providing combinational logic resources
- **`.gitignore`**: Version control exclusion list
- **`.DS_Store`**: macOS system file (can be ignored)

## Development Environment

### Required Tools

- Verilog simulation tool (e.g., ModelSim, Vivado Simulator, Icarus Verilog)
- FPGA synthesis and implementation tool (depending on target platform)
- Git for version control

### Recommended Setup

- Xilinx Vivado or Intel Quartus for FPGA development
- Text editor with Verilog syntax support (VS Code, Vim, Emacs)
- Waveform viewer for debugging (GTKWave, ModelSim)

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/Young-ChangJT/TenPointHalf.git
cd TenPointHalf
```

### Simulation

1. Import `tenthirty.v`, `LUT.v`, and `tb_tenthirty.v` into your simulation tool
2. Set `tb_tenthirty.v` as the top-level module
3. Run the simulation and observe waveforms and output results
4. Verify the functionality matches expected behavior

#### Example with Icarus Verilog

```bash
iverilog -o sim tenthirty.v LUT.v tb_tenthirty.v
vvp sim
```

### FPGA Implementation

1. Create a new FPGA project in your synthesis tool
2. Add `tenthirty.v` and `LUT.v` to the project
3. Configure I/O constraints according to your target board pinout
4. Run synthesis, implementation, and generate bitstream
5. Program the FPGA and verify hardware behavior

## Design Details

The project implements a Ten Point Half algorithm using:

- **Combinational logic** through lookup tables
- **Modular design** for easy testing and verification
- **Synthesizable Verilog** compatible with standard FPGA tools

## Testing

The included testbench (`tb_tenthirty.v`) provides:

- Automated stimulus generation
- Expected output verification
- Waveform generation for debugging
- Coverage of key functional scenarios

## Contributing

This is an academic/personal project. If you find issues or have suggestions:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with detailed description

## License

No explicit license specified. For usage in other projects, please contact the author.

## Author

- **Young-ChangJT**
- GitHub: [@Young-ChangJT](https://github.com/Young-ChangJT)

## Version History

- **Final Version** (Last commit): Complete implementation with all core features
- **First Commit**: Initial project setup with README

---

*For questions or collaboration opportunities, please open an issue or contact the author directly.*
