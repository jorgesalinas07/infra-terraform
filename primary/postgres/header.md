
# PostgreSQL Management for `ioet-primary`

## Common Tasks

### Creating a new user (or role)

1. Create a new SOPS file in `secrets/<workspace>/` -- this new SOPS file should contain a username and password key.
2. Reference the new SOPS file in `secrets/<workspace>/index.csv` as a new record. See CSV schemas below for more details on the available fields.
3. `terraform workspace select <workspace> && terraform apply` to create the new secret (there should be no other changes in the plan, otherwise please request help)
4. Add a new record to `config/<workspace>/roles.csv` for your new user, using the ARN from the `terraform output`s for your newly created secret. See CSV schemas below for more details on the available fields.
5. `terraform workspace select <workspace> && terraform apply` to create the new user (there should be no other changes in the plan, otherwise please request help)

**If you need a new database role instead of a new database user, you can leave the secret arn field blank and create the new role without the ability to login for permissions inherritence. As such, steps 1, 2 and 3 can be skipped for creating new database roles.**

### Creating a new database

1. Add a new record to `config/<workspace>/databases.csv` for your new database.
2. `terraform workspace select <workspace> && terraform apply` to create the new database (there should be no other changes in the plan, otherwise please request help)

### Creating a new database schema

1. Add a new record to `config/<workspace>/schemas.csv` for your new database schema.
2. `terraform workspace select <workspace> && terraform apply` to create the new database schema (there should be no other changes in the plan, otherwise please request help)

## How this works

Each workspace contains:
- a single RDS/PostgreSQL instance
- one or more Secrets Manager
    - these are created from `secrets/<workspace>/index.csv` and the SOPS files in `secrets/<workspace>/`
- within that RDS instance the following resources are created:
    - `admindb` / a root user managed by RDS itself -- these are only to be used for database management
    - one or more database users/roles managed via `config/<workspace>/roles.csv`
    - one or more databases managed via `config/<workspace>/databases.csv`
    - one or more database schemas managed via `config/<workspace>/schemas.csv`

## Terraform Workspaces

| Workspace | Contained Environments | Description                                        |
|-----------|------------------------|----------------------------------------------------|
| `nonprod` | `qa`, `stage`          | Contains databases for non-production environments |
| `prod`    | `prod`                 | Contains databases for production environments     |
