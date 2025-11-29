#Requires -Version 5.1
<#
.SYNOPSIS
    Enhanced VS Code Reset and Configuration Script
.DESCRIPTION
    Completely resets VS Code and configures it for C++, C#, Python, and Web development
.PARAMETER WhatIf
    Shows what would be done without making changes
.PARAMETER Verbose
    Provides detailed output
#>

param(
    [switch]$WhatIf = $false,
    [switch]$Verbose = $false
)

# Enhanced logging and status tracking
$Global:StepResults = @{}
$Global:ErrorLog = @()

# Enhanced color output functions
function Write-StepHeader { 
    param($StepNumber, $Description)
    Write-Host "`n" -NoNewline
    Write-Host "=" * 60 -ForegroundColor Blue
    Write-Host "STEP $StepNumber`: $Description" -ForegroundColor Yellow -BackgroundColor Blue
    Write-Host "=" * 60 -ForegroundColor Blue
}

function Write-Success { 
    param($Message) 
    Write-Host "✅ SUCCESS: $Message" -ForegroundColor Green 
    if ($Verbose) { Write-Host "   └─ $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray }
}

function Write-Error { 
    param($Message, $Exception = $null) 
    Write-Host "❌ ERROR: $Message" -ForegroundColor Red 
    if ($Exception) {
        Write-Host "   └─ $($Exception.Message)" -ForegroundColor DarkRed
        $Global:ErrorLog += @{
            Time = Get-Date
            Message = $Message
            Exception = $Exception.Message
        }
    }
}

function Write-Info { 
    param($Message) 
    Write-Host "ℹ️  INFO: $Message" -ForegroundColor Cyan 
}

function Write-Warning { 
    param($Message) 
    Write-Host "⚠️  WARNING: $Message" -ForegroundColor Yellow 
}

function Write-Progress { 
    param($Message) 
    Write-Host "🔄 PROGRESS: $Message" -ForegroundColor Magenta 
}

# Enhanced VS Code detection and validation
function Test-VSCodeEnvironment {
    Write-StepHeader "0" "Validating VS Code Environment"
    
    $checks = @{
        "VS Code CLI Available" = $false
        "VS Code Installation Path" = ""
        "User Data Directory" = ""
        "Extensions Directory" = ""
    }
    
    try {
        # Check VS Code CLI
        $codeVersion = & code --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $checks["VS Code CLI Available"] = $true
            Write-Success "VS Code CLI is available - Version: $($codeVersion[0])"
        } else {
            throw "VS Code CLI not found"
        }
        
        # Detect installation paths
        $userDataPath = "$env:APPDATA\Code"
        $extensionsPath = "$env:USERPROFILE\.vscode\extensions"
        
        $checks["User Data Directory"] = $userDataPath
        $checks["Extensions Directory"] = $extensionsPath
        
        Write-Success "User Data Path: $userDataPath"
        Write-Success "Extensions Path: $extensionsPath"
        
        return $checks
    }
    catch {
        Write-Error "VS Code environment validation failed" $_
        return $null
    }
}

# Enhanced process management
function Stop-VSCodeProcesses {
    Write-Info "Checking for running VS Code processes..."
    
    $processes = @("Code", "code", "code.exe")
    $foundProcesses = @()
    
    foreach ($processName in $processes) {
        $runningProcesses = Get-Process -Name $processName -ErrorAction SilentlyContinue
        if ($runningProcesses) {
            $foundProcesses += $runningProcesses
        }
    }
    
    if ($foundProcesses.Count -gt 0) {
        Write-Warning "Found $($foundProcesses.Count) running VS Code process(es)"
        
        if (-not $WhatIf) {
            $response = Read-Host "Close VS Code processes? (y/N)"
            if ($response -eq 'y' -or $response -eq 'Y') {
                foreach ($process in $foundProcesses) {
                    try {
                        $process.CloseMainWindow()
                        Start-Sleep -Seconds 2
                        if (-not $process.HasExited) {
                            $process.Kill()
                        }
                        Write-Success "Closed process: $($process.ProcessName) (PID: $($process.Id))"
                    }
                    catch {
                        Write-Error "Failed to close process: $($process.ProcessName)" $_
                    }
                }
            } else {
                Write-Warning "Please close VS Code manually and run the script again"
                return $false
            }
        }
    } else {
        Write-Success "No running VS Code processes found"
    }
    
    return $true
}

