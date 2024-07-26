module hwbp;

import std.stdio;
import core.sys.windows.windows;

enum Drx {
    Dr0,
    Dr1,
    Dr2,
    Dr3,
}

ulong setDr7Bits(ulong currDr7, int startingBitPos, int nmberOfBitsToModify, ulong newDr7) {

    ulong mask = (1UL << nmberOfBitsToModify) - 1UL;
    ulong NewDr7Register = (currDr7 & ~(mask << startingBitPos)) | (newDr7 << startingBitPos);

    return NewDr7Register;

}

// Critical Section Support Will Be Added Later.
PVOID[4] g_DetourFuncs;
PVOID g_Veh;

BOOL setHwBp(PVOID pAddress, PVOID hookFn, Drx drx) {

    CONTEXT threadCtx;
    threadCtx.ContextFlags = CONTEXT_DEBUG_REGISTERS;

    if (!GetThreadContext(cast(HANDLE)-2, &threadCtx)) {
        return FALSE;
    }

    switch(drx) {
        case Drx.Dr0:
            if (!threadCtx.Dr0) {
                threadCtx.Dr0 = cast(ulong)pAddress;
            }
            break;
        
        case Drx.Dr1:
            if (!threadCtx.Dr1) {
                
                threadCtx.Dr1 = cast(ulong)pAddress;
            }
            break;
        
        case Drx.Dr2:
            if (!threadCtx.Dr2) {
                threadCtx.Dr2 = cast(ulong)pAddress;
            }
            break;
        
        case Drx.Dr3:
            if (!threadCtx.Dr3) {
                threadCtx.Dr3 = cast(ulong)pAddress;
            }
            break;

        default:
            break;
    }

    g_DetourFuncs[drx] = hookFn;

    threadCtx.Dr7 = setDr7Bits(threadCtx.Dr7, drx * 2, 1, 1);

    if (!SetThreadContext(cast(HANDLE)-2, &threadCtx)) {
        return FALSE;
    }

    return TRUE;
}

BOOL removeHwBp(Drx drx) {

    CONTEXT threadCtx;
    threadCtx.ContextFlags = CONTEXT_DEBUG_REGISTERS;

    if (!GetThreadContext(GetCurrentThread(), &threadCtx)) {
        return FALSE;
    }

    switch(drx) {
        case Drx.Dr0:
            threadCtx.Dr0 = 0x0;
            break;
        
        case Drx.Dr1:
            threadCtx.Dr1 = 0x0;
            break;
        
        case Drx.Dr2:
            threadCtx.Dr2 = 0x0;
            break;
        
        case Drx.Dr3:
            threadCtx.Dr3 = 0x0;
            break;

        default:
            break;
    }

    threadCtx.Dr7 = setDr7Bits(threadCtx.Dr7, drx * 2, 1, 0);

    if (!SetThreadContext(GetCurrentThread(), &threadCtx)) {
        return FALSE;
    }

    return TRUE;
}


alias fnHook = void function(PCONTEXT);

LONG exceptionHandler(PEXCEPTION_POINTERS pExceptionInfo) {
    if (pExceptionInfo.ExceptionRecord.ExceptionCode == EXCEPTION_SINGLE_STEP) {
        ulong exceptionAddress = cast(ulong)pExceptionInfo.ExceptionRecord.ExceptionAddress;

        if (exceptionAddress == pExceptionInfo.ContextRecord.Dr0 || exceptionAddress == pExceptionInfo.ContextRecord.Dr1 || exceptionAddress == pExceptionInfo.ContextRecord.Dr2 || exceptionAddress == pExceptionInfo.ContextRecord.Dr3) {
                Drx drx = cast(Drx)(-1);

                if (exceptionAddress == pExceptionInfo.ContextRecord.Dr0) {
                    drx = Drx.Dr0;
                }

                if (exceptionAddress == pExceptionInfo.ContextRecord.Dr1) {
                    drx = Drx.Dr1;
                }

                if (exceptionAddress == pExceptionInfo.ContextRecord.Dr2) {
                    drx = Drx.Dr2;
                }

                if (exceptionAddress == pExceptionInfo.ContextRecord.Dr3) {
                    drx = Drx.Dr3;
                }

                removeHwBp(drx);

                fnHook hookFn = cast(fnHook)g_DetourFuncs[drx];

                hookFn(pExceptionInfo.ContextRecord);

                setHwBp(cast(PVOID)exceptionAddress, g_DetourFuncs[drx], drx);

                return EXCEPTION_CONTINUE_EXECUTION;

        }
    }

    return EXCEPTION_CONTINUE_SEARCH;
}


