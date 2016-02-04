;Project Lynxmotion Phoenix
;Description: Phoenix software
;Software version: V2.1 alfa
;Date: 15-04-2011
;Programmer: Jeroen Janssen (aka Xan)
;
; SSC Driver - Contains all of the code that knows anything about the Arc32
;		being used to drive the servos
; 		It also has timer functions as this may also change with drivers...
;
;====================================================================

;[GP PLAYER]
wGPSeqPtr		var word
abGPServoPins	var	byte(32)		; remember which pins are defined for this sequence
bGPCntServos	var	byte			; how many servos are used in this sequence
bGPServoNum		var	byte
bGPCntSteps		var	byte			; how many moves are in this sequence...
bGPStepNum		var	byte			; which step are we on.
awGPStepServoVals var	word(32)	; servo value for each pin in desired pulse width
swHSVal			var	sword			; converted to HServo value.
wGPStepTime		var	word			; How long this step will take
lGPNextStepTime	var	long			; When we should start the next step in the sequence...

; [Servo Driver variables]
;[HServo - or SSC32?]
StepsPerDegree 		con 200
aswCoxaServo	var sword(6)	; pre-calculated HSERVO values from Angles above
aswFemurServo	var sword(6)
aswTibiaServo	var sword(6)
#ifdef c4DOF
aswTarsServo	var sword(6)
#endif

fFirstMove		var bit			; need to handle first move specially...

; define the offset in the ARC32 EEPROM where we emulate the SSC-32 from
ARC32_SSC_OFFSET	con	0x400		; we will offset saving all of the SSC-32 by this amount
SERVOSAVECNT	con	32				
aServoOffsets	var	sword(SERVOSAVECNT)		; Our new values - must take stored away values into account...
bCSIn		var		byte					; used in Read/Write servo offsets - checksum read
bCSCalc		var		byte					; Used in Read/Write Servo offsets - calculated checksum



;--------------------------------------------------------------------
;[TIMER INTERRUPT INIT]
#ifndef BASICATOMPROARC32
Error: This only works on Arc32
#endif
  WTIMERTICSPERMSMUL con 256	; Arc32 is 20mhz need a multiplyer and divider to make the conversion with /8192
  WTIMERTICSPERMSDIV con 625  ; 



;--------------------------------------------------------------------
;[InitServoDriver] - Initializes the servo driver including the main timer used in the phoenix code
InitTimer:	; Can use either name...
InitServoDriver:
; Arc32 will use timer associated with HSERVO

  ; DEBUG: setup 
  sethserial1 H38400

; Read in servo offsets.
  gosub ReadServoOffsets
  
  gosub FreeServos

  return


;==============================================================================
; Subroutine: ReadServoOffsets
; Will read in the zero points that wer last saved for the different servos
; that are part of this robot.  
;
;==============================================================================
ReadServoOffsets:
	readdm 31, [ bCSIn]
	readdm 32, [str aServoOffsets\32]	; We are storing words now.
	readdm 64, [str aServoOffsets(16)\32]
	bCSCalc = 0
	for Index = 0 to SERVOSAVECNT-1
		bCSCalc = bCSCalc + AServoOffsets(Index).lowbyte + AServoOffsets(Index).highbyte
	next
		
	if bCSCalc <> bCSIn then 
      	Sound cSpeakerPin,[60\4000,100\5000, 60\4000]	' make some noise...
		aServoOffsets = rep 0\SERVOSAVECNT
	endif

	return



;==============================================================================
;[GetCurrentTime] - Gets the Timer value from our overflow counter as well as the TCA counter.  It
;                makes sure of consistancy. That is it is very posible that 
;                after we grabed the timers value it overflows, before we grab the other part
;                so we check to make sure it is correct and if necesary regrab things.
;==============================================================================
GetCurrentTime:
  lCurrentTime = HSERVOTIME 13	; Clock / 8192
  return lCurrentTime


;-------------------------------------------------------------------------------------
;[ConvertTimeMS]
_ttconv	var	long
ConvertTimeMS[_ttconv]:
	return (_ttconv * WTIMERTICSPERMSMUL)/WTIMERTICSPERMSDIV 


;--------------------------------------------------------------------

;[CheckGPEnable] Checks to see if the driver supports General Purpose sequences
CheckGPEnable:
	
  pause 10
  GPEnable=1
  
  return 1		; We roll our own...

;--------------------------------------------------------------------
;[GP PLAYER]
GPPlayer:
  ;Start sequence
  IF (GPStart=1) THEN
    readdm ARC32_SSC_OFFSET + GPSEQ*2, [str wGPSeqPtr\2]
