; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Control
; Description ...: This file Includes all functions to current GUI
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: GkevinOD (2014)
; Modified ......: Hervidero (2015), Boju (11-2016), MR.ViPER (11-2016), CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Func SetComboTroopComp()
	lblTotalCountTroop1()
	lblTotalCountSpell2()
	lblTotalCountSiege()
EndFunc   ;==>SetComboTroopComp

Func lblTotalCountTroop1()
	; Calculate count of troops, set progress bars, colors
	Local $TotalTroopsToTrain = 0
	Local $ArmyCampTemp = 0

	$ArmyCampTemp = Floor(GUICtrlRead($g_hTxtTotalCampForced) * GUICtrlRead($g_hTxtFullTroop) / 100)
	
	RemoveAllTmpTrain("Troop")
	Local $iTmpTroops = 0
	For $i = 0 To $eTroopCount - 1
		Local $iCount = GUICtrlRead($g_ahTxtTrainArmyTroopCount[$i])
		If $iCount > 0 Then
			$TotalTroopsToTrain += $iCount * $g_aiTroopSpace[$i]
			;;Set Troop Train Info
			If $iTmpTroops > UBound($g_ahPicTrainArmyTroopTmp) - 1 Then ContinueLoop
			_GUICtrlSetImage($g_ahPicTrainArmyTroopTmp[$iTmpTroops], $g_sLibIconPath, $g_aTroopsIcon[$i])
			GUICtrlSetState($g_ahPicTrainArmyTroopTmp[$iTmpTroops], $GUI_SHOW)
			GUICtrlSetData($g_ahLblTrainArmyTroopTmp[$iTmpTroops], $iCount)
			GUICtrlSetState($g_ahLblTrainArmyTroopTmp[$iTmpTroops], $GUI_SHOW)
			$iTmpTroops += 1
		EndIf
	Next

	GUICtrlSetData($g_hLblCountTotal, String($TotalTroopsToTrain))

	For $i = 0 To $eTroopCount - 1
		GUICtrlSetBkColor($g_ahTxtTrainArmyTroopCount[$i], $TotalTroopsToTrain <= GUICtrlRead($g_hTxtTotalCampForced) ? $COLOR_WHITE : $COLOR_ERROR)
	Next

	If GUICtrlRead($g_hLblCountTotal) = GUICtrlRead($g_hTxtTotalCampForced) Then
		GUICtrlSetBkColor($g_hLblCountTotal, $COLOR_LIGHTGREEN)
	ElseIf GUICtrlRead($g_hLblCountTotal) >= $ArmyCampTemp Then
		GUICtrlSetBkColor($g_hLblCountTotal, $COLOR_LIGHTGREEN)
	ElseIf GUICtrlRead($g_hLblCountTotal) > $ArmyCampTemp / 2 And GUICtrlRead($g_hLblCountTotal) < $ArmyCampTemp Then
		GUICtrlSetBkColor($g_hLblCountTotal, $COLOR_ORANGE)
	Else
		GUICtrlSetBkColor($g_hLblCountTotal, $COLOR_ERROR)
	EndIf

	Local $fPctOfForced = Floor((GUICtrlRead($g_hLblCountTotal) / GUICtrlRead($g_hTxtTotalCampForced)) * 100)
	Local $fPctOfCalculated = Floor((GUICtrlRead($g_hLblCountTotal) / $ArmyCampTemp) * 100)
	GUICtrlSetData($g_hCalTotalTroops, $fPctOfCalculated < 1 ? (GUICtrlRead($g_hLblCountTotal) > 0 ? 1 : 0) : $fPctOfCalculated)
EndFunc   ;==>lblTotalCountTroop1

