

Smart CityOps DevOps Final Project

Overview
Smart CityOps is an advanced, cloud-native DevOps platform designed to simulate and manage smart city IoT data flows. This graduate project demonstrates best practices in modern DevOps, integrating AWS, Terraform, Jenkins, Ansible, Docker, Nexus, and Kubernetes (EKS) to deliver a robust, scalable, and cost-efficient solution.

Achievements & Current State
* Infrastructure as Code: Automated provisioning of AWS VPC, subnets, security groups, IAM roles, and EKS clusters using Terraform.
* Backend Service: Python API for sensor data, containerized with Docker, deployed to AWS ECS (Fargate) and ready for EKS.
* IoT Simulation: Python-based simulator generates realistic traffic, pollution, and weather sensor data, posting to the backend API.
* CI/CD Automation: Jenkins pipelines for infrastructure, configuration, Docker builds, and Kubernetes deployments.
* Configuration Management: Ansible playbooks automate Nexus repository setup on EC2.
* Cloud-Native Logging: CloudWatch logging integrated for backend container diagnostics.
* Frontend: Next.js app (see frontend/README.md) for dashboard and visualization.
* Cost Optimization: All resources use free-tier or spot instances where possible, with cleanup reminders in pipelines.

File & Directory Descriptions

Infrastructure & IaC
* main.tf, variables.tf, outputs.tf: Terraform scripts for AWS networking, security, and compute resources.
* aws-auth.yaml, aws-auth-current.yaml: Kubernetes authentication config maps for AWS roles/users.
* scops-backend-deployment.yaml: Kubernetes manifest for backend deployment.

CI/CD Pipelines
* Jenkinsfile.terraform: Jenkins pipeline for Terraform infrastructure provisioning.
* Jenkinsfile.ansible: Jenkins pipeline for Ansible-based Nexus setup.
* Jenkinsfile.docker-backend: Jenkins pipeline for backend Docker build and push.
* Jenkinsfile.docker-frontend: Jenkins pipeline for frontend Docker build and push.
* Jenkinsfile.k8s-deploy: Jenkins pipeline for Kubernetes/EKS deployment.

Application & Simulation
* backend_service.py: Python backend API for sensor data, connects to SQL Server, ECS/EKS-ready.
* simulator.py: Python script simulating IoT sensors, sends data to backend via HTTP POST.
* Dockerfile: Builds backend container, installs Python dependencies and ODBC drivers for SQL Server.
* sensor_data.db: Local SQLite database (if used for testing).

Task Definitions & Deployment
* task-def.json: ECS task definition for backend container, including environment variables and resource settings.

Frontend
* frontend/: Next.js frontend app for dashboard and visualization (see its own README for details).
* DevOps Dashboard/: Dashboard or monitoring UI (if used).

Documentation & Planning
* README.md: This file, project overview and instructions.
* Smart_CityOps_DataFlow_DevOps.docx: Project documentation.
* project_plan (1).xlsx: Project planning spreadsheet.

Scripts & Utilities
* install-terraform.ps1: PowerShell script to install Terraform.
* scripts/: Additional scripts (if present).

How to Run the Project
1. Set up AWS credentials and install Terraform.
2. Use Jenkins to run pipelines in this order:
    - Terraform Infrastructure Pipeline
    - Ansible Nexus Automation Pipeline
    - Docker Build & Push Pipeline (backend)
    - Kubernetes Deploy to EKS Pipeline
    - Docker Build & Push Pipeline (frontend)
3. Deploy backend to ECS using the latest Docker image and task definition.
4. Monitor logs in CloudWatch for backend container health and errors.
5. Use `simulator.py` to generate and send sensor data to the backend.

---

## Troubleshooting & Best Practices
- If backend fails with `ModuleNotFoundError: No module named 'pyodbc'`, ensure Dockerfile installs both `pyodbc` and ODBC drivers.
- Check CloudWatch logs for container errors and diagnostics.
- Review ECS task definition and environment variables for correctness.
- Destroy unused resources to minimize AWS costs.

---

## Project Status
This README is up to date with the Smart CityOps DevOps project as of November 2025. For further details, see the documentation and planning files included in this repository.

## Quickstart: Terraform (for reference)

Install Terraform (choose one):

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

Verify AWS CLI and credentials:

    aws --version
    aws configure
    aws configure list --profile default

Run Terraform in this project folder:

    Set-Location 'D:\Depi DevOps Project'
    terraform init
    terraform plan -out=tfplan
    terraform apply tfplan

If you're using a named AWS profile for credentials, either set the environment variable for the session or pass the variable when running Terraform:


    $env:AWS_PROFILE = 'your-profile'
    terraform plan

    # Or pass as Terraform variable
    terraform plan -var "aws_profile=your-profile" -out=tfplan

## Troubleshooting

- `terraform` not recognized: reinstall via winget/choco or ensure the folder with `terraform.exe` is on your PATH and restart PowerShell.
- Chocolatey permission errors: make sure you run the `choco` command in an elevated PowerShell session. If permission issues persist, fix ownership/permissions as shown above.
- Long PATH issues: prefer editing PATH via Windows System UI or the `[Environment]::SetEnvironmentVariable` approach above.

## After Terraform Apply — Useful Commands

    Set-Location 'D:\Depi DevOps Project'
    terraform output

---
This README is up to date with the Smart CityOps DevOps project as of November 2025.
