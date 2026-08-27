# AWS Production Platform: Infrastructure, CI/CD & Containerized Deployment

> A production-oriented AWS platform demonstrating infrastructure as code, containerized application deployment, CI/CD automation, cloud security, networking, observability, scalability, and operational practices.

**Repository:** `aws-production-platform`
**Project:** AWS Production Platform
**Application:** LaunchPad API
**Status:** Planning / Initial Implementation

---

## 1. Project Overview

AWS Production Platform is a portfolio project designed to demonstrate how a small startup could build and operate a production-oriented containerized application platform on AWS.

The application itself is intentionally simple. **LaunchPad API** is a Node.js/Express REST API backed by PostgreSQL and serves primarily as the workload through which the underlying cloud and DevOps platform can be demonstrated.

The primary focus of this project is the platform:

- AWS networking and multi-AZ architecture
- Infrastructure as Code with Terraform
- Containerization with Docker
- Amazon ECS with AWS Fargate
- CI/CD with GitHub Actions
- Secure GitHub-to-AWS authentication using OIDC
- IAM and least-privilege access
- Secrets management
- Application and infrastructure monitoring
- Centralized logging
- High availability and scaling
- Production-style operational practices
- Simulated incident response

This project uses **ECS Fargate rather than Kubernetes/EKS** intentionally. Kubernetes will be explored separately so this project can concentrate on broader AWS and DevOps fundamentals.

---

## 2. Why This Project

A cloud platform is more than deploying an application to a server.

This project is intended to demonstrate the engineering decisions required around the application lifecycle:

```text
Code
  ↓
CI Validation
  ↓
Container Build
  ↓
Security Scanning
  ↓
Container Registry
  ↓
Infrastructure / Deployment
  ↓
Load Balancer
  ↓
Application
  ↓
Database
  ↓
Monitoring & Operations
```

The goal is to demonstrate practical understanding of how these components interact rather than simply demonstrating individual AWS services.

---

## 3. Project Goals

The planned platform aims to demonstrate:

- Designing a secure AWS VPC across multiple Availability Zones
- Separating public, application, and database network tiers
- Running stateless containers on ECS Fargate
- Using Amazon ECR as the container registry
- Using RDS PostgreSQL for persistent application data
- Provisioning infrastructure through reusable Terraform modules
- Maintaining separate development and production configurations
- Building automated CI/CD workflows with GitHub Actions
- Authenticating GitHub Actions to AWS without long-lived credentials
- Managing application secrets through AWS Secrets Manager
- Centralizing logs and operational metrics in CloudWatch
- Supporting horizontal application scaling
- Designing for service failure and recovery
- Applying least-privilege security principles
- Considering AWS operating costs during architectural decisions

---

## 4. Architecture

The intended high-level architecture is:

```text
                              Internet
                                 │
                                 ▼
                       ┌───────────────────┐
                       │ Application       │
                       │ Load Balancer     │
                       │      (ALB)        │
                       └─────────┬─────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                    ▼                         ▼
             ┌─────────────┐           ┌─────────────┐
             │ ECS Fargate │           │ ECS Fargate │
             │   Task      │           │   Task      │
             │     AZ-A    │           │     AZ-B    │
             └──────┬──────┘           └──────┬──────┘
                    │                         │
                    └────────────┬────────────┘
                                 │
                                 ▼
                       ┌───────────────────┐
                       │ RDS PostgreSQL    │
                       │ Private Database  │
                       └───────────────────┘
```

Supporting AWS services:

```text
                         ┌──────────────┐
                         │    Amazon    │
                         │     ECR      │
                         └──────┬───────┘
                                │
                                ▼
GitHub ──► GitHub Actions ──► ECS Fargate
              │                 │
              │                 ├──► Secrets Manager
              │                 │
              │                 └──► CloudWatch
              │
              ▼
         GitHub OIDC
              │
              ▼
          AWS IAM Role
              │
              ▼
             AWS
```

