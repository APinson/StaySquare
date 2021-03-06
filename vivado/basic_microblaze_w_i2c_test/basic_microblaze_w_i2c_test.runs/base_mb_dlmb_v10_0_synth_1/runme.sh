#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/afs/ece/support/xilinx/xilinx.release/Vivado-2017.2/SDK/2017.2/bin:/afs/ece/support/xilinx/xilinx.release/Vivado-2017.2/Vivado/2017.2/ids_lite/ISE/bin/lin64:/afs/ece/support/xilinx/xilinx.release/Vivado-2017.2/Vivado/2017.2/bin
else
  PATH=/afs/ece/support/xilinx/xilinx.release/Vivado-2017.2/SDK/2017.2/bin:/afs/ece/support/xilinx/xilinx.release/Vivado-2017.2/Vivado/2017.2/ids_lite/ISE/bin/lin64:/afs/ece/support/xilinx/xilinx.release/Vivado-2017.2/Vivado/2017.2/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/afs/ece/support/xilinx/xilinx.release/Vivado-2017.2/Vivado/2017.2/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/afs/ece/support/xilinx/xilinx.release/Vivado-2017.2/Vivado/2017.2/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/afs/ece.cmu.edu/usr/apinson/Documents/500/vivado/microblaze_HDMI_test/microblaze_HDMI_test.runs/base_mb_dlmb_v10_0_synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log base_mb_dlmb_v10_0.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source base_mb_dlmb_v10_0.tcl
