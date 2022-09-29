globals

[ 
nOfHouseholds

sortedBudget  giniIndex 

priceA
totalDemandA  
overallAlpha

newPrice
totalDemandBasePrice totalDemandNewPrice changeInTotalDemand%
totalExpenditureBasePrice totalExpenditureNewPrice changeInTotalExpenditure%
 ]

breed [households household]


households-own 
  [  
    alpha beta       
    budget quintileGroup
    demandA expenditureA       

    demandBasePrice demandNewPrice changeInDemand%
    expenditureBasePrice expenditureNewPrice
    utilityBasePrice utilityNewPrice changeInUtility%
   ]

;----------------------------------------
to setup 


  clear-all
  ask patches  [set pcolor white]
    
; create households & distributes randomly across world

set nOfHouseholds 1000

set-default-shape households "person"

create-households nOfHouseholds 
   [
     set color black
     set size 3 
     setxy random-pxcor random-pycor  
     while [any? other turtles-here] [ fd 1 ] 
   ] 

 setup-plots

end
;__________________________________________________________________

to go 

distribute-budgets 
calculate-gini
calculate-budget-quintiles   
calculate-utility-function-parameters
draw-demand-curves
calculate-change-in-demand-at-basePrice

update-plots

record-data

end

;____________________________________________________________________
; PROCEDURES
;____________________________________________________________________

to distribute-budgets  
 
  ;; from Budget Distribution model using initialMinBudget = 35 and initialMeanBudget = 100 
  ask households [ set budget 35 +  random-exponential 65  ]  

; to normalise budget to average 100   
   let calculatedMeanBudget precision ( mean [ budget ] of households ) 3 
   ask households [ set budget precision ( budget * ( 100 /  calculatedMeanBudget )) 3 ]    
; to ensure all households have an budget
   ask households with [ budget <= 0 ]  [ set budget 1 ]  

end
 
;----------------------------

to calculate-gini
; from Budget Distribution model
  set sortedBudget sort [ budget] of households
  let totalBudget sum sortedBudget
  let budget-sum-so-far 0
  let budgetIndex 0
  let gini 0
; to plot the Lorenz curve
  repeat nOfHouseholds
    [ 
      set budget-sum-so-far budget-sum-so-far + item budgetIndex sortedBudget
      set budgetIndex budgetIndex + 1  
      set gini  gini + (budgetIndex / nOfHouseholds ) - (budget-sum-so-far / totalBudget)
    ]
; to calculate the Gini coefficient  
  set giniIndex ( gini / nOfHouseholds ) * 2

end

;-----------------------------

to calculate-budget-quintiles 
; same method as used in Budget Distribtion model
   let firstQuintile item 200 sortedBudget
   let secondQuintile item 400 sortedBudget
   let thirdQuintile item 600 sortedBudget
   let fourthQuintile item 800 sortedBudget
   
   ask households with [ budget <  firstQuintile ] [ set quintileGroup 1 ]
   ask households with [ budget >=  firstQuintile and budget < secondQuintile ] [ set quintileGroup 2 ]
   ask households with [ budget >=  secondQuintile and budget < thirdQuintile ] [ set quintileGroup 3 ]
   ask households with [ budget >=  thirdQuintile and budget < fourthQuintile ] [ set quintileGroup 4 ]
   ask households with [ budget >=  fourthQuintile  ] [ set quintileGroup 5 ]

end

;----------------------------

to calculate-utility-function-parameters
  
; alpha + beta = 1 but alpha & beta > 0

    ask  households with [ quintileGroup = 1 ] [ set alpha precision ( random-normal meanBottomQuintileAlpha sdAlpha ) 3 ]
    ask  households with [ quintileGroup = 2 ] [ set alpha precision ( random-normal meanLowerQuintileAlpha sdAlpha ) 3 ]
    ask  households with [ quintileGroup = 3 ] [ set alpha  precision ( random-normal meanMiddleQuintileAlpha  sdAlpha ) 3 ]
    ask  households with [ quintileGroup = 4 ] [ set alpha  precision ( random-normal meanUpperQuintileAlpha sdAlpha  ) 3 ]
    ask  households with [ quintileGroup = 5 ] [ set alpha  precision ( random-normal meanTopQuintileAlpha sdAlpha ) 3 ]
    ask  households with [ alpha <= 0 ] [ set alpha 0.001 ]

plot-alpha

; to calculate overall budget share
    ask households [ set expenditureA ( alpha * budget ) ]      
    set overallAlpha ( sum [ expenditureA ] of households / sum [ budget ] of households )

end

;----------------------------------------------------------------------------------------