---

## 5. Architecture Diagram

The intended AWS network architecture:

```text
                                      Internet
                                          │
                                          ▼
                               ┌────────────────────┐
                               │   Internet Gateway │
                               └─────────┬──────────┘
                                         │
                    ┌────────────────────┴────────────────────┐
                    │                 AWS VPC                  │
                    │                                          │
                    │   Availability Zone A   │   AZ B         │
                    │                        │                  │
                    │   ┌────────────────┐   │   ┌───────────┐ │
                    │   │ Public Subnet  │   │   │  Public   │ │
                    │   │                │   │   │  Subnet   │ │
                    │   │ ALB            │   │   │   ALB     │ │
                    │   └───────┬────────┘   │   └─────┬─────┘ │
                    │           │            │         │       │
                    │   ┌───────▼────────┐   │   ┌─────▼─────┐ │
                    │   │ Private App    │   │   │ Private   │ │
                    │   │ Subnet         │   │   │ App       │ │
                    │   │ ECS Fargate    │   │   │ ECS       │ │
                    │   └───────┬────────┘   │   └─────┬─────┘ │
                    │           │            │         │       │
                    │           └────────────┼─────────┘       │
                    │                        │                 │
                    │              ┌─────────▼─────────┐       │
                    │              │ Private DB Subnet │       │
                    │              │ RDS PostgreSQL    │       │
                    │              └───────────────────┘       │
                    │                                          │
                    └──────────────────────────────────────────┘
```

The intended application traffic path is:

```text
Internet
   │
   ▼
Application Load Balancer
   │
   ▼
ECS Fargate
   │
   ▼
RDS PostgreSQL
```

The database is intended to remain private and must not be directly accessible from the public internet.

---

## 6. Technology Stack

| Area                   | Technology                                                       |
| ---------------------- | ---------------------------------------------------------------- |
| Cloud                  | Amazon Web Services (AWS)                                        |
| Networking             | Amazon VPC, Subnets, Route Tables, Internet Gateway, NAT Gateway |
| Compute                | Amazon ECS                                                       |
| Container Runtime      | AWS Fargate                                                      |
| Load Balancing         | Application Load Balancer                                        |
| Container Registry     | Amazon ECR                                                       |
| Database               | Amazon RDS PostgreSQL                                            |
| Infrastructure as Code | Terraform                                                        |
| CI/CD                  | GitHub Actions                                                   |
| AWS Authentication     | GitHub OIDC + AWS IAM                                            |
| Secrets                | AWS Secrets Manager                                              |
| Monitoring             | Amazon CloudWatch                                                |
| Logging                | CloudWatch Logs                                                  |
| Application            | Node.js / Express                                                |
| Containerization       | Docker                                                           |
| Version Control        | Git / GitHub                                                     |

---

## 7. Application

### LaunchPad API

LaunchPad API is a deliberately simple Node.js/Express REST API.

Its purpose is to provide a realistic workload for the AWS platform rather than demonstrate complex application development.

Conceptual endpoints:

| Method   | Endpoint         | Purpose                  |
| -------- | ---------------- | ------------------------ |
| `GET`    | `/health`        | Application health check |
| `GET`    | `/api/users`     | Retrieve users           |
| `POST`   | `/api/users`     | Create a user            |
| `GET`    | `/api/users/:id` | Retrieve a specific user |
| `DELETE` | `/api/users/:id` | Delete a user            |

PostgreSQL provides persistent storage for application data.

The application is intended to remain:

- Stateless
- Containerized
- Horizontally scalable
- Configurable through environment variables
- Independent of the underlying ECS task
- Dependent on external PostgreSQL persistence

Application complexity is intentionally limited so that the infrastructure and DevOps implementation remain the primary focus.

---

## 8. AWS Infrastructure

The planned AWS infrastructure consists of:

### Amazon VPC

The VPC provides the isolated network environment for the platform.