;	hserout 1, ["GP: ", dec GPSEQ, 13]
    ; make sure there is a sequence...
    IF (wGPSeqPtr <> 0)  and (wGPSeqPtr <> 0xffff)	THEN
	  ; now lets get the header information, will skip sequence number
	  readdm wGPSeqPtr+1,[bGPCntServos, bGPCntSteps]

	  ; now lets read in the pins
	  wGPSeqPtr = wGPSeqPtr + 3 ; point to start of pin information.
	  for bGPServoNum = 0 to bGPCntServos - 1
		readdm wGPSeqPtr, [abGPServoPins(bGPServoNum)]	; read in the pin, igore max value after
		wGPSeqPtr = wGPSeqPtr + 3
	  next

	  ; now lets start cycling through the steps... Will do seperate HSERVO call for each pin in each step...
	  wGPSeqPtr = wGPSeqPtr + 2 ; ignore step-1 time.

      bGPStepNum = 0
      GPSM = 100		; initialize in case caller does nothing with this...
      
      GPStart = 2		; we are in the Do the steps mode.
	  lGPNextStepTime = 0				; time to start the next step
    ELSE
      GPStart = 0						; Error sequence not defined
	ENDIF

  ELSEIF GPStart=2
    IF (HSERVOTIME 5) >= lGPNextStepTime then ; time to start the next sequence.
;      hserout 1, ["GP Mode GPMS:", sdec GPSM ]

      ; See if speed multipler is positive or negative as this will change how and where we read in the next step to use
      IF GPSM = 0 THEN
          return 		; If speed is zero just bail for now.
	  ELSEIF GPSM > 0
      	bGPStepNum = bGPStepNum + 1
;        hserout 1, [" > S=", dec bGPStepNum, 13 ]
        IF bGPStepNum > bGPCntSteps THEN
  	      GPStart = 0
  	    ENDIF
  	  ELSE
  	    IF bGPStepNum > 1 THEN
	      wGPSeqPtr = wGPSeqPtr - 2*(2*bGPCntServos + 2)	; Need to back up 2 steps as we increment by 1 step later on...
	      bGPStepNum = bGPStepNum - 1
;          hserout 1, [" < S=", dec bGPStepNum, 13]
	    ELSE
  	      GPStart = 0
  	    ENDIF
      ENDIF  	      

      ; Continue now to read in the step
      IF GPStart THEN 	        
        if bGPCntServos > 15 then ;make sure we don't read more than 32 bytes...
  	      readdm wGPSeqPtr, [str awGPStepServoVals\32] ; Read in the first 16 servos
  	      readdm wGPSeqPtr+32, [str awGPStepServoVals(16)\2*bGPCntServos-32, wGPStepTime.highbyte, wGPStepTime.lowByte] ; Update to read after the first 16
        else
  	      readdm wGPSeqPtr, [str awGPStepServoVals\2*bGPCntServos, wGPStepTime.highbyte, wGPStepTime.lowByte] ; note did not change time bytes order ???
		endif
			
	    for bGPServoNum = 0 to bGPCntServos - 1
		  ; need to convert the value to HServo Value
		  swHSVal = (awGPStepServoVals(bGPServoNum)*20 - 30000) +  aServoOffsets(abGPServoPins(bGPServoNum)) ; convert to hservo and take care of offsets
		  hservo [abGPServoPins(bGPServoNum) \ swHSVal\ abs(HServoPos(abGPServoPins(bGPServoNum)) - swHSVal) * 20 / wGPStepTime]
;  		  hserout 1, [" ", dec abGPServoPins(bGPServoNum), ":", sdec swHSVal]
        next
	    ; now lets wait for the step to complete
	    ; Keep from hanging...
	    if wGPStepTime > 2000 or wGPStepTime = 0 then 
	      Sound cSpeakerPin,[60\4000,100\5000, 60\4000]	' make some noise...
	      wGPStepTime = 500
	    endif
	    wGPSeqPtr = wGPSeqPtr + 2*bGPCntServos + 2	; increment to the next sequence
	    
	    ; reduced the multiplies/divides down from clocks/32 and *100/x
	    lGPNextStepTime = (HSERVOTIME 5) + (wGPStepTime*100*625)/ABS(GPSM); Convert the MS to Clocks/32 timer values Taks speed multiply in consideration
;	    hserout 1, [" T:", dec wGPStepTime, " ", sdec GPSM, " ", dec (lGPNextStepTime - (HSERVOTIME 5)), 13]
	  ELSE
	    GPStart = 0			; We completed the sequence.
	  ENDIF
    ENDIF
  ELSEIF GPStart=0xff		; User asked to cancel the sequence, tell all of the servos to stop where they are...
    for bGPServoNum = 0 to bGPCntServos - 1
      hservo [abGPServoPins(bGPServoNum) \ HServoPos(abGPServoPins(bGPServoNum))]
    next
  							
    GPStart = 0
  ENDIF
			
return

;--------------------------------------------------------------------
;[GPSeqNumSteps] returns the number of steps a specific sequence has 
;		as defined in the variable GPSEQ has or -1 if the sequence is not defined
GPSeqNumSteps:
  readdm ARC32_SSC_OFFSET + GPSEQ*2, [str wGPSeqPtr\2]
  IF (wGPSeqPtr = 0) or (wGPSeqPtr = 0xffff)	THEN
    return -1;
  ENDIF
  
  readdm wGPSeqPtr+1,[bGPCntServos, bGPCntSteps]
  return bGPCntSteps


