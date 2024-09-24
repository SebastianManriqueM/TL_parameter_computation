# CALCULATION OF TRANSMISSION LINE PARAMETERS - julia_start

This repository basic julia scripts for calculating transmission line parameters according to transmission line geometry, conductors and ground wires.

## To Do Datasets
- [ ] Include EHS Ground wires
- [ ] Include Transmission line Geometries of 230kV ans 138kV
- [ ] Include Transmission line data above 345kV, and update states of TL_Geometry dataset
- [ ] Conductors ACSS, ACSS_TW, ACSR/AW, ACSR/TW

## To Do Conductors filters
- [ ] Get typical conductor based on transmission line dataset
- [ ] Get conductor based on type and nearest kcmil in case it doesn't find the exact kcmil provided by the user.


## To Do TL Power Capacity - conductor
- [ ] Based on Line Voltage, distance, and conductor, estimate S_rated.
- [ ] Based on Line Voltage, distance, and S_rated, select conductors. 

## To Do Handle with Units
- [ ] PU calculations. Include Base power, etc.
- [ ] Include Capability for handle different units. For now miles, Ohm/kft, inch, 

## To Do general functionalities
- [ ] Add calculatios for TL capacitance
- [ ] Add GET CONDUCTOR/GROUND WIRE TYPICAL based on dataset
- [ ] Add user defined geometry capability
- [ ] Add Docstrings for documentation