It will contain separate subnet tiers distributed across multiple Availability Zones.

### Public Subnets

Public subnets are intended primarily for internet-facing infrastructure such as the Application Load Balancer.

They have routing toward the Internet Gateway.

### Private Application Subnets

ECS Fargate tasks will run in private application subnets.

The application containers should not require direct inbound internet access.

Outbound internet connectivity, where required, can use a NAT Gateway.

### Private Database Subnets

RDS PostgreSQL will reside in private database subnets.

The database should only be reachable from authorized application workloads.

### Application Load Balancer

The ALB provides:

- Internet-facing entry point
- Traffic distribution across ECS tasks
- Application health checks
- HTTP request routing
- Availability across multiple Availability Zones

### ECS Fargate

ECS Fargate provides serverless container execution.

The platform is intended to run multiple application tasks so that failure of an individual task does not necessarily result in application downtime.

### Amazon ECR

ECR will store versioned Docker images produced by the CI/CD pipeline.

### Amazon RDS PostgreSQL

RDS provides managed PostgreSQL persistence.

The database will be separated from the application tier and remain private.

### IAM

IAM will control access between GitHub Actions and AWS as well as between AWS workloads and supporting services.

### Secrets Manager

Secrets Manager will store sensitive application configuration such as database credentials.

### CloudWatch

CloudWatch will provide the primary monitoring and centralized logging solution.

---

## 9. Networking

The intended network segmentation is:

```text
                    VPC
                     │
        ┌────────────┼────────────┐
        │            │            │
        ▼            ▼            ▼
   Public Tier   Application   Database Tier
                 Tier
        │            │            │
        ▼            ▼            ▼
       ALB       ECS Fargate    RDS
```

### Public Subnets

Public subnets are intended for internet-facing components such as the ALB.

Traffic can reach these subnets through the Internet Gateway.

### Private Application Subnets

ECS tasks will run in private subnets.

They should receive inbound application traffic through the ALB rather than directly from the internet.

### Private Database Subnets

The RDS database will reside in private database subnets.

There should be no public route exposing the database directly to the internet.

### Security Groups

Security groups will control permitted traffic between tiers.

The intended model is:

```text
Internet
   │
   │ HTTP/HTTPS
   ▼
ALB Security Group
   │
   │ Application Port
   ▼
ECS Security Group
   │
   │ PostgreSQL Port
   ▼
RDS Security Group
```

The RDS security group should permit database traffic only from the appropriate application security group rather than allowing broad internet access.

### Route Tables

Route tables will control traffic paths between public and private network tiers.

Public subnets can route internet-bound traffic through the Internet Gateway.

Private application subnets may use a NAT Gateway for required outbound internet connectivity.

Private database subnets should remain isolated from direct internet access.

### Availability Zones

Multiple Availability Zones are used to reduce dependence on a single physical AWS location within the region.

The application tier is intended to distribute ECS tasks across multiple Availability Zones.

---

## 10. Infrastructure as Code

Terraform will be used to provision and manage AWS infrastructure.

The Terraform architecture is intended to use reusable modules:

```text
infrastructure/
├── modules/
│   ├── vpc/
│   ├── iam/
│   ├── ecr/
│   ├── ecs/
│   ├── alb/
│   ├── rds/
│   └── monitoring/
│
└── environments/
    ├── dev/
    └── prod/
```

Planned module responsibilities include:

| Module       | Responsibility                              |
| ------------ | ------------------------------------------- |
| `vpc`        | VPC, subnets, routing, gateways             |
| `iam`        | IAM roles and policies                      |
| `ecr`        | ECR repositories and configuration          |
| `ecs`        | ECS cluster, task definitions, services     |
| `alb`        | Load balancer, listeners, target groups     |
| `rds`        | PostgreSQL infrastructure                   |
| `monitoring` | CloudWatch metrics, alarms, and logging     |
| `secrets`    | Secrets Manager resources where appropriate |

