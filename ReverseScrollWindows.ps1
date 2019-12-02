<#
    .SYNOPSIS
    Flip the default scroll direction for all active scrolling devices in the
    system

    .DESCRIPTION
    This PowerShell script will flip the default scroll direction for all
    active scrolling devices in the system. This makes them behave like a
    touchscreen or a Mac. This is the reverse of the Windows default
    behavior.

    After running the script, scrolling down moves the contents of the
    window down and scrolling up moves the contents of the window up -
    reverse of what happens on Windows.

    The -Reset commandline argument will reset it back to the Windows
    default behavior for all scrolling devices on this computer

    If you install a new device, you will have to re-run this script.

    .PARAMETER Reset
    Resets the scrolling behavior to the Windows default for all scrolling
    devices on this computer.

    .INPUTS
    None. You cannot pipe objects to ReverseScrollWindows.

    .OUTPUTS
    None.

    .EXAMPLE
    C:\PS> ReverseScrollWindows

    .EXAMPLE
    C:\PS> ReverseScrollWindows -Reset

    .LINK
    Online version: https://github.com/ppk007/ReverseScrollWindows
#>

<#
MIT License

Copyright (c) [2019] [Pravin Kumar]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

# This script ensures administrator privileges because it writes to the registry and it tries to restart the computer.
#
#Requires -RunAsAdministrator

# Handle parameters
#
param([switch]$Reset = $false)

# Path in the registry for HID compliant mouse devices
#
#$HIDPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\HID"
$HIDPath = "HKLM:\SYSTEM\CurrentControlSet\Enum"

# Name of the directory in the registry that containst FlipFlopWheel
#
$DevParams = "Device Parameters"

# Name of the registry key to reverse the scroll
#
$FlipFlopWheel = "FlipFlopWheel"

# The value of $FlipFlopWheel is 1 unless $Reset is used.
#
$regKeyVal = 1

if ($Reset) {
    $regKeyVal = 0
}

# For enhancement: The script should allow the user to individually flip the scrolling device - NOT CURRENTLY IMPLEMENTED
#

if ($regKeyVal) {
    Write-Output "This script will reverse the scrolling direction for all devices on this computer."
    Write-Output "Scrolling up will scroll the contents of the window up and vice versa."
    Write-Output "This is the way scrolling works on touchscreens as well as Mac OS."
}
else {
    Write-Output "This script will set the scrolling direction for all devices on this computer."
    Write-Output "Scrolling up will scroll the contents of the window down and vice versa."
    Write-Output "This is the way scrolling works by default on Windows."
}
$ans = Read-Host "Continue? Y|N [Y]"

if ($ans -eq "N" -or $ans -eq "n") {
    Exit
}

# Get the device id (pnpDeviceID) of all the active HID compliant mouse devices
# and operate on each device.
#
 Get-WmiObject win32_PointingDevice | Where-Object { $_.Description -match "HID-compliant mouse"} | 
    Select-Object -ExpandProperty pnpDeviceID | ForEach-Object {

        # Construct the path to the DeviceParams registry directory
        #
        $hidDevParams = "$HIDPath\$_\$DevParams"
        Write-Verbose "Setting $hidDevParams\$FlipFlopWheel"

        # Then check if the $FlipFlopWheel key exists and set it to the
        # appropriate value if it does.
        #
        if (Get-ItemProperty -Path "$hidDevParams" -name $FlipFlopWheel -ErrorAction SilentlyContinue) {
            Set-ItemProperty -Path "$hidDevParams" -Name $FlipFlopWheel -Value $regKeyVal -Force | Out-Null
            Write-Verbose "Set $$hidDevParams\$FlipFlopWheel"
        }

    }
# The setting will not take effect until the computer is restarted. Ask the user if the computer can be restarted now.
#
$ans = Read-Host "Restart computer? Y|N [N] "

if ($ans -eq "Y" -or $ans -eq "y") {
    Restart-Computer
}
else {
    Write-Output "Exiting without restarting. The scroll settings will not take effect until the computer is restarted."
}