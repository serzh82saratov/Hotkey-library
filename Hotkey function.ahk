
	;  http://forum.script-coding.com/viewtopic.php?pid=69765#p69765

Hotkey_Control(State=1)  {
	Static IsStart
	If (!IsStart)
		Hotkey_ExtKeyInit(State), IsStart := 1
	Hotkey_WindowsHookEx(!!State)
	#HotkeyInterval 0
}

Hotkey_Main(In)  {
	Static K:={}, ModsOnly, Prefix := {"Alt":"!","Ctrl":"^","Shift":"+","Win":"#"}
		, LRPrefix := {"LAlt":"<!","LCtrl":"<^","LShift":"<+","LWin":"<#"
				,"RAlt":">!","RCtrl":">^","RShift":">+","RWin":">#"}
		, VkMouse := {"LButton":"vk1","RButton":"vk2","MButton":"vk4","WheelDown":"vk9E","WheelUp":"vk9F"
				,"WheelRight":"vk9D","WheelLeft":"vk9C","XButton1":"vk5","XButton2":"vk6"}
		, Symbols := "|vkBA|vkBB|vkBC|vkBD|vkBE|vkBF|vkC0|vkDB|vkDC|vkDD|vkDE|vk41|vk42|"
				. "vk43|vk44|vk45|vk46|vk47|vk48|vk49|vk4A|vk4B|vk4C|vk4D|vk4E|"
				. "vk4F|vk50|vk51|vk52|vk53|vk54|vk55|vk56|vk57|vk58|vk59|vk5A|"
	Local IsMod, sIsMod

	IsMod := In.IsMod, K.ModUp := 0
	If (In.Opt = "Down")
	{
		If (K["M" IsMod] != "")
			Return 1
		sIsMod := SubStr(IsMod, 2)
		K["M" sIsMod] := sIsMod "+", K["P" sIsMod] := Prefix[sIsMod]
		K["M" IsMod] := IsMod "+", K["P" IsMod] := LRPrefix[IsMod]
	}
	Else If (In.Opt = "Up")
	{
		sIsMod := SubStr(IsMod, 2)
		K.ModUp := 1, K["M" IsMod] := K["P" IsMod] := ""
		If (K["ML" sIsMod] = "" && K["MR" sIsMod] = "")
			K["M" sIsMod] := K["P" sIsMod] := ""
		If (K.HK != "")
			Return 1
	}
	Else If (In.Opt = "OnlyMods")
	{
		If !ModsOnly
			Return 0
		K.MCtrl := K.MAlt := K.MShift := K.MWin := K.Mods := ""
		K.PCtrl := K.PAlt := K.PShift := K.PWin := K.Pref := ""
		K.PRCtrl := K.PRAlt := K.PRShift := K.PRWin := ""
		K.PLCtrl := K.PLAlt := K.PLShift := K.PLWin := K.LRPref := ""
		K.MRCtrl := K.MRAlt := K.MRShift := K.MRWin := ""
		K.MLCtrl := K.MLAlt := K.MLShift := K.MLWin := K.LRMods := ""
		Func(Hotkey_Arr("Func")).Call(K)
		Return ModsOnly := 0
	}
	Else If (In.Opt = "GetMod")
		Return K.PCtrl K.PAlt K.PShift K.PWin

	K.VK := In.VK, K.SC := In.SC, K.NFP := In.NFP
	K.Mods := K.MCtrl K.MAlt K.MShift K.MWin
	K.LRMods := K.MLCtrl K.MRCtrl K.MLAlt K.MRAlt K.MLShift K.MRShift K.MLWin K.MRWin
	K.TK := GetKeyName(K.VK K.SC), K.TK := K.TK = "" ? K.VK K.SC : K.TK
	(IsMod) ? (K.HK := K.Pref := K.LRPref := K.Name := "", ModsOnly := K.Mods = "" ? 0 : 1)
	: (K.HK := InStr(Symbols, "|" K.VK "|") ? K.VK : K.TK
	, K.Name := K.HK = "vkBF" ? "/" : K.TK
	, (StrLen(K.Name) = 1 ? (K.TK := K.Name := Format("{:U}", K.Name)) : 0)
	, K.Pref := K.PCtrl K.PAlt K.PShift K.PWin
	, K.LRPref := K.PLCtrl K.PRCtrl K.PLAlt K.PRAlt K.PLShift K.PRShift K.PLWin K.PRWin
	, ModsOnly := 0)
	Func(Hotkey_Arr("Func")).Call(K)
	Return 1

Hotkey_PressName:
	K.Mods := K.MCtrl K.MAlt K.MShift K.MWin
	K.LRMods := K.MLCtrl K.MRCtrl K.MLAlt K.MRAlt K.MLShift K.MRShift K.MLWin K.MRWin
	K.Pref := K.PCtrl K.PAlt K.PShift K.PWin
	K.LRPref := K.PLCtrl K.PRCtrl K.PLAlt K.PRAlt K.PLShift K.PRShift K.PLWin K.PRWin
	K.HK := K.Name := K.TK := A_ThisHotkey, ModsOnly := 0, K.SC := "", K.NFP := 0
	K.VK := !InStr(A_ThisHotkey, "Joy") ? VkMouse[A_ThisHotkey] : ""
	Func(Hotkey_Arr("Func")).Call(K)
	Return 1
}

