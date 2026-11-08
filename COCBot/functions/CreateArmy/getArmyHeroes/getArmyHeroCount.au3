; #FUNCTION# ====================================================================================================================
; Name ..........: getArmyHeroCount
; Description ...: Obtains count of heroes available from Training - Army Overview window
; Syntax ........: getArmyHeroCount()
; Parameters ....: $bOpenArmyWindow  = Bool value true if train overview window needs to be opened
;				 : $bCloseArmyWindow = Bool value, true if train overview window needs to be closed
; Return values .: None
; Author ........:
; Modified ......: MonkeyHunter (06-2016), MR.ViPER (10-2016), Fliegerfaust (03-2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func getArmyHeroCount($bOpenArmyWindow = False, $bCloseArmyWindow = False, $CheckWindow = True, $bSetLog = True)

	If $g_bDebugSetlogTrain Or $g_bDebugSetlog Then SetLog("Begin getArmyHeroCount:", $COLOR_DEBUG)

	If $CheckWindow Then
		If Not $bOpenArmyWindow And Not IsTrainPage() Then ; check for train page
			SetError(1)
			Return ; not open, not requested to be open - error.
		ElseIf $bOpenArmyWindow Then
			If Not OpenArmyOverview("getArmyHeroCount()") Then
				SetError(2)
				Return ; not open, requested to be open - error.
			EndIf
			If _Sleep($DELAYCHECKARMYCAMP5) Then Return
		EndIf
	EndIf

	$g_iHeroAvailable = $eHeroNone ; Reset hero available data
	Local $iDebugArmyHeroCount = 0 ; local debug flag

	; Detection by OCR
	Local $sResult
	Local $sMessage = ""

	For $i = 0 To $eHeroCount - 1
		$sResult = ArmyHeroStatus($i)
		If $sResult <> "" Then ; we found something, figure out what?
			Select
				Case StringInStr($sResult, "king", $STR_NOCASESENSEBASIC)
					If $bSetLog Then SetLog(" - Barbarian King Available", $COLOR_SUCCESS)
					$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroKing)
					; unset King upgrading
					$g_iHeroUpgrading[0] = 0
					$g_iHeroUpgradingBit = BitAND($g_iHeroUpgradingBit, BitOr($eHeroQueen,$eHeroWarden,$eHeroChampion))
				Case StringInStr($sResult, "queen", $STR_NOCASESENSEBASIC)
					If $bSetLog Then SetLog(" - Archer Queen Available", $COLOR_SUCCESS)
					$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroQueen)
					; unset Queen upgrading
					$g_iHeroUpgrading[1] = 0
					$g_iHeroUpgradingBit = BitAND($g_iHeroUpgradingBit, BitOr($eHeroKing,$eHeroWarden,$eHeroChampion))
				Case StringInStr($sResult, "warden", $STR_NOCASESENSEBASIC)
					If $bSetLog Then SetLog(" - Grand Warden Available", $COLOR_SUCCESS)
					$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroWarden)
					; unset Warden upgrading
					$g_iHeroUpgrading[2] = 0
					$g_iHeroUpgradingBit = BitAND($g_iHeroUpgradingBit, BitOr($eHeroKing,$eHeroQueen,$eHeroChampion))
				Case StringInStr($sResult, "champion", $STR_NOCASESENSEBASIC)
					If $bSetLog Then SetLog(" - Royal Champion Available", $COLOR_SUCCESS)
					$g_iHeroAvailable = BitOR($g_iHeroAvailable, $eHeroChampion)
					; unset Champion upgrading
					$g_iHeroUpgrading[3] = 0
					$g_iHeroUpgradingBit = BitAND($g_iHeroUpgradingBit, BitOr($eHeroKing,$eHeroQueen,$eHeroWarden))
				Case StringInStr($sResult, "heal", $STR_NOCASESENSEBASIC)
					If $g_bDebugSetlogTrain Or $iDebugArmyHeroCount = 1 Then
						Switch $i
							Case 0
								$sMessage = "-Barbarian King"
								; unset King upgrading
								$g_iHeroUpgrading[0] = 0
								$g_iHeroUpgradingBit = BitAND($g_iHeroUpgradingBit, BitOr($eHeroQueen,$eHeroWarden,$eHeroChampion))
							Case 1
								$sMessage = "-Archer Queen"
								; unset Queen upgrading
								$g_iHeroUpgrading[1] = 0
								$g_iHeroUpgradingBit = BitAND($g_iHeroUpgradingBit, BitOr($eHeroKing,$eHeroWarden,$eHeroChampion))
							Case 2
								$sMessage = "-Grand Warden"
								; unset Warden upgrading
								$g_iHeroUpgrading[2] = 0
								$g_iHeroUpgradingBit = BitAND($g_iHeroUpgradingBit, BitOr($eHeroKing,$eHeroQueen,$eHeroChampion))
							Case 3
								$sMessage = "-Royal Champion"
								; unset Champion upgrading
								$g_iHeroUpgrading[3] = 0
								$g_iHeroUpgradingBit = BitAND($g_iHeroUpgradingBit, BitOr($eHeroKing,$eHeroQueen,$eHeroWarden))
							Case Else
								$sMessage = "-Very Bad Monkey Needs"
						EndSwitch
						SetLog("Hero slot#" & $i + 1 & $sMessage & " Healing", $COLOR_DEBUG)
					EndIf
				Case StringInStr($sResult, "upgrade", $STR_NOCASESENSEBASIC)
					Switch $i
						Case 0
							$sMessage = "-Barbarian King"
							; set King upgrading
							;; safety code to warn user when wait for hero found while being upgraded to reduce stupid user posts for not attacking
							;If ($g_abAttackTypeEnable[$DB] And BitAND($g_aiAttackUseHeroes[$DB], $g_aiSearchHeroWaitEnable[$DB], $eHeroKing) = $eHeroKing) Or _
							;		($g_abAttackTypeEnable[$LB] And BitAND($g_aiAttackUseHeroes[$LB], $g_aiSearchHeroWaitEnable[$LB], $eHeroKing) = $eHeroKing) Then ; check wait for hero status
						Case 1
							$sMessage = "-Archer Queen"
							; set Queen upgrading
							;; safety code
							;If ($g_abAttackTypeEnable[$DB] And BitAND($g_aiAttackUseHeroes[$DB], $g_aiSearchHeroWaitEnable[$DB], $eHeroQueen) = $eHeroQueen) Or _
							;		($g_abAttackTypeEnable[$LB] And BitAND($g_aiAttackUseHeroes[$LB], $g_aiSearchHeroWaitEnable[$LB], $eHeroQueen) = $eHeroQueen) Then
						Case 2
							$sMessage = "-Grand Warden"
							; set Warden upgrading
							;; safety code
							;If ($g_abAttackTypeEnable[$DB] And BitAND($g_aiAttackUseHeroes[$DB], $g_aiSearchHeroWaitEnable[$DB], $eHeroWarden) = $eHeroWarden) Or _
							;		($g_abAttackTypeEnable[$LB] And BitAND($g_aiAttackUseHeroes[$LB], $g_aiSearchHeroWaitEnable[$LB], $eHeroWarden) = $eHeroWarden) Then
						Case 3
							$sMessage = "-Royal Champion"
							; set Champion upgrading
							;; safety code
							;If ($g_abAttackTypeEnable[$DB] And BitAND($g_aiAttackUseHeroes[$DB], $g_aiSearchHeroWaitEnable[$DB], $eHeroChampion) = $eHeroChampion) Or _
							;		($g_abAttackTypeEnable[$LB] And BitAND($g_aiAttackUseHeroes[$LB], $g_aiSearchHeroWaitEnable[$LB], $eHeroChampion) = $eHeroChampion) Then
						Case Else
							$sMessage = "-Need to Feed Code Monkey some bananas"
					EndSwitch
					If $g_bDebugSetlogTrain Or $iDebugArmyHeroCount = 1 Then SetLog("Hero slot#" & $i + 1 & $sMessage & " Upgrade in Process", $COLOR_DEBUG)
				Case StringInStr($sResult, "none", $STR_NOCASESENSEBASIC)
					If $g_bDebugSetlogTrain Or $iDebugArmyHeroCount = 1 Then SetLog("Hero slot#" & $i + 1 & " Empty, stop count", $COLOR_DEBUG)
						SetDebugLog("$g_iHeroAvailable = " & $g_iHeroAvailable, $COLOR_DEBUG)
						Switch $i
							Case 0
								$sMessage = "-Barbarian King"
								$g_iHeroAvailable += $eHeroKing
							Case 1
								$sMessage = "-Archer Queen"
								$g_iHeroAvailable += $eHeroQueen
							Case 2
								$sMessage = "-Grand Warden"
								$g_iHeroAvailable += $eHeroWarden
							Case 3
								$sMessage = "-Royal Champion"
								$g_iHeroAvailable += $eHeroChampion
							Case Else
								$sMessage = "-Very Bad Monkey Needs"
						EndSwitch
						SetDebugLog("Adding value to $g_iHeroAvailable, Now = " & $g_iHeroAvailable, $COLOR_DEBUG) ;we add available hero because its not unlocked yet
					ExitLoop ; when we find empty slots, done looking for heroes
				Case Else
					If $bSetLog Then SetLog("Hero slot#" & $i + 1 & " bad OCR string returned!", $COLOR_ERROR)
			EndSelect
		Else
			If $bSetLog Then SetLog("Hero slot#" & $i + 1 & " status read problem!", $COLOR_ERROR)
		EndIf
	Next

	If $g_bDebugSetlogTrain Or $iDebugArmyHeroCount = 1 Then SetLog("Hero Status  K|Q|W|C : " & BitAND($g_iHeroAvailable, $eHeroKing) & "|" & BitAND($g_iHeroAvailable, $eHeroQueen) & "|" & BitAND($g_iHeroAvailable, $eHeroWarden) & "|" & BitAND($g_iHeroAvailable, $eHeroChampion), $COLOR_DEBUG)
	If $g_bDebugSetlogTrain Or $iDebugArmyHeroCount = 1 Then SetLog("Hero Upgrade K|Q|W|C : " & BitAND($g_iHeroUpgradingBit, $eHeroKing) & "|" & BitAND($g_iHeroUpgradingBit, $eHeroQueen) & "|" & BitAND($g_iHeroUpgradingBit, $eHeroWarden) & "|" & BitAND($g_iHeroUpgradingBit, $eHeroChampion), $COLOR_DEBUG)

	If $bCloseArmyWindow Then
		ClickAway()
		If _Sleep($DELAYCHECKARMYCAMP4) Then Return
	EndIf