Terraform workflows will include formatting, validation, planning, and application of infrastructure changes.

Infrastructure changes should be reviewed through pull requests before being applied to production.

---

## 11. CI/CD Pipeline

GitHub Actions will provide the primary CI/CD automation.

Two primary workflows are planned.

### Continuous Integration

The CI workflow is intended to run for pull requests.

```text
Pull Request
     │
     ▼
Code / Lint Checks
     │
     ▼
Unit Tests
     │
     ▼
Terraform Format
     │
     ▼
Terraform Validate
     │
     ▼
Security Checks
     │
     ▼
Docker Build Validation
     │
     ▼
Pull Request Result
```

Planned CI checks:

- Node.js code/lint validation
- Unit tests
- Terraform formatting
- Terraform validation
- Security checks
- Docker image build validation

The purpose is to catch issues before changes are merged.

### Continuous Deployment

The deployment workflow is intended to run after merges to `main`.

```text
Merge to main
     │
     ▼
Application Build
     │
     ▼
Tests
     │
     ▼
Docker Image Build
     │
     ▼
Container Vulnerability Scan
     │
     ▼
Push Image to ECR
     │
     ▼
Terraform Plan / Apply
     │
     ▼
ECS Deployment
     │
     ▼
Health Verification
```

The exact Terraform apply strategy may differ between development and production.

Production changes should be designed to require appropriate review and controlled execution rather than blindly applying every infrastructure change.

---

## 12. GitHub OIDC Authentication

GitHub Actions should not use long-lived AWS access keys.

The intended authentication model is:

```text
GitHub
   │
   ▼
GitHub Actions
   │
   ▼
GitHub OIDC
   │
   ▼
AWS IAM Role
   │
   ▼
Temporary AWS Credentials
   │
   ▼
AWS Resources
```

GitHub OIDC allows the workflow to obtain temporary AWS credentials through an IAM role.

This is preferable to storing permanent AWS access keys in GitHub because:

- Long-lived credentials do not need to be stored as GitHub secrets.
- Temporary credentials have a limited lifetime.
- IAM policies can restrict what the workflow is allowed to do.
- Trust policies can restrict which GitHub repository and workflow contexts may assume the role.
- Credential rotation requirements are reduced.
- A compromised repository secret does not expose a permanent AWS access key.

The planned implementation should use narrowly scoped IAM permissions and restrictive OIDC trust conditions.

---

## 13. Security

Security is a core design consideration of the project.

### IAM Least Privilege

IAM permissions should provide only the access required for a specific workload.

Separate roles are intended for appropriate purposes, such as:

- ECS task execution
- ECS application task permissions
- GitHub Actions infrastructure/deployment operations

Broad administrative permissions should not be used merely for convenience.

### Network Isolation

The architecture separates:

```text
Public
  │
  ▼
ALB
  │
  ▼
Private Application
  │
  ▼
Private Database
```

The database is not intended to be publicly accessible.

### Security Groups

Security groups will enforce service-to-service communication.

The intended principle is to allow only required traffic between:

- Internet → ALB
- ALB → ECS
- ECS → RDS

### GitHub OIDC

GitHub Actions will authenticate using OIDC and temporary credentials rather than long-lived AWS access keys.

### Container Security

The project intends to include:

- Container vulnerability scanning
- Minimal base images where practical
- Non-root container execution where practical
- No credentials embedded in images
- Externalized configuration
- Versioned images

### Encryption

Encryption will be enabled where appropriate for AWS-managed resources and sensitive data.

### Git Security

Credentials, passwords, tokens, private keys, and other sensitive values must not be committed to Git.

`.gitignore` should exclude local secrets and environment-specific files where appropriate.

---

## 14. Secrets Management

Sensitive application configuration should not be stored directly in:

- Source code
- Dockerfiles
- Git history
- Terraform source files containing plaintext secrets
- GitHub workflow files

AWS Secrets Manager is intended to manage sensitive runtime configuration.

