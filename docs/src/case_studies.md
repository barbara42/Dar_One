# Beginner Tutorial 

todo: copy beginner tutorial readme over? 

# Case Study A - Bottle Experiment 

A simple nutrient amendment experiment. 

In this experiment, DAR1 is initialized with values from a global DARWIN run, provided HERE [link]. Initial parameter values were X=203 and Y=108 (lon = 203.5, lat = 28.5). In the control run, nothing was modified. For the bottle experiment run, nitrate values were increased 10x. 

The initial parameters that were set include all nutrient tracers (TRAC01-TRAC20), all biomass tracers excluding diazotrophs (TRAC21-TRAC29, TRAC35-TRAC70), PAR at a depth of 45m, and temperature. It was set to run for 7 days (56 iterations), writing to diagnostic files every 4 hours (14400 seconds).

You can find the code HERE [link]. 


# Case Study B 

Grid experiment 

See the grid section of the documentation [TODO link] to learn the details of how to run DAR1 in parallel. 

The yearly averages from a global DARWIN run were used to initialize a grid of DAR1s. The 360 x 160 matrix was divided in 16 parts, each 90 x 40. After running, the 16 tiles were stitched together again. 

The simulation was run for 10 years (XXX iterations), with diagnostics being written every XXX years. The final "steady state" values were calculated by averaging the last 2 years. 

Code to run the grid og DAR1s can be found here [LINK], and here [LINK] is the code for stitching the files together. Here [todo LINK] is the ipython notebook for calculating the Bray-Curtis Dissimilarity index between the yearly averages of the global DARWIN run and the steady state DAR1 runs. 

