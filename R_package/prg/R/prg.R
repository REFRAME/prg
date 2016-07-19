
library(ggplot2)
library(grid)

#' Precision Gain
#'
#' This function calculates Precision Gain from the entries of the contingency table: number of true positives (TP), false negatives (FN), false positives (FP), and true negatives (TN). More information on Precision-Recall-Gain curves and how to cite this work is available at http://www.cs.bris.ac.uk/~flach/PRGcurves/.
#' @param TP number of true positives, can be a vector
#' @param FN number of false negatives, can be a vector
#' @param FP number of false positives, can be a vector
#' @param TN number of true negatives, can be a vector
#' @return Precision Gain (a numeric value less than or equal to 1; or -Inf or NaN, see the details below)
#' @details Precision Gain (PrecGain) quantifies by how much precision is improved over the default precision of the always positive predictor, equal to the proportion of positives (pi). PrecGain=1 stands for maximal improvement (Prec=1) and PrecGain=0 stands for no improvement (Prec=pi). If Prec=0, then PrecGain=-Inf. It can happen that PrecGain=NaN, for instance if there are no positives (TP=0 and FN=0) and TN>0.
#' @examples 
#' precision_gain(3,0,1,2)
#' # [1] 0.6666667
#' TP = c(0,2,3)
#' FN = 3-TP
#' FP = c(0,1,2)
#' TN = 2-FP
#' precision_gain(TP,FN,FP,TN)
#' # [1]  NaN 0.25 0.00
precision_gain = function(TP,FN,FP,TN) {
  n_pos = TP+FN
  n_neg = FP+TN
  prec_gain = 1-(n_pos*FP)/(n_neg*TP)
  prec_gain[TN+FN==0] = 0
  return(prec_gain)
}

#' Recall Gain
#'
#' This function calculates Recall Gain from the entries of the contingency table: number of true positives (TP), false negatives (FN), false positives (FP), and true negatives (TN). More information on Precision-Recall-Gain curves and how to cite this work is available at http://www.cs.bris.ac.uk/~flach/PRGcurves/.
#' @param TP number of true positives, can be a vector
#' @param FN number of false negatives, can be a vector
#' @param FP number of false positives, can be a vector
#' @param TN number of true negatives, can be a vector
#' @return Recall Gain (a numeric value less than or equal to 1; or -Inf or NaN, see the details below)
#' @details Recall Gain (RecGain) quantifies by how much recall is improved over the recall equal to the proportion of positives (pi). RecGain=1 stands for maximal improvement (Rec=1) and RecGain=0 stands for no improvement (Rec=pi). If Rec=0, then RecGain=-Inf. It can happen that RecGain=NaN, for instance if there are no negatives (FP=0 and TN=0) and FN>0 and TP=0.
#' @examples 
#' recall_gain(3,0,1,2)
#' # [1] 1
#' TP = c(0,2,3)
#' FN = 3-TP
#' FP = c(0,1,2)
#' TN = 2-FP
#' recall_gain(TP,FN,FP,TN)
#' # [1]  -Inf 0.25 1.00
recall_gain = function(TP,FN,FP,TN) {
  n_pos = TP+FN
  n_neg = FP+TN
  rg = 1-(n_pos*FN)/(n_neg*TP)
  rg[TN+FN==0] = 1
  return(rg)
}

# create a table of segments
.create.segments = function(labels,pos_scores,neg_scores) {
  # reorder labels and pos_scores by decreasing pos_scores, using increasing neg_scores in breaking ties
  new_order = order(pos_scores,-neg_scores,decreasing=TRUE)
  labels = labels[new_order]
  pos_scores = pos_scores[new_order]
  neg_scores = neg_scores[new_order]
  # create a table of segments
  segments = data.frame(pos_score=NA,neg_score=NA,pos_count=0,neg_count=rep(0,length(labels)))
  j = 0
  for (i in seq_along(labels)) {
    if ((i==1)||(pos_scores[i-1]!=pos_scores[i])||(neg_scores[i-1]!=neg_scores[i])) {
      j = j + 1
      segments$pos_score[j] = pos_scores[i]
      segments$neg_score[j] = neg_scores[i]
    }
    segments[j,4-labels[i]] = segments[j,4-labels[i]] + 1
  }
  segments = segments[1:j,]
  return(segments)
}