ULONG_PTR getFunctionArg(PCONTEXT threadCtx, DWORD dwParamIndex) {

    switch(dwParamIndex) {
        case 1:
            return cast(ULONG_PTR)threadCtx.Rcx;
        case 2:
            return cast(ULONG_PTR)threadCtx.Rdx;
        case 3:
            return cast(ULONG_PTR)threadCtx.R8;
        case 4:
            return cast(ULONG_PTR)threadCtx.R9;
        default:
            break;
    }

    return *cast(ULONG_PTR*)(threadCtx.Rsp + (dwParamIndex * PVOID.sizeof));

}
VOID setFunctionArg(PCONTEXT threadCtx, ULONG_PTR uVal, DWORD dwParamIndex) {

    switch(dwParamIndex) {
        case 1:
            threadCtx.Rcx = uVal;
            return;
        case 2:
            threadCtx.Rdx = uVal;
            return;
        case 3:
            threadCtx.R8 = uVal;
            return;
        case 4:
            threadCtx.R9 = uVal;
            return;

        default:
            break;
    }

    *cast(ULONG_PTR*)(threadCtx.Rsp + (dwParamIndex * PVOID.sizeof)) = uVal;

}

VOID CONTINUE_EXECUTION(PCONTEXT threadCtx) {
    threadCtx.EFlags = threadCtx.EFlags | (1 << 16);
}

ULONG_PTR GETPARAM_1(PCONTEXT ctx) {
    return getFunctionArg(ctx, 1);
}
ULONG_PTR GETPARAM_2(PCONTEXT ctx) {
    return getFunctionArg(ctx, 2);
}
ULONG_PTR GETPARAM_3(PCONTEXT ctx) {
    return getFunctionArg(ctx, 3);
}
ULONG_PTR GETPARAM_4(PCONTEXT ctx) {
    return getFunctionArg(ctx, 4);
}
ULONG_PTR GETPARAM_5(PCONTEXT ctx) {
    return getFunctionArg(ctx, 5);
}
ULONG_PTR GETPARAM_6(PCONTEXT ctx) {
    return getFunctionArg(ctx, 6);
}
ULONG_PTR GETPARAM_7(PCONTEXT ctx) {
    return getFunctionArg(ctx, 7);
}
ULONG_PTR GETPARAM_8(PCONTEXT ctx) {
    return getFunctionArg(ctx, 8);
}
ULONG_PTR GETPARAM_9(PCONTEXT ctx) {
    return getFunctionArg(ctx, 9);
}
ULONG_PTR GETPARAM_A(PCONTEXT ctx) {
    return getFunctionArg(ctx, 0xA);
}
ULONG_PTR GETPARAM_B(PCONTEXT ctx) {
    return getFunctionArg(ctx, 0xB);
}

VOID SETPARAM_1(PCONTEXT ctx, ULONG_PTR value) {
    setFunctionArg(ctx, value, 1);
}

VOID SETPARAM_2(PCONTEXT ctx, ULONG_PTR value) {
    setFunctionArg(ctx, value, 2);
}

VOID SETPARAM_3(PCONTEXT ctx, ULONG_PTR value) {
    setFunctionArg(ctx, value, 3);
}

VOID SETPARAM_4(PCONTEXT ctx, ULONG_PTR value) {
    setFunctionArg(ctx, value, 4);
}

VOID SETPARAM_5(PCONTEXT ctx, ULONG_PTR value) {
    setFunctionArg(ctx, value, 5);
}

VOID SETPARAM_6(PCONTEXT ctx, ULONG_PTR value) {
    setFunctionArg(ctx, value, 6);
}

VOID SETPARAM_7(PCONTEXT ctx, ULONG_PTR value) {
    setFunctionArg(ctx, value, 7);
}

VOID SETPARAM_8(PCONTEXT ctx, ULONG_PTR value) {
    setFunctionArg(ctx, value, 8);
}

VOID SETPARAM_9(PCONTEXT ctx, ULONG_PTR value) {
    setFunctionArg(ctx, value, 9);
}

VOID SETPARAM_A(PCONTEXT ctx, ULONG_PTR value) {
    setFunctionArg(ctx, value, 0xA);
}

VOID SETPARAM_B(PCONTEXT ctx, ULONG_PTR value) {
    setFunctionArg(ctx, value, 0xB);
}


void initHwBpVars() {
    PVOID excepHandler = &exceptionHandler;
    g_Veh = AddVectoredExceptionHandler(1, cast(PVECTORED_EXCEPTION_HANDLER)excepHandler);
}


void unInitHwBpVars() {

    if (g_Veh) {
        RemoveVectoredExceptionHandler(g_Veh);
    }

    ZeroMemory(&g_DetourFuncs[0], g_DetourFuncs.sizeof);

}

