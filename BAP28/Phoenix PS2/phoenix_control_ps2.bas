;Project Lynxmotion Phoenix
;Description: Phoenix, control file.
;		The control input subroutine for the phoenix software is placed in this file.
;		Can be used with V2.0 and above
;Configuration version: V1.0
;Date: 25-10-2009
;Programmer: Jeroen Janssen (aka Xan)
;
;Hardware setup: PS2 version
;
;NEW IN V1.0
;	- First Release
;
;	Walk method 1:
;	- Left Stick	Walk/Strafe
;	- Right Stick	Rotate
;
;	Walk method 2:
;	- Left Stick	Disable
;	- Right Stick	Walk/Rotate
;
;
;PS2 CONTROLS:
;	[Common Controls]
;	- Start			Turn on/off the bot
;	- L1			Toggle Shift mode
;	- L2			Toggle Rotate mode
;	- Circle		Toggle Single leg mode
;   - Square        Toggle Balance mode
;	- Triangle		Move body to 35 mm from the ground (walk pos) 
;					and back to the ground
;	- D-Pad up		Body up 10 mm
;	- D-Pad down	Body down 10 mm
;	- D-Pad left	decrease speed with 50mS
;	- D-Pad right	increase speed with 50mS
;
;	[Walk Controls]
;	- select		Switch gaits
;	- Left Stick	(Walk mode 1) Walk/Strafe
;				 	(Walk mode 2) Disable
;	- Right Stick	(Walk mode 1) Rotate, 		
;					(Walk mode 2) Walk/Rotate
;	- R1			Toggle Double gait travel speed
;	- R2			Toggle Double gait travel length
;
;	[Shift Controls]
;	- Left Stick	Shift body X/Z
;	- Right Stick	Shift body Y and rotate body Y
;
;	[Rotate Controls]
;	- Left Stick	Rotate body X/Z
;	- Right Stick	Rotate body Y	
;
;	[Single leg Controls]
;	- select		Switch legs
;	- Left Stick	Move Leg X/Z (relative)
;	- Right Stick	Move Leg Y (absolute)
;	- R2			Hold/release leg position
;
;	[GP Player Controls]
;	- select		Switch Sequences
;	- R2			Start Sequence
;
;====================================================================
;[CONSTANTS]
WalkMode			con 0
TranslateMode		con 1
RotateMode			con 2
SingleLegMode		con 3
GPPlayerMode		con 4
;--------------------------------------------------------------------
;[PS2 Controller Constants]
PS2DAT 				con P12		;PS2 Controller DAT (Brown)
PS2CMD 				con P13		;PS2 controller CMD (Orange)
PS2SEL 				con P14		;PS2 Controller SEL (Blue)
PS2CLK 				con P15		;PS2 Controller CLK (White)
PadMode 			con $79
;--------------------------------------------------------------------
;[Ps2 Controller Variables]
DualShock 			var Byte(7)
LastButton 			var Byte(2)
DS2Mode 			var Byte
PS2Index			var byte
BodyYOffset 		var sword
BodyYShift			var sbyte
ControlMode			var nib
DoubleHeightOn		var bit
DoubleTravelOn		var bit
WalkMethod			var bit
;--------------------------------------------------------------------
;[InitController] Initialize the PS2 controller
InitController:
  high PS2CLK
  LastButton(0) = 255
  LastButton(1) = 255
  BodyYOffset = 0
  BodyYShift = 0

  low PS2SEL
  shiftout PS2CMD,PS2CLK,FASTLSBPRE,[$1\8]
  shiftin PS2DAT,PS2CLK,FASTLSBPOST,[DS2Mode\8]
  high PS2SEL
  pause 1
  
  if DS2Mode <> PadMode THEN
	low PS2SEL
	shiftout PS2CMD,PS2CLK,FASTLSBPRE,[$1\8,$43\8,$0\8,$1\8,$0\8] ;CONFIG_MODE_ENTER
	high PS2SEL
	pause 1

	low PS2SEL
	shiftout PS2CMD,PS2CLK,FASTLSBPRE,[$01\8,$44\8,$00\8,$01\8,$03\8,$00\8,$00\8,$00\8,$00\8] ;SET_MODE_AND_LOCK
	high PS2SEL
	pause 1

	low PS2SEL
	shiftout PS2CMD,PS2CLK,FASTLSBPRE,[$01\8,$4F\8,$00\8,$FF\8,$FF\8,$03\8,$00\8,$00\8,$00\8] ;SET_DS2_NATIVE_MODE
	high PS2SEL
	pause 1

	low PS2SEL
	shiftout PS2CMD,PS2CLK,FASTLSBPRE,[$01\8,$43\8,$00\8,$00\8,$5A\8,$5A\8,$5A\8,$5A\8,$5A\8] ;CONFIG_MODE_EXIT_DS2_NATIVE
	high PS2SEL
	pause 1

	low PS2SEL
	shiftout PS2CMD,PS2CLK,FASTLSBPRE,[$01\8,$43\8,$00\8,$00\8,$00\8,$00\8,$00\8,$00\8,$00\8] ;CONFIG_MODE_EXIT
	high PS2SEL
	pause 100
		
	sound P9,[100\4000, 100\4500, 100\5000]
	
	goto InitController ;Check if the remote is initialized correctly
  ENDIF
