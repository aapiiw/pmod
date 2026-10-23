; #FUNCTION# ====================================================================================================================
; Name ..........: Laboratory
; Description ...:
; Syntax ........: Laboratory()
; Parameters ....:
; Return values .: None
; Author ........: summoner
; Modified ......: KnowJack (06/2015), Sardo (08/2015), Monkeyhunter(04/2016), MMHK(06/2018), Chilly-Chill (12/2019), xbenk (02/2021)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ==============================================================================================================================

Global $g_iXFindLabUpgrade = 560 ; left x of the upgrade name column in Lab window
Global Const $g_iLabMaxPages = 5 ; 59 research items, 12 per page

Func Laboratory($bDebug = False)
	If Not $g_bAutoLabUpgradeEnable Then Return ; Lab upgrade not enabled.
	If $bDebug Then $g_sLabUpgradeTime = ""
	If Not CheckIfLabIdle($bDebug) Then Return
	
 	; Get updated village elixir and dark elixir values
	VillageReport(True, True)
	
	If Not FindResearchButton(True) Then Return False ; cant start becuase we cannot find the research button
	If _Sleep(1500) Then Return
	
	; Lab upgrade is not in progress and not upgrading, so we need to start an upgrade.
	Local $iCurPage = 1, $iLabPicsPerPage = 12, $iLabMaxPages = $g_iLabMaxPages, $iPage = 0
	Local $sCost, $sCostType, $bUpgradeFound = False, $sReseachName = "", $sReseachImage = "", $aUpgrade
	Local $bNoResources = False
	Local $iLab = $g_iCmbLaboratory, $aCoords[2]
	
	If $iLab <> 0 Then ;user selected upgrade
		$iPage = Ceiling($iLab / $iLabPicsPerPage) ; page # of user choice
		$sReseachName = $g_avLabTroops[$iLab][0]
		$sReseachImage = $g_avLabTroops[$iLab][2]
		SetLog("Search " & $sReseachName & ", page:" & $iPage, $COLOR_DEBUG1)
		If $iLab < $g_iLabAnySpell And Not LabHasImage($iLab) Then
			SetLog("No image for " & $sReseachName & ", enable Lab Upgrade Order (Build menu OCR) to upgrade it", $COLOR_WARNING)
			ClickAway()
			Return False
		EndIf
		
		$iCurPage = LabGoToPage($iCurPage, $iPage)
		
		SetLog("FindImage : " & $sReseachName, $COLOR_INFO)
		$aUpgrade = FindLabUpgrade($sReseachImage)
		If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
			For $i = 0 To UBound($aUpgrade) - 1
				If $aUpgrade[$i][5] = $sReseachImage Then
					$aCoords[0] = $aUpgrade[$i][1] - 40
					$aCoords[1] = $aUpgrade[$i][2] - 40 
					$sCost = $aUpgrade[$i][3]
					$sCostType = $aUpgrade[$i][0]
					$sReseachName = $aUpgrade[$i][4]
					If Not IsLabUpgradeResourceEnough($sCost, $sCostType) Then
						$bNoResources = True
						SetLog($sReseachName & " Cost:" & $sCost & " " & $sCostType & ", Not Enough Resource", $COLOR_INFO)
					Else
						SetLog($sReseachName & " Cost:" & $sCost & " " & $sCostType, $COLOR_INFO)
						Return LaboratoryUpgrade($sReseachName, $aCoords, $sCost, $bDebug)
					EndIf
				EndIf
			Next
		Else
			SetLog("FindImage : No Image " & $sReseachName & " Found!", $COLOR_DEBUG1)
		EndIf 
	EndIf
	
	If $iLab = 0 Then
		$iPage = 1
		If $g_bLabUpgradeOrderEnable Then
			Local $iPrio = 0, $iIndex = 0
			For $z = 0 To UBound($g_aCmbLabUpgradeOrder) - 1 ; list of lab upgrade order
				$iPrio = $z + 1
				$iIndex = $g_aCmbLabUpgradeOrder[$z] + 1
				If $iIndex > 0 Then
					SetLog("Priority order [" & $iPrio & "] : " & $g_avLabTroops[$iIndex][0], $COLOR_SUCCESS)
				EndIf
			Next
			
			For $z = 0 To UBound($g_aCmbLabUpgradeOrder) - 1 ;try labupgrade based on order
				$iPrio = $z + 1
				$iIndex = $g_aCmbLabUpgradeOrder[$z] + 1
				
				If $iIndex > 0 Then
					Select 
						Case $iIndex < $g_iLabAnySpell ;Any Normal
							$sReseachName = $g_avLabTroops[$iIndex][0]
							$sReseachImage = $g_avLabTroops[$iIndex][2]
							If Not LabHasImage($iIndex) Then
								SetLog("No image for " & $sReseachName & ", skip (handled by Build menu OCR)", $COLOR_DEBUG1)
								ContinueLoop
							EndIf
							$iPage = Ceiling($iIndex / $iLabPicsPerPage) ; page # of user choice
							SetLog("Try Lab Upgrade: " & $sReseachName & ", Page:" & $iPage, $COLOR_INFO)
							$iCurPage = LabGoToPage($iCurPage, $iPage)
							
							SetLog("FindImage : " & $sReseachName, $COLOR_DEBUG1)
							$aUpgrade = FindLabUpgrade($sReseachImage)
							If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
								;For $i = 0 To UBound($aUpgrade) - 1
								;	SetLog($aUpgrade[$i][4] & ", Cost:" & $aUpgrade[$i][3] & $aUpgrade[$i][0], $COLOR_INFO)
								;Next
								For $i = 0 To UBound($aUpgrade) - 1
									If $aUpgrade[$i][5] = $sReseachImage Then
										$aCoords[0] = $aUpgrade[$i][1] - 40
										$aCoords[1] = $aUpgrade[$i][2] - 40 
										$sCost = $aUpgrade[$i][3]
										If Not IsLabUpgradeResourceEnough($sCost, $aUpgrade[$i][0]) Then
											$bNoResources = True
											SetLog($aUpgrade[$i][4] & " Cost:" & $sCost & " " & $aUpgrade[$i][0] & ", Not Enough Resource", $COLOR_INFO)
										Else
											Return LaboratoryUpgrade($sReseachName, $aCoords, $sCost, $bDebug)
										EndIf
									EndIf
								Next
							Else
								SetLog("FindImage : No Image " & $sReseachName & " Found!", $COLOR_DEBUG1)
							EndIf
											
						Case $iIndex = $g_iLabAnySpell ;Any Spell
							$sReseachName = $g_avLabTroops[$iIndex][0]
							$sReseachImage = $g_avLabTroops[$iIndex][2]
							$iPage = 2
							SetLog("Try Lab Upgrade: " & $sReseachName & ", Page:" & $iPage, $COLOR_INFO)
							$iCurPage = LabGoToPage($iCurPage, $iPage)
							
							For $page = 2 To 4 ; spells are on page 2, 3 and 4
								If $page > 2 Then $iCurPage = LabGoToPage($iCurPage, $page)
								$aUpgrade = FindLabUpgrade($sReseachImage)
								If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
									For $i = 0 To UBound($aUpgrade) - 1
										SetLog($aUpgrade[$i][4] & ", Cost:" & $aUpgrade[$i][3] & $aUpgrade[$i][0], $COLOR_INFO)
									Next
									For $i = 0 To UBound($aUpgrade) - 1
										$aCoords[0] = $aUpgrade[$i][1] - 40
										$aCoords[1] = $aUpgrade[$i][2] - 40 
										$sCost = $aUpgrade[$i][3]
										$sReseachName = $aUpgrade[$i][4]
										If Not IsLabUpgradeResourceEnough($sCost, $aUpgrade[$i][0]) Then
											$bNoResources = True
											SetLog($sReseachName & " Cost:" & $sCost & " " & $aUpgrade[$i][0] & ", Not Enough Resource", $COLOR_INFO)
										Else
											;SetLog($sReseachName & " Cost:" & $sCost & " " & $aUpgrade[$i][0], $COLOR_INFO)
											Return LaboratoryUpgrade($sReseachName, $aCoords, $sCost, $bDebug)
										EndIf
									Next
								Else
									SetLog("FindImage : No Image " & $sReseachName & " Found on page " & $iCurPage, $COLOR_DEBUG1)
								EndIf
							Next
												
						Case $iIndex = $g_iLabAnySiege ;Any Siege
							$sReseachName = $g_avLabTroops[$iIndex][0]
							$sReseachImage = $g_avLabTroops[$iIndex][2]
							$iPage = $iLabMaxPages
							SetLog("Try Lab Upgrade: " & $sReseachName & ", Page:" & $iPage, $COLOR_INFO)
							$iCurPage = LabGoToPage($iCurPage, $iPage)
							
							$aUpgrade = FindLabUpgrade($sReseachImage)
							If IsArray($aUpgrade) And UBound($aUpgrade) > 0 Then
								For $i = 0 To UBound($aUpgrade) - 1
									SetLog($aUpgrade[$i][4] & ", Cost:" & $aUpgrade[$i][3] & $aUpgrade[$i][0], $COLOR_INFO)
								Next
								For $i = 0 To UBound($aUpgrade) - 1
									$aCoords[0] = $aUpgrade[$i][1] - 40
									$aCoords[1] = $aUpgrade[$i][2] - 40 
									$sCost = $aUpgrade[$i][3]
									$sReseachName = $aUpgrade[$i][4]
									If Not IsLabUpgradeResourceEnough($sCost, $aUpgrade[$i][0]) Then
										$bNoResources = True
										SetLog($sReseachName & " Cost:" & $sCost & " " & $aUpgrade[$i][0] & ", Not Enough Resource", $COLOR_INFO)
									Else
										;SetLog($sReseachName & " Cost:" & $sCost & " " & $aUpgrade[$i][0], $COLOR_INFO)
										Return LaboratoryUpgrade($sReseachName, $aCoords, $sCost, $bDebug)
									EndIf
								Next
							Else
								SetLog("FindImage : No Image " & $sReseachName & " Found!", $COLOR_DEBUG1)
							EndIf
							
					EndSelect
				EndIf
			Next
			SetLog("Lab Upgrade by priority order - Not available.", $COLOR_INFO)

		Else ; no LabUpgradeOrder
			While($iCurPage <= $iLabMaxPages)
				Local $Upgrades = FindLabUpgrade()
				Local $aCoord[2], $sUpgrade
				If IsArray($Upgrades) And UBound($Upgrades) > 0 Then
					For $i = 0 To UBound($Upgrades) - 1
						$sUpgrade = $Upgrades[$i][4]
						$aCoord[0] = $Upgrades[$i][1] - 35
						$aCoord[1] = $Upgrades[$i][2] - 35
						$sCost = $Upgrades[$i][3]
						If $g_bDebugSetLog Then SetLog("LabUpgrade: " & $sUpgrade & " Cost: " & $sCost, $COLOR_INFO)	
						If Not IsLabUpgradeResourceEnough($sCost, $Upgrades[$i][0]) Then
							SetLog($sUpgrade & " Skip, Not Enough Resource", $COLOR_INFO)
						Else
							SetLog("LabUpgrade:" & $sUpgrade & " Cost:" & $sCost, $COLOR_SUCCESS)
							$bUpgradeFound = True
							ExitLoop
						EndIf
					Next
				Else
					SetLog("Not found Any Upgrade here, looking Next", $COLOR_INFO)
				EndIf

				If $bUpgradeFound Then
					Return LaboratoryUpgrade($sUpgrade, $aCoord, $sCost, $bDebug) ; Return whether or not we successfully upgraded
				EndIf
				
				$iCurPage = LabGoToPage($iCurPage, $iCurPage + 1) ; go to Next page of upgrades
				If _Sleep($DELAYLABORATORY2) Then Return
			WEnd
		EndIf
		; If We got to here without Returning, Then nothing available for upgrade
		SetLog("Nothing available for upgrade at the moment, try again later.")
		SetLog("LabUpgradeOrderEnable=" & String($g_bLabUpgradeOrderEnable) & ", UpgradeAnyTroops=" & String($g_bUpgradeAnyTroops) & ", tmpNoResources=" & String($bNoResources), $COLOR_DEBUG)
		If $g_bLabUpgradeOrderEnable And $g_bUpgradeAnyTroops And Not $bNoResources Then 
			Return UpgradeLabAny($bDebug)
		EndIf
		ClickAway()
	EndIf
	ClickAway()
	
