# Beschreibung

HyperV-VM-Backup-Manager.ps1 ist ein PowerShell-Skript zur automatisierten Sicherung von virtuellen Maschinen in Hyper-V. Das Skript exportiert alle VMs in ein Backup-Verzeichnis, das automatisch basierend auf dem aktuellen Datum erstellt wird. Zusätzlich sorgt es für effizientes Speicherplatzmanagement, indem ältere Backups gelöscht werden, sodass nur eine vordefinierte Anzahl an Sicherungen erhalten bleibt.

## Hauptfunktionen:

### Automatischer Export von Hyper-V-VMs:
Alle virtuellen Maschinen auf dem Host werden exportiert.
Die Exporte werden in einem eigenen Unterverzeichnis gespeichert, das nach dem aktuellen Datum benannt ist (z. B. 17-06-2024).

### Backup-Bereinigung:
Das Skript überwacht die Anzahl der Backups.
Ältere Sicherungen werden automatisch gelöscht, sodass nur eine festgelegte Anzahl an Backups beibehalten wird.

### Protokollierung:
Alle Aktionen werden in einer Logdatei festgehalten.
Erfolgreiche Exporte sowie eventuelle Fehler werden protokolliert, um die Nachvollziehbarkeit zu gewährleisten.

### Anwendungsfall:
Dieses Skript eignet sich ideal für Administratoren, die regelmäßig Sicherungen ihrer Hyper-V-Umgebung durchführen möchten, ohne manuelle Eingriffe vornehmen zu müssen. Es kann problemlos in der Windows-Aufgabenplanung integriert werden, um den Export zu einem bestimmten Zeitpunkt (z. B. täglich oder wöchentlich) automatisch durchzuführen.

## Vorteile:
- Automatisierung: Keine manuelle Exportarbeit mehr erforderlich.
- Speicheroptimierung: Alte Backups werden automatisch bereinigt.
- Transparenz: Detaillierte Protokolle über alle Aktivitäten.
- Benachrichtigungen: Push-Benachrichtigungen informieren bei erfolgreichem Export oder auftretenden Fehlern direkt auf dem Smartphone.
- Zuverlässigkeit: Sicherung der VMs in strukturierten und datumsbasierten Verzeichnissen.

Beispiel für Verzeichnisstruktur nach dem Export:

```bash 
C:\HyperVExports\
│
├── 15-06-2024\
│   ├── VM1\
│   ├── VM2\
│   └── VM3\
│
├── 16-06-2024\
│   ├── VM1\
│   ├── VM2\
│   └── VM3\
│
└── 17-06-2024\
    ├── VM1\
    ├── VM2\
    └── VM3\
```

## Einsatzmöglichkeiten:
- Regelmäßige Sicherung von Hyper-V-Umgebungen.
- Automatische Aufbewahrung der letzten x Backups.
- Nutzung in produktiven und Testumgebungen für Hyper-V-Hosts.


## Download
<a href="https://github.com/KurohKusanagi/Kurohs-Skripte/releases/download/v1.0.0/HyperV-VM-Export-Manager.ps1"><img alt="GitHub Downloads (specific asset, latest release)" src="https://img.shields.io/github/downloads/KurohKusanagi/Kurohs-Skripte/latest/HyperV-VM-Export-Manager.ps1"></a>

## Anforderungen:
Die App <a href="https://docs.ntfy.sh/">ntfy</a> wird benötigt um Benachrichtigungen auf dem Smartphone zu erhalten