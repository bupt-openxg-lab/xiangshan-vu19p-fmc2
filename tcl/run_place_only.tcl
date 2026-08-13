if {$argc != 2} {
  puts stderr "Usage: run_place_only.tcl <project.xpr> <report_dir>"
  exit 2
}

set project_file [file normalize [lindex $argv 0]]
set report_dir [file normalize [lindex $argv 1]]
file mkdir $report_dir

set jobs 8
if {[info exists ::env(VIVADO_JOBS)] && [string is integer -strict $::env(VIVADO_JOBS)] && $::env(VIVADO_JOBS) > 0} {
  set jobs $::env(VIVADO_JOBS)
}

open_project $project_file
set synth_status [get_property STATUS [get_runs synth_1]]
puts "PLACE synth_1.status=$synth_status"
if {![string match "synth_design Complete*" $synth_status]} {
  puts stderr "PLACE RESULT=FAIL: completed synth_1 is required"
  close_project
  exit 3
}

set impl_run [get_runs impl_1]
set old_status [get_property STATUS $impl_run]
puts "PLACE impl_1.old_status=$old_status"
if {[string match "*Running*" $old_status] || [string match "*Queued*" $old_status]} {
  puts stderr "PLACE RESULT=FAIL: impl_1 is already active"
  close_project
  exit 4
}

reset_run $impl_run
launch_runs $impl_run -to_step place_design -jobs $jobs
wait_on_run $impl_run
set place_status [get_property STATUS $impl_run]
puts "PLACE impl_1.status=$place_status"
set run_dir [get_property DIRECTORY $impl_run]
set placed_dcps [glob -nocomplain -directory $run_dir *_placed.dcp]
if {[llength $placed_dcps] != 1} {
  puts stderr "PLACE RESULT=FAIL: expected one placed checkpoint in $run_dir, found [llength $placed_dcps]"
  close_project
  exit 5
}
puts "PLACE checkpoint=[lindex $placed_dcps 0]"

open_run $impl_run
report_utilization -file [file join $report_dir utilization_placed.rpt]
report_utilization -hierarchical -hierarchical_depth 8 \
  -file [file join $report_dir utilization_hier_placed.rpt]
report_design_analysis -congestion \
  -file [file join $report_dir design_analysis_congestion_placed.rpt]
report_timing_summary -delay_type min_max -max_paths 20 \
  -file [file join $report_dir timing_summary_placed.rpt]
report_clock_utilization \
  -file [file join $report_dir clock_utilization_placed.rpt]
report_drc -file [file join $report_dir drc_placed.rpt]
write_checkpoint -force [file join $report_dir xs_fpga_top_debug_placed.dcp]

set gateway_cells [get_cells -quiet -hier -filter {NAME =~ *GatewayEndpoint* || REF_NAME =~ *GatewayEndpoint*}]
set packer_cells [get_cells -quiet -hier -filter {NAME =~ *axis_data_packge* || REF_NAME =~ *axis_data_packge*}]
set summary_file [file join $report_dir phase1_place_summary.txt]
set fd [open $summary_file w]
puts $fd "synth_status=$synth_status"
puts $fd "place_status=$place_status"
puts $fd "gateway_endpoint_cells=[llength $gateway_cells]"
puts $fd "axis_data_packge_cells=[llength $packer_cells]"
puts $fd "route_design_launched=0"
close $fd

puts "PLACE gateway_endpoint_cells=[llength $gateway_cells]"
puts "PLACE axis_data_packge_cells=[llength $packer_cells]"
puts "PLACE route_design_launched=0"
puts "PLACE RESULT=PASS"
close_project
exit 0
