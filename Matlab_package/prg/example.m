%% Precision-Recall-Gain curves
% This example demonstrates how to create and plot Precision-Recall-Gain 
% curves and how to calculate area under the curve. More information on 
% Precision-Recall-Gain curves and how to cite this work is available at 
% http://www.cs.bris.ac.uk/~flach/PRGcurves/.

%% Creating data

labels = [1 1 1 0 1 1 1 1 1 1 0 1 1 1 0 1 0 0 1 0 0 0 1 0 1]
scores = 1-(1:25)/25

%% Creating the PRG-curve

prg_curve = create_prg_curve(labels,scores)

%% Calculating area under the PRG-curve

auprg = calc_auprg(prg_curve)

%% Plotting the PRG-curve

plot_prg(prg_curve)


