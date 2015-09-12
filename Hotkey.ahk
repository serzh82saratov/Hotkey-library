
	;  http://forum.script-coding.com/viewtopic.php?id=8343

Hotkey_Init(Controls, Options = "") {
	Static IsStart
	Local D1, D2, D, S_FormatInteger, IsFocus, FocusHwnd, Hwnd
	S_FormatInteger := A_FormatInteger
	SetFormat, IntegerFast, H
	Loop, Parse, Controls, |
	{
		RegExMatch(A_LoopField, "S)(.*:)?\s*(.*)", D)
		GuiControlGet, Hwnd, % (D1 = "" ? "1:" : D1) "Hwnd", %D2%
		Hotkey_Arr(Hwnd, D2)
		GuiControl, %D1%+ReadOnly, %D2%
	}
	SetFormat, IntegerFast, %S_FormatInteger%
	If !IsStart
		Hotkey_SetWinEventHook(0x8005, 0x8005, 0, RegisterCallback("Hotkey_WinEvent", "F"), 0, 0, 0)   ;  EVENT_OBJECT_FOCUS := 0x8005
		, Hotkey_ExtKeyInit(Options), Hotkey_Arr("hHook", Hotkey_SetWindowsHookEx()), IsStart := 1
	ControlGetFocus, IsFocus, A
	ControlGet, FocusHwnd, Hwnd,, %IsFocus%, A
	If Hotkey_Arr(FocusHwnd)
		Hotkey_WinEvent(0, 0, FocusHwnd)
	Return
}

Hotkey_Main(Param1, Param2=0, Param3=0) {
	Static OnlyMods, VarName, ControlHandle, Hotkey, KeyName
		, MCtrl, MAlt, MShift, MWin, PCtrl, PAlt, PShift, PWin, Prefix
		, Pref := {"Alt":"!","Ctrl":"^","Shift":"+","Win":"#"}
		, Symbols := "|vkBA|vkBB|vkBC|vkBD|vkBE|vkBF|vkC0|vkDB|vkDC|vkDD|vkDE|vk41|vk42|"
					. "vk43|vk44|vk45|vk46|vk47|vk48|vk49|vk4A|vk4B|vk4C|vk4D|vk4E|"
					. "vk4F|vk50|vk51|vk52|vk53|vk54|vk55|vk56|vk57|vk58|vk59|vk5A|"
	Local IsMod, WriteText

	If Param1 = GetMod
		Return MCtrl MAlt MShift MWin = "" ? 0 : 1
	If Param1 = Control
	{
		If Param2
		{
			If OnlyMods
				SendMessage, 0xC, 0, "" Hotkey_Arr("TipNo"), , ahk_id %ControlHandle%
			OnlyMods := 0, ControlHandle := Param2, VarName := Param3
			If !Hotkey_Arr("Hook")
				Hotkey_Arr("Hook", 1)
			SendInput {LButton Up}
			PostMessage, 0x00B1, , , , ahk_id %ControlHandle%   ;  EM_SETSEL
		}
		Else If Hotkey_Arr("Hook")
		{
			Hotkey_Arr("Hook", 0)
			MCtrl := MAlt := MShift := MWin := ""
			PCtrl := PAlt := PShift := PWin := Prefix := ""
			If OnlyMods
				SendMessage, 0xC, 0, "" Hotkey_Arr("TipNo"), , ahk_id %ControlHandle%
		}
		Return
	}
	If Param1 = Mod
	{
		IsMod := Param2
		If (M%IsMod% != "")
			Return 1
		M%IsMod% := IsMod "+", P%IsMod% := Pref[IsMod]
	}
	Else If Param1 = ModUp
	{
		IsMod := Param2, M%IsMod% := P%IsMod% := ""
		If (Hotkey != "")
			Return 1
	}
	(IsMod) ? (KeyName := Hotkey := Prefix := "", OnlyMods := 1)
	: (KeyName := GetKeyName(Param1 Param2)
	,  Hotkey := InStr(Symbols, "|" Param1 "|") ? Param1 : KeyName
	,  KeyName := Hotkey = "vkBF" ? "/" : KeyName
	,  Prefix := PCtrl PAlt PShift PWin, OnlyMods := 0)
	Hotkey_SetVarName(VarName, Prefix Hotkey)
	WriteText := MCtrl MAlt MShift MWin KeyName = "" ? Hotkey_Arr("TipNo") : MCtrl MAlt MShift MWin KeyName
	SendMessage, 0xC, 0, &WriteText, , ahk_id %ControlHandle%
	Return 1

Hotkey_PressName:
	KeyName := Hotkey := A_ThisHotkey
	Prefix := PCtrl PAlt PShift PWin
	OnlyMods := 0
	Hotkey_SetVarName(VarName, Prefix Hotkey)
	WriteText := MCtrl MAlt MShift MWin KeyName
	SendMessage, 0xC, 0, &WriteText, , ahk_id %ControlHandle%
	Return
}

