# Cloud-Native Portfolio Website

This repository contains the Infrastructure as Code (IaC) for my personal portfolio website, built entirely on AWS and automated with Terraform.

## Demo

You can view the live, deployed website here: **[https://www.aravindakrishnan.click](https://www.aravindakrishnan.click)**

---

## Architecture

The infrastructure is designed to be serverless, secure, scalable, and fully automated.


![Architecture Diagram](my-website-files/images/architecture-diagram.png)

---

## Tech Stack

The project leverages a modern, cloud-native stack:

*   **Cloud Provider:** AWS
*   **Infrastructure as Code:** Terraform
*   **Static Content Hosting:** Amazon S3
*   **Content Delivery Network (CDN):** Amazon CloudFront
*   **DNS & Domain Management:** Amazon Route 53
*   **SSL/TLS Certificates:** AWS Certificate Manager (ACM)
*   **Security:** Origin Access Control (OAC) to secure the S3 bucket.

---

## Deployment & How to Run

This infrastructure is managed entirely by Terraform. To deploy or modify it, you would take the following steps:

1.  **Prerequisites:**
    *   An AWS account
    *   Terraform CLI installed
    *   AWS CLI installed and configured with appropriate permissions.

2.  **Clone the repository:**
    ```bash
    git clone https://github.com/arkhiVd/portfolio-frontend.git
    cd portfolio-frontend
    ```

3.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

4.  **Create a `terraform.tfvars` file:** This file is used to provide values for the variables defined in `variables.tf`. It should contain your unique S3 bucket name.

5.  **Plan the deployment:**
    ```bash
    terraform plan
    ```

6.  **Apply the plan:**
    ```bash
    terraform apply
    ```

---

## Future Improvements
*   **CI/CD Pipeline:** I will be creating a full GitHub Actions workflow to automatically `plan` and `apply` this Terraform code on every push to the `main` branch.