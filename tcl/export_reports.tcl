if {$argc != 2} {
  puts stderr "Usage: export_reports.tcl <project.xpr> <report-directory>"
  exit 2
}

set project_file [file normalize [lindex $argv 0]]
set report_dir [file normalize [lindex $argv 1]]
set project_name [file rootname [file tail $project_file]]
file mkdir $report_dir
open_project $project_file

set impl_status [get_property STATUS [get_runs impl_1]]
puts "REPORT impl_1.status=$impl_status"
if {![string match "write_bitstream Complete*" $impl_status]} {
  puts stderr "REPORT ERROR: impl_1 is not complete"
  close_project
  exit 3
}

open_run impl_1
report_utilization -hierarchical -file "$report_dir/utilization-hierarchical.rpt"
report_timing_summary -delay_type min_max -max_paths 50 -file "$report_dir/timing-summary.rpt"
report_drc -file "$report_dir/drc.rpt"
report_route_status -file "$report_dir/route-status.rpt"
write_checkpoint -force "$report_dir/${project_name}_routed.dcp"
puts "REPORT RESULT=PASS"
close_project
exit 0
