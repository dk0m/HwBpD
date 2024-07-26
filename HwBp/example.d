module example;

import std.stdio;
import core.sys.windows.windows;

import hwbp;

void main() {

    initHwBpVars();

    PVOID fnAddr = GetProcAddress(GetModuleHandleA("user32"), "MessageBoxA");

    PVOID hookFn = &msgBoxAHook;
    setHwBp(fnAddr, hookFn, Drx.Dr0);

    MessageBoxA(
        NULL,
        "yo",
        "yo",
        0
    );

    removeHwBp(Drx.Dr0);

    MessageBoxA(
        NULL,
        "This Will Run Fine!",
        ":)",
        0
    );


    unInitHwBpVars();
     
}