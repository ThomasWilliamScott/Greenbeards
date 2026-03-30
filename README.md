# Greenbeards
This repository contains all supplementary code for the submitted manuscript "No clear support for greenbeard genes".

The "Run_Model.m" Matlab script in this repository implements our full population genetic model. Within this script, users are asked to specify numerical values for each parameter in our model. Running the script then takes these parameter values, and through a process of numerical iteration, calculates the equilibrium genotype frequencies associated with these parameter values. 

The .mat files in this repository comprise different saved outputs of the "Run_Model.m" script, each generated from different parameter values. The results stored in these .mat files can be visualised in heatmap form by loading a particular .mat file in the Matlab workspace, then running the "Generate_Heatmaps.m" Matlab script.

The .mat files beginning "Fig2" comprise the data used to generate Figure 2 in the main text. The .mat files beginning "Fig_3a" comprise the data used to generate Figure 3a in the main text. 

The Mathematica script "Generate_Fig3b.nb" generates Figure 3b in the main text. It does so by plotting analytically derived greenbeard stability conditions derived in Equations 5 and 6 of the Supplementary Information.
