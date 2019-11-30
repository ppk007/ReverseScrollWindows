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

#Requires -RunAsAdministrator

# This PowerShell script will flip the default scroll direction for all scrolling devices in the system. This makes them
# behave like a Mac.
# Scrolling down moves the window down and scrolling up moves the window up. This is the reverse of what happens on
# Windows.
#

# Path in the registry for mouse devices
#
$HIDPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\HID"

# Name of the registry key to reverse the scroll
#
$FlipFlopWheel = "FlipFlopWheel"

# Name of the directory in the registry that containst FlipFlopWheel
#
$DevParams = "Device Parameters"

# For enhancement: The script should allow the user to individually flip the scrolling device - NOT CURRENTLY IMPLEMENTED
#
$AskForEach = $false

Write-Output "This script will reverse the scrolling direction on on this computer - scrolling up scrolls the window up and vice versa."
Write-Output "Some people find this more intuitive."
$ans = Read-Host "Continue? Y|N [Y]"

if ($ans -eq "N" -or $ans -eq "n") {
    Exit
}

# For every child item in $HIDPath, check if there is a child (grandchild of $HIDPath) of the form "Device Parameters\FlipFlopWheel".
# We are looking for keys that look like $HIDPath\<child>\<grandchild/Device Parameters\FlipFlopWheel. If one exists, set the
# value to 1.
#
Get-ChildItem -Path $HIDPath | ForEach-Object { 
    $hidChild = "Registry::$_"
    Write-Verbose "Looking at $hidChild ..."
    Get-ChildItem -Path $hidChild | ForEach-Object {
        $hidGrandChild = "Registry::$_"
        Write-Verbose "Looking at GC $hidGrandChild for $DevParams/$FlipFlopWheel"
        # If there is a FlipFlopWheel key, set it to 1
        #
        if (Get-ItemProperty -Path "$hidGrandChild\$DevParams" -name $FlipFlopWheel -ErrorAction SilentlyContinue) {
            Write-Verbose "Setting $hidGrandChild\$DevParams/$FlipFlopWheel ..."
            Set-ItemProperty -Path "$hidGrandChild\$DevParams" -Name $FlipFlopWheel -Value 1 -Force | Out-Null
        }
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