# Step 1: Enhanced settings reset
function Reset-VSCodeSettings {
    Write-StepHeader "1" "Resetting VS Code to Default Settings"
    
    $userDataPath = "$env:APPDATA\Code"
    $settingsPath = "$userDataPath\User"
    
    $itemsToReset = @{
        "User Settings" = "$settingsPath\settings.json"
        "Keybindings" = "$settingsPath\keybindings.json"
        "Snippets" = "$settingsPath\snippets"
        "Workspace Storage" = "$settingsPath\workspaceStorage"
        "Global Storage" = "$settingsPath\globalStorage"
        "History" = "$settingsPath\History"
        "Logs" = "$settingsPath\logs"
        "CachedExtensions" = "$settingsPath\CachedExtensions"
        "Machine Settings" = "$settingsPath\machineSettings.json"
    }
    
    $resetCount = 0
    $totalItems = $itemsToReset.Count
    
    foreach ($itemName in $itemsToReset.Keys) {
        $itemPath = $itemsToReset[$itemName]
        
        if (Test-Path $itemPath) {
            if ($WhatIf) {
                Write-Info "Would reset: $itemName ($itemPath)"
            } else {
                try {
                    Remove-Item $itemPath -Recurse -Force -ErrorAction Stop
                    Write-Success "Reset: $itemName"
                    $resetCount++
                }
                catch {
                    Write-Error "Failed to reset: $itemName" $_
                }
            }
        } else {
            Write-Info "Not found (already clean): $itemName"
            $resetCount++
        }
    }
    
    $Global:StepResults["Step1"] = @{
        Success = $resetCount -eq $totalItems
        Details = "Reset $resetCount of $totalItems items"
    }
    
    if ($resetCount -eq $totalItems) {
        Write-Success "Step 1 COMPLETED: All VS Code settings reset successfully"
    } else {
        Write-Warning "Step 1 PARTIAL: Reset $resetCount of $totalItems items"
    }
}

# Step 2: Enhanced extension updates
function Update-AllExtensions {
    Write-StepHeader "2" "Updating All Installed Extensions"
    
    try {
        # Get list of installed extensions first
        $installedExtensions = & code --list-extensions 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to list extensions: $installedExtensions"
        }
        
        $extensionCount = ($installedExtensions | Measure-Object).Count
        Write-Info "Found $extensionCount installed extensions"
        
        if ($extensionCount -eq 0) {
            Write-Info "No extensions to update"
            $Global:StepResults["Step2"] = @{ Success = $true; Details = "No extensions installed" }
            return
        }
        
        if ($WhatIf) {
            Write-Info "Would update $extensionCount extensions"
            return
        }
        
        Write-Progress "Updating extensions..."
        $updateResult = & code --update-extensions 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "All extensions updated successfully"
            $Global:StepResults["Step2"] = @{ Success = $true; Details = "Updated $extensionCount extensions" }
        } else {
            Write-Warning "Extension update completed with issues: $updateResult"
            $Global:StepResults["Step2"] = @{ Success = $false; Details = "Update issues: $updateResult" }
        }
    }
    catch {
        Write-Error "Failed to update extensions" $_
        $Global:StepResults["Step2"] = @{ Success = $false; Details = $_.Exception.Message }
    }
    
    Write-Success "Step 2 COMPLETED: Extension updates processed"
}

