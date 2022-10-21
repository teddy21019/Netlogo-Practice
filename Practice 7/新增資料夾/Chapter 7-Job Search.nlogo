globals [

counter

nOfWorkers nOfEmployers
unNormalisedMeanWage

wageIncreaseFactor 
wageReductionFactor

nOfJobOffers

recruitingEmployersList ; method 1

totalVacanciesAtEnd
totalNewRecruits 
totalUnfilledVacancies
nOfWorkersUnemp nOfJobSeekersEmployed

; analysis

unemploymentRate%  unemploymentRate%Record     

meanWageAllJobSeekers meanWageAllJobSeekersRecord
meanWageChange% meanWageChange%Record  

; error checks
vacancyError
unempError
errorLastEmployer 
wageError

employerError 
errorRecruits 
 
  ]
 
 breed [workers worker]
 
 breed [employers employer]

 workers-own [  myWage
                myLastWage 
                myEmployer 
                myLastEmployer
                tempStatus
                newEmploymentStatus
                newEmployers
                outcome 
               
                myNewEmployer
                myNewWage
                myWageChange%

              ]   
 
 employers-own 
    [ mySize 
      myEmployees
      listOfMyWages
      myTotalVacancies
      myWageOffer
      myVacancyWages 
 
      myNewTotalVacancies 
      myNewVacancyWages
      myMaxWageOffer
      myPossibleEmployees
      myLatestRecruit
      myNewRecruits 
      listMyNewRecuits 
      myUnfilledVacancies  
      myUnfilledVacancyWages

    ]
    
;_______________________________________________________________________________________________________________________________    
to setup 
; no visualisation needed but may need to look at characteristics of agents
 
 clear-all
 ask patches  [set pcolor white]  

 set nOfWorkers 1000 
 set nOfEmployers 100  
 
 set wageIncreaseFactor ( 1 + ( maxWageIncrease% / 100 ))
 set wageReductionFactor ( 1 - ( maxWageReduction% / 100 ))
 
 set nOfJobOffers  nOfJobseekers     ; nOfJobSeekers set by slider
 
 set unemploymentRate%Record [  ]

 set meanWageAllJobSeekersRecord  [  ]

 set meanWageChange%Record [  ]


end

;--------------------------------------------------------------------
to go 

; to give each worker a wage from a log-normal distribution 

repeat n-of-repeats
[
    clear-turtles
    
    set counter counter + 1
    
 ;   initialise-globals
    
    initialise-workers
    
    initialise-employers
  
  ; match workers and employers
    ask employers 
           [ 
               ask n-of mySize workers with [ myEmployer = nobody ] [  set myEmployer myself ]   
               set myEmployees count workers with [ myEmployer = myself ]      
               set listOfMyWages [ myWage ] of workers with [ myEmployer = myself ]   
               set myTotalVacancies 0
               set myVacancyWages [  ]                                       
            ]
   
   
     ask n-of nOfJobseekers  workers  
       [ 
         set tempStatus "unemployed" 
         ask myEmployer [ calculate-vacancies ] 
         become-unemployed       
        ]
   
     ask employers [ set myEmployees count workers with [ myEmployer = myself ] ]
     if any? employers with [ ( mySize - myEmployees ) != myTotalVacancies ] [ set vacancyError "Yes" ]
     
 ; job-market 
   recruit ; employer-led
 
 analyse-results
   
]

 
 if n-of-repeats > 1  [ record-results ]

end

;_________________________________________________________________________________________________________________
;PROCEDURES
;_________________________________________________________________________________________________________________

to initialise-workers
   
 create-workers nOfWorkers 


ask workers

[   locate
   set shape "person"
   set color blue
   set size 7 
   set myEmployer nobody
   
]  

    ask workers [ set myWage ( 10 * ( e ^ random-normal 1 0.7 ) )  ] 
    set unNormalisedMeanWage  mean [ myWage] of workers
    ask workers [ set myWage precision ( myWage * 100 /  unNormalisedMeanWage ) 0 ]


end

;-------------------------------------------------

to initialise-employers
  

create-employers nOfEmployers    
 
ask employers 
[ 
   locate 
    set shape "pentagon"
    set color black
    set size 7 
    set mySize 0
    set myEmployees 0 
    set listOfMyWages [   ]
    set myTotalVacancies 0
    set myVacancyWages [  ] 
    set myVacancyWages [  ] 
    set myWageOffer 0
    set myMaxWageOffer 0
    set myNewRecruits 0
    set myNewTotalVacancies 0
    set listMyNewRecuits [  ]
    set myUnfilledVacancyWages [  ]
]  
     setInitialSize 1 100
     setInitialSize 1 97
     setInitialSize 3 50
     setInitialSize 4 30
     setInitialSize 27 15
     setInitialSize 64 2 
     
  
 ask employers with [ mySize > 95 ] [ set size 14 ]  

