Add-Type @"
using System;
using System.Runtime.InteropServices;

public class KeyboardBlocker {
    private static IntPtr hookId = IntPtr.Zero;
    private static HookProc hookProc;
    public delegate IntPtr HookProc(int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr SetWindowsHookEx(int idHook, HookProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr GetModuleHandle(string lpModuleName);

    public static void Block() {
        hookProc = HookCallback;
        hookId = SetWindowsHookEx(13, hookProc, GetModuleHandle(null), 0);
    }

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
        if (nCode >= 0) return (IntPtr)1; // Bloque toutes les touches
        return CallNextHookEx(hookId, nCode, wParam, lParam);
    }

    public static void Unblock() {
        UnhookWindowsHookEx(hookId);
    }
}
"@

[KeyboardBlocker]::Block()

while ($true) {
    Start-Sleep -Seconds 10
}
