;[SERIAL CONNECTIONS]
cSSC_OUT        con P11     ;Output pin for (SSC32 RX) on BotBoard (Yellow)
cSSC_IN         con P10     ;Input pin for (SSC32 TX) on BotBoard (Blue)
cSSC_BAUD       con i115200	;SSC32 BAUD rate 38400 115200

;--------------------------------------------------------------------
;[GP PLAYER]
; from core
GPStart		var byte	;was bit			;Start the GP Player
GPSeq		var byte		;Number of the sequence
GPVerData	var byte(3)		;Received data to check the SSC Version
GPEnable	var bit			;Enables the GP player when the SSC version ends with "GP<cr>"
GPSM		var	sword		;Speed Multiply rand +-200
szVer		var	byte(40)	; get the version string...
; From SSC
GPStatSeq       var byte
GPStatFromStep  var byte
GPStepPrev		var byte
GPStatToStep   	var byte
GPStatTime      var byte
GPSMPrev		var sword
GPSeqStart		var	word
GPCntSteps		var byte
lTimerCnt		var	long

;
  WTIMERTICSPERMSMUL con 64	; BAP28 is 16mhz need a multiplyer and divider to make the conversion with /8192
  WTIMERTICSPERMSDIV con 125  ; 
  TMA = 0	; clock / 8192					; Low resolution clock - used for timeouts...

	pause 100
	serout cSSC_OUT, cSSC_BAUD, ["ver", 13]
	serin cSSC_IN, cSSC_BAUD, [str szVer\40\13]
	serout s_out, i9600, ["SSC Ver: ", str szVer\40\13, 13]

; Quick and dirty test of GP player timings to see what different SM values does...
	low	p12			; will use this pin to toggle to show progress through the sequences.
	low p13
Main:
	serout s_out, i9600, ["Enter sequence Number: "]
	serin s_in, i9600, [dec GPSeq]
	pause 50

	serout s_out, i9600, ["Enter Speed multiply -200 to 200: "]
	serin s_in, i9600, [sdec GPSM]
	pause 50


	gosub GPSeqNumSteps		; gets the count of steps for the sequence.  Should check error state.
	IF GPCntSteps = 0xff THEN Main
	
    serout cSSC_OUT, cSSC_BAUD, ["PL0SQ", dec GPSeq,"SM", sdec GPSM, 13] ;Start sequence
	
	lTimerCnt = 0
	TCA = 0
	IRR1.bit6 = 0	; clear overflow
	GPStepPrev = 0xff
	repeat
		toggle p13
;		pause 5
 		serout cSSC_OUT, cSSC_BAUD, ["QPL0", 13]
    	serin cSSC_IN, cSSC_BAUD, [GPStatSeq, GPStatFromStep, GPStatToStep, GPStatTime]
    	if GPStepPrev <> GPStatFromStep then
    		GPStepPrev = GPStatFromStep
    		toggle p12
    	endif
    	if IRR1.Bit6 then
    		lTimerCnt = lTimerCnt + 256
    		IRR1.Bit6 = 0
    	endif
    ;The ONCE command does not work after PL0SM cmd, therefore our own function for stopping the player
    ;NB! Reuse of the GPVerData, now it contains total # of steps in current sequence
    until(GPStatFromStep = (GPCntSteps-1)) and (GPStatTime=0);Stop SQ at the last step in SQ, 
	toggle p12 ; toggle when we reached the end

	; Now lets see how much time it took
	
	do 
		if IRR1.Bit6 then
    		lTimerCnt = (lTimerCnt + 256)& 0xffffff00 + TCA
    		IRR1.Bit6 = 0
    	else
    		lTimerCnt = lTimerCnt & 0xffffff00 + TCA
		endif		
	while IRR1.Bit6
	serout cSSC_OUT, cSSC_BAUD, ["PL0", 13] ;Stop the sequence now

	serout s_out, i9600, ["Sequence took: ", dec (lTimerCnt*WTIMERTICSPERMSMUL)/WTIMERTICSPERMSDIV, 13]
	goto Main
;--------------------------------------------------------------------
;[GPSeqNumSteps] returns the number of steps a specific sequence has 
;		as defined in the variable GPSEQ has or -1 if the sequence is not defined
GPSeqNumSteps:
  pause 1
  GPCntSteps = 0xff		; assume an error

  serout cSSC_OUT, cSSC_BAUD, ["EER -", dec GPSEQ*2, ";2",13];Read adr to current seq
  serin cSSC_IN, cSSC_BAUD, 50000, _TO_GPSNS, [str GPSeqStart\2] ;read in 2 byte header - bugbug reuse a local variable
  				
  IF (GPSeqStart <> 0)  and (GPSeqStart <> 0xffff)	THEN
    serout cSSC_OUT, cSSC_BAUD, ["EER -", dec (GPSeqStart.highbyte*256+GPSeqStart.lowbyte)+2, ";1",13] 
    serin cSSC_IN, cSSC_BAUD, 50000,_TO_GPSNS, [GPCntSteps];
  ENDIF

_TO_GPSNS:		 	
return GPCntSteps  ; SSC-32 did not respond, so assume not supported...


