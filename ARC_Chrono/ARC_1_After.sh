#!/bin/bash

# "name" and "dirout" are named according to the testcase

name=ARC_1
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

# CODES are executed according the selected parameters of execution in this testcase
errcode=0

${partvtk} -dirin ${diroutdata} -savevtk ${dirout2}/PartFloating -onlytype:-all,+floating
if [ $? -ne 0 ] ; then fail; fi

export dirout2=${dirout}/boundary
${boundaryvtk} -loadvtk AutoActual -motiondata ${diroutdata} -savevtkdata ${dirout2}/Buckets.vtk -onlymk:13-16 -savevtkdata ${dirout2}/Weel -onlymk:12
if [ $? -ne 0 ] ; then fail; fi

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
