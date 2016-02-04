USE_IDLEPROC con 1
;Project Lynxmotion Phoenix
;Description: 3DOF Phoenix running on Arc32, configuration file.
;      All Hardware connections (excl controls) and body dimensions 
;      are configurated in this file. Can be used with V2.1 and above
;Configuration version: V1.1 alfa
;Date: April 15, 2011
;Programmers: Jeroen Janssen (aka Xan)
;			  Kåre Halvorsen (aka Zenta)
;
;Hardware setup: ABB2 with ATOM 28 Pro, SSC32 V2, (See further for connections)
;
;NEW IN V1.1
;   - Added speaker constant
;	- Added support for different leg lengths
;	- Optional 4DOF
;	- Optional Safety shut down when voltage drops
;
;--------------------------------------------------------------------
;[CONDITIONAL COMPILING] - COMMENT IF NOT WANTED
;c4DOF			 con 1	 	; Switch between 3DOF and 4DOF
;cTurnOffVol	 con 630 	; When uncomment the bot will turn off when 
							; the voltage drops below this setpoint (630 = 6.3V)


;[ARC32 PIN NUMBERS]
cEyesPin      	con P0
cSpeakerPin		con P19
cVoltagePin		con 33		; Defines the analog input to read the voltage warning other command...
PS2DAT 			con P40		;PS2 Controller DAT (Brown)
PS2CMD 			con P41		;PS2 controller CMD (Orange)
PS2SEL 			con P42		;PS2 Controller SEL (Blue)
PS2CLK 			con P43		;PS2 Controller CLK (White)



cRRCoxaPin 		con P31	;Rear Right leg Hip Horizontal
cRRFemurPin 	con P30	;Rear Right leg Hip Vertical
cRRTibiaPin 	con P29	;Rear Right leg Knee

cRMCoxaPin 		con P28	;Middle Right leg Hip Horizontal
cRMFemurPin 	con P27	;Middle Right leg Hip Vertical
cRMTibiaPin 	con P26	;Middle Right leg Knee

cRFCoxaPin 		con P25	;Front Right leg Hip Horizontal
cRFFemurPin 	con P24	;Front Right leg Hip Vertical
cRFTibiaPin 	con P23	;Front Right leg Knee

cLRCoxaPin 		con P15	;Rear Left leg Hip Horizontal
cLRFemurPin 	con P14	;Rear Left leg Hip Vertical
cLRTibiaPin 	con P13	;Rear Left leg Knee

cLMCoxaPin 		con P12	;Middle Left leg Hip Horizontal
cLMFemurPin 	con P11	;Middle Left leg Hip Vertical
cLMTibiaPin 	con P10	;Middle Left leg Knee

cLFCoxaPin 		con P9	;Front Left leg Hip Horizontal
cLFFemurPin 	con P8	;Front Left leg Hip Vertical
cLFTibiaPin 	con P4	;Front Left leg Knee

;--------------------------------------------------------------------
;[Joint offsets]
;First calibrate the servos in the 0 deg position using the SSC-32 reg offsets, then:
cXXFemurHornOffset	con 0 ;
cXXTarsHornOffset	con 0 ;

; Set up to have per leg offsets...
cRRFemurHornOffset1	con cXXFemurHornOffset
cRRTarsHornOffset1	con cXXTarsHornOffset	

cRMFemurHornOffset1	con cXXFemurHornOffset
cRMTarsHornOffset1	con cXXTarsHornOffset	

cRFFemurHornOffset1	con cXXFemurHornOffset
cRFTarsHornOffset1	con cXXTarsHornOffset	

cLRFemurHornOffset1	con cXXFemurHornOffset
cLRTarsHornOffset1	con cXXTarsHornOffset	

cLMFemurHornOffset1	con cXXFemurHornOffset
cLMTarsHornOffset1	con cXXTarsHornOffset	

cLFFemurHornOffset1	con cXXFemurHornOffset
cLFTarsHornOffset1	con cXXTarsHornOffset	


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
;[LEG DIMENSIONS]
;Universal dimensions for each leg
cXXCoxaLength  	con 29		;Length of the Coxa [mm]
cXXFemurLength 	con 76		;Length of the Femur [mm]
cXXTibiaLength 	con 104		;Lenght of the Tibia [mm]
cXXTarsLength	con 85		; 4DOF ONLY...

cRRCoxaLength   con cXXCoxaLength	;Rigth Rear leg
cRRFemurLength  con cXXFemurLength
cRRTibiaLength  con cXXTibiaLength
cRRTarsLength	con cXXTarsLength	;4DOF ONLY

