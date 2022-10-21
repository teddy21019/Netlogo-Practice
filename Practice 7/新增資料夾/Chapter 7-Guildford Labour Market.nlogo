globals 

[

run-counter
quarter-counter

nOfWorkers ; no. of economically active
nOfEmployers
unNormalisedMeanWage

wageDistribution 

nOfJobseekers  
nOfJobOffers 
nOfRecruitingEmployers nOfRecruitingEmployers1 nOfRecruitingEmployers2 nOfRecruitingEmployers3plus
recruitingEmployersList

totalNewRecruits totalUnfilledVacancies

nOfEmployedAtStartOfQuarter nOfEmployedAfterDemogAndBusinessChanges

nOfUnemployedAtStartOfQuarter nOfUnemployedAtEndOfQuarter
unemploymentRate% unempRate%Record meanUnempRate%OverRun unempRate%RecordOverAllRuns
rangeUnempRate%OverRun unempRate%RangeRecordOverAllRuns
LTU% LTU%Record  meanLTU%OverRun LTU%RecordOverAllRuns 

totalLabourDemand
totalVacanciesAtEndOfQuarter 
vacancyRate% vacancyRate%Record meanVacancyRate%OverRun vacancyRate%RecordOverAllRuns

meanWage meanWageRecord meanWageOverRun meanWageOverAllRuns

;flows 
nOfQuitters 
nOfRetirees  nOfRetiredEmployees nOfRetiredUnemployed 
nOfEmployeesLeavingLF nOfUnemployedLeavingLF
nOfNewEntrants nOfReturningWorkers 
nOfRedundantWorkers
nIntoWork nUnempBackToWork nEmpBackToWork 
nIntoU netFlow

transitionRate%EtoU transitionRate%UtoE transitionRate%EtoI transitionRate%UtoI
transitionRate%EtoURecord transitionRate%UtoERecord transitionRate%EtoIRecord transitionRate%UtoIRecord
meanTransitionRate%EtoURecord meanTransitionRate%UtoERecord meanTransitionRate%EtoIRecord meanTransitionRate%UtoIRecord
transitionRate%EtoUOverAllRuns  transitionRate%UtoEOverAllRuns transitionRate%EtoIOverAllRuns transitionRate%UtoIOverAllRuns

nOfEmployersClosing

wageIncreaseFactor 
wageReductionFactor

; error messages
checkTotalAtStartQ ; checks sum employed and unemployed total 1000 - should be 0
checkNIntoWork ; ensures those returning to work divided beteen those moving from unemployment and those moving from employment: 0 if OK
unempError; "Yes" if no. of vacancies != no. of unemployed: 0 if OK
wageError ; "Yes" if wage change outside permitted range 
errorLastEmployer ; "Yes" if any workers with new emoployer same as last employer: 0 if OK
sizeError; "Yes" if myVacancies + myEmployees !=  mySize : 0 if OK

  ]
 
 breed [workers worker]
 
 breed [employers employer]

workers-own 
  [ 
    dateOfEntry
    age
    myInitialWage
    myWage
    myWageChange%
    my-work-history 
    myEmployer
    myLastEmployer
    myPossibleEmployers 
    myLastWage
    startOfUSpell
    durationOfU
    completedUSpells
    tempStatus
    
  ]     

employers-own 
  [   
  mySize  
  date-of-entry
  myEmployees
  listOfMyEmployees
  listOfMyWages
  myWorkerProfile
  myNewRecruits
  myVacancyWages
  myVacancies
  status
  myWageOffer ; used when creating vacancies
  myMaxWageOffer ; used in job market
  myVacancyOffer 
  myPossibleEmployees 
  listMyNewRecuits
  myLatestRecruit
  myUnfilledVacancies  
  myUnfilledVacancyWages
 
   ]
  
;___________________________________________________________________________________________________________________________________  

to setup 
; no visualisation needed but may need to look at characteristics of agents
 
 clear-all
 ask patches  [set pcolor white] 
 
 set nOfWorkers 1000 
 set nOfEmployers 100
 
 
 create-workers nOfWorkers  
 create-employers nOfEmployers
 
 set meanWageOverAllRuns [  ]
 
 set unempRate%RecordOverAllRuns [  ]
 set unempRate%RangeRecordOverAllRuns [  ]
 set vacancyRate%RecordOverAllRuns [  ]
 set LTU%RecordOverAllRuns [  ]
 
 set transitionRate%EtoUOverAllRuns [  ]
 set transitionRate%UtoEOverAllRuns [  ]
 set transitionRate%EtoIOverAllRuns [  ]
 set transitionRate%UtoIOverAllRuns [  ]
 
 set wageIncreaseFactor ( 1 + ( maxWageIncrease% / 100 ))
 set wageReductionFactor ( 1 - ( maxWageReduction% / 100 ))
 

end

;--------------------------------------------
to go 


repeat number-of-runs
[ 
  initialise-run-records
  initialise-run-workers
  initialise-run-employers
  record-initial-results
  
  repeat number-of-quarters
  
    [ 
      initialise-quarter
      ; Core dynamics
            ; retirement other movement in and out of the labour force - workers retire and are replaced by new unemployed workers
            in-and-out-of-labour-force
 
            ; business demographics - each quarter two of the employers go out of business and are replaced by two new ones
            make-business-changes
         
            ; frictional unemployment - workers leave and vacancies created
            create-frictional-unemployment
           
      run-job-market 
      collect-data-at-end-of-quarter 
     ]

  record-results-at-end-of-run  
]

record-results-at-end-of-all-runs 

end

;________________________________________________________________________________________________________________________________
; PROCEDURES
;________________________________________________________________________________________________________________________________

; INITIALISATION

to initialise-run-records

; counters  
set run-counter run-counter + 1  
set quarter-counter 0
    
; lists

set recruitingEmployersList [  ]

set meanWageRecord [  ]
set LTU%Record [  ]
set unempRate%Record [  ]   
set vacancyRate%Record [  ] 
set meanUnempRate%OverRun [  ] 
set meanVacancyRate%OverRun [ ]
set transitionRate%EtoURecord [  ]
set transitionRate%UtoERecord [  ] 
set transitionRate%EtoIRecord [  ]
set transitionRate%UtoIRecord [  ]

end