Func lblTotalCountSpell2()
	; calculate total space and time for spell composition
	Local $iTotalTotalTimeSpell = 0
	$g_iTotalTrainSpaceSpell = 0

	RemoveAllTmpTrain("Spell")
	Local $iTmpSpells = 0
	For $i = 0 To $eSpellCount - 1
		Local $iCount = GUICtrlRead($g_ahTxtTrainArmySpellCount[$i])
		If $iCount > 0 Then
			$g_iTotalTrainSpaceSpell += $g_aiArmyCustomSpells[$i] * $g_aiSpellSpace[$i]

			;Set Spell Train Info
			If $iTmpSpells > UBound($g_ahPicTrainArmySpellTmp) - 1 Then ContinueLoop
			_GUICtrlSetImage($g_ahPicTrainArmySpellTmp[$iTmpSpells], $g_sLibIconPath, $g_aSpellsIcon[$i])
			GUICtrlSetState($g_ahPicTrainArmySpellTmp[$iTmpSpells], $GUI_SHOW)
			GUICtrlSetData($g_ahLblTrainArmySpellTmp[$iTmpSpells], $iCount)
			GUICtrlSetState($g_ahLblTrainArmySpellTmp[$iTmpSpells], $GUI_SHOW)
			$iTmpSpells += 1
		EndIf
	Next

	For $i = 0 To $eSpellCount - 1
		GUICtrlSetBkColor($g_ahTxtTrainArmySpellCount[$i], $g_iTotalTrainSpaceSpell <= Number(GUICtrlRead($g_hTxtTotalCountSpell)) ? $COLOR_WHITE : $COLOR_ERROR)
	Next

	GUICtrlSetBkColor($g_hLblCountTotalSpells, $g_iTotalTrainSpaceSpell <= Number(GUICtrlRead($g_hTxtTotalCountSpell)) ? $COLOR_LIGHTGREEN : $COLOR_ERROR)

	Local $iSpellProgress = Floor(($g_iTotalTrainSpaceSpell / Number(GUICtrlRead($g_hTxtTotalCountSpell))) * 100)
	If $iSpellProgress <= 100 Then
		GUICtrlSetData($g_hCalTotalSpells, $iSpellProgress)
		GUICtrlSetState($g_hCalTotalSpells, $GUI_SHOW)
	Else
		GUICtrlSetState($g_hCalTotalSpells, $GUI_HIDE)
	EndIf

	GUICtrlSetData($g_hLblCountTotalSpells, String($g_iTotalTrainSpaceSpell))
	GUICtrlSetData($g_hLblTotalTimeSpell, CalculTimeTo($iTotalTotalTimeSpell))
EndFunc   ;==>lblTotalCountSpell2

Func lblTotalCountSiege()
	; calculate total space and time for Siege composition
	Local $iTotalTotalTimeSiege = 0, $indexLevel = 0
	$g_iTotalTrainSpaceSiege = 0
	RemoveAllTmpTrain("Siege")
	Local $iTmpSieges = 0
	For $i = 0 To $eSiegeMachineCount - 1

		Local $iCount = GUICtrlRead($g_ahTxtTrainArmySiegeCount[$i])
		If $iCount > 0 Then
			$g_iTotalTrainSpaceSiege += $g_aiArmyCustomSiegeMachines[$i] * $g_aiSiegeMachineSpace[$i]

			;Set Siege Train Info
			If $iTmpSieges > UBound($g_ahPicTrainArmySiegeTmp) - 1 Then ContinueLoop
			_GUICtrlSetImage($g_ahPicTrainArmySiegeTmp[$iTmpSieges], $g_sLibIconPath, $g_aSiegesIcon[$i])
			GUICtrlSetState($g_ahPicTrainArmySiegeTmp[$iTmpSieges], $GUI_SHOW)
			GUICtrlSetData($g_ahLblTrainArmySiegeTmp[$iTmpSieges], $iCount)
			GUICtrlSetState($g_ahLblTrainArmySiegeTmp[$iTmpSieges], $GUI_SHOW)
			$iTmpSieges += 1
		EndIf
	Next

	GUICtrlSetData($g_hLblCountTotalSiege, $g_iTotalTrainSpaceSiege)
	GUICtrlSetBkColor($g_hLblCountTotalSiege, $g_iTotalTrainSpaceSiege <= 3 ? $COLOR_LIGHTGREEN : $COLOR_ERROR)
	For $i = 0 To $eSiegeMachineCount - 1
		If ($g_iTotalTrainSpaceSiege <= 3) Then
			GUICtrlSetBkColor($g_ahTxtTrainArmySiegeCount[$i], $COLOR_WHITE)
		Else
			GUICtrlSetBkColor($g_ahTxtTrainArmySiegeCount[$i], $COLOR_ERROR)
		EndIf
	Next
EndFunc   ;==>lblTotalCountSiege