EndFunc

; True when there is an image for this Lab entry (needed by the image search way from Lab building)
Func LabHasImage($iIndex)
	Return FileExists($g_sImgLabResearch & $g_avLabTroops[$iIndex][2] & "*") <> 0
EndFunc   ;==>LabHasImage

; start a given upgrade
Func LaboratoryUpgrade($sUpgradeName, $aCoords, $sCost, $bDebug = False)
	
	SetLog("Selected upgrade: " & $sUpgradeName & " Cost: " & $sCost, $COLOR_INFO)
	ClickP($aCoords) ; click troop
	If _Sleep(1000) Then Return
	
	If $bDebug Then ; if debugging, do not actually click it
		SetLog("[debug mode] - Start Upgrade, Click Back Button", $COLOR_ACTION)
		ClickAway()
		Return True ; Return True as if we really started an upgrade
	Else
		Click(620, 545, 1, 0, "Upgrade " & $sUpgradeName) ; Everything is good - Click the upgrade button
		If _Sleep(1000) Then Return
		If Not isGemOpen(True) Then ; check for gem window
			; success
			SetLog("Start Upgrade for " & $sUpgradeName & " Success...", $COLOR_SUCCESS)
			PushMsg("LabSuccess")
			
			If _Sleep($DELAYLABUPGRADE2) Then Return
			ClickAway()
			If _Sleep(1000) Then Return
			ClickAway()
			Return True ; upgrade started
		Else
			SetLog("Oops, Gems required for " & $sUpgradeName & " Upgrade, try again.", $COLOR_DEBUG2)
			Return False
		EndIf
		ClickAway()
	EndIf