EndFunc   ;==>getArmyHeroCount

Func ArmyHeroStatus($i)
	Local $sResult = ""
	Local Const $aHeroesRect[$eHeroCount][4] = [[525, 322, 586, 395], [590, 322, 650, 395], [654, 322, 715, 395], [717, 322, 777, 395]] ; Review

	; Perform the search
	If QuickMIS("BC1", $g_sImgArmyOverviewHeroes, $aHeroesRect[$i][0], $aHeroesRect[$i][1], $aHeroesRect[$i][2], $aHeroesRect[$i][3]) Then
		$sResult = $g_sQuickMISName
		SetDebugLog($sResult)
		Select
			Case $i = 0
				Switch $sResult
					Case "heal" ; Blue
						GUICtrlSetState($g_hPicKingGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingGreen, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingBlue, $GUI_SHOW)
					Case "upgrade" ; Red
						GUICtrlSetState($g_hPicKingGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingGreen, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingBlue, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingRed, $GUI_SHOW)
					Case "king" ; Green
						GUICtrlSetState($g_hPicKingGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingBlue, $GUI_HIDE)
						GUICtrlSetState($g_hPicKingGreen, $GUI_SHOW)
				EndSwitch

			Case $i = 1
				Switch $sResult
					Case "heal" ; Blue
						GUICtrlSetState($g_hPicQueenGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenGreen, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenBlue, $GUI_SHOW)
					Case "upgrade" ; Red
						GUICtrlSetState($g_hPicQueenGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenGreen, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenBlue, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenRed, $GUI_SHOW)
					Case "queen" ; Green
						GUICtrlSetState($g_hPicQueenGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenBlue, $GUI_HIDE)
						GUICtrlSetState($g_hPicQueenGreen, $GUI_SHOW)
				EndSwitch

			Case $i = 2
				Switch $sResult
					Case "heal" ; Blue
						GUICtrlSetState($g_hPicWardenGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenGreen, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenBlue, $GUI_SHOW)
					Case "upgrade" ; Red
						GUICtrlSetState($g_hPicWardenGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenGreen, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenBlue, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenRed, $GUI_SHOW)
					Case "warden" ; Green
						GUICtrlSetState($g_hPicWardenGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenBlue, $GUI_HIDE)
						GUICtrlSetState($g_hPicWardenGreen, $GUI_SHOW)
				EndSwitch

			Case $i = 3
				Switch $sResult
					Case "heal" ; Blue
						GUICtrlSetState($g_hPicChampionGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionGreen, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionBlue, $GUI_SHOW)
					Case "upgrade" ; Red
						GUICtrlSetState($g_hPicChampionGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionGreen, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionBlue, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionRed, $GUI_SHOW)
					Case "Champion" ; Green
						GUICtrlSetState($g_hPicChampionGray, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionRed, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionBlue, $GUI_HIDE)
						GUICtrlSetState($g_hPicChampionGreen, $GUI_SHOW)
				EndSwitch
		EndSelect
		Return $sResult
	EndIf
	
	;return 'none' if there was a problem with the search ; or no Hero slot (bottom shields are set by HeroShieldSet)
	Return "none"

