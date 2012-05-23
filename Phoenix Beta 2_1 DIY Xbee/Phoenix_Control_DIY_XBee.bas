;Project Lynxmotion Phoenix
;Description: Phoenix, control file.
;		The control input subroutine for the phoenix software is placed in this file.
;		Can be used with V2.1 and above
;Configuration version: V1.1
;Date: 12-04-2011
;Programmer: Jeroen Janssen (aka Xan)
;
;Hardware setup: DIY XBee version
;
;DIY CONTROLS:
;	- Left Stick	(WalkMode) Body Height / Rotate
;					(Translate Mode) Body Height / Rotate body Y	
;					(Rotate Mode) Body Height / Rotate body Y
;					(Single leg Mode) Move Tars Y	
;
;	- Right Stick	(WalkMode) Walk/Strafe
;			 		(Translate Mode) Translate body X/Z
;					(Rotate Mode) Rotate body X/Z
;					(Single leg Mode) Move Tars X/Z
;
; 	- Left Slider	Speed
;	- Right Slider	Leg Lift Height
;
;	- A				Walk Mode
;	- B				Translate Mode
;	- C				Rotate Mode
;	- D				Single Leg Mode
;	- E				Balance Mode on/off
;
;	- 0				Turn on/off the bot
;
;	- 1-8			(Walk mode) Switch gaits
;	- 1-6			(Single leg mode) Switch legs
;
;====================================================================
USEGP	con	1
;
; We are rolling our own communication protocol between multiple XBees, one in
; the receiver (this one) and one in each robot.  We may also setup a PC based
; program that we can use to monitor things...
; Packet format:
; 		Packet Header: <Packet Type><Checksum><SerialNumber><cbExtra>
;
; Packet Types:
;[Packets sent from Remote to Robot]
XBEE_TRANS_READY		con	0x01	; Transmitter is ready for requests.
	; Optional Word to use in ATDL command
XBEE_TRANS_NOTREADY		con 0x02	; Transmitter is exiting transmitting on the sent DL
	; No Extra bytes.
XBEE_TRANS_DATA			con	0x03	; Data Packet from Transmitter to Robot*
	; Packet data described below.  Will only be sent when the robot sends
	; the remote a XBEE_RECV_REQ_DATA packet and we must return sequence number
XBEE_TRANS_NEW			con	0x04	; New Data Available
	; No extra data.  Will only be sent when we are in NEW only mode
XBEE_ENTER_SSC_MODE		con	0x05	; The controller is letting robot know to enter SSC echo mode
	; while in this mode the robot will try to be a pass through to the robot. This code assumes
	; cSSC_IN/cSSC_OUT.  The robot should probalby send a XBEE_SSC_MODE_EXITED when it decides
	; to leave this mode...	
	; When packet is received, fPacketEnterSSCMode will be set to TRUE.  Handlers should probalby
	; get robot to a good state and then call XBeeHandleSSCMode, which will return when some exit
	; condition is reached.  Start of with $$<CR> command as to signal exit
XBEE_REQ_SN_NI			con 0x06	; Request the serial number and NI string

XBEE_TRANS_CHANGED_DATA con                0x07   ; We transmite a bit mask with which fields changed plus the bytes that changes

XBEE_TRANS_NOTHIN_CHANGED con                0x08  ; 
XBEE_TRANS_DATA_VERSION con                  0x09  ; What format of data this transmitter supports. 
                                                   ;  1- New format supports changed data packets...


;[Packets sent from Robot to remote]
XBEE_RECV_REQ_DATA		con	0x80	; Request Data Packet*
	; No extra bytes, but we do pass a serial number that we expect back 
	; from Remote in the XBEE_TRANS_DATA_PACKET
XBEE_RECV_REQ_NEW		con	0x81	; Asking us to send a XBEE_TRANS_NEW message when data changes
XBEE_RECV_REQ_NEW_OFF	con	0x82	; Turn off that feature...

XBEE_RECV_NEW_THRESH	con 0x83	; Set new Data thresholds
	; currently not implemented
XBEE_RECV_DISP_VAL		con	0x84	; Display a value on line 2
	; Will send 4 bytes extra data for value.
XBEE_RECV_DISP_STR		con	0x85	; Display a String on line 2
	; If <cbExtra> is  0 then we will display the number contained in <SerialNumber> 
	; If not zero, then it is a count of bytes in a string to display.
XBEE_PLAY_SOUND			con	0x86	; Will make sounds on the remote...
	;	<cbExtra> - 2 bytes per sound: Duration <0-255>, Sound: <Freq/25> to make fit in byte...
XBEE_SSC_MODE_EXITED	con	0x87	; a message sent back to the controller when
	; it has left SSC-mode.
XBEE_SEND_SN_NI_DATA	con 0x88	; Response for REQ_SN_NI - will return
	; 4 bytes - SNH
	; 4 bytes - SNL
	; up to 20 bytes(probably 14) for NI
XBEE_RECV_REQ_DATA2		con 0x90    ; New format... 

;[XBEE_TRANS_DATA] - has XBEEPACKETSIZE extra bytes
;	0 - Buttons High
;	1 - Buttons Low
; 	2 - Right Joystick L/R
;	3 - Right Joystick U/D
;	4 - Left Joystick L/R
;	5 - Left Joystick U/D
; 	6 - Right Slider
;	7 - Left Slider
;	8 - Right Potmeter
;	9 - Left Potmeter


PKT_BTNLOW		con 0				; Low Buttons 0-7
PKT_BTNHI		con	1				; High buttons 8-F
PKT_RJOYLR		con	2				; Right Joystick Up/Down
PKT_RJOYUD		con	3				; Right joystick left/Right
PKT_LJOYLR		con	4				; Left joystick Left/Right
PKT_LJOYUD		con	5				; Left joystick Up/Down
PKT_RSLIDER		con	6				; right slider
PKT_LSLIDER		con	7				; Left slider
PKT_RPOT		con 8				; Zenta added - Right potmeter
PKT_LPOT		con 9				; Zenta added - Left potmeter
PKT_MSLIDER		con 10				; Optional Middle Slider
PKT_EXTRABTNS	con 11				; Optional Extra buttons. 

XBEEMINPACKETSIZE 	con 8			; 
XBEEMAXPACKETSIZE	con 12			; define the size of my standard pacekt.


XBEE_API_PH_SIZE	con	1		; Now just send the packet type...

#ifndef cSpeakerPin
cSpeakerPin				con p9
#endif

#ifdef BASICATOMPRO28
HSP_XBEE	con	 1
#else
HSP_DEBUG	con	 1
HSP_XBEE	con	 2
#endif

g_fAllowInput		var byte

;==============================================================================
; [Public Variables] that may be used outside of the helper file 
; Will also describe helper functions that are provided that use
; or return these values.
;==============================================================================

;------------------------------------------------------------------------------
; [InitXbee] - Intializes the XBee - This function assumes that
; 	gosub InitXBee
; 	cXBEE_OUT - is the output pin for the Xbee
; 	cXBEE_IN  - Is the input pin
;	cXBEE_RTS - is the flow control pin.  If using sparkfun regulated explorer
;			be careful that this is P6 or P7 as for lower voltage.
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; [ReceiveXbeePacket] - Main workhorse, it does all of the work to ask for new
;				data if appropriate or returns last packet if in new mode.  it
;				will also handle several other packets.  If in new only packet mode
;				and we have not received a packet in awhile, we may deside to force
;				asking for a packet.  If so fPacketForced will be true.  If forced
;				and not valid then maybe something is wrong on the other side so probably
;				go into a safe mode.  If Forced we may want to check to see if our new
;				data matches our old data. If not we may want to retell the Remote that we
;				want new packet only mode.
;	
;				Note: we wont ask for data from the remote until we have received a Transmit ready
;				packet.  This is what fTransReadyRecvd variable is for.
;	gosub ReceiveXbeePacket
;
; On return if fPacketValid is true then the array bPacket Contains valid data.  Other
; flags are described below
;------------------------------------------------------------------------------
bPacket				var	byte(XBEEMAXPACKETSIZE)		; This is the packet of data we will send to the robot.
cbPacket			var byte		; The actual packet size...