EndFunc

Func LabGoToPage($iFrom = 1, $iTo = 2, $iLabMaxPages = $g_iLabMaxPages)
	Local $iCurPage = $iFrom
	If $iFrom = $iTo Then Return $iCurPage
	SetLog("LabGoToPage : From " & $iFrom & " To " & $iTo, $COLOR_ACTION)
	Select
		Case $iTo > $iFrom
			For $i = $iFrom To $iTo - 1
				ClickDrag(720, 500, 80, 500)
				If _Sleep(1000) Then Return
				$iCurPage += 1
				SetLog("LabGoToPage : CurPage=" & $iCurPage, $COLOR_DEBUG2)
			Next
		Case $iTo < $iFrom
			For $i = $iFrom To $iTo + 1 Step - 1
				ClickDrag(130, 500, 766, 500)
				If _Sleep(1000) Then Return
				$iCurPage -= 1
				SetLog("LabGoToPage : CurPage=" & $iCurPage, $COLOR_DEBUG2)
			Next
		Case $iTo = $iFrom
	EndSelect
	
	If $iTo = 1 Or $iTo = $iLabMaxPages Then 
		If _Sleep(3000) Then Return
	EndIf
	
	Return $iCurPage
EndFunc

; check the lab to see if something is upgrading in the lab already


