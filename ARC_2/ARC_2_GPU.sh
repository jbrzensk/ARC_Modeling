#!/bin/bash

# "name" and "dirout" are named according to the testcase

name=ARC_2
dirout=${name}_out
diroutdata=${dirout}/data

# "executables" are renamed and called from their directory

dirbin=~/DualSPHysics/bin/linux
gencase="${dirbin}/GenCase4_linux64"
dualsphysicscpu="${dirbin}/DualSPHysics4.2CPU_linux64"
dualsphysicsgpu="${dirbin}/DualSPHysics4.4_linux64"
boundaryvtk="${dirbin}/BoundaryVTK4_linux64"
partvtk="${dirbin}/PartVTK4_linux64"
partvtkout="${dirbin}/PartVTKOut4_linux64"
measuretool="${dirbin}/MeasureTool4_linux64"
computeforces="${dirbin}/ComputeForces4_linux64"
isosurface="${dirbin}/IsoSurface4_linux64"
flowtool="${dirbin}/FlowTool4_linux64"
floatinginfo="${dirbin}/FloatingInfo4_linux64"

# Library path must be indicated properly

current=$(pwd)
cd $dirbin
path_so=$(pwd)
cd $current
export LD_LIBRARY_PATH=$path_so

# "dirout" to store results is removed if it already exists
if [ -e $dirout ]; then
  rm -r $dirout
fi


# CODES are executed according the selected parameters of execution in this testcase
errcode=0

# Executes GenCase4 to create initial files for simulation.
if [ $errcode -eq 0 ]; then
  $gencase ${name}_Def $dirout/$name -save:all
  errcode=$?
fi

# Executes DualSPHysics to simulate SPH method.
if [ $errcode -eq 0 ]; then
  $dualsphysicsgpu -gpu $dirout/$name $dirout -dirdataout data -svres
  errcode=$?
fi
# Executes PartVTK4 to create VTK files with particles and variables
export dirout2=${dirout}/particles
${partvtk} -dirin ${diroutdata} -savevtk ${dirout2}/PartFluid  -onlytype:-all,fluid -vars:+idp,+vel,+rhop,+press,+vor
if [ $? -ne 0 ] ; then fail; fi

${partvtk} -dirin ${diroutdata} -savevtk ${dirout2}/PartArc -onlytype:-all,+floating
if [ $? -ne 0 ] ; then fail; fi

${partvtkout} -dirin ${diroutdata} -savevtk ${dirout2}/PartFluidOut -SaveResume ${dirout2}/_ResumeFluidOut
if [ $? -ne 0 ] ; then fail; fi

export dirout2=${dirout}/boundary
${boundaryvtk} -loadvtk AutoDp -motiondata ${diroutdata} -savevtkdata ${dirout2}/Bound -onlytype:floating -savevtkdata ${dirout2}/Box.vtk -onlytype:fixed
if [ $? -ne 0 ] ; then fail; fi

export dirout2=${dirout}/floatinginfo
${floatinginfo} -dirin ${diroutdata} -onlymk:62 -savedata ${dirout2}/FloatingMotion 
if [ $? -ne 0 ] ; then fail; fi

export dirout2=${dirout}/surface
${isosurface} -dirin ${diroutdata} -saveiso ${dirout2}/Surface 
if [ $? -ne 0 ] ; then fail; fi

# Save the SOLID parts
export dirout2=${dirout}/boundary
${boundaryvtk} -loadvtk AutoDp -motiondata ${diroutdata} -savevtkdata ${dirout2}/Chain.vtk -onlymk:2-8 \
                                                             -savevtkdata ${dirout2}/ARC.vtk -onlymk:99 \
                                                             -savevtkdata ${dirout2}/Buoy.vtk -onlymk:98
if [ $? -ne 0 ] ; then fail; fi

# Save rendering of the surface
export dirout2=${dirout}/surface
${isosurface} -dirin ${diroutdata} -saveiso ${dirout2}/Surface 
if [ $? -ne 0 ] ; then fail; fi


if [ $errcode -eq 0 ]; then
  echo All done
else
  echo Execution aborted
fi
read -n1 -r -p "Press any key to continue..." key
echo