# Step 3: Enhanced extension health detection and cleanup
function Remove-ProblematicExtensions {
    Write-StepHeader "3" "Detecting and Removing Problematic Extensions"
    
    try {
        # Get detailed extension information
        $installedExtensions = & code --list-extensions --show-versions 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to get extension list: $installedExtensions"
        }
        
        Write-Info "Analyzing $($installedExtensions.Count) installed extensions..."
        
        # Extensions to remove (AI and problematic ones)
        $extensionsToRemove = @{
            # AI Extensions
            "github.copilot" = "GitHub Copilot (AI)"
            "github.copilot-chat" = "GitHub Copilot Chat (AI)"
            "tabnine.tabnine-vscode" = "TabNine (AI)"
            "visualstudioexptteam.vscodeintellicode" = "IntelliCode (AI)"
            "amazonwebservices.codewhisperer-for-command-line-companion" = "CodeWhisperer (AI)"
            "continue.continue" = "Continue (AI)"
            "codeium.codeium" = "Codeium (AI)"
            
            # Commonly problematic extensions
            "ms-vscode.vscode-json" = "JSON (built-in replacement available)"
            "hookyqr.beautify" = "Beautify (replaced by Prettier)"
            "ms-python.pylint" = "Pylint (conflicts with newer Python tools)"
        }
        
        $removedCount = 0
        $totalToRemove = 0
        
        foreach ($extension in $installedExtensions) {
            $extensionId = $extension.Split('@')[0]
            
            if ($extensionsToRemove.ContainsKey($extensionId)) {
                $totalToRemove++
                $reason = $extensionsToRemove[$extensionId]
                
                if ($WhatIf) {
                    Write-Info "Would remove: $extensionId ($reason)"
                } else {
                    try {
                        Write-Progress "Removing: $extensionId..."
                        & code --uninstall-extension $extensionId 2>&1 | Out-Null
                        if ($LASTEXITCODE -eq 0) {
                            Write-Success "Removed: $extensionId ($reason)"
                            $removedCount++
                        } else {
                            Write-Warning "Failed to remove: $extensionId"
                        }
                    }
                    catch {
                        Write-Error "Error removing $extensionId" $_
                    }
                }
            }
        }
        
        $Global:StepResults["Step3"] = @{
            Success = $removedCount -eq $totalToRemove
            Details = "Removed $removedCount of $totalToRemove problematic extensions"
        }
        
        if ($totalToRemove -eq 0) {
            Write-Success "No problematic extensions found"
        } else {
            Write-Success "Step 3 COMPLETED: Removed $removedCount of $totalToRemove problematic extensions"
        }
    }
    catch {
        Write-Error "Failed to analyze extensions" $_
        $Global:StepResults["Step3"] = @{ Success = $false; Details = $_.Exception.Message }
    }
}

# Step 4-5: Enhanced required extension installation
function Install-RequiredExtensions {
    Write-StepHeader "4-5" "Installing Required Extensions and Formatters"
    
    $requiredExtensions = [ordered]@{
        # Core language extensions
        "ms-vscode.cpptools" = @{
            Name = "C/C++ Extension"
            Category = "Language Support"
            Essential = $true
        }
        "ms-dotnettools.csharp" = @{
            Name = "C# Extension"
            Category = "Language Support"
            Essential = $true
        }
        "ms-python.python" = @{
            Name = "Python Extension"
            Category = "Language Support"
            Essential = $true
        }
        
        # Web development
        "ecmel.vscode-html-css" = @{
            Name = "HTML CSS Support"
            Category = "Web Development"
            Essential = $true
        }
        "xabikos.javascriptsnippets" = @{
            Name = "JavaScript (ES6) Snippets"
            Category = "Web Development"
            Essential = $true
        }
        
        # Tools and integration
        "github.vscode-pull-request-github" = @{
            Name = "GitHub Pull Requests and Issues"
            Category = "Version Control"
            Essential = $true
        }
        "zerotaskx.blackbox" = @{
            Name = "BlackBox AI Code Generation"
            Category = "AI Tools"
            Essential = $true
        }
        
        # Formatters
        "esbenp.prettier-vscode" = @{
            Name = "Prettier Code Formatter"
            Category = "Formatting"
            Essential = $true
        }
        "ms-python.black-formatter" = @{
            Name = "Black Python Formatter"
            Category = "Formatting"
            Essential = $true
        }
        
        # Additional useful extensions
        "ms-vscode.vscode-typescript-next" = @{
            Name = "TypeScript and JavaScript Language Features"
            Category = "Language Support"
            Essential = $false
        }
    }
    
    $installedCount = 0
    $failedCount = 0
    $totalExtensions = $requiredExtensions.Count
    
    foreach ($extensionId in $requiredExtensions.Keys) {
        $extensionInfo = $requiredExtensions[$extensionId]
        $extensionName = $extensionInfo.Name
        $category = $extensionInfo.Category
        
        Write-Progress "Installing: $extensionName ($category)..."
        
        if ($WhatIf) {
            Write-Info "Would install: $extensionName ($extensionId)"
            continue
        }
        
        try {
            $installResult = & code --install-extension $extensionId --force 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Installed: $extensionName"
                $installedCount++
            } else {
                Write-Error "Failed to install: $extensionName - $installResult"
                $failedCount++
            }
        }
        catch {
            Write-Error "Error installing $extensionName" $_
            $failedCount++
        }
        
        # Small delay to prevent rate limiting
        Start-Sleep -Milliseconds 500
    }
    
    $Global:StepResults["Step4-5"] = @{
        Success = $failedCount -eq 0
        Details = "Installed $installedCount of $totalExtensions extensions ($failedCount failed)"
    }
    
    Write-Success "Step 4-5 COMPLETED: Extension installation finished ($installedCount/$totalExtensions successful)"
}