cRMCoxaLength   con cXXCoxaLength	;Rigth middle leg
cRMFemurLength  con cXXFemurLength
cRMTibiaLength  con cXXTibiaLength
cRMTarsLength	con cXXTarsLength	;4DOF ONLY

cRFCoxaLength   con cXXCoxaLength	;Rigth front leg
cRFFemurLength  con cXXFemurLength
cRFTibiaLength  con cXXTibiaLength
cRFTarsLength	con cXXTarsLength	;4DOF ONLY

cLRCoxaLength   con cXXCoxaLength	;Left Rear leg
cLRFemurLength  con cXXFemurLength
cLRTibiaLength  con cXXTibiaLength
cLRTarsLength	con cXXTarsLength	;4DOF ONLY

cLMCoxaLength   con cXXCoxaLength	;Left middle leg
cLMFemurLength  con cXXFemurLength
cLMTibiaLength  con cXXTibiaLength
cLMTarsLength	con cXXTarsLength	;4DOF ONLY

cLFCoxaLength   con cXXCoxaLength	;Left front leg
cLFFemurLength  con cXXFemurLength
cLFTibiaLength  con cXXTibiaLength
cLFTarsLength	con cXXTarsLength

;--------------------------------------------------------------------
;[BODY DIMENSIONS]

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
cXXInitPosY		con 25

cRRInitPosX 	con 53		;Start positions of the Right Rear leg
cRRInitPosY 	con cXXInitPosY
cRRInitPosZ 	con 91

cRMInitPosX 	con 105		;Start positions of the Right Middle leg
cRMInitPosY 	con cXXInitPosY
cRMInitPosZ 	con 0

cRFInitPosX 	con 53		;Start positions of the Right Front leg
cRFInitPosY 	con cXXInitPosY
cRFInitPosZ 	con -91

cLRInitPosX 	con 53		;Start positions of the Left Rear leg
cLRInitPosY 	con cXXInitPosY
cLRInitPosZ 	con 91

cLMInitPosX 	con 105		;Start positions of the Left Middle leg
cLMInitPosY 	con cXXInitPosY
cLMInitPosZ 	con 0

cLFInitPosX 	con 53		;Start positions of the Left Front leg
cLFInitPosY 	con cXXInitPosY
cLFInitPosZ 	con -91
;--------------------------------------------------------------------

;==================================================================================
; BUGBUG:: section of defines for 4DOF, to simply get code to compile... If
; real 4DOF comes along need to define real values!
#ifdef c4DOF
cRRTarsPin		con P0  ;Front Right leg foot
cRMTarsPin		con P0  ;Middle Right leg foot
cRFTarsPin		con P0 ;Rear Right leg foot
cLRTarsPin		con P0 ;Front Left leg foot
cLMTarsPin		con P0	;Middle Left leg foot
cLFTarsPin		con P0 ;Rear Left leg foot

;[MIN/MAX ANGLES]
cRRTarsMin1		con -1300	  ;4DOF ONLY - In theory the kinematics can reach about -160 deg
cRRTarsMax1		con 500		  ;4DOF ONLY - The kinematics will never exceed 23 deg though..

cRMTarsMin1		con -1300	  ;4DOF ONLY
cRMTarsMax1		con 500	  	  ;4DOF ONLY
cRFTarsMin1		con -1300
cRFTarsMax1		con 500
cLRTarsMin1		con -1300	  ;4DOF ONLY
cLRTarsMax1		con 500	      ;4DOF ONLY
cLMTarsMin1		con -1300	  ;4DOF ONLY
cLMTarsMax1		con 500	      ;4DOF ONLY
cLFTarsMin1		con -1300
cLFTarsMax1		con 500

;[LEG DIMENSIONS]
;Universal dimensions for each leg
cXXTarsLength	con	85		;Lenght of the Tars [mm]
cRRTarsLength	con cXXTarsLength	;4DOF ONLY
cRMTarsLength	con cXXTarsLength	;4DOF ONLY
cRFTarsLength	con cXXTarsLength	;4DOF ONLY
cLRTarsLength	con cXXTarsLength	;4DOF ONLY
cLMTarsLength	con cXXTarsLength	;4DOF ONLY
cLFTarsLength	con cXXTarsLength	;4DOF ONLY
;[Tars factors used in formula to calc Tarsus angle relative to the ground]
cTarsConst		con	720	;4DOF ONLY
cTarsMulti		con 2	;4DOF ONLY
cTarsFactorA	con 70	;4DOF ONLY
cTarsFactorB	con 60	;4DOF ONLY
cTarsFactorC	con 50	;4DOF ONLY
;--------------------------------------------------------------------
#endif