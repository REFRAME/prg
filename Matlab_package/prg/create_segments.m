function [ segments ] = create_segments(labels,pos_scores,neg_scores)
% This is an internal function to create segments of the PRG curve
labels = reshape(labels,[],1);
pos_scores = reshape(pos_scores,[],1);
neg_scores = reshape(neg_scores,[],1);
t = sortrows(table(pos_scores,neg_scores,labels),[-1,2]);
j = 0;
counts = [];
for i = 1:length(t.labels)
   if (i==1)||(t.pos_scores(i-1)~=t.pos_scores(i))||(t.neg_scores(i-1)~=t.neg_scores(i))
       j = j+1;
       new_pos_scores(j) = t.pos_scores(i);
       new_neg_scores(j) = t.neg_scores(i);
       counts(j,1:2) = 0;
   end  
   counts(j,2-t.labels(i)) = counts(j,2-t.labels(i)) + 1;
end
pos_scores = new_pos_scores';
neg_scores = new_neg_scores';
pos_counts = counts(:,1);
neg_counts = counts(:,2);
segments = table(pos_scores,neg_scores,pos_counts,neg_counts);
end