Func CheckIfLabIdle($bDebug = False)
	Local $aLabInfo, $aGetLab, $bRet = True
	If $bDebug Then Return $bRet
	
	$aLabInfo = getBuilders(802, 545)
	If StringInStr($aLabInfo, "#") > 0 Then
		$aGetLab = StringSplit($aLabInfo, "#", $STR_NOCOUNT)
		Local $iLab = Number($aGetLab[0]), $iLabMax = Number($aGetLab[1])
		Select 
			Case $iLab = 0 And $iLabMax = 1
				SetLog("CheckIfLabIdle: Lab is Working on Upgrade", $COLOR_SUCCESS)
				$bRet = False
			Case $iLab = 0 And $iLabMax = 2
				SetLog("CheckIfLabIdle: Lab is Working on Upgrade", $COLOR_SUCCESS)
				$bRet = False
			Case $iLab = 1 And $iLabMax = 2
				SetLog("CheckIfLabIdle: Lab is Working on Upgrade", $COLOR_SUCCESS)
				$bRet = False
			Case $iLab = 1 And $iLabMax >= 1
				SetLog("CheckIfLabIdle: Lab is Idle", $COLOR_DEBUG1)
				$bRet = True
		EndSelect
	EndIf
	
	; lab busy: the Lab Assistant can speed up the research (Build menu tab 2, checked once per hour per account)
	If Not $bRet Then
		If BuildMenuHelperDue(1) And OpenBuildMenu(2) Then
			CheckLabAssistant()
			CloseBuildMenu()
		EndIf
	EndIf
	
	;
	;If Not $bRet And $g_bUseLabPotion Then
	;	OpenLabMenu()
	;	If QuickMIS("BC1", $g_sImgAUpgradeHour, 320, 105, 445, 140) Then
	;		Local $sUpgradeTime = getBuilderLeastUpgradeTime($g_iQuickMISX - 50, $g_iQuickMISY - 8)
	;		Local $mUpgradeTime = ConvertOCRTime("Least Upgrade", $sUpgradeTime)
	;		If $mUpgradeTime >= 1440 Then ; only use potion if lab upgrade time is more than 2 day
	;			SetLog("Upgrade time > 1 day, will use Resource Potion", $COLOR_INFO)
	;			ClickAway()
	;			UseLabPotion()
	;		Else
	;			SetLog("Upgrade time < 1 day, cancel using Resource potion", $COLOR_DEBUG2)
	;		EndIf
	;	EndIf
	;EndIf
	;
	;ClickAway()
	;If _Sleep(500) Then Return
	Return $bRet
EndFunc