;--------------------------------------------------------------

to initialise-run-workers
  
 ask workers 
     [ initialise-workers 
       set age ( 20 + ( random 160 / 4 ) ) ; set age randomly but evenly distributed from 20 to 59, to nearest quarter
     ] 

; set wages 
if scenario = "Homog" 
    [ ask workers  [  set myWage 100 ] 
    ]

if scenario = "Guildford"
  [ 
    ask workers [ set myWage ( 10 * ( e ^ random-normal 1 0.7 ) )  ] 
    set unNormalisedMeanWage  mean [ myWage] of workers
    ask workers [ set myWage precision ( myWage * 100 /  unNormalisedMeanWage ) 0 
                  set myInitialWage myWage ]
 ]

end

;----------------------------------------------

to initialise-run-employers
 
 ask employers [  set mySize 0
                  initialise-employers ]

if scenario = "Homog"
    [ setInitialSize 100 10 ]
    
if scenario = "Guildford" 
   [ setInitialSize 1 100
     setInitialSize 1 97
     setInitialSize 3 50
     setInitialSize 4 30
     setInitialSize 27 15
     setInitialSize 64 2 
     ask employers with [ mySize > 95 ] [ set size 14 ]
   ] 

; allocate workers to employers
ask employers [ 
               ask n-of mySize workers with [ myEmployer = nobody ]  
                  [ 
                    set myEmployer myself 
                    set color blue 
                   ]
                
               set myEmployees count workers with [ myEmployer = myself ]    
               set listOfMyEmployees [ who ] of workers with [ myEmployer = myself ]    
               set listOfMyWages [ myWage ] of workers with [ myEmployer = myself ]                                          
              ]

end

;--------------------------------------------------
to record-initial-results
  
; to record initial distributions of wages and employer size
if run-counter = 1 [ initial-plots ]

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

;--------------------------------------------

to initialise-workers

   locate
   set shape "person"
   set color red
   set size 5 
   set dateOfEntry quarter-counter  
   set myEmployer nobody
   set my-work-history [ ]
   set durationOfU 0
   set completedUSpells 0
 
   
end

;-------------------------------------------------

to initialise-employers
  
    locate 
    set shape "pentagon"
    set color black
    set size 7 
    set myEmployees 0 
    set listOfMyEmployees [  ]
    set listOfMyWages [   ]
    set myWorkerProfile [  ]
    set myVacancies 0
    set myVacancyWages [  ] 
    set myUnfilledVacancyWages [  ]
    set listMyNewRecuits [  ]
    set myNewRecruits 0
    set myWageOffer 0
  
end  

;-------------------------------------------
to setInitialSize [ numberOfEmployers employerSize ]
  
  ask n-of numberOfEmployers employers with [ mySize = 0 ] [ set mySize employerSize ]

end  

;----------------------------------------------------------------------------------------------------------------------------
; DYNAMICS

to initialise-quarter
  
   set quarter-counter ( quarter-counter + 1 )

; reset

   ask workers 
    [ set tempStatus 0 
      set myPossibleEmployers[ ] 
    ]
   ask employers
    [ set myMaxWageOffer 0 
      set myLatestRecruit nobody
      set myNewRecruits 0
    ]
    
   set nOfNewEntrants 0
   set nOfReturningWorkers 0
   set nOfRedundantWorkers 0
   set nOfQuitters 0
   set nIntoWork 0
   set nIntoU 0
   set netFlow 0


   ask workers with [ myEmployer != nobody ] [ set color blue ]
   ask workers with [ myEmployer = nobody ] [ set durationOfU ( quarter-counter - startOfUSpell ) ]

; measuring unemployment here means that workers can leave work and get a job within the quarter and not be counted as unemployed
   set nOfUnemployedAtStartOfQuarter  count workers with [ myEmployer = nobody ] 
   set nOfEmployedAtStartOfQuarter count workers with [ myEmployer != nobody ] 
   set checkTotalAtStartQ  ( nOfUnemployedAtStartOfQuarter + nOfEmployedAtStartOfQuarter - 1000 ) ; should be 0

end 

;---------------------------------------------------------
to in-and-out-of-labour-force

; retirement
  ask workers [ set age ( age + 0.25 ) ]
  ask workers with [ age = 60 ]  [  set tempStatus "Retired" ]   
  set nOfRetirees count workers with [ tempStatus = "Retired" ]
  set nOfRetiredEmployees  count workers with  [ tempStatus = "Retired" and myEmployer != nobody ]
  set nOfRetiredUnemployed count workers with  [ tempStatus = "Retired" and myEmployer = nobody ]
  ask workers with  [ tempStatus = "Retired" and myEmployer != nobody]
        [ ask myEmployer [ calculate-vacancies ] ]
  ask workers with [ tempStatus = "Retired" ] [ die ]

  ; new workers join labour force: number set to exactly offset retirees
  ; but characteristics not matched
  set nOfNewEntrants nOfRetirees
  create-workers nOfNewEntrants
                  [ initialise-workers 
                    set age 20                  
                    set startOfUSpell quarter-counter  
                    set color red
                    
                    if scenario = "Homog" 
                        [ set myWage 100
                          become-unemployed]
                 
                    if scenario = "Guildford"
                         [ set myWage ( 10 * ( e ^ random-normal 1 0.7 ) )  
                           set myWage precision ( myWage * 100 /  unNormalisedMeanWage ) 0 
                           set myInitialWage myWage
                           become-unemployed
                          ]                           
                ]     
 
  ; other leavers 
  
  ; unemployed: % leaving set by slider  
  set nOfUnemployedLeavingLF precision ( nOfUnemployedAtStartOfQuarter * %UnempLeavingLF / 100 ) 0
  if nOfUnemployedLeavingLF > 0 
    [ ask n-of nOfUnemployedLeavingLF workers with [ age < 60 and myEmployer = nobody] 
       [ set tempStatus "LeavingLF" ] 
    ]
    
  ; employees: % leaving set by slider    
  set nOfEmployeesLeavingLF  precision ( nOfEmployedAtStartOfQuarter *  %EmpLeavingLF / 100 ) 0
  if nOfEmployeesLeavingLF > 0 
    [ ask n-of nOfEmployeesLeavingLF workers with [ age < 60 and myEmployer != nobody] 
       [ set tempStatus "LeavingLF" ] 
    ]
  ask workers with  [ tempStatus = "LeavingLF" and myEmployer != nobody]
        [ ask myEmployer [ calculate-vacancies ] ]
  ask workers with [ tempStatus = "LeavingLF" ] [ die ]

  ; new workers join labour force: number set to exactly offset leavers
  ; but characteristics not matched

  set nOfReturningWorkers ( nOfEmployeesLeavingLF + nOfUnemployedLeavingLF )
  create-workers  nOfReturningWorkers
                  [ initialise-workers 
                    set age ( 20 + ( random 160 / 4 ) )                
                    set startOfUSpell quarter-counter  
                    set color red
                    
                    if scenario = "Homog" 
                        [ set myWage 100
                          become-unemployed]
                 
                    if scenario = "Guildford"
                         [ set myWage ( 10 * ( e ^ random-normal 1 0.7 ) )  
                           set myWage precision ( myWage * 100 /  unNormalisedMeanWage ) 0 
                           set myInitialWage myWage
                           become-unemployed
                          ]                           
                ]        
