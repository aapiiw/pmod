#include-once

Global $g_aCapitalDeployArea

Func CapitalPrepareAttack()
	AndroidZoomout()
	
EndFunc

Func SearchDeployArea()
	Local $aArea
	$aArea = QuickMIS("CNX", $g_sImgAttackDeployArea)
	If IsArray($aArea) And UBound($aArea) > 0 Then
		RemoveDupCNX($aArea)
		_ArraySort($aArea, 0, 0, 0, 1)
	EndIf
	Return $aArea
EndFunc
