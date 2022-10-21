globals

[
runCounter
nOfPrisoners nOfSmokers
initialCigs
totalChocs totalCigs
totalInitialUtility

maxChocs maxCigs
minChocs minCigs

; to draw demand and supply curves etc
priceChocs totalDemand totalSupply excessDemand minExcessDemand initialMCPrice finalMCPrice

; trading
 roundCounter
 totalQuantityThisRound
 averagePriceThisRound   averagePriceFirstRound averagePriceSecondRound averagePriceThirdRound averagePriceFourthRound averagePriceFifthRound averagePriceTenthRound
 averageQuantityThisRound averageQuantityFirstRound averageQuantitySecondRound averageQuantityThirdRound averageQuantityFourthRound averageQuantityFifthRound  averageQuantityTenthRound
 totalExpenditureThisRound  totalExpenditureFirstRound totalExpenditureSecondRound totalExpenditureThirdRound totalExpenditureFourthRound totalExpenditureFifthRound totalExpenditureTenthRound
 ; averagePrice totalExpenditure totalQuantity totalNOfTrades

 tradedThisRound%
 traders% tradersFirstRound% tradersSecondRound% tradersThirdRound% tradersFourthRound% tradersFifthRound% tradersTenthRound%
 totalTradersFirstRound% totalTradersSecondRound% totalTradersThirdRound%  totalTradersFourthRound%  totalTradersFifthRound% totalTradersTenthRound%

 increasedUtility% increaseTotalUtility%
 increaseTotalUtility%FirstRound increaseTotalUtility%SecondRound increaseTotalUtility%ThirdRound increaseTotalUtility%FourthRound increaseTotalUtility%FifthRound  increaseTotalUtility%TenthRound
 checkUtility

 ; to accumulate data
 accumInitialMCPrice accumFinalMCPrice
 accumAveragePriceFirstRound accumAveragePriceSecondRound accumAveragePriceThirdRound accumAveragePriceFourthRound accumAveragePriceFifthRound accumAveragePriceTenthRound
 ; accumAveragePrice accumTotalQuantity accumTotalExpenditure
 accumAverageQuantityFirstRound  accumAverageQuantitySecondRound  accumAverageQuantityThirdRound  accumAverageQuantityFourthRound accumAverageQuantityFifthRound accumAverageQuantityTenthRound
 accumExpenditureFirstRound  accumExpenditureSecondRound  accumExpenditureThirdRound  accumExpenditureFourthRound accumExpenditureFifthRound accumExpenditureTenthRound

 ;accumNOfTrades accumTraders%
 accumTradersFirstRound% accumTradersSecondRound% accumTradersThirdRound% accumTradersFourthRound% accumTradersFifthRound% accumTradersTenthRound%
 accumTotalTradersFirstRound% accumTotalTradersSecondRound%  accumTotalTradersThirdRound% accumTotalTradersFourthRound%  accumTotalTradersFifthRound%  accumTotalTradersTenthRound%

 ; accumIncreaseTotalUtility%
 accumIncreaseTotalUtility%FirstRound  accumIncreaseTotalUtility%SecondRound  accumIncreaseTotalUtility%ThirdRound  accumIncreaseTotalUtility%FourthRound accumIncreaseTotalUtility%FifthRound  accumIncreaseTotalUtility%TenthRound
]

breed [prisoners prisoner]

prisoners-own
  [
    alpha beta
    chocs cigs
    preftype
    initialUtility  utility
    mrs

    ; trading
    partner
    tradertype
    price

    optimal  excessDemandChocs   offerCigs
    excessSupplyChocs  offerChocs sellersOffer
    dealChocs dealCigs
    effectivePrice

    tradedThisRound nOfTrades

    ; required to calculate demand and supply curves
    budget  optimalChocs demand supply

   ]

;____________________________________________________________________________________________________________________________________________
to setup

  clear-all
  ask patches  [set pcolor white]

; to accumulate data over runs

 set accumInitialMCPrice [ ]
 set accumFinalMCPrice [ ]
 set accumAveragePriceFirstRound [ ]
 set accumAveragePriceSecondRound [ ]
 set accumAveragePriceThirdRound [ ]
 set accumAveragePriceFourthRound [ ]
 set accumAveragePriceFifthRound [ ]
 set accumAveragePriceTenthRound [  ]

 set accumAverageQuantityFirstRound [ ]
 set accumAverageQuantitySecondRound [ ]
 set accumAverageQuantityThirdRound [ ]
 set accumAverageQuantityFourthRound [ ]
 set accumAverageQuantityFifthRound [ ]
 set accumAverageQuantityTenthRound [  ]

 set accumExpenditureFirstRound [  ]
 set accumExpenditureSecondRound [  ]
 set accumExpenditureThirdRound [  ]
 set accumExpenditureFourthRound [  ]
 set accumExpenditureFifthRound [  ]
 set accumExpenditureTenthRound [  ]

 set accumTradersFirstRound% [  ]
 set accumTradersSecondRound% [  ]
 set accumTradersThirdRound% [  ]
 set accumTradersFourthRound% [  ]
 set accumTradersFifthRound% [  ]
 set accumTradersTenthRound% [ ]

 set accumTotalTradersFirstRound% [  ]
 set accumTotalTradersSecondRound% [  ]
 set accumTotalTradersThirdRound% [  ]
 set accumTotalTradersFourthRound% [  ]
 set accumTotalTradersFifthRound% [  ]
 set accumTotalTradersTenthRound% [  ]


 set accumIncreaseTotalUtility%FirstRound [ ]
 set accumIncreaseTotalUtility%SecondRound [ ]
 set accumIncreaseTotalUtility%ThirdRound [ ]
 set accumIncreaseTotalUtility%FourthRound [ ]
 set accumIncreaseTotalUtility%FifthRound [ ]
 set accumIncreaseTotalUtility%TenthRound [ ]

reset-ticks
end

;__________________________________________________________________

to go

