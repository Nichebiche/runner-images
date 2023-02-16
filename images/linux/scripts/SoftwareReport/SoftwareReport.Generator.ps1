using module ./software-report-base/SoftwareReport.psm1
using module ./software-report-base/SoftwareReport.Nodes.psm1

param (
    [Parameter(Mandatory)][string]
    $OutputDirectory
)

$global:ErrorActionPreference = "Stop"
$global:ErrorView = "NormalView"
Set-StrictMode -Version Latest

Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Android.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Browsers.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.CachedTools.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Common.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Databases.psm1") -DisableNameChecking
Import-Module "$PSScriptRoot/../helpers/SoftwareReport.Helpers.psm1" -DisableNameChecking
Import-Module "$PSScriptRoot/../helpers/Common.Helpers.psm1" -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Java.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Rust.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.Tools.psm1") -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot "SoftwareReport.WebServers.psm1") -DisableNameChecking

# Restore file owner in user profile
Restore-UserOwner

# Software report
$softwareReport = [SoftwareReport]::new("Ubuntu $(Get-OSVersionShort)")
$softwareReport.Root.AddToolVersion("OS Version:", $(Get-OSVersionFull))
$softwareReport.Root.AddToolVersion("Kernel Version:", $(Get-KernelVersion))
$softwareReport.Root.AddToolVersion("Image Version:", $env:IMAGE_VERSION)

$installedSoftware = $softwareReport.Root.AddHeader("Installed Software")

# Language and Runtime
Write-Host "language runtime"
$languageAndRuntime = $installedSoftware.AddHeader("Language and Runtime")
$languageAndRuntime.AddToolVersion("Bash", $(Get-BashVersion))
$languageAndRuntime.AddToolVersionsListInline("Clang", $(Get-ClangToolVersions -ToolName "clang"), "^\d+")
$languageAndRuntime.AddToolVersionsListInline("Clang-format", $(Get-ClangToolVersions -ToolName "clang-format"), "^\d+")
$languageAndRuntime.AddToolVersionsListInline("Clang-tidy", $(Get-ClangTidyVersions), "^\d+")
$languageAndRuntime.AddToolVersion("Dash", $(Get-DashVersion))
if ((Test-IsUbuntu18) -or (Test-IsUbuntu20)) {
    $languageAndRuntime.AddToolVersion("Erlang", $(Get-ErlangVersion))
    $languageAndRuntime.AddToolVersion("Erlang rebar3", $(Get-ErlangRebar3Version))
}
$languageAndRuntime.AddToolVersionsListInline("GNU C++", $(Get-CPPVersions), "^\d+")
$languageAndRuntime.AddToolVersionsListInline("GNU Fortran", $(Get-FortranVersions), "^\d+")
$languageAndRuntime.AddToolVersion("Julia", $(Get-JuliaVersion))
$languageAndRuntime.AddToolVersion("Kotlin", $(Get-KotlinVersion))
$languageAndRuntime.AddToolVersion("Mono", $(Get-MonoVersion))
$languageAndRuntime.AddToolVersion("MSBuild", $(Get-MsbuildVersion))
$languageAndRuntime.AddToolVersion("Node.js", $(Get-NodeVersion))
$languageAndRuntime.AddToolVersion("Perl", $(Get-PerlVersion))
$languageAndRuntime.AddToolVersion("Python", $(Get-PythonVersion))
$languageAndRuntime.AddToolVersion("Python3", $(Get-Python3Version))
$languageAndRuntime.AddToolVersion("Ruby", $(Get-RubyVersion))
$languageAndRuntime.AddToolVersion("Swift", $(Get-SwiftVersion))

