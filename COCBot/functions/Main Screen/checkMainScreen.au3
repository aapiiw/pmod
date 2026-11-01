; #FUNCTION# ====================================================================================================================
; Name ..........: checkMainScreen
; Description ...: Checks whether the pixel, located in the eyes of the builder in mainscreen, is available
;						If it is not available, it calls checkObstacles and also waitMainScreen.
; Syntax ........: checkMainScreen([$bSetLog = True], [$bBuilderBase = False])
; Parameters ....: $bCheck: [optional] Sets a Message in Bot Log. Default is True  - $bBuilderBase: [optional] Use CheckMainScreen for Builder Base instead of normal Village. Default is False
; Return values .: None
; Author ........:
; Modified ......: KnowJack (07-2015) , TheMaster1st(2015), Fliegerfaust (06-2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: checkObstacles(), waitMainScreen()
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func checkMainScreen($bSetLog = Default, $bBuilderBase = $g_bStayOnBuilderBase, $CalledFrom = "Default") ;Checks if in main screen
	If Not $g_bRunState Then Return
	FuncEnter(checkMainScreen)
	Return FuncReturn(_checkMainScreen($bSetLog, $bBuilderBase, $CalledFrom))
EndFunc   ;==>checkMainScreen

Func _checkMainScreen($bSetLog = Default, $bBuilderBase = $g_bStayOnBuilderBase, $CalledFrom = "Default") ;Checks if in main screen
	
	If $bSetLog = Default Then $bSetLog = True
	If Not $g_bRunState Then Return
	If Not CheckAndroidRunning(False) Then Return
	If GetAndroidProcessPID() = 0 Then CloseCoC(True)
	
	If $bSetLog Then SetLog("[" & $CalledFrom & "] checkMainScreen", $COLOR_INFO)
	PlaceUnplacedBuilding()	
	
	Local $i = 0, $iErrorCount = 0, $iLoading = 0, $iCheckBeforeRestartAndroidCount = 5, $bObstacleResult, $bContinue = False, $bLocated = False
	$bLocated = $bBuilderBase ? isOnBuilderBase() : isOnMainVillage()
	If Not $bBuilderBase And Not $bLocated Then
		If _Sleep(500) Then Return
		If isOnBuilderBase() Then $bBuilderBase = True ;check if account is on builderbase but it should on main
	EndIf
	
	If Not $bLocated Then PlacedOnLeague()
	
	While Not $bLocated
		$i += 1
		If Not $g_bRunState Then Return
		
		SetDebugLog("checkMainScreen : " & ($bBuilderBase ? "BuilderBase" : "MainVillage"))
		$bLocated = $bBuilderBase ? isOnBuilderBase() : isOnMainVillage()
		If $bLocated Then ExitLoop
		
		If GetAndroidProcessPID() = 0 Then OpenCoC()
		If Not $g_bRunState Then Return
		;mainscreen not located, proceed to check if there is obstacle covering screen
		$bObstacleResult = checkObstacles($bBuilderBase)
		SetDebugLog("CheckObstacles[" & $i & "] Result = " & $bObstacleResult, $COLOR_DEBUG)
		
		$bContinue = False
		If Not $bObstacleResult And $i > 5 Then $bContinue = True ; 5 time no obstacle deteced but mainscreen not located, set continue true to proceed to waitMainScreen
		
		If $bObstacleResult Then ; obstacle found, set g_bRestart = true (go to mainloop)
			$g_bRestart = True
			$bContinue = True
		EndIf
		
		If Not $g_bRunState Then Return
		If $bContinue Then $bLocated = waitMainScreen() ;wait main screen due to slow loading
		If Not $g_bRunState Then Return
		If _Sleep(1000) Then Return
	WEnd
	
	If Not $g_bRunState Then Return

	If $bLocated Then
		SetLog("[" & $CalledFrom & "] Main Screen located", $COLOR_SUCCESS)
	Else
		SetLog("[" & $CalledFrom & "] Main Screen not located", $COLOR_ERROR)
	EndIf

	If $bLocated Then 
		; not before the first account switch: the game can be on another account than the profile (bot started on qath
		; with macia open 29 Oct: request and donate done for macia with the settings of qath)
		If Not (ProfileSwitchAccountEnabled() And $g_bInitiateSwitchAcc) And CheckDonateNotifCounter() Then
			$g_bDonateNewChat = True
			RequestCC()
		EndIf
		If _Sleep(1000) Then Return
		If $g_bStayOnBuilderBase <> $bBuilderBase Then SwitchBetweenBases("Main")
	EndIf
	
	NotifyPendingActions()
	
	Return $bLocated
EndFunc   ;==>_checkMainScreen

Func _checkMainScreenImage($aPixelToCheck)
	Local $bRet = False, $bBuilderInfo = False, $bChatTab = False
	If $g_iAndroidBackgroundMode = 2 Then $aPixelToCheck[0] += 1
	_CaptureRegion() ; one frame for all pixel checks
	$bChatTab = checkChatTabPixel(False)
	If @extended Then _CaptureRegion() ; chat window was just closed, take a new frame
	$bBuilderInfo = _CheckPixel($aPixelToCheck, False, Default, "_checkMainScreen")
	
	$bRet = $bChatTab And $bBuilderInfo
	If $g_bDebugSetLog Then SetLog("PixelToCheck = " & $aPixelToCheck[0] & "," & $aPixelToCheck[1] & " exp:" & Hex($aPixelToCheck[2], 6) & ", tolerance:" & $aPixelToCheck[3] , $COLOR_ACTION)
	If $g_bDebugSetLog Then SetLog("PixelCheck result : " & ($bRet ? "succeed" : "failed"), $COLOR_ACTION)
	
	If Not $bRet Then
		If QuickMIS("BC1", $g_sImgCCMap, 300, 10, 430, 40) Then
			SwitchToMainVillage()
		EndIf
	EndIf
	
	Return $bRet
EndFunc

; @extended = 1 when an open chat window was closed (screen changed)
Func checkChatTabPixel($bNeedCapture = True)
	Local $bRet = False, $bClicked = False
	If $bNeedCapture Then _CaptureRegion()
	
	If _ColorCheck(_GetPixelColor(55, 330, False), Hex(0xE84C0D, 6), 20, Default, "checkChatTabPixel") Then ;red color on badge on chat tab
		If $g_bDebugSetLog Then SetLog("checkChatTabPixel: Found ChatTab", $COLOR_ACTION)
		$bRet = True
	EndIf
	
	If Not $bRet Then 
		If _CheckPixel($aChatTab, False) Then
			SetDebugLog("checkChatTabPixel: Found Chat Tab to close", $COLOR_ACTION)
			PureClickP($aChatTab, 1, 0, "ChatTab")
			If _Sleep(500) Then Return
			$bRet = True
			$bClicked = True
		Else
			SetDebugLog("ChatTabPixel not found", $COLOR_ERROR)
		EndIf
	EndIf
	
	Return SetExtended($bClicked ? 1 : 0, $bRet)
EndFunc   ;==>checkChatTabPixel

Func isOnMainVillage()
	Local $bRet = False
	$bRet = _checkMainScreenImage($aIsMain)
	; the elixir icon sparkles: one pixel read FF2CFF / DD22E9 instead of FF41FF (Oct 2026), so check the icon area too
	; (frame of _checkMainScreenImage; chat tab must still be found)
	If Not $bRet And checkChatTabPixel(False) And IsMainElixirIcon() Then $bRet = True
	Return $bRet
EndFunc

; pink elixir icon of home village top right (x 834..848, y 46..60) in the last _CaptureRegion frame:
; home main screen 25+ pixels, builder base elixir (992EFC) and open windows 0 (tested on screenshots)
Func IsMainElixirIcon()
	Local $iHits = 0, $iPix
	For $x = 834 To 848 Step 2
		For $y = 46 To 60 Step 2
			$iPix = Dec(_GetPixelColor($x, $y, False))
			If BitAND(BitShift($iPix, 16), 0xFF) > 190 And BitAND($iPix, 0xFF) > 190 And BitAND(BitShift($iPix, 8), 0xFF) < 110 Then $iHits += 1
		Next
	Next
	Return $iHits >= 10
EndFunc   ;==>IsMainElixirIcon

Func isOnBuilderBase()
	Local $bRet = False
	$bRet = _checkMainScreenImage($aIsOnBuilderBase)
	Return $bRet
EndFunc

Func CheckDonateNotifCounter()
	Local $bRet = False
	If $g_bChkDonate Then 
		If _ColorCheck(_GetPixelColor(73, 317, True), Hex(0xCB1D36, 6), 20, Default, "Red Chat notif count") Then $bRet = True
		If $bRet Then SetLog("New chat detected!, Check for Donate", $COLOR_DEBUG)
	EndIf
	Return $bRet
EndFunc

Func KillAds($iAndroidPID = 0)
	;kill ads
	If $iAndroidPID = 0 Then $iAndroidPID = GetAndroidProcessPID()
	If $iAndroidPID <> 0 And $g_sAndroidEmulator = "MuMu" Then AndroidAdbSendShellCommand("am force-stop com.mumu.store", Default, Default, False)
EndFunc