repeat number-of-runs

  [

   reset-globals
   reset-prisoners

   set runCounter runCounter + 1

   set-alphas
   ask prisoners [ distribute-goods ]

   calculate-utility
   ask prisoners [ set initialUtility utility ]
   set totalInitialUtility   sum [ initialUtility ] of prisoners

   calculate-mrs
   draw-initial-demand-and-supply-curves

   repeat number-of-rounds  [ trade ]

   draw-final-demand-and-supply-curves

   collect-data

 if runCounter = 1
     [ file-open (word "firstrun-" priceSetting "-" initialChocs "-" %smokers "-" number-of-rounds ".csv" )
       export-all-plots (word "firstrun-" priceSetting "-" initialChocs "-" %smokers  "-" number-of-rounds".csv" )
       file-close
     ]
  ]

report-results

end

;_________________________________________________________________________________________________________________
; PROCEDURES
;_________________________________________________________________________________________________________________

to reset-globals
; This cannot be done in setup because it needs to be done for each run.

; to draw demand and supply curves etc

 set priceChocs 0
 set totalDemand 0
 set totalSupply 0
 set excessDemand 0
 set minExcessDemand 0
 set initialMCPrice 0
 set finalMCPrice 0

; trading
 set roundCounter 0

 set totalQuantityThisRound 0

 set averageQuantityThisRound 0
 set averageQuantityFirstRound 0
 set averageQuantitySecondRound 0
 set averageQuantityThirdRound 0
 set averageQuantityFourthRound 0
 set averageQuantityFifthRound 0
 set averageQuantityTenthRound 0

 set totalExpenditureThisRound 0
 set totalExpenditureFirstRound 0
 set totalExpenditureSecondRound 0
 set totalExpenditureThirdRound 0
 set totalExpenditureFourthRound 0
 set totalExpenditureFifthRound 0
 set totalExpenditureTenthRound 0

 set averagePriceThisRound 0
 set averagePriceFirstRound 0
 set averagePriceSecondRound 0
 set averagePriceThirdRound 0
 set averagePriceFourthRound 0
 set averagePriceFifthRound 0
 set averagePriceTenthRound 0

; traders
 set traders% 0
 set tradedThisRound%  0

 set tradersFirstRound% 0
 set tradersSecondRound% 0
 set tradersThirdRound% 0
 set tradersFourthRound% 0
 set tradersFifthRound% 0
 set tradersTenthRound% 0

 set totalTradersFirstRound% 0
 set totalTradersSecondRound% 0
 set totalTradersThirdRound% 0
 set totalTradersFourthRound% 0
 set totalTradersFifthRound% 0
 set totalTradersTenthRound% 0

; utility
 set totalInitialUtility 0
 set increasedUtility% 0

 set increaseTotalUtility% 0
 set increaseTotalUtility%FirstRound 0
 set increaseTotalUtility%SecondRound 0
 set increaseTotalUtility%ThirdRound 0
 set increaseTotalUtility%FourthRound 0
 set increaseTotalUtility%FifthRound 0
 set increaseTotalUtility%TenthRound 0

 set checkUtility 0

end

;------------------------------------------

to reset-prisoners
; This cannot be done in setup because it needs to be done for each run.

clear-turtles
set nOfPrisoners 200

create-prisoners nOfPrisoners [
     set shape "person"
     set color black
     set size 3
     setxy random-pxcor random-pycor
   ;      while [any? other turtles-here] [ fd 1 ]
   ]


end
;---------------------

to set-alphas

set nOfSmokers ( %smokers / 100 ) * nOfPrisoners

; smokers have alpaha < 0.5
ask n-of nOfSmokers prisoners
  [ set alpha precision ( 0.001 +  ( random 499 ) / 1000 ) 3
    set beta precision (1 - alpha ) 3
    set color red
    set preftype "smoker"
  ]

; chocLovers have alpha > 0.5
ask prisoners with [ prefType != "smoker" ]
   [ set alpha precision ( 0.501 +  ( random 499 ) / 1000 ) 3
     set color black
     set preftype "chocLover"
   ]

ask prisoners [ set beta precision (1 - alpha ) 3 ]

end

;-------------------------------

to distribute-goods

 set initialCigs ( 100 - initialChocs )

 ask prisoners [ set chocs initialChocs
              set cigs  initialCigs  ]

 set totalChocs sum [ chocs ] of prisoners
 set totalCigs sum [ cigs ] of prisoners

end

;----------------------------

to calculate-utility
; Cobb-Douglas utility function

 ask prisoners  [  set utility  precision ( ( chocs ^ alpha ) * ( cigs ^ beta ) ) 2 ]

end

;-------------------------

to calculate-mrs
; based on Cobb-Douglas  utilityfunction
 ask prisoners
 [
 set mrs  precision ( ( alpha * cigs )  / ( beta * chocs) ) 3
 ]

end

;-------------------

to draw-initial-demand-and-supply-curves
; on basis that alpa + beta = 1

set priceChocs 0.1
set minExcessDemand totalChocs ; to set an inital max

repeat 100
[  set-demand-and-supply

   if abs excessDemand < minExcessDemand
      [ set minExcessDemand abs excessDemand
        set initialMCPrice priceChocs ]
      if runCounter = 1 [ plot-initial-demand-and-supply ]
   reset-for-next-repeat
]

set accumInitialMCPrice  ( fput initialMCPrice accumInitialMCPrice )

end
;-------------------
to draw-final-demand-and-supply-curves
; formulae work on basis that alpa + beta = 1 and Price of B = 1

 set priceChocs 0.1
 set minExcessDemand totalChocs


 repeat 100
 [ set-demand-and-supply

   if abs excessDemand < minExcessDemand
       [ set minExcessDemand abs excessDemand
         set finalMCPrice priceChocs ]

  if runCounter = 1  [ plot-final-demand-and-supply ]

  reset-for-next-repeat
 ]

 set accumFinalMCPrice  ( fput finalMCPrice accumFinalMCPrice )

end
;----------

