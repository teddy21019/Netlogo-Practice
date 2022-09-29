globals

[
nOfHouseholds

; all households
meanBudget
sortedBudget  giniIndex
overallBudgetShare% meanBudgetShare%
quintile

consumingAtBasePrice% totalDemandBasePrice totalExpenditureBasePrice
newPrice

changeInTotalDemand% changeInTotalExpenditure%
overallNewBudgetShare%
consumingAtNewPrice%


accumMeanBudget accumGini
accumDemandBasePrice
accumConsumingAtBasePrice%
accumBudgetShare% ; all households for plotting distribution
accumBSAtBasePrice%
accumElasticities

accumConsumingAtNewPrice%
accumBSAtNewPrice%
accumChangeInTotalExpenditure%
bar-interval


; quintiles
 quintileExpenditure%
 consumingAtBasePriceQ% consumingAtNewPriceQ%
 meanDemandChangeQ% meanExpenditureChangeQ% meanBudgetShareQ% meanNewBudgetShareQ%
 accumChangeInTotalDemand%  accumQuintileExpenditure%
 accumConsumingAtBasePriceQ% accumConsumingAtBasePriceQ1% accumConsumingAtBasePriceQ2% accumConsumingAtBasePriceQ3% accumConsumingAtBasePriceQ4% accumConsumingAtBasePriceQ5%
 accumQuintileExpenditureQ%  accumQuintileExpenditureQ1% accumQuintileExpenditureQ2%  accumQuintileExpenditureQ3%  accumQuintileExpenditureQ4% accumQuintileExpenditureQ5%
 accumMeanExpenditureChangeQ% accumMeanExpenditureChangeQ1% accumMeanExpenditureChangeQ2% accumMeanExpenditureChangeQ3% accumMeanExpenditureChangeQ4% accumMeanExpenditureChangeQ5%
 accumConsumingAtNewPriceQ% accumConsumingAtNewPriceQ1% accumConsumingAtNewPriceQ2% accumConsumingAtNewPriceQ3% accumConsumingAtNewPriceQ4% accumConsumingAtNewPriceQ5%

; tax
  tax  totalTaxPaid quintileTaxShare% meanEffectiveTaxRateQ%
  accumTaxShareQ% accumTaxShareQ1%  accumTaxShareQ2%  accumTaxShareQ3%  accumTaxShareQ4% accumTaxShareQ5%
  overallETR% accumOverallETR%
  accumMeanEffectiveTaxRateQ% accumMeanETRQ1% accumMeanETRQ2% accumMeanETRQ3% accumMeanETRQ4% accumMeanETRQ5%
]

breed [households household]

households-own
  [
    budget quintileGroup
    demandBasePrice expenditureBasePrice budgetshare%
    c
    demandNewPrice changeInDemand%
    newExpenditure   newBudgetShare% changeInExpenditure%
    taxPaid effectiveTaxRate%
   ]

;;----------------------------------------
to setup

  clear-alls
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

; for recording results
  ; basic metrics
  set accumMeanBudget [ ]
  set accumGini [  ]
  set accumDemandBasePrice [ ]
  set accumBudgetShare% [  ]
  set accumBSAtBasePrice% [ ]
  set accumElasticities [ ]

  set accumConsumingAtBasePrice% [  ]
  set accumConsumingAtBasePriceQ% [ ]
  set accumConsumingAtBasePriceQ1% [ ]
  set accumConsumingAtBasePriceQ2% [ ]
  set accumConsumingAtBasePriceQ3% [ ]
  set accumConsumingAtBasePriceQ4% [ ]
  set accumConsumingAtBasePriceQ5% [ ]


  set accumQuintileExpenditure% [ ]
  set accumQuintileExpenditureQ1% [ ]
  set accumQuintileExpenditureQ2% [ ]
  set accumQuintileExpenditureQ3% [ ]
  set accumQuintileExpenditureQ4% [ ]
  set accumQuintileExpenditureQ5% [ ]

  ; effect of price change
  set accumChangeInTotalDemand% [ ]
  set accumChangeInTotalExpenditure% [ ]
  set accumBSAtNewPrice% [  ]

  set accumMeanExpenditureChangeQ% [ ]
  set accumMeanExpenditureChangeQ1% [ ]
  set accumMeanExpenditureChangeQ2% [ ]
  set accumMeanExpenditureChangeQ3% [ ]
  set accumMeanExpenditureChangeQ4% [ ]
  set accumMeanExpenditureChangeQ5% [ ]

  set accumConsumingAtNewPrice% [  ]
  set accumConsumingAtNewPriceQ% [ ]
  set accumConsumingAtNewPriceQ1% [ ]
  set accumConsumingAtNewPriceQ2% [ ]
  set accumConsumingAtNewPriceQ3% [ ]
  set accumConsumingAtNewPriceQ4% [ ]
  set accumConsumingAtNewPriceQ5% [ ]

; tax
  set accumTaxShareQ% [ ]
  set accumTaxShareQ1% [ ]
  set accumTaxShareQ2% [ ]
  set accumTaxShareQ3% [ ]
  set accumTaxShareQ4% [ ]
  set accumTaxShareQ5% [ ]

  set accumOverallETR% [ ]

  set accumMeanEffectiveTaxRateQ% [ ]
  set accumMeanETRQ1% [ ]
  set accumMeanETRQ2% [ ]
  set accumMeanETRQ3% [ ]
  set accumMeanETRQ4% [ ]
  set accumMeanETRQ5% [ ]


 setup-plots

end
;__________________________________________________________________

to go

repeat number-of-runs

 [ clear
   distribute-budgets
   calculate-gini
   calculate-budget-quintiles
   calculate-demand-at-basePrice
   calculate-demand-at-newPrice
   calculate-tax
   calculate-quintile-means
   report-results-of-run
 ]

report-accumulated-results
generate-results-file

update-plots
end

;____________________________________________________________________
; PROCEDURES
;____________________________________________________________________

to clear
  ; needed as doing multiple runs
  ask households
 [   set budget 0
     set quintileGroup 0
     set demandBasePrice 0
     set expenditureBasePrice 0
     set budgetshare% 0
     set priceElasticity 0
     set demandNewPrice 0
     set changeInDemand% 0
     set newExpenditure 0
     set  newBudgetShare% 0
     set changeInExpenditure% 0
     set taxPaid 0
     set effectiveTaxRate% 0
 ]
