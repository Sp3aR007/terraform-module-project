# Terraform Module Project

## 📌 Overview

This repository contains a **modular Terraform infrastructure project** designed using best practices for **scalability, security, and reusability**.

The infrastructure is split into independent Terraform modules and uses an **S3 remote backend** for centralized and safe state management.

### Included Modules:
- **Network**
- **Load Balancer**
- **Bastion Host**
- **Backend**
- **Frontend**
- **Database**

Each module is designed to be loosely coupled and configurable via input variables.

---

## 🏗️ Architecture Overview

The high-level architecture follows this flow:

Internet
|
Load Balancer
|
Frontend Instances
|
Backend Instances
|
Database



- **Bastion Host** provides secure SSH access
- **Network module** creates VPC, subnets, routing
- **Load Balancer** distributes traffic
- **Frontend & Backend** host application tiers
- **Database** stores persistent data

---

## 📂 Repository Structure

terraform-module-project/
|-- modules
|   |-- backend
|   |-- bastion
|   |-- database
|   |-- frontend
|   |-- loadbalancer
|   `-- network
`-- terraform



---

## 📦 Module Details

### 🔹 Network Module
Creates the base networking layer.

**Resources:**
- VPC
- Public & private subnets
- Internet Gateway
- Route tables

**Purpose:**  
Provides isolated networking for all other modules.

---

### 🔹 Load Balancer Module
Handles incoming traffic distribution.

**Resources:**
- Application Load Balancer
- Target groups
- Listener rules

**Purpose:**  
Ensures high availability and scalability.

---

### 🔹 Bastion Module
Secure access point for private resources.

**Resources:**
- Bastion EC2 instance
- Security groups
- SSH access configuration

**Purpose:**  
Allows controlled administrative access to private subnets.

---

### 🔹 Frontend Module
Hosts the user-facing application layer.

**Resources:**
- EC2 / Auto Scaling Group
- Security groups

**Purpose:**  
Serves UI or public APIs.

---

### 🔹 Backend Module
Handles business logic and internal APIs.

**Resources:**
- EC2 instances
- Internal security groups

**Purpose:**  
Processes requests from frontend and communicates with the database.

---

### 🔹 Database Module
Provides persistent storage.

**Resources:**
- RDS / Database instance
- Subnet groups
- Security groups

**Purpose:**  
Stores application data securely in private subnets.

---

## 🚀 Usage Example (Root Module)

```hcl
module "network" {
  source = "./modules/network"
  vpc_cidr = "10.0.0.0/16"
}

module "loadbalancer" {
  source = "./modules/loadbalancer"
  vpc_id = module.network.vpc_id
}

module "frontend" {
  source = "./modules/frontend"
  subnet_ids = module.network.public_subnets
  lb_target_group_arn = module.loadbalancer.target_group_arn
}

module "backend" {
  source = "./modules/backend"
  subnet_ids = module.network.private_subnets
}

module "database" {
  source = "./modules/database"
  subnet_ids = module.network.private_subnets
}

module "bastion" {
  source = "./modules/bastion"
  subnet_id = module.network.public_subnets[0]
}
```
⚙️ Prerequisites

Terraform >= 1.0

Cloud provider CLI configured (AWS)

Proper IAM permissions

Remote backend (AWS S3 recommended)

🧪 Terraform Commands
```
terraform init
terraform validate
terraform plan
terraform apply
```

Destroy resources:
```
terraform destroy
```

📥 Inputs & 📤 Outputs

Each module defines:

variables.tf → configurable inputs

outputs.tf → exposed values

Refer to individual module folders for exact definitions.