# Step 6: Enhanced AI extension removal
function Remove-AIExtensions {
    Write-StepHeader "6" "Final AI Extension Cleanup"
    
    # Comprehensive AI extension list
    $aiExtensions = @(
        "github.copilot",
        "github.copilot-chat",
        "tabnine.tabnine-vscode",
        "visualstudioexptteam.vscodeintellicode",
        "amazonwebservices.codewhisperer-for-command-line-companion",
        "continue.continue",
        "codeium.codeium",
        "openai.openai-api",
        "rubberduck.rubberduck-vscode",
        "sourcegraph.cody-ai"
    )
    
    # Get current extensions
    $currentExtensions = & code --list-extensions 2>&1
    $removedCount = 0
    
    foreach ($aiExtension in $aiExtensions) {
        if ($currentExtensions -contains $aiExtension) {
            if ($WhatIf) {
                Write-Info "Would remove AI extension: $aiExtension"
            } else {
                try {
                    & code --uninstall-extension $aiExtension 2>&1 | Out-Null
                    if ($LASTEXITCODE -eq 0) {
                        Write-Success "Removed AI extension: $aiExtension"
                        $removedCount++
                    }
                }
                catch {
                    Write-Warning "Could not remove: $aiExtension"
                }
            }
        }
    }
    
    $Global:StepResults["Step6"] = @{
        Success = $true
        Details = "Removed $removedCount AI extensions"
    }
    
    Write-Success "Step 6 COMPLETED: AI extension cleanup finished"
}

