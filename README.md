# Bitonic Sort with Simulated Multicore Parallelism

## Overview
This project implements the **Bitonic Sort** algorithm in ARM Assembly language, designed to simulate multicore parallel processing on a Cortex-M3 processor. The implementation divides the sorting workload across four simulated cores, demonstrating how parallel algorithms can improve sorting efficiency.

## Course Information
- **Course**: CS 2400-003
- **Semester**: Fall 2025
- **Institution**: Metroploitan State University of Denver

## Codebase Contributers
- Isaiah Fite
- Matt Cantin
- Jackson Thomas

## Algorithm Description

### Bitonic Sort
Bitonic sort is a parallel sorting algorithm that works by recursively constructing a bitonic sequence (a sequence that monotonically increases then decreases, or vice versa) and then merging it into a sorted sequence. It is particularly well-suited for parallel execution because comparisons can be performed independently.

**Key Properties:**
- **Time Complexity**: O(log²n) parallel time with n processors
- **Data Size**: Works best with power-of-2 sized arrays

### Multicore Simulation
The algorithm simulates four cores working in parallel:

- **Core 0**: Sorts the first quarter (ascending)
- **Core 1**: Sorts the second quarter (descending) and merges the first half
- **Core 2**: Sorts the third quarter (ascending)
- **Core 3**: Sorts the fourth quarter (descending), merges the second half, and performs final merge

## Implementation Details

### Architecture
- **Target**: ARM Cortex-M3
- **Language**: ARM Assembly (ARMv7-M instruction set)
- **Simulator**: Keil µVision 5

### Key Functions in main.s

#### `main`
Entry point that initializes direction control and calls all four cores sequentially (simulating parallel execution).

#### `core0` - `core3`
Individual core routines that:
- Initialize their segment of the array
- Sort their quarter using `bitonicSort`
- Perform necessary merge operations

#### `bitonicSort`
Recursive function that:
- Splits array segment in half
- Sorts first half in one direction
- Sorts second half in opposite direction
- Merges the bitonic sequence

#### `merge`
Recursively merges a bitonic sequence by:
- Comparing and swapping elements at distance n/2
- Recursively merging both halves

### Register Usage
- **r4**: Array base address
- **r5**: Current segment length
- **r6**: Direction flag (1 = ascending, 0 = descending)
- **r7-r8**: Temporary calculation registers
- **r9**: Debug register (holds final array address)

## Getting Started

### Prerequisites
- **Keil µVision IDE** (version 5 or later recommended)
- **ARM Cortex-M3** device pack installed

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/IsaiahFite/CS2400Group6.git
   cd CS2400Group6
   ```

2. Open Keil µVision

3. Create a new project or open existing project file

### Configuration
1. **Device Selection**: Select an ARM Cortex-M3 device (e.g., STM32F103)
2. **Manage Runtime Environment** Select CMSIS->CORE and Device->C startup

### Target Options
1. **Debug** Select Simulation
2. **Linker** Select Scatter File

4. Add `main.s` to your project

### Running the Program

1. **Build the Project**:
   - Click Project → Build Target (F7)
   - Verify no errors in the build output

2. **Start Debug Session**:
   - Click Debug → Start/Stop Debug Session (Ctrl+F5)

3. **Run the Simulation**:
   - Click Debug → Run (F5)
   - The program will execute until the `stop` label

4. **View Results**:
   - Open Memory Window (View → Memory Windows → Memory 1)
   - Enter the address of `arr` to see the sorted array
   - Or view register `r9` which holds the array address after execution

## References

- Batcher, K. E. (1968). "Sorting networks and their applications"
- ARM Cortex-M3 Technical Reference Manual
- ARM Assembly Language Programming (ARMv7-M)

## Contact

For questions or issues, please contact the team members or create an issue in the repository.

---

**Last Updated**: November 18, 2025