.create.crossing.points = function(points,n_pos,n_neg) {
  n = n_pos+n_neg
  points$is_crossing = 0
  # introduce a crossing point at the crossing through the y-axis
  j = min(which(points$recall_gain>=0))
  if (points$recall_gain[j]>0) { # otherwise there is a point on the boundary and no need for a crossing point
    delta = points[j,,drop=FALSE]-points[j-1,,drop=FALSE]
    if (delta$TP>0) {
      alpha = (n_pos*n_pos/n-points$TP[j-1])/delta$TP
    } else {
      alpha = 0.5
    }
    new_point = points[j-1,,drop=FALSE] + alpha*delta
    new_point$precision_gain = precision_gain(new_point$TP,new_point$FN,new_point$FP,new_point$TN)
    new_point$recall_gain = 0
    new_point$is_crossing = 1
    points = rbind(points,new_point)
    points = points[order(points$index),,drop=FALSE]
  }   
  # now introduce crossing points at the crossings through the non-negative part of the x-axis
  crossings = data.frame()
  x = points$recall_gain
  y = points$precision_gain
  for (i in which((c(y,0)*c(0,y)<0)&(c(1,x)>=0))) {
    cross_x = x[i-1]+(-y[i-1])/(y[i]-y[i-1])*(x[i]-x[i-1])
    delta = points[i,,drop=FALSE]-points[i-1,,drop=FALSE]
    if (delta$TP>0) {
      alpha = (n_pos*n_pos/(n-n_neg*cross_x)-points$TP[i-1])/delta$TP
    } else {
      alpha = (n_neg/n_pos*points$TP[i-1]-points$FP[i-1])/delta$FP
    }
    new_point = points[i-1,,drop=FALSE] + alpha*delta
    new_point$precision_gain = 0
    new_point$recall_gain = recall_gain(new_point$TP,new_point$FN,new_point$FP,new_point$TN)
    new_point$is_crossing = 1
    crossings = rbind(crossings,new_point)
  }
  # add crossing points to the 'points' data frame
  points = rbind(points,crossings)
  points = points[order(points$index,points$recall_gain),2:ncol(points),drop=FALSE]
  rownames(points) = NULL
  points$in_unit_square = 1
  points$in_unit_square[points$recall_gain<0] = 0
  points$in_unit_square[points$precision_gain<0] = 0
  return(points)
}


