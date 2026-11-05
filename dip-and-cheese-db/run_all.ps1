# ============================================================================
# Dip&Cheese - Base de datos del microemprendimiento
# run_all.ps1 - Crea/actualiza el esquema y carga los datos del informe.
#
# Uso:
#   $env:PGPASSWORD = 'tu_password'
#   .\run_all.ps1 -Reset
#
# Requiere PostgreSQL 16+ (psql en PATH o en C:\Program Files\PostgreSQL\16\bin).
# ============================================================================
[CmdletBinding()]
param(
    [string]$Database = 'dipcheese',
    [string]$DbUser   = 'postgres',
    [string]$DbHost   = 'localhost',
    [int]$Port        = 5432,
    [switch]$Reset
)

$ErrorActionPreference = 'Continue'
$env:PGCLIENTENCODING = 'UTF8'
try {
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
    $OutputEncoding = [System.Text.UTF8Encoding]::new()
} catch {
    # Consolas antiguas pueden no soportar UTF-8; no es un error fatal.
}

function Find-Psql {
    $cmd = Get-Command psql -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $candidates = Get-ChildItem 'C:\Program Files\PostgreSQL\*\bin\psql.exe' -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending
    if ($candidates) { return $candidates[0].FullName }

    throw 'No se encontró psql.exe. Instalá PostgreSQL 16+ o agregá su carpeta bin al PATH.'
}

$psql = Find-Psql
$sqlDir = Join-Path $PSScriptRoot 'sql'

$files = @()
if ($Reset) { $files += '00_reset.sql' }
$files += @(
    '01_schema.sql',
    '02_data.sql',
    '03_views.sql',
    '04_queries.sql',
    '05_verificacion.sql'
)

$common = @(
    '--no-psqlrc',
    '-v', 'ON_ERROR_STOP=1',
    '-h', $DbHost,
    '-p', $Port.ToString(),
    '-U', $DbUser,
    '-d', $Database
)

Write-Host "psql:  $psql"
Write-Host "Base:  $Database @ ${DbHost}:$Port"
Write-Host ''

foreach ($file in $files) {
    $path = Join-Path $sqlDir $file
    Write-Host ">> $file"
    # 2>&1 evita que los NOTICE de psql se interpreten como errores en PowerShell.
    & $psql @common -f $path 2>&1 | ForEach-Object { Write-Host $_ }
    if ($LASTEXITCODE -ne 0) {
        throw "Falló $file (código $LASTEXITCODE)."
    }
}

Write-Host ''
Write-Host 'Listo. Verificación ejecutada en sql/05_verificacion.sql.'