end

;------------------------------

to distribute-budgets

 ; from Budget Distribution model using initialMinBudget = 35 and initialMeanBudget = 100
   ask households [ set budget 35 +  random-exponential 65  ]

 ; to normalise budget to average 100. It is important to have lots of decimal palces to ensure a unique
 ; figure for each household and thus that there are exactlt 200 households in each quintile
   let calculatedMeanBudget precision ( mean [ budget ] of households ) 4
   ask households [ set budget precision ( budget * ( 100 /  calculatedMeanBudget )) 4 ]
 ; to ensure all households have an budget
   ask households with [ budget <= 0 ]  [ set budget 1 ]
 ; to check mean = 100
   set meanBudget mean [ budget ] of households
end

;----------------------------

to calculate-gini
 ; from Budget Distribution model (based on Wilensky, 1998)
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

;;-----------------------------

to calculate-budget-quintiles
; same method as used in Budget Distribtion model
   let firstQuintile item 200 sortedBudget
   let secondQuintile item 400 sortedBudget
   let thirdQuintile item 600 sortedBudget
   let fourthQuintile item 800 sortedBudget

; quintiles labelled 1 to 5 rather that using words to facilitate repeat operation later in program
   ask households with [ budget <  firstQuintile ] [ set quintileGroup 1 ]
   ask households with [ budget >=  firstQuintile and budget < secondQuintile ] [ set quintileGroup 2 ]
   ask households with [ budget >=  secondQuintile and budget < thirdQuintile ] [ set quintileGroup 3]
   ask households with [ budget >=  thirdQuintile and budget < fourthQuintile ] [ set quintileGroup 4 ]
   ask households with [ budget >=  fourthQuintile  ] [ set quintileGroup 5 ]

end

;----------------------------

to calculate-demand-at-basePrice

    ask n-of (( initial%BottomQuintileConsuming / 100 ) * nOfHouseholds / 5 )  households with [ quintileGroup = 1 ] [ set budgetShare% precision ( random-normal meanBottomQuintileShare% sdShare% ) 2 ]
    ask n-of (( initial%LowerQuintileConsuming / 100 ) * nOfHouseholds / 5 ) households with [ quintileGroup = 2 ] [ set budgetShare% precision ( random-normal meanLowerQuintileShare% sdShare% ) 2 ]
    ask n-of (( initial%MiddleQuintileConsuming / 100 ) * nOfHouseholds / 5 ) households with [ quintileGroup = 3 ] [ set budgetShare% precision ( random-normal meanMiddleQuintileShare%  sdShare% ) 2 ]
    ask n-of (( initial%UpperQuintileConsuming / 100 ) * nOfHouseholds / 5 ) households with [ quintileGroup = 4 ] [ set budgetShare% precision ( random-normal meanUpperQuintileShare% sdShare%  ) 2 ]
    ask n-of (( initial%TopQuintileConsuming / 100 ) * nOfHouseholds / 5 ) households with [ quintileGroup = 5 ] [ set budgetShare% precision ( random-normal meanTopQuintileShare% sdShare% ) 2 ]
    ask households with [ budgetShare% < 0 ] [ set budgetShare% 0 ]


    ask households  [ set demandBasePrice ( budget * ( budgetShare% / 100 ) / basePrice ) ]
    ask households with [ demandBasePrice < minDemand ] [ set demandBasePrice  0  set budgetshare% 0 ]

   set consumingAtBasePrice% count households with  [ demandBasePrice > 0 ] / nOfHouseholds * 100

    set totalDemandBasePrice sum [demandBasePrice ] of households
    set totalExpenditureBasePrice  totalDemandBasePrice * basePrice

; to calculate overall budget share

    ask households [ set expenditureBasePrice ( budgetShare% * budget / 100 ) ]
    set overallBudgetShare%  ( totalExpenditureBasePrice / sum [ budget ] of households ) * 100


end

;--------------------------
to calculate-demand-at-newPrice

 ; set elasticities

    ask households with [ quintileGroup = 1 ] [ set priceElasticity  ( - random-normal meanBottomQuintileElasticity sdElasticity ) ]
    ask households with [ quintileGroup = 2 ] [ set priceElasticity  ( - random-normal meanLowerQuintileElasticity sdElasticity )]
    ask households with [ quintileGroup = 3 ] [ set priceElasticity  ( - random-normal meanMiddleQuintileElasticity sdElasticity ) ]
    ask households with [ quintileGroup = 4 ] [ set priceElasticity  ( - random-normal meanUpperQuintileElasticity sdElasticity) ]
    ask households with [ quintileGroup = 5 ] [ set priceElasticity  ( - random-normal meanTopQuintileElasticity sdElasticity ) ]
    ask households with [ priceElasticity > 0 ] [ set priceElasticity 0 ]

  ;  plot-priceElasticities

  ; calculate new demand

   set newPrice basePrice * (1 +  ( changeInPrice% / 100 ))

   ask households [ set demandNewPrice ( demandBasePrice * ( 1 + ( priceElasticity  * ( changeInPrice% / 100) ) ) ) ]
   ask households with [ demandNewPrice < minDemand ] [ set demandNewPrice  0  ]

  ; calculate households' changes in demand and expenditure

   set consumingAtNewPrice% count households with  [ demandNewPrice > 0 ] / nOfHouseholds * 100

   ask households with [ demandBasePrice > 0 ]
         [
          set newExpenditure  ( demandNewPrice * newPrice )
          set newBudgetShare% (( newExpenditure / budget ) * 100 )
          set changeInDemand% precision ( ( demandNewPrice - demandBasePrice ) / demandBasePrice * 100 ) 3
          set changeInExpenditure%  precision  (( newExpenditure -  expenditureBasePrice ) / expenditureBasePrice * 100 ) 3
         ]

      ;; calculate total demand and expenditure
   let totalDemandNewPrice sum [demandNewPrice ] of households
   let totalExpenditureNewPrice  totalDemandNewPrice * newPrice

  if totalDemandBasePrice > 0
    [  set changeInTotalDemand% ( totalDemandNewPrice - totalDemandBasePrice ) / totalDemandBasePrice * 100  ]

  if totalExpenditureBasePrice > 0
    [  set changeInTotalExpenditure% ( totalExpenditureNewPrice - totalExpenditureBasePrice ) / totalExpenditureBasePrice * 100 ]

  set overallNewBudgetShare%  ( sum [ newExpenditure  ] of households / sum [ budget ] of households ) * 100