fPacketValid		var	bit			; Is the data valid
fPacketForced		var	bit			; did we force a packet
fPacketTimeout		var	bit			; Did a timeout happen
fSendOnlyNewMode	var	bit			; Are we in the mode that we will only receive data when it is new?
fPacketEnterSSCMode	var	bit			; Did we receive packet to enter SSC mode?
fTransReadyRecvd	var	bit			; Are we waiting for transmit ready?

CPACKETTIMEOUTMAX	con	100			; Need to define per program as our loops may take long or short...
cPacketTimeouts		var	word		; See how many timeouts we get...


;==============================================================================
; XBEE standard strings to save memory - by Sharin
;==============================================================================
_XBEE_PPP_STR	bytetable	"+++"		; 3 bytes long
_XBEE_ATCN_STR	bytetable	"ATCN",13	; 5 byte

;------------------------------------------------------------------------------
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
; Variables from XBEE_TASERIAL_SUPPORT
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

;--------------------------------------------------------------------
;[DIY XBee Controller Variables]
_bPacketNum			var	byte		; A packet number...

APIPACKETMAXSIZE	con	32

_bTemp				var	byte(20)	; for reading in different strings...
_bAPIPacket			var	byte(APIPACKETMAXSIZE+1)	; Used to sending and receiving packets using API mode
_bAPISeqNum			var	byte		; We use as a sequence number to verify which packet we are receiving...
_wTransmitterDL		var	word		; this is the current DL we pass to apis...
_wAPIPacketLen		var	word		; Api Packet length...
_bAPIRecvRet		var	byte		; return value from API recv packet
_bTransDataVersion	var	byte		; What version of data is being sent...

_b					var	byte
_bAPI_i				var	byte		; 
_bChkSumIn			var	byte
_lCurrentTimeT		var	long		; 
_lTimerLastPacket	var	long		; the timer value when we received the last packet
_lTimerLastRequest	var	long		; what was the timer when we last requested data?
_lTimeDiffMS		var long		; calculated time difference

_fNewPacketAvail	var	bit			; Is there a new packet available?
_fPacketValidPrev	var	bit			; The previous valid...
_fReqDataPacketSent	var	bit			; has a request been sent since we last received one?
_fReqDataForced		var	bit			; Was our request forced by a timeout?
_tas_i				var	byte
_tas_b				var	byte		; 
_cbRead				var	byte		; how many bytes did we read?

wNewDL				var	word

CXBEE_BAUD				con H62500				; Non-standard baud rate for xbee but...

; Also define some timeouts.  Allow users to override
CXBEEPACKETTIMEOUTMS con 500					; how long to wait for packet after we send request
CXBEEFORCEREQMS		con	1000					; if nothing in 1 second force a request...
CXBEETIMEOUTRECVMS	con	2000					; 2 seconds if we receive nothing

;==============================================================================
; If XBEE is on HSERIAL, then define some more stuff...
;==============================================================================
ENABLEHSERIAL2
bHSerinHasData			var	byte		; 

;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$



;--------------------------------------------------------------------
;[CONSTANTS]
WalkMode		con 0
TranslateMode	con 1
RotateMode		con 2
SingleLegMode	con 3
#IFDEF USEGP
GPPlayerMode	con 4
#ELSE
GPPlayerMode	con 40 ;For avoiding any conflict with Balance mode when GP is not in use
#ENDIF
;--------------------------------------------------------------------

;[DIY XBee Controller Variables]
abButtonsPrev 		var Byte(2)		; The state of the buttons in previous packet
iNumButton			var	byte		; which button is pressed. Only used in a few places.
fGPSequenceRun		var	bit			; Was a sequence started?
fGPSpeedControl		var	bit		; Are we in speed control mode?

bCGPSStep			var	byte		; What is Our current step
bCGPSStepPrev		var	byte		; what was the previous step

fPacketChanged		var bit			; Something change in the packet
bPacketPrev			var	byte(XBEEMAXPACKETSIZE)

i					var	byte
b					var	byte		; 
pT					var	pointer		; temporary pointer

CtrlMoveInp			var sword		; Input for smooth control movement (ex joystick, pot value), using sword for beeing on the safe side
CtrlMoveOut			var sword		; 
CtrlDivider			var nib			;

LjoyUDFunction		var nib			; For setting different options/functions in RotateMode
LockFunction		var bit			; If True the actual function are freezed
FunctionIsChanged	var bit 		; Update the DIY remote with new text when this variable are True
LeftJoyUDmode		var bit
LeftJoyLRmode		var bit



; Feedback messages - First byte is the count
_PhoenixDebug		bytetable	19, "Starting Phoenix..."
_WALKMODE			bytetable	7,  "Walking"
_TANSLATEMODE		bytetable	14, "Body Translate"
_ROTATEMODE			bytetable	11, "Body Rotate"
_SINGLELEG			bytetable	10, "Single Leg"
_BALANCEON			bytetable	10, "Balance On"
_BALANCEOFF			bytetable	11, "Balance Off"
#IFDEF USEGP
_GPSEQMODE			bytetable	12, "Run Sequence"
_GPSEQSTART			bytetable	14, "Start Sequence"
_GPSEQCOMPLETE		bytetable	 9, "Completed"
_GPSEQDISABLED		bytetable	12, "Seq Disabled"
_GPSEQNOTDEF		bytetable	15, "Seq Not defined"
#ENDIF
_LJOYUDwalk			bytetable	11, "LJOYUD walk"
_LJOYUDtrans		bytetable	12, "LJOYUD trans"
_LJOYLRtrans		bytetable	12, "LJOYLR trans"
_LJOYLRrotate		bytetable	13, "LJOYLR rotate"
_SetRotOffset		bytetable	12, "SetRotOffset"
_LockON				bytetable	 7, "Lock ON"
_LockOFF			bytetable	 8, "Lock OFF"


; Feedback - Gait names *** Warning: make sure counts match as I hop through the strings"
_GATENAMES			bytetable	9, 	"Ripple 12",|
								8, 	"Tripod 8",|
								9, 	"Triple 12",|
								9, 	"Triple 16",|
								7, 	"Wave 24"
; Other strings...
_EER_SSC1			bytetable	"EER -" ; 5 characters
_EER_SSC2			bytetable	";2",13 ; 3

; Define a sound to send back...
_GPSNDERR			bytetable 100, 5000/25,80, 4000/25] ' play it a little different...

;
; Each of the packets will be defined throughout this file...
;
bXBeeControlMode			var byte
;--------------------------------------------------------------------
InitController:
	
	fSendOnlyNewMode = 0
	gosub InitXBee
   
 	bXBeeControlMode = WalkMode
	fGPSequenceRun = 0		; make sure it is init...
	g_fAllowInput = 1
 	
return

;==============================================================================
; [ControlAllowInput] - Are we allowing input?
;==============================================================================
_fCAI var byte
ControlAllowInput[_fCAI]:
#ifdef cXBEE_RTS   
      gosub XbeeRTSAllowInput[_fCAI]
#endif
   g_fAllowInput = _fCAI
   return

;==============================================================================
; [ControlXBeeInput] - if both controllers
; [ControlInput] - This function will try to receive a packet of information
; 		from the remote control over XBee.
;
; the data in a standard packet is arranged in the following byte order:
;	0 - Buttons High
;	1 - Buttons Low
; 	2 - Right Joystick L/R
;	3 - Right Joystick U/D
;	4 - Left Joystick L/R
;	5 - Left Joystick U/D
; 	6 - Right Slider
;	7 - Left Slider
;   Added with Zentas remote with
;	8 - Right Potmeter
;	9 - Left Potmeter
;   Added with Kurts Arduino
;   10 - Middle Slider
;   11 - Extra Buttons. 
;==============================================================================
ControlInput:
#IFDEF USEGP
	; Not sure the best place to test this, but if we ran a sequence and now
	; it says it is not running, let the user know this.
	if fGPSequenceRun and (GPStart = 0) then
		fGPSequenceRun = 0		; clear out the data...
		gosub XBeeOutputString[@_GPSEQCOMPLETE]
		GOSUB XBeeResetPacketTimeout ; sets _lTimerLastPacket
	endif