EndFunc   ;==>ArmyHeroStatus

; Bottom panel hero shields K Q P W C D: 0 gray (unknown), 1 green (ready), 2 red (upgrading), 3 blue (healing)
; set from the attack bar (heroes in it are ready) and from the Select Hero window (gray portrait = upgrading)
Global $g_aiHeroShieldAcc[16][6]

Func HeroShieldIndex($sHero)
	Select
		Case StringInStr($sHero, "King")
			Return 0
		Case StringInStr($sHero, "Queen")
			Return 1
		Case StringInStr($sHero, "Prince") Or StringInStr($sHero, "MinionP")
			Return 2
		Case StringInStr($sHero, "Warden")
			Return 3
		Case StringInStr($sHero, "Champion")
			Return 4
		Case StringInStr($sHero, "Duke")
			Return 5
	EndSelect
	Return -1
EndFunc   ;==>HeroShieldIndex

Func HeroShieldSet($sHero, $sState)
	Local $iHero = HeroShieldIndex($sHero)
	If $iHero < 0 Then Return
	HeroShieldShow($iHero, $sState = "green" ? 1 : ($sState = "red" ? 2 : ($sState = "blue" ? 3 : 0)))
EndFunc   ;==>HeroShieldSet

Func HeroShieldShow($iHero, $iState, $bStore = True)
	Local $aCtrl[6][4] = [[$g_hPicKingGray, $g_hPicKingGreen, $g_hPicKingRed, $g_hPicKingBlue], _
			[$g_hPicQueenGray, $g_hPicQueenGreen, $g_hPicQueenRed, $g_hPicQueenBlue], _
			[$g_hPicPrinceGray, $g_hPicPrinceGreen, $g_hPicPrinceRed, $g_hPicPrinceBlue], _
			[$g_hPicWardenGray, $g_hPicWardenGreen, $g_hPicWardenRed, $g_hPicWardenBlue], _
			[$g_hPicChampionGray, $g_hPicChampionGreen, $g_hPicChampionRed, $g_hPicChampionBlue], _
			[$g_hPicDukeGray, $g_hPicDukeGreen, $g_hPicDukeRed, $g_hPicDukeBlue]]
	For $i = 0 To 3
		GUICtrlSetState($aCtrl[$iHero][$i], $i = $iState ? $GUI_SHOW : $GUI_HIDE)
	Next
	If $bStore And $g_iCurAccount >= 0 And $g_iCurAccount < 16 Then $g_aiHeroShieldAcc[$g_iCurAccount][$iHero] = $iState
EndFunc   ;==>HeroShieldShow

; account switch: show the shields saved for this account
Func HeroShieldLoad($iAccount)
	If $iAccount < 0 Or $iAccount > 15 Then Return
	For $i = 0 To 5
		HeroShieldShow($i, $g_aiHeroShieldAcc[$iAccount][$i], False)
	Next
EndFunc   ;==>HeroShieldLoad
