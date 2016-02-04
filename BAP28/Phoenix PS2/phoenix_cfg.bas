;Project Lynxmotion Phoenix
;Description: Phoenix, configuration file.
;		All Hardware connections (excl controls) and body dimensions 
;		are configurated in this file. Can be used with V2.0 and above
;Configuration version: V1.0
;Date: 06-10-2009
;Programmer: Jeroen Janssen (aka Xan)
;
;Hardware setup: ABB2 with ATOM 28 Pro, SSC32 V2, (See further for connections)
;
;NEW IN V1.0
;	- First Release
;
;--------------------------------------------------------------------
;[SERIAL CONNECTIONS]
cSSC_OUT   		con P11		;Output pin for (SSC32 RX) on BotBoard (Yellow)
cSSC_IN    		con P10		;Input pin for (SSC32 TX) on BotBoard (Blue)
cSSC_BAUD 		con i38400	;SSC32 BAUD rate
;--------------------------------------------------------------------
;[BB2 PIN NUMBERS]
cEyesPin		con P8
;--------------------------------------------------------------------
;[SSC PIN NUMBERS]
cRRCoxaPin 		con P0	;Rear Right leg Hip Horizontal
cRRFemurPin 	con P1	;Rear Right leg Hip Vertical
cRRTibiaPin 	con P2	;Rear Right leg Knee

cRMCoxaPin 		con P4	;Middle Right leg Hip Horizontal
cRMFemurPin 	con P5	;Middle Right leg Hip Vertical
cRMTibiaPin 	con P6	;Middle Right leg Knee

cRFCoxaPin 		con P8	;Front Right leg Hip Horizontal
cRFFemurPin 	con P9	;Front Right leg Hip Vertical
cRFTibiaPin 	con P10	;Front Right leg Knee

cLRCoxaPin 		con P16	;Rear Left leg Hip Horizontal
cLRFemurPin 	con P17	;Rear Left leg Hip Vertical
cLRTibiaPin 	con P18	;Rear Left leg Knee

cLMCoxaPin 		con P20	;Middle Left leg Hip Horizontal
cLMFemurPin 	con P21	;Middle Left leg Hip Vertical
cLMTibiaPin 	con P22	;Middle Left leg Knee

cLFCoxaPin 		con P24	;Front Left leg Hip Horizontal
cLFFemurPin 	con P25	;Front Left leg Hip Vertical
cLFTibiaPin 	con P26	;Front Left leg Knee
;--------------------------------------------------------------------
;[MIN/MAX ANGLES]
cRRCoxaMin1		con -260	;Mechanical limits of the Right Rear Leg, decimals = 1
cRRCoxaMax1		con 740
cRRFemurMin1	con -1010
cRRFemurMax1	con 950
cRRTibiaMin1	con -1060
cRRTibiaMax1	con 770

cRMCoxaMin1		con -530	;Mechanical limits of the Right Middle Leg, decimals = 1
cRMCoxaMax1		con 530
cRMFemurMin1	con -1010
cRMFemurMax1	con 950
cRMTibiaMin1	con -1060
cRMTibiaMax1	con 770

cRFCoxaMin1		con -580	;Mechanical limits of the Right Front Leg, decimals = 1
cRFCoxaMax1		con 740
cRFFemurMin1	con -1010
cRFFemurMax1	con 950
cRFTibiaMin1	con -1060
cRFTibiaMax1	con 770

cLRCoxaMin1		con -740	;Mechanical limits of the Left Rear Leg, decimals = 1
cLRCoxaMax1		con 260
cLRFemurMin1	con -950
cLRFemurMax1	con 1010
cLRTibiaMin1	con -770
cLRTibiaMax1	con 1060

cLMCoxaMin1		con -530	;Mechanical limits of the Left Middle Leg, decimals = 1
cLMCoxaMax1		con 530
cLMFemurMin1	con -950
cLMFemurMax1	con 1010
cLMTibiaMin1	con -770
cLMTibiaMax1	con 1060

cLFCoxaMin1		con -740	;Mechanical limits of the Left Front Leg, decimals = 1
cLFCoxaMax1		con 580
cLFFemurMin1	con -950
cLFFemurMax1	con 1010
cLFTibiaMin1	con -770
cLFTibiaMax1	con 1060
;--------------------------------------------------------------------
;[BODY DIMENSIONS]
cCoxaLength  	con 29		;Length of the Coxa [mm]
cFemurLength 	con 76		;Length of the Femur [mm]
cTibiaLength 	con 106		;Lenght of the Tibia [mm]

cRRCoxaAngle1 	con -600	;Default Coxa setup angle, decimals = 1
cRMCoxaAngle1 	con 0		;Default Coxa setup angle, decimals = 1
cRFCoxaAngle1 	con 600		;Default Coxa setup angle, decimals = 1
cLRCoxaAngle1 	con -600	;Default Coxa setup angle, decimals = 1
cLMCoxaAngle1 	con 0		;Default Coxa setup angle, decimals = 1
cLFCoxaAngle1 	con 600		;Default Coxa setup angle, decimals = 1

cRROffsetX 		con -43		;Distance X from center of the body to the Right Rear coxa
cRROffsetZ 		con 82		;Distance Z from center of the body to the Right Rear coxa
cRMOffsetX 		con -63		;Distance X from center of the body to the Right Middle coxa
cRMOffsetZ 		con 0		;Distance Z from center of the body to the Right Middle coxa
cRFOffsetX 		con -43		;Distance X from center of the body to the Right Front coxa
cRFOffsetZ 		con -82		;Distance Z from center of the body to the Right Front coxa

cLROffsetX 		con 43		;Distance X from center of the body to the Left Rear coxa
cLROffsetZ 		con 82		;Distance Z from center of the body to the Left Rear coxa
cLMOffsetX 		con 63		;Distance X from center of the body to the Left Middle coxa
cLMOffsetZ 		con 0		;Distance Z from center of the body to the Left Middle coxa
cLFOffsetX 		con 43		;Distance X from center of the body to the Left Front coxa
cLFOffsetZ 		con -82		;Distance Z from center of the body to the Left Front coxa
;--------------------------------------------------------------------
;[START POSITIONS FEET]
cRRInitPosX 	con 53		;Start positions of the Right Rear leg
cRRInitPosY 	con 25
cRRInitPosZ 	con 91

cRMInitPosX 	con 105		;Start positions of the Right Middle leg
cRMInitPosY 	con 25
cRMInitPosZ 	con 0

cRFInitPosX 	con 53		;Start positions of the Right Front leg
cRFInitPosY 	con 25
cRFInitPosZ 	con -91

cLRInitPosX 	con 53		;Start positions of the Left Rear leg
cLRInitPosY 	con 25
cLRInitPosZ 	con 91

cLMInitPosX 	con 105		;Start positions of the Left Middle leg
cLMInitPosY 	con 25
cLMInitPosZ 	con 0

cLFInitPosX 	con 53		;Start positions of the Left Front leg
cLFInitPosY 	con 25
cLFInitPosZ 	con -91
;--------------------------------------------------------------------