#' Precision-Recall-Gain curve
#'
#' This function creates the Precision-Recall-Gain curve from the vector of labels and vector of scores where higher score indicates a higher probability to be positive. More information on Precision-Recall-Gain curves and how to cite this work is available at http://www.cs.bris.ac.uk/~flach/PRGcurves/.
#' @param labels a vector of labels, where 1 marks positives and 0 or -1 marks negatives
#' @param pos_scores vector of scores for the positive class, where a higher score indicates a higher probability to be a positive
#' @param neg_scores vector of scores for the negative class, where a higher score indicates a higher probability to be a negative (by default, equal to -pos_scores)
#' @param create_crossing_points whether to create crossing points where the curve crosses the x-axis or y-axis
#' @return A data.frame which lists the points on the PRG curve with the following columns: pos_score, neg_score, TP, FP, FN, TN, precision_gain, recall_gain. Optionally, if create_crossing_points=TRUE, then there are two more columns: is_crossing and in_unit_square. All the points are listed in the order of increasing thresholds on the score to be positive (the ties are broken by decreasing thresholds on the score to be negative).
#' @details The PRG-curve is built by considering all possible score thresholds, starting from -Inf and then using all scores that are present in the given data. The results are presented as a data.frame which includes the following columns: pos_score, neg_score, TP, FP, FN, TN, precision_gain, recall_gain. Optionally, if create_crossing_points=TRUE, then there are two more columns: is_crossing and in_unit_square. If create_crossing_points=TRUE, then the resulting points additionally include the points where the PRG curve crosses the y-axis and the positive half of the x-axis. The added points have is_crossing=1 whereas the actual PRG points have is_crossing=0. To help in visualisation and calculation of the area under the curve the value in_unit_square=1 marks that the point is within the unit square [0,1]x[0,1], and otherwise, in_unit_square=0.
#' @examples
#' create_prg_curve(c(1,1,0,0,1,0),c(0.8,0.8,0.6,0.4,0.4,0.2))
#' #   pos_score neg_score  TP FP  FN TN precision_gain recall_gain is_crossing in_unit_square
#' # 1      -Inf       Inf 0.0  0 3.0  3            NaN        -Inf           0              0
#' # 2       NaN       NaN 1.5  0 1.5  3      1.0000000         0.0           1              1
#' # 3       0.8      -0.8 2.0  0 1.0  3      1.0000000         0.5           0              1
#' # 4       0.6      -0.6 2.0  1 1.0  2      0.5000000         0.5           0              1
#' # 5       0.4      -0.4 3.0  2 0.0  1      0.3333333         1.0           0              1
#' # 6       0.2      -0.2 3.0  3 0.0  0      0.0000000         1.0           0              1
#'
#' create_prg_curve(c(1,1,0,0,1,0),c(0.8,0.8,0.6,0.4,0.4,0.2),create_crossing_points=FALSE)
#' #   pos_score neg_score TP FP FN TN precision_gain recall_gain
#' # 1      -Inf       Inf  0  0  3  3            NaN        -Inf
#' # 2       0.8      -0.8  2  0  1  3      1.0000000         0.5
#' # 3       0.6      -0.6  2  1  1  2      0.5000000         0.5
#' # 4       0.4      -0.4  3  2  0  1      0.3333333         1.0
#' # 5       0.2      -0.2  3  3  0  0      0.0000000         1.0
#'
#' create_prg_curve(c(1,1,0,0,1,0),c(1,1,1,1e-20,1e-40,1e-60),c(0,1e-20,1e-20,1,1,1))
#' #   pos_score neg_score  TP  FP  FN  TN precision_gain recall_gain is_crossing in_unit_square
#' # 1      -Inf       Inf 0.0 0.0 3.0 3.0            NaN        -Inf           0              0
#' # 2     1e+00     0e+00 1.0 0.0 2.0 3.0      1.0000000        -1.0           0              0
#' # 3     1e+00     5e-21 1.5 0.5 1.5 2.5      0.6666667         0.0           1              1
#' # 4     1e+00     1e-20 2.0 1.0 1.0 2.0      0.5000000         0.5           0              1
#' # 5     1e-20     1e+00 2.0 2.0 1.0 1.0      0.0000000         0.5           0              1
#' # 6     1e-40     1e+00 3.0 2.0 0.0 1.0      0.3333333         1.0           0              1
#' # 7     1e-60     1e+00 3.0 3.0 0.0 0.0      0.0000000         1.0           0              1
create_prg_curve = function(labels,pos_scores,neg_scores=-pos_scores,create_crossing_points=TRUE) {
  n = length(labels)
  n_pos = sum(labels)
  n_neg = n - n_pos
  # convert negative labels into 0s
  labels = 1*(labels==1) 
  segments = .create.segments(labels,pos_scores,neg_scores)
  # calculate recall gains and precision gains for all thresholds
  points = data.frame(index=1:(1+nrow(segments)))
  points$pos_score=c(Inf,segments$pos_score)
  points$neg_score=c(-Inf,segments$neg_score)
  points$TP = c(0,cumsum(segments$pos_count))
  points$FP = c(0,cumsum(segments$neg_count))
  points$FN = n_pos-points$TP
  points$TN = n_neg-points$FP
  points$precision_gain = precision_gain(points$TP,points$FN,points$FP,points$TN)
  points$recall_gain = recall_gain(points$TP,points$FN,points$FP,points$TN)
  if (create_crossing_points) {
    points = .create.crossing.points(points,n_pos,n_neg)
  } else {
    points = points[,2:ncol(points)]
  }
  return(points)
}

#' Calculate area under the Precision-Recall-Gain curve
#'
#' This function calculates the area under the Precision-Recall-Gain curve from the results of the function create_prg_curve. More information on Precision-Recall-Gain curves and how to cite this work is available at http://www.cs.bris.ac.uk/~flach/PRGcurves/. 
#' @param prg_curve the data structure resulting from the function create_prg_curve
#' @return A numeric value representing the area under the Precision-Recall-Gain curve.
#' @details This function calculates the area under the Precision-Recall-Gain curve, taking into account only the part of the curve with non-negative recall gain. The regions with negative precision gain (PRG-curve under the x-axis) contribute as negative area.
#' @examples
#' calc_auprg(create_prg_curve(c(1,1,0,0,1,0),c(0.8,0.8,0.6,0.4,0.4,0.2)))
#' # [1] 0.7083333
calc_auprg = function(prg_curve) {
  area = 0
  for (i in 2:nrow(prg_curve)) {
    if (!is.na(prg_curve$recall_gain[i-1]) && (prg_curve$recall_gain[i-1]>=0)) {
      width = prg_curve$recall_gain[i]-prg_curve$recall_gain[i-1]
      height = (prg_curve$precision_gain[i]+prg_curve$precision_gain[i-1])/2
      area = area + width*height
    }
  }
  return(area)
}

