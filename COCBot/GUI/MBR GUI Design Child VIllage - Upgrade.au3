; #FUNCTION# ====================================================================================================================
; Name ..........: MBR GUI Design
; Description ...: This file creates the "Upgrade" tab under the "Village" tab
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: CodeSlinger69 (2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

Global $g_hGUI_UPGRADE = 0, $g_hGUI_UPGRADE_TAB = 0, $g_hGUI_UPGRADE_TAB_ITEM1 = 0, $g_hGUI_UPGRADE_TAB_ITEM2 = 0, $g_hGUI_UPGRADE_TAB_ITEM3 = 0, _
	   $g_hGUI_UPGRADE_TAB_ITEM4 = 0, $g_hGUI_UPGRADE_TAB_ITEM5 = 0
; Lab
Global $g_hChkAutoLabUpgrades = 0, $g_hCmbLaboratory = 0, $g_hLblNextUpgrade = 0, $g_hBtnResetLabUpgradeTime = 0, $g_hPicLabUpgrade = 0

; Heroes
Global $g_hChkUpgradeKing = 0, $g_hChkUpgradeQueen = 0, $g_hChkUpgradeWarden = 0, $g_hPicChkKingSleepWait = 0, $g_hPicChkQueenSleepWait = 0, $g_hPicChkWardenSleepWait = 0
Global $g_hCmbHeroReservedBuilder = 0, $g_hLblHeroReservedBuilderTop = 0, $g_hLblHeroReservedBuilderBottom = 0
Global $g_hChkUpgradeChampion = 0, $g_hPicChkChampionSleepWait = 0, $g_hUseLabPotion = 0, $g_hUsePetPotion = 0
Global $g_hChkUpgradePrince = 0, $g_hChkUpgradeDuke = 0
Global $g_hChkUpgradePets[$ePetCount], $g_hChkSortPetUpgrade = 0, $g_hCmbSortPetUpgrade = 0, $g_hChkSyncSaveDE = 0

; Buildings
Global $g_hChkUpgrade[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hPicUpgradeStatus[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hTxtUpgradeName[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hTxtUpgradeLevel[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hPicUpgradeType[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hTxtUpgradeValue[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hTxtUpgradeTime[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hTxtUpgradeEndTime[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hChkUpgradeRepeat[$g_iUpgradeSlots] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hTxtUpgrMinGold = 0, $g_hTxtUpgrMinElixir = 0, $g_hTxtUpgrMinDark = 0

; Walls
Global $g_hChkWalls = 0, $g_hTxtWallMinGold = 0, $g_hTxtWallMinElixir = 0, $g_hChkUseGold = 0, $g_hChkUseElixir = 0, $g_hChkUseElixirGold = 0
Global $g_hChkSaveWallBldr = 0, $g_hAutoAdjustSaveWall = 0
Global $g_hChkOnly1Builder = 0

; Auto Upgrade
Global $g_hChkAutoUpgrade = 0, $g_hLblAutoUpgrade = 0, $g_hTxtAutoUpgradeLog = 0
Global $g_hTxtSmartMinGold = 0, $g_hTxtSmartMinElixir = 0, $g_hTxtSmartMinDark = 0
Global $g_hChkResourcesToIgnore[3] = [0, 0, 0]
Global $g_hChkUpgradesToIgnore = $g_iChkUpgradesToIgnore, $g_hLvUpgradesToIgnore = 0, $g_hLvUpgradesToIgnore2 = 0
Global $g_hChkRushTH = 0, $g_hBtnRushTHOption = 0, $g_hUseWallReserveBuilder = 0, $g_hUseBuilderPotion = 0, $g_hUpgradeOtherDefenses = 0
Global $g_hGUI_RushTHOption = 0, $g_hBtnRushTHOptionClose = 0, $g_ahCmbRushTHOption[5] = [0, 0, 0, 0, 0]
Global $RushTHOption[5] = ["TownHall", "Barracks", "Dark Barracks", "Spell Factory", "Dark Spell Factory"]
Global $g_hchkEssentialUpgrade[8] = [0, 0, 0, 0, 0, 0, 0, 0]
Global $g_hUpgradeOnlyTHLevelAchieve = 0, $g_hHeroPriority = 0
; buttons below Upgrades to ignore: [text, group of $g_asUpgradeIgnore ("" = Reset)]
Global Const $g_asIgnoreGroupBtn[6][2] = [["Reset", ""], ["TH", "T"], ["Hero", "H"], ["Army", "A"], ["Resource", "R"], ["Defense", "D"]]
Global $g_hBtnIgnoreGroup[6]
Global $g_hUseHeroBooks = 0, $g_hHeroMinUpgradeTime = 0

Func CreateVillageUpgrade()

	; ensure all language translation are created
	InitTranslatedTextUpgradeTab()

	$g_hGUI_UPGRADE = _GUICreate("", $g_iSizeWGrpTab2, $g_iSizeHGrpTab2, 5, 25, BitOR($WS_CHILD, $WS_TABSTOP), -1, $g_hGUI_VILLAGE)
	SetDebugLog("CreateVillageUpgrade()")
	
	
	GUISwitch($g_hGUI_UPGRADE)
	$g_hGUI_UPGRADE_TAB = GUICtrlCreateTab(0, 0, $g_iSizeWGrpTab2, $g_iSizeHGrpTab2, BitOR($TCS_MULTILINE, $TCS_RIGHTJUSTIFY))
	$g_hGUI_UPGRADE_TAB_ITEM1 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_02_STab_03_STab_01", "Laboratory"))
		SetDebugLog("==> CreateLaboratorySubTab()")
		CreateLaboratorySubTab()
	$g_hGUI_UPGRADE_TAB_ITEM2 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_02_STab_03_STab_02b", "Pets && Equipment"))
		CreatePetsGroup()
		CreateHeroEquipment()
	$g_hGUI_UPGRADE_TAB_ITEM5 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_02_STab_03_STab_05", "Auto Upgrade"))
		SetDebugLog("==> CreateAutoUpgradeSubTab()")
		CreateAutoUpgradeSubTab()
	$g_hGUI_UPGRADE_TAB_ITEM4 = GUICtrlCreateTabItem(GetTranslatedFileIni("MBR Main GUI", "Tab_02_STab_03_STab_04", "Walls"))
		SetDebugLog("==> CreateWallsSubTab()")
		CreateWallsSubTab()
	
		;other gui (new dialog window)
		CreateRushTHOption()

	GUICtrlCreateTabItem("")

EndFunc   ;==>CreateVillageUpgrade

Global $g_hTxtUpgradeDeadline = 0
Global $g_bIgnoreListLocked = False ; Rush TH: Upgrades to ignore check boxes locked (scroll still works)
Global $g_hChkLabUpgradeOrder = 0, $g_hBtnRemoveLabUpgradeOrder = 0, $g_hBtnSetLabUpgradeOrder = 0, $g_hUpgradeAnyTroops = 0

Func CreateLaboratorySubTab()
	Local $sTxtNames = ""
	For $i = 0 To Ubound($g_avLabTroops) - 3
		$sTxtNames &= $g_avLabTroops[$i][0] & "|"
	Next
	
	Local $x = 25, $y = 45
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "Group_01", "Laboratory"), $x - 20, $y - 20, $g_iSizeWGrpTab3 - 2, 228)
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnLaboratory, $x, $y, 64, 64)
		$g_hChkAutoLabUpgrades = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkAutoLabUpgrades", "Auto Laboratory Upgrades"), $x + 80, $y , -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkAutoLabUpgrades_Info_01", "Check box to enable automatically starting Upgrades in laboratory"))
			GUICtrlSetOnEvent(-1, "chkLab")
		$g_hLblNextUpgrade = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "LblNextUpgrade", "Next one") & ":", $x + 80, $y + 25, 50, -1)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$g_hCmbLaboratory = GUICtrlCreateCombo("", $x + 135, $y + 23, 140, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL, $WS_VSCROLL))
			GUICtrlSetData(-1, $sTxtNames, GetTranslatedFileIni("MBR Global GUI Design", "Any", "Any"))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "CmbLaboratory_Info_01", "Select the troop type to upgrade with this pull down menu") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "CmbLaboratory_Info_02", "The troop icon will appear on the right.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "CmbLaboratory_Info_03", "Any Dark Spell/Troop have priority over Upg Heroes!"))
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetOnEvent(-1, "cmbLab")
		$g_hPicLabUpgrade = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnBlank, $x + 330, $y, 64, 64)
			GUICtrlSetState(-1, $GUI_HIDE)

		;Enable Lab Upgrade Order
		$g_hChkLabUpgradeOrder = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkLabUpgradeOrder", "Enable Order"), $x + 80, $y + 45, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkAutoLabUpgrades_Info_04", "Check box to enable Upgrades Order in laboratory"))
			GUICtrlSetOnEvent(-1, "chkLabUpgradeOrder")

		; Create translated list of Troops for combo box
		Local $sComboData = ""
		For $i = 1 To Ubound($g_avLabTroops) - 1
			$sComboData &= $g_avLabTroops[$i][0] & "|"
		Next

		; Create ComboBox(es) for selection of troop training order
		$y += 70
		$x += 20
		For $z = 0 To UBound($g_ahCmbLabUpgradeOrder) - 1
			If $z < 5 Then
				GUICtrlCreateLabel($z + 1 & ":", $x - 16, $y + 2, -1, 18)
				$g_ahCmbLabUpgradeOrder[$z] = GUICtrlCreateCombo("", $x, $y, 110, 18, BitOR($CBS_DROPDOWNLIST + $WS_VSCROLL, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "cmbLabUpgradeOrder")
				GUICtrlSetData(-1, $sComboData, "")
				GUICtrlSetState(-1, $GUI_DISABLE)
				$y += 22 ; move down to next combobox location
			ElseIf $z > 4 And $z < 10 Then
				If $z = 5 Then
					$x += 141
					$y -= 110
				EndIf
				GUICtrlCreateLabel($z + 1 & ":", $x - 13, $y + 2, -1, 18)
				$g_ahCmbLabUpgradeOrder[$z] = GUICtrlCreateCombo("", $x + 4, $y, 110, 18, BitOR($CBS_DROPDOWNLIST + $WS_VSCROLL, $CBS_AUTOHSCROLL))
				GUICtrlSetOnEvent(-1, "cmbLabUpgradeOrder")
				GUICtrlSetData(-1, $sComboData, "")
				GUICtrlSetState(-1, $GUI_DISABLE)
				$y += 22 ; move down to next combobox location
			EndIf
		Next

		$x += 140
		$y -= 100
		$g_hBtnRemoveLabUpgradeOrder = GUICtrlCreateButton("Clear List", $x - 6, $y, 96, 20)
		GUICtrlSetState(-1, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		GUICtrlSetOnEvent(-1, "btnRemoveLabUpgradeOrder")

		$y += 25
		$g_hBtnSetLabUpgradeOrder = GUICtrlCreateButton("Apply Order", $x - 6, $y, 96, 20)
		GUICtrlSetState(-1, BitOR($GUI_UNCHECKED, $GUI_DISABLE))
		GUICtrlSetOnEvent(-1, "btnSetLabUpgradeOrder")

		$y += 25
		$g_hUseLabPotion = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkUseResearchPotion", "Use Research Potion"), $x - 6, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkUseResearchPotion_Info", "Use a Research Potion (Magic Items) when the running research has 1 day or more left"))
		$y += 55
		$x = 25
		$g_hUpgradeAnyTroops = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkUpgradeAny", "Upgrade Any Troops/Spells/Sieges If All in Order Cannot be Upgraded"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Laboratory", "ChkUpgradeAny_Info", "Enable Upgrade Any after Upgrade Order" & @CRLF & "And all upgrades on list cannot be upgraded"))
			GUICtrlSetOnEvent(-1, "chkUpgradeAnyTroops")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$x = 25
	$y = 250

