# ====================================================================================
# Skript: HyperV-VM-Export-Manager.ps1
# Autor: Daniel Jörges aka Kuroh
# Webseite: www.kurohs-blog.de
#
# Beschreibung: PowerShell-Skript zur automatisierten Sicherung von
#               virtuellen Maschinen in Hyper-V. Das Skript exportiert alle VMs in
#               ein Backup-Verzeichnis, das automatisch basierend auf dem aktuellen
#               Datum erstellt wird. Zusätzlich sorgt es für effizientes
#               Speicherplatzmanagement, indem ältere Backups gelöscht werden,
#               sodass nur eine vordefinierte Anzahl an Sicherungen erhalten bleibt.
#
# Anforderungen: ntfy - https://docs.ntfy.sh/
# ====================================================================================

# ======= Konfiguration =======
# Verzeichnis für den Export
$ExportDir = "C:\HyperVExports"

# Maximale Anzahl von Backups, die beibehalten werden sollen
$KeepBackups = 1

# Protokolldatei
$LogFile = "C:\HyperVExports\ExportLog.txt"

# ntfy Topic an das Nachrichten gesendet werden sollen
$ntfyTopic = "VMBackup"


# ======= Funktionen ========

# Funktion: Log-Schreiben (Konsole + Datei)
function Write-Log {
    param (
        [string]$Message,
        [string]$LogFilePath
    )

    # Zeitstempel hinzufügen
    $timestamp = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
    $logMessage = "[$timestamp] $Message"

    # Ausgabe in Konsole und Logdatei
    Write-Output $logMessage
    $logMessage | Out-File -FilePath $LogFilePath -Encoding utf8 -Append
}

# Funktion: Alte Backups bereinigen
function Remove-OldBackups {
    param (
        [string]$BackupDir,
        [int]$MaxBackups
    )

    Write-Log -Message "Starte Bereinigung alter Backups im Verzeichnis '$BackupDir'..." -LogFilePath $LogFile

    # Alle vorhandenen Backups sortieren (älteste zuerst)
    $backups = Get-ChildItem -Path $BackupDir -Directory | Sort-Object CreationTime

    # Wenn mehr als die maximale Anzahl vorhanden ist, alte löschen
    if ($backups.Count -gt $MaxBackups) {
        $toDelete = $backups | Select-Object -First ($backups.Count - $MaxBackups)

        foreach ($backup in $toDelete) {
            Write-Log -Message "Lösche altes Backup: $($backup.FullName)" -LogFilePath $LogFile
            Remove-Item -Path $backup.FullName -Recurse -Force -ErrorAction Stop
        }
    }
    else {
        Write-Log -Message "Keine alten Backups zum Löschen gefunden." -LogFilePath $LogFile
    }
}

# Funktion: Alle vorhandenen VMs abrufen und Exportieren
function Export-VMs {
    param (
        [string]$ExportDir,
        [string]$LogFile
    )

    # Abrufen und Speichern des aktuellen Datums
    $timestamp = Get-Date -Format "dd-MM-yyyy"
    
    # Alle VMs abrufen
    try {
        $vms = Get-VM
        Write-Log -Message "Gefundene VMs: $($vms.Count)" -LogFilePath $logFile
    }
    catch {
        Write-Log -Message "Fehler beim Abrufen der VMs: $_" -LogFilePath $logFile

        # ntfy Benachrichtigung
        $Request = @{
            Method = "POST"
            URI    = "https://ntfy.sh/$ntfyTopic"
            Body   = "Fehler beim Abrufen der VMs: $_"
        }
        Invoke-RestMethod @Request
        exit 1
    }

    # Schleife, welche alle VMs exportiert
    foreach ($vm in $vms) {
        try {
            $vmExportPath = Join-Path -Path $ExportDir -ChildPath $timestamp
            Write-Log -Message "Exportiere VM '$($vm.Name)' nach '$vmExportPath'..." -LogFilePath $LogFile

            Export-VM -Name $vm.Name -Path $vmExportPath
            Write-Log -Message "Export abgeschlossen: $($vm.Name)" -LogFilePath $LogFile
        }
        catch {
            Write-Log -Message "Fehler beim Exportieren von VM '$($vm.Name)': $_" -LogFilePath $LogFile

            # ntfy Benachrichtigung
            $Request = @{
                Method = "POST"
                URI    = "https://ntfy.sh/$ntfyTopic"
                Body   = "Fehler beim Exportieren von VM '$($vm.Name)': $_"
            }
            Invoke-RestMethod @Request
        }
    }
}

# -------------------------------------
# Main-Funktion
# -------------------------------------
function Main {
    # Startzeit loggen
    Write-Log -Message "Hyper-V-Export-Skript gestartet." -LogFilePath $LogFile

    # Verzeichnis prüfen/erstellen
    if (-not (Test-Path -Path $ExportDir)) {
        Write-Log -Message "Erstelle Exportverzeichnis: $ExportDir" -LogFilePath $LogFile
        New-Item -Path $ExportDir -ItemType Directory | Out-Null
    }

    # VMs exportieren
    Export-VMs -ExportDir $ExportDir -LogFile $LogFile

    # Alte Backups bereinigen
    Remove-OldBackups -BackupDir $ExportDir -MaxBackups $KeepBackups

    # Endzeit loggen
    Write-Log -Message "Hyper-V-Export-Skript abgeschlossen." -LogFilePath $LogFile

    # ntfy Benachrichtigung, dass das Backup erfolgreich ist
    $Request = @{
        Method = "POST"
        URI    = "https://ntfy.sh/$ntfyTopic"
        Body   = "Backup Erfolgreich!"
    }
    Invoke-RestMethod @Request
}

# -------------------------------------
# Skript ausführen
# -------------------------------------
Main