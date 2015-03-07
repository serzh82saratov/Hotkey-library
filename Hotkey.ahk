Hotkey_Init(Controls, Options = "")  {
	Static IsStart
	SaveFormat := A_FormatInteger
	SetFormat, IntegerFast, H
	Loop, Parse, Controls, |
	{
		RegExMatch(A_LoopField, "S)(.*:)?\s*(.*)", D)
		GuiControlGet, Hwnd, % (D1 = "" ? "1:" : D1) "Hwnd", %D2%
		Hotkey_Arr(Hwnd, D2, 1)
		GuiControl, %D1%+ReadOnly, %D2%
	}
	SetFormat, IntegerFast, %SaveFormat%
	If !IsStart
		Hotkey_SetWinEventHook(0x8005, 0x8005, 0, RegisterCallback("Hotkey_WinEvent", "F"), 0, 0, 0)   ;  EVENT_OBJECT_FOCUS := 0x8005
		, Hotkey_ExtKeyInit(Options), Hotkey_Arr("hHook", Hotkey_SetWindowsHookEx(), 1), IsStart := 1
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

	If Param1 = GetMod
		Return MCtrl MAlt MShift MWin = "" ? 0 : 1
	If Param1 = Control
	{
		If Param2
		{
			If OnlyMods
				SendMessage, 0xC, 0, "Нет", , ahk_id %ControlHandle%
			OnlyMods := 0, ControlHandle := Param2, VarName := Param3
			If !Hotkey_Arr("Hook")
				Hotkey_Arr("Hook", 1, 1)
			SendInput {LButton Up}
			PostMessage, 0x00B1, , , , ahk_id %ControlHandle%   ;  EM_SETSEL
		}
		Else If Hotkey_Arr("Hook")
		{
			Hotkey_Arr("Hook", 0, 1)
			MCtrl := MAlt := MShift := MWin := ""
			PCtrl := PAlt := PShift := PWin := Prefix := ""
			If OnlyMods
				SendMessage, 0xC, 0, "Нет", , ahk_id %ControlHandle%
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
	WriteText := MCtrl MAlt MShift MWin KeyName = "" ? "Нет" : MCtrl MAlt MShift MWin KeyName
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

Hotkey_WinEvent(hWinEventHook, event, hwnd)   {
	SaveFormat := A_FormatInteger
	SetFormat, IntegerFast, H
	Name := Hotkey_Arr(hwnd)
	SetFormat, IntegerFast, %SaveFormat%
	(Name = "") ? Hotkey_Main("Control", 0) : Hotkey_Main("Control", hwnd, Name)
}


Hotkey_ExtKeyInit(Options)  {
	#IF Hotkey_Arr("Hook")
	#IF Hotkey_Arr("Hook") && Hotkey_Main("GetMod")
	#IF Hotkey_Arr("Hook") && !Hotkey_Main("GetMod")
	#IF
	IfInString, Options, M
	{
		Hotkey, IF, Hotkey_Arr("Hook")
		For i, button in ["MButton","WheelDown","WheelUp","WheelRight","WheelLeft","XButton1","XButton2"]
			Hotkey, %button%, Hotkey_PressName
	}
	IfInString, Options, J
	{
		Hotkey, IF, Hotkey_Arr("Hook") && !Hotkey_Main("GetMod")
		Loop, 128
			Hotkey % Ceil(A_Index/32) "Joy" Mod(A_Index-1,32)+1, Hotkey_PressName
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

Hotkey_LowLevelKeyboardProc(nCode, wParam, lParam)  {
	Static Mods := {"vkA4":"Alt","vkA5":"Alt","vkA2":"Ctrl","vkA3":"Ctrl"
			,"vkA0":"Shift","vkA1":"Shift","vk5B":"Win","vk5C":"Win"}, SaveFormat
	If !Hotkey_Arr("Hook")
		Return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam)
	SaveFormat := A_FormatInteger
	SetFormat, IntegerFast, H
	VkCode := "vk" SubStr(NumGet(lParam+0, 0, "UInt"), 3)
		sc := NumGet(lParam+0, 8, "UInt") & 1, sc := sc << 8 | NumGet(lParam+0, 4, "UInt")
	SCCode := "sc" SubStr(sc, 3)
	SetFormat, IntegerFast, %SaveFormat%
	IF (wParam = 0x100 || wParam = 0x104)   ;  WM_KEYDOWN := 0x100, WM_SYSKEYDOWN := 0x104
		(IsMod := Mods[VkCode]) ? Hotkey_Main("Mod", IsMod) : Hotkey_Main(VkCode, SCCode)
	Else IF ((wParam = 0x101 || wParam = 0x105) && VkCode != "vk5D")   ;  WM_KEYUP := 0x101, WM_SYSKEYUP := 0x105, AppsKey = "vk5D"
		nCode := -1, (IsMod := Mods[VkCode]) ? Hotkey_Main("ModUp", IsMod) : 0
	Return nCode < 0 ? DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam) : 1
}

Hotkey_SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags) {
	Return DllCall("SetWinEventHook" , "UInt", eventMin, "UInt", eventMax, "Ptr", hmodWinEventProc
			, "Ptr", lpfnWinEventProc, "UInt", idProcess, "UInt", idThread, "UInt", dwFlags, "Ptr")
}

Hotkey_SetWindowsHookEx()   {
	Return DllCall("SetWindowsHookEx" . (A_IsUnicode ? "W" : "A")
		, "Int", 13   ;  WH_KEYBOARD_LL := 13
		, "Ptr", RegisterCallback("Hotkey_LowLevelKeyboardProc", "Fast")
		, "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr")
		, "UInt", 0, "Ptr")
}

Hotkey_Exit()  {
	DllCall("UnhookWindowsHookEx", "Ptr", Hotkey_Arr("hHook"))
}

Hotkey_SetVarName(Name, Value) {
	Global
	%Name% := Value
}

Hotkey_Arr(Key, Value="", Write=0)   {
	Static Arr := {}
	If !Write
		Return Arr[Key]
	Arr[Key] := Value
}

Hotkey_IsRegControl()   {
	MouseGetPos,,,, Control, 2
	Return Hotkey_Arr(Control) != ""
}

Hotkey_RButton(RM)   {
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

Hotkey_IniRead(Key, Section, Path) {
	IniRead, Key, % Path, % Section, % Key, % A_Space
	Return Hotkey_FormatHKToStr(Key)
}

Hotkey_FormatHKToStr(Key) {
	RegExMatch(Key, "S)^([\^\+!#]*)\{?(.*?)}?$", K)
	If (K2 = "")
		Return "Нет"
	If InStr(K2, "vk")
		KeyName := K2 = "vkBF" ? "/" : GetKeyName(K2)
	Else
		KeyName := K2
	Return (InStr(K1,"^")?"Ctrl+":"")(InStr(K1,"!")?"Alt+":"")
			. (InStr(K1,"+")?"Shift+":"")(InStr(K1,"#")?"Win+":"") KeyName
}

Hotkey_FormatStrToHK(Str) {
	Static Buttons := ":ж:`;:|vkBA| :=:|vkBB| :б:,:|vkBC| :-:|vkBD| :ю:.:|vkBE|"
		. ":/:|vkBF| :``:ё:|vkC0| :х:[:|vkDB| :\:|vkDC| :ъ:]:|vkDD| :э:':|vkDE|"
		. ":A:|vk41| :B:|vk42| :C:|vk43| :D:|vk44| :E:|vk45| :F:|vk46| :G:|vk47|"
		. ":H:|vk48| :I:|vk49| :J:|vk4A| :K:|vk4B| :L:|vk4C| :M:|vk4D| :N:|vk4E|"
		. ":O:|vk4F| :P:|vk50| :Q:|vk51| :R:|vk52| :S:|vk53| :T:|vk54| :U:|vk55|"
		. ":V:|vk56| :W:|vk57| :X:|vk58| :Y:|vk59| :Z:|vk5A|"

	If (Str = "Нет" || Str = "" || SubStr(Str, 0) ~= "\+|\s+")
		Return ""
	RegExMatch(Str, "S)(.*\+)?(.*)", K)
	If (StrLen(K2) = 1)
		RegExMatch(Buttons, "Si)\Q:" K2 ":\E.*?\|(.*?)\|", vk)
	Return (InStr(K1,"Ctrl+")?"^":"")(InStr(K1,"Alt+")?"!":"")
		. (InStr(K1,"Shift+")?"+":"")(InStr(K1,"Win+")?"#":"")(vk1 = "" ? K2 : vk1)
}

Hotkey_FormatHKToSend(Key, Section = "", Path = "") {
	If (Section != "")
		IniRead, Key, % Path, % Section, % Key, % A_Space
	Return RegExReplace(Key, "S)[^\^!\+#].*", "{$0}")
}

Hotkey_GetVar(VarName)  {
	RegExMatch(VarName, "S)(.*:)?\s*(.*)", D)
	GuiControlGet, Hwnd, % (D1 = "" ? "1:" : D1) "Hwnd", % D2
	ControlGetText, Text,, ahk_id %Hwnd%
	Return Hotkey_FormatStrToHK(Text)
}