EndFunc   ;==>CreateLaboratorySubTab

; Pets group of the Pets & Equipment sub tab (Heroes sub tab removed: heroes are upgraded by Auto Upgrade, set them in
; Upgrades to ignore). Same order as Pet House window, 6 per row
Func CreatePetsGroup()
	Local $sTxtTip = "", $x = 20, $y = 45, $iStep = 66
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Pets", "LblAutoUpgrading_02", "Pets Upgrade :"), $x - 15, $y - 15, $g_iSizeWGrpTab3 - 2, 164)
	For $i = 0 To $ePetCount - 1
		Local $iCol = Mod($i, 6), $iRow = Int($i / 6)
		$sTxtTip = GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Heroes", "ChkUpgrade" & $g_asPetConfigKey[$i] & "_Info_01", _
				"Enable upgrading of your Pet, " & $g_asPetNames[$i] & ", when you have enough Dark Elixir")
		$g_hChkUpgradePets[$i] = GUICtrlCreateCheckbox("", $x + $iCol * $iStep, $y + $iRow * 48 + 12, 17, 17)
			_GUICtrlSetTip(-1, $sTxtTip)
			GUICtrlSetOnEvent(-1, "chkUpgradePets")
		_GUICtrlCreateIcon($g_sLibIconPath, $g_aiPetIcon[$i], $x + $iCol * $iStep + 17, $y + $iRow * 48, 40, 40)
			_GUICtrlSetTip(-1, $sTxtTip)
	Next

	$y += 2 * 48 + 3
		$g_hChkSortPetUpgrade = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Pets", "ChkSortPetUpgrade", "Sort Pet Upgrade By:"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "SortPetUpgrade")
		$g_hCmbSortPetUpgrade = GUICtrlCreateCombo("", $x + 120, $y, 95, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
		GUICtrlSetData(-1, "Higher Cost|Lower Cost|Assigned", "Assigned")
		GUICtrlSetOnEvent(-1, "SortPetUpgrade")
		$g_hChkSyncSaveDE = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Pets", "ChkSyncSaveDE", "Sync Save DE with AutoUpgrade"), $x + 225, $y, -1, -1)
		$g_hUsePetPotion = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Pets", "ChkUsePetPotion", "Use Pet Potion"), $x, $y + 22, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Pets", "ChkUsePetPotion_Info", "Use a Pet Potion (Magic Items) when the running pet upgrade has 1 day or more left"))
	GUICtrlCreateGroup("", -99, -99, 1, 1)