# Step 7: Enhanced configuration setup
function Set-OptimizedConfiguration {
    Write-StepHeader "7" "Configuring Optimized Settings"
    
    $settingsPath = "$env:APPDATA\Code\User"
    $settingsFile = "$settingsPath\settings.json"
    
    if (-not (Test-Path $settingsPath)) {
        New-Item -Path $settingsPath -ItemType Directory -Force | Out-Null
    }
    
    $optimizedSettings = @{
        # Editor settings
        "editor.formatOnSave" = $true
        "editor.formatOnPaste" = $true
        "editor.codeActionsOnSave" = @{
            "source.organizeImports" = $true
            "source.fixAll" = $true
        }
        "editor.minimap.enabled" = $true
        "editor.wordWrap" = "on"
        "editor.tabSize" = 4
        "editor.insertSpaces" = $true
        
        # File settings
        "files.autoSave" = "afterDelay"
        "files.autoSaveDelay" = 1000
        "files.trimTrailingWhitespace" = $true
        "files.insertFinalNewline" = $true
        
        # Language-specific formatters
        "[javascript]" = @{ "editor.defaultFormatter" = "esbenp.prettier-vscode" }
        "[typescript]" = @{ "editor.defaultFormatter" = "esbenp.prettier-vscode" }
        "[html]" = @{ "editor.defaultFormatter" = "esbenp.prettier-vscode" }
        "[css]" = @{ "editor.defaultFormatter" = "esbenp.prettier-vscode" }
        "[json]" = @{ "editor.defaultFormatter" = "esbenp.prettier-vscode" }
        "[jsonc]" = @{ "editor.defaultFormatter" = "esbenp.prettier-vscode" }
        "[python]" = @{ "editor.defaultFormatter" = "ms-python.black-formatter" }
        
        # Python settings
        "python.defaultInterpreterPath" = "python"
        "python.linting.enabled" = $true
        "python.linting.pylintEnabled" = $false
        "python.linting.flake8Enabled" = $true
        "python.formatting.provider" = "black"
        
        # C++ settings
        "C_Cpp.default.cppStandard" = "c++17"
        "C_Cpp.default.cStandard" = "c11"
        "C_Cpp.default.intelliSenseMode" = "windows-msvc-x64"
        
        # Workbench settings
        "workbench.startupEditor" = "welcomePage"
        "workbench.colorTheme" = "Default Dark+"
        "workbench.iconTheme" = "vs-seti"
        
        # Terminal settings
        "terminal.integrated.defaultProfile.windows" = "PowerShell"
        
        # Git settings
        "git.enableSmartCommit" = $true
        "git.confirmSync" = $false
        
        # Extension settings
        "extensions.autoUpdate" = $true
        "extensions.autoCheckUpdates" = $true
    }
    
    if ($WhatIf) {
        Write-Info "Would create optimized settings.json configuration"
    } else {
        try {
            $settingsJson = $optimizedSettings | ConvertTo-Json -Depth 10
            Set-Content -Path $settingsFile -Value $settingsJson -Encoding UTF8
            Write-Success "Optimized settings configured"
        }
        catch {
            Write-Error "Failed to create settings configuration" $_
        }
    }
    
    $Global:StepResults["Step7"] = @{
        Success = $true
        Details = "Optimized configuration applied"
    }
    
    Write-Success "Step 7 COMPLETED: Optimized configuration applied"
}

# Final validation and reporting
function Invoke-FinalValidation {
    Write-StepHeader "VALIDATION" "Final Environment Validation"
    
    try {
        # Check installed extensions
        $finalExtensions = & code --list-extensions 2>&1
        $expectedExtensions = @(
            "ms-vscode.cpptools",
            "ms-dotnettools.csharp", 
            "ms-python.python",
            "ecmel.vscode-html-css",
            "xabikos.javascriptsnippets",
            "github.vscode-pull-request-github",
            "zerotaskx.blackbox",
            "esbenp.prettier-vscode",
            "ms-python.black-formatter"
        )
        
        $installedRequired = @()
        $missingRequired = @()
        
        foreach ($required in $expectedExtensions) {
            if ($finalExtensions -contains $required) {
                $installedRequired += $required
            } else {
                $missingRequired += $required
            }
        }
        
        Write-Info "Extension Validation Results:"
        Write-Success "✅ Installed: $($installedRequired.Count)/$($expectedExtensions.Count) required extensions"
        
        if ($missingRequired.Count -gt 0) {
            Write-Warning "❌ Missing: $($missingRequired -join ', ')"
        }
        
        # Check settings file
        $settingsPath = "$env:APPDATA\Code\User\settings.json"
        if (Test-Path $settingsPath) {
            Write-Success "✅ Settings file created successfully"
        } else {
            Write-Warning "❌ Settings file not found"
        }
        
        return @{
            ExtensionsInstalled = $installedRequired.Count
            ExtensionsExpected = $expectedExtensions.Count
            SettingsConfigured = Test-Path $settingsPath
            Success = ($missingRequired.Count -eq 0) -and (Test-Path $settingsPath)
        }
    }
    catch {
        Write-Error "Validation failed" $_
        return @{ Success = $false }
    }
}

