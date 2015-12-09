function [ prg_curve ] = create_prg_curve( labels,pos_scores,neg_scores,make_crossing_points )
% This function creates the Precision-Recall-Gain curve from the vector of 
% labels and vector of scores where higher score indicates a higher 
% probability to be positive.
%   More information on Precision-Recall-Gain curves and how to cite this 
%   work is available at http://www.cs.bris.ac.uk/~flach/PRGcurves/.
if nargin<4
    make_crossing_points = true;
    if nargin<3
        neg_scores = -pos_scores;
    end
end
labels = reshape(labels,1,[]);
pos_scores = reshape(pos_scores,1,[]);
neg_scores = reshape(neg_scores,1,[]);
n = length(labels);
n_pos = sum(labels);
n_neg = n - n_pos;
% convert negative labels into 0s
labels = labels==1;
segments = create_segments(labels,pos_scores,neg_scores);
% calculate recall gains and precision gains for all thresholds
index = (1:(height(segments)+1))';
prg_curve = table(index);
prg_curve.pos_scores = [ -Inf ; segments.pos_scores ];
prg_curve.neg_scores = [ Inf ; segments.neg_scores ];
prg_curve.TP = [ 0 ; cumsum(segments.pos_counts) ];
prg_curve.FP = [ 0 ; cumsum(segments.neg_counts) ];
prg_curve.FN = n_pos - prg_curve.TP;
prg_curve.TN = n_neg - prg_curve.FP;
prg_curve.precision_gain = precision_gain(prg_curve.TP,prg_curve.FN,prg_curve.FP,prg_curve.TN);
prg_curve.recall_gain = recall_gain(prg_curve.TP,prg_curve.FN,prg_curve.FP,prg_curve.TN);
if make_crossing_points
    prg_curve = create_crossing_points(prg_curve,n_pos,n_neg);
else
    prg_curve = prg_curve(:,2:end);
end
