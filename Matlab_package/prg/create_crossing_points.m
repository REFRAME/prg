function [ points ] = create_crossing_points( points,n_pos,n_neg )
% This is an internal function to create crossing points of the PRG curve
n = n_pos+n_neg;
points.is_crossing = repmat(0,height(points),1);
% introduce a crossing point at the crossing through the y-axis
j = min(find(points.recall_gain>=0));
if points.recall_gain(j)>0 % otherwise there is a point on the boundary and no need for a crossing point
    delta = points(1,:);
    delta(1,:) = num2cell(points{j,:}-points{j-1,:});
    if delta.TP>0
        alpha = (n_pos*n_pos/n-points.TP(j-1))/delta.TP;
    else
        alpha = 0.5;
    end
    new_point = points(j-1,:);
    new_point{1,:} = new_point{1,:}+alpha*delta{1,:};
    new_point.precision_gain = precision_gain(new_point.TP,new_point.FN,new_point.FP,new_point.TN);
    new_point.recall_gain = 0;
    new_point.is_crossing = 1;
    points = sortrows([ points; new_point ],[1,9]);
end
% now introduce crossing points at the crossings through the non-negative part of the x-axis
crossings = [];
x = points.recall_gain;
y = points.precision_gain;
f = find(([y;0].*[0;y]<0)&([1;x]>=0));
if length(f)>0
  for i = f
    cross_x = x(i-1)+(-y(i-1))/(y(i)-y(i-1))*(x(i)-x(i-1))
    delta = points(1,:);
    delta(1,:) = num2cell(points{i,:}-points{i-1,:});
    if (delta.TP>0)
        alpha = (n_pos*n_pos/(n-n_neg*cross_x)-points.TP(i-1))/delta.TP;
    else
        alpha = (n_neg/n_pos*points.TP(i-1)-points.FP(i-1))/delta.FP;
    end
    new_point = points(i-1,:);
    new_point{1,:} = new_point{1,:}+alpha*delta{1,:};
    new_point.precision_gain = 0;
    new_point.recall_gain = recall_gain(new_point.TP,new_point.FN,new_point.FP,new_point.TN);
    new_point.is_crossing = 1;
    crossings = [crossings; new_point];
  end
points = sortrows([points; crossings],[1,9]);
end
points.in_unit_square = repmat(1,height(points),1);
points.in_unit_square(points.recall_gain<0) = 0;
points.in_unit_square(points.precision_gain<0) = 0;
points = points(:,2:end);
end