return
;--------------------------------------------------------------------
;[ControlInput] reads the input data from the PS2 controller and processes the
;data to the parameters.
ControlInput:
	
  low PS2SEL
  shiftout PS2CMD,PS2CLK,FASTLSBPRE,[$1\8,$42\8]	
  shiftin PS2DAT,PS2CLK,FASTLSBPOST,[DualShock(0)\8, DualShock(1)\8, DualShock(2)\8, DualShock(3)\8, |
  	DualShock(4)\8, DualShock(5)\8, DualShock(6)\8]
  high PS2SEL
  pause 10	
  
  ; Switch bot on/off
  IF (DualShock(1).bit3 = 0) and LastButton(0).bit3 THEN	;Start Button test
	IF(HexOn) THEN
	  'Turn off
	  BodyPosX = 0
	  BodyPosY = 0
	  BodyPosZ = 0
	  BodyRotX = 0
	  BodyRotY = 0
	  BodyRotZ = 0
	  TravelLengthX = 0
	  TravelLengthZ = 0
	  TravelRotationY = 0
	  BodyYOffset = 0
	  BodyYShift = 0
	  SelectedLeg = 255

	  HexOn = 0
	ELSE
	  'Turn on
	  HexOn = 1	
	ENDIF
  ENDIF	

  IF HexOn THEN
;[SWITCH MODES]
    
    ;Translate mode
	IF (DualShock(2).bit2 = 0) and LastButton(1).bit2 THEN	;L1 Button test
	  sound p9, [50\4000]
	  IF ControlMode <> TranslateMode THEN
	    ControlMode = TranslateMode
	  ELSE
	    IF (SelectedLeg=255) THEN
	      ControlMode = WalkMode
	    ELSE
	      ControlMode = SingleLegMode
	    ENDIF
	  ENDIF
	ENDIF  
  
    ;Rotate mode
  	IF (DualShock(2).bit0 = 0) and LastButton(1).bit0 THEN	;L2 Button test
	  sound p9, [50\4000]
	  IF ControlMode <> RotateMode THEN
	    ControlMode = RotateMode
	  ELSE
	    IF (SelectedLeg=255) THEN
	      ControlMode = WalkMode
	    ELSE
	      ControlMode = SingleLegMode
	    ENDIF
	  ENDIF
	ENDIF
  
    ;Single leg mode
  	IF (DualShock(2).bit5 = 0) and LastButton(1).bit5 THEN	;Circle Button test
	  IF ABS(TravelLengthX)<cTravelDeadZone AND ABS(TravelLengthZ)<cTravelDeadZone AND ABS(TravelRotationY*2)<cTravelDeadZone THEN
	    Sound P9,[50\4000]
	    IF (ControlMode <> SingleLegMode) THEN
	      ControlMode = SingleLegMode
	      IF (SelectedLeg = 255) THEN ;Select leg if none is selected
	        SelectedLeg=cRF ;Startleg
	      ENDIF
	    ELSE
	      ControlMode = WalkMode
	      SelectedLeg=255	      
	    ENDIF
	  ENDIF
	ENDIF

	;GP Player mode
	IF (DualShock(2).bit6 = 0) and LastButton(1).bit6 THEN	;Cross Button test
	  Sound P9,[50\4000]
	  IF ControlMode <> GPPlayerMode THEN
	    ControlMode = GPPlayerMode
	    GPSeq=0
	  ELSE
	    ControlMode = WalkMode
	  ENDIF
	ENDIF
  