end

;--------------------------------------------------------------------
to make-business-changes
  
; employers closing 
  if scenario = "Homog"
   [ set nOfEmployersClosing 2
     ask n-of 2 employers  [ set status "Closing"]
   ]  

  if scenario = "Guildford"
   [ set nOfEmployersClosing 2
     ask n-of 2 employers with [ mySize < 3 ]   [ set status "Closing"]
   ]  

  ask employers with [ status = "Closing" ] 
    [ ask workers with [ myEmployer = myself ] [ set tempStatus "Redundant"  ] ]
  
; not all closing employers may have full staff as some may have quit.

  set nOfRedundantWorkers count workers with [ tempStatus = "Redundant" ]

  ask workers with [ tempStatus = "Redundant" ] 
     [ set myLastEmployer "Dead"
       become-unemployed ]

  ask employers with [ status = "Closing" ] [ die ]

; new employers

  create-employers nOfEmployersClosing   
     [ initialise-employers
       set status "New"
       set color brown
       set date-of-entry quarter-counter ]

  if scenario = "Homog" 
     [ ask employers with [ status = "New" ] 
       [ set mySize 10 
         create-new-jobs
       ] 
     ]
   
  if scenario = "Guildford" 
     [ ask employers with [ status = "New" ] 
       [ set mySize 2 
         create-new-jobs 
       ]
      ]   
end

;-----------------------------------------------------------------
to  create-frictional-unemployment 
  set nOfEmployedAfterDemogAndBusinessChanges count workers with [ myEmployer != nobody ] 
  set nOfQuitters floor ( ( %EmpsLeavingJob / 100 ) * nOfEmployedAfterDemogAndBusinessChanges )   
  ask n-of nOfQuitters  workers with [ myEmployer != nobody ]  [ set tempStatus "Quitter" ]
 
  ; important to set status then do action - see Guidance
  ask workers with [ tempStatus = "Quitter" ]
      [ ask myEmployer [ calculate-vacancies ]   ]
    
  ; worker actions - must come after or else "myEmployer" = nobody   
 
  ask workers with [ tempStatus = "Quitter" ] 
  [ set myLastEmployer [ who ] of myEmployer 
    become-unemployed  ]
end 



;---------------------------------------------------------------------------------

to run-job-market

; nOfJobseekers should equal nOfJobOffers
  set nOfJobseekers  count workers with [ myEmployer = nobody ]
  set nOfJobOffers sum [ myVacancies ] of employers 
  set nOfRecruitingEmployers count employers with [ myVacancies > 0 ]
  set nOfRecruitingEmployers1 count employers with [ myVacancies = 1 ]
  set nOfRecruitingEmployers2 count employers with [ myVacancies = 2 ]
  set nOfRecruitingEmployers3plus count employers with [ myVacancies > 2 ]

  if run-counter = 1  
    [ plot-job-market 
      plot-recruiting-employers  ]

  recruit 

;-----------------
; after job search

  set nIntoWork count workers with [ tempStatus = "Into work" ]

; need to split those moving directly from job to job from those moving from unemployment into work
  set nUnempBackToWork count workers with [ tempStatus = "Into work" and startOfUSpell != quarter-counter ] 
  set nEmpBackToWork count workers with [ tempStatus = "Into work" and startOfUSpell = quarter-counter ] 

; to check this is being done correctly: ; should be 0
  set checkNIntoWork ( nIntoWork - nUnempBackToWork - nEmpBackToWork )

; ask workers to record work history
  ask workers [ set my-work-history lput myEmployer my-work-history ]

; employers 

  ask employers with [ status = "New" ]
   [ 
   set myEmployees count workers with [ myEmployer = myself ]    
   set listOfMyEmployees [ who ] of workers with [ myEmployer = myself ]    
   set listOfMyWages [ myWage ] of workers with [ myEmployer = myself ] 
   set status 0 
   ]

end

;___________________________________________________________________________________________________________________________________
; RESULTS (PLOTS also at end)
;___________________________________________________________________________________________________________________________________

to collect-data-at-end-of-quarter

; wages

  set meanWage mean [ myWage] of workers with [ myWage > 0 ]  

; unemployment rate

  set nOfUnemployedAtEndOfQuarter count workers with [ myEmployer = nobody ]
  set unemploymentRate%  precision ( nOfUnemployedAtEndOfQuarter / nOfWorkers * 100 ) 2 ; 'workers' = employed and unemployed
 
  ; to measure duration

  if nOfUnemployedAtStartOfQuarter  > 0 
    [ set LTU% precision (( count workers with  [ durationOfU > 3 ] ) / nOfUnemployedAtStartOfQuarter  * 100 ) 1 ]
  
  if number-of-quarters > run-in-time   [ set LTU%Record lput LTU% LTU%Record  ]

  set totalLabourDemand sum [ mySize ] of employers ; check 

  set totalVacanciesAtEndOfQuarter sum [ myVacancies ] of employers 
  set vacancyRate%  precision (( totalVacanciesAtEndOfQuarter / totalLabourDemand ) * 100 ) 1
 
  set nIntoU ( nOfQuitters + nOfRedundantWorkers + nOfNewEntrants + nOfReturningWorkers ) 
  set netFlow ( nIntoWork - nIntoU )


