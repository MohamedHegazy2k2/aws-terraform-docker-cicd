# 🤖 Automated AWS EC2 Deployment with Terraform & GitHub Actions 🚀

This project demonstrates a complete CI/CD pipeline for automatically deploying a Node.js web application to an AWS EC2 instance. The entire process is orchestrated using GitHub Actions, with infrastructure managed by Terraform and the application containerized using Docker.

## 🛠️ Technologies Used

* **CI/CD:** GitHub Actions
* **Infrastructure as Code (IaC):** Terraform
* **Cloud Provider:** AWS ☁️ (EC2, S3, ECR, Security Group)
* **Containerization:** Docker 🐳
* **Application:** Node.js (Express.js) 🟩

## ⚙️ How it Works: The CI/CD Pipeline

The pipeline is defined in `.github/workflows/deploy.yml` and is triggered on every `push` to the `dev` branch. It consists of two main jobs that run in sequence.

### 1. Job: `deploy-infra` (🏗️ Infrastructure Deployment)

This job is responsible for creating and managing the AWS infrastructure using Terraform.

1.  **Checkout Code:** The repository's code is checked out.
2.  **Setup Terraform:** The `hashicorp/setup-terraform` action is used to install Terraform.
3.  **Terraform Init:** Initializes Terraform, configuring the S3 backend to store the `terraform.tfstate` file remotely.
4.  **Terraform Plan:** Generates an execution plan. It passes necessary variables like VPC ID, Subnet ID, and SSH keys (from GitHub Secrets) to Terraform.
5.  **Terraform Apply:** Automatically applies the plan to create or update the following AWS resources:
    * **`aws_key_pair`**: 🔑 An SSH key pair for accessing the EC2 instance.
    * **`aws_security_group`**: 🛡️ A security group (`main_sg`) that allows inbound traffic on:
        * **Port 22 (SSH)** from any IP (`0.0.0.0/0`).
        * **Port 80 (HTTP)** from any IP (`0.0.0.0/0`).
    * **`aws_instance`**: 🖥️ An EC2 instance (`servernode`) configured with the specified AMI, instance type, and the security group/key pair created above.
6.  **Set Output:** After the infrastructure is successfully deployed, this step runs `terraform output` to get the `instance_public_ip` and saves it as a GitHub output variable (`SERVER_PUBLIC_IP`) to be used by the next job.

### 2. Job: `deploy-app` (🚢 Application Deployment)

This job depends on the successful completion of `deploy-infra` (`needs: deploy-infra`). It is responsible for building the application, pushing it to a container registry, and deploying it on the new EC2 instance.

1.  **Checkout Code:** Checks out the repository code again.
2.  **Login to AWS ECR:** Uses the `aws-actions/amazon-ecr-login` action to authenticate Docker with the AWS Elastic Container Registry.
3.  **Build and Push Docker Image:**
    * Builds the Docker image from the `Dockerfile`.
    * Tags the image with the unique commit SHA (`${{ github.sha }}`) for versioning.
    * Pushes the tagged image to the ECR repository (`example-node-app`).
4.  **Deploy Docker Image to EC2:** This is the final step, using `appleboy/ssh-action` to connect to the EC2 instance.
    * It connects via SSH using the `SERVER_PUBLIC_IP` (from the previous job) and the `PRIVATE_SSH_KEY` (from GitHub Secrets).
    * Once connected, it executes a shell script on the server that does the following:
        1.  Updates the server's packages (`apt update`).
        2.  Installs Docker (`docker.io`) and the AWS CLI.
        3.  Logs the server's Docker daemon into AWS ECR.
        4.  Stops (`docker stop`) 🛑 and removes (`docker rm`) 🗑️ any container named `myappcontainer` that might be running from a previous deployment.
        5.  Pulls the new Docker image (with the specific commit SHA tag) from ECR.
        6.  Runs the new container as `myappcontainer` ▶️, mapping port **80** on the EC2 host (which is open to the public) to port **8080** inside the container (where the Node.js app is listening).

## 📋 Setup & Prerequisites

To use this project, you must configure the following:

1.  **AWS Account:** An active AWS subscription.
2.  **S3 Bucket:** 🪣 An S3 bucket to store the Terraform state file. You must update the `bucket` name in `provider.tf`.
3.  **AWS ECR:** An ECR repository named `example-node-app`.
4.  **SSH Key Pair:** Generate an SSH key pair.
5.  **GitHub Secrets:** 🤫 Add the following secrets to your GitHub repository (`Settings > Secrets and variables > Actions`):
    * `AWS_ACCESS_KEY_ID`: Your AWS IAM user access key.
    * `AWS_SECRET_ACCESS_KEY`: Your AWS IAM user secret key.
    * `AWS_TF_STATE_BUCKET_NAME`: The name of the S3 bucket you created for Terraform state.
    * `AWS_SSH_KEY_PRIVATE`: The *content* of your private SSH key.
    * `AWS_SSH_KEY_PUBLIC`: The *content* of your public SSH key.

## 🚀 How to Use

1.  Fork this repository.
2.  Configure all the prerequisites and GitHub secrets listed above.
3.  In `deploy.yml`, update the `Terraform Plan` step with your specific AWS environment details:
    * `vpc_id`
    * `subnet_id`
    * `ami_id` (Ensure it's a valid Ubuntu AMI for your chosen `AWS_REGION`, `eu-north-1`)
4.  Push a commit to the `dev` branch.
5.  Go to the "Actions" tab in your GitHub repository to watch the pipeline run.
6.  Once completed, your application will be accessible at `http://<YOUR_EC2_PUBLIC_IP>`. ✅