EndFunc   ;==>CreatePetsGroup

; Hero Equipment (Blacksmith) group of the Pets & Equipment sub tab (was a dialog opened from the Lab tab)
Func CreateHeroEquipment()
	Local $x = 10, $y = 198
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "GUI_Equipment", "Hero Equipment"), $x - 5, $y, $g_iSizeWGrpTab3 - 2, 200)
	_GUICtrlCreateIcon($g_sLibIconPath, $eIcnBlacksmith, $x, $y + 15, 32, 32)
	$g_hChkCustomEquipmentOrderEnable = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "ChkCustomEquipmentEnable", "Auto Equipment Upgrades"), $x + 40, $y + 15, -1, -1)
	GUICtrlSetState(-1, $GUI_UNCHECKED)
	_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "ChkCustomEquipmentEnable_Info_01", "Enable to select a custom equipment upgrade order"))
	GUICtrlSetOnEvent(-1, "chkEquipmentOrder")
	$g_hChkEquippedOnly = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "ChkEquippedOnly", "Only Equipped"), $x + 230, $y + 15, -1, -1)
	_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "ChkEquippedOnly_Info_01", "Upgrade only equipments a hero wears now"))
	$g_hChkMinOreUpgrade = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "ChkMinOreUpgrade", "Only Upgrade Equipment when Shiny Ore >"), $x + 40, $y + 36, -1, -1)
	GUICtrlSetOnEvent(-1, "ChkMinOreUpgrade")
	$g_hTxtMinOreUpgrade = GUICtrlCreateInput("", $x + 270, $y + 38, 50, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_RIGHT, $ES_NUMBER))

	Local $sComboData = ""
	For $t = 0 To UBound($g_asEquipmentOrderList) - 1
		$sComboData &= $g_asEquipmentOrderList[$t][0] & "|"
	Next
	Local $txtEquipmentOrder = GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "TxtEquipmentOrder", "Select Equipment To Upgrade In Position ")

	; 2 columns of 5: check box, combo, icons of the equipment and its hero
	Local $iTop = $y + 62
	For $z = 0 To UBound($g_ahCmbEquipmentOrder) - 1
		If $z > 9 Then ExitLoop
		$x = ($z < 5 ? 10 : 220)
		$y = $iTop + Mod($z, 5) * 23
		$g_hChkCustomEquipmentOrder[$z] = GUICtrlCreateCheckbox("", $x, $y, 17, 20)
		GUICtrlSetState(-1, $GUI_UNCHECKED)
		_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "ChkCustomEquipmentOrder_Info_01", "Enable or disable a custom equipment upgrade"))
		$g_ahCmbEquipmentOrder[$z] = GUICtrlCreateCombo("", $x + 20, $y, 120, 25, BitOR($CBS_DROPDOWNLIST + $WS_VSCROLL, $CBS_AUTOHSCROLL))
		GUICtrlSetOnEvent(-1, "GUIRoyalEquipmentOrder")
		GUICtrlSetData(-1, $sComboData, "")
		_GUICtrlSetTip(-1, $txtEquipmentOrder & $z + 1)
		$g_ahImgEquipmentOrder[$z] = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnOptions, $x + 144, $y, 20, 20)
		$g_ahImgEquipmentOrder2[$z] = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnOptions, $x + 166, $y, 20, 20)
	Next

	$y = $iTop + 5 * 23 + 2
	$g_hBtnRegularOrder = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "BtnRegularOrder", "Sort in Original Order"), 10, $y, 130, 20)
	_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "BtnRegularOrder_Info_01", "Push button to sort equipment in original order"))
	GUICtrlSetOnEvent(-1, "btnRegularOrder")
	$g_hBtnRemoveEquipment = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "BtnRemoveEquipment", "Empty Equipment List"), 145, $y, 130, 20)
	_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "BtnRemoveEquipment_Info_01", "Push button to remove all equipment from list and start over"))
	GUICtrlSetOnEvent(-1, "btnRemoveEquipment")
	$g_hBtnEquipmentOrderSet = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "BtnEquipmentOrderSet", "Apply New Order"), 280, $y, 96, 20)
	_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "BtnEquipmentOrderSet_Info_01", "Push button when finished selecting custom equipment upgrading order") & @CRLF & _
			GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "BtnEquipmentOrderSet_Info_02", "Icon changes color based on status: Red= Not Set, Green = Order Set") & @CRLF & _
			GetTranslatedFileIni("MBR GUI Design Child Attack - Equipment", "BtnEquipmentOrderSet_Info_03", "When not all equipment slots are filled, will use random equipment order in empty slots!"))
	GUICtrlSetOnEvent(-1, "btnEquipmentOrderSet")
	$g_ahImgEquipmentOrderSet = _GUICtrlCreateIcon($g_sLibIconPath, $eIcnSilverStar, 380, $y + 1, 18, 18)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
