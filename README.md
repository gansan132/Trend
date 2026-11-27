DevOps Practice Project – Dist Directory

This repository contains the production-ready build files (dist folder) for DevOps practice and deployment exercises.

It is intentionally structured to help learners focus on CI/CD pipelines, hosting, containerization, and infrastructure setup rather than application development.

📁 What This Repository Contains

dist/ – Compiled and production-ready static files

HTML

CSS

JavaScript

Assets (images, fonts, etc.)

These files are ready to deploy to:

Web servers (Nginx / Apache)

Cloud platforms (AWS S3, Azure Blob, GCP Storage)

Containerized environments (Docker + Nginx)

Kubernetes clusters

CI/CD pipeline demonstrations

🎯 Purpose of This Repository

This repository is designed for:

DevOps beginners

CI/CD practice

Deployment pipeline testing

Docker & Kubernetes deployment exercises

Web server configuration practice

Reverse proxy and load balancer setup

The goal is to simulate real-world deployment scenarios using already built application files.

❓ Why is there NO package.json?

You may notice that this repository does not include:

package.json

node_modules

Source code (src/)

Build tools configuration

✅ Reason:

This repository only contains the final production build output (dist), not the development source code.

In a typical project:

Developers write source code.

The project is built using tools like:

Node.js

Webpack

Vite

React (or other frameworks)

A dist/ folder is generated.

Only the production build is deployed to servers.

This repository represents step 4 only.

Since this is already the compiled output:

No dependencies are required

No build process is required

No package.json is needed

Automated CI/CD deployment using Jenkins and AWS EKS.

---

# Production Deployment – AWS EKS

## Project Overview

This project demonstrates deploying a production-ready static React application using DevOps tools and AWS cloud infrastructure.

The application is containerized using Docker, deployed to Amazon EKS, and exposed through an AWS Network Load Balancer.

## Architecture

GitHub → Jenkins → Docker Build → DockerHub → AWS EKS → Network Load Balancer → Users

Monitoring:

Prometheus → Grafana → Alertmanager → Gmail Notifications

## Technologies Used

| Category | Technology |
|---|---|
| Cloud Provider | AWS |
| Infrastructure as Code | Terraform |
| Containerization | Docker |
| Container Registry | DockerHub |
| Container Orchestration | Kubernetes / AWS EKS |
| CI/CD | Jenkins |
| Load Balancing | AWS Network Load Balancer |
| Monitoring | Prometheus |
| Visualization | Grafana |
| Alert Management | Alertmanager |
| Notifications | Gmail |
| Web Server | Nginx |
| Version Control | Git and GitHub |

## AWS Infrastructure

- AWS Region: ap-south-2 (Hyderabad)
- VPC with CIDR 10.0.0.0/16
- Public and private subnets across two Availability Zones
- Internet Gateway and NAT Gateway
- Amazon EKS cluster: trend-eks
- Two worker nodes using t3.medium instances
- AWS Load Balancer Controller
- Network Load Balancer for application access

## Docker Configuration

The application uses Nginx to serve the prebuilt static files from the dist directory.

Docker image:

sangan132/trend-app

Build the image:

docker build -t sangan132/trend-app:latest .

Run locally:

docker run -d -p 3000:80 sangan132/trend-app:latest

Access:

http://localhost:3000

## CI/CD Pipeline

Jenkins automates the application deployment process.

Pipeline stages:

1. Checkout source code from GitHub.
2. Validate Dockerfile, Nginx configuration, and dist files.
3. Build the Docker image.
4. Run a container test.
5. Push the image to DockerHub.
6. Update the Kubernetes Deployment.
7. Verify the Kubernetes rollout.

GitHub integration uses Jenkins Poll SCM to detect repository changes approximately every two minutes.

## Kubernetes Deployment

- Deployment name: trend-app
- Replicas: 2
- Container port: 80
- Service name: trend-app-service
- Service type: LoadBalancer
- Container image: DockerHub

Kubernetes manages application replicas and performs readiness and liveness health checks.

## Monitoring and Alerting

Prometheus collects Kubernetes and node metrics.

Grafana provides monitoring dashboards.

Alertmanager sends email notifications through Gmail.

Configured alerts:

- HighNodeCPU: Node CPU usage above 80% for 5 minutes.
- HighNodeMemory: Node memory usage above 85% for 5 minutes.
- TrendAppPodNotReady: Application pod not ready for 2 minutes.

## Application URL

http://k8s-default-trendapp-6414b6c8de-91f16b66ec04173d.elb.ap-south-2.amazonaws.com

## Project Outcome

Successfully implemented an end-to-end DevOps deployment workflow using Terraform, Docker, Jenkins, Kubernetes, AWS EKS, Prometheus, Grafana, and Alertmanager.

The project demonstrates infrastructure provisioning, automated container builds, continuous deployment, application availability, monitoring, and email-based alert notifications.

## Security Notes

- AWS access uses an EC2 IAM role.
- DockerHub credentials are stored in Jenkins Credentials.
- Gmail App Password is stored in a Kubernetes Secret.
- Terraform state and sensitive configuration files should not be committed to GitHub.
- Jenkins access should remain restricted and protected.