;  Transition rates

; Out of employment
; From employment to unemployment: workers quitting and being made redundant
  set transitionRate%EtoU precision ( ( ( nOfQuitters + nOfRedundantWorkers ) / nOfEmployedAtStartOfQuarter ) * 100 ) 3

; From employment out of labour force - retiring and leaving for other reasons
  set transitionRate%EtoI precision ( ( ( nOfRetiredEmployees + nOfEmployeesLeavingLF )/ nOfEmployedAtStartOfQuarter ) * 100 ) 2

; Out of unemployment 
; Those leaving jobs abd moving back into employment within quarter do NOT count as unemployed
; So need to exclude those who become unemployed in this quarter

  ifelse nOfUnemployedAtStartOfQuarter > 0
    [ set transitionRate%UtoE precision ( (nUnempBackToWork / nOfUnemployedAtStartOfQuarter  ) * 100 ) 2 
      set transitionRate%UtoI precision ( ( ( nOfRetiredUnemployed + nOfUnemployedLeavingLF ) / nOfUnemployedAtStartOfQuarter  ) * 100 ) 2 ]
    [ set transitionRate%UtoE  0 
      set transitionRate%UtoI  0]

; data collection

  if quarter-counter > run-in-time   
    [ 
      set meanWageRecord lput meanWage meanWageRecord
        
      set unempRate%Record lput unemploymentRate% unempRate%Record 
      set vacancyRate%Record lput  vacancyRate% vacancyRate%Record
      set LTU%Record lput LTU% LTU%Record

      set transitionRate%EtoURecord lput transitionRate%EtoU transitionRate%EtoURecord 
      set transitionRate%UtoERecord lput transitionRate%UtoE transitionRate%UtoERecord
      set transitionRate%EtoIRecord lput transitionRate%EtoI transitionRate%EtoIRecord
      set transitionRate%UtoIRecord lput transitionRate%UtoI transitionRate%UtoIRecord
    ]
    
; plots 
  if run-counter = 1
   [  plot-rates%
      plot-long-term-unemployed%
      plot-flows  
      plot-wage-changes
      plot-wages
   ]

if run-counter = 1 and quarter-counter > 1 [ plot-transition-rates ]

; error messages

; micro - workers
if totalVacanciesAtEndOfQuarter != nOfUnemployedAtEndOfQuarter [ set unempError "Yes" ]   

end

;---------------------------------------------
to record-results-at-end-of-run

  if quarter-counter > run-in-time  
   [
    set meanWageOverRun precision mean (  meanWageRecord ) 2
    set meanUnempRate%OverRun precision mean ( unempRate%Record ) 2 
    set rangeUnempRate%OverRun precision ( max unempRate%Record - min unempRate%Record ) 2  
    set meanVacancyRate%OverRun precision mean ( vacancyRate%Record ) 2
    set meanLTU%OverRun precision mean ( LTU%Record ) 2
    
    set meanTransitionRate%EtoURecord precision mean ( transitionRate%EtoURecord ) 2
    set meanTransitionRate%UtoERecord precision mean ( transitionRate%UtoERecord ) 2
    set meanTransitionRate%EtoIRecord precision mean ( transitionRate%EtoIRecord ) 2
    set meanTransitionRate%UtoIRecord precision mean ( transitionRate%UtoIRecord ) 2
   ]
  
  if number-of-runs > 1 and quarter-counter > run-in-time  
  
  [   
    set meanWageOverAllRuns lput meanWageOverRun meanWageOverAllRuns 
    set unempRate%RecordOverAllRuns lput meanUnempRate%OverRun unempRate%RecordOverAllRuns 
    set unempRate%RangeRecordOverAllRuns lput rangeUnempRate%OverRun unempRate%RangeRecordOverAllRuns
    set vacancyRate%RecordOverAllRuns lput meanVacancyRate%OverRun vacancyRate%RecordOverAllRuns 
    set LTU%RecordOverAllRuns lput meanLTU%OverRun LTU%RecordOverAllRuns
    
    set transitionRate%EtoUOverAllRuns lput meanTransitionRate%EtoURecord  transitionRate%EtoUOverAllRuns
    set transitionRate%UtoEOverAllRuns lput meanTransitionRate%UtoERecord  transitionRate%UtoEOverAllRuns
    set transitionRate%EtoIOverAllRuns lput meanTransitionRate%EtoIRecord  transitionRate%EtoIOverAllRuns  
    set transitionRate%UtoIOverAllRuns lput meanTransitionRate%UtoIRecord  transitionRate%UtoIOverAllRuns  
  ]

end
 
