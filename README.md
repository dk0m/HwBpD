
# HwBpD

Utilizing Hardware Breakpoints For Hooking In D.

## Compilation
To compile any files using the **HwBp** module, Run this:

```
$ dmd YourFile.d -i HwBp.d
```

## Examples

#### MessageBoxA Hook
```d
void msgBoxAHook(PCONTEXT ctxRec) {

    LPCSTR newTitle = "Get Hooked!";
    LPCSTR newCaption = "Hooked!";

    SETPARAM_2(ctxRec, cast(ULONG_PTR)newTitle);
    SETPARAM_3(ctxRec, cast(ULONG_PTR)newCaption);
    SETPARAM_4(ctxRec, cast(ULONG_PTR)(MB_OK | MB_ICONEXCLAMATION));

    CONTINUE_EXECUTION(ctxRec);

}
```

#### MessageBoxA Detour

```d
void msgBoxADetour(PCONTEXT ctxRec) {

    RETURN_VALUE(ctxRec, cast(ULONG_PTR)(MessageBoxA(NULL, "New Hook!", "Hooked!", 0)));
    BLOCK_REAL(ctxRec);

    CONTINUE_EXECUTION(ctxRec);

}
```

#### Sleep Detour

```d
void sleepDetour(PCONTEXT ctxRec) {

    writeln("[*] Sleep's Old Parameters: ");

    DWORD timeToSleep = cast(DWORD)(GETPARAM_1(ctxRec));
    
    writefln("\t> %d", timeToSleep);

    BLOCK_REAL(ctxRec);

    CONTINUE_EXECUTION(ctxRec);
}
```
