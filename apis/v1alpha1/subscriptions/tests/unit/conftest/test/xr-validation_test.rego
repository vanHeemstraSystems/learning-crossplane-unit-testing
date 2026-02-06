package xr_validation

test_xr_missing_environment_label {
    deny["XR must have 'environment' label"] with input as {
        "metadata": {"labels": {"managed-by": "crossplane"}}
    }
}

test_xr_missing_managed_by_label {
    deny["XR must have 'managed-by' label"] with input as {
        "metadata": {"labels": {"environment": "dev"}}
    }
}

test_xr_environment_mismatch {
    deny["Environment label must match spec.parameters.environment"] with input as {
        "metadata": {"labels": {"environment": "staging", "managed-by": "crossplane"}},
        "spec": {"parameters": {"environment": "dev"}}
    }
}

test_xr_missing_cost_center_tag {
    deny["XR must include 'cost-center' tag"] with input as {
        "metadata": {"labels": {"environment": "dev", "managed-by": "crossplane"}},
        "spec": {
            "parameters": {
                "subscriptionName": "atlas-test",
                "billingAccountId": "test",
                "environment": "dev",
                "workload": "DevTest",
                "tags": {"project": "test", "owner": "test"},
                "defaultResourceGroup": {"name": "rg-atlas-test", "location": "westeurope"}
            }
        }
    }
}

test_xr_invalid_subscription_name {
    deny["Subscription name must start with 'atlas-'"] with input as {
        "metadata": {"labels": {"environment": "dev", "managed-by": "crossplane"}},
        "spec": {
            "parameters": {
                "subscriptionName": "wrong-name",
                "billingAccountId": "test",
                "environment": "dev",
                "workload": "DevTest",
                "tags": {"cost-center": "test", "project": "test", "owner": "test"},
                "defaultResourceGroup": {"name": "rg-atlas-test", "location": "westeurope"}
            }
        }
    }
}

test_xr_prod_wrong_workload {
    deny["Production environment must use 'Production' workload"] with input as {
        "metadata": {"labels": {"environment": "prod", "managed-by": "crossplane"}},
        "spec": {
            "parameters": {
                "subscriptionName": "atlas-prod",
                "billingAccountId": "test",
                "environment": "prod",
                "workload": "DevTest",
                "tags": {"cost-center": "test", "project": "test", "owner": "test"},
                "defaultResourceGroup": {"name": "rg-atlas-prod", "location": "westeurope"}
            }
        }
    }
}

test_xr_valid {
    not deny[_] with input as {
        "metadata": {"labels": {"environment": "dev", "managed-by": "crossplane"}},
        "spec": {
            "parameters": {
                "subscriptionName": "atlas-dev",
                "billingAccountId": "/providers/Microsoft.Billing/billingAccounts/12345",
                "environment": "dev",
                "workload": "DevTest",
                "tags": {
                    "cost-center": "engineering",
                    "project": "atlas-idp",
                    "owner": "willem.vanheemstra"
                },
                "defaultResourceGroup": {
                    "name": "rg-atlas-dev-weu",
                    "location": "westeurope"
                }
            }
        }
    }
}
