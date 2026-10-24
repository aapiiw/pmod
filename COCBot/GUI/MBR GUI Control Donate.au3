; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Control Donate
; Description ...: This file Includes all functions to current GUI
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: MyBot.run team
; Modified ......: MonkeyHunter (07-2016), CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_aiDonIcons[$eTroopCount + 1] = [$eIcnDonBarbarian, $eIcnSuperBarbarian, $eIcnDonArcher, $eIcnSuperArcher, $eIcnDonGiant, $eIcnSuperGiant, $eIcnDonGoblin, $eIcnSneakyGoblin, _
							$eIcnDonWallBreaker, $eIcnSuperWallBreaker, $eIcnDonBalloon, $eIcnRocketBalloon, $eIcnDonWizard, $eIcnSuperWizard, _
							$eIcnDonHealer, $eIcnDonDragon, $eIcnSuperDragon, $eIcnDonPekka, $eIcnDonBabyDragon, _
							$eIcnInfernoDragon, $eIcnDonMiner, $eIcnElectroDragon, $eIcnYeti, $eIcnDragonRider, $eIcnElectroTitan, _
							$eIcnDonMinion, $eIcnSuperMinion, $eIcnDonHogRider, $eIcnDonValkyrie, $eIcnSuperValkyrie, $eIcnDonGolem, _
							$eIcnDonWitch, $eIcnSuperWitch, $eIcnDonLavaHound, $eIcnIceHound, $eIcnDonBowler, $eIcnSuperBowler, $eIcnIceGolem, $eIcnHeadhunter, $eIcnDonBlank]

Func chkRequestCC()
	If GUICtrlRead($g_hChkRequestTroopsEnable) = $GUI_CHECKED Then
		$g_bRequestTroopsEnable = True
		GUICtrlSetState($g_hTxtRequestCC, $GUI_ENABLE)
	Else
		$g_bRequestTroopsEnable = False
		GUICtrlSetState($g_hTxtRequestCC, $GUI_DISABLE)
	EndIf
EndFunc

Func chkReinforcementCake()
	If GUICtrlRead($g_hChkReinforcementCake) = $GUI_CHECKED Then
		$g_bUseCake = True
	Else
		$g_bUseCake = False
	EndIf
EndFunc

Func chkUpdateRequest()
	If  GUICtrlRead($g_hChkUpdateRequest) = $GUI_CHECKED Then
		$g_bChkUpdateRequest = True
		For $i = $g_hCmbRequestTroop1 To $g_hRequestSiegeQuantity2
			GUICtrlSetState($i, $GUI_ENABLE)
		Next
	Else
		$g_bChkUpdateRequest = False
		For $i = $g_hCmbRequestTroop1 To $g_hRequestSiegeQuantity2
			GUICtrlSetState($i, $GUI_DISABLE)
		Next
	EndIf
EndFunc

Func RequestQty()
	$g_iRequestTroopQuantity1 = GUICtrlRead($g_hRequestTroopQuantity1)
	$g_iRequestSpellQuantity1 = GUICtrlRead($g_hRequestSpellQuantity1)
	$g_iRequestSiegeQuantity1 = GUICtrlRead($g_hRequestSiegeQuantity1)
	$g_iRequestTroopQuantity2 = GUICtrlRead($g_hRequestTroopQuantity2)
	$g_iRequestSpellQuantity2 = GUICtrlRead($g_hRequestSpellQuantity2)
	$g_iRequestSiegeQuantity2 = GUICtrlRead($g_hRequestSiegeQuantity2)
	Local $iTroop1Space = $g_aCmbRequestTroop[_GUICtrlComboBox_GetCurSel($g_hCmbRequestTroop1)][2]
	Local $iTroop2Space = $g_aCmbRequestTroop[_GUICtrlComboBox_GetCurSel($g_hCmbRequestTroop2)][2]
	Local $iSpell1Space = $g_aCmbRequestSpell[_GUICtrlComboBox_GetCurSel($g_hCmbRequestSpell1)][2]
	Local $iSpell2Space = $g_aCmbRequestSpell[_GUICtrlComboBox_GetCurSel($g_hCmbRequestSpell2)][2]
	Local $iSiege1Space = $g_aCmbRequestSiege[_GUICtrlComboBox_GetCurSel($g_hCmbRequestSiege1)][2]
	Local $iSiege2Space = $g_aCmbRequestSiege[_GUICtrlComboBox_GetCurSel($g_hCmbRequestSiege2)][2]
	
	Local $iTroopCap = ($iTroop1Space * $g_iRequestTroopQuantity1) + ($iTroop2Space * $g_iRequestTroopQuantity2)
	Local $iSpellCap = ($iSpell1Space * $g_iRequestSpellQuantity1) + ($iSpell2Space * $g_iRequestSpellQuantity2)
	Local $iSiegeCap = ($iSiege1Space * $g_iRequestSiegeQuantity1) + ($iSiege2Space * $g_iRequestSiegeQuantity2)
	GUICtrlSetData($g_hLblRequestTroopCap, $iTroopCap)
	GUICtrlSetData($g_hLblRequestSpellCap, $iSpellCap)
	GUICtrlSetData($g_hLblRequestSiegeCap, $iSiegeCap)
