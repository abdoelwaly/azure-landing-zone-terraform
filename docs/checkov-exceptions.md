# Checkov exceptions

| Check | Why it is skipped |
|---|---|
| `CKV_AZURE_4` (AKS logging) | Container Insights is enabled through `oms_agent`; the check looks for the legacy add-on block. |
| `CKV_AZURE_117` (AKS disk encryption set) | Customer-managed keys for OS disks are optional for dev; enable `disk_encryption_set_id` for production. |

Every other finding fails the pipeline.
