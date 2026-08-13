if {$argc != 2} {
  puts stderr "Usage: export_synth_reports.tcl <project.xpr> <report_dir>"
  exit 2
}

set project_file [file normalize [lindex $argv 0]]
set report_dir [file normalize [lindex $argv 1]]
file mkdir $report_dir

open_project $project_file
set status [get_property STATUS [get_runs synth_1]]
puts "REPORT synth_1.status=$status"
if {![string match "synth_design Complete*" $status]} {
  puts stderr "REPORT RESULT=FAIL synth_1 is incomplete"
  close_project
  exit 3
}

open_run synth_1
report_utilization -file [file join $report_dir utilization_synth.rpt]
report_utilization -hierarchical -hierarchical_depth 8 \
  -file [file join $report_dir utilization_hier_synth.rpt]

set gateway_cells [get_cells -quiet -hier -filter {NAME =~ *GatewayEndpoint* || REF_NAME =~ *GatewayEndpoint*}]
set packer_cells [get_cells -quiet -hier -filter {NAME =~ *axis_data_packge* || REF_NAME =~ *axis_data_packge*}]
set xdma_cells [get_cells -quiet -hier -filter {NAME =~ *xdma_ep_i*}]
set cpu_cells [get_cells -quiet -hier -filter {NAME =~ *U_CPU_TOP*}]

set summary_file [file join $report_dir phase1_pruning_summary.txt]
set fd [open $summary_file w]
foreach pair [list \
  [list synth_status $status] \
  [list gateway_endpoint_cells [llength $gateway_cells]] \
  [list axis_data_packge_cells [llength $packer_cells]] \
  [list xdma_shell_cells [llength $xdma_cells]] \
  [list cpu_wrapper_cells [llength $cpu_cells]]] {
  lassign $pair key value
  puts $fd "$key=$value"
  puts "REPORT $key=$value"
}
close $fd

if {[llength $gateway_cells] != 0 || [llength $packer_cells] != 0} {
  puts stderr "REPORT RESULT=FAIL DiffTest transport survived synthesis"
  close_project
  exit 4
}

puts "REPORT RESULT=PASS"
close_project
exit 0
