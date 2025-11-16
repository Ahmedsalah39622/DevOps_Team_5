Phase 1 — Terraform (IoT → Kinesis)

This README contains quick, copy-pasteable instructions to install Terraform on Windows, verify the AWS CLI, and run the Terraform configuration in this folder.

Location of Terraform files

- `d:\Depi DevOps Project\main.tf`
- `d:\Depi DevOps Project\variables.tf`
- `d:\Depi DevOps Project\outputs.tf`

1) Install Terraform (choose one)

- Using winget (recommended if available):

    winget --version
    winget install --id HashiCorp.Terraform -e --source winget
    terraform -v

- Using Chocolatey (requires elevated PowerShell / Administrator):

    # Open an elevated PowerShell (Start-Process powershell -Verb runAs)
    choco install terraform -y
    terraform -v

If you received the error "Access to the path 'C:\ProgramData\chocolatey\lib-bad' is denied", run the above in an elevated PowerShell (right-click -> Run as Administrator). If permission problems persist you may need to fix folder ownership or permissions:

    # Run as Administrator
    takeown /f "C:\ProgramData\chocolatey" /r /d y
    icacls "C:\ProgramData\chocolatey" /grant Administrators:F /t

- Manual download (no package manager):

1. Open https://releases.hashicorp.com/terraform/ and download the latest Windows AMD64 zip.
2. Extract `terraform.exe` to `C:\tools\terraform` (create the folder if needed).
3. Add that folder to your user PATH (then restart PowerShell):

    New-Item -ItemType Directory -Path 'C:\tools\terraform' -Force
    # After extracting terraform.exe into that folder, add to user PATH:
    $old = [Environment]::GetEnvironmentVariable('PATH','User')
    if (-not $old -or $old -notlike '*C:\tools\terraform*') {
      [Environment]::SetEnvironmentVariable('PATH', ($old + ';C:\tools\terraform').TrimStart(';'), 'User')
    }
    # Open a NEW PowerShell session and run:
    terraform -v

2) Verify AWS CLI and credentials

    aws --version
    aws configure
    aws configure list --profile default

3) Run Terraform in this project folder

    Set-Location 'D:\Depi DevOps Project'
    terraform init
    terraform plan -out=tfplan
    terraform apply tfplan

If you're using a named AWS profile for credentials, either set the environment variable for the session or pass the variable when running Terraform:

    $env:AWS_PROFILE = 'your-profile'
    terraform plan

    # Or pass as Terraform variable
    terraform plan -var "aws_profile=your-profile" -out=tfplan

4) Troubleshooting notes

- `terraform` not recognized: reinstall via winget/choco or ensure the folder with `terraform.exe` is on your PATH and restart PowerShell.
- Chocolatey permission errors: make sure you run the `choco` command in an elevated PowerShell session. If permission issues persist, fix ownership/permissions as shown above.
- Long PATH issues: prefer editing PATH via Windows System UI or the `[Environment]::SetEnvironmentVariable` approach above.

5) After apply — useful commands

    Set-Location 'D:\Depi DevOps Project'
    terraform output kinesis_stream_name
    terraform output kinesis_stream_arn
    terraform output iot_endpoint_address
    terraform output iot_thing_name
    terraform output iot_certificate_arn
    terraform output iot_certificate_id

6) Want me to do more?

- I can add a `terraform.tfvars.example` or create a CI job to run `terraform fmt` and `terraform validate` for this repo.

---
Generated to help run the Phase 1 Terraform deployment.
