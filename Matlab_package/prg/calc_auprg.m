function [ area ] = calc_auprg( prg_curve )
%Calculate area under the Precision-Recall-Gain curve
%   This function calculates the area under the Precision-Recall-Gain curve 
% from the results of the function create_prg_curve. More information on 
% Precision-Recall-Gain curves and how to cite this work is available at 
% http://www.cs.bris.ac.uk/~flach/PRGcurves/.
area = 0;
for i = 2:height(prg_curve)
    if (~isnan(prg_curve.recall_gain(i-1)) && (prg_curve.recall_gain(i-1)>=0))
        wid = prg_curve.recall_gain(i)-prg_curve.recall_gain(i-1);
        hei = (prg_curve.precision_gain(i)+prg_curve.precision_gain(i-1))/2;
        area = area + wid*hei;
    end
end
end