end

;------------------------
to  calculate-tax

set tax ( newPrice - basePrice )
ask households [ set taxPaid tax *  demandNewPrice
                 set effectiveTaxRate%  taxPaid / budget * 100]
set totalTaxPaid  sum [ taxPaid ] of households
set overallETR%  ( totalTaxPaid / ( nOfHouseholds * meanBudget ) ) * 100

end


;--------------------------
to calculate-quintile-means
          set accumQuintileExpenditure% [ ]
          set accumMeanExpenditureChangeQ% [ ]
          set accumConsumingAtBasePriceQ%  [ ]
          set accumConsumingAtNewPriceQ% [ ]
          set accumTaxShareQ% [ ]
          set accumMeanEffectiveTaxRateQ% [ ]

   set quintile 1
   repeat 5
         [
           if count households with [ quintileGroup = quintile and demandBasePrice > 0 ] > 0
              [ set meanDemandChangeQ% mean [ changeInDemand% ] of households with [ quintileGroup = quintile and demandBasePrice > 0 ]
                set meanExpenditureChangeQ% mean [ changeInExpenditure% ] of households with [ quintileGroup = quintile and demandBasePrice > 0]
               ]

          set meanBudgetShareQ% mean [ budgetShare% ]  of households with [ quintileGroup = quintile ]
          set meanNewBudgetShareQ% mean [ newBudgetShare% ]  of households with [ quintileGroup = quintile ]
          set quintileExpenditure%  sum  ( [expenditureBasePrice ] of households with [ quintileGroup = quintile ] ) / totalExpenditureBasePrice * 100

          set consumingAtBasePriceQ% count households with [ quintileGroup = quintile and demandBasePrice > 0 ] / count households with [ quintileGroup = quintile ] * 100
          set consumingAtNewPriceQ% count households with [ quintileGroup = quintile and demandNewPrice > 0 ] / count households with [ quintileGroup = quintile ] * 100


          set quintileTaxShare% sum ( [ taxPaid ] of households with [ quintileGroup = quintile ] ) / totalTaxPaid * 100
          set meanEffectiveTaxRateQ% mean [ effectiveTaxRate% ]  of households with [ quintileGroup = quintile ]

          set accumQuintileExpenditure% lput quintileExpenditure%  accumQuintileExpenditure%
          set accumMeanExpenditureChangeQ% lput meanExpenditureChangeQ% accumMeanExpenditureChangeQ%
          set accumConsumingAtBasePriceQ% lput consumingAtBasePriceQ%  accumConsumingAtBasePriceQ%
          set accumConsumingAtNewPriceQ% lput consumingAtNewPriceQ%  accumConsumingAtNewPriceQ%
          set accumTaxShareQ% lput quintileTaxShare% accumTaxShareQ%
          set accumMeanEffectiveTaxRateQ% lput meanEffectiveTaxRateQ% accumMeanEffectiveTaxRateQ%

          set quintile quintile + 1
         ]

end

;_______________________________________________________________________________________________________________
; RESULTS
;_______________________________________________________________________________________________________________

to report-results-of-run
  ; push this run's results onto the accumulating list i.e. produces a list containing one number for each ru
   ; basic metrics
   set accumMeanBudget fput meanBudget accumMeanBudget
   set accumGini fput giniIndex  accumGini

   set accumConsumingAtBasePrice% fput  consumingAtBasePrice%  accumConsumingAtBasePrice%

   set accumConsumingAtBasePriceQ1% fput ( item 0  accumConsumingAtBasePriceQ% ) accumConsumingAtBasePriceQ1%
   set accumConsumingAtBasePriceQ2% fput ( item 1  accumConsumingAtBasePriceQ% ) accumConsumingAtBasePriceQ2%
   set accumConsumingAtBasePriceQ3% fput ( item 2  accumConsumingAtBasePriceQ% ) accumConsumingAtBasePriceQ3%
   set accumConsumingAtBasePriceQ4% fput ( item 3  accumConsumingAtBasePriceQ% ) accumConsumingAtBasePriceQ4%
   set accumConsumingAtBasePriceQ5% fput ( item 4  accumConsumingAtBasePriceQ% ) accumConsumingAtBasePriceQ5%

   set accumBSAtBasePrice% fput overallBudgetShare% accumBSAtBasePrice%

   ; expenditure shares by quintile
   set accumQuintileExpenditureQ1% fput ( item 0  accumQuintileExpenditure%) accumQuintileExpenditureQ1%
   set accumQuintileExpenditureQ2% fput ( item 1  accumQuintileExpenditure%) accumQuintileExpenditureQ2%
   set accumQuintileExpenditureQ3% fput ( item 2  accumQuintileExpenditure%) accumQuintileExpenditureQ3%
   set accumQuintileExpenditureQ4% fput ( item 3  accumQuintileExpenditure%) accumQuintileExpenditureQ4%
   set accumQuintileExpenditureQ5% fput ( item 4  accumQuintileExpenditure%) accumQuintileExpenditureQ5%


   ; impact of price change

   set accumConsumingAtNewPrice% fput consumingAtNewPrice% accumConsumingAtNewPrice%

   set accumChangeInTotalDemand% fput  changeInTotalDemand% accumChangeInTotalDemand%
   set accumChangeInTotalExpenditure% fput changeInTotalExpenditure% accumChangeInTotalExpenditure%

   set accumMeanExpenditureChangeQ1% fput ( item 0  accumMeanExpenditureChangeQ% ) accumMeanExpenditureChangeQ1%
   set accumMeanExpenditureChangeQ2% fput ( item 1  accumMeanExpenditureChangeQ% ) accumMeanExpenditureChangeQ2%
   set accumMeanExpenditureChangeQ3% fput ( item 2  accumMeanExpenditureChangeQ% ) accumMeanExpenditureChangeQ3%
   set accumMeanExpenditureChangeQ4% fput ( item 3  accumMeanExpenditureChangeQ% ) accumMeanExpenditureChangeQ4%
   set accumMeanExpenditureChangeQ5% fput ( item 4  accumMeanExpenditureChangeQ% ) accumMeanExpenditureChangeQ5%

   set accumBSAtNewPrice% fput overallNewBudgetShare%  accumBSAtNewPrice%

   set accumConsumingAtNewPriceQ1% fput ( item 0  accumConsumingAtNewPriceQ% ) accumConsumingAtNewPriceQ1%
   set accumConsumingAtNewPriceQ2% fput ( item 1  accumConsumingAtNewPriceQ% ) accumConsumingAtNewPriceQ2%
   set accumConsumingAtNewPriceQ3% fput ( item 2  accumConsumingAtNewPriceQ% ) accumConsumingAtNewPriceQ3%
   set accumConsumingAtNewPriceQ4% fput ( item 3  accumConsumingAtNewPriceQ% ) accumConsumingAtNewPriceQ4%
   set accumConsumingAtNewPriceQ5% fput ( item 4  accumConsumingAtNewPriceQ% ) accumConsumingAtNewPriceQ5%

  ; tax

   set accumTaxShareQ1% fput ( item 0  accumTaxShareQ% ) accumTaxShareQ1%
   set accumTaxShareQ2% fput ( item 1  accumTaxShareQ% ) accumTaxShareQ2%
   set accumTaxShareQ3% fput ( item 2  accumTaxShareQ% ) accumTaxShareQ3%
   set accumTaxShareQ4% fput ( item 3  accumTaxShareQ% ) accumTaxShareQ4%
   set accumTaxShareQ5% fput ( item 4  accumTaxShareQ% ) accumTaxShareQ5%

   set accumOverallETR% fput overallETR% accumOverallETR%

   set accumMeanETRQ1% fput ( item 0  accumMeanEffectiveTaxRateQ% ) accumMeanETRQ1%
   set accumMeanETRQ2% fput ( item 1  accumMeanEffectiveTaxRateQ% ) accumMeanETRQ2%
   set accumMeanETRQ3% fput ( item 2  accumMeanEffectiveTaxRateQ% ) accumMeanETRQ3%
   set accumMeanETRQ4% fput ( item 3  accumMeanEffectiveTaxRateQ% ) accumMeanETRQ4%
   set accumMeanETRQ5% fput ( item 4  accumMeanEffectiveTaxRateQ% ) accumMeanETRQ5%

  ; creates list of all budgets over all runs i.e. if there are 1,000 agents and 10 runs, it will contain 10,000 items
   set accumBudgetShare% (sentence [ budgetshare% ] of households accumBudgetShare% )
   set accumDemandBasePrice (sentence [ demandBasePrice ] of households accumDemandBasePrice )
   set accumElasticities (sentence [ priceElasticity ] of households accumElasticities)