# Package Management
Write-Host "package managers"
$packageManagement = $installedSoftware.AddHeader("Package Management")
$packageManagement.AddToolVersion("cpan", $(Get-CpanVersion))
$packageManagement.AddToolVersion("Helm", $(Get-HelmVersion))
$packageManagement.AddToolVersion("Homebrew", $(Get-HomebrewVersion))
$packageManagement.AddToolVersion("Miniconda", $(Get-MinicondaVersion))
$packageManagement.AddToolVersion("Npm", $(Get-NpmVersion))
$packageManagement.AddToolVersion("NuGet", $(Get-NuGetVersion))
$packageManagement.AddToolVersion("Pip", $(Get-PipVersion))
$packageManagement.AddToolVersion("Pip3", $(Get-Pip3Version))
$packageManagement.AddToolVersion("Pipx", $(Get-PipxVersion))
$packageManagement.AddToolVersion("RubyGems", $(Get-GemVersion))
$packageManagement.AddToolVersion("Vcpkg", $(Get-VcpkgVersion))
$packageManagement.AddToolVersion("Yarn", $(Get-YarnVersion))
$packageManagement.AddHeader("Environment variables").AddTable($(Build-PackageManagementEnvironmentTable))
$packageManagement.AddHeader("Homebrew note").AddNote(@'
Location: /home/linuxbrew
Note: Homebrew is pre-installed on image but not added to PATH.
run the eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" command
to accomplish this.
'@)

# Project Management
Write-Host "project management"
$projectManagement = $installedSoftware.AddHeader("Project Management")
if ((Test-IsUbuntu18) -or (Test-IsUbuntu20)) {
    $projectManagement.AddToolVersion("Ant", $(Get-AntVersion))
    $projectManagement.AddToolVersion("Gradle", $(Get-GradleVersion))
}
if ((Test-IsUbuntu20) -or (Test-IsUbuntu22)) {
    $projectManagement.AddToolVersion("Lerna", $(Get-LernaVersion))
}
if ((Test-IsUbuntu18) -or (Test-IsUbuntu20)) {
    $projectManagement.AddToolVersion("Maven", $(Get-MavenVersion))
    $projectManagement.AddToolVersion("Sbt", $(Get-SbtVersion))
}

# Tools
Write-Host "tools"
$tools = $installedSoftware.AddHeader("Tools")
$tools.AddToolVersion("Ansible", $(Get-AnsibleVersion))
$tools.AddToolVersion("apt-fast", $(Get-AptFastVersion))
$tools.AddToolVersion("AzCopy", $(Get-AzCopyVersion))
$tools.AddToolVersion("Bazel", $(Get-BazelVersion))
$tools.AddToolVersion("Bazelisk", $(Get-BazeliskVersion))
$tools.AddToolVersion("Bicep", $(Get-BicepVersion))
$tools.AddToolVersion("Buildah", $(Get-BuildahVersion))
$tools.AddToolVersion("CMake", $(Get-CMakeVersion))
$tools.AddToolVersion("CodeQL Action Bundles", $(Get-CodeQLBundleVersions))
$tools.AddToolVersion("Docker Amazon ECR Credential Helper", $(Get-DockerAmazonECRCredHelperVersion))
$tools.AddToolVersion("Docker Compose v1", $(Get-DockerComposeV1Version))
$tools.AddToolVersion("Docker Compose v2", $(Get-DockerComposeV2Version))
$tools.AddToolVersion("Docker-Buildx", $(Get-DockerBuildxVersion))
$tools.AddToolVersion("Docker-Moby Client", $(Get-DockerMobyClientVersion))
$tools.AddToolVersion("Docker-Moby Server", $(Get-DockerMobyServerVersion))
if ((Test-IsUbuntu20) -or (Test-IsUbuntu22)) {
    $tools.AddToolVersion("Fastlane", $(Get-FastlaneVersion))
}
$tools.AddToolVersion("Git", $(Get-GitVersion))
$tools.AddToolVersion("Git LFS", $(Get-GitLFSVersion))
$tools.AddToolVersion("Git-ftp", $(Get-GitFTPVersion))
$tools.AddToolVersion("Haveged", $(Get-HavegedVersion))
$tools.AddToolVersion("Heroku", $(Get-HerokuVersion))
if ((Test-IsUbuntu18) -or (Test-IsUbuntu20)) {
    $tools.AddToolVersion("HHVM (HipHop VM)", $(Get-HHVMVersion))
}
$tools.AddToolVersion("jq", $(Get-JqVersion))
$tools.AddToolVersion("Kind", $(Get-KindVersion))
$tools.AddToolVersion("Kubectl", $(Get-KubectlVersion))
$tools.AddToolVersion("Kustomize", $(Get-KustomizeVersion))
$tools.AddToolVersion("Leiningen", $(Get-LeiningenVersion))
$tools.AddToolVersion("MediaInfo", $(Get-MediainfoVersion))
$tools.AddToolVersion("Mercurial", $(Get-HGVersion))
$tools.AddToolVersion("Minikube", $(Get-MinikubeVersion))
$tools.AddToolVersion("n", $(Get-NVersion))
$tools.AddToolVersion("Newman", $(Get-NewmanVersion))
$tools.AddToolVersion("nvm", $(Get-NvmVersion))
$tools.AddToolVersion("OpenSSL", $(Get-OpensslVersion))
$tools.AddToolVersion("Packer", $(Get-PackerVersion))
$tools.AddToolVersion("Parcel", $(Get-ParcelVersion))
if ((Test-IsUbuntu18) -or (Test-IsUbuntu20)) {
    $tools.AddToolVersion("PhantomJS", $(Get-PhantomJSVersion))
}
$tools.AddToolVersion("Podman", $(Get-PodManVersion))
$tools.AddToolVersion("Pulumi", $(Get-PulumiVersion))
$tools.AddToolVersion("R", $(Get-RVersion))
$tools.AddToolVersion("Skopeo", $(Get-SkopeoVersion))
$tools.AddToolVersion("Sphinx Open Source Search Server", $(Get-SphinxVersion))
$tools.AddToolVersion("SVN", $(Get-SVNVersion))
$tools.AddToolVersion("Terraform", $(Get-TerraformVersion))
$tools.AddToolVersion("yamllint", $(Get-YamllintVersion))
$tools.AddToolVersion("yq", $(Get-YqVersion))
$tools.AddToolVersion("zstd", $(Get-ZstdVersion))

# CLI Tools
Write-Host "cli-tools"
$cliTools = $installedSoftware.AddHeader("CLI Tools")
Write-Host "alibaba cli"
$cliTools.AddToolVersion("Alibaba Cloud CLI", $(Get-AlibabaCloudCliVersion))
Write-Host "aws cli"
$cliTools.AddToolVersion("AWS CLI", $(Get-AWSCliVersion))
Write-Host "aws-cli pm"
$cliTools.AddToolVersion("AWS CLI Session Manager Plugin", $(Get-AWSCliSessionManagerPluginVersion))
Write-Host "aws-cli sam"
$cliTools.AddToolVersion("AWS SAM CLI", $(Get-AWSSAMVersion))
Write-Host "azure-cli"
$cliTools.AddToolVersion("Azure CLI", $(Get-AzureCliVersion))
Write-Host "azure devops"
$cliTools.AddToolVersion("Azure CLI (azure-devops)", $(Get-AzureDevopsVersion))
Write-Host "github-cli"
$cliTools.AddToolVersion("GitHub CLI", $(Get-GitHubCliVersion))
Write-Host "gcloud sdk"
$cliTools.AddToolVersion("Google Cloud SDK", $(Get-GoogleCloudSDKVersion))
Write-Host "Hub cli"
$cliTools.AddToolVersion("Hub CLI", $(Get-HubCliVersion))
Write-Host "Netfly cli"
$cliTools.AddToolVersion("Netlify CLI", $(Get-NetlifyCliVersion))
Write-Host "Openshift cli"
$cliTools.AddToolVersion("OpenShift CLI", $(Get-OCCliVersion))
Write-Host "oras cli"
$cliTools.AddToolVersion("ORAS CLI", $(Get-ORASCliVersion))
Write-Host "vercel cli"
$cliTools.AddToolVersion("Vercel CLI", $(Get-VerselCliversion))


$installedSoftware.AddHeader("Java").AddTable($(Get-JavaVersionsTable))
if ((Test-IsUbuntu20) -or (Test-IsUbuntu22)) {
    $installedSoftware.AddHeader("GraalVM").AddTable($(Build-GraalVMTable))
}

$phpTools = $installedSoftware.AddHeader("PHP Tools")
Write-Host "php"
$phpTools.AddToolVersionsListInline("PHP", $(Get-PHPVersions), "^\d+\.\d+")
Write-Host "composer"
$phpTools.AddToolVersion("Composer", $(Get-ComposerVersion))
Write-Host "phpunit"
$phpTools.AddToolVersion("PHPUnit", $(Get-PHPUnitVersion))
Write-Host "phpunit2"
$phpTools.AddNote("Both Xdebug and PCOV extensions are installed, but only Xdebug is enabled.")
$haskellTools = $installedSoftware.AddHeader("Haskell Tools")
Write-Host "cabal"
$haskellTools.AddToolVersion("Cabal", $(Get-CabalVersion))
Write-Host "ghc"
$haskellTools.AddToolVersion("GHC", $(Get-GHCVersion))
Write-Host "ghcup"
$haskellTools.AddToolVersion("GHCup", $(Get-GHCupVersion))
Write-Host "stack"
$haskellTools.AddToolVersion("Stack", $(Get-StackVersion))

Initialize-RustEnvironment
$rustTools = $installedSoftware.AddHeader("Rust Tools")
Write-Host "cargo"
$rustTools.AddToolVersion("Cargo", $(Get-CargoVersion))
Write-Host "rust"
$rustTools.AddToolVersion("Rust", $(Get-RustVersion))
Write-Host "rustdoc"
$rustTools.AddToolVersion("Rustdoc", $(Get-RustdocVersion))
Write-Host "rustup"
$rustTools.AddToolVersion("Rustup", $(Get-RustupVersion))
$rustToolsPackages = $rustTools.AddHeader("Packages")
Write-Host "bindgen"
$rustToolsPackages.AddToolVersion("Bindgen", $(Get-BindgenVersion))
Write-Host "cargo audit"
$rustToolsPackages.AddToolVersion("Cargo audit", $(Get-CargoAuditVersion))
Write-Host "clippy"
$rustToolsPackages.AddToolVersion("Cargo clippy", $(Get-CargoClippyVersion))
Write-Host "outdated"
$rustToolsPackages.AddToolVersion("Cargo outdated", $(Get-CargoOutdatedVersion))
Write-Host "cbindgen"
$rustToolsPackages.AddToolVersion("Cbindgen", $(Get-CbindgenVersion))
Write-Host "rustfmt"
$rustToolsPackages.AddToolVersion("Rustfmt", $(Get-RustfmtVersion))

$browsersTools = $installedSoftware.AddHeader("Browsers and Drivers")
Write-Host "chrome"
$browsersTools.AddToolVersion("Google Chrome", $(Get-ChromeVersion))
Write-Host "chrome driver"
$browsersTools.AddToolVersion("ChromeDriver", $(Get-ChromeDriverVersion))
Write-Host "chromium"
$browsersTools.AddToolVersion("Chromium", $(Get-ChromiumVersion))
Write-Host "edge"
$browsersTools.AddToolVersion("Microsoft Edge", $(Get-EdgeVersion))
Write-Host "edge driver"
$browsersTools.AddToolVersion("Microsoft Edge WebDriver", $(Get-EdgeDriverVersion))
Write-Host "selenium"
$browsersTools.AddToolVersion("Selenium server", $(Get-SeleniumVersion))
Write-Host "firefox"
$browsersTools.AddToolVersion("Mozilla Firefox", $(Get-FirefoxVersion))
Write-Host "firefox driver"
$browsersTools.AddToolVersion("Geckodriver", $(Get-GeckodriverVersion))
Write-Host "variables"
$browsersTools.AddHeader("Environment variables").AddTable($(Build-BrowserWebdriversEnvironmentTable))

$netCoreTools = $installedSoftware.AddHeader(".NET Tools")
Write-Host "bet core sdks!!111"
$netCoreTools.AddToolVersionsListInline(".NET Core SDK", $(Get-DotNetCoreSdkVersions), "^\d+\.\d+\.\d")
$netCoreTools.AddNodes($(Get-DotnetTools))

Write-Host "before dbs"

$databasesTools = $installedSoftware.AddHeader("Databases")
Write-Host "mongo"
if ((Test-IsUbuntu18) -or (Test-IsUbuntu20)) {
    $databasesTools.AddToolVersion("MongoDB", $(Get-MongoDbVersion))
}
Write-Host "sqlite"
$databasesTools.AddToolVersion("sqlite3", $(Get-SqliteVersion))
$databasesTools.AddNode($(Build-PostgreSqlSection))
$databasesTools.AddNode($(Build-MySQLSection))
$databasesTools.AddNode($(Build-MSSQLToolsSection))

$cachedTools = $installedSoftware.AddHeader("Cached Tools")
$cachedTools.AddToolVersionsList("Go", $(Get-ToolcacheGoVersions), "^\d+\.\d+")
$cachedTools.AddToolVersionsList("Node.js", $(Get-ToolcacheNodeVersions), "^\d+")
$cachedTools.AddToolVersionsList("Python", $(Get-ToolcachePythonVersions), "^\d+\.\d+")
$cachedTools.AddToolVersionsList("PyPy", $(Get-ToolcachePyPyVersions), "^\d+\.\d+")
$cachedTools.AddToolVersionsList("Ruby", $(Get-ToolcacheRubyVersions), "^\d+\.\d+")

$powerShellTools = $installedSoftware.AddHeader("PowerShell Tools")
$powerShellTools.AddToolVersion("PowerShell", $(Get-PowershellVersion))
$powerShellTools.AddHeader("PowerShell Modules").AddNodes($(Get-PowerShellModules))

$installedSoftware.AddHeader("Web Servers").AddTable($(Build-WebServersTable))

$androidTools = $installedSoftware.AddHeader("Android")
$androidTools.AddTable($(Build-AndroidTable))
$androidTools.AddHeader("Environment variables").AddTable($(Build-AndroidEnvironmentTable))

$installedSoftware.AddHeader("Cached Docker images").AddTable($(Get-CachedDockerImagesTableData))
$installedSoftware.AddHeader("Installed apt packages").AddTable($(Get-AptPackages))

$softwareReport.ToJson() | Out-File -FilePath "${OutputDirectory}/software-report.json" -Encoding UTF8NoBOM
$softwareReport.ToMarkdown() | Out-File -FilePath "${OutputDirectory}/software-report.md" -Encoding UTF8NoBOM