to set-demand-and-supply
  ; calculates budget
   ask prisoners [ set budget ( chocs * priceChocs ) + cigs  ]
  ; calculates optimal chocolate
   ask prisoners [ set  optimalChocs round ( budget * alpha / priceChocs ) ]
   ask prisoners with [ optimalChocs < 1 ] [ set optimalChocs 1 ]
  ; calculates excess demand/supply i.e. allowing for how much the prisoner has already
   ask prisoners with [ ( optimalChocs - chocs ) > 0 ] [ set demand ( optimalChocs - chocs ) ]
   ask prisoners with [ ( optimalChocs - chocs ) = 0 ] [ set demand 0 set supply 0 ] ; probably not needed
   ask prisoners with [ ( optimalChocs - chocs ) < 0 ] [ set supply ( chocs - optimalChocs ) ]
 ; sums over all prisoners
   set totalDemand sum [ demand ] of prisoners
   set totalSupply sum [ supply ] of prisoners
   set excessDemand totalDemand - totalSupply

end

;----------
to reset-for-next-repeat

 set priceChocs priceChocs + 0.1
 ask prisoners [ set budget 0 set optimalChocs 0 set demand 0  set supply 0  ]
 set totalDemand 0
 set totalSupply 0
 set excessDemand 0

end

;--------------------------
to trade

set roundCounter roundCounter + 1
; clear previous trades
ask prisoners [ set partner nobody
             set tradertype 0  set price 0 set effectivePrice 0 set optimal 0
             set excessDemandChocs 0   set offerCigs 0
             set excessSupplyChocs 0  set offerChocs 0 set sellersOffer 0
             set dealCigs 0 set dealChocs 0
             set tradedThisRound "No"]

calculate-mrs

; buyers identify sellers within reach and choose one at random who doesn't already have a partner themselves
; so once a partner has been identified, it needs to be logged
 ask prisoners with [ preftype = "chocLover" ]
   [  set partner one-of other prisoners in-radius reach with [ preftype = "smoker" and partner = nobody ]
     if partner != nobody
      [  set tradertype "buyer"
         ask partner [ set partner myself
                       set tradertype "seller"  ]
      ]
    ]

; PRICES
; if pay 10 cigs for 5 chocs, then the price of chocs in terms of cigs is 2.
; if pay 10 cigs for 10 chocs, then the price of chocs in terms of cigs is 1
; if pay 10 cigs for 20 chocs, then the price of chocs in terms of cigs is 0.5 i.e. 2 chocs per cig: so choc buyer has to give twice as many cigs as receives chocs
; if price < 1, more than 1 choc will be given for 1 cig. If this is not provided for, then
; when the number of initialChocs exceeds the number of initialCigs, there won't be any trading!
; to ensure whole numbers of cigs are exchanged for whole numbers of chocs, need to round to 3 dec places for auctioneer ; and so do the same for other methods

; price set on basis of demand and supply curves
if priceSetting = "Auctioneer"
 [  ask prisoners with [ tradertype = "buyer" ]  [ set price precision initialMCPrice 3] ]

; buyer and seller negotiate price on basis of equiblirium price formala
if priceSetting = "Equilibrium"
 [
   ask prisoners with [ tradertype = "buyer" ]
   [  set price  precision (
                           ( ( alpha * cigs ) + [ alpha * cigs ] of partner )  /
                           ( ( beta * chocs ) + [ beta  * chocs ] of partner ) )    3 ]
 ]

; buyer and seller negotiate price random between the two MRSs
   ; price to lie between mrs of both prisoners. If equal, no trade anyway.

 if priceSetting = "Random"
   [ ask prisoners with [ tradertype = "buyer" ]
    [
      let minMRS min list ( mrs ) ( [ mrs ] of partner )
      let maxMRS max list ( mrs ) ( [ mrs ] of partner )
      set price precision ( minMRS  + random ( maxMRS - minMRS )) 3
    ]
   ]

; buyer transmits price to seller

  ask prisoners with [ tradertype = "buyer" ]
   [ ask partner  [ set price [ price ] of myself ] ]

; buyer determines how much to buy at negotiated price

ask prisoners with [ tradertype = "buyer" and price > 0 ]
         [  set budget ( chocs * price ) + cigs
            set optimal ( budget * alpha / price )
            set excessDemandChocs ( optimal - chocs ) ; what buyer would like
            set offerCigs min list ( excessDemandChocs * price ) ( cigs - 1) ; what buyer can afford, ensuring always hold at least 1 cig, rounded down
            set offerChocs 0;offerCigs / price
          ]

; seller determines how much to sell at negotiated price
ask prisoners with [ tradertype = "seller" and price > 0 ]
         [ set budget ( chocs * price ) + cigs
           set optimal ( budget * alpha / price )
           set excessSupplyChocs ( chocs - optimal )
           set offerChocs min list ( excessSupplyChocs ) (chocs - 1 ) ; what seller can afford, ensuring always hold at least 1 choc
           set offerCigs 0
          ]

; compare offers and set deal
; round down using floor to ensure only whole numbers traded and only and the utility not reduced by exhanging too much
; seller transmits offer to buyer
ask prisoners with [ tradertype = "buyer" ]
     [
       set sellersOffer [ offerChocs ] of partner
       set dealChocs floor min list ( offerChocs )  ( sellersOffer )
       set dealCigs floor ( dealChocs * price )
     ]



; buyer sets deal as the smallest of offer; deal is the number of chocs
ask prisoners with [ tradertype = "seller" ]
      [ set dealChocs [ dealChocs ] of partner
        set dealCigs  [ dealCigs ] of partner]

; to prevent prisoners from holding less than 1 choc or cig
ask prisoners with [ dealChocs < 1 or dealCigs < 1 ] [ cancel-deal ]

; deal done and recorded
; buyer gains chocs = deal but loses cigs = deal * price; opposite for seller
ask prisoners with [tradertype = "buyer"]
      [ set chocs ( chocs + dealChocs  )
        set cigs  ( cigs -  dealCigs )
        set effectivePrice ( dealCigs / dealChocs )
        set tradedThisRound "Yes"
        set nOfTrades nOfTrades + 1 ]

ask prisoners with [tradertype = "seller"]
      [ set chocs ( chocs - dealChocs  )
        set cigs  ( cigs + dealCigs  )
        set effectivePrice ( dealCigs / dealChocs )
        set tradedThisRound "Yes"
        set nOfTrades nOfTrades + 1 ]