#ENDIF
	; First lets try getting a packet from the XBEE
	gosub ReceiveXBeePacket
	; See if we have a valid packet to process
	if fPacketValid  then
		fPacketChanged = 0	; don't need to worry about slop 
		for i = 0 to XBEEMAXPACKETSIZE-1
			if (bPacket(i) <> bPacketPrev(i)) then
				fPacketChanged = 1
				bPacketPrev(i) = bPacket(i)
			endif
		next
		
		; OK lets try "0" button for Start. 
		IF bPacket(PKT_BTNLOW).bit0 and (abButtonsPrev(0).bit0 = 0) THEN	;Start Button (0 on keypad) test
			IF(HexOn) THEN
				'Turn off
				Sound cSpeakerPin,[100\5000,80\4500,60\4000]
				BodyPosX = 0
				BodyPosY = 0
				BodyPosZ = 0
				BodyRotX1 = 0
				BodyRotY1 = 0
				BodyRotZ1 = 0
				TravelLengthX = 0
				TravelLengthZ = 0
				TravelRotationY = 0
				
				SSCTime = 600
				HexOn = 0
			ELSE
				'Turn on
				Sound cSpeakerPin,[60\4000,80\4500,100\5000]
				SSCTime = 200
				HexOn = 1	
			ENDIF
		ENDIF	
		
		IF HexOn THEN
		  IF (GPStart=0) THEN ; Don't do this while GP is playing
			IF bPacket(PKT_BTNHI).bit2 and (abButtonsPrev(1).bit2 = 0) THEN		;A Button Walk Mode
				sound cSpeakerPin, [50\4000]
				bXBeeControlMode = WalkMode
				gosub XBeeOutputString[@_WALKMODE]
			ENDIF

			IF bPacket(PKT_BTNHI).bit3 and (abButtonsPrev(1).bit3 = 0) THEN		;B Button Translate Mode
				sound cSpeakerPin, [50\4000]
				bXBeeControlMode = TranslateMode
				gosub XBeeOutputString[@_TANSLATEMODE]
			ENDIF
      
			IF bPacket(PKT_BTNHI).bit4 and (abButtonsPrev(1).bit4 = 0) THEN		;C Button Rotate Mode
				sound cSpeakerPin, [50\4000]
				bXBeeControlMode = RotateMode
				gosub XBeeOutputString[@_ROTATEMODE]
			ENDIF
      
			IF bPacket(PKT_BTNHI).bit5 and (abButtonsPrev(1).bit5 = 0) THEN		;D Button Single Leg Mode
				sound cSpeakerPin, [50\4000]
				IF SelectedLeg=255 THEN ; none
					SelectedLeg=cRF
				ELSEIF bXBeeControlMode=SingleLegMode ;Double press to turn all legs down
					SelectedLeg=255 ; none
				ENDIF
				bXBeeControlMode=SingleLegMode        
				gosub XBeeOutputString[@_SINGLELEG]
			ENDIF

			IF bPacket(PKT_BTNHI).bit6 and (abButtonsPrev(1).bit6 = 0) THEN		; E Button Balance Mode on/of
				IF BalanceMode = 0 THEN
					BalanceMode = 1
					sound cSpeakerPin,[100\4000, 50\8000]
					gosub XBeeOutputString[@_BALANCEON]
				ELSE
					BalanceMode = 0
					sound cSpeakerPin,[250\3000]
					gosub XBeeOutputString[@_BALANCEOFF]
				ENDIF  
			ENDIF   
#IFDEF USEGP
			IF bPacket(PKT_BTNHI).bit7 and (abButtonsPrev(1).bit7 = 0) THEN		; F Button GP Player Mode Mode on/off
      			if GPEnable THEN ;F Button GP Player Mode Mode on/off -- SSC supports this mode
					gosub XBeeOutputString[@_GPSEQMODE]
					sound cSpeakerPin, [50\4000]
					
					BodyPosX = 0
					BodyPosZ = 0
					BodyRotX1 = 0
					BodyRotY1 = 0
					BodyRotZ1 = 0
					TravelLengthX = 0
					TravelLengthZ = 0
					TravelRotationY = 0
					
					SelectedLeg=255 ; none
					SLHold=0
			
					bXBeeControlMode = GPPlayerMode
				else
					gosub XBeeOutputString[@_GPSEQDISABLED]
					sound cSpeakerPin, [50\4000]
				endif
			ENDIF
#ENDIF
			; Hack there are several places that use the 1-N buttons to select a number as an index
			; so lets convert our bitmap of which key may be pressed to a number...
			; BUGBUG:: There is probably a cleaner way to convert...
			iNumButton = 0		; assume no button
			if ((bPacket(PKT_BTNLOW) & 0xFE) or (bPacket(PKT_BTNHI) & 0x03)) and ((abButtonsPrev(0) & 0xFE) = 0) and ((abButtonsPrev(1) & 0x03) = 0) then
				b = bPacket(PKT_BTNLOW) & 0xfe
				if b then
					while not b.bit0
						b = b >> 1
						iNumButton = iNumButton + 1
					wend
				else
					b = bPacket(PKT_BTNHI)
					iNumButton = 8		; start off at bit 8
					while not b.bit0
						b = b >> 1
						iNumButton = iNumButton + 1
					wend
				endif
			endif
			; BUGBUG:: we are using all keys now, may want to reserve some...		
			;Switch gait
			; We will do slightly different here than the RC version as we have a bit per button
			IF bXBeeControlMode=WalkMode then
				IF iNumButton  and (iNumButton <= 5) THEN	;1-5 Button Gait select	  
					IF ABS(TravelLengthX)<cTravelDeadZone & ABS(TravelLengthZ)<cTravelDeadZone & ABS(TravelRotationY*2)<cTravelDeadZone THEN
					
						;Switch Gait type
						GaitType = iNumButton-1
						Sound cSpeakerPin,[50\4000]
						GOSUB GaitSelect
						; For the heck do in assembly!
						pT = @_GATENAMES	; Point to the first of the paint names
						mov.l	@PT:16, er0					; pointer to our strings
						mov.b	@GAITTYPE, r1l				; r1l has the gait type
						beq		_CI_GS_ENDLOOP:8			; passed zero in so done
_CI_GS_LOOP:					
						mov.b	@er0+, r2l					; get the count of bytes in this string and increment to next spot
						extu.w	r2
						extu.l	er2							; convert to 32 bits
						add.l	er2, er0					; and increment to the next string
						dec.b	r1l							; decrement our count
						bne		_CI_GS_LOOP:8				; done
