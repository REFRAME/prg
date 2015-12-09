
# prg: R package for creating Precision-Recall-Gain curves and calculating area under the curve

### What are the Precision-Recall-Gain curves?

Please see http://www.cs.bris.ac.uk/~flach/PRGcurves/.

### Contents

This package provides the following 6 functions:
* `precision_gain(TP,FN,FP,TN)`
* `recall_gain(TP,FN,FP,TN)`
* `create_prg_curve(labels,pos_scores)`
* `calc_auprg(prg_curve)`
* `prg_convex_hull(prg_curve)`
* `plot_prg(prg_curve)`

### Installation

This package can be installed from within your R session using the package `devtools`:
```R
install.packages("devtools")  # necessary only if devtools are not installed
library(devtools)
install_github('meeliskull/prg/R_package/prg')
```

### Usage

Detailed information about the usage can be seen in the manual pages of the individual functions, e.g. by typing `?create_prg_curve`.
The example usage is as follows:
```R
library(prg)
labels = c(1,1,1,0,1,1,1,1,1,1,0,1,1,1,0,1,0,0,1,0,0,0,1,0,1)
scores = (25:1)/25
prg_curve = create_prg_curve(labels,scores)
auprg = calc_auprg(prg_curve)
convex_hull = prg_convex_hull(prg_curve)
fig = plot_prg(prg_curve)
print(prg_curve)
print(auprg)
print(convex_hull)
print(fig)
```

### Authors

This package has been written by Meelis Kull, based on work by Peter Flach and Meelis Kull, see http://www.cs.bris.ac.uk/~flach/PRGcurves/.