end  

;--------------------------------------------

to locate 
; used by workers and employers
  setxy random-pxcor random-pycor  
     if any? other turtles-here [ 
      let empty-patches patches with [ not any? turtles-here ] 
      if not any? empty-patches [ show "Run out of empty patches!"]
      move-to one-of empty-patches ]    

end 


;-------------------------------------------

to setInitialSize [ numberOfEmployers employerSize ]
  
  ask n-of numberOfEmployers employers with [ mySize = 0 ] [ set mySize employerSize ]

end  
;--------------------------------------------

to become-unemployed     
        set myLastEmployer myEmployer
        set myEmployer nobody 
        set myLastWage myWage
        set myWage 0
        set color red 
        set tempStatus 0 
          
end
;---------------------------------------------
to calculate-vacancies
; employer action initiated by workers becoming unemployed

        set myWageOffer [ myWage ] of myself 
        create-vacancy              
        set color green                        
       
end

;---------------------------------------------
; a set of employer actions - used by workers who quit and new employers
to create-vacancy 
; employer action
   set myTotalVacancies ( myTotalVacancies  + 1 ) 
   set myVacancyWages lput myWageOffer  myVacancyWages
end              

;-------------------------------------------------------------------------------

; Job search

to recruit
 
; sets variables for this method
ask employers with [ myTotalVacancies > 0 ]  
    [  set myNewTotalVacancies myTotalVacancies
       set myVacancyWages myVacancyWages
       set myVacancyWages sort-by > myVacancyWages        
     ]    

ask workers with [ myEmployer = nobody ] [ set myNewEmployer nobody ]

; employers list vacancies by order of size of wage offer, starting with highest
repeat nOfJobOffers

 [   
   ask employers with [ myNewTotalVacancies > 0 ] [ set myMaxWageOffer item 0 myVacancyWages ] 
   ; to sort employers by highest wage offered
    set recruitingEmployersList  sort-by [ [ myMaxWageOffer ] of ?1 >= [ myMaxWageOffer ] of ?2 ] employers with [ myNewTotalVacancies > 0 ]

   ask item 0 recruitingEmployersList ; employer offering highest wage
      [
         set myPossibleEmployees  workers with [ myNewEmployer = nobody 
                                               and myLastEmployer  != myself 
                                               and wageIncreaseFactor *  myLastWage  >= [ myMaxWageOffer ] of myself 
                                               and wageReductionFactor *  myLastWage <= [ myMaxWageOffer ] of myself  
                                               ]
        ; employer selects worker with highest last wage
        if myPossibleEmployees != nobody  [  set myLatestRecruit max-one-of myPossibleEmployees [ myLastWage ] ] 
     
         ; employee
         if myLatestRecruit != nobody 
          [ 
            ask myLatestRecruit
            [ set myNewEmployer myself 
              set myWage [ myMaxWageOffer ] of myNewEmployer  
              set myWageChange% precision ( ( myWage - myLastWage ) / myLastWage * 100  ) 1
              set color violet
              set tempStatus "Into work"
             ] ; end of worker actions
          
             ; employer actions 
           set myNewRecruits ( myNewRecruits + 1 ) 
           set listMyNewRecuits lput myLatestRecruit  listMyNewRecuits 
          ]  
           ; employer actions whether or not job filled; as not rolling forward, does not matter whether vacancy filled
          
           set myNewTotalVacancies ( myNewTotalVacancies - 1 ) 
                  
           if myLatestRecruit = nobody 
             [ 
               set myUnfilledVacancies  ( myUnfilledVacancies + 1 ) 
               set myUnfilledVacancyWages lput ( item 0 myVacancyWages ) myUnfilledVacancyWages 
             ]    
         
           set myVacancyWages  remove-item 0  myVacancyWages    

        ] ; to end actions by item 0   
    
    ] ; to end repeat        
   
  set totalVacanciesAtEnd sum [ myUnfilledVacancies ] of employers
  if totalVacanciesAtEnd != count workers with [ myEmployer = nobody and myNewEmployer = nobody ] [ set unempError "Yes" ]
  
  set totalNewRecruits sum [ myNewRecruits ] of employers
  set totalUnfilledVacancies sum [ myUnfilledVacancyWages ] of employers
   
 ; error check
  if any? workers with [ myNewEmployer != 0 and myLastEmployer != 0 and myNewEmployer =  myLastEmployer ] [ set errorLastEmployer  "Yes"] 
  if count workers with [ tempStatus = "Into work" and myWageChange% >= 0 and myWageChange% > maxWageIncrease% ] > 0 [ set wageError "Yes" ]
  if count workers with [ tempStatus = "Into work" and myWageChange% <= 0 and myWageChange% < (- maxWageReduction% ) ] > 0 [ set wageError "Yes" ]
  
  if any? employers with [ myUnfilledVacancies + myNewRecruits !=  myTotalVacancies] [ set employerError "Yes" ]
 
 ; record results 
 set nOfWorkersUnemp count workers with [ myEmployer = nobody and myNewEmployer = nobody ]
 set nOfJobSeekersEmployed ( nOfJobSeekers - nOfWorkersUnemp )
 
 if nOfJobSeekersEmployed != totalNewRecruits [ set errorRecruits "Yes" ]
 
 set unemploymentRate%  precision ( count workers with [ myEmployer = nobody and myNewEmployer = nobody ] / nOfWorkers  * 100 ) 2 
 set unemploymentRate%Record  lput unemploymentRate% unemploymentRate%Record  
   