end

;---------------------------------
to report-accumulated-results
  ; produces the results shown on the interface
  ; find the mean and standard deviation of the results accumulated over all runs
  ; s.d can't be calculated for just one run

  output-print ( word "Results over "  number-of-runs " runs" )
  output-print " "

  output-type (word "Mean budget = " precision ( mean accumMeanBudget ) 2 )
    if number-of-runs > 1 [ output-type (word " sd = " precision ( standard-deviation accumMeanBudget ) 2 ) ]
  output-print " "

  output-type (word "Gini: mean = " precision ( mean accumGini ) 3 )
       if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumGini ) 3 ) ]
  output-print " "

  output-type (word "% households consuming at base price: mean = " precision ( mean accumConsumingAtBasePrice% ) 1 )
   if number-of-runs > 1 [ output-type (word " sd = " precision ( standard-deviation accumConsumingAtBasePrice% ) 1 ) ]
  output-print " "

  output-type (word "Mean Overall Budget Share At Base Price %: mean = " precision ( mean accumBSAtBasePrice%) 2 )
  if number-of-runs > 1 [ output-type (word " sd = " precision ( standard-deviation accumBSAtBasePrice% ) 2 ) ]
  output-print " "

  output-print (word "Mean expenditure share by quintile %: " )
  output-type (word "Q1 " precision ( mean accumQuintileExpenditureQ1%) 2 )
          if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumQuintileExpenditureQ1% ) 2 ) ]
  output-type (word "Q2 " precision ( mean accumQuintileExpenditureQ2%) 2 )
          if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumQuintileExpenditureQ2% ) 2 ) ]
  output-type (word "Q3 " precision ( mean accumQuintileExpenditureQ3%) 2 )
          if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumQuintileExpenditureQ3% ) 2 ) ]
  output-type (word "Q4 " precision ( mean accumQuintileExpenditureQ4%) 2 )
          if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumQuintileExpenditureQ4% ) 2 ) ]
  output-type (word "Q5 " precision ( mean accumQuintileExpenditureQ5%) 2 )
          if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumQuintileExpenditureQ5% ) 2 ) ]
  output-print " "


  set-current-plot "Budget shares"
  set-plot-x-range 0 20
  set-plot-y-range 0 20
  set bar-interval 1 ; width of each bar
  plot-bar-chart accumBudgetShare%