; Laboratory upgrade from Build menu, tab 2 "Army Upgrades" (Lab building way is kept in LabUpgradeLegacy/Laboratory)
Func LabUpgrade($bTest = False)
	If Not $g_bAutoLabUpgradeEnable Then Return False
	checkMainScreen(False)
	If Not CheckIfLabIdle($bTest) Then Return False ; lab counter on main screen
	If _Sleep(50) Then Return False
	SetLog("Checking for Laboratory Research", $COLOR_INFO)

	If Not OpenBuildMenu(2) Then Return False
	BuildMenuReadLoot()
	; Lab Assistant is checked while the lab is busy (CheckIfLabIdle): an idle lab has no research to speed up
	If $g_aiBuildMenuCounter[2][0] = 0 And Not $bTest Then
		LabSaveBusyTime(BuildMenuBusyTime())
		CloseBuildMenu()
		Return False
	EndIf

	; selected upgrades all of one kind (troops / spells / sieges): Build menu filter of that kind, short list
	Local $sFilter = LabFilterType()
	If $sFilter <> "" Then
		If OpenBuildMenu(2, False, $sFilter) Then
			SetLog("Laboratory filter: " & $sFilter, $COLOR_INFO)
		Else
			$sFilter = ""
			If Not OpenBuildMenu(2) Then Return False ; filter failed: whole list
		EndIf
	EndIf

	; selected upgrades: stop scrolling when all of them are seen ("Upgrade Any" picks from the top rows already read)
	Local $aStop = LabWantedNames()
	; no order / no selection ("Any"): first affordable row from the top, page 1 is enough most of the time
	Local $bAnyOnly = Not $g_bLabUpgradeOrderEnable And $g_iCmbLaboratory = 0
	Local $aList = BuildMenuCollect($g_sImgResIcon, $g_iXFindLabUpgrade, -23, "lab", $aStop, $bAnyOnly ? 1 : 8)
	If $bAnyOnly And LabPickUpgrade($aList, False) < 0 Then $aList = BuildMenuCollect($g_sImgResIcon, $g_iXFindLabUpgrade, -23, "lab", $aStop)
	If UBound($aList) = 0 Then
		SetLog("No Laboratory upgrade found in Build menu", $COLOR_INFO)
		CloseBuildMenu()
		Return False
	EndIf
	SetLog("Laboratory Upgrade List:", $COLOR_INFO)
	For $i = 0 To UBound($aList) - 1
		SetLog(" - " & ($aList[$i][7] ? $aList[$i][3] : "? '" & $aList[$i][3] & "'") & " : " & _NumberFormat($aList[$i][5]) & " " & $aList[$i][0] & _
				(IsLabUpgradeResourceEnough($aList[$i][5], $aList[$i][0]) ? "" : " (not enough)"), $COLOR_DEBUG)
	Next

	Local $iPick = LabPickUpgrade($aList)
	If $iPick < 0 And $g_bUpgradeAnyTroops And (IsArray($aStop) Or $sFilter <> "") Then ; list stopped at the selected upgrades or filtered: "Upgrade Any" needs the rest
		If $sFilter <> "" Then
			$sFilter = ""
			If Not OpenBuildMenu(2) Then Return False ; filter off, list back on top
		EndIf
		$aList = BuildMenuCollect($g_sImgResIcon, $g_iXFindLabUpgrade, -23, "lab")
		$iPick = LabPickUpgrade($aList)
	EndIf
	If $iPick < 0 Then
		SetLog("Nothing to upgrade in Laboratory now", $COLOR_INFO)
		CloseBuildMenu()
		Return False
	EndIf

	Local $aCoord = BuildMenuGoToItem(2, $aList[$iPick][3], $aList[$iPick][8], $g_sImgResIcon, $g_iXFindLabUpgrade, -23, "lab", $sFilter)
	If Not IsArray($aCoord) Then
		CloseBuildMenu()
		Return False
	EndIf
	Local $bRet = LaboratoryUpgrade($aList[$iPick][3], $aCoord, $aList[$iPick][5], $bTest)
	If $bRet And Not $bTest Then LabSaveBusyTime($aCoord[2])
	CloseBuildMenu()
	Return $bRet
EndFunc   ;==>LabUpgrade

; Build menu filter of the Lab tab for the selected upgrades (order or single selection): all of one kind gives
; Troops / Spells / Siege, "" for "Any", no selection or mixed kinds
Func LabFilterType()
	Local $aIdx[0], $sKind = "", $sThis
	If $g_bLabUpgradeOrderEnable Then
		For $z = 0 To UBound($g_aCmbLabUpgradeOrder) - 1
			If $g_aCmbLabUpgradeOrder[$z] >= 0 Then _ArrayAdd($aIdx, $g_aCmbLabUpgradeOrder[$z] + 1)
		Next
	ElseIf $g_iCmbLaboratory > 0 Then
		_ArrayAdd($aIdx, $g_iCmbLaboratory)
	EndIf
	If UBound($aIdx) = 0 Then Return ""
	For $i In $aIdx
		If $i <= 0 Or $i >= UBound($g_avLabTroops) Then Return ""
		If $i = $g_iLabAnySpell Then
			$sThis = "Spells"
		ElseIf $i = $g_iLabAnySiege Then
			$sThis = "Siege"
		ElseIf StringRight($g_avLabTroops[$i][3], 5) = "Spell" Then
			$sThis = "Spells"
		ElseIf StringInStr("|WallW|BattleB|StoneS|SiegeB|LogL|FlameF|BattleD|TroopL|SkyW|", "|" & $g_avLabTroops[$i][2] & "|") Then
			$sThis = "Siege"
		Else
			$sThis = "Troops"
		EndIf
		If $sKind = "" Then $sKind = $sThis
		If $sKind <> $sThis Then Return ""
	Next
	Return $sKind
