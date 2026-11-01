; #FUNCTION# ====================================================================================================================
; Name ..........: SpecialModes
; Description ...: Bottom buttons Direct / Rush / BBSpam / CCSpam.
;                  Direct = attack the base on screen now (found by hand), Rush = attack again and again (no donate, request,
;                  upgrades) until Halt Attack, BBSpam = Builder Base attacks until both BB storages are full,
;                  CCSpam = DonateCC every CC Spam Min..Max seconds. Rush / BBSpam / CCSpam run inside runBot (one at a time).
; ===============================================================================================================================

; called at the top of the runBot loop: True = a special mode ran (runBot starts its loop again)
Func SpecialModeCycle()
	If $g_bRushAttackEnabled Then
		RushAttackCycle()
	ElseIf $g_bBBSpamEnabled Then
		BBSpamCycle()
	ElseIf $g_bCCSpamEnabled Then
		CCSpamCycle()
	Else
		Return False
	EndIf
	; mode ended (clicked off or done): back to the normal account rotation, else the bot stays on this account
	If $g_bRunState And ProfileSwitchAccountEnabled() Then checkSwitchAcc()
	Return True
EndFunc   ;==>SpecialModeCycle

Func RushAttackCycle()
	SetLog("» RUSH ATTACK «", $COLOR_INFO)
	Local $iAttack = 0
	While $g_bRushAttackEnabled And $g_bRunState
		$g_bRestart = False
		checkMainScreen(False, False, "RushAttack")
		VillageReport()
		If BotCommand() Or $g_bMeetCondStop Then
			DisableSpecialMode("Halt Attack condition reached")
			ExitLoop
		EndIf
		If Not $g_bRunState Or Not $g_bRushAttackEnabled Then ExitLoop
		$iAttack += 1
		SetLog("Rush Attack #" & $iAttack, $COLOR_ACTION)
		AttackMain()
		If _Sleep($DELAYRUNBOT3) Then ExitLoop
	WEnd
EndFunc   ;==>RushAttackCycle

Func BBSpamCycle()
	SetLog("» BB SPAM «", $COLOR_INFO)
	If Not SwitchBetweenBases("BB") Then
		SetLog("BB Spam: Builder Base not opened", $COLOR_ERROR)
		Return
	EndIf
	$g_bStayOnBuilderBase = True
	While $g_bBBSpamEnabled And $g_bRunState
		checkMainScreen(False, True, "BBSpam")
		CollectBuilderBase()
		BuilderBaseReport(False, False)
		If isGoldFullBB() And isElixirFullBB() Then
			DisableSpecialMode("Builder Base storages are full")
			ExitLoop
		EndIf
		If Not PrepareAttackBB() Then
			SetLog("BB Spam: no attack possible now, wait 60 s", $COLOR_INFO)
			If _SleepStatus(60000) Then ExitLoop
			ContinueLoop
		EndIf
		_AttackBB()
		If _Sleep(2000) Then ExitLoop
	WEnd
	$g_bStayOnBuilderBase = False
	If $g_bRunState Then SwitchBetweenBases("Main")
EndFunc   ;==>BBSpamCycle

Func CCSpamCycle()
	SetLog("» CC SPAM «", $COLOR_INFO)
	If Not $g_bChkDonate Then
		DisableSpecialMode("Donate is off in the settings")
		Return
	EndIf
	While $g_bCCSpamEnabled And $g_bRunState
		checkMainScreen(False, False, "CCSpam")
		DonateCC()
		If Not $g_bRunState Or $g_bRestart Then ExitLoop
		checkMainScreen(False, False, "CCSpam")
		Local $iWait = Random(_Min($g_iCCSpamDelayMin, $g_iCCSpamDelayMax), _Max($g_iCCSpamDelayMin, $g_iCCSpamDelayMax), 1)
		SetLog("CC Spam: next donate check in " & $iWait & " s", $COLOR_INFO)
		Local $hWait = __TimerInit()
		While __TimerDiff($hWait) < $iWait * 1000
			If Not $g_bCCSpamEnabled Or Not $g_bRunState Then ExitLoop 2
			If _Sleep(1000) Then ExitLoop 2
		WEnd
	WEnd