_CI_GS_ENDLOOP:
						mov.l	er0, @PT					; save away our generated pointer					
						; And tell the remote the name for the selected gate
		
					gosub XBeeOutputString[pT]
				  endif	
				ENDIF;IF iNumButton... 
			ENDIF;IF bXBeeControlMode=WalkMode

			;Switch single leg
			IF bXBeeControlMode=SingleLegMode THEN	  
				IF iNumButton>=1 & iNumButton<=6 THEN
					Sound cSpeakerPin,[50\4000]
					SelectedLeg = iNumButton-1
					SLHold=0
				ENDIF
			
				IF iNumButton = 9  THEN ;Switch Directcontrol
			  		sound cSpeakerPin, [50\4000]
			  		SLHold = SLHold^1 	;Toggle SLHold
				ENDIF
			ELSEIF bXBeeControlMode=Walkmode
				SelectedLeg=255	; none
				SLHold=0
			ENDIF

			;Body Height Control depends on packet size we received.  For now only process 2 different ones, but could/should
			; add in support for the original control...
			if cbPacket > PKT_MSLIDER then 
				GOSUB SmoothControl [bPacket(PKT_MSLIDER), BodyPosY, 3], BodyPosY ;[CtrlMoveInp, CtrlMoveOut, CtrlDivider], CtrlMoveOut
			else	
				GOSUB SmoothControl [bPacket(PKT_LPOT), BodyPosY, 3], BodyPosY ;[CtrlMoveInp, CtrlMoveOut, CtrlDivider], CtrlMoveOut
			endif
			;Leg lift height - Right slider has value 0-255 translate to 30-93
			LegLiftHeight = 30 + bPacket(PKT_RSLIDER)/4 ;Trying 4 for T-Hex
		
			;**********************************************************************************
			;Walk mode	
			;**********************************************************************************			
			IF (bXBeeControlMode=WalkMode) THEN 	
				TravelLengthX = -(bPacket(PKT_LJOYLR) - 128)
				TravelLengthZ = -(bPacket(PKT_LJOYUD) - 128)
				;XP:	
				TravelRotationY = -(bPacket(PKT_RJOYLR) - 128)/3
				
				GOSUB SmoothControl [((bPacket(PKT_RJOYUD)-128)*3), BodyRotX1, 2], BodyRotX1; max +/- 38,4 deg
				GOSUB SmoothControl [(-(bPacket(PKT_RPOT)-128)*5/2), BodyRotZ1, 2], BodyRotZ1; max +/- 32,0 deg
				
				;Calculate walking time delay
				InputTimeDelay = 128 - (ABS((bPacket(PKT_RJOYLR)-128)) MIN ABS(((bPacket(PKT_LJOYUD)-128)))) MIN ABS(((bPacket(PKT_LJOYLR)-128))) + (128 -(bPacket(PKT_LSLIDER))/2)

			ENDIF
			
			;**********************************************************************************
			;Body move
			;**********************************************************************************		
			IF (bXBeeControlMode=TranslateMode) THEN	
				TravelLengthZ = -(bPacket(PKT_LJOYUD) - 128)
				GOSUB SmoothControl [((bPacket(PKT_RJOYLR)-128)*2/3), BodyPosX, 2], BodyPosX
				GOSUB SmoothControl [((bPacket(PKT_RJOYUD)-128)*2/3), BodyPosZ, 2], BodyPosZ
				GOSUB SmoothControl [((bPacket(PKT_LJOYLR)-128)*2), BodyRotY1, 2], BodyRotY1 ; max +/- 25,5 deg
				
				;Calculate walking time delay
				InputTimeDelay = 128 - (ABS((bPacket(PKT_LJOYUD)-128)))  + (128 -(bPacket(PKT_LSLIDER))/2)

			ENDIF		
			
			;**********************************************************************************
			;Body rotate	
			;**********************************************************************************	
			IF (bXBeeControlMode=RotateMode) THEN
				IF iNumButton  and (iNumButton <=3) THEN
				  LjoyUDFunction = iNumButton -1
				  FunctionIsChanged = 1
				  Sound P9,[20\4000]
				ENDIF
				IF (iNumButton = 4) THEN ; Toogle Left Joystick left/Right function
				  LeftJoyLRmode = !LeftJoyLRmode
				  IF LeftJoyLRmode THEN
				    gosub XBeeOutputString[@_LJOYLRtrans]
				    Sound P9,[20\1500]
				  ELSE
				    gosub XBeeOutputString[@_LJOYLRrotate]
				    Sound P9,[20\2500]
				  ENDIF
				ENDIF
#IFDEF LiPoSafetyON
				IF (iNumButton = 8) THEN ; Toggle bDisplayLiPo
				  bDisplayLiPo = !bDisplayLiPo
				  Sound P9,[20\(1500+1000*bDisplayLiPo)]
				ENDIF
#ENDIF  
				IF (iNumButton = 9) THEN ; Toogle LockFunction
				  LockFunction = !LockFunction
				  IF LockFunction THEN
				    gosub XBeeOutputString[@_LockON]
				    Sound P9,[20\1500]
				  ELSE
				    gosub XBeeOutputString[@_LockOFF]
				    Sound P9,[20\2500]
				  ENDIF 
				ENDIF
				GOSUB BranchLjoyUDFunction
				IF LeftJoyLRmode THEN ;Do X translation:
				  GOSUB SmoothControl [((bPacket(PKT_LJOYLR)-128)*2/3), BodyPosX, 2], BodyPosX
				ELSE				  ;Do Y rotation:
				  GOSUB SmoothControl [((bPacket(PKT_LJOYLR)-128)*2), BodyRotY1, 2], BodyRotY1 
				ENDIF
				GOSUB SmoothControl [((bPacket(PKT_RJOYUD)-128)*3), BodyRotX1, 2], BodyRotX1
				GOSUB SmoothControl [(-(bPacket(PKT_RJOYLR)-128)/4), BodyRotZ1, 2], BodyRotZ1
				
				;Calculate walking time delay
				InputTimeDelay = 128 - (ABS((bPacket(PKT_LJOYUD)-128)))  + (128 -(bPacket(PKT_LSLIDER))/2)

			ENDIF
			
			;**********************************************************************************
			;Single Leg Mode
			;**********************************************************************************
			IF (bXBeeControlMode = SingleLegMode) THEN
				SLLegX = (bPacket(PKT_RJOYLR)-128)
				SLLegZ = -(bPacket(PKT_RJOYUD)-128)
				SLLegY = -(bPacket(PKT_LJOYUD)-128)*2 ;XP more logic single leg control ;)
			ENDIF
			
		  ENDIF;IF (GPStart=0)
#IFDEF USEGP
			;**********************************************************************************
			; GP Player mode
			;**********************************************************************************
			IF bXBeeControlMode = GPPlayerMode THEN
				IF (iNumButton>=1 & iNumButton<=9 ) THEN	;1-9 Button Play GP Seq
					IF (GPStart = 0) THEN
						GPSEQ = iNumButton-1
					ENDIF
				
					; We may need to disable interrupts here for this to work properly with SSC-32...
					gosub ControlAllowInput[0];
					pause 1	
					gosub GPSeqNumSteps[], _b		; Reused the variable...
					gosub ControlAllowInput[1];	
					IF (_b = 0xff)	THEN
						gosub XBeeOutputString[@_GPSEQNOTDEF]  ; that sequence was not defined...
						;gosub XBeePlaySounds[@_GPSNDERR, 4];	// BUGBUG: maybe should pass number of notes instead?
						gosub WaitXBeeHSeroutComplete
					ELSE
						; let user know that sequence was started
						gosub XBeeOutputString[@_GPSEQSTART]  	; Tell user sequence started.
						gosub WaitXBeeHSeroutComplete
						pause 5

						fGPSequenceRun = 1 						; remember that ran one...
						fGPSpeedControl = 0; 					; start off running the speed normal...
						GPStart = 1
						GPSM = 100								; run at 100% speed...
					ENDIF
					iNumButton = 0 ; reset
				ENDIF
			
				; If the GP Player is still running, see what step we are at and if it is different we can
				; report that to the end user.
    			CtrlMoveOut = GPSM								; Hack reuse variable to test to see if something changed...
				IF (GPStart) THEN
					IF fGPSpeedControl or ((ABS(bPacket(PKT_RJOYUD)-128))>=cTravelDeadZone) THEN
						GPSM = ((bPacket(PKT_RJOYUD)-128)*25) / 16;Set GP Speed
						fGPSpeedControl = 1				; we are now in speed control mode
					ELSE
						GPSM = 100						; Main area may destroy it...
					ENDIF

					; Find out what step we are now running and if it has changed or
					; we changed GP speed, update the display on the controller
					gosub GPGetCurrentStep[], bCGPSStep 
					IF (bCGPSStep <> bCGPSStepPrev) OR (CtrlMoveOut <> GPSM) THEN
   						_bTemp = 14,"CS:    SM:    " ;Current Step and Speed Multiplier
      					_b = 0
      					bCGPSStepPrev = bCGPSStep	; save away the last one
      					do ;Convert byte value to string:
	      					i = bCGPSStep	; save away the last one
 							_bTemp(6-_b) = "0" + bCGPSStep // 10
         					bCGPSStep = bCGPSStep / 10
         					_b = _b + 1
      					while (i >= 10)
      					
      					; we will reuse CtrlMoveOut here to output the number  
      					CtrlMoveOut = GPSM
      					If CtrlMoveOut < 0 then
      						_bTemp(10) = "-"
     						CtrlMoveOut = -CtrlMoveOut
      						_b = 1   
   	  					endif
   					
   	  					do ;Convert byte value to string:
         					i = CtrlMoveOut
         					_bTemp(14-_b) = "0" + CtrlMoveOut // 10
         					CtrlMoveOut = CtrlMoveOut / 10
         					_b = _b + 1
      					while (i >= 10)
    					; output to display...
	   					gosub XBeeOutputString[@_bTemp]  
						gosub WaitXBeeHSeroutComplete	; give a little time for it to output
	   				ENDIF  
				ENDIF
			ENDIF
			;*********************************************************************************************