; to produce percentage distribution of households by demand at base price
  set-current-plot "Demand at base price"
  set-plot-x-range 0 50
  set-plot-y-range 0 100
  set bar-interval 1 ; width of each bar
  plot-bar-chart accumDemandBasePrice

  output-print (word "Mean % consuming at base price by quintile: " )
  output-type (word "Q1 " precision ( mean accumConsumingAtBasePriceQ1%) 2 )
              if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumConsumingAtBasePriceQ1% ) 2 ) ]
  output-type (word "Q2 " precision ( mean accumConsumingAtBasePriceQ2%) 2 )
              if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumConsumingAtBasePriceQ2% ) 2 ) ]
  output-type (word "Q3 " precision ( mean accumConsumingAtBasePriceQ3%) 2 )
              if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumConsumingAtBasePriceQ3% ) 2 ) ]
  output-type (word "Q4 " precision ( mean accumConsumingAtBasePriceQ4%) 2 )
              if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumConsumingAtBasePriceQ4% ) 2 ) ]
  output-type (word "Q5 " precision ( mean accumConsumingAtBasePriceQ5%) 2 )
              if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumConsumingAtBasePriceQ5% ) 2 ) ]
  output-print " "

  output-type (word "Mean elasticity = " precision ( mean accumElasticities) 2 )
    if number-of-runs > 1 [ output-type (word " sd = " precision ( standard-deviation accumElasticities ) 2 ) ]
  output-print " "

  ; to produce percentage distribution of households by price elasticity
  set-current-plot "Price elasticities"
  set-plot-x-range -5 0
  set-plot-y-range 0 10
  set bar-interval 0.1 ; width of each bar
  plot-bar-chart-decrement accumElasticities

  output-print " "
  output-type (word "% households consuming at new price: mean = " precision ( mean accumConsumingAtNewPrice%) 2 )
   if number-of-runs > 1 [ output-type (word " sd = " precision ( standard-deviation accumConsumingAtNewPrice% ) 2 ) ]
  output-print " "

  output-type (word "% change in demand expenditure: mean = " precision ( mean accumChangeInTotalDemand% ) 2 )
     if number-of-runs > 1 [ output-type (word " sd = " precision ( standard-deviation accumChangeInTotalDemand% ) 2 ) ]
  output-print " "

  output-type (word "% change in total expenditure: mean = " precision ( mean accumChangeInTotalExpenditure% ) 2 )
     if number-of-runs > 1 [ output-type (word " sd = " precision ( standard-deviation accumChangeInTotalExpenditure% ) 2 ) ]
  output-print " "

  output-print " "
  output-print (word "Mean % changes in expenditure by quintile: " )
  output-print (word "Only households consuming at base perice included")
  output-type (word "Q1 " precision ( mean accumMeanExpenditureChangeQ1%) 2 )
       if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumMeanExpenditureChangeQ1%)  2 ) ]
  output-type (word "Q2 " precision ( mean accumMeanExpenditureChangeQ2%) 2 )
        if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumMeanExpenditureChangeQ2%)  2 ) ]
  output-type (word "Q3 " precision ( mean accumMeanExpenditureChangeQ3%) 2 )
        if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumMeanExpenditureChangeQ3%)  2 ) ]
  output-type (word "Q4 " precision ( mean accumMeanExpenditureChangeQ4%) 2 )
        if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumMeanExpenditureChangeQ4%)  2 ) ]
  output-type (word "Q5 " precision ( mean accumMeanExpenditureChangeQ5%) 2 )
        if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumMeanExpenditureChangeQ5%)  2 ) ]
  output-print " "

  output-print (word "Mean % consuming at new price by quintile: " )
  output-type (word "Q1 " precision ( mean accumConsumingAtNewPriceQ1%) 2 )
        if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumConsumingAtNewPriceQ1% ) 2 ) ]
  output-type (word "Q2 " precision ( mean accumConsumingAtNewPriceQ2%) 2 )
        if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumConsumingAtNewPriceQ2% ) 2 ) ]
  output-type (word "Q3 " precision ( mean accumConsumingAtNewPriceQ3%) 2 )
        if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumConsumingAtNewPriceQ3% ) 2 ) ]
  output-type (word "Q4 " precision ( mean accumConsumingAtNewPriceQ4%) 2 )
        if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumConsumingAtNewPriceQ4% ) 2 ) ]
  output-type (word "Q5 " precision ( mean accumConsumingAtNewPriceQ5%) 2 )
        if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumConsumingAtNewPriceQ5% ) 2 ) ]
  output-print " "

  output-type (word "Mean Overall Budget Share At New Price %: mean = " precision ( mean accumBSAtNewPrice%) 2 )
    if number-of-runs > 1 [ output-type (word " sd = " precision ( standard-deviation accumBSAtNewPrice% ) 2 ) ]
  output-print " "

  output-print " "
  output-print (word "Mean Tax Share %: " )
  output-type (word "Q1 " precision ( mean accumTaxShareQ1%) 2 )
       if number-of-runs > 1 [ output-print (word " sd = " precision ( standard-deviation accumTaxShareQ1% ) 2 ) ]
  output-type (word "Q2 " precision ( mean accumTaxShareQ2%) 2 )
       if number-of-runs > 1 [ output-print  (word " sd = " precision ( standard-deviation accumTaxShareQ2% ) 2 ) ]
  output-type (word "Q3 " precision ( mean accumTaxShareQ3%) 2 )
     if number-of-runs > 1 [ output-print  (word " sd = " precision ( standard-deviation accumTaxShareQ3%) 2 ) ]
  output-type (word "Q4 " precision ( mean accumTaxShareQ4%) 2 )
     if number-of-runs > 1 [ output-print  (word " sd = " precision ( standard-deviation accumTaxShareQ4%) 2 ) ]
  output-type (word "Q5 " precision ( mean accumTaxShareQ5%) 2 )
     if number-of-runs > 1 [ output-print  (word " sd = " precision ( standard-deviation accumTaxShareQ5% ) 2 ) ]
  output-print " "

  output-type (word "Overall ETR % = " precision ( mean accumOverallETR% ) 3 )
    if number-of-runs > 1 [ output-type (word " sd = " precision ( standard-deviation accumOverallETR%  ) 3 ) ]
  output-print " "

  output-print (word "Mean ETR %: " )
  output-type (word "Q1 " precision ( mean accumMeanETRQ1%) 3 )
        if number-of-runs > 1 [ output-print  (word " sd = " precision ( standard-deviation accumMeanETRQ1% ) 3 ) ]
  output-type (word "Q2 " precision ( mean accumMeanETRQ2%) 3 )
          if number-of-runs > 1 [ output-print  (word " sd = " precision ( standard-deviation accumMeanETRQ2% ) 3 ) ]
  output-type (word "Q3 " precision ( mean accumMeanETRQ3%) 3 )
         if number-of-runs > 1 [ output-print  (word " sd = " precision ( standard-deviation accumMeanETRQ3% ) 3 ) ]
  output-type (word "Q4 " precision ( mean accumMeanETRQ4%) 3 )
          if number-of-runs > 1 [ output-print  (word " sd = " precision ( standard-deviation accumMeanETRQ4% ) 3 ) ]
  output-type (word "Q5 " precision ( mean accumMeanETRQ5%) 3 )
          if number-of-runs > 1 [ output-print  (word " sd = " precision ( standard-deviation accumMeanETRQ5% ) 3 ) ]
  output-print " "