EndFunc   ;==>CreateHeroEquipment

Func CreateWallsSubTab()
	Local $x = 25, $y = 45
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "Group_01", "Walls"), $x - 20, $y - 20, $g_iSizeWGrpTab3, 220)
		$x = 10
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnWall, $x, $y - 6, 32, 32)
		$x = 50
		$g_hChkWalls = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "ChkWalls", "Auto Wall Upgrade"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "ChkWalls_Info_01", "Check this to upgrade Walls if there are enough resources."))
			GUICtrlSetState(-1, $GUI_ENABLE)
			GUICtrlSetState(-1, $GUI_UNCHECKED)
			GUICtrlSetOnEvent(-1, "chkWalls")
		$x += 20
		$y += 20
		$g_hChkUseGold = GUICtrlCreateRadio(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseGold", "Use Gold"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseGold_Info_01", "Use only Gold for Walls.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseGold_Info_02", "Available at all Wall levels."))
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetOnEvent(-1, "chkWalls")
		$y += 20
		$g_hChkUseElixir = GUICtrlCreateRadio(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseElixir", "Use Elixir"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseElixir_Info_01", "Use only Elixir for Walls.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseElixir_Info_02", "Available only at Wall levels upgradeable with Elixir."))
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetOnEvent(-1, "chkWalls")
		$y += 20
		$g_hChkUseElixirGold = GUICtrlCreateRadio(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseElixirGold", "Try Elixir first, Gold second"), $x, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseElixirGold_Info_01", "Try to use Elixir first. If not enough Elixir try to use Gold second for Walls.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "RdoUseElixir_Info_02", -1))
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetOnEvent(-1, "chkWalls")
		
		$y += 30
		$g_hAutoAdjustSaveWall = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "AutoAdjustSaveWall", "Auto Adjust Save Min Gold And Elixir"), $x - 20, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "AutoAdjustSaveWall_Info_01", "Bot overwrites wall Min Save Gold / Elixir from your storage capacity, so the TH upgrade is not delayed.") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "AutoAdjustSaveWall_Info_02", "Target TH = TH level of the Rush TH setting (Rush TH does not need to be checked):") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "AutoAdjustSaveWall_Info_03", "- TH below target, TH < 7: save 3 storages of Gold and Elixir") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "AutoAdjustSaveWall_Info_04", "- TH below target, TH 7+: Gold 3 storages, Elixir Hero Hall cost + 1 storage") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "AutoAdjustSaveWall_Info_05", "- TH at target, TH 9+: save 3.8 storages of Gold and Elixir"))
			GUICtrlSetState(-1, $GUI_ENABLE)
			GUICtrlSetState(-1, $GUI_UNCHECKED)
			GUICtrlSetOnEvent(-1, "chkAutoAdjustSaveMinWall")
			
		$y += 25
		_GUICtrlCreateIcon ($g_sLibIconPath, $eIcnGold, $x - 20, $y, 16, 16)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "LblMin.Goldtosave", "Min. Gold to save"), $x, $y, -1, -1)
		$g_hTxtWallMinGold = GUICtrlCreateInput("250000", $x + 110, $y, 80, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "LblMin.Goldtosave_Info_01", "Save this much Gold after the wall upgrade completes,") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "LblMin.Goldtosave_Info_02", "Set this value to save Gold for other upgrades, or searching."))
			GUICtrlSetLimit(-1, 8)
			GUICtrlSetState(-1, $GUI_DISABLE)
		$y += 20
		_GUICtrlCreateIcon ($g_sLibIconPath, $eIcnElixir, $x - 20, $y, 16, 16)
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "LblMin.Elixirtosave", "Min. Elixir to save"), $x, $y, -1, -1)
		$g_hTxtWallMinElixir = GUICtrlCreateInput("250000", $x + 110, $y, 80, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "LblMin.Elixirtosave_Info_01", "Save this much Elixir after the wall upgrade completes,") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "LblMin.Elixirtosave_Info_02", "Set this value to save Elixir for other upgrades or troop making."))
			GUICtrlSetLimit(-1, 8)
			GUICtrlSetState(-1, $GUI_DISABLE)

		$x = 210
		$y = 45
		_GUICtrlCreateIcon($g_sLibIconPath, $eIcnBuilder, $x, $y, 32, 32)
		$x += 10
		$g_hChkSaveWallBldr = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "ChkSaveWallBldr", "Save ONE builder for Walls"), $x + 30, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "ChkSaveWallBldr_Info_01", "Check this to reserve 1 builder exclusively for walls and") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "ChkSaveWallBldr_Info_02", "reduce the available builder by 1 for other upgrades"))
			GUICtrlSetState(-1, $GUI_ENABLE)
			GUICtrlSetState(-1, $GUI_UNCHECKED)
			GUICtrlSetOnEvent(-1, "chkSaveWallBldr")
		$y += 20
		$g_hChkOnly1Builder = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "ChkOnly1Builder", "Only Upgrade If Only 1 Builder left"), $x + 30, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "ChkSaveWallBldr_Info_01", "Only Upgrade wall if there is only 1 builder left") & @CRLF & _
							   GetTranslatedFileIni("MBR GUI Design Child Village - Upgrade_Walls", "ChkSaveWallBldr_Info_02", "So If builder stacked, it will priority other upgrade"))
			GUICtrlSetState(-1, $GUI_ENABLE)
			GUICtrlSetState(-1, $GUI_UNCHECKED)
			GUICtrlSetOnEvent(-1, "chkWallOnly1Builder")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