Hotkey_WinEvent(hWinEventHook, event, hwnd) {
	Local Name, S_FormatInteger
	S_FormatInteger := A_FormatInteger
	SetFormat, IntegerFast, H
	Name := Hotkey_Arr(hwnd)
	SetFormat, IntegerFast, %S_FormatInteger%
	(Name = "") ? Hotkey_Main("Control", 0) : Hotkey_Main("Control", hwnd, Name)
}

Hotkey_ExtKeyInit(Options) {
	Local S_FormatInteger, MouseKey
	#IF Hotkey_Arr("Hook")
	#IF Hotkey_Arr("Hook") && Hotkey_Main("GetMod")
	#IF Hotkey_Arr("Hook") && !Hotkey_Main("GetMod")
	#IF
	IfInString, Options, M
	{
		MouseKey := "MButton|WheelDown|WheelUp|WheelRight|WheelLeft|XButton1|XButton2"
		Hotkey, IF, Hotkey_Arr("Hook")
		Loop, Parse, MouseKey, |
			Hotkey, %A_LoopField%, Hotkey_PressName
	}
	IfInString, Options, J
	{
		S_FormatInteger := A_FormatInteger
		SetFormat, IntegerFast, D
		Hotkey, IF, Hotkey_Arr("Hook") && !Hotkey_Main("GetMod")
		Loop, 128
			Hotkey % Ceil(A_Index/32) "Joy" Mod(A_Index-1,32)+1, Hotkey_PressName
		SetFormat, IntegerFast, %S_FormatInteger%
	}
	IfInString, Options, L
	{
		Hotkey, IF, Hotkey_Arr("Hook") && Hotkey_Main("GetMod")
		Hotkey, LButton, Hotkey_PressName
	}
	IfInString, Options, R
	{
		Hotkey, IF, Hotkey_Arr("Hook")
		Hotkey, RButton, Hotkey_PressName
		Hotkey_RButton(1)
	}
	Else
		Hotkey_RButton(0)
	Hotkey, IF
}

Hotkey_LowLevelKeyboardProc(nCode, wParam, lParam) {
	Static Mods := {"vkA4":"Alt","vkA5":"Alt","vkA2":"Ctrl","vkA3":"Ctrl"
		,"vkA0":"Shift","vkA1":"Shift","vk5B":"Win","vk5C":"Win"}
		, oMem := [], HEAP_ZERO_MEMORY := 0x8, Size := 16, hHeap := DllCall("GetProcessHeap", Ptr)
	Local pHeap, Wp, Lp, Ext, VK, SC, IsMod
	Critical

	If !Hotkey_Arr("Hook")
		Return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam)
	pHeap := DllCall("HeapAlloc", Ptr, hHeap, UInt, HEAP_ZERO_MEMORY, Ptr, Size, Ptr)
	DllCall("RtlMoveMemory", Ptr, pHeap, Ptr, lParam, Ptr, Size), oMem.Push([wParam, pHeap])
	SetTimer, Hotkey_LLKPWork, -10
	Return nCode < 0 ? DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam) : 1

	Hotkey_LLKPWork:
		While (oMem[1] != "")
		{
			IF Hotkey_Arr("Hook")
			{
				Wp := oMem[1][1], Lp := oMem[1][2]
				VK := Format("vk{:X}", NumGet(Lp + 0, "UInt"))
				Ext := NumGet(Lp + 0, 8, "UInt")
				SC := Format("sc{:X}", (Ext & 1) << 8 | NumGet(Lp + 0, 4, "UInt"))
				IsMod := Mods[VK]
				If (Wp = 0x100 || Wp = 0x104)		;  WM_KEYDOWN := 0x100, WM_SYSKEYDOWN := 0x104
					(IsMod := Mods[VK]) ? Hotkey_Main("Mod", IsMod) : Hotkey_Main(VK, SC)
				Else IF ((Wp = 0x101 || Wp = 0x105) && VK != "vk5D")   ;  WM_KEYUP := 0x101, WM_SYSKEYUP := 0x105, AppsKey = "vk5D"
					(IsMod := Mods[VK]) ? Hotkey_Main("ModUp", IsMod) : 0
			}
			DllCall("HeapFree", Ptr, hHeap, UInt, 0, Ptr, Lp)
			oMem.RemoveAt(1)
		}
		Return
}

Hotkey_SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags) {
	Return DllCall("SetWinEventHook" , "UInt", eventMin, "UInt", eventMax, "Ptr", hmodWinEventProc
			, "Ptr", lpfnWinEventProc, "UInt", idProcess, "UInt", idThread, "UInt", dwFlags, "Ptr")
}