Func TotalSpellCountClick()
	Local $bWasRedraw = SetRedrawBotWindow(False, Default, Default, Default, "TotalSpellCountClick")
	_GUI_Value_STATE("DISABLE", $groupListSpells)
	$g_iTownHallLevel = Int($g_iTownHallLevel)

	If $g_iTownHallLevel > 4 Or $g_iTownHallLevel = 0 Then
		_GUI_Value_STATE("ENABLE", $groupLightning)
	Else
		For $i = 0 To $eSpellCount - 1
			GUICtrlSetData($g_ahTxtTrainArmySpellCount[$i], 0)
		Next
		GUICtrlSetData($g_hTxtTotalCountSpell, 0)
	EndIf

	If $g_iTownHallLevel > 5 Or $g_iTownHallLevel = 0 Then
		_GUI_Value_STATE("ENABLE", $groupHeal)
	Else
		For $i = $eSpellRage To $eSpellBat
			GUICtrlSetData($g_ahTxtTrainArmySpellCount[$i], 0)
		Next
	EndIf

	If $g_iTownHallLevel > 6 Or $g_iTownHallLevel = 0 Then
		_GUI_Value_STATE("ENABLE", $groupRage)
	Else
		For $i = $eSpellJump To $eSpellBat
			GUICtrlSetData($g_ahTxtTrainArmySpellCount[$i], 0)
		Next
	EndIf

	If $g_iTownHallLevel > 7 Or $g_iTownHallLevel = 0 Then
		_GUI_Value_STATE("ENABLE", $groupPoison)
		_GUI_Value_STATE("ENABLE", $groupEarthquake)
	Else
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellJump], 0)
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellFreeze], 0)
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellClone], 0)
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellInvisibility], 0)
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellHaste], 0)
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellSkeleton], 0)
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellBat], 0)
	EndIf

	If $g_iTownHallLevel > 8 Or $g_iTownHallLevel = 0 Then
		_GUI_Value_STATE("ENABLE", $groupJump)
		_GUI_Value_STATE("ENABLE", $groupFreeze)
		_GUI_Value_STATE("ENABLE", $groupHaste)
		_GUI_Value_STATE("ENABLE", $groupSkeleton)
	Else
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellClone], 0)
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellBat], 0)
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellInvisibility], 0)
	EndIf

	If $g_iTownHallLevel > 9 Or $g_iTownHallLevel = 0 Then
		_GUI_Value_STATE("ENABLE", $groupClone)
		_GUI_Value_STATE("ENABLE", $groupBat)
	Else
		GUICtrlSetData($g_ahTxtTrainArmySpellCount[$eSpellInvisibility], 0)
	EndIf

	If $g_iTownHallLevel > 10 Or $g_iTownHallLevel = 0 Then
		_GUI_Value_STATE("ENABLE", $groupInvisibility)
	EndIf

	lblTotalCountSpell2()
	SetRedrawBotWindow($bWasRedraw, Default, Default, Default, "TotalSpellCountClick")
EndFunc   ;==>TotalSpellCountClick

Func sldTrainITDelay()
	$g_iTrainClickDelay = GUICtrlRead($g_hSldTrainITDelay)
	GUICtrlSetData($g_hLblTrainITDelayTime, $g_iTrainClickDelay & " ms")
EndFunc   ;==>sldTrainITDelay

Func CalculTimeTo($TotalTotalTime)
	Local $HourToTrain = 0
	Local $MinToTrain = 0
	Local $SecToTrain = 0
	Local $TotalTotalTimeTo
	If $TotalTotalTime >= 3600 Then
		$HourToTrain = Int($TotalTotalTime / 3600)
		$MinToTrain = Int(($TotalTotalTime - $HourToTrain * 3600) / 60)
		$SecToTrain = $TotalTotalTime - $HourToTrain * 3600 - $MinToTrain * 60
		$TotalTotalTimeTo = " " & $HourToTrain & "h " & $MinToTrain & "m " & $SecToTrain & "s"
	ElseIf $TotalTotalTime < 3600 And $TotalTotalTime >= 60 Then
		$MinToTrain = Int(($TotalTotalTime - $HourToTrain * 3600) / 60)
		$SecToTrain = $TotalTotalTime - $HourToTrain * 3600 - $MinToTrain * 60
		$TotalTotalTimeTo = " " & $MinToTrain & "m " & $SecToTrain & "s"
	Else
		$SecToTrain = $TotalTotalTime
		$TotalTotalTimeTo = " " & $SecToTrain & "s"
	EndIf
	Return $TotalTotalTimeTo
