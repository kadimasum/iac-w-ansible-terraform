# Terraform End-to-End Fundamentals (Learner Documentation)

This document is an end-to-end learning guide to Terraform fundamentals, covering the Terraform workflow, HCL language basics (including data types), variables/outputs, providers/resources/data sources, modules, state/backends, and the most commonly used Terraform commands. It’s designed as an accompanying handout for learners (not a slide deck).

---

## 1) What is Terraform?

Terraform (by HashiCorp) is an **Infrastructure as Code (IaC)** tool that lets you define infrastructure in configuration files and then **plan** and **apply** those changes safely.

Key ideas:
- **Declarative**: you describe the desired state (what you want), Terraform decides the steps to reach it.
- **Provider-based**: Terraform uses providers (plugins) to talk to external APIs (AWS, Azure, GCP, Kubernetes, GitHub, etc.).
- **State-driven**: Terraform tracks what it manages using a state file, enabling drift detection and safe updates.

---

## 2) Core Building Blocks (Conceptual Model)

### Provider
A provider is the integration layer between Terraform and an external API.

### Resource
A resource is something Terraform **creates/updates/deletes** (e.g., a cloud subnet, a VM, a bucket).

### Data Source
A data source lets Terraform **read** information about existing infrastructure (things not necessarily created by Terraform).

### Module
A module is a reusable package of Terraform configuration. The “root module” is the directory you run Terraform from; “child modules” are called by the root (or other modules).

### State
State is Terraform’s record of managed objects and metadata required to plan changes correctly.

---

## 3) Typical Terraform Workflow

1. **Write**: create `.tf` configuration files.
2. **Initialize**: `terraform init` downloads providers/modules and configures state backend.
3. **Validate and format**: `terraform fmt`, `terraform validate`.
4. **Plan**: `terraform plan` previews changes.
5. **Apply**: `terraform apply` makes changes.
6. **Operate / maintain**: change code over time, refactor, import resources, manage state safely.

---

## 4) Recommended Project Structure

Common layout (not mandatory, but widely used):

- `main.tf` — primary resources and/or module calls
- `providers.tf` — provider configurations and versions
- `variables.tf` — input variables
- `outputs.tf` — outputs
- `locals.tf` — local values
- `versions.tf` — Terraform and provider version constraints
- `backend.tf` — backend configuration (or inside `terraform { }`)
- `modules/` — local reusable modules
- `envs/` — environment overlays (optional pattern)

---

## 5) Terraform Configuration Blocks (HCL)

Terraform uses **HCL** (HashiCorp Configuration Language). The most common blocks:

- `terraform { ... }` — required versions, backend, required providers
- `provider "..." { ... }` — provider configuration
- `resource "TYPE" "NAME" { ... }` — managed objects
- `data "TYPE" "NAME" { ... }` — read-only lookups
- `module "NAME" { ... }` — module usage
- `variable "NAME" { ... }` — inputs
- `output "NAME" { ... }` — exported values
- `locals { ... }` — computed values

HCL basics:
- Assignments: `key = value`
- Comments: `#`, `//`, `/* ... */`
- Expressions: functions, conditionals, loops
- Interpolation: `${...}` exists, but often not needed in modern Terraform because expressions can be used directly.

---

## 6) Terraform Data Types (with Examples)

Terraform’s type system helps validate inputs and make modules safer.

### 6.1 Primitive Types
- `string` — `"dev"`, `"us-east-1"`
- `number` — `1`, `2.5`
- `bool` — `true`, `false`
- `null` — “unset” / “not specified” (useful for optional arguments)

### 6.2 Collection Types
- `list(T)` — ordered, duplicates allowed  
  Example: `["a", "b", "b"]`
- `set(T)` — unordered, duplicates removed  
  Example: `toset(["a","b","b"]) -> {"a","b"}`
- `map(T)` — string keys to values  
  Example: `{ env = "dev", owner = "team-a" }`

### 6.3 Structural Types
- `object({ name=string, port=number })`  
  Example: `{ name = "web", port = 80 }`
- `tuple([string, number, bool])`  
  Example: `["web", 80, true]`

### 6.4 Type Constraints (Why They Matter)
Type constraints:
- catch mistakes early (during plan/validate)
- document module inputs clearly
- improve reusability and maintainability

Examples:
- `type = string`
- `type = map(string)`
- `type = list(object({ name = string, size = string }))`

### 6.5 Common Type/Utility Functions
Conversions:
- `tostring()`, `tonumber()`, `tobool()`
- `tolist()`, `toset()`, `tomap()`

General-purpose:
- `length()`, `keys()`, `values()`
- `merge()`, `zipmap()`
- `lookup()`, `contains()`
- `try()`, `coalesce()`