;---------------------------------------------
to record-results-at-end-of-all-runs  
  
  
  if number-of-quarters > run-in-time  and number-of-runs = 1 
    [ ; results to file
     file-open ( word scenario "-" %EmpsLeavingJob "-"maxWageIncrease%"-"maxWageReduction%"-"number-of-quarters "("run-in-time") Qs-" number-of-runs"-.csv" )
     
     file-print ( word scenario )
     file-print ( word "%EmpsLeavingJob " %EmpsLeavingJob )
     file-print ( word "%UnempLeavingLF " %UnempLeavingLF )
     file-print ( word "%EmpLeavingLF " %EmpLeavingLF )
     file-print ( word "maxWageIncrease% " maxWageIncrease% )
     file-print ( word "maxWageReduction% "maxWageReduction% )
     file-print "  "
     file-print ( word "Results over " number-of-quarters " quarters  (ignoring first " run-in-time ") and " number-of-runs " run"  )
     file-print "  "
     file-print (word "Mean wage: " meanWageOverRun " (sd " precision standard-deviation ( meanWageRecord ) 2 " )"  )
     file-print (word "Vacancy rate %: mean: " meanVacancyRate%OverRun " (sd " precision standard-deviation ( vacancyRate%Record ) 2 " )"  )
     file-print (word "Unemployment rate %: mean: " meanUnempRate%OverRun " (sd " precision standard-deviation ( unempRate%Record ) 2 " )"  )
     file-print (word "Unemployment rate %: range: " rangeUnempRate%OverRun )
     file-print (word "Long-term unemployed %: mean: "  meanLTU%OverRun "  (sd " precision standard-deviation (  LTU%Record ) 2 " )" )
     file-print "Hazard Rates  "
     file-print (word "  E to U %: mean: " meanTransitionRate%EtoURecord " (sd " precision standard-deviation ( transitionRate%EtoURecord ) 2 " )"  )
     file-print (word "  U to E %: mean: " meanTransitionRate%UtoERecord " (sd " precision standard-deviation ( transitionRate%UtoERecord ) 2 " )"  )
     file-print (word "  E to I %: mean: " meanTransitionRate%EtoIRecord " (sd " precision standard-deviation ( transitionRate%EtoIRecord ) 2 " )"  )
     file-print (word "  U to I %: mean: " meanTransitionRate%UtoIRecord " (sd " precision standard-deviation ( transitionRate%UtoIRecord ) 2 " )"  )
  
     file-close
     
    ; results to interface
    
     output-print ( word "Results over " number-of-quarters " quarters  (ignoring first " run-in-time ") and " number-of-runs " run"  )
     output-print "  "
     output-print (word "Mean wage: " meanWageOverRun " (sd " precision standard-deviation ( meanWageRecord ) 2 " )"  )
     output-print (word "Vacancy rate %: mean: " meanVacancyRate%OverRun " (sd " precision standard-deviation ( vacancyRate%Record ) 2 " )"  )
     output-print (word "Unemployment rate %: mean: " meanUnempRate%OverRun " (sd " precision standard-deviation ( unempRate%Record ) 2 " )"  )
     output-print (word "Unemployment rate %: range: " rangeUnempRate%OverRun )
     output-print (word "Long-term unemployed %: mean: "  meanLTU%OverRun "  (sd " precision standard-deviation (  LTU%Record ) 2 " )"  )
  
     output-print "Hazard Rates  "
     output-print (word "  E to U %: mean: " meanTransitionRate%EtoURecord " (sd " precision standard-deviation ( transitionRate%EtoURecord ) 2 " )"  )
     output-print (word "  U to E %: mean: " meanTransitionRate%UtoERecord " (sd " precision standard-deviation ( transitionRate%UtoERecord ) 2 " )"  )
     output-print (word "  E to I %: mean: " meanTransitionRate%EtoIRecord " (sd " precision standard-deviation ( transitionRate%EtoIRecord ) 2 " )"  )
     output-print (word "  U to I %: mean: " meanTransitionRate%UtoIRecord " (sd " precision standard-deviation ( transitionRate%UtoIRecord ) 2 " )"  )
          
   ]

if number-of-quarters > run-in-time and number-of-runs > 1  
  [  
    ; results to file
     file-open ( word scenario "-" %EmpsLeavingJob "-" number-of-quarters "("run-in-time") Qs-" maxWageIncrease% "%I-" maxWageReduction% "%D-"number-of-runs"-.csv" )
    
     file-print ( word scenario )
     file-print ( word "%EmpsLeavingJob " %EmpsLeavingJob )
     file-print ( word "maxWageIncrease% " maxWageIncrease% )
     file-print ( word "maxWageReduction% "maxWageReduction% )
     file-print "  "
    
     file-print ( word "Results over " number-of-quarters " quarters (ignoring first " run-in-time ") and " number-of-runs " runs"  )
     file-print "  "
     file-print (word "Mean wage: " precision mean ( meanWageOverAllRuns ) 2 " (sd " precision standard-deviation ( meanWageOverAllRuns ) 2 " )" )
     
     file-print (word "Vacancy rate %: mean: " precision mean ( vacancyRate%RecordOverAllRuns ) 2 " (sd " precision standard-deviation ( vacancyRate%RecordOverAllRuns ) 2 " )"  )
     file-print (word "Unemployment rate %: mean: " precision mean ( unempRate%RecordOverAllRuns ) 2 " (sd " precision standard-deviation ( unempRate%RecordOverAllRuns ) 2 " )"  )
     file-print (word "Unemployment rate %: range: "  precision mean ( unempRate%RangeRecordOverAllRuns  ) 2 " (sd " precision standard-deviation ( unempRate%RangeRecordOverAllRuns  ) 2 " )"  ) 
     file-print (word "Long-term unemployed %: mean: " precision mean ( LTU%RecordOverAllRuns  ) 2 " (sd " precision standard-deviation ( LTU%RecordOverAllRuns ) 2 " )"  )
  
     file-print "Hazard  Rates  "
     file-print (word "  E to U %: mean: " precision mean ( transitionRate%EtoUOverAllRuns ) 2 " (sd " precision standard-deviation ( transitionRate%EtoUOverAllRuns ) 2 " )"  )
     file-print (word "  U to E %: mean: " precision mean ( transitionRate%UtoEOverAllRuns ) 2 " (sd " precision standard-deviation ( transitionRate%UtoEOverAllRuns ) 2 " )"  )
     file-print (word "  E to I %: mean: " precision mean ( transitionRate%EtoIOverAllRuns ) 2 " (sd " precision standard-deviation ( transitionRate%EtoIOverAllRuns ) 2 " )"  )
     file-print (word "  U to I %: mean: " precision mean ( transitionRate%UtoIOverAllRuns ) 2 " (sd " precision standard-deviation ( transitionRate%UtoIOverAllRuns ) 2 " )"  )
     
     file-close  
     
     ; results to interface
     output-print ( word "Results over " number-of-quarters " quarters (ignoring first " run-in-time ") and " number-of-runs " runs"  )
     output-print "  "
     output-print (word "Mean wage: " precision mean ( meanWageOverAllRuns ) 2 " (sd " precision standard-deviation ( meanWageOverAllRuns ) 2 " )" )
     output-print (word "Vacancy rate %: mean: " precision mean ( vacancyRate%RecordOverAllRuns ) 2 " (sd " precision standard-deviation ( vacancyRate%RecordOverAllRuns ) 2 " )"  )
     output-print (word "Unemployment rate %: mean: " precision mean ( unempRate%RecordOverAllRuns ) 2 " (sd " precision standard-deviation ( unempRate%RecordOverAllRuns ) 2 " )"  )
     output-print (word "Unemployment rate %: mean of range: " precision mean ( unempRate%RangeRecordOverAllRuns ) 2 " (sd " precision standard-deviation ( unempRate%RangeRecordOverAllRuns  ) 2 " )"  )
     output-print (word "Long-term unemployed %: mean: " precision mean ( LTU%RecordOverAllRuns  ) 2 " (sd " precision standard-deviation ( LTU%RecordOverAllRuns ) 2 " )"  )
  
     output-print "Hazard Rates  "
     output-print (word "  E to U %: mean: " precision mean ( transitionRate%EtoUOverAllRuns ) 2 " (sd " precision standard-deviation ( transitionRate%EtoUOverAllRuns ) 2 " )"  )
     output-print (word "  U to E %: mean: " precision mean ( transitionRate%UtoEOverAllRuns ) 2 " (sd " precision standard-deviation ( transitionRate%UtoEOverAllRuns ) 2 " )"  )
     output-print (word "  E to I %: mean: " precision mean ( transitionRate%EtoIOverAllRuns ) 2 " (sd " precision standard-deviation ( transitionRate%EtoIOverAllRuns ) 2 " )"  )
     output-print (word "  U to I %: mean: " precision mean ( transitionRate%UtoIOverAllRuns ) 2 " (sd " precision standard-deviation ( transitionRate%UtoIOverAllRuns ) 2 " )"  )   
     ]


