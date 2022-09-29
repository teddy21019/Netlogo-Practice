extensions[py]

globals
[
  nOfHouseholds
  ; budget distribution metrics
  minBudget
  medianBudget
  meanBudget
  maxBudget

  accumMinBudget accumMedianBudget accumMeanBudget accumMaxBudget
  accumbudgets bar-interval

  ratio-P90-P10 accumDecileRatio

  ; Gini coefficient and Lorenz curve
  sortedBudget totalBudget
  budget-sum-so-far budgetIndex
  giniIndex  accumGini

 ]

breed [households household]

households-own  [ budget ]

;----------------------------------------
to setup
  py:setup py:python3
  clear-all
  ask patches  [set pcolor white]

;; creates households and
;; distributes them randomly across world (although this isn't strictly needed at this stage)

set nOfHouseholds 1000
set-default-shape households "person"
create-households nOfHouseholds
[
     set color black
     set size 3
     setxy random-pxcor random-pycor
     while [any? other turtles-here] [ fd 1 ]
   ]
; lists of budget summary statistics
set accumMinBudget [ ]
set accumMedianBudget [ ]
set accumMeanBudget [ ]
set accumMaxBudget [ ]
set accumDecileRatio [ ]
; list of all budgets generated e.g. if 10 runs of 1,000 agents, luist contains 10,000 values
set accumbudgets []
; list of all Gini coefficients
set accumGini [ ]

setup-plots
end
;__________________________________________________________________

to go

repeat number-of-runs

[
    distribute-budgets
    calculate-gini
    calculate-P90P10ratio
    report-results-of-run
]

report-accumulated-results
generate-results-file

update-plots

end

;____________________________________________________________________
; PROCEDURES
;____________________________________________________________________

to distribute-budgets

 ; init + x, x~exp(100-init).  The mean will be 100 - init, making the expected value to be exactly 100

 ask households [ set budget initialMinBudget +
            random-exponential ( 100 - initialMinBudget )  ]

; to normalise budget to average 100 and round to 3 decimal places
   let calculatedMeanBudget precision ( mean [ budget ] of households ) 3
   ask households [ set budget precision ( budget * ( 100 /  calculatedMeanBudget )) 3 ]
; to ensure all households have an budget
   ask households with [ budget <= 0 ]  [ set budget 1 ]
; to record metrics iof the distribution
   set minBudget min [ budget ] of households
   set medianBudget median [ budget ] of households
   set meanBudget mean [ budget ] of households
   set maxBudget max [ budget ] of households

end

;----------------------------

to calculate-gini
; Based on NetLogo Library Wealth Distribution  example, but items fixed at nOfHouseholds.
; Sort the households by income.
; Accumulate for each household in turn from the poorest to the richest, the rank of the
; household minus the proportion of the sum of the incomes of all households up to and
; including this household as a proportion of the total income of all households.
; Divide the result by twice the number of households to give the Gini index.

  set sortedBudget sort [ budget] of households
  set totalBudget sum sortedBudget
  set budget-sum-so-far 0
  set budgetIndex 0
  let gini 0
  repeat nOfHouseholds
    [ set budget-sum-so-far budget-sum-so-far + item budgetIndex sortedBudget
      set budgetIndex budgetIndex + 1
      set gini  gini + (budgetIndex / nOfHouseholds ) - (budget-sum-so-far / totalBudget) ; 45 degree line - accumulation
    ]
  set giniIndex ( gini / nOfHouseholds ) * 2

end
;----------------------------

to calculate-P90P10ratio
; This procedure uses the list sortedBudget from the calculate-gini procedure.
; Households are numberered from 0, so item 99 is the 100th household.
; Thus the value of "bottomDecile" is the lower bound of the second decile.

; to define the boundaries of the bottom and top deciles
   let bottomDecile item 100 sortedBudget
   let topDecile item 900 sortedBudget
   set ratio-P90-P10   topDecile /  bottomDecile

end

;___________________________________________________________________________
;RESULTS
;___________________________________________________________________________

to report-results-of-run
  ; push this run's results onto the accumulating list i.e. produces a list containing one number for each run
   set accumMinBudget fput minBudget accumMinBudget
   set accumMedianBudget fput medianBudget accumMedianBudget
   set accumMeanBudget fput meanBudget accumMeanBudget
   set accumMaxBudget fput maxBudget accumMaxBudget
   set accumDecileRatio fput  ratio-P90-P10 accumDecileRatio
   set accumGini fput giniIndex  accumGini

  ; creates list of all budgets over all runs i.e. if there are 1,000 agents and 10 runs, it will contain 10,000 items
  set accumbudgets (sentence [budget] of households accumbudgets) ; put lists together without becoming a list of sublists

end

;---------------------------------
to report-accumulated-results
  ; find the mean and standard deviation of the results accumulated over all runs
  ; s.d can't be calculated for just one run
  ; and plot the accumulated household budgets
  output-print ( word "Results over "  number-of-runs " runs" )
  output-print " "

  output-type ( word "Min budget: mean = " precision ( mean accumMinBudget ) 1 )
  if number-of-runs > 1 [ output-type (word " sd = " precision ( standard-deviation accumMinBudget ) 1 ) ]
  output-print " "

  output-type (word "Median budget: mean = " precision ( mean accumMediANBudget ) 1 )
  if number-of-runs > 1 [ output-type (word " sd = " precision ( standard-deviation accumMedianBudget ) 1 ) ]
  output-print " "

  output-type (word "Mean budget = " precision ( mean accumMeanBudget ) 1 )
  if number-of-runs > 1 [ output-type (word " sd = " precision ( standard-deviation accumMeanBudget ) 1 ) ]
  output-print " "

  output-type (word "Max budget: mean = " precision ( mean accumMaxBudget ) 1 )
  if number-of-runs > 1 [ output-print (word " sd  = " precision ( standard-deviation accumMaxBudget ) 1 ) ]
  output-print " "

  output-type (word "P90/P10: mean  = " precision ( mean accumDecileRatio ) 1 )
  if number-of-runs > 1 [ output-print (word " sd  = " precision ( standard-deviation accumDecileRatio ) 1 ) ]
  output-print " "

  output-type (word "Gini: mean = " precision ( mean accumGini ) 3 )
  if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumGini ) 3 )  ]
  output-print (word "Gini range: min " precision ( min accumGini ) 3  ": max " precision ( max accumGini ) 3  )

  ; to produce percentage distribution of households by budget
  set-current-plot "Budget"
  set-plot-x-range 0 1000
  set-plot-y-range 0 20
  set bar-interval 10 ; width of each bar
  plot-bar-chart accumbudgets