;[Common functions]
	;Switch Balance mode on/off
	IF (DualShock(2).bit7 = 0) and LastButton(1).bit7 THEN	;Square Button test
	  BalanceMode = BalanceMode^1
	  IF BalanceMode THEN
		sound P9,[250\3000]	  
	  ELSE	  
		sound P9,[100\4000, 50\8000]
	  ENDIF
	ENDIF

	;Stand up, sit down
	IF (DualShock(2).bit4 = 0) and LastButton(1).bit4 THEN	;Triangle Button test
	  IF (BodyYOffset>0) THEN
	    BodyYOffset = 0
	  ELSE
	    BodyYOffset = 35
	  ENDIF
	ENDIF

	IF (DualShock(1).bit4 = 0) and LastButton(0).bit4 THEN	;D-Up Button test
	  BodyYOffset = BodyYOffset+10
	ENDIF
		
	IF (DualShock(1).bit6 = 0) and LastButton(0).bit6 THEN	;D-Down Button test
	  BodyYOffset = BodyYOffset-10	
	ENDIF
	
	IF (DualShock(1).bit5 = 0) and LastButton(0).bit5 THEN	;D-Right Button test
	  IF SpeedControl>0 THEN
	    SpeedControl = SpeedControl - 50
	    sound p9, [50\4000]
	  ENDIF
	ENDIF	
	
	IF (DualShock(1).bit7 = 0) and LastButton(0).bit7 THEN	;D-Left Button test
	  IF SpeedControl<2000 THEN
	    SpeedControl = SpeedControl + 50
	    sound p9, [50\4000]	  
	  ENDIF
	ENDIF

;[Walk functions]
	IF (ControlMode=WALKMODE) THEN
	
	  ;Switch gates
	  IF (DualShock(1).bit0 = 0) and LastButton(0).bit0 | 	;Select Button test 
			AND ABS(TravelLengthX)<cTravelDeadZone |		;No movement
			AND ABS(TravelLengthZ)<cTravelDeadZone |
			AND ABS(TravelRotationY*2)<cTravelDeadZone THEN
  		IF GaitType<7 THEN
		  Sound P9,[50\4000]
		  GaitType = GaitType+1
  	  	ELSE
		  Sound P9,[50\4000, 50\4500]
		  GaitType = 0
 	  	ENDIF
	  	GOSUB GaitSelect					
	  ENDIF
	  	
	  ;Double leg lift height		
	  IF (DualShock(2).bit3 = 0) and LastButton(1).bit3 THEN	;R1 Button test
	    sound p9, [50\4000]
	    DoubleHeightOn = DoubleHeightOn^1
	    IF DoubleHeightOn THEN
	      LegLiftHeight = 80	  
	    ELSE	  	  
	  	  LegLiftHeight = 50
	    ENDIF
	  ENDIF
	  	
	  ;Double Travel Length
	  IF (DualShock(2).bit1 = 0) and LastButton(1).bit1 THEN	;R2 Button test
	    sound p9, [50\4000]
	    DoubleTravelOn = DoubleTravelOn^1
	  ENDIF
	  
	  ; Switch between Walk method 1 and Walk method 2
	  IF (DualShock(1).bit2 = 0) and LastButton(0).bit2 THEN	;R3 Button test
	    sound p9, [50\4000]
	    WalkMethod = WalkMethod^1	  
	  ENDIF
	  	
	  ;Walking	
	  IF WalkMethod THEN ;(Walk Methode)
	    TravelLengthZ = (Dualshock(4) - 128) ;Right Stick Up/Down	  
	  ELSE	  
		TravelLengthX = -(Dualshock(5) - 128)
		TravelLengthZ = (Dualshock(6) - 128)
	  ENDIF
	  
	  IF DoubleTravelOn=0 THEN ;(Double travel length)
	    TravelLengthX = TravelLengthX/2
	    TravelLengthZ = TravelLengthZ/2
	  ENDIF
		
	  TravelRotationY = -(Dualshock(3) - 128)/4 ;Right Stick Left/Right  
	ENDIF
	
