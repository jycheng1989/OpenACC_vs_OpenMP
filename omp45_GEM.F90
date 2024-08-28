!!!!!!
!! Author: Junyi Cheng, junyi.cheng@colorado, University of Coloradot at Boulder
!! Time: Aug. 27, 2024
!! This program is generated as a test kernel for GEM, as an example of specific loops
!! with both reduction and atomic operation   
!!!!!!
   
!OpenMP 4.5 with reduction and atomic
module particle
   implicit none
   integer :: numOfParticle
   integer :: outOfBoundaryOfParticle1, outOfBoundaryOfParticle2, outOfBoundaryOfParticle3
   real(8), dimension(:), allocatable :: particle1, particle2, particle3
end module particle
 
module grid
   implicit none
   integer :: numOfGrid1, numOfGrid2, numOfGrid3
   real :: dGrid1, dGrid2, dGrid3
   real(8), dimension(:), allocatable :: grid1, grid2, grid3
end module grid

Program test
   use particle
   use grid
   use mpi
   implicit none
   integer :: i, mpiRank, mpiSize, error
   integer, parameter :: testLoopCount = 1
   real(8) :: startTime, endTime
   real(8) :: totalTime = 0
   call MPI_INIT(error)
   call MPI_COMM_SIZE(MPI_COMM_WORLD, mpiSize, error)
   call MPI_COMM_RANK(MPI_COMM_WORLD, mpiRank, error)

   numOfParticle = 100000000
   numOfGrid1 = 5
   numOfGrid2 = 10
   numOfGrid3 = 20
   call initializeParticle()
   call initializeGrid()
   do i = 1, testLoopCount
      grid1 = 0.0
      grid2 = 0.0
      grid3 = 0.0
      !$omp target update to(grid1, grid2, grid3)
      startTime = MPI_WTIME()
      call testKernel()
      endTime = MPI_WTIME()
      !$omp target update from(grid1, grid2, grid3)
      totalTime = totalTime + endTime - startTime
   enddo
   !if (mpiRank == 0) then
   !   write(*,*)'particle number out of boundary is', outOfBoundaryOfParticle1, outOfBoundaryOfParticle2, outOfBoundaryOfParticle3
   !   write(*,*)'grid1 is', grid1
   !   write(*,*)'grid2 is', grid2
   !   write(*,*)'grid3 is', grid3
   !endif
   write(*,*)'OpenMP 4.5: total time is', totalTime
   call finalizeParticle()
   call finalizeGrid()
   call MPI_FINALIZE(error)
end Program test

subroutine testKernel()
   use particle
   use grid
   implicit none
   integer :: i, k1, k2, k3 

   outOfBoundaryOfParticle1 = 0
   outOfBoundaryOfParticle2 = 0
   outOfBoundaryOfParticle3 = 0
   !$omp target teams
   !$omp distribute parallel do reduction(+: outOfBoundaryOfParticle1, outOfBoundaryOfParticle2, outOfBoundaryOfParticle3)
   !$omp map(tofrom: outOfBoundaryOfParticle1, outOfBoundaryOfParticle2, outOfBoundaryOfParticle3) map(to:dGrid1, dGrid2, dGrid3)
   do i = 1, numOfParticle
      particle1(i) = particle1(i) * 1.01
      particle2(i) = particle2(i) * 1.02
      particle3(i) = particle3(i) * 1.03
    
      if (particle1(i) > 1) then
         outOfBoundaryOfParticle1 = outOfBoundaryOfParticle1 + 1
      endif

      if (particle2(i) > 1) then
         outOfBoundaryOfParticle2 = outOfBoundaryOfParticle2 + 1
      endif

      if (particle3(i) > 1) then
         outOfBoundaryOfParticle3 = outOfBoundaryOfParticle3 + 1
      endif

      k1 = int(particle1(i) / dGrid1) + 1
      if (k1 >= 1 .and. k1 <= numOfGrid1) then
         !$omp atomic
         grid1(k1) = grid1(k1) + particle1(i) / real(numOfParticle)
      endif 

      k2 = int(particle2(i) / dGrid2) + 1
      if (k2 >= 1 .and. k2 <= numOfGrid2) then
         !$omp atomic
         grid2(k2) = grid2(k2) + particle2(i) / real(numOfParticle)
      endif

      k3 = int(particle3(i) / dGrid3) + 1
      if (k3 >= 1 .and. k3 <= numOfGrid3) then
         !$omp atomic
         grid3(k3) = grid3(k3) + particle3(i) / real(numOfParticle)
      endif
     
     particle1(i) = modulo(particle1(i), 1.0_8)
     particle2(i) = modulo(particle2(i), 1.0_8)
     particle3(i) = modulo(particle3(i), 1.0_8)   
  enddo
  !$omp end target teams

end subroutine testKernel
  
subroutine initializeParticle()
   use particle
   implicit none
   allocate(particle1(numOfParticle), particle2(numOfParticle), particle3(numOfParticle))
   !$omp target enter data map(alloc:particle1, particle2, particle3)
   call random_number(particle1)
   call random_number(particle2)
   call random_number(particle3)
   !$omp target update to(particle1, particle2, particle3)
end subroutine initializeParticle

subroutine initializeGrid()
   use grid
   implicit none
   allocate(grid1(numOfGrid1), grid2(numOfGrid2), grid3(numOfGrid3))
   !$omp target enter data map(alloc:grid1, grid2, grid3)
   grid1 = 0.0
   grid2 = 0.0
   grid3 = 0.0
   !$omp target update to(grid1, grid2, grid3)
   dGrid1 = 1.0 / real(numOfGrid1)
   dGrid2 = 1.0 / real(numOfGrid2)
   dGrid3 = 1.0 / real(numOfGrid3)
end subroutine initializeGrid

subroutine finalizeParticle()
   use particle
   implicit none
   !$omp target exit data map(delete:particle1, particle2, particle3)
   deallocate(particle1, particle2, particle3)
end subroutine finalizeParticle

subroutine finalizeGrid
   use grid
   implicit none
   !$omp target exit data map(delete:grid1, grid2, grid3)
   deallocate(grid1, grid2, grid3)
end subroutine finalizeGrid
