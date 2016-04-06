$ontext
CEE 6410 Fall 2015
Parametric programming with Example 2.1 from Bishop Et Al Text
Lecture Sept 24, 2015

THE PROBLEM:

An irrigated farm can be planted in two crops:  eggplants and tomatoes.  Data are as follows:

Seasonal Resource
Inputs or Profit        Crops        Resource
Availability
        Eggplant        Tomatoes
Water        1x103 gal/plant        2x103 gal/plant        4x106 gal/year
Land        4 ft2/plant        3 ft2/plant        1.2x104 ft2
Profit/plant        $6        $7

How do the objective function and decision variable values changes if the
water requirement for tomatoes decreases from 2,000 gal/plant to
1,500, 1000, and 500 gal/plant? At what water requirement
level does the solution basis change?

Solution Approach:
Solve the model 4 times changing the tomato water requirement value. Store
results for each run.

David E Rosenberg
david.rosenberg@usu.edu
September 21, 2015
$offtext

* 1. DEFINE the SETS
SETS plnt crops growing /Eggplant, Tomatoes/
     res resources /Water, Land/

* 2. DEFINE input data
PARAMETERS
   c(plnt) Objective function coefficients ($ per plant)
         /Eggplant 6,
         Tomatoes 7/
   b(res) Right hand constraint values (per resource)
          /Water 4000000,
           Land  12000 /
   c_inp(plnt) Objective function coefficients to read in from Matlab ($ per plant);

*Load user-specified profit data from Matlab (GDX file)
$GDXIN PlantProfit.gdx
$LOAD   c_inp
$GDXIN
*Assign input to model parameter
c(plnt) = c_inp(plnt);

TABLE A(plnt,res) Left hand side constraint coefficients
                 Water    Land
 Eggplant        1000      4
 Tomatoes        2000      3 ;

*PARAMETRIC Programming data
SETS runs parametric programming runs /r1*r4/;
*                            same as /r1,r2,r3,r4,r5/
PARAMETER TomWatReq(runs) Tomato water use requirement (gal per plant);
* Initializes TomWatReq to zero.
*   /r1 2000
*    r2 1500
*    r3 1000
*    r4 500/;

*Now initialize the tomato water requirement with an equation statement
* ord(runs) generates a number 1, 2, 3, ... that is the item number
TomWatReq(runs) = 2000 - (ord(runs)-1)*500;

*Confirm that calculation is correct (look in .lst file)
Display TomWatReq;

*Parameters to store parametric results of runs
PARAMETERS ObjFunc(runs) Objective funcation values ($)
           DecVars(runs,plnt) Decision variable values (Number of plants)
           ShadowVals(runs,res) Shadow values of resource constraints ($ per resource);


* 3. DEFINE the variables
VARIABLES X(plnt) plants planted (Number)
          VPROFIT  total profit ($);

* Non-negativity constraints
POSITIVE VARIABLES X;

* 4. COMBINE variables and data in equations
EQUATIONS
   PROFIT Total profit ($) and objective function value
   RES_CONSTRAIN(res) Resource Constraints;

PROFIT..                 VPROFIT =E= SUM(plnt,c(plnt)*X(plnt));
RES_CONSTRAIN(res) ..    SUM(plnt,A(plnt,res)*X(plnt)) =L= b(res);

* 5. DEFINE the MODEL from the EQUATIONS
MODEL PLANTING /PROFIT, RES_CONSTRAIN/;
*Altnerative way to write (include all previously defined equations)
*MODEL PLANTING /ALL/;

* 6. SOLVE the MODEL runs number of time for each parametric value
LOOP (runs,
*    Parametrically set the model input parameter value for this run
     A("Tomatoes","Water") = TomWatReq(runs);

*    Initialize decision variable values to zero
     X.L(plnt) = 0;

*    Solve the model
     SOLVE PLANTING USING LP MAXIMIZING VPROFIT;

*    Record stuff about the solution
*    Objective function value
     ObjFunc(runs) = VPROFIT.L;
*                           .L means the variable level
*    Decision variable values
     DecVars(runs,plnt) = X.L(plnt);

*    Shadcw values of constraints. .M means marginal
     ShadowVals(runs,res) = RES_CONSTRAIN.M(res);
     );
*    finish loop over runs

* 7. Print out the results for the runs
DISPLAY TomWatReq,ObjFunc,DecVars, ShadowVals;

* Dump all input data and results to a GAMS gdx file
Execute_Unload "Ex2-1-parametric.gdx";
* Dump the gdx file to an Excel workbook
*Execute "gdx2xls Ex2-1-parametric.gdx"