EndFunc   ;==>CCSpamCycle

; Direct: attack the village on screen with the Direct Attack mode (Dead Base / Live Base settings), back home after the battle
Func DirectAttack()
	If $g_bDirectAttackRunning Then Return
	If $g_bRunState Then
		SetLog("Direct Attack: stop the bot first (it attacks the village on screen)", $COLOR_ERROR)
		Return
	EndIf
	If Not IsAttackPage() Then
		SetLog("Direct Attack: open a village to attack first (Search Mode or by hand)", $COLOR_ERROR)
		Return
	EndIf
	Local $bRunState = $g_bRunState
	$g_bDirectAttackRunning = True
	GUICtrlSetBkColor($g_hBtnDirectAttack, 0x90EE90)
	$g_iMatchMode = ($g_iDirectAttackMode = 0) ? $DB : $LB
	$g_bRunState = True
	SetLog("» DIRECT ATTACK (" & $g_asModeText[$g_iMatchMode] & ") «", $COLOR_INFO)
	PrepareAttack($g_iMatchMode)
	If $g_bRunState Then Attack()
	If $g_bRunState Then ReturnHome(False)
	$g_bRunState = $bRunState
	$g_bDirectAttackRunning = False
	SpecialModeButtonColor($g_hBtnDirectAttack, False)
	SetLog("» DIRECT ATTACK DONE «", $COLOR_SUCCESS)
EndFunc   ;==>DirectAttack

Func ToggleRushAttack()
	ToggleSpecialMode(0)
EndFunc   ;==>ToggleRushAttack

Func ToggleBBSpam()
	ToggleSpecialMode(1)
EndFunc   ;==>ToggleBBSpam

Func ToggleCCSpam()
	ToggleSpecialMode(2)
EndFunc   ;==>ToggleCCSpam

; $iMode 0 Rush, 1 BBSpam, 2 CCSpam: on = the other two off, bot started when it is stopped
Func ToggleSpecialMode($iMode)
	Local $abOn[3] = [$g_bRushAttackEnabled, $g_bBBSpamEnabled, $g_bCCSpamEnabled], $asName[3] = ["RUSH ATTACK", "BB SPAM", "CC SPAM"]
	Local $bOn = Not $abOn[$iMode]
	$g_bRushAttackEnabled = ($bOn And $iMode = 0)
	$g_bBBSpamEnabled = ($bOn And $iMode = 1)
	$g_bCCSpamEnabled = ($bOn And $iMode = 2)
	SpecialModeButtons()
	SetLog("» " & $asName[$iMode] & " MODE " & ($bOn ? "ON" : "OFF") & " «", $COLOR_INFO)
	If $bOn And Not $g_bRunState Then btnStart()
EndFunc   ;==>ToggleSpecialMode

Func DisableSpecialMode($sReason)
	$g_bRushAttackEnabled = False
	$g_bBBSpamEnabled = False
	$g_bCCSpamEnabled = False
	SpecialModeButtons()
	SetLog("» Special mode OFF: " & $sReason & " «", $COLOR_INFO)
EndFunc   ;==>DisableSpecialMode

; on = green, off = default button color (like the other buttons)
Func SpecialModeButtons()
	SpecialModeButtonColor($g_hBtnRushAttack, $g_bRushAttackEnabled)
	SpecialModeButtonColor($g_hBtnBBSpam, $g_bBBSpamEnabled)
	SpecialModeButtonColor($g_hBtnCCSpam, $g_bCCSpamEnabled)
EndFunc   ;==>SpecialModeButtons

Func SpecialModeButtonColor($hBtn, $bOn)
	If $bOn Then
		GUICtrlSetBkColor($hBtn, 0x90EE90)
	Else
		GUICtrlSetBkColor($hBtn, $GUI_BKCOLOR_DEFAULT)
	EndIf
EndFunc   ;==>SpecialModeButtonColor