to draw-demand-curves
; formulae work on basis that alpa + beta = 1 and Price of B = 1
; calculates prices from 0.5 to 5 in increments of 0.1
     
set priceA 0.5

repeat 46 
 [  
   ask households  [ set demandA ( budget * alpha / priceA )  ]                   
   set totalDemandA sum [ demandA ] of households
   plot-demand-ownprice                 
   set priceA priceA + 0.1
 ]     
  
end

;---------------------------------------------------------------------------------------
to calculate-change-in-demand-at-basePrice
       
 ; unrounded number used for calculating impact of price change
  
    ask households 
        [ set demandBasePrice( budget * alpha / basePrice ) 
          set expenditureBasePrice demandBasePrice * basePrice ]
              
    set totalDemandBasePrice sum [demandBasePrice ] of households
    set totalExpenditureBasePrice  sum [ expenditureBasePrice ] of households
       
    plot-demand-basePrice 
         
    set newPrice basePrice * (1 +  ( changeInPrice% / 100 ))       
   
    ask households 
         [ 
           set demandNewPrice( budget * alpha / newPrice )
           set changeInDemand% ( ( demandNewPrice - demandBasePrice ) / demandBasePrice ) * 100
           set expenditureNewPrice demandNewPrice * newPrice
         ]
      
   set totalDemandNewPrice sum [demandNewPrice ] of households
   set totalExpenditureNewPrice  totalDemandNewPrice * newPrice     
   
   if totalDemandBasePrice > 0
      [ set changeInTotalDemand% ( totalDemandNewPrice - totalDemandBasePrice ) / totalDemandBasePrice * 100 ]
   
   if totalExpenditureBasePrice > 0
      [ set changeInTotalExpenditure% ( totalExpenditureNewPrice - totalExpenditureBasePrice ) / totalExpenditureBasePrice * 100 ]
  
  ; to calculate change in utility   
  ; utility function is demand for A to the power alpsa x demand for B to the power beta
  ; the expenditure on B is whatever is not spent on A
   
   ask households 
      [ set utilityBasePrice  ( demandBasePrice ^ alpha ) * (budget - expenditureBasePrice) ^ beta
        set utilityNewPrice ( demandNewPrice ^ alpha ) * (budget - expenditureNewPrice) ^ beta
        set changeInUtility% ( ( utilityNewPrice - utilityBasePrice  ) / utilityBasePrice ) * 100
      ]  
   
  ask households [ plot-change-in-utility% ]   

end        
 

;______________________________________________________________________________________________________________
; RESULTS
;______________________________________________________________________________________________________________

; utility function
to plot-alpha
  set-current-plot "Budget shares (alphas)"
  set-plot-x-range 0 0.2
  set-plot-y-range 0 50
  set-histogram-num-bars 110
  histogram [ alpha ]  of households
end

; demand curve

to plot-demand-ownprice
  set-current-plot "Total demand"
  set-plot-x-range 0 25000
  set-plot-y-range 0 5
  plotxy totalDemandA priceA  
end

to plot-demand-basePrice
  set-current-plot "Total demand at base price"
  set-plot-x-range 0 50
  set-plot-y-range 0 100
  set-histogram-num-bars 50
  histogram [ demandBasePrice ]  of households
end  


to plot-change-in-utility%
  set-current-plot "Change in utility for households %"
  set-plot-x-range 0  500
  set-plot-y-range -2   0
  plotxy   budget changeInUtility% 

end

;-------------------------------

to record-data

file-open ( word "Utility-" runName".csv"  )

export-all-plots 
(word "Utility-" runName ".csv" )  

file-print " "

file-type "Gini coeff "
file-print precision giniIndex 3

file-print " "

file-type "Min alpha"
file-print precision min [ alpha ] of households 3

file-type "Median alpha "
file-print precision median [ alpha ] of households 3 

file-type "Max alpha "
file-print precision max [ alpha ] of households 3

file-type "Overall alpha "
file-print precision overallAlpha 3

file-print " "

file-type "Change In Total Demand % "
file-print precision changeInTotalDemand% 1

file-type "Change In Total Expenditure % "
file-print precision  changeInTotalExpenditure% 1

file-close 

end   
  
;______________________________________________________________________________________________________________
;______________________________________________________________________________________________________________
  
@#$#@#$#@
GRAPHICS-WINDOW
1248
10
1516
299
50
50
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
19
13
83
46
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
109
13
172
46
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

MONITOR
18
239
90
284
Gini coeff
giniIndex
2
1
11

PLOT
400
392
729
684
Total demand
Quantity
Price
0.0
25000.0
0.0
5.0
true
true
"" ""
PENS
"default" 0.1 0 -16777216 false "" ""

