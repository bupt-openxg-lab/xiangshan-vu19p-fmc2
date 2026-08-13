if {$argc != 1} {
  puts stderr "Usage: vivado -mode batch -source check_project.tcl -tclargs <project.xpr>"
  exit 2
}

proc require_equal {label actual expected} {
  puts "CHECK $label=$actual"
  if {$actual ne $expected} {
    puts stderr "CHECK ERROR $label expected='$expected' actual='$actual'"
    exit 3
  }
}

proc require_contains {label values expected} {
  puts "CHECK $label=$values"
  if {[lsearch -exact $values $expected] < 0} {
    puts stderr "CHECK ERROR $label missing '$expected'"
    exit 3
  }
}

proc require_file_text {label path pattern} {
  set fd [open $path r]
  set content [read $fd]
  close $fd
  if {![regexp -- $pattern $content]} {
    puts stderr "CHECK ERROR $label pattern '$pattern' missing from $path"
    exit 3
  }
  puts "CHECK $label=PASS"
}

proc files_with_basename {basename} {
  set matches [list]
  foreach path [get_files -quiet] {
    if {[file tail $path] eq $basename} {
      lappend matches [file normalize $path]
    }
  }
  return [lsort -unique $matches]
}

set project_file [file normalize [lindex $argv 0]]
open_project $project_file

set expected_project [file rootname [file tail [lindex $argv 0]]]
require_equal project [get_property NAME [current_project]] $expected_project
require_equal part [get_property PART [current_project]] "xcvu19p-fsva3824-2-e"
require_equal top [get_property TOP [get_filesets sources_1]] "fpga_top_debug"

set xstop_files [files_with_basename XSTop.sv]
set simtop_files [files_with_basename SimTop.sv]
set endpoint_files [files_with_basename GatewayEndpoint.sv]
puts "CHECK XSTop_files=$xstop_files"
require_equal XSTop_file_count [llength $xstop_files] 1
require_equal SimTop_file_count [llength $simtop_files] 0
require_equal GatewayEndpoint_file_count [llength $endpoint_files] 0

set wrapper_files [get_files -quiet */kmh/SimTop_wrapper.sv]
require_equal standalone_wrapper_count [llength $wrapper_files] 1
require_file_text wrapper_selects_XSTop [lindex $wrapper_files 0] {`define TOP_NAME XSTop}

set source_defines [get_property VERILOG_DEFINE [get_filesets sources_1]]
foreach expected_define {
  XIANGSHAN_FPGA
  NO_DIFF
  VU19P_SOLO_FMC2
  VU19P_SOLO_FMC2_TRUE_NO_DIFF
} {
  require_contains defines $source_defines $expected_define
}

set constraints [get_files -of_objects [get_filesets constrs_1]]
require_equal constraint_count [llength $constraints] 3
set normalized_constraints [list]
foreach constraint $constraints {
  lappend normalized_constraints [file normalize $constraint]
}
puts "CHECK constraints=$normalized_constraints"
foreach expected_name {ddr.xdc fpga.xdc debug.xdc} {
  set hits [lsearch -all -glob $normalized_constraints "*/$expected_name"]
  require_equal ${expected_name}_count [llength $hits] 1
}
foreach forbidden_name {ddr_rank1.xdc xdma.xdc xdma_x4_lanes.xdc xdma_x8_lanes.xdc xdma_ila.xdc} {
  set hits [lsearch -all -glob $normalized_constraints "*/$forbidden_name"]
  require_equal ${forbidden_name}_count [llength $hits] 0
}

set xdma_bd [get_files -quiet */xdma_ep.bd]
set data_bridge_bd [get_files -quiet */data_bridge.bd]
require_equal xdma_bd_count [llength $xdma_bd] 0
require_equal data_bridge_bd_count [llength $data_bridge_bd] 0

set ddr_bd [get_files -quiet */jtag_ddr_subsys.bd]
require_equal ddr_bd_count [llength $ddr_bd] 1
open_bd_design [lindex $ddr_bd 0]
validate_bd_design

set ddr [get_bd_cells ddr4_0]
foreach property_expected {
  {CONFIG.C0.DDR4_AxiAddressWidth 34}
  {CONFIG.C0.DDR4_AxiDataWidth 64}
  {CONFIG.C0.DDR4_CasLatency 11}
  {CONFIG.C0.DDR4_CasWriteLatency 9}
  {CONFIG.C0.DDR4_DataWidth 64}
  {CONFIG.C0.DDR4_Ecc false}
  {CONFIG.C0.DDR4_InputClockPeriod 5000}
  {CONFIG.C0.DDR4_MemoryPart KSM26SES8_16HC_NOECC_1600}
  {CONFIG.C0.DDR4_MemoryType SODIMMs}
  {CONFIG.C0.DDR4_TimePeriod 1250}
  {CONFIG.C0.DDR4_isCustom true}
} {
  lassign $property_expected property expected
  require_equal $property [get_property $property $ddr] $expected
}

set custom_parts [file normalize [get_property CONFIG.C0.DDR4_CustomParts $ddr]]
puts "CHECK CONFIG.C0.DDR4_CustomParts=$custom_parts"
if {![string match "*/src/memory_parts/ksm26ses8_16hc_noecc.csv" $custom_parts]} {
  puts stderr "CHECK ERROR unexpected custom memory-parts file: $custom_parts"
  exit 3
}

require_equal OSC_SYS_CLK.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_intf_ports OSC_SYS_CLK]] 200000000
require_equal SOC_CLK.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_ports SOC_CLK]] 25000000
require_equal JTAG_AXI.ADDR_WIDTH [get_property CONFIG.M_AXI_ADDR_WIDTH [get_bd_cells jtag_axi_0]] 64
require_equal JTAG_AXI.DATA_WIDTH [get_property CONFIG.M_AXI_DATA_WIDTH [get_bd_cells jtag_axi_0]] 64

require_equal synth_strategy [get_property STRATEGY [get_runs synth_1]] "Flow_PerfOptimized_high"
require_equal impl_strategy [get_property STRATEGY [get_runs impl_1]] "Congestion_SSI_SpreadLogic_high"
set synth_hook [file normalize [get_property STEPS.SYNTH_DESIGN.TCL.PRE [get_runs synth_1]]]
puts "CHECK synth_hook=$synth_hook"
if {![string match "*/tools/limit_synth_threads.tcl" $synth_hook]} {
  puts stderr "CHECK ERROR unexpected synthesis thread hook: $synth_hook"
  exit 3
}

require_equal synth_status [get_property STATUS [get_runs synth_1]] "Not started"
require_equal impl_status [get_property STATUS [get_runs impl_1]] "Not started"
puts "CHECK RESULT=PASS"
close_project
exit 0