#ENDIF	
			
		ENDIF;IF HexOn
	  
		abButtonsPrev(0) = bPacket(PKT_BTNLOW)
		abButtonsPrev(1) = bPacket(PKT_BTNHI)
	else;if fPacketValid
		; Not a valid packet - we should go to a turned off state as to not walk into things!
		IF(HexOn and (fPacketForced or fPacketEnterSSCMode)) THEN
			'Turn off
			Sound cSpeakerPin,[100\5000,80\4500,100\5000,60\4000] ' play it a little different...
			BodyPosX = 0
			BodyPosY = 0
			BodyPosZ = 0
			BodyRotX1 = 0
			BodyRotY1 = 0
			BodyRotZ1 = 0
			TravelLengthX = 0
			TravelLengthZ = 0
			TravelRotationY = 0
			
			SSCTime = 600
			HexOn = 0
		endif
	endif;if fPacketValid


return


;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
; From XBEE_TASERIAL_SUPPORT
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;==============================================================================
; XBEE - Support
;==============================================================================

;==============================================================================
; [WaitXBeeHSeroutComplete] - This simple helper function waits until the HSersial
; 							output buffer is empty before continuing...
; BUGBUG: Rolling our own as the hserstat reset the processor
;==============================================================================
WaitXBeeHSeroutComplete:
	nop						; transisition to assembly language.
_WTC_LOOP:	
#ifdef BASICATOMPRO28
	mov.b	@_HSEROUTSTART,r0l
	mov.b	@_HSEROUTEND,r0h
#else
	mov.b	@_HSEROUT2START,r0l
	mov.b	@_HSEROUT2END,r0h
#endif	
	cmp.b	r0l,r0h
	bne		_WTC_LOOP:8

	;hserstat 5, WaitTransmitComplete				; wait for all output to go out...	
	return



;==============================================================================
; [InitXbee] - Initialize the XBEE for use with DIY support
;==============================================================================
InitXBee:
#ifdef BASICATOMPRO28
	sethserial1 cXBEE_BAUD
#else	
	sethserial2 cXBEE_BAUD
#endif	
	_bAPISeqNum = 0
	pause 20							; have to have a guard time to get into Command sequence
#ifdef cXBEE_RTS			; RTS line optional for us with HSERIAL 
	hserout HSP_XBEE, [str _XBEE_PPP_STR\3]
	gosub WaitXBeeHSeroutComplete
	pause 20							; have to wait a bit again
	hserout HSP_XBEE, [	"ATD6 1",13,|			; turn on flow control
				str _XBEE_ATCN_STR\5]				; exit command mode
	low cXBEE_RTS						; make sure RTS is output and input starts off enabled...

#endif ; cXBEE_RTS
	pause 20							; have to have a guard time to get into Command sequence
	; will start off trying to make sure we are in api mode...
	hserout HSP_XBEE, [str _XBEE_PPP_STR\3]
	gosub WaitXBeeHSeroutComplete
	pause 20							; have to wait a bit again
	hserout HSP_XBEE, [	"ATAP 1",13,|			; turn on flow control
				str _XBEE_ATCN_STR\5]				; exit command mode
	
	pause 10	; need to wait to exit command mode...
	cPacketTimeouts = 0
	fTransReadyRecvd = 0
	_fPacketValidPrev = 0
	fPacketEnterSSCMode = 0   
	_fReqDataPacketSent = 0
	_fReqDataForced = 0			;
    gosub ClearInputBuffer		; make sure we toss everything out of our buffer and init the RTS pin

return

;==============================================================================
; [XBeeOutputVal[bXbeeVal]] - Output a value back to the device.  Works for XBee
; 		by sending Byte value back to the DIY remote to display.
; Parmameters:
;		bXbeeVal - Value to send back
;==============================================================================
wXbeeVal	var	word
XBeeOutputVal[wXbeeVal]:
	gosub SendXBeePacket[_wTransmitterDL, XBEE_RECV_DISP_VAL, 2, @wXbeeVal]	
	  
	;GOSUB XBeeResetPacketTimeout ; sets _lTimerLastPacket ***TEST	
return

;==============================================================================
; [XBeeOutputString] - Output a string back to the device.  Works for XBee
; 		by outputing the string back to the DIY remote to display.
; Parmameters:
;		pString - Pointer to string.  First byte contains the length
;==============================================================================
pString	var	pointer
wDL var word
XBeeOutputString[pString]:
	wDL = _wTransmitterDL
	goto _XOSTODL_DoIt

;==============================================================================
; [XBeeOutputStringDL] - Output a string to a specified DL.. To save some
; 		code the non dl one will simply jump to us to finish the work...
; 		by outputing the string back to the DIY remote to display.
; Parmameters:
;		_wDestDL - what address to send the stuff to
;		pString - Pointer to string.  First byte contains the length
;==============================================================================
XBeeOutputStringToDL[wDL, pString]:
	; BUGBUG:: Will not work for zero count, but what the heck.
	; First we need to get the count..
_XOSTODL_DoIt:
	mov.l	@PSTRING:16, er0		; get the pointer value into ero
	mov.b	@er0+, r1l				; Get the count into R1l - start of the checksum
	mov.l	er0, @PSTRING:16		; Update pointer value to be after the count byte.
	mov.b	r1l, @_TAS_B:16			; save away count to pass to the serial output...

	gosub SendXBeePacket[wDL, XBEE_RECV_DISP_STR, _tas_b, pString]		; Send Data to remote (CmdType, ChkSum, Packet Number, CB extra data)

return

#ifdef DIY_SOUNDS	; Currently disabled as DIY remote currently has no speaker enabled...
;==============================================================================
; [XBeePlaySounds] - Sends the buffer of souncs back to the remote to play
; Parmameters:
;		pSnds - Pointer to the sounds
;		cbSnds - Size of the buffer
;==============================================================================
; Too bad I don't have real macros to save space...
pSnds 	var pointer
cbSnds	var	byte
XBeePlaySounds[pSnds, cbSnds]:
	gosub SendXBeePacket[_wTransmitterDL, XBEE_PLAY_SOUND, cbSnds, pSnds]		; Send Data to remote (CmdType, ChkSum, Packet Number, CB extra data)
	return
#endif
	
;==============================================================================
; [XbeeRTSAllowInput] - This function enables or disables the RTS line for the XBEE
; This is only used for the XBEE on HSERIAL mode as the TASerial has the RTS stuff
; built in and we don't want to throw away characters...
;==============================================================================
fRTSEnable	var	byte
XbeeRTSAllowInput[fRTSEnable]
#ifdef cXBEE_RTS
	if fRTSEnable then
		low cXBEE_RTS
	else
		high cXBEE_RTS
	endif
#endif
return

;==============================================================================
; [APISetXbeeHexVal] - Set the XBee DL to the specified word that is passed
; BUGBUG: sample function, need to clean up.
;==============================================================================
_c1		var		byte
_c2		var		byte
_lval	var		long
APISetXBeeHexVal[_c1, _c2, _lval]:
	' We are going to reuse _bAPIPacket to generate the packet...
	_bAPIPacket(0) = 0x7E
	_bAPIPacket(1) = 0
	_bAPIPacket(2) = 8      			' this is the length LSB
	_bAPIPacket(3) = 8      			' CMD=8 which is AT command
	_bAPISEQnum = _bAPISEQnum + 1 		' keep a running sequence number so we can see which ack we are processing		
	_bAPIPacket(4) = _bAPISeqnum     	' could be anything here
	_bAPIPacket(5) = _c1
	_bAPIPacket(6) = _c2
	_bAPIPacket(7) = _lval >> 24
	_bAPIPacket(8) = (_lval >> 16) And 0xFF
	_bAPIPacket(9) = (_lval >> 8) And 0xFF
	_bAPIPacket(10) = _lval And 0xFF
	b = 0
    
    For _bAPI_i = 3 To 10  ' don't include the frame delimter or length in count - likewise not the checksum itself...
        b = b + _bAPIPacket(_bAPI_i)
    Next
    _bAPIPacket(11) = 0xFF - b
        
    ' now write out the data to the hardware serial port
    hserout HSP_XBEE,[str _bAPIPacket\12]

	' BUGBUG:: Should we wait for and process the response?
	return