EndFunc   ;==>CreateWallsSubTab


Func CreateAutoUpgradeSubTab()

	Local $x = 25, $y = 40
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "Group_01", "Auto Upgrade"), $x - 20, $y - 15, $g_iSizeWGrpTab3, 65)

		$g_hChkAutoUpgrade = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "ChkAutoUpgrade", "Enabled"), $x - 5, $y, -1, -1)
			_GUICtrlSetTip(-1, GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "ChkAutoUpgrade_Info_01", "Check box to enable automatically starting Upgrades from builders menu"))
			GUICtrlSetOnEvent(-1, "chkAutoUpgrade")
		$g_hLblAutoUpgrade = GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "Label_01", "Save"), $x + 90, $y, +1, -1)
		$g_hTxtSmartMinGold = GUICtrlCreateInput("150000", $x + 133, $y, 60, 21, BitOR($ES_CENTER, $ES_NUMBER))
			_GUICtrlCreateIcon($g_sLibIconPath, $eIcnGold, $x + 198, $y, 16, 16)
		$g_hTxtSmartMinElixir = GUICtrlCreateInput("150000", $x + 218, $y, 60, 21, BitOR($ES_CENTER, $ES_NUMBER))
			_GUICtrlCreateIcon($g_sLibIconPath, $eIcnElixir, $x + 283, $y, 16, 16)
		$g_hTxtSmartMinDark = GUICtrlCreateInput("1500", $x + 303, $y, 60, 21, BitOR($ES_CENTER, $ES_NUMBER))
			_GUICtrlCreateIcon($g_sLibIconPath, $eIcnDark, $x + 368, $y, 16, 16)
		$x = 150
		$g_hChkResourcesToIgnore[0] =GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "Ignore_01", "Ignore Gold"), $x, $y + 25, -1, -1)
			GUICtrlSetOnEvent(-1, "chkResourcesToIgnore")
		$g_hChkResourcesToIgnore[1] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "Ignore_02", "Ignore Elixir"), $x + 100, $y + 25, -1, -1)
			GUICtrlSetOnEvent(-1, "chkResourcesToIgnore")
		$g_hChkResourcesToIgnore[2] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "Ignore_03", "Ignore DE "), $x + 200, $y + 25, -1, -1)
			GUICtrlSetOnEvent(-1, "chkResourcesToIgnore")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	
	$x = 25
	$y = 90
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "Group_02", "Upgrades to ignore"), $x - 20, $y, $g_iSizeWGrpTab3, 220)
		; one check box per building, names from $g_asUpgradeIgnore, in 2 lists side by side by group (column header = group):
		; left Town Hall / heroes / army / resources, right defenses / traps. One column scrolled down (report mode): the old
		; multi column list (scrolled sideways) hid the last row of each column behind the scroll bar with display scaling
		Local $iLvW = Int(($g_iSizeWGrpTab3 - 21) / 2), $iColW = $iLvW - _WinAPI_GetSystemMetrics($SM_CXVSCROLL) - 6
		$g_hLvUpgradesToIgnore = GUICtrlCreateListView(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "LvIgnoreMain", "TH / Hero / Army / Resource"), 12, $y + 15, $iLvW, 176, BitOR($LVS_REPORT, $LVS_SINGLESEL, $LVS_NOSORTHEADER), BitOR($LVS_EX_CHECKBOXES, $WS_EX_CLIENTEDGE))
		_GUICtrlListView_SetColumnWidth(GUICtrlGetHandle($g_hLvUpgradesToIgnore), 0, $iColW)
		$g_hLvUpgradesToIgnore2 = GUICtrlCreateListView(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "LvIgnoreDefense", "Defense / Trap"), 18 + $iLvW, $y + 15, $iLvW, 176, BitOR($LVS_REPORT, $LVS_SINGLESEL, $LVS_NOSORTHEADER), BitOR($LVS_EX_CHECKBOXES, $WS_EX_CLIENTEDGE))
		_GUICtrlListView_SetColumnWidth(GUICtrlGetHandle($g_hLvUpgradesToIgnore2), 0, $iColW)
		For $i = 0 To UBound($g_asUpgradeIgnore) - 1
			$g_hChkUpgradesToIgnore[$i] = GUICtrlCreateListViewItem(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", $g_asUpgradeIgnore[$i][0], $g_asUpgradeIgnore[$i][0]), _
					$g_asUpgradeIgnore[$i][3] = "D" ? $g_hLvUpgradesToIgnore2 : $g_hLvUpgradesToIgnore)
		Next
		; Reset (nothing ignored) and one button per group: ignore the whole group, or nothing of it when all are ignored
		For $b = 0 To UBound($g_asIgnoreGroupBtn) - 1
			$g_hBtnIgnoreGroup[$b] = GUICtrlCreateButton($g_asIgnoreGroupBtn[$b][0], 12 + $b * 68, $y + 194, 64, 20)
				GUICtrlSetOnEvent(-1, "btnIgnoreGroup")
				_GUICtrlSetTip(-1, $b = 0 ? "Uncheck all (nothing ignored)" : "Ignore all " & $g_asIgnoreGroupBtn[$b][0] & " upgrades, click again to ignore none of them")
		Next
		$y += 200
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	
	$x = 20
	$y += 28
	$g_hChkRushTH = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Traps", "Rush TH", "Rush TH"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkRushTH")
		_GUICtrlSetTip(-1, "Toggle to Make RushTH, Wont Ugrade Defense Or colletor")
	$g_hBtnRushTHOption = GUICtrlCreateButton("Upgrade Setting", $x + 65, $y + 1, -1, 23)
			GUICtrlSetOnEvent(-1, "BtnRushTHOption")
	$x = 180
	$g_hUseWallReserveBuilder = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Traps", "UseWallReserveBuilder", "Use Wall Reserve Builder"), $x, $y, -1, -1)
		GUICtrlSetOnEvent(-1, "chkUseWallReserveBuilder")
		_GUICtrlSetTip(-1, "Use the builder saved for walls (Walls tab) when it is the only free builder:" & @CRLF & "first upgrade in progress ends in 12h or less = any upgrade, later = cheap upgrades only (Gold / Elixir <= 500 000, DE <= 50 000)")
	$g_hUseBuilderPotion = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "ChkUseBuilderPotion", "Use Builder Potion"), $x + 145, $y, 105, -1)
		_GUICtrlSetTip(-1, "Use a Builder Potion (Magic Items) when no builder is free and the first upgrade in progress has 1 day or more left")
	
	$x = 20
	$y += 24
		GUICtrlCreateLabel(GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "LblUpgradeDeadline", "Upgrades must end before (yyyy-mm-dd hh:mm, empty = off):"), $x, $y + 3, 280, -1)
		$g_hTxtUpgradeDeadline = GUICtrlCreateInput("", $x + 285, $y, 110, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
			_GUICtrlSetTip(-1, "Builder, hero, Laboratory and Pet House upgrades start only when they end at least 30 min before this time" & @CRLF & _
					"(ex: 2026-11-01 15:00, builders free for an event). Upgrade time not read = skipped. Ignored after that time")
	$x = 5
		$g_hTxtAutoUpgradeLog = GUICtrlCreateEdit("", $x, 366, $g_iSizeWGrpTab3, 36, BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY))
		GUICtrlSetData(-1, GetTranslatedFileIni("MBR GUI Design - AutoUpgrade", "TxtAutoUpgradeLog", "------------------------------------------------ AUTO UPGRADE LOG ------------------------------------------------"))