#' Create the convex hull of the Precision-Recall-Gain curve
#'
#' This function creates the convex hull of the Precision-Recall-Gain curve resulting from the function create_prg_curve and calculates the F-calibrated scores. More information on Precision-Recall-Gain curves and how to cite this work is available at http://www.cs.bris.ac.uk/~flach/PRGcurves/.
#' @param prg_curve the data structure resulting from the function create_prg_curve
#' @return the data.frame representing the convex hull
#' @examples
#' labels = c(1,1,1,0,1,1,1,1,1,1,0,1,1,1,0,1,0,0,1,0,0,0,1,0,1)
#' scores = (25:1)/25
#' prg_convex_hull(create_prg_curve(labels,scores))
prg_convex_hull = function(prg_curve) {
  y = prg_curve$precision_gain
  x = prg_curve$recall_gain
  m = length(x)
  y[is.na(x)] = NA
  y_peak = max(which(y==max(y,na.rm=TRUE)),na.rm=TRUE)
  ch = !is.na(y) & ((1:m)>=y_peak)
  ch[(c(Inf,x[1:(m-1)])==x)] = 0
  chi = which(ch==1)
  while (length(chi)>=3) {
    changed = FALSE
    for (i in 3:length(chi)) {
      s1 = (y[chi[i-1]]-y[chi[i-2]]) / (x[chi[i-1]]-x[chi[i-2]])
      s2 = (y[chi[i]]-y[chi[i-1]]) / (x[chi[i]]-x[chi[i-1]])
      if (s1<=1.00001*s2) {
        chi = chi[-(i-1)]
	changed = TRUE
	break
      }
    }
    if (!changed) {
      break
    }
  }
  convex_hull = prg_curve[chi,c("pos_score","neg_score","precision_gain","recall_gain")]
  convex_hull = rbind(c(Inf,-Inf,y[y_peak],-Inf),convex_hull)
  y = convex_hull$precision_gain
  x = convex_hull$recall_gain
  slopes = (c(0,y)-c(y,0))/(c(0,x)-c(x,0))
  convex_hull$f_calibrated_score = 1/(1-slopes[1:nrow(convex_hull)])
  return(convex_hull)
}