---

## 7) Variables (Inputs)

Variables parameterize Terraform configurations and modules.

### 7.1 Variable Declaration (Common Fields)
- `type` — type constraint
- `description` — documentation for learners and module consumers
- `default` — makes variable optional
- `sensitive` — hides value from some output displays
- `validation` — custom rules to prevent bad inputs

Example patterns:
- environment selection (`dev`, `stage`, `prod`)
- resource sizing (`instance_type`, `node_count`)
- tags/labels (`map(string)`)

### 7.2 How to Set Variables
Common methods:
- CLI: `-var="environment=dev"`
- Var file: `-var-file="dev.tfvars"`
- Auto-loaded files: `terraform.tfvars`, `*.auto.tfvars`
- Environment variables: `TF_VAR_environment=dev`

### 7.3 Variable Validation
Validation adds guardrails and reduces runtime surprises:
- allowed environment names
- ranges (`min <= x <= max`)
- formatting checks (CIDR, naming rules)
- non-empty inputs

---

## 8) Locals

Locals are named expressions used to reduce repetition and improve readability.

Good uses:
- computed names/prefixes
- merged tag maps
- feature flags / environment-based settings
- normalization of input values

Locals are **not** user inputs; they’re computed inside the configuration.

---

## 9) Outputs

Outputs expose values from your Terraform configuration:
- printed after apply
- consumed by other systems (CI pipelines, scripts)
- passed up to parent modules

Tips:
- output only what consumers need
- use `sensitive = true` for secrets (but remember: state may still contain sensitive data)

Common outputs:
- IDs (VPC ID, subnet IDs, instance IDs)
- endpoints (DNS names, URLs)
- configuration values needed by downstream steps

---

## 10) Providers

Providers define how Terraform communicates with an API.

Common learning points:
- Providers have versions (pin them to avoid unexpected changes).
- Providers can be configured per region/account using **aliases** (useful for multi-account or multi-region deployments).
- Authentication is usually configured in the provider block and/or via environment variables.

---

## 11) Resources and Lifecycle

Resources represent managed infrastructure objects.

### 11.1 Resource Meta-Arguments
- `depends_on`  
  Explicit dependency (use sparingly; prefer implicit dependencies via references).
- `count` and `for_each`  
  Create multiple instances of a resource.
- `lifecycle { ... }`  
  Control replace behavior and protections:
  - `create_before_destroy`
  - `prevent_destroy`
  - `ignore_changes`

### 11.2 Dependencies
- **Implicit** dependencies happen automatically when you reference another resource’s attributes.
- **Explicit** dependencies (`depends_on`) are sometimes needed when dependencies aren’t visible via direct references.

---

## 12) Data Sources

Data sources query existing information:
- look up latest images (e.g., machine images)
- fetch existing network IDs
- reference externally created infrastructure

Data sources do not create resources; they’re read-only.

---

## 13) State (What It Is and Why It Matters)

Terraform state:
- maps Terraform config to real objects created in the provider
- stores IDs and attributes needed for change planning
- enables drift detection and accurate updates

Default: local `terraform.tfstate` in your working directory (not recommended for teams).

---

## 14) Backends (Remote State)

A backend controls:
- **where state is stored** (local or remote)
- how Terraform **loads** and **updates** that state
- whether state **locking** is supported

Common backends:
- S3 (often with DynamoDB for locking)
- AzureRM
- GCS
- Terraform Cloud
- Consul

Backend configuration is applied during:
- `terraform init`

Important: backend configuration changes typically require `terraform init -reconfigure`.

---

## 15) State Locking (Team Safety)

State locking prevents simultaneous modifications that can corrupt or conflict state.

Examples:
- Terraform Cloud: built-in locking
- S3: commonly paired with DynamoDB for locking (pattern depends on your implementation)

---

## 16) Modules (Reusability)

A module is a reusable unit of Terraform code.

### 16.1 Module Inputs and Outputs
Think of modules like functions:
- inputs (variables) → internal resources → outputs

### 16.2 Module Sources
- Local: `./modules/network`
- Git: `git::https://...//path?ref=v1.2.0`
- Registry: `hashicorp/vpc/aws`

Recommendation: **pin module versions** when consuming registry/Git modules.

### 16.3 Recommended Module Structure
- `main.tf`
- `variables.tf`
- `outputs.tf`
- `versions.tf`
- `README.md`

### 16.4 Module Best Practices
- strong typing and validation on variables
- minimal, useful outputs
- avoid “magic” defaults that surprise users
- keep modules focused and composable
- don’t hardcode provider configuration inside modules unless you understand the tradeoffs (often better to pass provider config from the root)