Conceptually:

```text
AWS Secrets Manager
        │
        ▼
   ECS Task
        │
        ▼
 LaunchPad API
        │
        ▼
 RDS PostgreSQL
```

The ECS task should obtain only the secrets required by the application.

Database credentials and other sensitive configuration should therefore remain external to the application image.

---

## 15. Containerization

LaunchPad API will be packaged as a Docker image.

The container design is intended to support:

### Reproducible Builds

The Dockerfile should produce consistent application images from a defined dependency set.

### Minimal Base Image

A reasonably minimal Node.js base image should be considered to reduce unnecessary packages and attack surface.

### Non-Root Execution

The application should run as a non-root user where practical.

### Health Checks

The application exposes:

```text
GET /health
```

This endpoint can be used for application health verification and ECS/ALB health checks.

### Stateless Containers

Application state should not depend on the local container filesystem.

Persistent state belongs in PostgreSQL or other external managed services.

### Externalized Configuration

Environment-specific configuration and secrets should be injected at runtime rather than baked into the Docker image.

---

## 16. Monitoring and Logging

Amazon CloudWatch will be the primary monitoring and logging platform for this project.

Prometheus and Grafana are intentionally **not** core components of this architecture. They will be explored separately in an observability-focused portfolio project.

### ECS Monitoring

Planned metrics include:

- ECS CPU utilization
- ECS memory utilization
- ECS task health
- Task count
- Service health

### Application Load Balancer Monitoring

Planned metrics include:

- Request count
- Response time
- HTTP 4xx responses
- HTTP 5xx responses
- Target health

### RDS Monitoring

Planned metrics include:

- CPU utilization
- Database connections
- Storage utilization
- Other relevant RDS health metrics

### Centralized Application Logging

Application logs from ECS tasks will be centralized in CloudWatch Logs.

This provides a single location for investigating:

- Application errors
- Request failures
- Deployment problems
- Runtime behavior
- Incident symptoms

The project should also define sensible log retention rather than retaining all logs indefinitely.

---

## 17. High Availability and Scalability

The architecture is designed to demonstrate production-style availability and scaling patterns.

### Multiple ECS Tasks

Running multiple ECS tasks allows traffic to continue being served if an individual task becomes unhealthy.

### Multiple Availability Zones

Application tasks will be distributed across multiple Availability Zones where practical.

### ECS Health Checks

Unhealthy tasks should be detected and replaced by ECS according to the configured service behavior.

### Application Load Balancer

The ALB distributes requests across healthy application tasks.

### ECS Service Auto Scaling

ECS service auto scaling is planned to allow the application tier to adjust task capacity based on demand.

### Managed Database

RDS reduces the operational burden associated with managing the database infrastructure directly.

### Tier Separation

The architecture separates:

```text
Load Balancing
      │
      ▼
Application
      │
      ▼
Database
```

This separation makes it possible to scale and secure each tier independently.

This architecture is **production-oriented**, but it should not be interpreted as a claim that the resulting portfolio environment is equivalent to a fully hardened production system.

---

## 18. Environment Strategy

The Terraform configuration will separate environments at minimum into:

```text
infrastructure/
└── environments/
    ├── dev/
    └── prod/
```

### Development

The development environment is intended for:

- Testing infrastructure changes
- Testing application deployments
- Validating Terraform modules
- Testing CI/CD behavior
- Simulating operational scenarios

Development resources should be sized with cost awareness.

### Production

The production configuration is intended to represent a more conservative deployment with stronger availability and operational considerations.

Production infrastructure should not be treated as identical to development simply by changing variable values.

Environment-specific configuration should be explicit and reviewable.

---

## 19. Repository Structure

The planned repository structure is:

```text
aws-production-platform/
├── application/
│   ├── src/
│   ├── tests/
│   ├── package.json
│   ├── package-lock.json
│   └── Dockerfile
│
├── infrastructure/
│   ├── modules/
│   │   ├── vpc/
│   │   ├── iam/
│   │   ├── ecr/
│   │   ├── ecs/
│   │   ├── alb/
│   │   ├── rds/
│   │   └── monitoring/
│   │
│   └── environments/
│       ├── dev/
│       └── prod/
│
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy.yml
│
├── docs/
│   ├── architecture.md
│   ├── deployment.md
│   ├── security.md
│   └── incidents/
│       ├── 001-database-connectivity.md
│       ├── 002-failed-deployment.md
│       └── 003-high-cpu.md
│
├── .gitignore
├── README.md
└── LICENSE
```

The structure may evolve during implementation.

---

## 20. Deployment Flow

The intended deployment lifecycle is:

```text
Developer
   │
   ▼
Git Push
   │
   ▼
Pull Request
   │
   ▼
GitHub Actions CI
   │
   ├── Tests
   ├── Lint
   ├── Terraform Validation
   ├── Security Checks
   └── Docker Build Validation
   │
   ▼
Code Review
   │
   ▼
Merge to main
   │
   ▼
GitHub Actions Deployment
   │
   ├── Build Application
   ├── Build Docker Image
   ├── Scan Image
   ├── Push to ECR
   ├── Terraform Plan / Apply
   └── Deploy ECS Service
   │
   ▼
Health Verification
   │
   ▼
CloudWatch Monitoring
```

The exact implementation of deployment ordering will be refined during development.

---

## 21. Failure and Incident Scenarios

The project will include simulated production-style incidents to demonstrate operational troubleshooting rather than only successful deployment.

Each incident document is intended to capture:

1. Impact
2. Symptoms
3. Detection
4. Investigation
5. Root cause
6. Resolution
7. Preventive action

### Incident 001 — Database Connectivity Failure

Scenario:

The LaunchPad API can no longer establish a connection to PostgreSQL.

Potential investigation areas:

- ECS task logs
- RDS status
- Security groups
- Network routes
- Database credentials
- Secrets Manager configuration
- Database connection limits

The actual root cause and resolution will be documented after the scenario is implemented and simulated.

### Incident 002 — Failed Application Deployment

Scenario:

A new application version is deployed but fails health checks.

Potential investigation areas:

- ECS service events
- ECS task status
- Container logs
- ALB target health
- Container image
- Application startup
- Environment variables
- Health endpoint

The actual root cause and resolution will be documented after implementation.

### Incident 003 — High CPU Utilization

Scenario:

Application CPU utilization increases significantly under simulated workload.

Potential investigation areas:

- ECS CPU metrics
- CloudWatch logs
- Request volume
- Application behavior
- ECS task capacity
- Auto scaling configuration

The scenario will be used to demonstrate detection, investigation, scaling, and preventive action.

---

## 22. Cost Considerations

This project follows a startup-oriented architecture where operational simplicity and reliability must be balanced against cloud cost.

Important cost areas include:

### Fargate Sizing

CPU and memory allocations should be sufficient for the workload without unnecessarily overprovisioning tasks.

### RDS Sizing

Database instance and storage sizing should reflect the small portfolio workload.

### NAT Gateway

NAT Gateways can introduce meaningful costs. Their necessity and placement should therefore be considered carefully.

### CloudWatch Logs

Log volume and retention should be controlled to avoid unnecessary storage costs.

### ECR Storage

Unused container images should not accumulate indefinitely.

### Data Transfer

Traffic between AWS services and external destinations can introduce data transfer charges.

### Development Resources

Development environments should be destroyed when they are not required.

For example:

```bash
terraform destroy
```

can be used for disposable development infrastructure when appropriate.

No exact monthly AWS cost is stated because actual costs depend on the final implementation, region, workload, resource sizing, traffic, and usage patterns.

---

## 23. Key Design Decisions

### ECS Fargate Instead of EKS

Kubernetes/EKS is intentionally excluded from this project.