end
;------------------------
to plot-bar-chart [lst]
  ; requires a list of numbers, lst
  ; creates a bar chart, with each bar representing the percentage of the values in
  ; the given list of values, lst, that fall into the bar interval

  let lst-len length lst
  let percent-denom lst-len / 100
  let next-top-limit bar-interval

  while [ lst-len > 0 ] [
    set lst filter [ ?1 -> ?1 >= next-top-limit ] lst
    plotxy next-top-limit (lst-len - length lst) / percent-denom
    set lst-len length lst
    set next-top-limit next-top-limit + bar-interval
  ]

end

;---------------------------------------------

to generate-results-file

  file-open "budgets.csv"

  ; "," ensures value printed in new col
  file-type "Number-of-runs, "
  file-print number-of-runs
  file-print " "

  file-type "Initial Min Budget, "
  file-print initialMinBudget
  file-print " "

  file-type "Mean min budget, "
  file-print precision mean accumMinBudget 1
   if number-of-runs > 1 [ file-type "S.D. min budget, "
                           file-print precision standard-deviation  accumMinBudget  1 ]
  file-type "Mean median budget, "
  file-print precision mean accumMedianBudget 1
     if number-of-runs > 1 [file-type "S.D. median budget, "
                            file-print precision standard-deviation  accumMedianBudget  1 ]
  file-type "Mean budget, "
  file-print precision mean accumMeanBudget 1
    if number-of-runs > 1 [ file-type "S.D. mean budget, "
                             file-print precision standard-deviation  accumMeanBudget  1 ]
  file-type "Mean max budget, "
  file-print precision mean accumMaxBudget 1
     if number-of-runs > 1 [ file-type "S.D. max budget, "
                              file-print precision standard-deviation  accumMaxBudget  1 ]
  file-print " "

  file-type "Mean P90/P10 Ratio, "
  file-print precision mean accumDecileRatio  1
  if number-of-runs > 1 [ file-type  " S.D. p19/P10 Ratio, "
                          file-print precision ( standard-deviation accumDecileRatio ) 1  ]
  file-print " "

  file-type "Mean Gini, "
  file-print precision mean accumGini 3
     if number-of-runs > 1 [  file-type "S.D. Gini, "
                              file-print precision standard-deviation accumGini 3 ]
  file-type "Gini range: min, "
  file-print precision ( min accumGini ) 3
  file-type "Gini range: max, "
  file-print precision ( max accumGini ) 3
  file-print " "

  export-all-plots (word "budgets.csv" )
  file-close

end
;__________________________________________________________________________________________________________
;__________________________________________________________________________________________________________
@#$#@#$#@
GRAPHICS-WINDOW
236
434
502
701
-1
-1
2.5545
1
10
1
1
1
0
1
1
1
-50
50
-50
50
0
0
1
ticks
30.0

BUTTON
12
10
76
43
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
81
10
144
43
Go
Go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
234
17
596
231
Budget
Budget
Percent of households
0.0
1000.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 false "" ""

SLIDER
12
79
166
112
initialMinBudget
initialMinBudget
0
95
5.0
1
1
NIL
HORIZONTAL

CHOOSER
11
121
162
166
number-of-runs
number-of-runs
1 10 30 100
0

OUTPUT
235
245
599
420
12

@#$#@#$#@
## WHAT IS IT?

Distributes budgets to produce  
-  a Gini ceofficient of about one third   
- the ‘P90/P10’ ratio, which is the ratio of the income at the 90th percentile to the 10th: just over 4 in the UK in recent years   
(ONS, 2011)

## HOW IT WORKS

The distribution is based on an exponential function, which is "shifted right".  

The budget is generated by this line of code:

    ask agents [ set budget 
    initialMinBudget + round random-exponential ( 100 - initialMinBudget) ] 

The results are normalised so that the average budget is always 100 but that the minimum is always greater than 0. 

The results are also rounded to 3 decimal place. This precision is necessary to ensure that each household has a unique budget. If it is rounded further, it may not be possible to divide the households into 5 equal size quintile groups as more than one household may have a budget equal to the boundary value.)

## HOW TO USE IT

Select number of runs and choose initialMinBudget. 

## CREDITS AND REFERENCES

Wilensky, U. (1998). NetLogo Wealth Distribution model. http://ccl.northwestern.edu/netlogo/models/WealthDistribution. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

ONS (2011) The effects of taxes and benefits on household income. Statistical bulletin. 19 May 2011. Available at http://www.ons.gov.uk.

Runs on NetLogo 5.2.

For more information, see Hamill, L. & Gilbert, N. (2016) Agent-based 
Modelling in Economics. Wiley: Chapter 3.

To refer to this model: Hamill, L. & Gilbert, N. (2016) Budget distribution model.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
