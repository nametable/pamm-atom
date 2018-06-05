$ErrorActionPreference = "Stop"
&{
    $WorkingDir = (Split-Path ((Get-Variable MyInvocation -Scope 1).Value).MyCommand.Path)

    $PammDir = $ENV:LOCALAPPDATA + "\Uber Entertainment\Planetary Annihilation\pamm"
    $ElectronDir = "$PammDir"
    $AppDir = "$PammDir\resources\app"
    $env:Path = $env:Path + ";" + $WorkingDir + ";"

    $ReleasesURL = "https://github.com/electron/electron/releases/tag/v2.0.2"
    $RCEditURL = "https://github.com/electron/rcedit/releases/tag/v1.1.0"

    [System.Net.ServicePointManager]::SecurityProtocol = @("Tls12","Tls11","Tls","Ssl3")

    try {
        Write-Host "Find latest Electron release..."
        $Html = (New-Object System.Net.WebClient).DownloadString($ReleasesURL)

        if($Html -match "href=`"(/electron/electron/releases/download/v2.0.2/electron-v2.0.2-win32-x64.zip)") {

            # Prepare PAMM installation folder

            if((Test-Path $PammDir)) {
                Remove-Item -Recurse -Force $PammDir
                Start-Sleep -s 2
            }
            [void](New-Item -ItemType directory -Path $PammDir)

            # Download latest Atom Shell release

            Write-Host "Downloading Electron..."

            $ArchiveURL = "https://github.com" + $Matches[1]
            Write-Host "  from:" $ArchiveURL

            $Archive = $WorkingDir + "\" + $ArchiveURL.Substring($ArchiveURL.LastIndexOf("/")+1)
            Write-Host "  to:" $Archive

            (New-Object System.Net.WebClient).DownloadFile($ArchiveURL, $Archive)

            # Extract Atom Shell

            Write-Host "Extracting Electron Shell..."
            $Shell = New-Object -com shell.application

            if(!(Test-Path $ElectronDir)) {
                [void](New-Item -ItemType directory -Path $ElectronDir)
            }

            $sa = $Shell.NameSpace($Archive)
            foreach($ArchiveItem in $sa.items())
            {
                $Shell.Namespace($ElectronDir).copyhere($ArchiveItem)
            }

            $ModulesArchive = $WorkingDir + "\" + "node_modules.zip"
            $ModulesDir = $WorkingDir + "\app\node_modules"

            if(!(Test-Path $ModulesDir)) {
                [void](New-Item -ItemType directory -Path $ModulesDir)
            }

            $Shell = New-Object -com shell.application
            $sa = $Shell.NameSpace($ModulesArchive)
            foreach($ArchiveItem in $sa.items())
            {
                $Shell.Namespace($ModulesDir).copyhere($ArchiveItem)
            }

            # Rename Electron binary

            Move-Item "$ElectronDir\electron.exe" "$ElectronDir\pamm.exe"

            # Copy PAMM module

            Write-Host "Copying PAMM module..."
            Copy-Item "$WorkingDir\app" $AppDir -Recurse

            #Rebrand Electron

            $Html = (New-Object System.Net.WebClient).DownloadString($RCEditURL)
            $RCEditExecute = $WorkingDir + "\rcedit-x64.exe"
            if($Html -match "href=`"(/electron/rcedit/releases/download/v1.1.0/rcedit-x64.exe)") {
                $RCEditExecuteURL = "https://github.com" + $Matches[1]
                (New-Object System.Net.WebClient).DownloadFile($RCEditExecuteURL, $RCEditExecute)
                $PammExecute = $ElectronDir + '\pamm.exe'
                $PammIcon = $ElectronDir + '\resources\app\assets\img\favicon.ico'
                & rcedit-x64.exe $PammExecute --set-icon $PammIcon
                & rcedit-x64.exe $PammExecute --set-file-version '1.5.0' --set-product-version '1.5.0'
            }

            # Create shortcuts

            Write-Host "Create PAMM shortcut..."
            $WshShell = New-Object -ComObject WScript.Shell
            try {
                $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\PAMM.lnk")
                $Shortcut.TargetPath = "`"$ElectronDir\pamm.exe`""
                $Shortcut.Arguments = ""
                $Shortcut.Save()
            }
            catch {
                Write-Host "An error occurred during the shortcut creation." -ForegroundColor Red
            }

            # Register protocol
            # http://msdn.microsoft.com/en-us/library/ie/aa767914%28v=vs.85%29.aspx
        
            Write-Host "Register pamm:// protocol.."

            if((Test-Path HKCU:\Software\Classes\pamm)) {
                Remove-Item -Path HKCU:\Software\Classes\pamm -Recurse
            }

            [void](New-Item -Path HKCU:\Software\Classes\pamm -Value "URL:pamm Protocol")
            [void](New-ItemProperty -Path HKCU:\Software\Classes\pamm -Name "URL Protocol" -PropertyType String -Value "")
            [void](New-Item -Path HKCU:\Software\Classes\pamm\DefaultIcon -Value "$AppDir\assets\img\favicon.ico")
            [void](New-Item -Path HKCU:\Software\Classes\pamm\shell)
            [void](New-Item -Path HKCU:\Software\Classes\pamm\shell\open)
            [void](New-Item -Path HKCU:\Software\Classes\pamm\shell\open\command -Value "`"$ElectronDir\pamm.exe`" `"%1`"")

            Write-Host "PAMM has been successfully installed." -ForegroundColor Green
            Write-Host "  => $PammDir" -ForegroundColor Green
            
            # Start PAMM
            
            Start-Process "cmd.exe" "/C start pamm.exe" -WorkingDirectory $ElectronDir
        }
        else {
            Write-Host "Electron release not found." -ForegroundColor Red
            Exit 1
        }
    }
    catch {
        Write-Host "An unexpected error occurred:" $_.Exception.Message -ForegroundColor Red
        Exit 2
    }

    #Cleanup
    Remove-Item -Path $RCEditExecute
    Remove-Item -Path $Archive
    Remove-Item -Recurse -Force $ModulesDir
}