;-------------------------------------------------------------------
;[GPGetCurrentStep] returns the current step number of an active sequence or -1 
GPGetCurrentStep:
  IF GPStart THEN
    return bGPStepNum
  ENDIF
return -1
	
	
;--------------------------------------------------------------------
;[SERVO DRIVER] Updates the positions of the servos
;**********************************************************************
UpdateServoDriver:
  ;Update Right Legs
  ; BUGBUG : should we convert the offsets to their own table that has been pre multiplied?...
  for LegIndex = 0 to 2
    aswCoxaServo(LegIndex) = (-CoxaAngle1(LegIndex) * StepsPerDegree ) / 10  + aServoOffsets(cCoxaPin(LegIndex))	; Convert angle to HServo value
    aswFemurServo(LegIndex) = (-FemurAngle1(LegIndex) * StepsPerDegree ) / 10 + aServoOffsets(cFemurPin(LegIndex))
    aswTibiaServo(LegIndex) = (-TibiaAngle1(LegIndex) * StepsPerDegree ) / 10 + aServoOffsets(cTibiaPin(LegIndex))
#ifdef c4DOF
    aswTarsServo(LegIndex) = (-TarsAngle1(LegIndex) * StepsPerDegree ) / 10 + aServoOffsets(cTarsPin(LegIndex))
#endif    
  next
  
  ;Update Left Legs
  for LegIndex = 3 to 5
    aswCoxaServo(LegIndex) = (CoxaAngle1(LegIndex) * StepsPerDegree ) / 10 + aServoOffsets(cCoxaPin(LegIndex))
    aswFemurServo(LegIndex) = (FemurAngle1(LegIndex) * StepsPerDegree ) / 10	+ aServoOffsets(cFemurPin(LegIndex))
    aswTibiaServo(LegIndex) = (TibiaAngle1(LegIndex) * StepsPerDegree ) / 10 + aServoOffsets(cTibiaPin(LegIndex))
#ifdef c4DOF
    aswTarsServo(LegIndex) = (TarsAngle1(LegIndex) * StepsPerDegree ) / 10 + aServoOffsets(cTarsPin(LegIndex))
#endif    
  next  

  PrevSSCTime = SSCTime
return
;--------------------------------------------------------------------
;[FREE SERVOS] Frees all the servos (binary)
FreeServos
  for LegIndex = 0 to 5
	hservo [cCoxaPin(LegIndex)	\	-30000, |
			cFemurPin(LegIndex)	\	-30000, |
			cTibiaPin(LegIndex)	\	-30000]
	; This way if commit is called it will leave us not doing anything!		
    aswCoxaServo(LegIndex) = -30000
	aswFemurServo(LegIndex) = -30000
	aswTibiaServo(LegIndex) = -30000
#ifdef c4DOF
	if cTarsLength(LegIndex) then
		hservo [cTarsPin(LegIndex)	\	-30000]
		aswTarsServo(LegIndex) = -30000
	endif
#endif    
  next
  fFirstMove = 1		; May need to tell servo system again to do it without time values...
return

;--------------------------------------------------------------------
;[COMMIT SERVO POSITIONS]
CommitServoDriver:
  if fFirstMove then
  	; Catch case where Commit is called without any valid data...
	fFirstMove = 0		; Clear it...
    for LegIndex = 0 to 5
      ; first time through move imdediate as no real position to base off of...
      hservo [cCoxaPin(LegIndex)	\	aswCoxaServo(LegIndex), |
	          cFemurPin(LegIndex)	\	aswFemurServo(LegIndex), |
		      cTibiaPin(LegIndex)	\	aswTibiaServo(LegIndex)]
#ifdef c4DOF
	  if cTarsLength(LegIndex) then
		  hservo [cTarsPin(LegIndex)	\	aswTarsServo(LegIndex)]
	  endif
#endif    
    next

  else
    for LegIndex = 0 to 5
      hservo [cCoxaPin(LegIndex)	\	aswCoxaServo(LegIndex)	\	abs(HServoPos(cCoxaPin(LegIndex)) - aswCoxaServo(LegIndex)) * 20 / SSCTime, |
	          cFemurPin(LegIndex)	\	aswFemurServo(LegIndex)	\	abs(HServoPos(cFemurPin(LegIndex)) - aswFemurServo(LegIndex)) * 20 / SSCTime, |
		      cTibiaPin(LegIndex)	\	aswTibiaServo(LegIndex)	\	abs(HServoPos(cTibiaPin(LegIndex)) - aswTibiaServo(LegIndex)) * 20 / SSCTime]
#ifdef c4DOF
	  if cTarsLength(LegIndex) then
		  hservo [cTarsPin(LegIndex)	\	aswTarsServo(LegIndex) \ abs(HServoPos(cTarsPin(LegIndex)) - aswTarsServo(LegIndex)) * 20 / SSCTime]
	  endif
#endif    
    next
  endif
  return