EndFunc   ;==>CreateAutoUpgradeGUI

Func CreateRushTHOption()

	; index + 9 = TH level (see IsTHLevelAchieved), last entry never reached = rush all the way
	Local $TxtRushTHOptionTH = "Level 9|Level 10|Level 11|Level 12|Level 13|Level 14|Level 15|Level 16|Level 17|Level 18|Rush to Max Level"
	Local $TxtRushTHOptionBarracks = "2 Unlock Archer|3 Unlock Giant|4 Unlock Goblin|5 Unlock Wall Breaker|" & _
									"6 Unlock Balloon|7 Unlock Wizard|8 Unlock Healer|9 Unlock Dragon|" & _
									"10 Unlock Pekka|11 Unlock Baby Dragon|12 Unlock Miner|13 Unlock Electro Dragon|" & _
									"14 Unlock Yeti|15 Unlock Dragon Rider|16 Unlock Electro Titan|" & _
									"17 Unlock Root Rider|18 Unlock Thrower|19 Unlock Meteor Golem"
	Local $TxtRushTHOptionDarkBarracks = "2 Unlock Hog Rider|3 Unlock Valkyrie|4 Unlock Golem|5 Unlock Witch|" & _
									"6 Unlock Lava Hound|7 Unlock Bowler|8 Unlock Ice Golem|9 Unlock Headhunter|" & _
									"10 Unlock Appr Warden|11 Unlock Druid|12 Unlock Furnace|13 Unlock Ruin Witch"
	Local $TxtRushTHOptionSpellF = "2 Unlock Healing Spell|3 Unlock Rage Spell|4 Unlock Jump & Freeze Spell|5 Unlock Clone Spell|" & _
									"6 Unlock Invisibility Spell|7 Unlock Recall Spell|8 Unlock Revive Spell|9 Unlock Totem Spell"
	Local $TxtRushTHOptionDSpellF = "2 Unlock EarthQuake Spell|3 Unlock Haste Spell|4 Unlock Skeleton Spell|5 Unlock Bat Spell|6 Unlock Overgrowth Spell|" & _
									"7 Unlock Ice Block Spell|8 Unlock Angry Spell"

	$g_hGUI_RushTHOption = _GUICreate(GetTranslatedFileIni("GUI Design Child Village - AutoUpgrade", "GUI_RushTHOption", "Optional Settings: Set Max Level to Upgrade"), 330, 430, $g_iFrmBotPosX, $g_iFrmBotPosY + 200, $WS_DLGFRAME, $WS_EX_TOPMOST)
	Local $x = 25, $y = 25
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - AutoUpgrade", "SelectRushTHOption", "Upgrade To Level :"), $x - 20, $y - 20, 320, 160)
	$x += 10
	$y += 5
	For $i = 0 To Ubound($RushTHOption) - 1
		GUICtrlCreateLabel($RushTHOption[$i] & ":", $x - 19, $y + 3 + 25*$i, -1, 18)
		$g_ahCmbRushTHOption[$i] = GUICtrlCreateCombo("", $x + 90, $y + 25*$i, 185, 18, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
			Switch $i
				Case 0
					GUICtrlSetData(-1,  $TxtRushTHOptionTH, "Rush to Max Level")
				Case 1
					GUICtrlSetData(-1,  $TxtRushTHOptionBarracks, "19 Unlock Meteor Golem")
				Case 2
					GUICtrlSetData(-1,  $TxtRushTHOptionDarkBarracks, "13 Unlock Ruin Witch")
				Case 3
					GUICtrlSetData(-1,  $TxtRushTHOptionSpellF, "9 Unlock Totem Spell")
				Case 4
					GUICtrlSetData(-1,  $TxtRushTHOptionDSpellF, "8 Unlock Angry Spell")
			EndSwitch
	Next
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$x = 25
	$y = 190
	GUICtrlCreateGroup(GetTranslatedFileIni("MBR GUI Design Child Village - AutoUpgrade", "SelectEssentialBuilding", "Select Essential Building to Upgrade :"), $x - 20, $y - 20, 320, 190)
		$x += 10
		$g_hchkEssentialUpgrade[0] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "X-Bow", "X-Bow"), $x, $y, -1, -1)
		GUICtrlSetState(-1, $GUI_ENABLE)
		$y += 20
		$g_hchkEssentialUpgrade[1] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Inferno Tower", "Inferno Tower"), $x, $y, -1, -1)
		GUICtrlSetState(-1, $GUI_ENABLE)
		$y += 20
		$g_hchkEssentialUpgrade[2] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Eagle Artillery", "Eagle Artillery"), $x, $y, -1, -1)
		GUICtrlSetState(-1, $GUI_ENABLE)
		$y += 20
		$g_hchkEssentialUpgrade[3] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Scattershot", "Scattershot"), $x, $y, -1, -1)
		GUICtrlSetState(-1, $GUI_ENABLE)

		$x += 130
		$y = 190
		$g_hchkEssentialUpgrade[4] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Wizard Tower", "Wizard Tower"), $x, $y, -1, -1)
		$y += 20
		$g_hchkEssentialUpgrade[5] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Bomb Tower", "Bomb Tower"), $x, $y, -1, -1)
		$y += 20
		$g_hchkEssentialUpgrade[6] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Air Defense", "Air Defense"), $x, $y, -1, -1)
		$y += 20
		$g_hchkEssentialUpgrade[7] = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "Air Sweeper", "Air Sweeper"), $x, $y, -1, -1)

		$x = 15
		$y += 25
		$g_hUpgradeOnlyTHLevelAchieve = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "OnlyUpgradeIfTHLevelAchieve", "Only Upgrade Buildings If TH Level Already Achieved"), $x, $y, -1, -1)
		$y += 20
		$g_hHeroPriority = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "HeroPriority", "Prioritizes Hero Upgrade"), $x, $y, -1, -1)
		$y += 20
		$g_hUseHeroBooks = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "UserHeroBooks", "Use Hero Books, If UpgradeTime is more than"), $x, $y, -1, -1)
		$g_hHeroMinUpgradeTime = GUICtrlCreateInput("5", $x + 240, $y, 25, 18, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
		GUICtrlCreateLabel("Days", $x + 270, $y + 3)
		$y += 20
		$g_hUpgradeOtherDefenses = GUICtrlCreateCheckbox(GetTranslatedFileIni("MBR Global GUI Design Names Buildings", "UpgradeOtherDefenses", "Upgrades Other Defenses (From Essential Upgrade)"), $x, $y, -1, -1)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$y = 300
	$g_hBtnRushTHOptionClose = GUICtrlCreateButton(GetTranslatedFileIni("MBR GUI Design Child Village - AutoUpgrade", "BtnRushTHOptionClose", "Close"), 230, $y + 65, 85, 25)
		GUICtrlSetOnEvent(-1, "CloseRushTHOption")

EndFunc ;==>CreateRushTHOption
