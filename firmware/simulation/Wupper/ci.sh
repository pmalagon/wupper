#!/bin/bash
#Installation path and license server at Nikhef. For other institutes, please try another location.
echo "free -h"
free -h
if [ -d work/ ]; then
    echo "Deleting work directory"
    rm -rf work/
fi

if [ -d /opt/questasim_2019.1/bin/ ]; then
    #Nikhef questasim installation path and license server.
    export PATH=/opt/questasim_2019.1/bin/:$PATH
    export LM_LICENSE_FILE=@192.16.199.39
elif [ -d /afs/cern.ch/work/f/fschreud/public/questasim_2019.1/ ]; then
    #Cern questasim installation path and license server
    export PATH=/afs/cern.ch/work/f/fschreud/public/questasim_2019.1/linux_x86_64/:$PATH
    export MGLS_LICENSE_FILE=1717@lxlicen01,1717@lxlicen02,1717@lxlicen03,1717@lnxmics1,1717@lxlicen08
else
    echo "Could not find questasim installation path, exiting."
    exit 1
fi
    



if [ ! -d ../UVVM/ ]; then
  echo UVVM does not exist, copy from /project/et
  if [ -d /home/gitlab-runner/UVVM ]; then
    cp -r /home/gitlab-runner/UVVM ../UVVM
  elif [ -d /afs/cern.ch/work/f/fschreud/public/UVVM/ ]; then
    cp -r /afs/cern.ch/work/f/fschreud/public/UVVM ../UVVM
  else
    echo "Could not find UVVM library, exiting"
    exit 1
  fi
fi

if [ ! -d ../xilinx_simlib/ ]; then
  echo xilinx_simlib does not exist, copy from /project/et
  if [ -d /home/gitlab-runner/xilinx_simlib ]; then
    cp -r /home/gitlab-runner/xilinx_simlib ../xilinx_simlib
  elif [ -d /afs/cern.ch/work/f/fschreud/public/xilinx_simlib/ ]; then
    cp -r /afs/cern.ch/work/f/fschreud/public/xilinx_simlib/ ../xilinx_simlib
  else
    echo "Could not find xilinx libraries, exiting"
    exit 1
  fi
fi


if [ $# -eq 0 ]
then
    TESTS="Wupper"
    echo "No arguments supplied, running the following tests:
    $TESTS"
else
    TESTS=$1
    echo "Running test:
    $TESTS"
fi



for TEST in $TESTS 
do
  vsim -do ci-${TEST}.do
  SIMSTATUS=$?
  mv transcript transcript-${TEST}
  if grep -q "Simulation SUCCESS: No mismatch between counted and expected serious alerts" transcript-${TEST} && [ $SIMSTATUS == "0" ]
then
      echo ${TEST} simulation successful
else
      echo ${TEST} sumulation ERROR
    exit 1
fi
done