;-------------------------
; collect data at end of round

  ; prices
   ; Expenditure on chocolate = effectivePrice x quantity of chocolate.
   ; But by definition, expenditure on chocolate = no. of cigarettes given in exchange
   ; So to calculate the price taking account of the quantity, need to set
   ; price = expenditure / quantity of chocolates = quanitity of cigarettes / quantity of chocolates

  if ( count prisoners with [tradertype = "buyer" and tradedThisRound = "Yes" ]  > 0 )
    [ set totalQuantityThisRound  sum [ dealChocs ] of prisoners with [ tradertype = "buyer" and tradedThisRound = "Yes" ]
      set averageQuantityThisRound  mean [ dealChocs ] of prisoners with [ tradertype = "buyer" and tradedThisRound = "Yes"]
    ;  set totalQuantity totalQuantityThisRound + totalQuantity
      if roundCounter = 1 [ set averageQuantityFirstRound averageQuantityThisRound ]
      if roundCounter = 2 [ set averageQuantitySecondRound averageQuantityThisRound ]
      if roundCounter = 3 [ set averageQuantityThirdRound averageQuantityThisRound ]
      if roundCounter = 4 [ set averageQuantityFourthRound averageQuantityThisRound ]
      if roundCounter = 5 [ set averageQuantityFifthRound averageQuantityThisRound ]
      if roundCounter = 10 [ set averageQuantityTenthRound averageQuantityThisRound ]

      set totalExpenditureThisRound sum [ dealCigs ] of prisoners with [ tradertype = "buyer" and tradedThisRound = "Yes" ]
   ;   set totalExpenditure totalExpenditureThisRound + totalExpenditure
      if roundCounter = 1 [ set totalExpenditureFirstRound totalExpenditureThisRound ]
       if roundCounter = 2 [ set totalExpenditureSecondRound totalExpenditureThisRound ]
       if roundCounter = 3 [ set totalExpenditureThirdRound totalExpenditureThisRound ]
       if roundCounter = 4 [ set totalExpenditureFourthRound totalExpenditureThisRound ]
      if roundCounter = 5 [ set totalExpenditureFifthRound totalExpenditureThisRound ]
      if roundCounter = 10 [ set totalExpenditureTenthRound totalExpenditureThisRound ]

      set averagePriceThisRound ( totalExpenditureThisRound / totalQuantityThisRound  )
   ;   set averagePrice ( totalExpenditure / totalQuantity )
      if roundCounter = 1 [ set averagePriceFirstRound averagePriceThisRound ]
      if roundCounter = 2 [ set averagePriceSecondRound averagePriceThisRound ]
      if roundCounter = 3 [ set averagePriceThirdRound averagePriceThisRound ]
      if roundCounter = 4 [ set averagePriceFourthRound averagePriceThisRound ]
      if roundCounter = 5 [ set averagePriceFifthRound averagePriceThisRound ]
      if roundCounter = 10 [ set averagePriceTenthRound averagePriceThisRound ]
    ]

  ; traders

  set tradedThisRound% count prisoners with [ tradedThisRound = "Yes" ] / nOfPrisoners * 100

  if roundCounter = 1 [ set tradersFirstRound% tradedThisRound% ]
  if roundCounter = 2 [ set tradersSecondRound% tradedThisRound%]
  if roundCounter = 3 [ set tradersThirdRound% tradedThisRound% ]
  if roundCounter = 4 [ set tradersFourthRound% tradedThisRound% ]
  if roundCounter = 5 [ set tradersFifthRound% tradedThisRound% ]
  if roundCounter = 10 [ set tradersTenthRound% tradedThisRound% ]

  set traders% count prisoners with [ nOfTrades > 0 ] / nOfPrisoners * 100

  if roundCounter = 1 [ set totalTradersFirstRound% traders% ]  ; should be same as tradersFirstRound%
  if roundCounter = 2 [ set totalTradersSecondRound% traders%]
  if roundCounter = 3 [ set totalTradersThirdRound% traders%]
  if roundCounter = 4 [ set totalTradersFourthRound% traders% ]
  if roundCounter = 5 [ set totalTradersFifthRound% traders% ]
  if roundCounter = 10 [ set totalTradersTenthRound% traders% ]



  ; utility
  ask prisoners with [ tradedThisRound = "Yes" ] [ calculate-utility ]

  set increasedUtility% count prisoners with [ (utility - initialUtility) > 0 ] / nOfPrisoners * 100

  set increaseTotalUtility% ( sum [ utility ] of prisoners - totalInitialUtility ) / totalInitialUtility * 100

  if roundCounter = 1 [ set increaseTotalUtility%FirstRound increaseTotalUtility%]
  if roundCounter = 2 [ set increaseTotalUtility%SecondRound increaseTotalUtility%]
  if roundCounter = 3 [ set increaseTotalUtility%ThirdRound increaseTotalUtility%]
  if roundCounter = 4 [ set increaseTotalUtility%FourthRound increaseTotalUtility%]
  if roundCounter = 5 [ set increaseTotalUtility%FifthRound increaseTotalUtility% ]
  if roundCounter = 10[ set increaseTotalUtility%TenthRound increaseTotalUtility% ]

  ; plots (First run only)

    ; each round
    if runCounter = 1
      [
        plot-quantity-each-round
        plot-expenditure-each-round
        plot-trades-each-round
        plot-traders
        if count prisoners with [ tradedThisRound = "Yes" ] > 0  [ plot-prices ]
        plot-totalUtility
       ]
   ; at end of trades
   if runCounter = 1 and roundCounter = number-of-rounds
     [
       set maxChocs max [ chocs ] of prisoners
       set maxCigs max [ cigs ] of prisoners
       set minChocs min [ chocs ] of prisoners
       set minCigs min [ cigs ] of prisoners

       plot-utility
     ]

; check, allowing for rounding
   if count prisoners with [ utility - initialUtility  < -1 ] > 0
      [ set checkUtility "Error"
      ]
end

;--------------------

to cancel-deal

  set traderType 0
  set price 0
  set dealChocs 0
  set dealCigs 0

end

;__________________________________________________________________________________________________________________
; RESULTS
;__________________________________________________________________________________________________________________