end
;-----------------------------------------
to plot-bar-chart-decrement [lst]
  ; requires a list of numbers, lst
  ; creates a bar chart, with each bar representing the percentage of the values in
  ; the given list of values, lst, that fall into the bar interval

  let lst-len length lst
  let percent-denom lst-len / 100
  let next-top-limit bar-interval

  while [ lst-len > 0 ] [
    set lst filter [? -> ? < next-top-limit ] lst
    plotxy next-top-limit (lst-len - length lst) / percent-denom
    set lst-len length lst
    set next-top-limit next-top-limit - bar-interval
  ]

end


to plot-bar-chart [lst]
  ; requires a list of numbers, lst
  ; creates a bar chart, with each bar representing the percentage of the values in
  ; the given list of values, lst, that fall into the bar interval

  let lst-len length lst
  let percent-denom lst-len / 100
  let next-top-limit bar-interval

  while [ lst-len > 0 ] [
    set lst filter [ ? -> ? >= next-top-limit ] lst
    plotxy next-top-limit (lst-len - length lst) / percent-denom
    set lst-len length lst
    set next-top-limit next-top-limit + bar-interval
  ]

end

;----------------------------------------
to generate-results-file

file-open ( word "Practical-demand-" runName ".csv"  )

file-type "RUN NAME, "
file-print runName

file-type "INPUTS"
file-print "  "

file-type "Number of runs , "
file-print number-of-runs
file-print "  "

file-type "Base Price , "
file-print basePrice

file-type "Change in price % , "
file-print changeInPrice%

file-type "Min demand cut-off , "
file-print minDemand
file-print "  "

file-type "Initial % Bottom Quintile Consuming , "
file-print initial%BottomQuintileConsuming
file-type "Initial % Lower Quintile Consuming , "
file-print initial%LowerQuintileConsuming
file-type "Initial % Middle Quintile Consuming , "
file-print initial%MiddleQuintileConsuming
file-type "Initial % Upper Quintile Consuming , "
file-print initial%UpperQuintileConsuming
file-type "Initial % Top Quintile Consuming , "
file-print initial%TopQuintileConsuming
file-print "  "

file-type "Mean Bottom Quintile Share % , "
file-print meanBottomQuintileShare%
file-type "Mean Lower Quintile Share % , "
file-print meanLowerQuintileShare%
file-type "Mean Middle Quintile Share % , "
file-print meanMiddleQuintileShare%
file-type "Mean Upper Quintile Share % , "
file-print meanUpperQuintileShare%
file-type "Mean Top Quintile Share % , "
file-print meanTopQuintileShare%
file-type "s.d. share %, "
file-print sdshare%
file-print "  "

file-type "Mean Bottom Elasticity , "
file-print meanBottomQuintileElasticity
file-type "Mean Lower Quintile Elasticity , "
file-print meanLowerQuintileElasticity
file-type "Mean Middle Quintile Elasticity , "
file-print meanMiddleQuintileElasticity
file-type "Mean Upper Quintile Elasticity, "
file-print meanUpperQuintileElasticity
file-type "Mean Top Quintile Elasticity , "
file-print meanTopQuintileElasticity
file-type "s.d elasticity, "
file-print sdElasticity
file-print "  "


