
# Smart CityOps DevOps Final Project

## Project Idea
Smart CityOps is a full-stack, cloud-native DevOps project simulating a smart city IoT data flow and management platform. It demonstrates modern DevOps practices using AWS, Terraform, Jenkins, Ansible, Docker, Nexus, and Kubernetes (EKS). The project includes:

- Infrastructure as Code (Terraform)
- Configuration Management (Ansible)
- CI/CD Automation (Jenkins)
- Containerization (Docker)
- Kubernetes Deployment (EKS)
- Nexus Repository for images
- Application Deployment (Frontend + Backend + Database)

## What Has Been Built (Base)
- AWS VPC, subnets, security groups, IAM roles
- ECS backend running on public IP
- IoT Simulators (Python)
- Backend Python API (Dockerized)

## Current DevOps Architecture
### Infrastructure (Terraform)
- VPC, public/private subnets, security groups
- Internet Gateway, Route Tables
- EKS cluster (1–2 nodes, spot if possible, free-tier where possible)
- EC2 instance (t3.micro) for Nexus
- IAM roles for EKS, EC2, and nodes
- Modular Terraform structure

### Configuration Management (Ansible)
- Playbook to install and configure Nexus on EC2 (t3.micro)
- Opens only required ports (8081, 8082)

### CI/CD Pipelines (Jenkins)
Pipelines are defined as Jenkinsfiles:
1. **Terraform Infrastructure Pipeline**: Provisions AWS resources with cost-saving settings
2. **Ansible Nexus Automation Pipeline**: Configures Nexus on EC2
3. **Docker Build & Push Pipeline (backend)**: Builds and pushes backend image to Nexus
4. **Kubernetes Deploy to EKS Pipeline**: Deploys backend/frontend/database to EKS
5. **Docker Build & Push Pipeline (frontend)**: Builds and pushes frontend image to Nexus

### Application
- Backend: Python API (Dockerized, ECS now, EKS planned)
- Frontend: React or HTML/JS (Dockerized)
- Database: PostgreSQL or MySQL (inside EKS)

### Nexus Repository
- Hosted on EC2 (t3.micro), managed by Ansible
- Stores Docker images for backend and frontend

### Kubernetes (EKS)
- Manifests for backend, frontend, and database deployments/services
- Uses images from Nexus private registry
- ConfigMaps, Secrets, Ingress/LoadBalancer

### Cost Optimization
- All EC2/EKS use smallest instance types (t3.micro)
- EKS node group: 1–2 nodes, spot if possible
- Free-tier resources and regions
- Cleanup steps and reminders in pipelines

## How to Run the Project
1. Install Jenkins and set up pipeline jobs for each Jenkinsfile in this repo
2. Run pipelines in this order:
   1. Terraform Infrastructure Pipeline
   2. Ansible Nexus Automation Pipeline
   3. Docker Build & Push Pipeline (backend)
   4. Kubernetes Deploy to EKS Pipeline
   5. Docker Build & Push Pipeline (frontend)
3. Monitor each pipeline for success before starting the next
4. Clean up unused resources to minimize AWS costs

## Location of Key Files
- `main.tf`, `variables.tf`, `outputs.tf` — Terraform infrastructure
- `Jenkinsfile.terraform` — Terraform pipeline
- `Jenkinsfile.ansible` — Ansible Nexus pipeline
- `Jenkinsfile.docker-backend` — Backend Docker pipeline
- `Jenkinsfile.k8s-deploy` — Kubernetes deploy pipeline
- `Jenkinsfile.docker-frontend` — Frontend Docker pipeline
- `ansible/playbook.yml`, `ansible/inventory` — Ansible Nexus setup
- `k8s/` — Kubernetes manifests

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
