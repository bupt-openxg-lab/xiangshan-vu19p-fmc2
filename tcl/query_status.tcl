if {$argc != 1} {
  puts stderr "Usage: query_status.tcl <project.xpr>"
  exit 2
}
open_project [file normalize [lindex $argv 0]]
foreach run_name {synth_1 impl_1} {
  set run [get_runs $run_name]
  puts "STATUS $run_name=[get_property STATUS $run]"
  puts "PROGRESS $run_name=[get_property PROGRESS $run]"
}
close_project
exit 0