#' Plot the Precision-Recall-Gain curve
#'
#' This function plots the Precision-Recall-Gain curve resulting from the function create_prg_curve using ggplot. More information on Precision-Recall-Gain curves and how to cite this work is available at http://www.cs.bris.ac.uk/~flach/PRGcurves/.
#' @param prg_curve the data structure resulting from the function create_prg_curve
#' @param show_convex_hull whether to show the convex hull (default: TRUE)
#' @param show_f_calibrated_scores whether to show the F-calibrated scores (default:TRUE)
#' @return the ggplot object which can be plotted using print()
#' @details This function plots the Precision-Recall-Gain curve, indicating for each point whether it is a crossing-point or not (see help on create_prg_curve). By default, only the part of the curve within the unit square [0,1]x[0,1] is plotted.
#' @examples
#' labels = c(1,1,1,0,1,1,1,1,1,1,0,1,1,1,0,1,0,0,1,0,0,0,1,0,1)
#' scores = (25:1)/25
#' plot_prg(create_prg_curve(labels,scores))
plot_prg = function(prg_curve,show_convex_hull=TRUE,show_f_calibrated_scores=TRUE) {
  d = prg_curve
  d = d[(!is.na(d$precision_gain))&(!is.na(d$recall_gain)),]
  d2 = d
  d2$precision_gain[d2$in_unit_square==0] = NA
  d3 = d[(d$is_crossing==0)&(d$in_unit_square==1),]
  p = ggplot2::ggplot(d)
  p = p + ggplot2::geom_segment(x=-0.015,xend=1,y=0.00,yend=0.00,color="grey",size=0.1)
  p = p + ggplot2::geom_segment(x=-0.015,xend=1,y=0.25,yend=0.25,color="grey",size=0.1)
  p = p + ggplot2::geom_segment(x=-0.015,xend=1,y=0.50,yend=0.50,color="grey",size=0.1)
  p = p + ggplot2::geom_segment(x=-0.015,xend=1,y=0.75,yend=0.75,color="grey",size=0.1)
  p = p + ggplot2::geom_segment(x=-0.015,xend=1,y=1.00,yend=1.00,color="grey",size=0.1)
  p = p + ggplot2::geom_segment(y=-0.015,yend=1,x=0.00,xend=0.00,color="grey",size=0.1)
  p = p + ggplot2::geom_segment(y=-0.015,yend=1,x=0.25,xend=0.25,color="grey",size=0.1)
  p = p + ggplot2::geom_segment(y=-0.015,yend=1,x=0.50,xend=0.50,color="grey",size=0.1)
  p = p + ggplot2::geom_segment(y=-0.015,yend=1,x=0.75,xend=0.75,color="grey",size=0.1)
  p = p + ggplot2::geom_segment(y=-0.015,yend=1,x=1.00,xend=1.00,color="grey",size=0.1)
  p = p + ggplot2::geom_rect(xmin=0,xmax=1,ymin=0,ymax=1,fill="transparent",color="black",size=0.3)
  p = p + ggplot2::geom_line(ggplot2::aes(x=recall_gain,y=precision_gain),color="lightblue",size=1.5)
  p = p + ggplot2::geom_line(data=d2,ggplot2::aes(x=recall_gain,y=precision_gain),color="blue",size=1.5,na.rm=TRUE)
  p = p + ggplot2::geom_point(data=d3,ggplot2::aes(x=recall_gain,y=precision_gain),color="blue",size=3)
  p = p + ggplot2::xlab("Recall Gain")
  p = p + ggplot2::ylab("Precision Gain")
  p = p + ggplot2::coord_cartesian(xlim=c(-0.015,1.015),ylim=c(-0.015,1.015))
  p = p + ggplot2::theme_bw()
  p = p + ggplot2::theme(
    panel.border = ggplot2::element_blank(),
    panel.grid.major = ggplot2::element_blank(),
    panel.grid.minor = ggplot2::element_blank(),
    axis.ticks.margin = grid::unit(-0.1,"lines"),
    axis.ticks = ggplot2::element_blank()
    )
  convex_hull = prg_convex_hull(prg_curve)
  if (show_convex_hull) {
    p = p + ggplot2::geom_line(data=convex_hull,ggplot2::aes(x=recall_gain,y=precision_gain),color="red",linetype=2)
  }
  if (show_f_calibrated_scores) {
    y = convex_hull$precision_gain
    x = convex_hull$recall_gain
    convex_hull$ya = 0.5*(y+c(0,y[1:(length(y)-1)]))
    convex_hull$xa = 0.5*(x+c(0,x[1:(length(x)-1)]))
    if (nrow(convex_hull)>=3) {
      p = p + ggplot2::geom_text(data=convex_hull[3:nrow(convex_hull),],ggplot2::aes(x=xa,y=ya,label=round(f_calibrated_score,2)),color="red",hjust=0,vjust=0)
    }
  }
  return(p)
}

.test = function() {
  dir.create("prg_r_test_fig_auto",showWarnings=FALSE)
  dir.create("prg_r_test_fig_unit",showWarnings=FALSE)
  dir.create("prg_r_test_tab",showWarnings=FALSE)
  dir.create("prg_r_test_auprg",showWarnings=FALSE)
  test_labels = c("0","1","00","01","10","11","001","010","011","100","101","110","0001","0010","0011","0100","0101","0110","0111","1000","1001","1010","1011","1100","1101","1110","01100","0011000","010110100101","000010101100101","1111110010101100101") 
  for (i in seq_along(test_labels)) {
    labels = as.numeric(strsplit(test_labels[i],"")[[1]])
    pos_scores = rev(1:length(labels))
    prg_curve = create_prg_curve(labels,pos_scores)
    p = plot_prg(prg_curve,xlim=c(-0.6,1.1),ylim=c(-0.6,1.1))
    ggplot2::ggsave(paste("prg_r_test_fig_auto/prg_r_test_",i,".pdf",sep=""),p)
    p = plot_prg(prg_curve)
    ggplot2::ggsave(paste("prg_r_test_fig_unit/prg_r_test_",i,".pdf",sep=""),p)
    prg_curve = round(prg_curve,5)
    auprg = round(calc_auprg(prg_curve),5)
    write.csv(prg_curve,file=paste("prg_r_test_tab/prg_r_test_",i,".csv",sep=""),row.names=FALSE)
    write.csv(data.frame(auprg=auprg),file=paste("prg_r_test_auprg/prg_r_test_",i,".csv",sep=""),row.names=FALSE)
  }
}

#.test()