end   

;________________________________________________________________________________________________________________________
;RESULTS
;________________________________________________________________________________________________________________________

to analyse-results

; change in wages

 set meanWageChange% mean [ myWageChange%] of workers with [ tempStatus = "Into work" ]
 set meanWageChange%Record lput meanWageChange% meanWageChange%Record

end
   
;--------------------------------------------

to record-results

; clean up data  
set meanWageAllJobSeekersRecord remove 0 meanWageAllJobSeekersRecord


; write results to file   
file-open (word "Job search-"nOfJobSeekers"-"maxWageIncrease%"-"maxWageReduction%"-"n-of-repeats".csv")

file-print ( word "nOfJobSeekers " nOfJobSeekers )
file-print ( word "maxWageIncrease% " maxWageIncrease% )
file-print ( word "maxWageReduction% "maxWageReduction% )
file-print (word "number-of-repeats " n-of-repeats )

file-print "  "
file-print (word "Unemployment rate %:" )
file-print (word "- mean: " precision ( mean unemploymentRate%Record ) 2 " (sd " precision standard-deviation ( unemploymentRate%Record ) 2 " )"  )
file-print (word "- min: " precision ( min unemploymentRate%Record ) 2   )
file-print (word "- max: " precision ( max unemploymentRate%Record ) 2   )
file-print "  " 

file-print "Wages  "
file-print (word "Mean change in wages % " precision ( mean  meanWageChange%Record ) 2 " (sd " precision ( standard-deviation  meanWageChange%Record ) 2 ")" )  

file-close

; output to interface
output-print (word "Unemployment rate %:" )
output-print (word "- mean: " precision ( mean unemploymentRate%Record ) 2 " (sd " precision standard-deviation ( unemploymentRate%Record ) 2 " )"  )
output-print (word "- min: " precision ( min unemploymentRate%Record ) 2   )
output-print (word "- max: " precision ( max unemploymentRate%Record ) 2   )

output-print "  "
output-print "Wages  "
output-print (word "Mean change in wages % " precision ( mean  meanWageChange%Record ) 2 " (sd " precision ( standard-deviation  meanWageChange%Record ) 2 ")" )  

end

;___________________________________________________________________________________________________________________________
;___________________________________________________________________________________________________________________________
@#$#@#$#@
GRAPHICS-WINDOW
617
10
1264
680
314
315
1.013
1
9
1
1
1
0
1
1
1
-314
314
-315
315
0
0
0
ticks
30.0

BUTTON
16
10
79
43
NIL
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
17
47
80
80
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
23
143
564
264
12

SLIDER
356
10
528
43
nOfJobseekers
nOfJobseekers
0
200
100
10
1
NIL
HORIZONTAL

SLIDER
355
45
586
78
maxWageIncrease%
maxWageIncrease%
0
100
10
1
1
NIL
HORIZONTAL

SLIDER
356
83
587
116
maxWageReduction%
maxWageReduction%
0
100
10
1
1
NIL
HORIZONTAL

CHOOSER
150
15
288
60
n-of-repeats
n-of-repeats
1 2 10 100
2

MONITOR
35
310
134
355
NIL
errorLastEmployer
0
1
11

MONITOR
36
363
134
408
NIL
wageError
0
1
11

MONITOR
36
491
134
536
NIL
employerError
0
1
11

MONITOR
36
438
135
483
NIL
vacancyError
0
1
11

MONITOR
37
571
138
616
NIL
unempError
0
1
11

MONITOR
38
626
139
671
NIL
errorRecruits
0
1
11

MONITOR
152
62
209
107
NIL
counter
0
1
11