EndFunc

Func btnDonateTroop()
	For $i = 0 To UBound($g_ahBtnDonateTroop) - 1
		If @GUI_CtrlId = $g_ahBtnDonateTroop[$i] Then
			If GUICtrlGetState($g_ahGrpDonateTroop[$i]) = BitOR($GUI_HIDE, $GUI_ENABLE) Then
				_DonateBtn($g_ahGrpDonateTroop[$i], $g_ahTxtDonateTroop[$i]) ;Hide/Show controls on Donate tab
			EndIf
			ExitLoop
		EndIf
	Next
EndFunc   ;==>btnDonateTroop

Func btnDonateSpell()
	For $i = 0 To UBound($g_ahBtnDonateSpell) - 1
		If @GUI_CtrlId = $g_ahBtnDonateSpell[$i] Then
			If GUICtrlGetState($g_ahGrpDonateSpell[$i]) = BitOR($GUI_HIDE, $GUI_ENABLE) Then
				_DonateBtn($g_ahGrpDonateSpell[$i], $g_ahTxtDonateSpell[$i])
			EndIf
			ExitLoop
		EndIf
	Next
EndFunc   ;==>btnDonateSpell

Func chkDonateTroop()
	For $i = 0 To UBound($g_ahChkDonateTroop) - 1
		If @GUI_CtrlId = $g_ahChkDonateTroop[$i] Then
			If GUICtrlRead($g_ahChkDonateTroop[$i]) = $GUI_CHECKED Then
				_DonateControls($i)
			Else
				GUICtrlSetBkColor($g_ahLblDonateTroop[$i], $GUI_BKCOLOR_TRANSPARENT)
			EndIf
		EndIf
	Next
EndFunc   ;==>chkDonateTroop

Func chkDonateSpell()
	For $i = 0 To UBound($g_ahChkDonateSpell) - 1
		If @GUI_CtrlId = $g_ahChkDonateSpell[$i] Then
			If GUICtrlRead($g_ahChkDonateSpell[$i]) = $GUI_CHECKED Then
				_DonateControlsSpell($i)
			Else
				GUICtrlSetBkColor($g_ahLblDonateSpell[$i], $GUI_BKCOLOR_TRANSPARENT)
			EndIf
		EndIf
	Next
EndFunc   ;==>chkDonateSpell

Func _DonateBtn($hFirstControl, $hLastControl)
    Static $hLastDonateBtn1 = -1, $hLastDonateBtn2 = -1

	; Hide Controls
	If $hLastDonateBtn1 = -1 Then
		For $i = $g_ahGrpDonateTroop[$eTroopBarbarian] To $g_ahTxtDonateTroop[$eTroopBarbarian] ; 1st time use: Hide Barbarian controls
			GUICtrlSetState($i, $GUI_HIDE)
		Next
	Else
		For $i = $hLastDonateBtn1 To $hLastDonateBtn2 ; Hide last used controls on Donate Tab
			GUICtrlSetState($i, $GUI_HIDE)
		Next
	EndIf

	$hLastDonateBtn1 = $hFirstControl
	$hLastDonateBtn2 = $hLastControl

	;Show Controls
	For $i = $hFirstControl To $hLastControl ; Show these controls on Donate Tab
		GUICtrlSetState($i, $GUI_SHOW)
	Next
EndFunc   ;==>_DonateBtn

Func _DonateControls($iTroopIndex)
	For $i = 0 To UBound($g_ahLblDonateTroop) - 1 ; troops, sieges and donate only troops
		If $i = $iTroopIndex Then
			GUICtrlSetBkColor($g_ahLblDonateTroop[$i], $COLOR_ORANGE)
		Else
			If GUICtrlGetBkColor($g_ahLblDonateTroop[$i]) = $COLOR_NAVY Then GUICtrlSetBkColor($g_ahLblDonateTroop[$i], $GUI_BKCOLOR_TRANSPARENT)
		EndIf
		
		If BitAND(GUICtrlGetState($g_ahTxtDonateTroop[$i]), $GUI_DISABLE) = $GUI_DISABLE Then GUICtrlSetState($g_ahTxtDonateTroop[$i], $GUI_ENABLE)
	Next
