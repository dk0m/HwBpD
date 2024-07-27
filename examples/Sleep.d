import std.stdio;
import core.sys.windows.windows;

// Make Sure To Include The HwBp File In The Same Directory To Compile
import hwbp;

// Sleep Detour Example, Not Allowing Sleep Call
void sleepDetour(PCONTEXT ctxRec) {

    writeln("[*] Sleep's Old Parameters: ");

    DWORD timeToSleep = cast(DWORD)(GETPARAM_1(ctxRec));
    
    writefln("\t> %d", timeToSleep);

    BLOCK_REAL(ctxRec);

    CONTINUE_EXECUTION(ctxRec);
}

void main() {
    
    if (!initHwBpVars()) {
        writeln("[-] Failed To Initialize Hardware BreakPoint Variables.");
        return;
    }

    setHwBp(&Sleep, &sleepDetour, Drx.Dr0);

    Sleep(3000);

    removeHwBp(Drx.Dr0);
}