TEXTBOX
498
290
618
396
In last run:\nWORKERS\nVoilet = found new job\nRed= unemployed\nEMPLOYERS\nGreen = vacancy(ies)
11
0.0
1

TEXTBOX
160
498
503
542
\"Yes\" if any employers with [ myUnfilledVacancies + myNewRecruits !=  myTotalVacancies]
11
0.0
1

TEXTBOX
166
638
456
658
\"Yes\" if nOfJobSeekersEmployed != totalNewRecruits
11
0.0
1

TEXTBOX
163
316
382
334
\"Yes\" if myNewEmployer =  myLastEmployer 
11
0.0
1

TEXTBOX
38
285
188
303
WORKER CHECKS
11
0.0
1

TEXTBOX
48
553
147
571
MACRO CHECKS
11
0.0
1

TEXTBOX
164
373
422
401
\"Yes\" if wage chage outside specified range
11
0.0
1

TEXTBOX
166
584
535
611
\"Yes\" if totalVacanciesAtEnd != count workers with [ myEmployer = nobody and myNewEmployer = nobody ]
11
0.0
1

TEXTBOX
163
440
501
496
\"Yes\" if any employers with [ ( mySize - myEmployees ) != myTotalVacancies ]
11
0.0
1

TEXTBOX
43
416
193
434
EMPLOYER CHECKS
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This is a simple model of job search.

## HOW IT WORKS

100 employers are created, varying in size from 2 to 100.

1,000 workers are created and alloacted wages from a log normal distribution, normalised so that the average wage equals 100. The workers are allocated to the employers.

A number of workers - detemined by the slider nOfJobseekers - leave their employers and enter the job market. This leaves matching vacancies.

Workers and vacancies are then matched. However, workers are NOT allowed to return to their old jobs.

Employers offer the same wage as they paid the workers who left.

Workers seek the same or similiar wages, depending on the degree of 'stickiness' - set by the maxWageIncrease% and maxWagereduction% sliders.

The highest wages are offered and the highest paid job seeker are matched first. This minimises unemployment. 

Vacancies are listed, starting with the highest paid. The key coding is:

    ; employers list vacancies by order of size of wage offer, starting with highest
    repeat nOfJobOffers

     ask employers with [ myTotalVacanciesM1 > 0 ] [ set myMaxWageOffer item   myVacancyWagesM1 ] 
     ; to sort employers by highest wage offered
     set recruitingEmployersList  sort-by [ [ myMaxWageOffer ] of ?1 >= [ myMaxWageOffer ] of ?2 ] employers with [ myTotalVacanciesM1 > 0 ]
     ask item 0 recruitingEmployersList ; employer offering highest wage
      [
         set myPossibleEmployees  workers with 
             [ myEmployerM1 = nobody 
               and myLastEmployer  != myself 
               and wageIncreaseFactor *  myLastWage  >= [ myMaxWageOffer ] of myself 
               and wageReductionFactor *  myLastWage <= [ myMaxWageOffer ] of myself  
              ]
     
        if myPossibleEmployees != nobody  [  set myLatestRecruit max-one-of myPossibleEmployees [ myLastWage ] ] 

### Outputs

The model reports the unemployment rate and the change in wages, writing to both the interface and a file..

### Verification

However, as there is some very complicated programming involved in this job-search model, so to be sure that it is working as intended, several verification checks are carried out, at both the micro and the macro level and the results are shown on the interface.

Checks at the micro level:

Workers
•	Do any job-seekers receive wage increases outside the specified range? If so, then the wage restrictions have not been modelled correctly.

•	Have any workers been re-employed by their last employer? This is not supposed to happen as if it did all the job-seekers could simply slot back into the jobs they have just left.

Employers
•	Does the sum of the number of employees and the number of vacancies equal the employer’s size?
 
•	Are there any employers for whom the sum of their unfilled vacancies and new recruits not equal their total initial vacancies? If not, then the recruitment process has not been modelled correctly.

Checks at the macro level:
•	Do the total vacancies equal the total number of workers with no employers? If not, there is an error because the overall demand for labour is set to equal the overall supply.

•	Do the total new recruits equal the total number of workers who have found jobs? If not, then the recruitment process has not been modelled correctly.


## TO RUN

Set the number of job seekers, the maxWageIncrease% and maxWageReduction% sliders.
Set the number of repeats.

## CREDITS AND REFERENCES

Runs on NetLogo 5.2.

For more information, see Hamill, L. & Gilbert, N. (2016) Agent-based Modelling in Economics. Wiley: Chapter 7.

To refer to this model: Hamill, L. & Gilbert, N. (2016) Job Search model.
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
NetLogo 5.2.0
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