The goal is to demonstrate a broader set of cloud and DevOps capabilities:

- AWS networking
- IAM
- Docker
- Terraform
- CI/CD
- Secrets management
- Monitoring
- Scaling
- Production operations

Introducing Kubernetes would shift part of the project's focus toward Kubernetes-specific operational complexity.

Kubernetes will instead be demonstrated in a separate portfolio project.

### Managed RDS Instead of Self-Managed PostgreSQL

RDS is used to demonstrate the operational benefits of a managed database service while keeping the application architecture realistic.

### Terraform Instead of Manual Infrastructure

Terraform provides:

- Repeatable infrastructure
- Version-controlled configuration
- Reviewable changes
- Reusable modules
- Environment separation

### GitHub OIDC Instead of AWS Access Keys

OIDC avoids the need for long-lived AWS credentials in GitHub Actions and supports temporary, role-based access.

### CloudWatch Instead of Prometheus/Grafana

CloudWatch is sufficient for this project's core AWS monitoring requirements.

Prometheus/Grafana will be covered separately so that the two portfolio projects demonstrate different observability approaches rather than unnecessarily duplicating the same stack.

---

## 24. Lessons Learned

This section will be updated during implementation.

Areas expected to be documented include:

- Designing AWS network boundaries
- Terraform module design
- Managing dependencies between AWS resources
- ECS task and service configuration
- Container health checks
- Secure CI/CD authentication
- IAM policy design
- Secrets injection into containers
- CloudWatch monitoring and log investigation
- ECS deployment behavior
- Failure recovery
- AWS cost trade-offs
- Differences between development and production environments

The lessons documented here will be based on actual implementation and troubleshooting rather than theoretical claims.

---

## 25. Future Improvements

Potential future improvements include:

- HTTPS with a managed TLS certificate
- Route 53 DNS integration
- WAF protection for the ALB
- Blue/green or canary deployment strategies
- More comprehensive automated integration testing
- Database backup and recovery testing
- Disaster recovery planning
- Terraform remote state management
- Terraform state locking
- More granular CloudWatch alarms
- AWS CloudTrail integration
- AWS Config integration
- Enhanced container image lifecycle management
- Dependency update automation
- Load testing
- Performance benchmarking
- SAST and dependency security scanning
- Formal runbooks
- Expanded incident simulations

These are future improvements and are not considered implemented unless explicitly marked as completed.

---

## 26. Getting Started

### Prerequisites

The following tools/accounts are expected to be required:

- AWS account
- AWS CLI
- Terraform
- Docker
- Git
- Node.js
- GitHub account

Verify local installations as appropriate:

```bash
aws --version
terraform version
docker --version
git --version
node --version
npm --version
```

### Clone the Repository

```bash
git clone <repository-url>
cd aws-production-platform
```

The repository URL should be replaced with the actual repository URL after the project is published.

### Install Application Dependencies

```bash
cd application
npm install
```

### Run Tests

```bash
npm test
```

### Run the Application Locally

```bash
npm start
```

The local application should expose the `/health` endpoint according to the final application implementation.

### Terraform Initialization

Move to the appropriate environment:

```bash
cd infrastructure/environments/dev
```

Initialize Terraform:

```bash
terraform init
```

### Format Terraform

```bash
terraform fmt -recursive
```

### Validate Terraform

```bash
terraform validate
```

### Create a Terraform Plan

```bash
terraform plan
```

Review the proposed infrastructure changes before applying them.

### Apply Terraform

```bash
terraform apply
```

The exact variables, backend configuration, authentication requirements, and deployment sequence will depend on the final implementation.

### Destroy Development Infrastructure

When development resources are no longer required:

```bash
terraform destroy
```

This should be used carefully and only against the intended environment.

---

## 27. Project Status

**Current status: Planning / Initial Implementation**

The project is being created before infrastructure implementation. Therefore, unchecked items below represent planned work rather than completed functionality.

### Foundation