EndFunc   ;==>CalculTimeTo

Func TrainTroopCountEdit()
	For $i = 0 To $eTroopCount - 1
		If @GUI_CtrlId = $g_ahTxtTrainArmyTroopCount[$i] Then
			$g_aiArmyCustomTroops[$i] = GUICtrlRead($g_ahTxtTrainArmyTroopCount[$i])
			lblTotalCountTroop1()
			Return
		EndIf
	Next
EndFunc   ;==>TrainTroopCountEdit

Func TrainSpellCountEdit()
	For $i = 0 To $eSpellCount - 1
		If @GUI_CtrlId = $g_ahTxtTrainArmySpellCount[$i] Then
			$g_aiArmyCustomSpells[$i] = GUICtrlRead($g_ahTxtTrainArmySpellCount[$i])
			lblTotalCountSpell2()
			Return
		EndIf
	Next
EndFunc   ;==>TrainSpellCountEdit

Func TrainSiegeCountEdit()
	For $i = 0 To $eSiegeMachineCount - 1
		If @GUI_CtrlId = $g_ahTxtTrainArmySiegeCount[$i] Then
			$g_aiArmyCustomSiegeMachines[$i] = GUICtrlRead($g_ahTxtTrainArmySiegeCount[$i])
			lblTotalCountSiege()
			Return
		EndIf
	Next
EndFunc   ;==>TrainSiegeCountEdit

Func chkAddDelayIdlePhaseEnable()
	$g_bTrainAddRandomDelayEnable = (GUICtrlRead($g_hChkTrainAddRandomDelayEnable) = $GUI_CHECKED)
	For $i = $g_hLblAddDelayIdlePhaseBetween To $g_hLblAddDelayIdlePhaseSec
		GUICtrlSetState($i, $g_bTrainAddRandomDelayEnable ? $GUI_ENABLE : $GUI_DISABLE)
	Next
EndFunc   ;==>chkAddDelayIdlePhaseEnable

Func chkSuperTroops()
	If GUICtrlRead($g_hChkSuperTroops) = $GUI_CHECKED Then
		$g_bSuperTroopsEnable = True
		GUICtrlSetState($g_hChkSkipBoostSuperTroopOnHalt, $GUI_ENABLE)
		GUICtrlSetState($g_hChkUsePotion, $GUI_ENABLE)
		For $i = 0 To $iMaxSupersTroop - 1
			GUICtrlSetState($g_ahLblSuperTroops[$i], $GUI_ENABLE)
			GUICtrlSetState($g_ahCmbSuperTroops[$i], $GUI_ENABLE)
			GUICtrlSetState($g_ahPicSuperTroops[$i], $GUI_SHOW)
			_GUICtrlSetImage($g_ahPicSuperTroops[$i], $g_sLibIconPath, $g_aSuperTroopsIcons[$g_iCmbSuperTroops[$i]])
		Next
	Else
		$g_bSuperTroopsEnable = False
		GUICtrlSetState($g_hChkSkipBoostSuperTroopOnHalt, $GUI_DISABLE)
		GUICtrlSetState($g_hChkUsePotion, $GUI_DISABLE)
		For $i = 0 To $iMaxSupersTroop - 1
			GUICtrlSetState($g_ahLblSuperTroops[$i], $GUI_DISABLE)
			GUICtrlSetState($g_ahCmbSuperTroops[$i], $GUI_DISABLE)
			GUICtrlSetState($g_ahPicSuperTroops[$i], $GUI_HIDE)
			_GUICtrlSetImage($g_ahPicSuperTroops[$i], $g_sLibIconPath, $g_aSuperTroopsIcons[$g_iCmbSuperTroops[$i]])
		Next
	EndIf
	If GUICtrlRead($g_hChkSkipBoostSuperTroopOnHalt) = $GUI_CHECKED Then
		$g_bSkipBoostSuperTroopOnHalt = True
	Else
		$g_bSkipBoostSuperTroopOnHalt = False
	EndIf
	If GUICtrlRead($g_hChkUsePotion) = $GUI_CHECKED Then
		$g_bSuperTroopsBoostUsePotion = True
	Else
		$g_bSuperTroopsBoostUsePotion = False
	EndIf