Hotkey_SetWindowsHookEx() {
	Return DllCall("SetWindowsHookEx" . (A_IsUnicode ? "W" : "A")
		, "Int", 13   ;  WH_KEYBOARD_LL := 13
		, "Ptr", RegisterCallback("Hotkey_LowLevelKeyboardProc", "Fast")
		, "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr")
		, "UInt", 0, "Ptr")
}

Hotkey_Exit() {
	DllCall("UnhookWindowsHookEx", "Ptr", Hotkey_Arr("hHook"))
}

Hotkey_SetVarName(Name, Value) {
	Global
	%Name% := Value
}

Hotkey_Arr(P*) {
	Static Arr := {TipNo:"Нет"}
	Return P.MaxIndex() = 1 ? Arr[P[1]] : (Arr[P[1]] := P[2])
}

Hotkey_IsRegControl() {
	Local Control
	MouseGetPos,,,, Control, 2
	Return Hotkey_Arr(Control) != ""
}

Hotkey_RButton(RM) {
	#IF Hotkey_IsRegControl()
	#IF !Hotkey_Arr("Hook") && Hotkey_IsRegControl()
	#IF
	If RM
		Hotkey, IF, !Hotkey_Arr("Hook") && Hotkey_IsRegControl()
	Else
		Hotkey, IF, Hotkey_IsRegControl()
	Hotkey, RButton Up, Hotkey_RButton
	Hotkey, IF
	Return

	Hotkey_RButton:
		Click
		Return
}

	; -------------------------------------- Format func --------------------------------------

Hotkey_IniRead(Key, Section, Path, SetVar = 0) {
	Local Data
	IniRead, Data, % Path, % Section, % Key, % A_Space
	If SetVar
		Hotkey_SetVarName(Key, Data)
	Return Hotkey_HKToStr(Data)
}

Hotkey_HKToStr(Key) {
	Local K, K1, K2, KeyName
	RegExMatch(Key, "S)^([\^\+!#]*)\{?(.*?)}?$", K)
	If (K2 = "")
		Return "" Hotkey_Arr("TipNo")
	If InStr(K2, "vk")
		KeyName := K2 = "vkBF" ? "/" : GetKeyName(K2)
	Else
		KeyName := K2
	Return (InStr(K1,"^")?"Ctrl+":"")(InStr(K1,"!")?"Alt+":"")
			. (InStr(K1,"+")?"Shift+":"")(InStr(K1,"#")?"Win+":"") KeyName
}

Hotkey_StrToHK(Str) {
	Static Buttons := ":ж:`;:|vkBA| :=:|vkBB| :б:,:|vkBC| :-:|vkBD| :ю:.:|vkBE|"
		. ":/:|vkBF| :``:ё:|vkC0| :х:[:|vkDB| :\:|vkDC| :ъ:]:|vkDD| :э:':|vkDE|"
		. ":A:|vk41| :B:|vk42| :C:|vk43| :D:|vk44| :E:|vk45| :F:|vk46| :G:|vk47|"
		. ":H:|vk48| :I:|vk49| :J:|vk4A| :K:|vk4B| :L:|vk4C| :M:|vk4D| :N:|vk4E|"
		. ":O:|vk4F| :P:|vk50| :Q:|vk51| :R:|vk52| :S:|vk53| :T:|vk54| :U:|vk55|"
		. ":V:|vk56| :W:|vk57| :X:|vk58| :Y:|vk59| :Z:|vk5A|"
	Local K, K1, K2, vk, vk1, vk2

	If (Str = Hotkey_Arr("TipNo") || Str = "" || SubStr(Str, 0) ~= "\+|\s+")
		Return ""
	RegExMatch(Str, "S)(.*\+)?(.*)", K)
	If (StrLen(K2) = 1)
		RegExMatch(Buttons, "Si)\Q:" K2 ":\E.*?\|(.*?)\|", vk)
	Return (InStr(K1,"Ctrl+")?"^":"")(InStr(K1,"Alt+")?"!":"")
		. (InStr(K1,"Shift+")?"+":"")(InStr(K1,"Win+")?"#":"")(vk1 = "" ? K2 : vk1)
}

Hotkey_HKToSend(Key, Section = "", Path = "") {
	Local Data
	If (Section != "")
		IniRead, Data, % Path, % Section, % Key, % A_Space
	Return RegExReplace(Data, "S)[^\^!\+#].*", "{$0}")
}

Hotkey_GetVar(VarName)  {
	Local D, D1, D2, Hwnd, Text
	RegExMatch(VarName, "S)(.*:)?\s*(.*)", D)
	GuiControlGet, Hwnd, % (D1 = "" ? "1:" : D1) "Hwnd", % D2
	ControlGetText, Text,, ahk_id %Hwnd%
	Return Hotkey_StrToHK(Text)
}
