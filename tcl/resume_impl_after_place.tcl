if {$argc != 1} {
  puts stderr "Usage: resume_impl_after_place.tcl <project.xpr>"
  exit 2
}

set project_file [file normalize [lindex $argv 0]]
set jobs 8
if {[info exists ::env(VIVADO_JOBS)] && [string is integer -strict $::env(VIVADO_JOBS)] && $::env(VIVADO_JOBS) > 0} {
  set jobs $::env(VIVADO_JOBS)
}

open_project $project_file
set impl_run [get_runs impl_1]
set old_status [get_property STATUS $impl_run]
set run_dir [get_property DIRECTORY $impl_run]
set placed_dcps [glob -nocomplain -directory $run_dir *_placed.dcp]

puts "ROUTE impl_1.old_status=$old_status"
puts "ROUTE vivado_jobs=$jobs"
if {[string match "write_bitstream Complete*" $old_status]} {
  puts "ROUTE RESULT=PASS (already complete)"
  close_project
  exit 0
}
if {[string match "*Running*" $old_status] || [string match "*Queued*" $old_status]} {
  puts stderr "ROUTE RESULT=FAIL: impl_1 is already active"
  close_project
  exit 3
}
if {[llength $placed_dcps] != 1} {
  puts stderr "ROUTE RESULT=FAIL: expected one placed checkpoint in $run_dir, found [llength $placed_dcps]"
  close_project
  exit 4
}

puts "ROUTE resume_checkpoint=[lindex $placed_dcps 0]"
puts "ROUTE start_step=phys_opt_design"
puts "ROUTE target_step=write_bitstream"
launch_runs $impl_run -to_step write_bitstream -jobs $jobs
set wait_rc [catch {wait_on_run $impl_run} wait_message]
if {$wait_rc != 0} {
  puts stderr "ROUTE wait_on_run_error=$wait_message"
}

set final_status [get_property STATUS $impl_run]
puts "ROUTE impl_1.final_status=$final_status"
if {![string match "write_bitstream Complete*" $final_status]} {
  puts stderr "ROUTE RESULT=FAIL"
  close_project
  exit 5
}

puts "ROUTE RESULT=PASS"
close_project
exit 0
