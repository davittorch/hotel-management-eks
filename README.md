# Hotel Management Application Deployment

This repository contains the necessary components to deploy a Hotel Management PHP application on Amazon EKS using RDS for database management. The project is structured into three main parts:
- **Application code** (`hotel_management` folder)
- **Terraform infrastructure code** (in the `terraform` folder)
- **Helm chart** for application deployment (`bluebird_chart` folder)

## Prerequisites

- AWS account
- Configured AWS CLI
- Docker installed and configured
- Helm and kubectl installed

## Configuration Files

Ensure the following configuration files are updated before deployment:
- `values.yaml` in the Helm chart folder(bluebird_chart)
- `variables.tf` RDS related variables in the Terraform folder(terraform)
- `config.php` in the Application folder(hotel_management)

## Deployment Steps

1. **Initialize Terraform:**
   ```bash
   cd terraform
   terraform init
   terraform apply

2. **Build and Push Docker Image:**
   Navigate to the `hotel_management` folder, build the Docker image, and push it to the ECR repository created by Terraform:
   Make sure to make necessary changes in config.php file of the hotel_management folder. 
   ```bash
   docker build -t your-ecr-repo-url/hotel-management:latest .
   docker push your-ecr-repo-url/hotel-management:latest

3. **Deploy with Helm:**
   Update the `values.yaml` file with the RDS endpoint and user credentials, then deploy using Helm:
   ```bash
   cd ../bluebird_chart
   helm install bluebird-release .

4. **Access the Application:**
   Access the application via the AWS Load Balancer's endpoint.


## Troubleshooting/Common Issues

During the development and deployment of this application, several challenges were encountered and resolved:

1. **Apache Default Page Displayed Instead of Application**:
   Initially, after deploying the application, the Apache server displayed the default "Apache works" page instead of the application's `index.php`. This issue was due to `index.html` being prioritized over `index.php` in the Apache configuration file located at `/etc/apache2/mods-enabled/dir.conf`. To resolve this, I adjusted the file to prioritize `index.php` over `index.html`.

2. **Difficulty Connecting to RDS**:
   Connecting the application to the RDS database initially failed. The connection issues were resolved by modifying the RDS module in the Terraform configuration with the following attributes:
   ```terraform
   manage_master_user_password = false
   storage_encrypted = false


