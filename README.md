# Light-Field-Simulation

# Installation
Run the manuscript AddToolboxPath.m in folder MyPlenopticTool.

# Demo
There are two demos for simulation of plenoptic cameras(focused and unfocused).

Run RunSimulateLytroImage.m  to simulate the imaging process of Lytro.

Run RunSimulateRaytrixImage.m to simulate the imaging process of Raytrix.

# Simulated Image  Size
You can change the simulated image size in Line 48 and 49 of RunSimulateRaytrixImage.m.

`
InfoBag.pixelY              = 70;
InfoBag.pixelX              = 70;
`

You can also change the simulated image size in Line 76 and 77 of RunSimulateLytroImage.m.

`
    InfoBag.pixelY              = 100; 
    InfoBag.pixelX              = 100; 
`