---

## 17) Terraform Workspaces (Environment Separation Option)

Workspaces allow multiple state instances for the same configuration.

Commands:
- `terraform workspace list`
- `terraform workspace new dev`
- `terraform workspace select prod`

Notes:
- Workspaces can be useful for simple setups.
- Many teams prefer separate directories/backends per environment for clearer isolation.

---

## 18) Terraform Commands (Day-to-Day)

This section summarizes the most-used commands and what learners should understand about each.

### 18.1 Initialization and Quality
- `terraform init`  
  Downloads providers/modules and sets up the backend.
  - Common flags: `-upgrade`, `-reconfigure`

- `terraform fmt`  
  Formats Terraform code.
  - Common flags: `-recursive`, `-check`

- `terraform validate`  
  Static validation for syntax/type errors (best after init).

### 18.2 Planning and Applying
- `terraform plan`  
  Previews changes.
  - Common flags: `-out=plan.tfplan`, `-var`, `-var-file`
  - `-refresh=false` exists but should be used carefully.

- `terraform apply`  
  Applies changes.
  - Apply a saved plan: `terraform apply plan.tfplan`
  - Common flag: `-auto-approve` (use caution / guardrails in CI)

- `terraform destroy`  
  Destroys managed infrastructure (use with caution).

### 18.3 Inspection and Debugging
- `terraform show`  
  Shows current state or a saved plan file.

- `terraform output`  
  Prints output values from state.
  - Helpful flags: `-json`

- `terraform console`  
  Interactive evaluation of Terraform expressions.

- `terraform providers`  
  Shows provider requirements and module/provider usage.

- `terraform graph`  
  Outputs a dependency graph (DOT format).

- `terraform version` / `terraform help`  
  Useful for checking version and command help.

### 18.4 Importing Existing Infrastructure
- `terraform import`  
  Brings an existing resource under Terraform control.
  - Requires a matching resource block in config.
  - After import, run `plan` to align configuration with reality.

### 18.5 State Operations (Advanced / Caution)
- `terraform state list`
- `terraform state show <addr>`
- `terraform state mv <src> <dst>`
- `terraform state rm <addr>`
- `terraform state pull` / `terraform state push`

**Important:** State operations can detach or re-address resources. Use carefully and prefer backups and peer review when working in shared environments.

---

## 19) Advanced Language Patterns (Useful Next Steps)

### 19.1 `count` vs `for_each`
- `count` creates indexed resources (`resource.x[0]`), but indexes can shift.
- `for_each` uses keys (`resource.x["key"]`), safer for collections that change.

### 19.2 Dynamic Blocks
Dynamic blocks generate nested configuration blocks from data structures—useful when the number of nested blocks depends on inputs.

### 19.3 Conditionals and Optional Values
- Conditional expressions: `condition ? a : b`
- Using `null` for optional arguments is a common pattern to “omit” a value when not needed.

---

## 20) Team Practices, CI/CD, and Safety

Recommended team approach:
- Use **remote state** + locking
- Enforce code review
- CI checks:
  - `terraform fmt -check`
  - `terraform validate`
  - `terraform plan` (often required before merge)
- Separate environments clearly (directories/backends/workspaces depending on team preference)
- Apply least-privilege access controls to credentials and state storage

---

## 21) Common Pitfalls (What Learners Should Watch For)

- Not pinning provider/module versions → unexpected breaking changes
- Editing state manually → corruption or drift risk
- Heavy use of `-target` → partial, inconsistent changes (avoid as a standard practice)
- Too many environments in one state → large blast radius
- Secrets in state → state must be protected; prefer secret managers

---

## 22) Security Considerations

- Treat state as sensitive (it may contain secrets or sensitive attributes)
- Encrypt remote state at rest
- Restrict access to state storage and locking mechanisms
- Prefer secret managers (AWS Secrets Manager, Azure Key Vault, GCP Secret Manager, Vault, etc.) over plaintext variables

---

## 23) Example End-to-End Command Flow (Lab-Friendly)

A common learner-friendly flow:

1. `terraform init`
2. `terraform fmt -recursive`
3. `terraform validate`
4. `terraform plan -var-file=dev.tfvars -out=dev.tfplan`
5. `terraform apply dev.tfplan`
6. `terraform output`
7. `terraform destroy` (for labs only)

---

## 24) Summary (What You Should Be Comfortable With)
After studying and practicing, learners should be able to:
- explain the Terraform workflow (init → plan → apply)
- use variables/locals/outputs confidently
- understand and use Terraform data types (including objects/collections)
- work with modules and versioning
- understand state, remote backends, and locking
- use essential Terraform commands safely in a team setting