to collect-data
; at end of each run, after trading has stopped

 set accumAveragePriceFirstRound (fput averagePriceFirstRound accumAveragePriceFirstRound )
 set accumAveragePriceSecondRound (fput averagePriceSecondRound accumAveragePriceSecondRound )
 set accumAveragePriceThirdRound (fput averagePriceThirdRound accumAveragePriceThirdRound )
 set accumAveragePriceFourthRound (fput averagePriceFourthRound accumAveragePriceFourthRound )
 set accumAveragePriceFifthRound (fput averagePriceFifthRound accumAveragePriceFifthRound )
 set accumAveragePriceTenthRound ( fput  averagePriceTenthRound  accumAveragePriceTenthRound  )

 set accumAverageQuantityFirstRound (fput averageQuantityFirstRound accumAverageQuantityFirstRound )
 set accumAverageQuantitySecondRound (fput averageQuantitySecondRound accumAverageQuantitySecondRound )
 set accumAverageQuantityThirdRound (fput averageQuantityThirdRound accumAverageQuantityThirdRound )
 set accumAverageQuantityFourthRound (fput averageQuantityFourthRound accumAverageQuantityFourthRound )
 set accumAverageQuantityFifthRound (fput averageQuantityFifthRound accumAverageQuantityFifthRound )
 set accumAverageQuantityTenthRound ( fput  averageQuantityTenthRound  accumAverageQuantityTenthRound )

 set accumExpenditureFirstRound (fput totalExpenditureFirstRound accumExpenditureFirstRound )
 set accumExpenditureSecondRound (fput totalExpenditureSecondRound accumExpenditureSecondRound )
 set accumExpenditureThirdRound (fput totalExpenditureThirdRound accumExpenditureThirdRound )
 set accumExpenditureFourthRound (fput totalExpenditureFourthRound accumExpenditureFourthRound )
 set accumExpenditureFifthRound (fput totalExpenditureFifthRound accumExpenditureFifthRound )
 set accumExpenditureTenthRound  ( fput  totalExpenditureThisRound  accumExpenditureTenthRound )

;set accumNOfTrades ( fput  totalNOfTrades  accumNOfTrades  )
 set accumTradersFirstRound%  ( fput  tradersFirstRound%   accumTradersFirstRound%  )
 set accumTradersSecondRound%  ( fput  tradersSecondRound%   accumTradersSecondRound%  )
 set accumTradersThirdRound%  ( fput  tradersThirdRound%  accumTradersThirdRound%  )
 set accumTradersFourthRound%  ( fput  tradersFourthRound%   accumTradersFourthRound%  )
 set accumTradersFifthRound%  ( fput  tradersFifthRound%  accumTradersFifthRound%  )
 set accumTradersTenthRound%  ( fput  tradersTenthRound%   accumTradersTenthRound%  )

 set accumTotalTradersFirstRound% (fput totalTradersFirstRound% accumTotalTradersFirstRound% )
 set accumTotalTradersSecondRound% (fput totalTradersSecondRound% accumTotalTradersSecondRound% )
 set accumTotalTradersThirdRound% (fput totalTradersThirdRound% accumTotalTradersThirdRound% )
 set accumTotalTradersFourthRound% (fput totalTradersFourthRound% accumTotalTradersFourthRound% )
 set accumTotalTradersFifthRound% (fput totalTradersFifthRound% accumTotalTradersFifthRound% )
 set accumTotalTradersTenthRound% (fput totalTradersTenthRound% accumTotalTradersTenthRound% )

 set accumIncreaseTotalUtility%FirstRound ( fput  increaseTotalUtility%FirstRound  accumIncreaseTotalUtility%FirstRound )
 set accumIncreaseTotalUtility%SecondRound ( fput  increaseTotalUtility%SecondRound  accumIncreaseTotalUtility%SecondRound )
 set accumIncreaseTotalUtility%ThirdRound ( fput  increaseTotalUtility%ThirdRound  accumIncreaseTotalUtility%ThirdRound )
 set accumIncreaseTotalUtility%FourthRound ( fput  increaseTotalUtility%FourthRound  accumIncreaseTotalUtility%FourthRound )
 set accumIncreaseTotalUtility%FifthRound ( fput  increaseTotalUtility%FifthRound  accumIncreaseTotalUtility%FifthRound )
 set accumIncreaseTotalUtility%TenthRound ( fput  increaseTotalUtility%TenthRound  accumIncreaseTotalUtility%TenthRound )

end

;---------------------------------------------

