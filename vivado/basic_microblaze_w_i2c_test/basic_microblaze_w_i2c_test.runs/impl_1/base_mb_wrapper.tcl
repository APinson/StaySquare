proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}


start_step write_bitstream
set ACTIVE_STEP write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  open_checkpoint base_mb_wrapper_routed.dcp
  set_property webtalk.parent_dir /afs/ece.cmu.edu/usr/apinson/Documents/500/vivado/microblaze_HDMI_test/microblaze_HDMI_test.cache/wt [current_project]
  set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
  add_files /afs/ece.cmu.edu/usr/apinson/Documents/500/vivado/microblaze_test/microblaze_test.srcs/sources_1/bd/base_mb/ip/base_mb_microblaze_0_0/data/mb_bootloop_le.elf
  set_property SCOPED_TO_REF base_mb [get_files -all /afs/ece.cmu.edu/usr/apinson/Documents/500/vivado/microblaze_test/microblaze_test.srcs/sources_1/bd/base_mb/ip/base_mb_microblaze_0_0/data/mb_bootloop_le.elf]
  set_property SCOPED_TO_CELLS microblaze_0 [get_files -all /afs/ece.cmu.edu/usr/apinson/Documents/500/vivado/microblaze_test/microblaze_test.srcs/sources_1/bd/base_mb/ip/base_mb_microblaze_0_0/data/mb_bootloop_le.elf]
  catch { write_mem_info -force base_mb_wrapper.mmi }
  catch { write_bmm -force base_mb_wrapper_bd.bmm }
  write_bitstream -force base_mb_wrapper.bit 
  catch { write_sysdef -hwdef base_mb_wrapper.hwdef -bitfile base_mb_wrapper.bit -meminfo base_mb_wrapper.mmi -file base_mb_wrapper.sysdef }
  catch {write_debug_probes -no_partial_ltxfile -quiet -force debug_nets}
  catch {file copy -force debug_nets.ltx base_mb_wrapper.ltx}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
  unset ACTIVE_STEP 
}