EndFunc

Func cmbSuperTroops()
	For $i = 0 To $iMaxSupersTroop - 1
		$g_iCmbSuperTroops[$i] = _GUICtrlComboBox_GetCurSel($g_ahCmbSuperTroops[$i])
		_GUICtrlSetImage($g_ahPicSuperTroops[$i], $g_sLibIconPath, $g_aSuperTroopsIcons[$g_iCmbSuperTroops[$i]])
		For $j = 0 To $iMaxSupersTroop - 1
			If $i = $j Then ContinueLoop
			If $g_iCmbSuperTroops[$i] <> 0 And $g_iCmbSuperTroops[$i] = $g_iCmbSuperTroops[$j] Then
				_GUICtrlComboBox_SetCurSel($g_ahCmbSuperTroops[$j], 0)
				_GUICtrlSetImage($g_ahImgTroopOrder[$j], $g_sLibIconPath, $eIcnOptions)
			EndIf
		Next
	Next
 EndFunc

Func ChkPreciseArmy()
	If GUICtrlRead($g_hChkPreciseArmy) = $GUI_CHECKED Then
		$g_bPreciseArmy = True
	Else
		$g_bPreciseArmy = False
	EndIf
EndFunc ;==>ChkPreciseArmy

Func RemoveAllTmpTrain($sWhat = "All")
	If $sWhat = "All" Or $sWhat = "Troop" Then
		For $i = 0 To UBound($g_ahPicTrainArmyTroopTmp) - 1
			GUICtrlSetState($g_ahPicTrainArmyTroopTmp[$i], $GUI_HIDE)
			GUICtrlSetState($g_ahLblTrainArmyTroopTmp[$i], $GUI_HIDE)
		Next
	EndIf

	If $sWhat = "All" Or $sWhat = "Spell" Then
		For $i = 0 To UBound($g_ahPicTrainArmySpellTmp) - 1
			GUICtrlSetState($g_ahPicTrainArmySpellTmp[$i], $GUI_HIDE)
			GUICtrlSetState($g_ahLblTrainArmySpellTmp[$i], $GUI_HIDE)
		Next
	EndIf

	If $sWhat = "All" Or $sWhat = "Siege" Then
		For $i = 0 To UBound($g_ahPicTrainArmySiegeTmp) - 1
			GUICtrlSetState($g_ahPicTrainArmySiegeTmp[$i], $GUI_HIDE)
			GUICtrlSetState($g_ahLblTrainArmySiegeTmp[$i], $GUI_HIDE)
		Next
	EndIf
EndFunc

Func HideAllTroops()
	For $i = $g_ahPicTrainArmyTroop[$eTroopMinion] To $g_ahPicTrainArmyTroop[$eTroopAppWard]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahTxtTrainArmyTroopCount[$eTroopMinion] To $g_ahTxtTrainArmyTroopCount[$eTroopAppWard]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahPicTrainArmyTroop[$eTroopBarbarian] To $g_ahPicTrainArmyTroop[$eTroopRootRider]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahTxtTrainArmyTroopCount[$eTroopBarbarian] To $g_ahTxtTrainArmyTroopCount[$eTroopRootRider]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahPicTrainArmyTroop[$eTroopSuperBarbarian] To $g_ahPicTrainArmyTroop[$eTroopSuperHogRider]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahTxtTrainArmyTroopCount[$eTroopSuperBarbarian] To $g_ahTxtTrainArmyTroopCount[$eTroopSuperHogRider]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahPicTrainArmySpell[$eSpellLightning] To $g_ahPicTrainArmySpell[$eSpellOverGrowth]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahTxtTrainArmySpellCount[$eSpellLightning] To $g_ahTxtTrainArmySpellCount[$eSpellOverGrowth]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahPicTrainArmySiege[$eSiegeWallWrecker] To $g_ahPicTrainArmySiege[$eSiegeBattleDrill]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahTxtTrainArmySiegeCount[$eSiegeWallWrecker] To $g_ahTxtTrainArmySiegeCount[$eSiegeBattleDrill]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahPicTrainArmyTroop[$eTroopGiantSkeleton] To $g_ahPicTrainArmyTroop[$eTroopIceWizard]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
	For $i = $g_ahTxtTrainArmyTroopCount[$eTroopGiantSkeleton] To $g_ahTxtTrainArmyTroopCount[$eTroopIceWizard]
		GUICtrlSetState($i, $GUI_HIDE)
	Next
