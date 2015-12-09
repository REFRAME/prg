function [ rec_gain ] = recall_gain(TP,FN,FP,TN)
% Calculates Recall Gain from the contingency table
%    This function calculates Recall Gain from the entries 
% of the contingency table: number of true positives (TP), false negatives 
% (FN), false positives (FP), and true negatives (TN). More information on 
% Precision-Recall-Gain curves and how to cite this work is available at 
% http://www.cs.bris.ac.uk/~flach/PRGcurves/.
n_pos = TP+FN;
n_neg = FP+TN;
rec_gain = 1-(n_pos.*FN)./(n_neg.*TP);
rec_gain(TN+FN==0) = 1;
end
