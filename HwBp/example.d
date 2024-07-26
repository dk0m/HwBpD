module example;

import std.stdio;
import core.sys.windows.windows;

import hwbp;

pragma(lib, "user32.lib");

// MessageBoxA Hook Example, Changing Title And Caption.
void msgBoxAHook(PCONTEXT ctxRec) {

    LPCSTR title = "Hooked!";
    LPCSTR caption = "Get Hooked!";

    SETPARAM_2(ctxRec, cast(ULONG_PTR)title);
    SETPARAM_3(ctxRec, cast(ULONG_PTR)caption);

    CONTINUE_EXECUTION(ctxRec);
}

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
