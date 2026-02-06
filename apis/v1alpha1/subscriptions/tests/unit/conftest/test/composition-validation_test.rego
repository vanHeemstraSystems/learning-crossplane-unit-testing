package composition_validation

test_composition_wrong_kind {
    deny[msg] with input as {
        "spec": {
            "compositeTypeRef": {
                "kind": "WrongKind"
            }
        }
    }
    contains(msg, "Composition must reference XAzureSubscription")
}

test_composition_not_pipeline_mode {
    deny["Composition should use Pipeline mode for Crossplane v2"] with input as {
        "spec": {
            "compositeTypeRef": {"kind": "XAzureSubscription"},
            "mode": "Resources"
        }
    }
}

test_composition_missing_subscription {
    deny["Composition must include a Subscription resource"] with input as {
        "spec": {
            "compositeTypeRef": {"kind": "XAzureSubscription"},
            "mode": "Pipeline",
            "pipeline": [{
                "input": {
                    "resources": [{
                        "base": {"kind": "ResourceGroup"}
                    }]
                }
            }]
        }
    }
}

test_composition_valid {
    not deny[_] with input as {
        "spec": {
            "compositeTypeRef": {"kind": "XAzureSubscription"},
            "mode": "Pipeline",
            "pipeline": [{
                "input": {
                    "resources": [
                        {
                            "name": "subscription",
                            "base": {"kind": "Subscription"},
                            "patches": [
                                {"fromFieldPath": "spec.parameters.billingAccountId"},
                                {"fromFieldPath": "spec.parameters.subscriptionName"},
                                {"fromFieldPath": "spec.parameters.workload"},
                                {"fromFieldPath": "spec.parameters.tags"}
                            ]
                        },
                        {
                            "base": {"kind": "ResourceGroup"}
                        }
                    ]
                }
            }]
        }
    }
}
