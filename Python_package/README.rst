pyprg: Python package for creating Precision-Recall-Gain curves and calculating area under the curve
====================================================================================================

What are the Precision-Recall-Gain curves?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Please see http://www.cs.bris.ac.uk/~flach/PRGcurves/.

Contents
~~~~~~~~

This package provides the following 6 functions:

::

    precision_gain(TP,FN,FP,TN)
    recall_gain(TP,FN,FP,TN)
    create_prg_curve(labels,pos_scores)
    calc_auprg(prg_curve)
    prg_convex_hull(prg_curve)
    plot_prg(prg_curve)

Installation
~~~~~~~~~~~~

This package can be installed using ``pip`` from command line:

::

    pip install pyprg

Usage
~~~~~

Detailed information about the usage can be seen in the manual pages of
the individual functions, e.g. by typing ``?prg.create_prg_curve`` after
importing with ``from prg import prg``. The example usage is as follows:

.. code:: python

    from prg import prg
    import numpy as np
    labels = np.array([1,1,1,0,1,1,1,1,1,1,0,1,1,1,0,1,0,0,1,0,0,0,1,0,1], dtype='int')
    scores = np.arange(1,26)[::-1]
    prg_curve = prg.create_prg_curve(labels, scores, create_crossing_points=True)
    auprg = prg.calc_auprg(prg_curve)
    print(auprg)
    prg.plot_prg(prg_curve)

Authors
~~~~~~~

This package has been written by Meelis Kull, Telmo de Menezes e Silva
Filho, Miquel Perello Nieto, based on work by Peter Flach and Meelis
Kull, see http://www.cs.bris.ac.uk/~flach/PRGcurves/.
