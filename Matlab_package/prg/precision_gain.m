function [ prec_gain ] = precision_gain(TP,FN,FP,TN)
% Calculates Precision Gain from the contingency table
%    This function calculates Precision Gain from the entries 
% of the contingency table: number of true positives (TP), false negatives 
% (FN), false positives (FP), and true negatives (TN). More information on 
% Precision-Recall-Gain curves and how to cite this work is available at 
% http://www.cs.bris.ac.uk/~flach/PRGcurves/.
n_pos = TP+FN;
n_neg = FP+TN;
prec_gain = 1-(n_pos.*FP)./(n_neg.*TP);
prec_gain(TN+FN==0) = 0;
end