- [ ] Create LaunchPad API
- [ ] Add unit tests
- [ ] Add Dockerfile
- [ ] Add application health endpoint
- [ ] Add PostgreSQL integration

### AWS Infrastructure

- [ ] Create VPC
- [ ] Create public subnets
- [ ] Create private application subnets
- [ ] Create private database subnets
- [ ] Configure route tables
- [ ] Configure Internet Gateway
- [ ] Configure required NAT Gateway resources
- [ ] Create ECS Fargate cluster
- [ ] Create ECS service
- [ ] Create Application Load Balancer
- [ ] Create ECR repository
- [ ] Create RDS PostgreSQL
- [ ] Configure IAM roles
- [ ] Configure Secrets Manager
- [ ] Configure CloudWatch logging and monitoring

### Terraform

- [ ] Create reusable Terraform modules
- [ ] Create development environment
- [ ] Create production environment
- [ ] Add Terraform validation
- [ ] Add Terraform plan workflow
- [ ] Document infrastructure decisions

### CI/CD

- [ ] Create GitHub Actions CI workflow
- [ ] Add code/lint checks
- [ ] Add unit tests
- [ ] Add Terraform formatting and validation
- [ ] Add security checks
- [ ] Add Docker build validation
- [ ] Create deployment workflow
- [ ] Add container vulnerability scanning
- [ ] Push images to ECR
- [ ] Deploy to ECS
- [ ] Add post-deployment health verification

### Security

- [ ] Configure GitHub OIDC
- [ ] Create restricted GitHub Actions IAM role
- [ ] Apply least-privilege IAM policies
- [ ] Configure security groups
- [ ] Keep RDS private
- [ ] Integrate Secrets Manager
- [ ] Configure appropriate encryption
- [ ] Verify no credentials are committed

### Observability

- [ ] Configure CloudWatch Logs
- [ ] Monitor ECS CPU utilization
- [ ] Monitor ECS memory utilization
- [ ] Monitor ECS task health
- [ ] Monitor ALB request count
- [ ] Monitor ALB response time
- [ ] Monitor ALB 4xx/5xx responses
- [ ] Monitor RDS CPU
- [ ] Monitor RDS connections
- [ ] Monitor RDS storage
- [ ] Configure relevant alarms

### Operations

- [ ] Document deployment procedure
- [ ] Document architecture
- [ ] Document security model
- [ ] Simulate database connectivity failure
- [ ] Simulate failed deployment
- [ ] Simulate high CPU utilization
- [ ] Document incident investigations
- [ ] Document lessons learned
- [ ] Review AWS cost considerations

---

## 28. Author

**Nikhil Mhatre**

GitHub: https://github.com/Nikhil-Mhatre

LinkedIn: https://www.linkedin.com/in/nikhilmhatre4757/

---

## Project Philosophy

This project is intentionally designed as a **portfolio demonstration of engineering practices**, not as a claim that a fully hardened production system has been built.

The application is deliberately simple. The engineering challenge is the platform around it:

```text
                 AWS Production Platform

       ┌─────────────────────────────────────┐
       │             GitHub                  │
       │                                     │
       │  Code → PR → CI → OIDC → Deploy    │
       └──────────────────┬──────────────────┘
                          │
                          ▼
                 ┌─────────────────┐
                 │      AWS IAM    │
                 └────────┬────────┘
                          │
                          ▼
                 ┌─────────────────┐
                 │       VPC       │
                 │                 │
                 │  ALB            │
                 │   ↓             │
                 │  ECS Fargate    │
                 │   ↓             │
                 │  RDS PostgreSQL │
                 └─────────────────┘
                          │
              ┌───────────┼───────────┐
              ▼           ▼           ▼
             ECR    Secrets Manager  CloudWatch
```

The implementation will be evaluated not only by whether the application runs, but by whether the infrastructure, security controls, deployment process, monitoring, failure handling, and operational decisions are understandable, reproducible, and defensible.
