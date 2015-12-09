
# prg: Matlab package for creating Precision-Recall-Gain curves and calculating area under the curve

### What are the Precision-Recall-Gain curves?

Please see http://www.cs.bris.ac.uk/~flach/PRGcurves/.

### Contents

This package provides an example script and the following 5 functions:
* `precision_gain(TP,FN,FP,TN)`
* `recall_gain(TP,FN,FP,TN)`
* `create_prg_curve(labels,pos_scores)`
* `calc_auprg(prg_curve)`
* `plot_prg(prg_curve)`

### Installation

This package can be used by copying the files to your computer:
```sh
svn checkout https://github.com/meeliskull/prg/trunk/Matlab_package/prg
```

### Usage

The example usage in Matlab is as follows:
```Matlab
%% Creating the PRG-curve
prg_curve = create_prg_curve([1 1 0 0 1 0],[0.8 0.8 0.6 0.4 0.4 0.2])
%% Calculating area under the PRG-curve
auprg = calc_auprg(prg_curve)
%% Plotting the PRG-curve
plot_prg(prg_curve)
```

### Authors

This package has been written by Meelis Kull, based on work by Peter Flach and Meelis Kull, see http://www.cs.bris.ac.uk/~flach/PRGcurves/.