to report-results
; at end of last run

 file-open (word priceSetting "-" initialChocs "-chocs-" %smokers "%smokers-" number-of-rounds "-rounds-" number-of-runs "runs.csv" )

 file-print ( word priceSetting " with inital choc rations " initialChocs " and " %smokers "%smokers and reach " reach)
 file-type ( word "Results over "  number-of-runs " runs with " number-of-rounds " rounds of trading")
 file-print " "
 file-print " "

 file-type (word "Mean initial market-clearing price = " precision ( mean accumInitialMCPrice ) 2 )
 if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumInitialMCPrice  ) 2 ) ]
 file-type (word " n = " length accumInitialMCPrice  )
 file-print " "

  file-type (word "Mean final market-clearing price = " precision ( mean accumFinalMCPrice  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumFinalMCPrice  ) 2 ) ]
  file-type (word " n = " length accumFinalMCPrice  )
  file-print " "
  file-print " "

  ; first round
  file-print "FIRST ROUND"
  file-type (word "Average price = " precision ( mean accumAveragePriceFirstRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumAveragePriceFirstRound  ) 2 ) ]
  file-type  (word " n = " length accumAveragePriceFirstRound )
  file-print " "

  file-type (word "Average quantity = " precision ( mean accumAverageQuantityFirstRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumAverageQuantityFirstRound  ) 2 ) ]
  file-type  (word " n = " length accumAverageQuantityFirstRound )
  file-print " "

  file-type (word "Average expenditure  = " precision ( mean accumExpenditureFirstRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumExpenditureFirstRound  ) 2 ) ]
  file-type  (word " n = " length accumExpenditureFirstRound )
  file-print " "

  file-type (word "Mean % traded this round = " precision ( mean accumTradersFirstRound% ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumTradersFirstRound% ) 2 ) ]
  file-type (word " n = " length accumTradersFirstRound% )
  file-print " "

  file-type (word "Mean cum % traded at end of round = " precision ( mean accumTotalTradersFirstRound%  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumTotalTradersFirstRound%  ) 2 ) ]
  file-type (word " n = " length accumTotalTradersFirstRound%  )
  file-type (word "  (Should be same as above.)" )
  file-print " "

  file-type (word "Mean % increase in total utility  = " precision ( mean accumIncreaseTotalUtility%FirstRound ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumIncreaseTotalUtility%FirstRound  ) 2 ) ]
  file-type (word " n = " length accumIncreaseTotalUtility%FirstRound )
  file-print " "
  file-print " "

  if number-of-rounds > 1

  [ file-print "SECOND ROUND"

  file-type (word "Average price = " precision ( mean accumAveragePriceSecondRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumAveragePriceSecondRound  ) 2 ) ]
  file-type  (word " n = " length accumAveragePriceSecondRound )
  file-print " "

  file-type (word "Average quantity = " precision ( mean accumAverageQuantitySecondRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumAverageQuantitySecondRound  ) 2 ) ]
  file-type  (word " n = " length accumAverageQuantitySecondRound )
  file-print " "

  file-type (word "Average expenditure  = " precision ( mean accumExpenditureSecondRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumExpenditureSecondRound  ) 2 ) ]
  file-type  (word " n = " length accumExpenditureSecondRound )
  file-print " "

  file-type (word "Mean % traded this round = " precision ( mean accumTradersSecondRound% ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumTradersSecondRound% ) 2 ) ]
  file-type (word " n = " length accumTradersSecondRound% )
  file-print " "

  file-type (word "Mean cum % traded at end of round = " precision ( mean accumTotalTradersSecondRound%  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumTotalTradersSecondRound%  ) 2 ) ]
  file-type (word " n = " length accumTotalTradersSecondRound%  )
  file-print " "

  file-type (word "Mean % increase in total utility  = " precision ( mean accumIncreaseTotalUtility%SecondRound ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumIncreaseTotalUtility%SecondRound  ) 2 ) ]
  file-type (word " n = " length accumIncreaseTotalUtility%SecondRound )
  file-print " "
  file-print " "
  ]

  if number-of-rounds > 2

  [
  file-print "THIRD ROUND"

  file-type (word "Average price = " precision ( mean accumAveragePriceThirdRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumAveragePriceThirdRound  ) 2 ) ]
  file-type  (word " n = " length accumAveragePriceThirdRound )
  file-print " "

  file-type (word "Average quantity = " precision ( mean accumAverageQuantityThirdRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumAverageQuantityThirdRound  ) 2 ) ]
  file-type  (word " n = " length accumAverageQuantityThirdRound )
  file-print " "

  file-type (word "Average expenditure  = " precision ( mean accumExpenditureThirdRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumExpenditureThirdRound  ) 2 ) ]
  file-type  (word " n = " length accumExpenditureThirdRound )
  file-print " "

  file-type (word "Mean % traded this round = " precision ( mean accumTradersThirdRound% ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumTradersThirdRound% ) 2 ) ]
  file-type (word " n = " length accumTradersThirdRound% )
  file-print " "

  file-type (word "Mean cum % traded at end of round = " precision ( mean accumTotalTradersThirdRound%  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumTotalTradersThirdRound%  ) 2 ) ]
  file-type (word " n = " length accumTotalTradersThirdRound%  )

  file-print " "
  file-type (word "Mean % increase in total utility  = " precision ( mean accumIncreaseTotalUtility%ThirdRound ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumIncreaseTotalUtility%ThirdRound  ) 2 ) ]
  file-type (word " n = " length accumIncreaseTotalUtility%ThirdRound )
  file-print " "
  file-print " "
  ]


  if number-of-rounds > 3

  [
  file-print "FOURTH ROUND"

  file-type (word "Average price = " precision ( mean accumAveragePriceFourthRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumAveragePriceFourthRound  ) 2 ) ]
  file-type  (word " n = " length accumAveragePriceFourthRound )
  file-print " "

  file-type (word "Average quantity = " precision ( mean accumAverageQuantityFourthRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumAverageQuantityFourthRound  ) 2 ) ]
  file-type  (word " n = " length accumAverageQuantityFourthRound )
  file-print " "

  file-type (word "Average expenditure  = " precision ( mean accumExpenditureFourthRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumExpenditureFourthRound  ) 2 ) ]
  file-type  (word " n = " length accumExpenditureFourthRound )
  file-print " "

  file-type (word "Mean % traded this round = " precision ( mean accumTradersFourthRound% ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumTradersFourthRound% ) 2 ) ]
  file-type (word " n = " length accumTradersFourthRound% )
  file-print " "

  file-type (word "Mean cum % traded at end of round = " precision ( mean accumTotalTradersFourthRound%  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumTotalTradersFourthRound%  ) 2 ) ]
  file-type (word " n = " length accumTotalTradersFourthRound%  )
  file-print " "

  file-type (word "Mean % increase in total utility  = " precision ( mean accumIncreaseTotalUtility%FourthRound ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumIncreaseTotalUtility%FourthRound  ) 2 ) ]
  file-type (word " n = " length accumIncreaseTotalUtility%FourthRound )
  file-print " "
  file-print " "
  ]

  ; fifth round

  if number-of-rounds > 4
  [
  file-print "FIFTH ROUND"

  file-type (word "Average price  = " precision ( mean accumAveragePriceFifthRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumAveragePriceFifthRound  ) 2 ) ]
  file-type  (word " n = " length accumAveragePriceFifthRound )
  file-print " "

  file-type (word "Average quantity = " precision ( mean accumAverageQuantityFifthRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumAverageQuantityFifthRound  ) 2 ) ]
  file-type  (word " n = " length accumAverageQuantityFifthRound )
  file-print " "

  file-type (word "Average expenditure  = " precision ( mean accumExpenditureFifthRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumExpenditureFifthRound  ) 2 ) ]
  file-type  (word " n = " length accumExpenditureFifthRound )
  file-print " "

  file-type (word "Mean % traded this round = " precision ( mean accumTradersFifthRound% ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumTradersFifthRound% )2 ) ]
  file-type (word " n = " length accumTradersFifthRound% )
  file-print " "

  file-type (word "Mean cum % traded at end of round = " precision ( mean accumTotalTradersFifthRound%  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumTotalTradersFifthRound%  ) 2 ) ]
  file-type (word " n = " length accumTotalTradersFifthRound%  )
  file-print " "

  file-type (word "Mean % increase in total utility  = " precision ( mean accumIncreaseTotalUtility%FifthRound ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumIncreaseTotalUtility%FifthRound  ) 2 ) ]
  file-type (word " n = " length accumIncreaseTotalUtility%FifthRound  )
  file-print " "
  file-print " "

  ]

  ; tenth round

  if number-of-rounds > 9
  [
  file-print "TENTH ROUND"

  file-type (word "Average price = " precision ( mean accumAveragePriceTenthRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumAveragePriceTenthRound  ) 2 ) ]
  file-type  (word " n = " length accumAveragePriceTenthRound  )
  file-print " "

  file-type (word "Average quantity = " precision ( mean accumAverageQuantityTenthRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumAverageQuantityTenthRound  ) 2 ) ]
  file-type  (word " n = " length accumAverageQuantityTenthRound )
  file-print " "

  file-type (word "Average expenditure = " precision ( mean accumExpenditureTenthRound  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumExpenditureTenthRound  ) 2 ) ]
  file-type  (word " n = " length accumExpenditureTenthRound )
  file-print " "

  file-type (word "Mean % traded  = " precision ( mean accumTradersTenthRound% ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumTradersTenthRound% ) 2 ) ]
  file-type (word " n = " length accumTradersTenthRound% )
  file-print " "

  file-type (word "Mean cum % traded at end of round = " precision ( mean accumTotalTradersTenthRound%  ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumTotalTradersTenthRound%  ) 2 ) ]
  file-type (word " n = " length accumTotalTradersTenthRound%  )
  file-print " "

  file-type (word "Mean % increase in total utility  = " precision ( mean accumIncreaseTotalUtility%TenthRound ) 2 )
  if number-of-runs > 1 [ file-type (word " sd = " precision ( standard-deviation accumIncreaseTotalUtility%TenthRound  ) 2 ) ]
  file-type (word " n = " length accumIncreaseTotalUtility%TenthRound  )
  file-print " "

  ]