EndFunc   ;==>LabFilterType

; remember when lab should be free again ($iMin = lower bound read in Build menu, 0 = unknown)
Func LabSaveBusyTime($iMin)
	If $iMin <= 0 Then $iMin = 120
	$g_sLabUpgradeTime = _DateAdd("n", $iMin, _NowCalc())
	SetLog("Laboratory busy, next check after " & $g_sLabUpgradeTime, $COLOR_INFO)
EndFunc   ;==>LabSaveBusyTime

; choose row to upgrade: Lab Upgrade Order (if enabled) > selected troop > any affordable
Func LabPickUpgrade(ByRef $aList, $bLog = True)
	Local $aWanted[0]
	If $g_bLabUpgradeOrderEnable Then
		For $z = 0 To UBound($g_aCmbLabUpgradeOrder) - 1
			If $g_aCmbLabUpgradeOrder[$z] >= 0 Then _ArrayAdd($aWanted, $g_aCmbLabUpgradeOrder[$z] + 1)
		Next
	ElseIf $g_iCmbLaboratory > 0 Then
		_ArrayAdd($aWanted, $g_iCmbLaboratory)
	EndIf

	For $iWant In $aWanted
		For $i = 0 To UBound($aList) - 1
			If Not $aList[$i][7] Or Not LabNameIsWanted($aList[$i][3], $iWant) Then ContinueLoop
			If IsLabUpgradeResourceEnough($aList[$i][5], $aList[$i][0]) Then
				SetLog("Lab priority: " & $g_avLabTroops[$iWant][0] & " -> " & $aList[$i][3], $COLOR_SUCCESS)
				Return $i
			EndIf
			SetLog($aList[$i][3] & ": not enough resource", $COLOR_DEBUG1)
		Next
	Next

	If UBound($aWanted) > 0 And Not $g_bUpgradeAnyTroops Then
		SetLog("Selected Lab upgrade not available, enable 'Upgrade Any' to upgrade something else", $COLOR_INFO)
		Return -1
	EndIf

	; any: first affordable row from the top, like the game list order (Suggested first). The cost of DE and Elixir rows
	; can not be compared, and a recognized name is needed to find the row again
	For $i = 0 To UBound($aList) - 1
		If Not $aList[$i][7] Or Not IsLabUpgradeResourceEnough($aList[$i][5], $aList[$i][0]) Then ContinueLoop
		If $bLog Then SetLog("Lab upgrade any: " & $aList[$i][3], $COLOR_INFO)
		Return $i
	Next
	Return -1
EndFunc   ;==>LabPickUpgrade

; names of selected Lab upgrades (order list or single selection), Default when "Any" / Any Spell / Any Siege is used
Func LabWantedNames()
	Local $aNames[0], $aIdx[0]
	If $g_bLabUpgradeOrderEnable Then
		For $z = 0 To UBound($g_aCmbLabUpgradeOrder) - 1
			If $g_aCmbLabUpgradeOrder[$z] >= 0 Then _ArrayAdd($aIdx, $g_aCmbLabUpgradeOrder[$z] + 1)
		Next
	ElseIf $g_iCmbLaboratory > 0 Then
		_ArrayAdd($aIdx, $g_iCmbLaboratory)
	EndIf
	If UBound($aIdx) = 0 Then Return Default
	For $i In $aIdx
		If $i = 0 Or $i >= $g_iLabAnySpell Then Return Default ; category: needs full list
		_ArrayAdd($aNames, $g_avLabTroops[$i][3])
	Next
	Return $aNames
EndFunc   ;==>LabWantedNames

Func LabNameIsWanted($sName, $iWant)
	Switch $iWant
		Case $g_iLabAnySpell
			Return StringRight($sName, 5) = "Spell"
		Case $g_iLabAnySiege
			For $i = 0 To UBound($g_asSiegeMachineNames) - 1
				If $sName = $g_asSiegeMachineNames[$i] Then Return True
			Next
			Return False
		Case Else
			Return $sName = $g_avLabTroops[$iWant][3]
	EndSwitch
EndFunc   ;==>LabNameIsWanted

; old way (Lab menu without scroll + Lab building), kept for reference


