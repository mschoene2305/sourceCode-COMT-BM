# sourceCode-COMT-BM
Here you can download the source code of the paper "Curvature-Oriented Splitting for Multivariate Model Trees"

Due to the availability of existing functions to construct the models for benchmarking, we use different environments for the experimental analysis.
The main part is performed in Matlab, in which COMT, LSRT and CART are estimated by custom implemented functions, and M5' by the toolbox M5PrimeLab.
The toolbox M5PrimeLab is available at http://www.cs.rtu.lv/jekabsons/regression.html.
GUIDE is estimated through a compiled Windows binary, which is available at http://pages.stat.wisc.edu/~loh/guide.html, and imported into Matlab by a custom implemented function.
In contrast, the estimation and application of MARS is performed in RStudio using the earth package (https://cran.r-project.org/web/packages/earth/index.html).

To perform the benchmarking of our paper, the Matlab-script "main.m" must be executed.
First, our script generates the benchmarking data by an additional script "constructionSynthetic04072021.m" and partitions the benchmarking data into the different experiments for the applications in R.
Subsequently, the scripts "Benchmarking08072021_GOMT_LSRT_CART.m", "Benchmarking08072021_GUIDE.m" and "Benchmarking09072021_M5.m" are used to test five different parameterizations for the generation of GOMT as well as one parameterization each for the generation of LSRT, CART, GUIDE and M5'.
As part of the 5 parameterizations of COMT, additional methods for determining the split value are investigated, in which, for example, our own developed kenel-based hinge-finding algorithm is included.
Both the R-script and the benchmarking data for MARS are stored in the "20_benchmarkingR_MARS" folder, and the R-script must be executed separately.
If the benchmarking of GUIDE causes errors, please comment out "Benchmarking08072021_GUIDE.m" to run the benchmarking with the remaining models.

The construction algorithm for generating COMT (presented in Figure 2 of our paper) is executed by the function "GOMT.m", which is stored in the folder "11_GOMT".
At this point it must be mentioned that our source code continues to be improved and commented, and that we welcome bug notifications.