;==============================================================================
; [APIGetXbeeHexVal] - Set the XBee DL to the specified word that is passed
;==============================================================================
APIGetXBeeHexVal[_c1, _c2]:
	_bAPIPacket(0) = 0x7E
	_bAPIPacket(1) = 0
	_bAPIPacket(2) = 4      			' this is the length LSB
	_bAPIPacket(3) = 8      			' CMD=8 which is AT command
	_bAPISEQnum = _bAPISEQnum + 1 		' keep a running sequence number so we can see which ack we are processing		
	_bAPIPacket(4) = _bAPISeqnum     	' could be anything here
	_bAPIPacket(5) = _c1
	_bAPIPacket(6) = _c2
	b = 0
    For _bAPI_i = 3 To 6  ' don't include the frame delimter or length in count - likewise not the checksum itself...
        b = b + _bAPIPacket(_bAPI_i)
    Next
    _bAPIPacket(7) = 0xFF - (b And 0xFF)
    
    ' now write out the data to the hardware serial port
    hserout HSP_XBEE,[str _bAPIPacket\8]
	gosub WaitXBeeHSeroutComplete
	
	do 
		gosub APIRecvPacket[1], _bAPIRecvRet
		
		if _bAPIRecvRet then
			if (_bAPIPacket(0) = 0x88) and (_bAPIPacket(1) = _bAPISEQnum) and (_bAPIPacket(4) = 0) then
				if _bAPIRecvRet = 7 then ; only a word returned...
					return (_bAPIPacket(5) << 8) +  _bAPIPacket(6) 
				else
					return (_bAPIPacket(5) << 24) + (_bAPIPacket(6) << 16) + (_bAPIPacket(7) << 8) + _bAPIPacket(8) 
				endif
			endif
		endif	
	while (_bAPIRecvRet)
	
	return -1 ; some form of error