file-type "OUTPUTS "
file-print "  "

  file-print ( word "Results over "  number-of-runs " runs" )
  file-print " "

  file-type (word "Mean budget = ," precision ( mean accumMeanBudget ) 2 )
    if number-of-runs > 1 [ file-type (word ", sd = ," precision ( standard-deviation accumMeanBudget ) 2 ) ]
  file-print " "

  file-type (word "Gini: mean = ," precision ( mean accumGini ) 3 )
       if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumGini ) 3 ) ]
  file-print " "

  file-type (word "% households consuming at base price: mean = ," precision ( mean accumConsumingAtBasePrice% ) 1 )
   if number-of-runs > 1 [ file-type (word ", sd = ," precision ( standard-deviation accumConsumingAtBasePrice% ) 1 ) ]
  file-print " "

  file-type (word "Mean Overall Budget Share At Base Price %: mean = ," precision ( mean accumBSAtBasePrice%) 2 )
  if number-of-runs > 1 [ file-type (word ", sd = ," precision ( standard-deviation accumBSAtBasePrice% ) 2 ) ]
  file-print " "

  file-print (word "Mean expenditure share by quintile %: ," )
  file-type (word "Q1, " precision ( mean accumQuintileExpenditureQ1%) 2 )
          if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumQuintileExpenditureQ1% ) 2 ) ]
  file-type (word "Q2, " precision ( mean accumQuintileExpenditureQ2%) 2 )
          if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumQuintileExpenditureQ2% ) 2 ) ]
  file-type (word "Q3, " precision ( mean accumQuintileExpenditureQ3%) 2 )
          if number-of-runs > 1 [ file-print (word ", sd =, " precision ( standard-deviation accumQuintileExpenditureQ3% ) 2 ) ]
  file-type (word "Q4, " precision ( mean accumQuintileExpenditureQ4%) 2 )
          if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumQuintileExpenditureQ4% ) 2 ) ]
  file-type (word "Q5 ," precision ( mean accumQuintileExpenditureQ5%) 2 )
          if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumQuintileExpenditureQ5% ) 2 ) ]
  file-print " "

  file-print (word "Mean % consuming at base price by quintile: ," )
  file-type (word "Q1 ," precision ( mean accumConsumingAtBasePriceQ1%) 2 )
              if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumConsumingAtBasePriceQ1% ) 2 ) ]
  file-type (word "Q2 ," precision ( mean accumConsumingAtBasePriceQ2%) 2 )
              if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumConsumingAtBasePriceQ2% ) 2 ) ]
  file-type (word "Q3 ," precision ( mean accumConsumingAtBasePriceQ3%) 2 )
              if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumConsumingAtBasePriceQ3% ) 2 ) ]
  file-type (word "Q4 ," precision ( mean accumConsumingAtBasePriceQ4%) 2 )
              if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumConsumingAtBasePriceQ4% ) 2 ) ]
  file-type (word "Q5 ," precision ( mean accumConsumingAtBasePriceQ5%) 2 )
              if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumConsumingAtBasePriceQ5% ) 2 ) ]
  file-print " "

  file-type (word "Mean elasticity = ," precision ( mean accumElasticities) 2 )
    if number-of-runs > 1 [ file-type (word ", sd = ," precision ( standard-deviation accumElasticities ) 2 ) ]
  file-print " "

  file-print " "
  file-type (word "% households consuming at new price: mean = ," precision ( mean accumConsumingAtNewPrice%) 2 )
   if number-of-runs > 1 [ file-type (word ", sd = ," precision ( standard-deviation accumConsumingAtNewPrice% ) 2 ) ]
  file-print " "

  file-type (word "% change in demand expenditure: mean = ," precision ( mean accumChangeInTotalDemand% ) 2 )
     if number-of-runs > 1 [ file-type (word ", sd = ," precision ( standard-deviation accumChangeInTotalDemand% ) 2 ) ]
  file-print " "

  file-type (word "% change in total expenditure: mean = ," precision ( mean accumChangeInTotalExpenditure% ) 2 )
     if number-of-runs > 1 [ file-type (word ", sd = ," precision ( standard-deviation accumChangeInTotalExpenditure% ) 2 ) ]
  file-print " "

  file-print " "
  file-print (word "Mean % changes in expenditure by quintile: ," )
  file-print (word "Only households consuming at base perice included")
  file-type (word "Q1 ," precision ( mean accumMeanExpenditureChangeQ1%) 2 )
       if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumMeanExpenditureChangeQ1%)  2 ) ]
  file-type (word "Q2, " precision ( mean accumMeanExpenditureChangeQ2%) 2 )
        if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumMeanExpenditureChangeQ2%)  2 ) ]
  file-type (word "Q3 ," precision ( mean accumMeanExpenditureChangeQ3%) 2 )
        if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumMeanExpenditureChangeQ3%)  2 ) ]
  file-type (word "Q4 ," precision ( mean accumMeanExpenditureChangeQ4%) 2 )
        if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumMeanExpenditureChangeQ4%)  2 ) ]
  file-type (word "Q5 ," precision ( mean accumMeanExpenditureChangeQ5%) 2 )
        if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumMeanExpenditureChangeQ5%)  2 ) ]
  file-print " "

  file-print (word "Mean % consuming at new price by quintile: ," )
  file-type (word "Q1 ," precision ( mean accumConsumingAtNewPriceQ1%) 2 )
        if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumConsumingAtNewPriceQ1% ) 2 ) ]
  file-type (word "Q2 ," precision ( mean accumConsumingAtNewPriceQ2%) 2 )
        if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumConsumingAtNewPriceQ2% ) 2 ) ]
  file-type (word "Q3 ," precision ( mean accumConsumingAtNewPriceQ3%) 2 )
        if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumConsumingAtNewPriceQ3% ) 2 ) ]
  file-type (word "Q4 ," precision ( mean accumConsumingAtNewPriceQ4%) 2 )
        if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumConsumingAtNewPriceQ4% ) 2 ) ]
  file-type (word "Q5 ," precision ( mean accumConsumingAtNewPriceQ5%) 2 )
        if number-of-runs > 1 [ file-print (word ", sd =, " precision ( standard-deviation accumConsumingAtNewPriceQ5% ) 2 ) ]
  file-print " "

  file-type (word "Mean Overall Budget Share At New Price %: mean =, " precision ( mean accumBSAtNewPrice%) 2 )
    if number-of-runs > 1 [ file-type (word ", sd = ," precision ( standard-deviation accumBSAtNewPrice% ) 2 ) ]
  file-print " "

  file-print " "
  file-print (word "Mean Tax Share %: ," )
  file-type (word "Q1 ," precision ( mean accumTaxShareQ1%) 2 )
       if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumTaxShareQ1% ) 2 ) ]
  file-type (word "Q2 ," precision ( mean accumTaxShareQ2%) 2 )
       if number-of-runs > 1 [ file-print  (word ", sd = ," precision ( standard-deviation accumTaxShareQ2% ) 2 ) ]
  file-type (word "Q3 ," precision ( mean accumTaxShareQ3%) 2 )
     if number-of-runs > 1 [ file-print  (word ", sd = ," precision ( standard-deviation accumTaxShareQ3%) 2 ) ]
  file-type (word "Q4 ," precision ( mean accumTaxShareQ4%) 2 )
     if number-of-runs > 1 [ file-print  (word ", sd = ," precision ( standard-deviation accumTaxShareQ4%) 2 ) ]
  file-type (word "Q5 ," precision ( mean accumTaxShareQ5%) 2 )
     if number-of-runs > 1 [ file-print  (word ", sd = ," precision ( standard-deviation accumTaxShareQ5% ) 2 ) ]
  file-print " "

  file-type (word "Overall ETR % = ," precision ( mean accumOverallETR% ) 3 )
    if number-of-runs > 1 [ file-print (word ", sd = ," precision ( standard-deviation accumOverallETR%  ) 3 ) ]
  file-print " "

  file-print (word "Mean ETR %: " )
  file-type (word "Q1 ," precision ( mean accumMeanETRQ1%) 3 )
        if number-of-runs > 1 [ file-print  (word ", sd = ," precision ( standard-deviation accumMeanETRQ1% ) 3 ) ]
  file-type (word "Q2 ," precision ( mean accumMeanETRQ2%) 3 )
          if number-of-runs > 1 [ file-print  (word ", sd =, " precision ( standard-deviation accumMeanETRQ2% ) 3 ) ]
  file-type (word "Q3 , " precision ( mean accumMeanETRQ3%) 3 )
         if number-of-runs > 1 [ file-print  (word ", sd = ," precision ( standard-deviation accumMeanETRQ3% ) 3 ) ]
  file-type (word "Q4 ," precision ( mean accumMeanETRQ4%) 3 )
          if number-of-runs > 1 [ file-print  (word ", sd = ," precision ( standard-deviation accumMeanETRQ4% ) 3 ) ]
  file-type (word "Q5 ," precision ( mean accumMeanETRQ5%) 3 )
          if number-of-runs > 1 [ file-print  (word ", sd =, " precision ( standard-deviation accumMeanETRQ5% ) 3 ) ]
  file-print " "



file-close

export-all-plots (word "Practical-demand-plots-" runName ".csv" )

end

