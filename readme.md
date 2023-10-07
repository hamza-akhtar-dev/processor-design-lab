# Guidelines

This repository will contain all the codes written in the coming processor design labs.

## Compilation

RTL can be compiled with the command: 

``` 
vlog names_of_all_system_verilog_files
```

or simply:

``` 
vlog *.sv 
```

Compilation creates a ``` work ``` folder in your current working directory in which all the files generated after compilation are stored.
 
## Simulation

The compiled RTL can be simulated with command:

``` 
vsim -c name_of_toplevel_module -do "run -all"
```

Simulation creates a ``` .vcd ``` file. This files contains all the simulation behaviour of design.

## Viewing the VCD Waveform File

To view the waveform of the design run the command:

```
gtkwave dumfile_name.vcd
```

This opens a waveform window. Pull the required signals in the waveform and verify the behaviour of the design.


