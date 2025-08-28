# Azure DevOps Pipelines for Terraform on Azure

This project shows how to run **Terraform** against Azure from **Azure DevOps Pipelines**.  
It includes a reusable remote state backend, single‑environment pipelines, and a multi‑environment pipeline with **manual approvals**.

---

## ✨ What’s inside

- **Terraform IaC** that provisions a sample Azure network layout and resource groups.
- **Remote state** in Azure Storage with per‑environment isolation (dev/test/prod) under `tf-backends/`.
- **Azure DevOps pipelines** for:
  - `basic.yml` – init/validate/plan/apply in one environment.
  - `manual-validation.yml` – same as basic but requires a **ManualValidation** step before `apply`.
  - `destroy.yml` – safely tears down resources.
  - `complete/complete-pipeline.yml` – **multi‑stage** (dev → test → prod) with approvals, implemented via the template `complete/terraform-template.yml`.
- Pipeline steps use **TerraformTaskV4** and publish/download artifacts to share the lockfile/state when needed.

---

## 📁 Repository structure

```
azure-pipelines/
  basic.yml
  destroy.yml
  lockfile-artifact.yml
  manual-validation.yml
  complete/
    complete-pipeline.yml
    terraform-template.yml
terraform/
  main.tf
  providers.tf
  variables.tf
tf-backends/
  main.tf               # calls modules/backend for dev/test/prod
  modules/backend/
    backend.tf          # RG + Storage + Container for Terraform state
README.md
```

---

## ⚙️ Prerequisites

- **Azure subscription** with permissions to create RG/Storage/Network.
- **Azure DevOps** project with:
  - An **Azure Resource Manager service connection** named `azurerm` (or update the variable in the YAML).
  - A **self‑hosted agent** or MS‑hosted agents with Terraform available (pipelines install Terraform v1.5.5 by default).
- **Terraform** (optional for local runs).

---

## 🧱 Remote state backend (recommended first step)

Use the Terraform in `tf-backends/` to create the storage account & container that will hold your Terraform state per environment.

```bash
cd tf-backends
terraform init
terraform apply
```

Outputs will include:

- `resource_group_name`
- `storage_account_name`
- `container_name`

Copy these values into `terraform/providers.tf` (or set them as pipeline variables).

**Example backend (providers.tf):**

```hcl
backend "azurerm" {
  resource_group_name  = "skink-rg"
  storage_account_name = "skinktfstate"
  container_name       = "tfstate"
  key                  = "terraform.tfstate"
}
```

---

## 🚀 Pipelines

### 1) Basic (single environment)

Runs `init → validate → plan → apply`. Triggered on `main` by default.

- File: `azure-pipelines/basic.yml`
- Variables you may want to change:
  - `azureServiceConnection`
  - `backendResourceGroup`
  - `backendStorageAccount`
  - `backendContainer`
  - `backendKey`

### 2) Manual validation

Same as **Basic**, but pauses before `apply` for a human approval (uses `ManualValidation@0`).

- File: `azure-pipelines/manual-validation.yml`
- Artifact `terraform-state` is downloaded before apply.

### 3) Destroy

Runs `init → validate → destroy --auto-approve`.

- File: `azure-pipelines/destroy.yml`

### 4) Complete multi‑environment

Three stages (**Dev → Test → Prod**) using a template to avoid duplication. Each stage can use a **different backend** and requires an approval email to continue.

- File: `azure-pipelines/complete/complete-pipeline.yml`
- Template: `azure-pipelines/complete/terraform-template.yml`
- Parameters per stage: `environmentName`, `backendRG`, `backendSA`, `backendKey`, `azureServiceConnection`, `approvalEmail`

---

## 🛠️ Terraform configuration

- **Inputs**: see `terraform/variables.tf` (e.g., `resource_group_location`, `resource_group_name_prefix`).
- **Resources**: see `terraform/main.tf` (resource groups, VNets, subnets).
- **Providers & Backend**: `terraform/providers.tf` (azurerm provider and remote state backend).

> Tip: When moving to production, set secrets like storage account names and service connections as **secure pipeline variables** or **variable groups**.

---

## 🔐 Security notes

- Scope the service connection to least privilege (e.g., RG level instead of subscription when possible).
- Store sensitive data (e.g., storage keys) in **Azure DevOps Library → Variable groups** marked secret.
- Consider enabling **state file versioning & soft delete** on the storage account.

---

## 🧪 Local development

```bash
cd terraform
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply
```

Use `-var` or `.tfvars` files to override defaults. Example:

```bash
terraform apply -var="resource_group_location=switzerlandnorth"
```
