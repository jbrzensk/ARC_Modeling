#!/bin/bash

# "name" and "dirout" are named according to the testcase

name=ARC_2
dirout=${name}_out
diroutdata=${dirout}/data
forceout=./
# "executables" are renamed and called from their directory

dirbin=/home/jbrzensk/Downloads/DualSPHysics_v4.4/bin/linux
gencase="${dirbin}/GenCase4_linux64"
dualsphysicscpu="${dirbin}/DualSPHysics4.4CPU_linux64"
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

# Executes GenCase4 to create initial files for simulation.
export dirout2=${dirout}/forces
${computeforces} -dirin ${diroutdata} -onlymk:110 -savecsv ${forceout}forceout2

${computeforces} -dirin ${diroutdata} -onlymk:99 -savecsv ${forceout}forceoutmk99

${computeforces} -dirin ${diroutdata} -onlymk:11 -savecsv ${forceout}forceoutmk11
if [ $? -ne 0 ] ; then fail; fi

# export dirout2=${dirout}/floatinginfo
# ${floatinginfo} -dirin ${diroutdata} -onlymk:99 -savedata ${dirout2}/FloatingMotion
# if [ $? -ne 0 ] ; then fail; fi


if [ $errcode -eq 0 ]; then
  echo All done
else
  echo Execution aborted
fi
echo

