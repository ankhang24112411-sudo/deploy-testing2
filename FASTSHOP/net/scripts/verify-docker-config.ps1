$ErrorActionPreference = 'Stop'

if ($PSScriptRoot) {
    $root = Split-Path -Parent $PSScriptRoot
} else {
    $root = (Get-Location).Path
}
$failures = [System.Collections.Generic.List[string]]::new()

function Require-File {
    param([string] $RelativePath)

    $path = Join-Path $root $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $script:failures.Add("Missing file: $RelativePath")
        return $null
    }

    return Get-Content -LiteralPath $path -Raw
}

$dockerfile = Require-File 'Dockerfile'
$compose = Require-File 'docker-compose.yml'
$envExample = Require-File '.env.example'
$dockerignore = Require-File '.dockerignore'
$properties = Require-File 'src/main/resources/application.properties'

if ($null -ne $dockerfile) {
    if ($dockerfile -notmatch 'FROM\s+.*maven.*\s+AS\s+dependencies') {
        $failures.Add('Dockerfile must use a Maven build stage.')
    }
    if ($dockerfile -notmatch 'mvn\s+clean\s+package\s+-DskipTests') {
        $failures.Add('Dockerfile must build the Spring Boot WAR with Maven.')
    }
    if ($dockerfile -notmatch 'EXPOSE\s+8000') {
        $failures.Add('Dockerfile must expose port 8000.')
    }
}

if ($null -ne $compose) {
    foreach ($required in @('web:', 'db:', 'fastshop-network:', 'mssql-data:', 'SPRING_DATASOURCE_URL', 'SPRING_DATASOURCE_USERNAME', 'SPRING_DATASOURCE_PASSWORD', 'service_healthy')) {
        if ($compose -notmatch [regex]::Escape($required)) {
            $failures.Add("docker-compose.yml must contain $required.")
        }
    }
}

if ($null -ne $envExample) {
    foreach ($required in @('APP_PORT=', 'DB_PORT=', 'DB_NAME=', 'DB_USERNAME=', 'DB_PASSWORD=', 'JPA_DDL_AUTO=', 'MAIL_USERNAME=', 'MAIL_PASSWORD=', 'GOOGLE_CLIENT_ID=', 'GOOGLE_CLIENT_SECRET=', 'FACEBOOK_CLIENT_ID=', 'FACEBOOK_CLIENT_SECRET=')) {
        if ($envExample -notmatch [regex]::Escape($required)) {
            $failures.Add(".env.example must contain $required.")
        }
    }
}

if ($null -ne $dockerignore) {
    foreach ($ignored in @('target/', '.idea/', '.env')) {
        if ($dockerignore -notmatch [regex]::Escape($ignored)) {
            $failures.Add(".dockerignore must ignore $ignored.")
        }
    }
}

if ($null -ne $properties) {
    foreach ($secret in @('05327912', 'DracoNguyen1805', 'GOCSPX-', '3fbca36ef1b362a9ffd1a23b7e416b11')) {
        if ($properties -match [regex]::Escape($secret)) {
            $failures.Add("application.properties still contains a hard-coded secret matching $secret.")
        }
    }
    foreach ($placeholder in @('${SPRING_DATASOURCE_URL:', '${DB_NAME:', '${DB_USERNAME:', '${DB_PASSWORD:', '${SPRING_JPA_HIBERNATE_DDL_AUTO:', '${MAIL_USERNAME:', '${MAIL_PASSWORD:', '${GOOGLE_CLIENT_ID:', '${GOOGLE_CLIENT_SECRET:', '${FACEBOOK_CLIENT_ID:', '${FACEBOOK_CLIENT_SECRET:')) {
        if ($properties -notmatch [regex]::Escape($placeholder)) {
            $failures.Add("application.properties must use env placeholder $placeholder.")
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host 'Docker deployment config verification passed.'
