set synth_threads 2
if {[info exists ::env(VIVADO_SYNTH_THREADS)] && [string trim $::env(VIVADO_SYNTH_THREADS)] ne ""} {
  set requested [string trim $::env(VIVADO_SYNTH_THREADS)]
  if {![string is integer -strict $requested] || $requested < 1} {
    error "VIVADO_SYNTH_THREADS must be a positive integer, got '$requested'"
  }
  set synth_threads $requested
}

set_param general.maxThreads $synth_threads
puts "INFO: synthesis pre-hook set general.maxThreads=$synth_threads"
