# Checkov exceptions

Every finding not listed here fails the pipeline. Each exception is a conscious trade-off for a single-region dev environment, with the production setting noted.

| Check | Why it is skipped | Production setting |
|---|---|---|
| `CKV_AZURE_4` AKS logging | Container Insights is enabled through `oms_agent`; the check looks for the legacy add-on block. | already covered |
| `CKV_AZURE_117` AKS disk encryption set | OS disks are ephemeral and host encryption is on; customer-managed keys are optional for dev. | set `disk_encryption_set_id` if CMK is required |
| `CKV_AZURE_170` AKS paid SKU | dev uses the Free tier to save cost; the module default is `Standard`. | `aks_sku_tier = "Standard"` |
| `CKV_AZURE_233` ACR zone redundancy | enabled automatically when `environment = "prod"`. | automatic |
| `CKV_AZURE_165` ACR geo-replication | single-region deployment; geo-replication only helps multi-region clusters. | add `georeplications` blocks per region |
| `CKV_AZURE_164` ACR content trust | Docker Content Trust is deprecated in favour of Notation signing, which is done in the pipeline, not on the registry. | sign images with Notation |
| `CKV_AZURE_166` ACR quarantine | quarantine needs an extra service to mark images as verified; the pipeline already blocks images with HIGH/CRITICAL CVEs before push. | enable with Defender for Containers |
| `CKV2_AZURE_31` subnet NSG | false positive: NSGs are attached with a separate `for_each` association resource that Checkov's graph does not follow. The AKS node subnet uses the NSG that AKS manages. | already covered |

## Fixed rather than skipped

- `CKV_AZURE_116` Azure Policy add-on: `azure_policy_enabled = true`
- `CKV_AZURE_168` at least 50 pods per node: `max_pods = 110`
- `CKV_AZURE_227` host encryption: `host_encryption_enabled = true` (register the `Microsoft.Compute/EncryptionAtHost` feature once per subscription)
- `CKV_AZURE_237` dedicated data endpoints: `data_endpoint_enabled = true`
