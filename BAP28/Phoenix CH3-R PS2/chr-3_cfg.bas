;Project Lynxmotion Phoenix
;Description: chr-3, configuration file.
;      All Hardware connections (excl controls) and body dimensions 
;      are configurated in this file. Can be used with V2.0 and above
;Configuration version: V1.0
;Date: Nov 1, 2009
;Programmer: Kurt (aka KurtE)
;
;Hardware setup: ABB2 with ATOM 28 Pro, SSC32 V2, (See further for connections)
;
;NEW IN V1.0
;   - First Release
;
;--------------------------------------------------------------------
;[SERIAL CONNECTIONS]
cSSC_OUT         con P11      ;Output pin for (SSC32 RX) on BotBoard (Yellow)
cSSC_IN          con P10      ;Input pin for (SSC32 TX) on BotBoard (Blue)
cSSC_BAUD       con i38400   ;SSC32 BAUD rate
;--------------------------------------------------------------------
;[BB2 PIN NUMBERS]
cEyesPin      con P8
;--------------------------------------------------------------------
;[SSC PIN NUMBERS]
cRRCoxaPin       con P0   ;Rear Right leg Hip Horizontal
cRRFemurPin    con P1   ;Rear Right leg Hip Vertical
cRRTibiaPin    con P2   ;Rear Right leg Knee

cRMCoxaPin       con P4   ;Middle Right leg Hip Horizontal
cRMFemurPin    con P5   ;Middle Right leg Hip Vertical
cRMTibiaPin    con P6   ;Middle Right leg Knee

cRFCoxaPin       con P8   ;Front Right leg Hip Horizontal
cRFFemurPin    con P9   ;Front Right leg Hip Vertical
cRFTibiaPin    con P10   ;Front Right leg Knee

cLRCoxaPin       con P16   ;Rear Left leg Hip Horizontal
cLRFemurPin    con P17   ;Rear Left leg Hip Vertical
cLRTibiaPin    con P18   ;Rear Left leg Knee

cLMCoxaPin       con P20   ;Middle Left leg Hip Horizontal
cLMFemurPin    con P21   ;Middle Left leg Hip Vertical
cLMTibiaPin    con P22   ;Middle Left leg Knee

cLFCoxaPin       con P24   ;Front Left leg Hip Horizontal
cLFFemurPin    con P25   ;Front Left leg Hip Vertical
cLFTibiaPin    con P26   ;Front Left leg Knee
;--------------------------------------------------------------------
;[MIN/MAX ANGLES]
cRRCoxaMin1      con -750      ;Mechanical limits of the Right Rear Leg
cRRCoxaMax1      con 750
cRRFemurMin1   con -900
cRRFemurMax1   con 550
cRRTibiaMin1   con -400
cRRTibiaMax1   con 750

cRMCoxaMin1      con -750      ;Mechanical limits of the Right Middle Leg
cRMCoxaMax1      con 750
cRMFemurMin1   con -900
cRMFemurMax1   con 550
cRMTibiaMin1   con -400
cRMTibiaMax1   con 750

cRFCoxaMin1      con -750      ;Mechanical limits of the Right Front Leg
cRFCoxaMax1      con 750
cRFFemurMin1   con -900
cRFFemurMax1   con 550
cRFTibiaMin1   con -400
cRFTibiaMax1   con 750

cLRCoxaMin1      con -750      ;Mechanical limits of the Left Rear Leg
cLRCoxaMax1      con 750
cLRFemurMin1   con -900
cLRFemurMax1   con 550
cLRTibiaMin1   con -400
cLRTibiaMax1   con 750

cLMCoxaMin1      con -750      ;Mechanical limits of the Left Middle Leg
cLMCoxaMax1      con 750
cLMFemurMin1   con -900
cLMFemurMax1   con 550
cLMTibiaMin1   con -400
cLMTibiaMax1   con 750

cLFCoxaMin1      con -750      ;Mechanical limits of the Left Front Leg
cLFCoxaMax1      con 750
cLFFemurMin1   con -550
cLFFemurMax1   con 900
cLFTibiaMin1   con -750
cLFTibiaMax1   con 400
;--------------------------------------------------------------------
;[BODY DIMENSIONS]
cCoxaLength    con 29      ;1.14" = 29mm (1.14 * 25.4)
cFemurLength    con  57     ;2.25" = 57mm (2.25 * 25.4)
cTibiaLength    con  141    ;5.55" = 141mm (5.55 * 25.4)

cRRCoxaAngle1    con -600   ;Default Coxa setup angle, decimals = 1
cRMCoxaAngle1    con 0      ;Default Coxa setup angle, decimals = 1
cRFCoxaAngle1    con 600      ;Default Coxa setup angle, decimals = 1
cLRCoxaAngle1    con -600   ;Default Coxa setup angle, decimals = 1
cLMCoxaAngle1    con 0      ;Default Coxa setup angle, decimals = 1
cLFCoxaAngle1    con 600      ;Default Coxa setup angle, decimals = 1

cRROffsetX       con -69     ;Distance X from center of the body to the Right Rear coxa
cRROffsetZ       con 119     ;Distance Z from center of the body to the Right Rear coxa
cRMOffsetX       con -138    ;Distance X from center of the body to the Right Middle coxa
cRMOffsetZ       con 0       ;Distance Z from center of the body to the Right Middle coxa
cRFOffsetX       con -69     ;Distance X from center of the body to the Right Front coxa
cRFOffsetZ       con -119    ;Distance Z from center of the body to the Right Front coxa

cLROffsetX       con 69      ;Distance X from center of the body to the Left Rear coxa
cLROffsetZ       con 119     ;Distance Z from center of the body to the Left Rear coxa
cLMOffsetX       con 138     ;Distance X from center of the body to the Left Middle coxa
cLMOffsetZ       con 0       ;Distance Z from center of the body to the Left Middle coxa
cLFOffsetX       con 69      ;Distance X from center of the body to the Left Front coxa
cLFOffsetZ       con -119    ;Distance Z from center of the body to the Left Front coxa

;--------------------------------------------------------------------
;[START POSITIONS FEET]
cRRInitPosX    con 52      ;Start positions of the Right Rear leg
cRRInitPosY    con 80
cRRInitPosZ    con 91

cRMInitPosX    con 105      ;Start positions of the Right Middle leg
cRMInitPosY    con 80
cRMInitPosZ    con 0

cRFInitPosX    con 52      ;Start positions of the Right Front leg
cRFInitPosY    con 80
cRFInitPosZ    con -91

cLRInitPosX    con 52      ;Start positions of the Left Rear leg
cLRInitPosY    con 80
cLRInitPosZ    con 91

cLMInitPosX    con 105      ;Start positions of the Left Middle leg
cLMInitPosY    con 80
cLMInitPosZ    con 0

cLFInitPosX    con 52      ;Start positions of the Left Front leg
cLFInitPosY    con 80
cLFInitPosZ    con -91
;--------------------------------------------------------------------