Hotkey_ExtKeyInit(Options)   {
	Local S_FormatInteger, MouseKey
	#If Hotkey_Arr("Hook")
	#If Hotkey_Arr("Hook") && !Hotkey_Main({Opt:"GetMod"})
	#If Hotkey_Arr("Hook") && Hotkey_Main({Opt:"GetMod"})
	#If
	IfInString, Options, M
	{
		MouseKey := "MButton|WheelDown|WheelUp|WheelRight|WheelLeft|XButton1|XButton2"
		Hotkey, IF, Hotkey_Arr("Hook")
		Loop, Parse, MouseKey, |
			Hotkey, %A_LoopField%, Hotkey_PressName
	}
	IfInString, Options, L
	{
		Hotkey, IF, Hotkey_Arr("Hook") && Hotkey_Main({Opt:"GetMod"})
		Hotkey, LButton, Hotkey_PressName
	}
	IfInString, Options, R
	{
		Hotkey, IF, Hotkey_Arr("Hook")
		Hotkey, RButton, Hotkey_PressName
	}
	IfInString, Options, J
	{
		S_FormatInteger := A_FormatInteger
		SetFormat, IntegerFast, D
		Hotkey, IF, Hotkey_Arr("Hook") && !Hotkey_Main({Opt:"GetMod"})
		Loop, 128
			Hotkey % Ceil(A_Index/32) "Joy" Mod(A_Index-1,32)+1, Hotkey_PressName
		SetFormat, IntegerFast, %S_FormatInteger%
	}
	Hotkey, IF
}

Hotkey_Arr(P*) {
	Static Arr := {}
	Return P.MaxIndex() = 1 ? Arr[P[1]] : (Arr[P[1]] := P[2])
}

Hotkey_Reset()  {
	Return Hotkey_Arr("Hook", 0), Hotkey_Main({Opt:"OnlyMods"})
}

	;  http://forum.script-coding.com/viewtopic.php?id=6350

Hotkey_LowLevelKeyboardProc(nCode, wParam, lParam)  {
	Static Mods := {"vkA4":"LAlt","vkA5":"RAlt","vkA2":"LCtrl","vkA3":"RCtrl"
		,"vkA0":"LShift","vkA1":"RShift","vk5B":"LWin","vk5C":"RWin"}
		, oMem := [], HEAP_ZERO_MEMORY := 0x8, Size := 16, hHeap := DllCall("GetProcessHeap", Ptr)
	Local pHeap, Wp, Lp, Ext, VK, SC, IsMod, Time, NFP
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
			If Hotkey_Arr("Hook")
			{
				Wp := oMem[1][1], Lp := oMem[1][2]
				VK := Format("vk{:X}", NumGet(Lp + 0, "UInt"))
				Ext := NumGet(Lp + 0, 8, "UInt")
				SC := Format("sc{:X}", (Ext & 1) << 8 | NumGet(Lp + 0, 4, "UInt"))
				NFP := Ext & 16			;  Не физическое нажатие
				Time := NumGet(Lp + 12, "UInt")
				IsMod := Mods[VK]
				If Hotkey_Arr("Hook") && (Wp = 0x100 || Wp = 0x104)		;  WM_KEYDOWN := 0x100, WM_SYSKEYDOWN := 0x104
					IsMod ? Hotkey_Main({VK:VK, SC:SC, Opt:"Down", IsMod:IsMod, NFP:NFP, Time:Time})
					: Hotkey_Main({VK:VK, SC:SC, NFP:NFP, Time:Time})
				Else If Hotkey_Arr("Hook") && (Wp = 0x101 || Wp = 0x105)		;  WM_KEYUP := 0x101, WM_SYSKEYUP := 0x105
					IsMod ? Hotkey_Main({VK:VK, SC:SC, Opt:"Up", IsMod:IsMod, NFP:NFP, Time:Time}) : 0
			}
			DllCall("HeapFree", Ptr, hHeap, UInt, 0, Ptr, Lp)
			oMem.RemoveAt(1)
		}
		Return
}

Hotkey_WindowsHookEx(State)  {
	Static Hook
	If State
		Hook := DllCall("SetWindowsHookEx" . (A_IsUnicode ? "W" : "A")
				, "Int", 13   ;  WH_KEYBOARD_LL
				, "Ptr", RegisterCallback("Hotkey_LowLevelKeyboardProc", "Fast")
				, "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr")
				, "UInt", 0, "Ptr")
	Else
		DllCall("UnhookWindowsHookEx", "Ptr", Hook), Hook := "", Hotkey_Reset()
}