export-all-plots ( word "Plots-" scenario "-" %EmpsLeavingJob "-" maxWageIncrease% "%I-" maxWageReduction% "%D-"number-of-quarters " Qs.csv" )

end

;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
; SUBROUTINES

to become-unemployed     
     
        set myEmployer nobody 
        set myLastWage myWage
        set myWage 0
        set color red 
        set startOfUSpell quarter-counter      
  
end

;-------------------------------
to create-new-jobs
       repeat mySize 
        [ 
          if scenario = "Homog" 
           [ 
             set myWageOffer 100 
             create-vacancy 
           ]
          
          if scenario = "Guildford"
             [ 
               set myWageOffer ( 10 * ( e ^ random-normal 1 0.7 ) )
               set myWageOffer precision ( myWageOffer * 100 /  unNormalisedMeanWage ) 0  
               create-vacancy 
             ]
        ]
end

;------------------------
to calculate-vacancies
; employer action initiated by workers quitting and retiring

             set myWageOffer [ myWage ] of myself 
             create-vacancy              
             set color green                     
             set listOfMyEmployees  remove [ who ] of myself   listOfMyEmployees     
             set myEmployees count workers with [ myEmployer = myself ]
end

;------------------------
; a set of employer actions - used by workers who quit and new employers
to create-vacancy 
; employer action
   set myVacancies ( myVacancies  + 1 ) 
   set myVacancyWages lput myWageOffer  myVacancyWages
end              

;--------------------------

to recruit

ask employers with [ myVacancies > 0 ]  
   [  set myVacancyWages sort-by > myVacancyWages  
 ]    

; employers list vacancies by order of size of wage offer, starting with highest
repeat nOfJobOffers

 [   
   ask employers with [ myVacancies > 0 ] [ set myMaxWageOffer item 0 myVacancyWages ] 
   ; to sort employers by highest wage offered
   set recruitingEmployersList  sort-by [ [ myMaxWageOffer ] of ?1 >= [ myMaxWageOffer ] of ?2 ] employers with [ myVacancies > 0 ]

   ask item 0 recruitingEmployersList ; employer offering highest wage
      [
         set myPossibleEmployees  workers with [ myEmployer = nobody 
                                               and myLastEmployer  != myself 
                                               and wageIncreaseFactor *  myLastWage  >= [ myMaxWageOffer ] of myself 
                                               and wageReductionFactor *  myLastWage <= [ myMaxWageOffer ] of myself  
                                               ]
        ; selects one with highest last wage 
        if myPossibleEmployees != nobody  [ set myLatestRecruit max-one-of myPossibleEmployees [ myLastWage ] ] 
    
        if myLatestRecruit != nobody 
          [ 
            ; worker actions           
            ask myLatestRecruit
            [ set myEmployer myself 
              set myWage [ myMaxWageOffer ] of myEmployer  
              set myWageChange% precision ( ( myWage - myLastWage ) / myLastWage * 100  ) 1
              set durationOfU 0
              set completedUSpells  ( completedUSpells + 1 ) 
              set color violet
              set tempStatus "Into work"
             ] ; end of worker actions
           ; employer actions 
           set listOfMyEmployees  lput [ who ] of myLatestRecruit listOfMyEmployees 
          
           set myNewRecruits ( myNewRecruits + 1 ) 
           set listMyNewRecuits lput myLatestRecruit  listMyNewRecuits 
          ]  
          
           ; employer actions whether or not job filled
          
           set myEmployees count workers with [ myEmployer = myself ]   
           set myVacancies ( myVacancies - 1 )
                  
           if myLatestRecruit = nobody 
             [ 
               set myUnfilledVacancies  ( myUnfilledVacancies + 1 ) 
               set myUnfilledVacancyWages lput ( item 0 myVacancyWages ) myUnfilledVacancyWages 
             ]    
         
           set myVacancyWages  remove-item 0  myVacancyWages    

        ] ; to end actions by item 0   
    
    ] ; to end repeat        

; reset
  ask employers 
    [ set myVacancies myUnfilledVacancies
      set myUnfilledVacancies 0
      set myVacancyWages myUnfilledVacancyWages 
      set myUnfilledVacancyWages [  ]  
     ]        

; error messages
  if any? workers with [ myEmployer != 0 and myLastEmployer != 0 and myEmployer =  myLastEmployer ] [ set errorLastEmployer  "Yes"]    
  if any? workers with [ tempStatus = "Into work" and myWageChange% >= 0 and myWageChange% > maxWageIncrease% ]  [ set wageError "Yes" ]
  if any? workers with [ tempStatus = "Into work" and myWageChange% <= 0 and myWageChange% < (- maxWageReduction% ) ]  [ set wageError "Yes" ]

  if any? employers with [ myVacancies + myEmployees !=  mySize ] [ set sizeError "Yes" ]                                                                                      

end   
   
;--------------------------------------------
; PLOTS
;--------------------------------------------

to initial-plots
 
  set-current-plot "Initial wage distribution"
  set-plot-x-range 0 1000
  set-plot-y-range 0 100
  set-histogram-num-bars 100
  histogram [ myWage ] of workers  
  
  set-current-plot "Employer sizes"
  set-plot-x-range 0 110
  set-plot-y-range 0 100
  set-histogram-num-bars 110
  histogram [ mySize ] of employers  
  
