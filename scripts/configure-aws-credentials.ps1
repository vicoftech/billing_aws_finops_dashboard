# AWS Credentials Configuration Helper
# This script helps configure AWS credentials for the Cost Analytics project

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment,

    [Parameter(Mandatory=$false)]
    [switch]$ConfigureSSO,

    [Parameter(Mandatory=$false)]
    [switch]$CheckCredentials
)

$profileName = switch ($Environment) {
    "dev" { "bsj_dev" }
    "staging" { "bsj_test" }
    "prod" { "bsj_prod" }
}

Write-Host "=== AWS Credentials Configuration for $Environment Environment ===" -ForegroundColor Cyan
Write-Host "Profile: $profileName" -ForegroundColor Yellow

if ($CheckCredentials) {
    Write-Host "`n🔍 Checking current AWS credentials..." -ForegroundColor Green

    try {
        # Check if profile exists
        $profiles = aws configure list-profiles 2>$null
        if ($profiles -contains $profileName) {
            Write-Host "✅ Profile '$profileName' exists" -ForegroundColor Green

            # Check credentials
            $result = aws sts get-caller-identity --profile $profileName 2>&1
            if ($LASTEXITCODE -eq 0) {
                $identity = $result | ConvertFrom-Json
                Write-Host "✅ Credentials are valid" -ForegroundColor Green
                Write-Host "   Account: $($identity.Account)" -ForegroundColor Gray
                Write-Host "   User: $($identity.UserId)" -ForegroundColor Gray
                Write-Host "   ARN: $($identity.Arn)" -ForegroundColor Gray
            } else {
                Write-Host "❌ Credentials are invalid or expired" -ForegroundColor Red
                Write-Host "   Error: $result" -ForegroundColor Red
            }
        } else {
            Write-Host "❌ Profile '$profileName' does not exist" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Error checking credentials: $($_.Exception.Message)" -ForegroundColor Red
    }

    exit 0
}

if ($ConfigureSSO) {
    Write-Host "`n🔐 Configuring AWS SSO..." -ForegroundColor Green

    # Check if AWS CLI SSO is configured
    $ssoSessions = aws configure sso list-sessions 2>$null
    if ($LASTEXITCODE -eq 0 -and $ssoSessions) {
        Write-Host "SSO sessions found. Use one of these:" -ForegroundColor Green
        Write-Host $ssoSessions
    } else {
        Write-Host "No SSO sessions found. Please configure SSO first:" -ForegroundColor Yellow
        Write-Host "aws configure sso" -ForegroundColor Cyan
        exit 1
    }

    Write-Host "`nRun these commands to configure SSO for $profileName profile:" -ForegroundColor Green
    Write-Host "aws configure sso --profile $profileName" -ForegroundColor Cyan
    Write-Host "aws sso login --profile $profileName" -ForegroundColor Cyan

    exit 0
}

# Manual credential configuration
Write-Host "`n🔑 Manual AWS Credentials Configuration" -ForegroundColor Green
Write-Host "You need to provide AWS Access Key ID and Secret Access Key." -ForegroundColor Yellow
Write-Host "Get these from: https://console.aws.amazon.com/iam/ -> Users -> Security credentials" -ForegroundColor Yellow

$configure = Read-Host "`nDo you want to configure AWS credentials now? (yes/no)"
if ($configure -ne "yes") {
    Write-Host "Configuration cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host "`n⚠️  IMPORTANT SECURITY NOTES:" -ForegroundColor Red
Write-Host "• Never share your AWS credentials" -ForegroundColor Red
Write-Host "• Use IAM users with minimal required permissions" -ForegroundColor Red
Write-Host "• Consider using AWS SSO instead for better security" -ForegroundColor Red
Write-Host "• Rotate access keys regularly" -ForegroundColor Red

$accessKey = Read-Host "`nEnter AWS Access Key ID"
$secretKey = Read-Host "Enter AWS Secret Access Key" -AsSecureString
$region = Read-Host "Enter AWS Region (default: us-east-1)"

if (-not $region) { $region = "us-east-1" }

# Configure the profile
Write-Host "`n🔧 Configuring AWS profile: $profileName" -ForegroundColor Green

try {
    # Convert secure string to plain text for aws configure
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secretKey)
    $plainSecretKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    # Configure AWS CLI profile
    aws configure set aws_access_key_id $accessKey --profile $profileName
    aws configure set aws_secret_access_key $plainSecretKey --profile $profileName
    aws configure set region $region --profile $profileName

    Write-Host "✅ AWS profile '$profileName' configured successfully!" -ForegroundColor Green

    # Test the credentials
    Write-Host "`n🔍 Testing credentials..." -ForegroundColor Green
    $result = aws sts get-caller-identity --profile $profileName 2>&1
    if ($LASTEXITCODE -eq 0) {
        $identity = $result | ConvertFrom-Json
        Write-Host "✅ Credentials are valid!" -ForegroundColor Green
        Write-Host "   Account: $($identity.Account)" -ForegroundColor Gray
        Write-Host "   ARN: $($identity.Arn)" -ForegroundColor Gray

        Write-Host "`n🎉 Setup complete! You can now use Terraform with this profile." -ForegroundColor Green
        Write-Host "Example: .\scripts\workspace-helper.ps1 $Environment plan" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Credential test failed: $result" -ForegroundColor Red
        Write-Host "`n🔧 Troubleshooting:" -ForegroundColor Yellow
        Write-Host "1. Check that your access keys are correct" -ForegroundColor Yellow
        Write-Host "2. Ensure your IAM user has the required permissions" -ForegroundColor Yellow
        Write-Host "3. Verify that the access keys are not expired" -ForegroundColor Yellow
    }

} catch {
    Write-Host "❌ Error configuring credentials: $($_.Exception.Message)" -ForegroundColor Red
}

# Clear sensitive data from memory
if ($BSTR) { [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR) }
$plainSecretKey = $null
