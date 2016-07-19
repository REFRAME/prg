function [] = plot_prg( prg_curve )
%Plot the Precision-Recall-Gain curve
%   This function plots the Precision-Recall-Gain curve resulting from the 
% function create_prg_curve using ggplot. More information on 
% Precision-Recall-Gain curves and how to cite this work is available at 
% http://www.cs.bris.ac.uk/~flach/PRGcurves/.
plot(prg_curve.recall_gain,prg_curve.precision_gain,'o-');
xlim([0,1]);
ylim([0,1]);
end

