# Terraform Infrastructure for Cloud-Native Frontend

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)

This repository contains the complete Terraform code to deploy a secure, high-performance, and cost-effective frontend for a modern web application on AWS. This infrastructure serves as the delivery layer for my full-stack portfolio project.

The backend API infrastructure for the visitor counter can be found in its own repository: **[portfolio-backend](https://github.com/arkhiVd/portfolio-backend)**.

## Live Demo

The infrastructure defined in this repository is live at: **[https://www.aravindakrishnan.click](https://www.aravindakrishnan.click)**

---

## Frontend Architecture

The architecture is designed for global low-latency, high availability, and robust security by leveraging the AWS edge network and enforcing a "private-by-default" security posture.

![Frontend Architecture Diagram](my-website-files/images/architecture-diagram.png)

### Architectural Flow:
1.  A user accesses the domain `aravindakrishnan.click`.
2.  **Amazon Route 53** resolves the DNS query and, using an Alias record, points the user to the CloudFront distribution.
3.  **Amazon CloudFront** serves the website's static assets (HTML, CSS, JS, images) from the nearest edge location, providing the fastest possible load time. All traffic is served over HTTPS.
4.  If the content is not in the cache, CloudFront securely fetches it from a **private Amazon S3 bucket**.
5.  **Origin Access Control (OAC)** is used to ensure that the S3 bucket is only accessible by my specific CloudFront distribution, blocking all direct public access.
6.  The **AWS Certificate Manager (ACM)** provisions and manages the free, auto-renewing SSL/TLS certificate that enables HTTPS.

---

## Core Concepts & Key Features

*   **Global Content Delivery:** Uses **Amazon CloudFront** to cache static content at AWS edge locations worldwide, ensuring low-latency access for all users and providing a layer of protection against DDoS attacks.
*   **Ironclad Security:** The **S3 bucket** is 100% private, with all public access blocked. The S3 bucket policy is configured to only allow `GetObject` requests from the specific CloudFront distribution's ARN via **Origin Access Control (OAC)**, the modern best practice for securing S3 origins.
*   **Fully Automated DNS & SSL:** **Route 53** manages the DNS with highly reliable **Alias records**. The SSL certificate is provisioned and automatically validated and renewed by **ACM**, ensuring encrypted traffic at no cost.
*   **Efficient, Automated Content Deployment:** The `aws_s3_object` resource uses a `for_each` loop over a `fileset` to programmatically upload all website files. It also uses the `filemd5()` hash in the `etag` argument to ensure that only changed files are re-uploaded, making deployments faster and more efficient.

---

## CI/CD Pipeline with GitHub Actions

This repository has a "push-to-deploy" CI/CD pipeline that automates the entire deployment process for the frontend infrastructure and application files.

The workflow is triggered on every push to the `main` branch and performs the following steps:

1.  **Secure AWS Authentication:** Uses **OpenID Connect (OIDC)** to request temporary, short-lived credentials from AWS IAM. This passwordless approach is highly secure and avoids storing long-lived access keys as GitHub secrets.
2.  **Deploy Infrastructure:** Runs `terraform apply` to ensure the S3 bucket, CloudFront distribution, and all other AWS resources are configured according to the code.
3.  **Sync Website Files:** Executes an `aws s3 sync` command to upload the website's static files to the S3 bucket. It uses the `--delete` flag to ensure the bucket is an exact mirror of the Git repository, removing any old files that are no longer needed.
4.  **Invalidate CDN Cache:** This is the most critical step for a frontend deployment. The pipeline runs an `aws cloudfront create-invalidation` command with a `/*` path. This purges the old cached content from all CloudFront edge locations globally, ensuring that users see the updated version of the site almost immediately.

---

## Terraform Highlights

This codebase demonstrates several professional Terraform patterns:

*   **Multi-Region Provider Configuration:** Because CloudFront requires ACM certificates to be in the `us-east-1` region, the code defines an aliased AWS provider. This allows the certificate to be managed in `us-east-1` while the primary S3 bucket and other resources are deployed in `ap-south-2`, all from a single codebase.
*   **Dynamic File Uploads with MIME Types:** A `lookup` function is used with a local map to dynamically set the correct `Content-Type` for each uploaded file based on its extension. This is critical for ensuring browsers correctly render CSS, execute JavaScript, and display images.
*   **Robust Dependency Management:** The code relies on Terraform's implicit dependency graph. For example, the CloudFront distribution references the certificate validation resource (`aws_acm_certificate_validation`), ensuring Terraform waits for the SSL certificate to be fully issued before attempting to attach it, preventing race conditions.

---

## Local Development & Deployment

While deployment is automated via the CI/CD pipeline, the infrastructure can be managed from a local machine.

1.  **Prerequisites:**
    *   Terraform CLI (`~> 1.0`)
    *   AWS CLI
    *   Configured AWS credentials (e.g., via `aws configure sso`)

2.  **Clone the repository:**
    ```bash
    git clone https://github.com/arkhiVd/portfolio-frontend.git
    cd portfolio-frontend
    ```

3.  **Prepare Variables:**
    Create a variables file for your specific domain name.
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    # Edit terraform.tfvars with your own values
    ```

4.  **Deploy:**
    Initialize Terraform and apply the configuration.
    ```bash
    terraform init
    terraform plan
    terraform apply
    ```