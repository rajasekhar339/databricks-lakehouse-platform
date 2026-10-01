# One-time setup

Do these steps before the pipelines can run.

0. **Branches.** Create `develop` and `uat` from `main`. Protect all three branches: changes only through PRs, with CI required to pass.

1. **Terraform state.** Create the storage account `stlakehousetfstate001` in `rg-lakehouse-tfstate`, with containers `tfstate-dev`, `tfstate-uat` and `tfstate-prod`.

2. **Service principal per environment.** For each environment:
   - Add a federated credential for GitHub with subject `repo:<org>/<repo>:environment:<env>`.
   - Give it `Contributor` and `User Access Administrator` on the subscription.
   - Give it `Storage Blob Data Contributor` on its state container.
   - Add it to the Databricks account as an account admin. This is needed for the metastore assignment.

3. **GitHub environments.**
   - Create `dev`, `uat` and `prod`. In each, set the variables `AZURE_CLIENT_ID`, `AZURE_TENANT_ID` and `AZURE_SUBSCRIPTION_ID`.
   - Limit each one to its own branch: `dev` to `develop`, `uat` to `uat`, `prod` to `main`.
   - Create `dev-plan`, `uat-plan` and `prod-plan` with the same variables as their matching environment and no branch limit. PR checks use these to run `terraform plan` and `bundle validate`.
   - Add a federated credential for `environment:<env>-plan` on each service principal. Ideally, point it at a read-only service principal instead.
   - Optional: add required reviewers on `prod` for an extra approval step after the merge to `main`.

4. **Placeholders.** Replace the placeholder IDs in `infra/terraform/environments/*` and in `databricks.yml`.

5. **First deploy.** After the first apply, copy each workspace URL into `databricks.yml`.

6. **Secrets.** Add the secrets to each Key Vault:

   ```bash
   az keyvault secret set --vault-name <kv> --name crm-jdbc-password --value "..."
   ```

   Also add `crm-jdbc-url` and `crm-jdbc-user` the same way.

7. **Test data.** Put some test files in `/Volumes/uat_lakehouse/bronze/landing/orders/`, so the uat run has data to process.
