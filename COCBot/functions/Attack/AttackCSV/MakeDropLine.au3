
Func MakeDropLineOriginal($searchvect, $startpoint, $endpoint)

	SetDebugLog("MakeDropLineOriginal for " & UBound($searchvect) & " points")

	Local $startX = $startpoint[0]
	Local $startY = $startpoint[1]
	Local $endX = $endpoint[0]
	Local $endY = $endpoint[1]

	CheckAttackLocation($startX, $startY)
	CheckAttackLocation($endX, $endY)

	Local $point1 = [$startX, $startY]
	Local $t, $f
	$t = 0
	$f = 0
	Local $ReturnVect = $startX & "," & $startY

	For $i = $startX + 1 To $endX
		For $j = $t To UBound($searchvect) - 1
			Local $pixel = $searchvect[$j]
			If $i < $pixel[0] Then
				Local $h = Line2Points($point1, $pixel, $i)
				CheckAttackLocation($i, $h)
				$ReturnVect &= "|" & $i & "," & $h
				$f = $i
				ExitLoop
			Else
				If $i = $pixel[0] Then
					Local $x = $pixel[0]
					Local $h = $pixel[1]
					CheckAttackLocation($x, $h)
					$ReturnVect &= "|" & $x & "," & $h
					$point1 = $pixel
					$t = $j + 1
					$f = $i
					ExitLoop
				EndIf
			EndIf
		Next
	Next
	For $i = $f + 1 To $endX
		Local $h = Line2Points($point1, $endpoint, $i)
		CheckAttackLocation($i, $h)
		$ReturnVect &= "|" & $i & "," & $h
	Next

	Return GetListPixel($ReturnVect, ",")
EndFunc   ;==>MakeDropLineOriginal
