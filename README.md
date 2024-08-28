## Author

- **Junyi Cheng**  
  University of Colorado Boulder  
  junyi.cheng@colorado.edu

## Overview

This repository contains a test kernel designed to compare OpenACC and OpenMP GPU offloading for a specific loop with both reduction and atomic operations. The code is extracted from the gyrokinetic particle-in-cell code GEM.

## Files

- **acc_GEM.F90**: OpenACC version.
- **omp45_GEM.F90**: OpenMP 4.5 version.
- **omp5x_GEM.F90**: OpenMP 5.x version.

- **make_nvidia.sh**: Bash script to compile the executable files for Nvidia GPUs.
- **local_run_nvidia.sh**: Bash script to run the executables locally on Nvidia GPUs. The script runs the executables four times for comparison and displays the timing results by default.
- **clean.sh**: Script to remove executable and module files.

## Usage

To run the code on Perlmutter:

```bash
module load nvhpc
sh make_nvidia.sh
sh local_run_nvidia.sh