end


to plot-job-market
  set-current-plot "Job Market"
  set-current-plot-pen "Seek"
  plotxy quarter-counter nOfJobseekers  
  set-current-plot-pen "Vacs"
  plotxy quarter-counter nOfJobOffers 
  
end

to plot-recruiting-employers  
  set-current-plot "Recruiting employers" 
  set-current-plot-pen "All"
  plotxy quarter-counter nOfRecruitingEmployers 
  set-current-plot-pen "1Vac"
  plotxy quarter-counter nOfRecruitingEmployers1 
  set-current-plot-pen "2Vacs"
  plotxy quarter-counter nOfRecruitingEmployers2 
  set-current-plot-pen "3+Vacs"
  plotxy quarter-counter nOfRecruitingEmployers3plus
end


to plot-rates%
  
  set-current-plot "U and V Rates %"
  set-current-plot-pen "Unemp"
  plotxy quarter-counter unemploymentRate%   
  set-current-plot-pen "Vacs"
  plotxy quarter-counter vacancyRate%   

end
    
to plot-flows
  
  set-current-plot "Flows"
  set-current-plot-pen "Retd"
  plotxy quarter-counter nOfRetirees
  set-current-plot-pen "New"
  plotxy quarter-counter nOfNewEntrants ; nOfRetirees = nOfNewEntrants
  set-current-plot-pen "LLF"
  plotxy quarter-counter ( nOfEmployeesLeavingLF + nOfUnemployedLeavingLF )
  set-current-plot-pen "Return"
  plotxy quarter-counter nOfReturningWorkers ; nLeavingLF = nOfReturningWorkers
  set-current-plot-pen "Quit"
  plotxy quarter-counter nOfQuitters
  set-current-plot-pen "Red"
  plotxy quarter-counter nOfRedundantWorkers
  set-current-plot-pen "To U"
  plotxy quarter-counter nIntoU ; nOfQuitters + nOfRedundantWorkers + nOfYNewEntrants + nOfReturningWorkers 
  set-current-plot-pen "U to E"
  plotxy quarter-counter nUnempBackToWork
  set-current-plot-pen "E to E"
  plotxy quarter-counter nEmpBackToWork
  set-current-plot-pen "To E"
  plotxy quarter-counter nIntoWork  ; nUnempBackToWork + nEmpBackToWork 
  set-current-plot-pen "Net U"
  plotxy quarter-counter netFlow ;  nIntoWork - nIntoU
    
end   

to plot-transition-rates
  
  set-current-plot "Transition rates"
  set-current-plot-pen "E->U"
  plotxy quarter-counter transitionRate%EtoU 
  set-current-plot-pen "U->E"
  plotxy quarter-counter transitionRate%UtoE 
  set-current-plot-pen "E->I"
  plotxy quarter-counter transitionRate%EtoI 
  set-current-plot-pen "U->I"
  plotxy quarter-counter transitionRate%UtoI
  
end  

to plot-long-term-unemployed%
  
  set-current-plot "LT Unemployed %"
  plotxy quarter-counter LTU% 

end   


to plot-wage-changes

  set-current-plot "Wage changes"
  set-current-plot-pen "+"
  plotxy quarter-counter count workers with [ myWageChange% > 0 ]
  set-current-plot-pen "0"
  plotxy quarter-counter count workers with [ myWageChange% = 0 ]
  set-current-plot-pen "-"
  plotxy quarter-counter count workers with [ myWageChange% < 0 ]

end  

to plot-wages
  set-current-plot "Wages (in emp)"
  set-current-plot-pen "max"
  plotxy quarter-counter  max [ myWage ] of workers with [ myEmployer != nobody ] 
  set-current-plot-pen "min"
  plotxy quarter-counter min [ myWage ] of workers with [ myEmployer != nobody ] 
  set-current-plot-pen "mean"
  plotxy quarter-counter meanWage
  
end  

;___________________________________________________________________________________________________________________________________________________________
;___________________________________________________________________________________________________________________________________________________________
@#$#@#$#@
GRAPHICS-WINDOW
21
795
490
1285
200
200
1.145
1
10
1
1
1
0
1
1
1
-200
200
-200
200
0
0
1
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

PLOT
926
672
1174
792
Initial wage distribution
Wages
Workers
0.0
1000.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

CHOOSER
114
10
252
55
number-of-runs
number-of-runs
1 2 10 30
1

CHOOSER
160
64
318
109
scenario
scenario
"Homog" "Guildford"
1

PLOT
692
671
909
791
Employer Sizes
Size
Frequency
0.0
110.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

PLOT
353
222
737
457
U and V Rates %
Quarter 
Rates %
0.0
200.0
0.0
10.0
true
true
"" ""
PENS
"Unemp" 1.0 0 -2674135 true "" ""
"Vacs" 1.0 0 -13345367 true "" ""

SLIDER
217
115
403
148
%EmpsLeavingJob
%EmpsLeavingJob
0
10
1
0.5
1
NIL
HORIZONTAL

CHOOSER
380
10
518
55
number-of-quarters
number-of-quarters
1 2 12 100 200 500 1000
4

MONITOR
526
12
628
57
NIL
quarter-counter
0
1
11

PLOT
847
432
1218
653
Flows
Quarters
Number
0.0
200.0
-50.0
50.0
true
true
"" ""
PENS
"Retd" 1.0 0 -7500403 true "" ""
"New" 1.0 0 -955883 true "" ""
"Quit" 1.0 0 -6459832 true "" ""
"LLF" 1.0 0 -2064490 true "" ""
"Return" 1.0 0 -14835848 true "" ""
"Red" 1.0 0 -5825686 true "" ""
"To U" 1.0 0 -2674135 true "" ""
"U to E" 1.0 0 -11221820 true "" ""
"E to E" 1.0 0 -5325092 true "" ""
"To E" 1.0 0 -13345367 true "" ""
"Net U" 1.0 0 -16777216 true "" ""

PLOT
357
460
690
618
LT Unemployed %
Quarter
Per cent
0.0
200.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