EndFunc

Func SetBtnSelector($sType = "All")
	For $i = $g_hBtnElixirTroops To $g_hBtnEventTroops
		GUICtrlSetBkColor($i, $COLOR_BLACK)
		GUICtrlSetColor($i, $COLOR_WHITE)
	Next
	Switch $sType
		Case "ElixirTroops"
			GUICtrlSetColor($g_hBtnElixirTroops, $COLOR_YELLOW)
		Case "DarkElixirTroops"
			GUICtrlSetColor($g_hBtnDarkElixirTroops, $COLOR_YELLOW)
		Case "SuperTroops"
			GUICtrlSetColor($g_hBtnSuperTroops, $COLOR_YELLOW)
		Case "Spells"
			GUICtrlSetColor($g_hBtnSpells, $COLOR_YELLOW)
		Case "Sieges"
			GUICtrlSetColor($g_hBtnSieges, $COLOR_YELLOW)
		Case "EventTroops"
			GUICtrlSetColor($g_hBtnEventTroops, $COLOR_YELLOW)
	EndSwitch
EndFunc

Func BtnElixirTroops()
	HideAllTroops()
	For $i = $g_ahPicTrainArmyTroop[$eTroopBarbarian] To $g_ahPicTrainArmyTroop[$eTroopRootRider]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	For $i = $g_ahTxtTrainArmyTroopCount[$eTroopBarbarian] To $g_ahTxtTrainArmyTroopCount[$eTroopRootRider]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	SetBtnSelector("ElixirTroops")
EndFunc

Func BtnDarkElixirTroops()
	HideAllTroops()
	For $i = $g_ahPicTrainArmyTroop[$eTroopMinion] To $g_ahPicTrainArmyTroop[$eTroopAppWard]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	For $i = $g_ahTxtTrainArmyTroopCount[$eTroopMinion] To $g_ahTxtTrainArmyTroopCount[$eTroopAppWard]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	SetBtnSelector("DarkElixirTroops")
EndFunc

Func BtnSuperTroops()
	HideAllTroops()
	For $i = $g_ahPicTrainArmyTroop[$eTroopSuperBarbarian] To $g_ahPicTrainArmyTroop[$eTroopSuperHogRider]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	For $i = $g_ahTxtTrainArmyTroopCount[$eTroopSuperBarbarian] To $g_ahTxtTrainArmyTroopCount[$eTroopSuperHogRider]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	SetBtnSelector("SuperTroops")
EndFunc

Func BtnSpells()
	HideAllTroops()
	For $i = $g_ahPicTrainArmySpell[$eSpellLightning] To $g_ahPicTrainArmySpell[$eSpellOverGrowth]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	For $i = $g_ahTxtTrainArmySpellCount[$eSpellLightning] To $g_ahTxtTrainArmySpellCount[$eSpellOverGrowth]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	SetBtnSelector("Spells")
EndFunc

Func BtnSieges()
	HideAllTroops()
	For $i = $g_ahPicTrainArmySiege[$eSiegeWallWrecker] To $g_ahPicTrainArmySiege[$eSiegeBattleDrill]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	For $i = $g_ahTxtTrainArmySiegeCount[$eSiegeWallWrecker] To $g_ahTxtTrainArmySiegeCount[$eSiegeBattleDrill]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	SetBtnSelector("Sieges")
EndFunc

Func BtnEventTroops()
	HideAllTroops()
	For $i = $g_ahPicTrainArmyTroop[$eTroopGiantSkeleton] To $g_ahPicTrainArmyTroop[$eTroopIceWizard]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	For $i = $g_ahTxtTrainArmyTroopCount[$eTroopGiantSkeleton] To $g_ahTxtTrainArmyTroopCount[$eTroopIceWizard]
		GUICtrlSetState($i, $GUI_SHOW)
	Next
	SetBtnSelector("EventTroops")
EndFunc