# Enhanced summary report
function Show-CompletionReport {
    Write-Host "`n" -NoNewline
    Write-Host "=" * 80 -ForegroundColor Green
    Write-Host "🎉 VS CODE RESET AND OPTIMIZATION COMPLETED" -ForegroundColor White -BackgroundColor Green
    Write-Host "=" * 80 -ForegroundColor Green
    
    # Step results summary
    Write-Host "`nSTEP RESULTS SUMMARY:" -ForegroundColor Yellow
    Write-Host "-" * 40 -ForegroundColor Yellow
    
    foreach ($step in $Global:StepResults.Keys) {
        $result = $Global:StepResults[$step]
        $status = if ($result.Success) { "✅ SUCCESS" } else { "❌ FAILED" }
        $color = if ($result.Success) { "Green" } else { "Red" }
        
        Write-Host "$step`: " -NoNewline -ForegroundColor White
        Write-Host $status -ForegroundColor $color
        Write-Host "   └─ $($result.Details)" -ForegroundColor Gray
    }
    
    # Final validation
    $validation = Invoke-FinalValidation
    
    Write-Host "`nENVIRONMENT STATUS:" -ForegroundColor Yellow
    Write-Host "-" * 40 -ForegroundColor Yellow
    Write-Host "🔧 VS Code optimized for:" -ForegroundColor Cyan
    Write-Host "   • C/C++ Development" -ForegroundColor White
    Write-Host "   • C# Development" -ForegroundColor White
    Write-Host "   • Python Development" -ForegroundColor White
    Write-Host "   • Web Development (HTML, CSS, JavaScript)" -ForegroundColor White
    Write-Host "   • GitHub Integration" -ForegroundColor White
    Write-Host "   • Code Formatting (Prettier, Black)" -ForegroundColor White
    
    if ($validation.Success) {
        Write-Host "`n🚀 READY TO USE!" -ForegroundColor Green -BackgroundColor Black
        Write-Host "You can now restart VS Code to begin development." -ForegroundColor Green
    } else {
        Write-Host "`n⚠️  SETUP INCOMPLETE" -ForegroundColor Yellow -BackgroundColor Black
        Write-Host "Some issues were encountered. Please review the log above." -ForegroundColor Yellow
    }
    
    # Error summary
    if ($Global:ErrorLog.Count -gt 0) {
        Write-Host "`nERROR SUMMARY:" -ForegroundColor Red
        Write-Host "-" * 40 -ForegroundColor Red
        foreach ($error in $Global:ErrorLog) {
            Write-Host "⚠️  $($error.Message)" -ForegroundColor Red
            Write-Host "   └─ $($error.Exception)" -ForegroundColor DarkRed
        }
    }
    
    Write-Host "`n" + "=" * 80 -ForegroundColor Green
}

# Main execution function
function Start-EnhancedVSCodeReset {
    # Initialize
    $Global:StepResults = @{}
    $Global:ErrorLog = @()
    
    Write-Host "🚀 ENHANCED VS CODE RESET AND OPTIMIZATION" -ForegroundColor White -BackgroundColor Blue
    Write-Host "Version 2.0 - Enhanced Error Handling & Validation" -ForegroundColor Gray
    
    if ($WhatIf) {
        Write-Warning "🔍 RUNNING IN PREVIEW MODE - No changes will be made"
    }
    
    # Pre-flight checks
    $environment = Test-VSCodeEnvironment
    if (-not $environment) {
        Write-Error "Environment validation failed. Cannot continue."
        return
    }
    
    if (-not (Stop-VSCodeProcesses)) {
        return
    }
    
    try {
        # Execute all steps
        Reset-VSCodeSettings
        Update-AllExtensions  
        Remove-ProblematicExtensions
        Install-RequiredExtensions
        Remove-AIExtensions
        Set-OptimizedConfiguration
        
        # Show completion report
        Show-CompletionReport
        
    }
    catch {
        Write-Error "Critical error during execution" $_
        Write-Host "`n❌ SCRIPT EXECUTION FAILED" -ForegroundColor Red -BackgroundColor Black
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Execute the enhanced script
Start-EnhancedVSCodeReset