MONITOR
18
295
89
340
Av Budget
mean [ budget ] of households
0
1
11

PLOT
32
389
391
682
Total demand at base price
Demand
Households
0.0
50.0
0.0
50.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

CHOOSER
18
123
156
168
basePrice
basePrice
0.5 1 2
1

MONITOR
793
179
873
224
Overall alpha
overallAlpha
3
1
11

PLOT
454
10
779
310
Budget shares (alphas)
Budget shares (alphas)
Households
0.0
0.2
0.0
50.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

MONITOR
793
12
872
57
min  alpha
min [ alpha ] of households
3
1
11

MONITOR
792
119
873
164
max  alpha 
max [ alpha ] of households
3
1
11

MONITOR
793
64
871
109
median alpha
median [ alpha ] of households
3
1
11

SLIDER
215
68
435
101
meanBottomQuintileAlpha
meanBottomQuintileAlpha
0.02
.98
0.15
.01
1
NIL
HORIZONTAL

SLIDER
216
148
435
181
meanMiddleQuintileAlpha
meanMiddleQuintileAlpha
0.02
0.98
0.12
.01
1
NIL
HORIZONTAL

SLIDER
217
186
434
219
meanUpperQuintileAlpha
meanUpperQuintileAlpha
0.02
0.98
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
216
225
433
258
meanTopQuintileAlpha
meanTopQuintileAlpha
0.02
.98
0.08
0.01
1
NIL
HORIZONTAL

TEXTBOX
221
10
371
74
Set average budget share (alpha) for each quintile:\n(Min value 0.02; max, 0.98)
12
0.0
1

SLIDER
216
105
433
138
meanLowerQuintileAlpha
meanLowerQuintileAlpha
0.02
0.98
0.13
0.01
1
NIL
HORIZONTAL

CHOOSER
16
183
154
228
changeInPrice%
changeInPrice%
1 10
1

MONITOR
922
330
1068
375
NIL
changeInTotalExpenditure%
1
1
11

MONITOR
765
331
909
376
NIL
changeInTotalDemand%
1
1
11

PLOT
751
393
1070
688
Change in utility for households %
Budget
Per cent change in utility
0.0
500.0
-2.0
0.0
true
false
"" ""
PENS
"default" 1.0 2 -16777216 true "" ""

INPUTBOX
18
55
185
115
runName
food
1
0
String

SLIDER
220
270
392
303
sdAlpha
sdAlpha
0
1
0.02
.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

It uses a Cobb-Douglas utility function and generates a demand curve; it then calculates the effect of a change in price. It is suitable for examining the demand for goods which everyone consumes and which has a price elasticity of 1. 


## HOW IT WORKS

Budgets are distributed to give a Gini coefficient of about a third (using the procedure set out in the Budget distribution model). The average budget is always 100.

Households have Cobb-Douglas utility functions, with alpha lying between 0 and 1. (The Cobb-Douglas means that they always have to consume some of each good.)  

So the marginal rate of substitution ( MRS ) is  ( alpha * goodB )  / (( 1- alpha)  * goodA). 

If price of B = 1, utility is maximised subject to the budget constraint when   
A = alpha x budget  / price of A  
Re-arranging this means that the budget share of A = alpha.   
The value of alpha will vary according to what A represents.

The mean alpha for each budget quintile is given by the 5 sliders combined with the budget share standard deviation (which is the same for all quintiles). For each quintile, the budget shares are allocated randomly using a normal distribution based on these parameters. For example, for those in the bottom quintile: 

    ask  households with [ quintileGroup = 1 ] [ set alpha precision ( random-normal  meanBottomQuintileAlpha sdAlpha ) 3 ]

where quintileGroup 1 is the bottom quintile group. This is repeated for each quintile group.

The program then calculates (1) aggregate demand and (2) the impact of a price change.

To draw the aggregate demand curve, each household is asked how much of good A they will consume at prices from 0.5 to 5 and the results for each price level added together.

The distribution of demand is also shown at a give price point (called base price) and the effect of a price change is assessed at this price point. The Cobb-Douglas function implies a constant own-price elasticity of 1 and there is no change in overall expenditure. However, the program calculates the change in utility resulting from the price change.

Key output data is sent to a csv file called  "Utility-runName".

## HOW TO USE IT

Choose the base price, which defines the point for calculating the impact of the price change and the size of the price change: an increase of 1% or 10%. 


## CREDITS AND REFERENCES

Runs on NetLogo 5.2.

For more information, see Hamill, L. & Gilbert, N. (2016) Agent-based Modelling in Economics. Wiley: Chapter 3.

To refer to this model: Hamill, L. & Gilbert, N. (2016) Utility function-based demand model.
 
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