; $sUpgrade = Any, will search all image 
; $sUpgrade = AnySpell, will search all within AnySpell image dir
; $sUpgrade = AnySiege, will search all within AnySiege image dir
; $sUpgrade = sShortName, will search only shortName image
Func FindLabUpgrade($sUpgrade = "Any")
	If $g_bDebugSetLog Then SetLog("FindLabUpgrade : " & $sUpgrade)
	Local $aResult[0][6], $sUpgradeName = "", $sDir = "", $sSearchWay = "BC1", $iSortBy = 0, $iSortDirection = 0
	Local $TmpResult = QuickMIS("CNX", $g_sImgResIcon, 70, 415, 790, 564)
	If IsArray($TmpResult) And UBound($TmpResult) > 0 Then
		For $i = 0 To UBound($TmpResult) - 1
			Local $aTmp[1][6] = [[$TmpResult[$i][0], $TmpResult[$i][1], $TmpResult[$i][2], 0, "", ""]]
			_ArrayAdd($aResult, $aTmp)
		Next
		
		For $i = 0 To UBound($aResult) - 1
			Switch $sUpgrade
				Case "Any"
					$sSearchWay = "BC1"
					$sDir = $g_sImgLabResearch
					$iSortBy = 3
					$iSortDirection = 1
				Case "AnySpell"
					$sSearchWay = "BC1"
					$sDir = $g_sImgAnySpell
				Case "AnySiege"
					$sSearchWay = "BC1"
					$sDir = $g_sImgAnySiege
					$iSortBy = 3
				Case Else
					$sSearchWay = "BFI"
					$sDir = $g_sImgLabResearch & $sUpgrade & "*"
			EndSwitch
				
			If QuickMIS($sSearchWay, $sDir, $aResult[$i][1] - 92, $aResult[$i][2] - 93, $aResult[$i][1] + 17, $aResult[$i][2]) Then
				Local $cost = getLabCost($aResult[$i][1] - 92, $aResult[$i][2] - 10)
				$sUpgradeName = GetTroopName(TroopIndexLookup($sSearchWay = "BC1" ? $g_sQuickMISName : $sUpgrade))
				$aResult[$i][3] = Number($cost)
				$aResult[$i][4] = $sUpgradeName
				$aResult[$i][5] = $sSearchWay = "BC1" ? $g_sQuickMISName : $sUpgrade
			EndIf
		Next
	EndIf
	
	
	; remove every entry without a matched image or without a readable cost (cost 0 would always pass resource check)
	For $i = UBound($aResult) - 1 To 0 Step -1
		If $aResult[$i][4] = "" Or $aResult[$i][3] <= 0 Then
			SetDebugLog("FindLabUpgrade: deleting [" & $i & "] name='" & $aResult[$i][4] & "' cost=" & $aResult[$i][3])
			_ArrayDelete($aResult, $i)
		EndIf
	Next

	_ArraySort($aResult, $iSortDirection, 0, 0, $iSortBy)
	Return $aResult
EndFunc

Func IsLabUpgradeResourceEnough($Cost, $CostType)
	Local $bRet = False
	
	Switch $CostType
		Case "Elix"
			If $g_aiCurrentLoot[$eLootElixir] > ($g_iTxtSmartMinElixir + $Cost) Then
				If $g_bDebugSetLog Then SetLog($g_iTxtSmartMinElixir & " + " & $Cost & " = " & $g_iTxtSmartMinElixir + $Cost)
				If $g_bDebugSetLog Then SetLog("Elixir = " & $g_aiCurrentLoot[$eLootElixir])
				$bRet = True
			EndIf
		Case "DE"
			If $g_aiCurrentLoot[$eLootDarkElixir] > ($g_iTxtSmartMinDark + $Cost) Then
				If $g_bDebugSetLog Then SetLog($g_iTxtSmartMinDark & " + " & $Cost & " = " & $g_iTxtSmartMinDark + $Cost)
				If $g_bDebugSetLog Then SetLog("DE = " & $g_aiCurrentLoot[$eLootDarkElixir])
				$bRet = True
			EndIf
	EndSwitch
	
	Return $bRet
EndFunc

; Find Research Button
Func FindResearchButton($bForceOpen = False)
	Local $TryLabAutoLocate = False
	Local $LabFound = False
	
	If _ColorCheck(_GetPixelColor(288, 36, True), Hex(0xFFFF5E, 6), 20, Default, "Laboratory") And $bForceOpen Then
		SetLog("Laboratory: Found Goblin Lab!, Return False", $COLOR_DEBUG1)
		Return False
	EndIf
	
	ZoomOut()
	;Click Laboratory
	If Int($g_aiLaboratoryPos[0]) < 1 Or Int($g_aiLaboratoryPos[1]) < 1 Then
		$TryLabAutoLocate = True
	Else
		Click($g_aiLaboratoryPos[0], $g_aiLaboratoryPos[1])
		If _Sleep(1000) Then Return
		Local $BuildingInfo = BuildingInfo(260, 477)
		If StringInStr($BuildingInfo[1], "Lab") Then
			$TryLabAutoLocate = False
			$LabFound = True
			CheckLabAssistant()
		Else
			$TryLabAutoLocate = True
		EndIf
	EndIf

	If $TryLabAutoLocate Then
		$LabFound = AutoLocateLab()
		If $LabFound Then
			applyConfig()
			saveConfig()
		Else
			SetLog("TryLabAutoLocate Failed, please locate manually", $COLOR_DEBUG2)
			Return
		EndIf
	EndIf

	If $LabFound Then
		If $bForceOpen Then 
			If Not ClickB("Research") Then Return
		EndIf
		If _Sleep(1000) Then Return
	EndIf
	
	Return True
