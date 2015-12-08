
# prg: R package for creating Precision-Recall-Gain curves and calculating area under the curve

### What are the Precision-Recall-Gain curves?

Please see http://www.cs.bris.ac.uk/~flach/PRGcurves/.

### Contents

This package provides the following 5 functions:
* `precision_gain(TP,FN,FP,TN)`
* `recall_gain(TP,FN,FP,TN)`
* `create_prg_curve(labels,pos_scores)`
* `calc_auprg(prg_curve)`
* `plot_prg(prg_curve)`

### Installation

This package can be installed from within your R session using the package `devtools`:
```R
> library(devtools)
> install_github('prg','meeliskull')
```

### Usage

Detailed information about the usage can be seen in the manual pages of the individual functions, e.g. by typing `?create_prg_curve`.
The example usage is as follows:
```R
> prg_curve = create_prg_curve(labels=c(1,1,0,0,1,0),pos_scores=c(0.8,0.8,0.6,0.4,0.4,0.2))
> auprg = calc_auprg(prg_curve)
> fig = plot_prg(prg_curve)
> print(prg_curve)
> print(auprg)
> print(fig)
```

### Authors

This package has been written by Meelis Kull, based on work by Peter Flach and Meelis Kull, see http://www.cs.bris.ac.uk/~flach/PRGcurves/.

