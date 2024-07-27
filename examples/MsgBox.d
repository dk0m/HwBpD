import std.stdio;
import core.sys.windows.windows;

// Make Sure To Include The HwBp File In The Same Directory To Compile
import hwbp;

pragma(lib, "user32.lib");

// MessageBoxA Hook Example 1, Changing Title And Caption.

void msgBoxAHook(PCONTEXT ctxRec) {

    LPCSTR newTitle = "Get Hooked!";
    LPCSTR newCaption = "Hooked!";

    SETPARAM_2(ctxRec, cast(ULONG_PTR)newTitle);
    SETPARAM_3(ctxRec, cast(ULONG_PTR)newCaption);
    SETPARAM_4(ctxRec, cast(ULONG_PTR)(MB_OK | MB_ICONEXCLAMATION));

    CONTINUE_EXECUTION(ctxRec);

}


// MessageBoxA Detour Example, Calling MessageBoxA Directly And Blocking The Original Call.

void msgBoxADetour(PCONTEXT ctxRec) {

    RETURN_VALUE(ctxRec, cast(ULONG_PTR)(MessageBoxA(NULL, "New Hook!", "Hooked!", 0)));
    BLOCK_REAL(ctxRec);

    CONTINUE_EXECUTION(ctxRec);

}

void main() {

    if (!initHwBpVars()) {
        writeln("[-] Failed To Initialize Hardware BreakPoint Variables.");
        return;
    }

    writeln("[+] Running MessageBoxA Example!");

    setHwBp(&MessageBoxA, &msgBoxADetour, Drx.Dr0);
    
    MessageBoxA(
        NULL,
        "This Will Be Hooked!",
        ":(",
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