EndFunc

Func AutoLocateLab()
	Local $LabFound = False
	SetLog("Try to Auto Locate Laboratory!", $COLOR_INFO)
	ClickAway()
	Local $aLabCoord = QuickMIS("CNX", $g_sImgLaboratory)
	If IsArray($aLabCoord) And UBound($aLabCoord) > 0 Then
		_ArraySort($aLabCoord, 1, 0, 0, 3)
		For $i = 0 To UBound($aLabCoord) - 1
			If StringInStr($aLabCoord[$i][0], "Research") Then 
				$aLabCoord[$i][2] += 30
			EndIf
			Click($aLabCoord[$i][1], $aLabCoord[$i][2])
		
			If _Sleep(1000) Then Return
			Local $BuildingInfo = BuildingInfo()
			If StringInStr($BuildingInfo[1], "Lab") Then	
				$g_aiLaboratoryPos[0] = $aLabCoord[$i][1]
				$g_aiLaboratoryPos[1] = $aLabCoord[$i][2]
				SetLog("Found Laboratory Lvl " & $BuildingInfo[2] & ", save as Lab Coords : " & $g_aiLaboratoryPos[0] & "," & $g_aiLaboratoryPos[1], $COLOR_INFO)
				$LabFound = True
				ExitLoop
			Else
				SetLog("Not Laboratory, its a " & $BuildingInfo[1], $COLOR_DEBUG1)
				ClickAway()
			EndIf
		Next
		
		If $LabFound Then CheckLabAssistant()
		
	EndIf
	SetLog("AutoLocateLaboratory, Success", $COLOR_SUCCESS)
	Return $LabFound	
EndFunc

; Lab Assistant: icon left of Build menu tab 2 (see BuildMenuAssignHelper), the menu must be open on tab 2
Func CheckLabAssistant()
	Return BuildMenuAssignHelper(1, 2)
EndFunc   ;==>CheckLabAssistant

Func UpgradeLabAny($bDebug = False)
	;just start from page 1, close and open again lab window
	ClickAway()
	If _Sleep(1000) Then Return
	If Not ClickB("Research") Then Return
	If _Sleep(1000) Then Return
	Local $iCurPage = 1, $bUpgradeFound = False, $sCost = 0, $iLabMaxPages = $g_iLabMaxPages
	While($iCurPage <= $iLabMaxPages)
		Local $Upgrades = FindLabUpgrade()
		Local $aCoord[2], $sUpgrade
		If IsArray($Upgrades) And UBound($Upgrades) > 0 Then
			For $i = 0 To UBound($Upgrades) - 1
				If $g_bDebugSetLog Then SetLog("LabUpgrade:" & $Upgrades[$i][4] & " Cost:" & $Upgrades[$i][3] & " " & $Upgrades[$i][0], $COLOR_DEBUG1)
				$aCoord[0] = $Upgrades[$i][1] - 40 
				$aCoord[1] = $Upgrades[$i][2] - 40
				$sCost = $Upgrades[$i][3]
				$sUpgrade = $Upgrades[$i][4]
				If Not IsLabUpgradeResourceEnough($sCost, $Upgrades[$i][0]) Then
					SetLog("LabUpgrade:" & $sUpgrade & " Skip, Not Enough Resource", $COLOR_INFO)
				Else
					SetLog("LabUpgrade:" & $sUpgrade & " Cost:" & $sCost, $COLOR_SUCCESS)
					$bUpgradeFound = True
					ExitLoop
				EndIf
			Next
		Else
			SetLog("Not found Any Upgrade here, looking Next", $COLOR_INFO)
		EndIf
		
		If $bUpgradeFound Then
			Return LaboratoryUpgrade($sUpgrade, $aCoord, $sCost, $bDebug) ; Return whether or not we successfully upgraded
		EndIf
		
		$iCurPage = LabGoToPage($iCurPage, $iCurPage + 1) ; go to Next page of upgrades
		If _Sleep($DELAYLABORATORY2) Then Return
	WEnd
	
	ClickAway()
	Return False
EndFunc
