start-transcript C:\temp\FixBITSWriter.log

$BarracudaServce = get-service -name bbagent -erroraction SilentlyContinue
$configPath = "C:/Program Files/Barracuda/Barracuda Backup Agent/config/config.ini"
$configContent = `
"[debug]
vssWriterBlackList=Background Intelligent Transfer Service

[System State.Background Intelligent Transfer Service]
ignore=Yes"

if ($null -eq $BarracudaServce)
    {

        write-host $(Get-Date -Format u) "[Error] $($error.exception.message[0]) Please ensure that the Barracuda Backup Agent is installed"
        exit

    }

write-host $(Get-Date -Format u) "[Information] Attempting to stop the Barracuda Backup Service"

if ($BarracudaServce.status -eq "Running")
    {

        try
            {

                Stop-Service -Name bbagent -ErrorAction Stop

            }
        catch
            {

                write-host $(Get-Date -Format u) "[Error] Unable to stop the Barracuda Backup Service. $($error.exception.message[0])"
                $ServiceStopCatch = $true

            }
        finally
            {

                if ($ServiceStopCatch -ne $true)
                    {

                        write-host $(Get-Date -Format u) "[Information] Barracuda Backup Service stopped successfully"

                    }

            }
    }
else
    {

        write-host $(Get-Date -Format u) "[Error] Barracuda Backup service is not running"
        exit

    }

write-host $(Get-Date -Format u) "[Information] Attempting to set config.ini settings"
$ConfigExists = Test-Path $ConfigPath

if ($ConfigExists -ne $true)
    {

        write-host $(Get-Date -Format u) "[Error] Unable to locate the Barracuda Backup Agent config file. Please ensure that the Barracuda Backup Agent is installed."
        exit

    }
else
    {

        $ContentExists = select-string -path $configPath -Pattern "vssWriterBlackList=Background Intelligent Transfer Service" -Quiet

        if ($ContentExists)
            {

                write-host $(Get-Date -Format u) "[Error] config.ini already set correct"
                exit

            }
        else
            {
                try
                    {

                        add-content $configPath -Value $configContent -ErrorAction stop

                    }
                catch
                    {

                        write-host $(Get-Date -Format u) "[Error] Unable to add content to config.ini. $($error.exception.message[0])"
                        $AddContentCatch = $true

                    }
                finally
                    {
                        if ($AddContentCatch -ne $true)
                        {

                            write-host $(Get-Date -Format u) "[Information] Barracuda config file successfully amended"

                        }

                    }

            }

    }

write-host $(Get-Date -Format u) "[Information] Attempting to start the Barracuda Backup Service"
try
    {

        Start-Service -Name bbagent -ErrorAction Stop

    }
catch
    {

        write-host $(Get-Date -Format u) "[Error] Unable to start the Barracuda Backup Service. $($error.exception.message[0])"
        $ServiceStartCatch = $true

    }
finally
    {

        if ($ServiceStartCatch -ne $true)
            {

                write-host $(Get-Date -Format u) "[Information] Barracuda Backup Service started successfully"

            }

    }

Stop-Transcript