;==============================================================================
; [APIGetXBeeStringVal - Retrieve a string value back from the XBEE 
;		- Will return TRUE if it receives something, else false
;==============================================================================
_pbSVal		var	pointer
_cbSVal		var	byte
APIGetXBeeStringVal[_c1, _c2, _pbSVal, _cbSVal]:

	; BUGBUG: very much like the DL except what we do with the string result at the end - combine???
	_bAPIPacket(0) = 0x7E
	_bAPIPacket(1) = 0
	_bAPIPacket(2) = 4      			' this is the length LSB
	_bAPIPacket(3) = 8      			' CMD=8 which is AT command
	_bAPISEQnum = _bAPISEQnum + 1 		' keep a running sequence number so we can see which ack we are processing		
	_bAPIPacket(4) = _bAPISeqnum     	' could be anything here
	_bAPIPacket(5) = _c1
	_bAPIPacket(6) = _c2
	b = 0
    For _bAPI_i = 3 To 6  ' don't include the frame delimter or length in count - likewise not the checksum itself...
        b = b + _bAPIPacket(_bAPI_i)
    Next
    _bAPIPacket(7) = 0xFF - (b And 0xFF)
    
    ' now write out the data to the hardware serial port
    hserout HSP_XBEE,[str _bAPIPacket\8]
	gosub WaitXBeeHSeroutComplete
	
	do 
		gosub APIRecvPacket[1], _bAPIRecvRet
		
		if _bAPIRecvRet then
			if (_bAPIPacket(0) = 0x88) and (_bAPIPacket(1) = _bAPISEQnum) and (_bAPIPacket(4) = 0) then
				; The return value from the recv is the total packet length, we can use this to know how many
				; bytes were in the string.  (count - 5 )
				; Need to see if we read all of the value or not, ie did we get a CR
				; 
				_bAPIRecvRet = (_bAPIRecvRet - 5) max _cbSVal
				for _cbSVal = 0 to _bAPIRecvRet - 1
					@_pbSVal = _bAPIPacket(_cbSVal + 5)
					_pbSVal = _pbSVal + 1
				next
			endif
			return _bAPIRecvRet
		endif	
	while (_bAPIRecvRet)
	
	return -1 ; some form of error


;==============================================================================
; [APIRecvPacket - try to receive a packet from the XBee. 
;		- Will return TRUE if it receives something, else false
;		
;==============================================================================
_fapiWaitForInput	var	byte
APIRecvPacket[_fapiWaitForInput]:

	' First see if the user wants us to wait for input or not
	;	hserstat HSERSTAT_INPUT_EMPTY, _TP_Timeout			; if no input available quickly jump out.
	; Well Hserstat is failing, try rolling our own.
	if not _fapiWaitForInput then
		; use the new hserinnext instead of assembly to see if there is input...
#ifdef BASICATOMPRO28
		if (hserinnext 0x81) = -1 then
#else
		if (hserinnext 0x82) = -1 then
#endif
			return 0;
		endif
	endif	


	' now lets try to read in the header part of the packet.  Note, we will provide some
	' timeout for this as we don't want to completely hang if something goes wrong!
	' will not get out of the loop until either we time out or we get an appropriate start
	' character for a packet
	repeat
		hserin HSP_XBEE, _ARP_TO, 20000, [_bAPIPacket(0)]
	until _bAPIPacket(0) = 0x7E

	hserin HSP_XBEE,  _ARP_TO,20000, [_wAPIPacketLen.highbyte, _wAPIPacketLen.lowbyte]



	' Lets do a little verify that the packet looks somewhat valid.
	if (_wAPIPacketLen > APIPACKETMAXSIZE) then
		return 0
	endif

	' Then read in the packet including the checksum.
	hserin HSP_XBEE, _ARP_TO, 20000,  [str _bAPIPacket\_wAPIPacketLen, _bChkSumIn]
	

	' Now lets verify the checksum.
	_b = 0
	for _bAPI_i = 0 to _wAPIPacketLen-1
		_b = _b + _bAPIPacket(_bAPI_i)
	next

	if _bChkSumIn <> (0xff - _b) then
		return 0		' checksum was off
	endif

	return _wAPIPacketLen 	' return the packet length as the caller may need to know this...
	
_ARP_TO:
	return 0  ; we had a timeout

;==============================================================================
; [SendXBeePacket] - Simple helper function to send the 4 byte packet header
;	 plus the extra data if any
; 	 gosub SendXBeePacket[bPacketType, bSeq, cbExtra, pExtra]
;==============================================================================

_wDestDL	var word
_bPCBExtra	var	byte
_pbIN		var	pointer		; pointer to data to retrieve
_bPHType 	var _bAPIPacket(8)
SendXbeePacket[_wDestDL, _bPHType, _bPCBExtra, _pbIN]:

	' We are going to reuse _bAPIPacket to generate the packet...
	' will be using 15 bit addressing to talk to destination.
	_bAPIPacket(0) = 0x7E
	_bAPIPacket(1) = 0
	_bAPIPacket(2) = 5 + XBEE_API_PH_SIZE+_bPCBExtra 		' this is the length LSB
	_bAPIPacket(3) = 1      			' CMD=1 which is TX with 16 bit addressing
	_bAPISEQnum = _bAPISEQnum + 1 		' keep a running sequence number so we can see which ack we are processing		
	if _bAPISEQnum = 0 then				' Don't have sequence number = 0 as this causes no ACK...
		_bAPISEQnum = 1
	endif
	_bAPIPacket(4) = _bAPISeqnum    
	_bAPIPacket(5) = _wDestDL.highbyte	' set the destination DL in the message
	_bAPIPacket(6) = _wDestDL.lowbyte
	_bAPIPacket(7) = 0					' normal type of message
	' So our data starts at offset 8 in this structure.  Use this in handling the parameters passed...
	' bytes 8-9 were set by the parameter handling in basic

	' We could have copied the extra data to our api buffer or we could simply
	' handle it on our write to the xbee, first pass do on write.
	' Need to first compute the XBee checksum
	
	_b = 0
    For _bAPI_i = 3 To 7 + XBEE_API_PH_SIZE  ' Compute the checksum for all of the standard parts of the packet header.
        _b = _b + _bAPIPacket(_bAPI_i)
    Next

	' Output the packet - easy if no extra data
	
	if not _bPCBExtra then
		hserout HSP_XBEE, [str _bAPIPacket\8 + XBEE_API_PH_SIZE, 0xff - _b]							; Real simple message 
	else
		' Now see if we need to add the extra bytes on 
		; need to finish checksum - could do in basic but need to verify pointer...
		mov.b	@_B:16, r1l				; get the checkum already calculated for header
		mov.b	@_BPCBEXTRA:16, r1h		; get the count of bytes 
		mov.l	@_PBIN, er0				; get the pointer to extra data
_SXBP_CHKSUM_LOOP:
		mov.b	@er0+, r2l				; get the next character
		add.b	r2l,  r1l				; add on to r0l for checksum
		dec.b	r1h						; decrement	our counter
		bne		_SXBP_CHKSUM_LOOP:8		; not done yet.  
		mov.b	r1l, @_B:16				; save away checksum for basic to use
    
		hserout HSP_XBEE, [str _bAPIPacket\8 + XBEE_API_PH_SIZE, str @_pbIN\_bPCBExtra, 0xff - _b]		; Real simple message 
	endif
	return

	
;==============================================================================
; [ClearInputBuffer] - This simple helper function will clear out the input
;						buffer from the XBEE
;==============================================================================
ClearInputBuffer:

; 	warning this function does not handle RTS for HSERIAL
; 	assumes that it has been setup properly before it got here.
_CIB_LOOP:	
	hserin HSP_XBEE, _CIB_TO, 1000, [_tas_b]
	goto _CIB_LOOP
	
_CIB_TO:
	return


;--------------------------------------------------------------------
;[XBeeResetPacketTimeout] - This function resets the save timer value that is used to 
;				 decide if our XBEE has timed out It could/should be simplay;				 a call to GetCurrentTime, but try to save a little time of
;				 not nesting the calls...
;==============================================================================
	
XBeeResetPacketTimeout:
	gosub GetCurrentTime[],_lTimerLastPacket
	return



;==============================================================================
; [ReceiveXBeePacket] - This function will try to receive a packet of information
; 		from the remote control over XBee.
;
; the data in a standard packet is arranged in the following byte order:
;	0 - Buttons High
;	1 - Buttons Low
; 	2 - Right Joystick L/R
;	3 - Right Joystick U/D
;	4 - Left Joystick L/R
;	5 - Left Joystick U/D
; 	6 - Right Slider
;	7 - Left Slider
;==============================================================================
bDataOffset	var	byte
_alNIPD		var long(7)		; 2 for SL+H + 20 bytes for NI data...
_lSNH		var _alNIPD(0)	; Serial Number High
_lSNL		var _alNIPD(1)	; Serial number low.
_bNI		var	_alNIPD(2)	; String to read NI into...
_pbNI		var	pointer		; need something to point as a byte pointer

ReceiveXBeePacket:
	_fPacketValidPrev = fPacketValid		; Save away the previous state as this is the state if no new data...
	fPacketValid = 0
	fPacketTimeOut = 0
	_fNewPacketAvail = 0;
	fPacketForced = 0;
	fPacketEnterSSCMode = 0   
	;	We will first see if we have a packet header waiting for us.
#ifdef CXBEE_RTS
	low cXBEE_RTS		; Ok enable input from the XBEE - wont turn off by default
	; bugbug should maybe check to see if it was high first and if
	; so maybe bypass the next check...
#endif	
_RXP_TRY_RECV_AGAIN:
	gosub APIRecvPacket[0], _bAPIRecvRet
	
	if  not _bAPIRecvRet then _RXP_CHECKFORHEADER_TO	; I hate gotos...

	' We received an XBee Packet, See what type it is.
	' first see if it is a RX 16 bit or 64 bit packet?
	If _bAPIPacket(0) = 0x81 Then
		' 16 bit address sent, so there is 5 bytes of packet header before our data
		bDataOffset = 5
	ElseIf _bAPIPacket(0) = 0x80
		' 64 bit address so our data starts at offset 11...
		bDataOffset = 11
		
	ElseIf _bAPIPacket(0) = 0x89
		' this is an A TX Status message - May check status and maybe update something?
		goto _RXP_TRY_RECV_AGAIN
		
	Else
		goto _RXP_CHECKFORHEADER_TO
	EndIf

	;-----------------------------------------------------------------------------
	; [XBEE_TRANS_DATA]
	;-----------------------------------------------------------------------------
	; process first as higher number of these come in...
	if (_bAPIPacket(bDataOffset + 0) = XBEE_TRANS_DATA) then
		' Don't need to worry about checksum or the like as verified higher up...
		_fReqDataPacketSent = 0	; if we received a packet reset so we will request data again...

		; Allow for packets larger than the data we are actually going to process
		; Also remember what type of packet we received.  We have had 3 different sizes of with changes
		; in the remote, remember which we received, such that we can change how we use them...
		if (_bAPIRecvRet-bDataOffset >= (XBEE_API_PH_SIZE + XBEEMINPACKETSIZE) ) then
		    cbPacket = (_bAPIRecvRet-bDataOffset-1) max XBEEMAXPACKETSIZE		; don't allow it to be bigger than our max value
			for _b = 0 to cbPacket-1
				bPacket(_b) = _bAPIPacket(_b + XBEE_API_PH_SIZE + bDataOffset)
			next
			goto _SetToValidDataAndReturn
		else
			; Data size is less than minimum 
;			toggle p6			; BUGBUG - Debug
			gosub ClearInputBuffer
		endif
	;-----------------------------------------------------------------------------
	; [XBEE_TRANS_CHANGED_DATA] - We have a packet that is a delta from our current data
	;			so we need to walk through this data and update the appropriate bytes in
	;			the packet
	;-----------------------------------------------------------------------------
	elseif (_bAPIPacket(bDataOffset + 0) = XBEE_TRANS_CHANGED_DATA) 
		cbPacket = (_bAPIRecvRet-bDataOffset-1) max XBEEMAXPACKETSIZE		; don't allow it to be bigger than our max value
		if (cbPacket > 2) and (cbPacket < (2+XBEEMAXPACKETSIZE)) then 
			
			; going to reuse the wNewDL variable...
			wNewDL.highbyte = _bAPIPacket(bDataOffset+XBEE_API_PH_SIZE)
			wNewDL.lowbyte = _bAPIPacket(bDataOffset+XBEE_API_PH_SIZE+1)
			
			_b = 0				; offset into complete packet
			_bAPI_i = XBEE_API_PH_SIZE + bDataOffset + 2;		; offset into our compressed packet
			while wNewDL
				if (wNewDL & 0x1) then
					bPacket(_b) = _bAPIPacket(_bAPI_i)
					_bAPI_i = _bAPI_i + 1
				endif
				_b = _b + 1
				wNewDL = wNewDL >> 1		; shift it down to next bit
			wend	
			goto _SetToValidDataAndReturn
		endif
	
	;-----------------------------------------------------------------------------
	; [XBEE_TRANS_NOTHIN_CHANGED] - Answer came back from remote telling us that
	;		nothing was changed since the last packet data we received...
	;-----------------------------------------------------------------------------
	elseif (_bAPIPacket(bDataOffset + 0) = XBEE_TRANS_NOTHIN_CHANGED) 

_SetToValidDataAndReturn:
		_fReqDataPacketSent = 0	; if we received a packet reset so we will request data again...
		fPacketValid = 1	; data is valid
		cPacketTimeouts = 0	; reset when we have a valid packet
		fPacketForced = _fReqDataForced	; Was the last request forced???
		_fReqDataForced = 0				; clear that state now
		_bTransDataVersion = 0;			; start off assuming old version data...
		GOSUB XBeeResetPacketTimeout ; sets _lTimerLastPacket
		return	;  		; get out quick!
		
	;-----------------------------------------------------------------------------
	; [XBEE_TRANS_READY]
	;-----------------------------------------------------------------------------
	elseif (_bAPIPacket(bDataOffset + 0) = XBEE_TRANS_READY)
		; Two cases.  everything zero which is the old simple all zero, newer one has the MY of the transmitter, so we will want to update
		; our DL to point to it...
		if (_bAPIRecvRet-bDataOffset = (XBEE_API_PH_SIZE + 2) ) then  ; 4 bytes for the packet header + 2 bytes for the extra data!.
			' Normal format, may later add in 64 bit addressing...
			wNewDL.highbyte = _bAPIPacket(bDataOffset+XBEE_API_PH_SIZE)
			wNewDL.lowbyte = _bAPIPacket(bDataOffset+XBEE_API_PH_SIZE+1)
			fTransReadyRecvd = 1		; OK we have received a packet saying transmitter is ready.	
			gosub APISetXBeeHexVal["D","L", wNewDL]
			_wTransmitterDL = wNewDL
		endif
		Sound cSpeakerPin,[100\4400]

		GOSUB XBeeResetPacketTimeout ; sets _lTimerLastPacket
		_fReqDataPacketSent = 0							; make sure we don't think we have any outstanding requests
		gosub XBeeOutputStringToDL[0, @_PhoenixDebug]			; try with 0 to imply our debug terminal...
	;-----------------------------------------------------------------------------
	; [XBEE_TRANS_NOTREADY]
	;-----------------------------------------------------------------------------
	elseif (_bAPIPacket(bDataOffset + 0) = XBEE_TRANS_NOTREADY)
		; we are being told that the transmitter may not be valid anymore...
		Sound cSpeakerPin,[60\3200]
		fTransReadyRecvd = 0			; Ok not valid anymore...
		
	;-----------------------------------------------------------------------------
	; [XBEE_TRANS_DATA_VERSION]
	;-----------------------------------------------------------------------------
	elseif (_bAPIPacket(bDataOffset + 0) = XBEE_TRANS_DATA_VERSION)
		if (_bAPIRecvRet-bDataOffset = (XBEE_API_PH_SIZE + 1) ) then  ; 1 byte for data...
			_bTransDataVersion = _bAPIPacket(bDataOffset+XBEE_API_PH_SIZE);
		endif

	;-----------------------------------------------------------------------------
	; [XBEE_TRANS_NEW]
	;-----------------------------------------------------------------------------
	elseif (_bAPIPacket(bDataOffset + 0) = XBEE_TRANS_NEW)
		; The remote has told us it has new data available for us, so we should now ask for it!
		_fNewPacketAvail = 1;
	;-----------------------------------------------------------------------------
	; [XBEE_REQ_SN_NI]
	;-----------------------------------------------------------------------------
	elseif (_bAPIPacket(bDataOffset + 0) = XBEE_REQ_SN_NI)
		; The caller must pass through the DL to talk back to, or how else would we???
		; our DL to point to it...
		if (_bAPIRecvRet-bDataOffset = (XBEE_API_PH_SIZE + 2) ) then  ; 4 bytes for the packet header + 2 bytes for the extra data!.
			; we need to read in a new DL for the transmitter...
			wNewDL.highbyte = _bAPIPacket(bDataOffset)
			wNewDL.lowbyte = _bAPIPacket(bDataOffset+1)
			gosub APISetXBeeHexVal["D","L", wNewDL]
			_wTransmitterDL = wNewDL
			; now lets get the data to send back
			gosub APIGetXBeeStringVal["N","I", @_bNI, 20], _cbRead ; 
			gosub APIGetXBeeHexVal["S","L",0x0], _lSNL		; get the serial low, don't enter or leave
			gosub APIGetXBeeHexVal["S","H",0x2], _lSNH		; get the serial high, 

			_pbNI	= @_bNI				; get address
			_pbni.highword = 0x2		; make it a byte pointer
			_pbni = _pbni + _cbRead
			; lets blank fill the name...
			while (_cbRead < 14)
				@_pbNI = " "
				_cbRead = _cbRead + 1
				_pbNI = _pbNI + 1
			wend

			; last but not least try to send the data as a packet.
			gosub SendXBeePacket[_wTransmitterDL, XBEE_SEND_SN_NI_DATA, 22, @_lSNH]		; Send Data to remote (CmdType, ChkSum, Packet Number, CB extra data)
		endif
	;-----------------------------------------------------------------------------
	; [UNKNOWN PACKET]
	;-----------------------------------------------------------------------------
	else
		gosub ClearInputBuffer
	endif

;-----------------------------------------------------------------------------
; [See if we need to request data from the other side]
;-----------------------------------------------------------------------------
_RXP_CHECKFORHEADER_TO:

	; Only send when we know the transmitter is ready.  Also if we are in the New data only mode don't ask for data unless we have been told there
	; is new data. We relax this a little and be sure to ask for data every so often as to make sure the remote is still working...
	; 
	if fTransReadyRecvd then
		GOSUB GetCurrentTime[], _lCurrentTimeT

		; Time in MS since last packet
        gosub ConvertTimeMS[_lCurrentTimeT-_lTimerLastPacket], _lTimeDiffMS

		; See if we exceeded a global timeout.  If so let caller know so they can stop themself if necessary...
		if _ltimeDiffMS > CXBEETIMEOUTRECVMS then
			fPacketValid = 0
			fPacketForced = 1
			return
		endif

		; see if we have an outstanding request out and if it timed out...
		if _fReqDataPacketSent then
	        gosub ConvertTimeMS[_lCurrentTimeT-_lTimerLastRequest], _lTimeDiffMS
			if _lTimeDiffMS > CXBEEPACKETTIMEOUTMS then
				; packet request timed out, force a new attempt.
				_fNewPacketAvail = 1		; make sure it requests a new one	
				_fReqDataPacketSent = 0		; turn off that we sent it
			endif
		endif
		
		; Next see if it has been too long since we received a packet.  Ask to make sure they are there...
		if (_fNewPacketAvail = 0) and (_lTimeDiffMS > CXBEEFORCEREQMS) then
			_fNewPacketAvail = 1
			_fReqDataForced = 1		; remember that this request was forced!
		endif

		if ((fSendOnlyNewMode = 0) or (fSendOnlyNewMode and _fNewPacketAvail)) then
			; Now send out a prompt request to the transmitter:
			if _fReqDataPacketSent = 0 then 
				if _bTransDataVersion = 0 then
					gosub SendXBeePacket [_wTransmitterDL, XBEE_RECV_REQ_DATA, 0, 0]		; Request data Prompt (CmdType, ChkSum, Packet Number, CB extra data)
				else
					gosub SendXBeePacket [_wTransmitterDL, XBEE_RECV_REQ_DATA2, 0, 0]		; Transmitter supports new method with delta packets...
				endif
				_fReqDataPacketSent = 1	; 											; yes we have already sent one.
				GOSUB GetCurrentTime[], _lTimerLastRequest							; use current time to take care of delays...
			endif
		endif
		fPacketValid = _fPacketValidPrev	; Say the data is in the same state as the previous call...
	endif
	return

;-----------------------------------------------------------------------------------
;Branch Left Joystick Up/Down Function
;
BranchLjoyUDFunction:
  BRANCH LjoyUDFunction,[LjoyUDWalk, LjoyUDTranslate, SetRotOffset]
  
  LjoyUDWalk:
    TravelLengthZ = -(bPacket(PKT_LJOYUD) - 128)
  	IF FunctionIsChanged THEN 'Update DIY, send text string:
  	  gosub XBeeOutputString[@_LJOYUDwalk]
  	  FunctionIsChanged = 0
  	ENDIF
  return
  
  LjoyUDTranslate:
    GOSUB SmoothControl [((bPacket(PKT_LJOYUD)-128)*2/3), BodyPosZ, 2], BodyPosZ
  	IF FunctionIsChanged THEN 'Update DIY, send text string:
  	  gosub XBeeOutputString[@_LJOYUDtrans]
  	  FunctionIsChanged = 0
  	ENDIF
  return
  
  SetRotOffset:				
	IF LockFunction = 0 THEN	
	  BodyRotOffsetZ = (bPacket(PKT_LJOYUD) - 128)
	  BodyRotOffsetY = (bPacket(PKT_RPOT) - 128)
	ENDIF
  	IF FunctionIsChanged THEN 'Update DIY, send text string:
  	  gosub XBeeOutputString[@_SetRotOffset]
  	  FunctionIsChanged = 0
  	ENDIF
return
;--------------------------------------------------------------------
; SmoothControl
; This function makes the body rotation and translation much smoother while walking
; 
SmoothControl [CtrlMoveInp, CtrlMoveOut, CtrlDivider] 
  IF Walking THEN
    IF (CtrlMoveOut < (CtrlMoveInp - 4)) THEN
      CtrlMoveOut = CtrlMoveOut + ABS((CtrlMoveOut - CtrlMoveInp)/CtrlDivider)
    ELSEIF (CtrlMoveOut > (CtrlMoveInp + 4))
      CtrlMoveOut = CtrlMoveOut - ABS((CtrlMoveOut - CtrlMoveInp)/CtrlDivider)
    ELSE
      CtrlMoveOut = CtrlMoveInp
    ENDIF
  ELSE
    CtrlMoveOut = CtrlMoveInp
  ENDIF
  
return CtrlMoveOut