file-close

end

;---------------------------------------------
; PLOTS

; demand and supply curves

to plot-initial-demand-and-supply

  set-current-plot "Initial Excess Demand & Supply"
  set-plot-x-range 0 1000
  set-plot-y-range 0 10
  set-current-plot-pen "supply"
  plotxy totalSupply priceChocs
  set-current-plot-pen "demand"
  plotxy totalDemand priceChocs

end

to plot-final-demand-and-supply

  set-current-plot "Final Excess Demand & Supply"
  set-plot-x-range 0 1000
  set-plot-y-range 0 10
  set-current-plot-pen "supply"
  plotxy totalSupply priceChocs
  set-current-plot-pen "demand"
  plotxy totalDemand priceChocs

end

;------------------

to plot-quantity-each-round

set-current-plot "Av Quantity Traded"
plotxy roundCounter averageQuantityThisRound

end

;------------------

to plot-expenditure-each-round

set-current-plot "Total Expenditure"
plotxy roundCounter totalExpenditureThisRound

end

;------------------
to plot-trades-each-round

set-current-plot "Trades Each Round"
plotxy roundCounter tradedThisRound%

end

;------------------

to plot-traders

set-current-plot "Cum % Traded"
plotxy roundCounter traders%

end

;------------------

to plot-prices

set-current-plot "Prices"
set-current-plot-pen "Max"
plotxy roundCounter max [ price ] of prisoners with [ price > 0 ]
set-current-plot-pen "Av"
plotxy roundCounter averagePriceThisRound
set-current-plot-pen "Min"
plotxy roundCounter min [ price ] of prisoners  with [ price > 0 ]

end


;------------------

to plot-utility
  set-current-plot "Utility"
  set-plot-x-range 0 200
  set-plot-y-range 0 20
  set-plot-pen-interval 1 ; width of each bar
  histogram [ (utility - initialUtility) / initialUtility * 100 ] of prisoners with [ utility - initialUtility > 0 ]

end
;---------

to plot-totalUtility

set-current-plot "% Change in Total Utility"
plotxy roundCounter increaseTotalUtility%
end

;____________________________________________________________________________________________________________________________________________
;____________________________________________________________________________________________________________________________________________
@#$#@#$#@
GRAPHICS-WINDOW
30
263
398
632
-1
-1
2.5545
1
10
1
1
1
0
0
0
1
-70
70
-70
70
0
0
1
ticks
30.0

BUTTON
8
10
72
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
86
10
149
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

MONITOR
231
52
306
97
Total chocs
sum [chocs] of prisoners
0
1
11

MONITOR
307
52
376
97
Total cigs
sum [ cigs] of prisoners
0
1
11

SLIDER
10
53
149
86
initialChocs
initialChocs
0
100
50.0
5
1
NIL
HORIZONTAL

PLOT
583
10
880
213
Initial Excess Demand & Supply
Quantity of chocs
Price of chocs
0.0
1000.0
0.0
10.0
true
true
"" ""
PENS
"supply" 1.0 0 -2674135 true "" ""
"demand" 1.0 0 -16777216 true "" ""

PLOT
584
420
785
616
Trades Each Round
Round
Trades
1.0
10.0
0.0
5.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

SLIDER
13
135
149
168
reach
reach
10
200
200.0
5
1
NIL
HORIZONTAL

CHOOSER
15
189
155
234
number-of-rounds
number-of-rounds
1 2 5 10
0

PLOT
902
10
1187
213
Final Excess Demand & Supply
Quantity of chocs
Price of chocs
0.0
1000.0
0.0
10.0
true
true
"" ""
PENS
"supply" 1.0 0 -2674135 true "" ""
"demand" 1.0 0 -16777216 true "" ""