;[Translate functions]	
	;BodyYShift = 0	
	IF (ControlMode=TRANSLATEMODE) THEN	
	  BodyPosX = (Dualshock(5) - 128)/2
	  BodyPosZ = -(Dualshock(6) - 128)/3
	  BodyRotY = (Dualshock(3) - 128)/6
	  BodyYShift = (-(Dualshock(4) - 128)/2)
	ENDIF
	
;[Rotate functions]	
	IF (ControlMode=ROTATEMODE) THEN
	  BodyRotX = (Dualshock(6) - 128)/8
	  BodyRotY = (Dualshock(3) - 128)/6
	  BodyRotZ = (Dualshock(5) - 128)/8
	  BodyYShift = (-(Dualshock(4) - 128)/2)
	ENDIF	
	
;[Single leg functions]	
	IF (ControlMode=SINGLELEGMODE) THEN
	
	  ;Switch leg for single leg control
	  IF (DualShock(1).bit0 = 0) and LastButton(0).bit0 THEN	;Select Button test 
	    Sound P9,[50\4000]
	    IF SelectedLeg<5 THEN
	      SelectedLeg = SelectedLeg+1
	    ELSE
	      SelectedLeg=0
	    ENDIF
	  ENDIF
	
	  ;Single Leg Mode
	  IF (ControlMode = SingleLegMode) THEN 
	    SLLegX	= (Dualshock(5) - 128)/2 ;Left Stick Right/Left
	    SLLegY	= (Dualshock(4) - 128)/10 ;Right Stick Up/Down
	    SLLegZ 	= (Dualshock(6) - 128)/2 ;Left Stick Up/Down
	  ENDIF	
	
	  ; Hold single leg in place
	  IF (DualShock(2).bit1 = 0) and LastButton(1).bit1 THEN	;R2 Button test
	    sound p9, [50\4000]
	    SLHold = SLHold^1
	  ENDIF	  
  	ENDIF
  	
  	;[Single leg functions]	
	IF (ControlMode=GPPLAYERMODE) THEN
	
	  ;Switch between sequences
	  IF (DualShock(1).bit0 = 0) and LastButton(0).bit0 THEN	;Select Button test
	    IF GPStart=0 THEN
	      IF GPSeq < 5 THEN ;Max sequence
	        sound p9, [50\3000]	    
	        GPSeq = GPSeq+1
	      ELSE
	        Sound P9,[50\4000, 50\4500]
	        GPSeq=0
	      ENDIF
	    ENDIF
	  ENDIF
	  
	  ;Start Sequence
	  IF (DualShock(2).bit1 = 0) and LastButton(1).bit1 THEN	;R2 Button test	  
	    GPStart=1
	  ENDIF
	ENDIF
	
	;Calculate walking time delay
	InputTimeDelay = 128 - (ABS((Dualshock(5) - 128)) MIN ABS((Dualshock(6) - 128))) MIN ABS((Dualshock(3) - 128))
	
  ENDIF
  
  ;Calculate BodyPosY
  BodyPosY = (BodyYOffset + BodyYShift)MIN 0
  
  ;Store previous state
  LastButton(0) = DualShock(1)
  LastButton(1) = DualShock(2)
return	
;--------------------------------------------------------------------