EndFunc   ;==>_DonateControls

Func _DonateControlsSpell($iSpellIndex)
	For $i = 0 To UBound($g_ahLblDonateSpell) - 1
		If $i = $iSpellIndex Then
			GUICtrlSetBkColor($g_ahLblDonateSpell[$i], $COLOR_ORANGE)
		Else
			If GUICtrlGetBkColor($g_ahLblDonateSpell[$i]) = $COLOR_NAVY Then GUICtrlSetBkColor($g_ahLblDonateSpell[$i], $GUI_BKCOLOR_TRANSPARENT)
	    EndIf
		
		If BitAND(GUICtrlGetState($g_ahTxtDonateSpell[$i]), $GUI_DISABLE) = $GUI_DISABLE Then GUICtrlSetState($g_ahTxtDonateSpell[$i], $GUI_ENABLE)
	Next
 EndFunc   ;==>_DonateControlsSpell

; drop down Troops / Spells / Sieges: show the icons of one category, each already at its slot
Func cmbDonateCategory()
	Local $iCat = _GUICtrlComboBox_GetCurSel($g_hCmbDonateCategory)
	If $iCat < 0 Then $iCat = 0
	For $c = 0 To UBound($g_aDonateCategory) - 1
		Local $aCat = $g_aDonateCategory[$c]
		If Not IsArray($aCat) Then ContinueLoop
		Local $iState = ($c = $iCat) ? $GUI_SHOW : $GUI_HIDE
		For $k = 0 To UBound($aCat) - 1
			Local $iIdx = $aCat[$k][1]
			Local $hBtn = $aCat[$k][0] ? $g_ahBtnDonateSpell[$iIdx] : $g_ahBtnDonateTroop[$iIdx]
			Local $hLbl = $aCat[$k][0] ? $g_ahLblDonateSpell[$iIdx] : $g_ahLblDonateTroop[$iIdx]
			GUICtrlSetState($hBtn, $iState)
			GUICtrlSetState($hLbl, $iState)
			If $c = $iCat Then GUICtrlSetState($hLbl, $GUI_DISABLE) ; the label is only the colored frame, clicks go to the button
		Next
	Next
EndFunc   ;==>cmbDonateCategory

; "All": donate every troop, spell and siege (keywords kept)
Func BtnAllSelected()
	For $i = 0 To UBound($g_ahChkDonateTroop) - 1
		If $g_ahChkDonateTroop[$i] = 0 Then ContinueLoop
		GUICtrlSetState($g_ahChkDonateTroop[$i], $GUI_CHECKED)
		GUICtrlSetBkColor($g_ahLblDonateTroop[$i], $COLOR_ORANGE)
	Next
	For $i = 0 To UBound($g_ahChkDonateSpell) - 1
		If $g_ahChkDonateSpell[$i] = 0 Then ContinueLoop
		GUICtrlSetState($g_ahChkDonateSpell[$i], $GUI_CHECKED)
		GUICtrlSetBkColor($g_ahLblDonateSpell[$i], $COLOR_ORANGE)
	Next
EndFunc   ;==>BtnAllSelected

; "Reset": donate nothing
Func BtnResetSelected()
	For $i = 0 To UBound($g_ahChkDonateTroop) - 1
		If $g_ahChkDonateTroop[$i] = 0 Then ContinueLoop
		GUICtrlSetState($g_ahChkDonateTroop[$i], $GUI_UNCHECKED)
		GUICtrlSetBkColor($g_ahLblDonateTroop[$i], $GUI_BKCOLOR_TRANSPARENT)
	Next
	For $i = 0 To UBound($g_ahChkDonateSpell) - 1
		If $g_ahChkDonateSpell[$i] = 0 Then ContinueLoop
		GUICtrlSetState($g_ahChkDonateSpell[$i], $GUI_UNCHECKED)
		GUICtrlSetBkColor($g_ahLblDonateSpell[$i], $GUI_BKCOLOR_TRANSPARENT)
	Next
EndFunc   ;==>BtnResetSelected

Func Doncheck()
	tabDONATE() ; just call tabDONATE()
EndFunc   ;==>Doncheck