;_____________________________________________________________________________________________________________________
;_____________________________________________________________________________________________________________________
@#$#@#$#@
GRAPHICS-WINDOW
37
1404
335
1703
-1
-1
2.8713
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
7
10
71
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
542
620
828
857
Demand at base price
Demand
Per cent of households
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
424
11
562
56
basePrice
basePrice
0.1 0.5 1 2 3 4 5
2

SLIDER
272
124
510
157
meanBottomQuintileShare%
meanBottomQuintileShare%
0
50
15.0
.5
1
NIL
HORIZONTAL

SLIDER
277
209
511
242
meanMiddleQuintileShare%
meanMiddleQuintileShare%
0
50
12.0
.5
1
NIL
HORIZONTAL

SLIDER
275
250
509
283
meanUpperQuintileShare%
meanUpperQuintileShare%
0
50
10.0
.5
1
NIL
HORIZONTAL

SLIDER
276
294
507
327
meanTopQuintileShare%
meanTopQuintileShare%
0
50
8.0
0.5
1
NIL
HORIZONTAL

SLIDER
277
164
509
197
meanLowerQuintileShare%
meanLowerQuintileShare%
0
50
13.0
0.5
1
NIL
HORIZONTAL

CHOOSER
423
65
561
110
changeInPrice%
changeInPrice%
-10 -1 -0.1 0.1 1 5 10
6

SLIDER
526
126
760
159
meanBottomQuintileElasticity
meanBottomQuintileElasticity
0.1
5
0.6
0.1
1
NIL
HORIZONTAL

SLIDER
527
168
760
201
meanLowerQuintileElasticity
meanLowerQuintileElasticity
0.1
5
0.6
0.1
1
NIL
HORIZONTAL

SLIDER
527
209
758
242
meanMiddleQuintileElasticity
meanMiddleQuintileElasticity
0.1
5
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
526
251
760
284
meanUpperQuintileElasticity
meanUpperQuintileElasticity
0.1
5
0.4
0.1
1
NIL
HORIZONTAL

SLIDER
526
293
757
326
meanTopQuintileElasticity
meanTopQuintileElasticity
0.1
5
0.3
0.1
1
NIL
HORIZONTAL

INPUTBOX
183
10
381
70
runName
food2
1
0
String

SLIDER
279
335
409
368
sdShare%
sdShare%
0
5
2.0
0.25
1
NIL
HORIZONTAL

SLIDER
3
126
262
159
initial%BottomQuintileConsuming
initial%BottomQuintileConsuming
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
3
168
259
201
initial%LowerQuintileConsuming
initial%LowerQuintileConsuming
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
3
212
260
245
initial%MiddleQuintileConsuming
initial%MiddleQuintileConsuming
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
5
250
259
283
initial%UpperQuintileConsuming
initial%UpperQuintileConsuming
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
6
291
257
324
initial%TopQuintileConsuming
initial%TopQuintileConsuming
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
184
74
356
107
minDemand
minDemand
0
0.5
0.0
.1
1
NIL
HORIZONTAL

SLIDER
529
332
679
365
sdElasticity
sdElasticity
0
1
0.1
0.1
1
NIL
HORIZONTAL

PLOT
544
866
828
1110
Price elasticities
Elasticity
Per cent of households
-5.0
0.0
0.0
10.0
true
false
"" ""
PENS
"default" 0.1 1 -16777216 false "" ""

CHOOSER
611
22
749
67
number-of-runs
number-of-runs
1 10 30 100
2

OUTPUT
27
395
522
1400
12

PLOT
543
400
827
611
Budget shares
Budget shares %
Per cent of households
0.0
20.0
0.0
20.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

@#$#@#$#@
## WHAT IS IT?

Estimates the impact of price changes on demand using price elasticities and budget shares only. (As it does not start with a utility function, it does not draw a demand curve.)

## HOW IT WORKS

Budgets are distributed to give a Gini coefficient of about a third (using the procedure set out in the Budget distribution model). The average budget is always 100. 

The percentage of households consuming are given by 5 sliders, but the actual figures used will depend on the minimum demand. This minimum is needed to ensure that a price change can result in a reduction in the percentage consuming (although this only tends to happen for small budgets and high price elasticities.)

The mean budget shares for each budget quintile is given by the 5 sliders combined with the budget share standard deviation (which is the same for all quintiles). For each quintile, the budget shares are allocated randomly using a normal distribution based on these parameters. For example, for those in the bottom quintile: 

    ask  households with [ quintileGroup = 1 ]  [ set budgetShare% precision (random-normal meanBottomQuintileShare% sdShare% ) 2 ]     

The elasticities are set similarly. For example, for the bottom quintile:
  
    ask households with [ quintileGroup = 1 ] 
    [ set priceElasticity  ( - random-normal  meanBottomQuintileElasticity sdElasticity ) ]

The key operational line is:

    ask households 
    [ set demandNewPrice ( demandBasePrice * ( 1 + ( priceElasticity  * ( changeInPrice% / 100) ) ) ) ]

The model allows you to view the price change as an imposition of a tax and calculates much tax each qunitile would pay and what the effective tax rate would be for each household i.e.

    effectiveTaxRate = taxPaid / budget x 100


The output data is also sent to 2 csv files, one for plots the other for the rest of the output data. The files are given the runName.

## HOW TO USE IT

Set the percentage of households consuming in each quintile. If all households always consume, these sliders should be set to 100 and minDemand to zero for example, for food.

Choose the mean budget shares for each quintile, the budget share standard deviation and the mean price elasticities for each quintile and the elasticity standard deviation. (Set the elasticities as positive values - the progam will add the minus signs.)

Assign a runName.

If desired change the basePrice from 1 or change to percentage change in from 10.


## CREDITS AND REFERENCES

For calculation of Gini coefficient:
Wilensky, U. (1998) NetLogo Wealth Distribution model. http://ccl.northwestern.edu/netlogo/models/WealthDistribution. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Runs on NetLogo 5.2.

For more information, see Hamill, L. & Gilbert, N. (2016) Agent-based Modelling in Economics. Wiley: Chapter 3.

To refer to this model: Hamill, L. & Gilbert, N. (2016) Practical demand model.
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
<experiments>
  <experiment name="luxury4" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <steppedValueSet variable="counter" first="1" step="1" last="30"/>
  </experiment>
</experiments>
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
