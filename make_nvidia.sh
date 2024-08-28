#!/bin/bash
ftn -O3 -Minfo=accel -acc acc_GEM.F90 -o GEM_acc
ftn -O3 -Minfo=accel -mp=gpu omp45_GEM.F90 -o GEM_omp45
ftn -O3 -Minfo=accel -mp=gpu omp5x_GEM.F90 -o GEM_omp5x