PLOT
584
216
786
415
Prices
Round
Prices
1.0
10.0
0.0
5.0
true
true
"" ""
PENS
"max" 1.0 0 -2674135 true "" ""
"av" 1.0 0 -13840069 true "" ""
"min" 1.0 0 -13345367 true "" ""

TEXTBOX
33
658
228
690
Smokers = red (alpha < 0.5)\nChocLover = black (alpha > 0.5 )\n
12
0.0
1

MONITOR
429
489
496
534
NIL
checkUtility
0
1
11

PLOT
997
419
1200
612
% Change in Total Utility
Round
Per cent
1.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

PLOT
791
419
992
613
Cum % Traded
Round
% Traded
1.0
10.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

PLOT
584
622
1204
766
Utility
% change in utility
Agents
0.0
100.0
0.0
20.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 false "" ""

SLIDER
12
94
149
127
%smokers
%smokers
0
100
70.0
5
1
NIL
HORIZONTAL

CHOOSER
168
123
323
168
priceSetting
priceSetting
"Auctioneer" "Equilibrium" "Random"
2

MONITOR
160
54
224
99
NIL
initialCigs
0
1
11

CHOOSER
167
186
296
231
number-of-runs
number-of-runs
1 2 5 10 100
2

TEXTBOX
456
10
559
89
Plots based on first run
20
0.0
1

MONITOR
328
185
418
230
NIL
runCounter
0
1
11

MONITOR
432
183
522
228
NIL
roundCounter
0
1
11

PLOT
789
217
989
415
Total Expenditure
Round
Expenditure
0.0
10.0
0.0
1000.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

PLOT
991
218
1191
416
Av Quantity Traded
Round
Quantity
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

@#$#@#$#@
## WHAT IS IT?

This is a very simple trading model based on the Red Cross parcels situation as described by Radford (1945). All agents receive the same initial allocations. But some agents would prefer more chocolate and fewer cigarettes or vice-versa.

## HOW IT WORKS

Two hundred agents are distributed randomly within an area 141 x 141, with no wrapping. The densisty of agents is therefore 1 per cent: 200 / (141 x 141 ) = 200 / 19881. Thus, by Pythagoras's theorem, no agent is further than 200 from another.

The agents have Cobb-Douglas utility functions, with  alpha + beta = 1. (The Cobb-Douglas means that they always have at least one of each good.) The larger alpha, the greater the preference for chocolate. 

The percentage of smokers is set by a slider. Smokers are allocated alphas of less than 0.5 and are coloured red. The chocLovers are defined as those with alpha greater than 0.5 and are coloured black. 

The chocolate ration are set by a slider. There are a maximum of 100 items, so if the chioclate ration is set at 50, the ciagrette ration will be 50 too: if there are 25 chocolates, there will be 75 cigarettes.

### Prices

Chocolate is priced in cigarettes. 
- If the price > 1, then more than one cigarette is given for one chocolate: e.g. if the price = 2, then  chocLover has to give 2 cigarettes for 1 chocolate.
- If price = 1, then 1 chocolate is exchanged for 1 cigarette.
- If price < 1, then more than 1 chocolate is given for 1 cigarette. For example, if the price = 0.5, then 1 chocolate only buys half a cigarette, so 20 chocolates buy 10 cigarettes.
The program ensures only whole numbers of cigarettess are exchanged for whole numbers of chocolates.

### Demand and supply

Before any trading occurs and starting with price = 0.1, each agent calculates their budget: 

     set budget ( chocs * price ) + cigs     

They then calculate their optimal holding at that price:

     set optimal ( budget * alpha / price )

and deduct their holding. These are summed over all agents to give a total demand and a totyal supply. The exces demand is then calculated by subtracting the supply from the demand. This is repeated 100 times, increasing the price by 0.1 each time.

The demand and supply curves are drawn and the market-clearing price calculated.

This is repeated after trading ends. 

### Trading

ChocLovers locate smokers within a distance defined by the reach as potential trading partners. If the reach is set at at 200, then any agent can trade with any other agent. 

The price is set in one of three ways:
- by the auctioneer at the initial market-clearing price (as described above)
- at the equilbilrium price (as defined in Chapter 5) 
- randomly between MRSs (as in the Edgeworth Random Box model.)

They compare the optimal with their actual holding. If the chocLover's optimal holding of chocolate is less than its actual holding, it offers to trade. If the smoker's optimal holding of chocolate exceeds its actual holding it offers to trade. The deal is done on the basis of the minimum offer. For example, if the price were 1, and the buyer offered 5 cigarettes but the seller only offered 3 chocolates, then the deal would be for 3. 

### Outputs

Data is collected at the end of each round and the model is designed to undertake up to 100 runs at a time and accumulate the results. But the graphics are based only on the first run.

The output box records the average over all the rounds (plus the standard deviation where there are more than one run).

Mean initial market-clearing price 
Mean final market-clearing price 

For the first, fifth and tenth trading rounds: 
  Average price 
  Average quantity traded
  Average total expenditure (1) 
  Mean % traded 
  Mean increase in total utility % after trade round  

Average total no. of trades over all rounds
Max potential trades
Mean cum % traded at end of last round
 
(1) Note that for each round the total expenditure, which is the number of cigarettes traded, is the product of the average price, the average quantity of chocolate traded and the number of trades.

## HOW TO USE IT

There are only 5 parameters:
- the initial number of chocolates given to each agent. (The number of cigarettes is 100   less this number)
- the percentage of smokers (who have alpha < 0.5 )
- reach: the distance which agents can search for trading partners. It must be at least 10 and a reach of 200 will give access to everyone.
- the price setting method: auctioneer, equilibrium or random MRS.

Set the number of rounds of trading: 1, 2, 5, or 10.
Set the number of runs: 


## CREDITS AND REFERENCES

Runs on NetLogo 5.2.

Radford, R. A. (1945) The Economic Organisation of a P.O.W. Camp. Economica, New Series, Vol. 12, No. 48 pp. 189-201 

For more information, see Hamill, L. & Gilbert, N. (2016) Agent-based Modelling in Economics. Wiley: Chapter 5.

To refer to this model: Hamill, L. & Gilbert, N. (2016) Red Cross Parcel model.
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
