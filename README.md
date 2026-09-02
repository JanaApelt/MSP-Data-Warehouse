# MSP Data Warehouse | Data Engineering Project

## Projektübersicht

Konzeption und technische Umsetzung einer vollständigen **Data-Warehouse-Architektur für ein fiktives Managed-Service-Provider-/VMS-Szenario**.

Ziel des Projekts war es, operative VMS-Daten aus verschiedenen CSV-Quelldateien strukturiert aufzubereiten und für spätere Analysen und KPI-Auswertungen in einem Data Warehouse bereitzustellen.

## Architektur

**CSV-Quelldaten → Staging → Cleaning/Transformation → Business Database → Data Warehouse**

Umgesetzt wurden:

- relationale Business-Datenbank für VMS-Daten
- Staging Area (`stg`) für Rohdaten
- Cleaning Area (`cln`) zur Datenbereinigung und Standardisierung
- Business Schema (`vms`) für bereinigte operative Daten
- separates Data Warehouse mit Star Schema (`dwh`)
- Faktentabelle `FactMSP`
- Dimensionen für Zeit, Anfrage, Kandidat, Lieferant und Hiring Manager

## ETL-Prozess

Der ETL-Prozess wurde mit **SQL Stored Procedures** automatisiert:

1. **Extract** – CSV-Dateien per `BULK INSERT` in die Staging Area laden
2. **Transform** – Datentypen, Datums- und Textformate bereinigen und standardisieren sowie Datenqualität sicherstellen
3. **Load Business DB** – bereinigte Daten in das VMS-Schema laden
4. **Load Dimensions** – Dimensionstabellen des Data Warehouse befüllen
5. **Load Facts** – Kennzahlen berechnen und `FactMSP` laden

Eine übergeordnete ETL-Steuerung führt die einzelnen Ladeprozesse in definierter Reihenfolge aus.

## Data-Warehouse-Modell

Das Star Schema wurde aus konkreten Business-Fragen entwickelt und ermöglicht unter anderem die Analyse von:

- Time to Hire
- angebotenen und finalen Tagessätzen
- Abweichungen zum maximalen Tagessatz
- Anzahl der Kandidatenübermittlungen
- Interviews und Selections
- Work Orders

Für historische Änderungen wurden verschiedene **Slowly Changing Dimension (SCD)**-Strategien konzeptionell berücksichtigt.

## Technologien & Methoden

`SQL Server` · `T-SQL` · `SSMS` · `Stored Procedures` · `ETL` · `BULK INSERT` · `Data Cleaning` · `Data Mapping` · `Star Schema` · `Fact & Dimension Tables` · `SCD` · `Data Warehouse`

## Kernerkenntnis

Das Projekt verbindet meine langjährige Erfahrung mit **MSP-/VMS-Prozessen und KPIs** mit Data Engineering: von operativen Rohdaten über Datenbereinigung und Modellierung bis zu einer strukturierten Datenbasis für Business Analytics.
