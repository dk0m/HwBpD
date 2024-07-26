
# HwBpD

Utilizing Hardware Breakpoints For Hooking In D.

## Compilation
To run the HwBpD example, Execute this:

```
$ rdmd example.d
```

To compile it, Run this:

```
$ dmd example.d
```

## Examples

```d
// MessageBoxA Hook
void msgBoxAHook(PCONTEXT ctxRec) {

    LPCSTR title = "Hooked!";
    LPCSTR caption = "Get Hooked!";

    SETPARAM_2(ctxRec, cast(ULONG_PTR)title);
    SETPARAM_3(ctxRec, cast(ULONG_PTR)caption);

    CONTINUE_EXECUTION(ctxRec);
}
```