MONITOR
927
797
1112
842
mean wage of workers in emp
mean [ myWage] of workers with [ myWage > 0 ]
1
1
11

OUTPUT
774
10
1218
187
12

PLOT
846
197
1221
428
Transition rates
Quarter
%
0.0
200.0
0.0
100.0
true
true
"" ""
PENS
"E->U" 1.0 0 -2674135 true "" ""
"U->E" 1.0 0 -13345367 true "" ""
"E->I" 1.0 0 -13840069 true "" ""
"U->I" 1.0 0 -5825686 true "" ""

MONITOR
257
10
359
55
NIL
run-counter
0
1
11

TEXTBOX
15
199
165
230
PLOTS FOR FIRST RUN
11
0.0
1

TEXTBOX
16
136
206
164
This is in addition to redundancies and retirement.
11
0.0
1

PLOT
11
650
327
793
Wage changes
Quarter
Number
0.0
200.0
0.0
1000.0
true
true
"" ""
PENS
"+" 1.0 0 -13345367 true "" ""
"0" 1.0 0 -16777216 true "" ""
"-" 1.0 0 -2674135 true "" ""

MONITOR
534
887
605
932
NIL
wageError
0
1
11

SLIDER
220
152
407
185
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
415
154
588
187
maxWageReduction%
maxWageReduction%
0
90
10
1
1
NIL
HORIZONTAL

PLOT
342
652
655
791
Wages (in emp)
Quarters
Mean  wage
0.0
200.0
0.0
110.0
true
true
"" ""
PENS
"max" 1.0 0 -8630108 true "" ""
"min" 1.0 0 -13840069 true "" ""
"mean" 1.0 0 -16777216 true "" ""

MONITOR
534
839
655
884
NIL
checkTotalAtStartQ
0
1
11

CHOOSER
382
59
474
104
run-in-time
run-in-time
100 300
0

TEXTBOX
484
64
590
105
Quarters for which results ignored.
11
0.0
1

SLIDER
415
117
587
150
%UnempLeavingLF
%UnempLeavingLF
0
100
15
1
1
NIL
HORIZONTAL

SLIDER
594
117
766
150
%EmpLeavingLF
%EmpLeavingLF
0
10
2
.5
1
NIL
HORIZONTAL

PLOT
6
223
326
381
Recruiting employers
Quarter
Number
0.0
200.0
0.0
50.0
true
true
"" ""
PENS
"All" 1.0 0 -13840069 true "" ""
"1Vac" 1.0 0 -14835848 true "" ""
"2Vacs" 1.0 0 -6459832 true "" ""
"3+Vacs" 1.0 0 -955883 true "" ""

TEXTBOX
15
119
165
138
Leaving probabilities
15
0.0
1

TEXTBOX
16
159
116
177
Wage flexibility
15
0.0
1

PLOT
8
386
328
600
Job Market
NIL
NIL
0.0
200.0
0.0
200.0
true
true
"" ""
PENS
"Seek" 1.0 0 -2674135 true "" ""
"Vacs" 1.0 0 -13345367 true "" ""

TEXTBOX
286
444
325
514
Seekers = vacs
11
0.0
1

TEXTBOX
691
278
736
349
Unemp rate = vac rate
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

A very simple model of the labour market to illustrate the undrlying dynamics.


## HOW IT WORKS

The number of workers is set at 1 000 and there are 100 employers.

Workers' ages are divided evenly from 20 to 59, in quarters (i.e. 3 months).

###Scenarios

Only two scenarios: "Homog" (meaning homogeneous) and "Guildford".

#### Workers


For the "Homog" scenario, all workers have wages of 100.

For "Guildford" scenario, workers have different wages. Wages are allocated according to a normalised log normal distribution, with a mean of 1 and a standard deviation of 0.7. The quintile points of the distribution are calculated and the workers are divided into five groups: top, upper, middle, lower and bottom. 

#### Employers

For the "Homog" scenario, all employers are the same size: 10.
 
For "Guildford" scenario, the 10 employers and 1 000 workers are distributed as follows:  
     1 employer with 100 workers
     1 employer with 97 workers
     3 employers with 50 workers
     4 employers with 30 workers
    27 employers with 15 workers
    64 employers with 2 workers

### Initial conditions

Workers are allocated randomly to employers, so that initially there is full employment. This initial random allocation sets the employee structure for the employer.

### Dynamics
Each quarter:

####Movements in and out of the labour force
Workers aged 60 retire. They are replaced by new entrants, aged 20. 

Some workers under 60 leave the labour force either from employment or from unemployment. The proportions are set by a slider and the leavers are chosen at random. They are replaced by workers of random age.

The initial wage for the new workers is generated by the same formula as used at the start of the program. This ensures that the average wage is maintained.

####Business demographics
Some employers "die" and replacements are "born". Two employers close each quarter. For the "Guildford" scenario, only the smallest employers die.

All three processes generate unemployment and vacancies.

Employers calculate their vacancies. Existing employers use the same wage level paid to the worker who has left or retired. For new employers, the wages offered by the replacements are generated by the same formula used to calculate the wages initially.

###The labour market

Workers take the wage offered by the employer. However, all workers cannot seek all jobs. Workers can only take a vacancy offering a wage in the band set by the maxWageIncrease% and maxWageReduction% sliders. 

For example, if maxWageIncrease% is set at 10 and maxWageReduction% set at 0, then workers will only seek job paying at least the same as their last wage and up to 10% higher i.e. none will accept a reduction in wages. But if maxWageReduction% is also set at 10, then workers can take jobs at +/- 10 per cent of their last wage. 

This allows workers to have some, but limited, upward and downward mobility.

The unemployed workers and the recruiting employers are brought together in the labour market using the employer-led procedure described in the job-search model.



### Output

The graphs are produced for the first run only and record the results from quarter 1. These are set to a csv file.

Summary results are sent to the Interface and to a seprate csv file.

Measurements are only recorded after the period set by the run-in time slider.


## CREDITS AND REFERENCES

Runs on NetLogo 5.2.

For more information, see Hamill, L. & Gilbert, N. (2016) Agent-based Modelling in Economics. Wiley: Chapter 7.

To refer to this model: Hamill, L. & Gilbert, N. (2016) Guildford Labour Market model.



Hamill & Gilbert, May 2014.
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
