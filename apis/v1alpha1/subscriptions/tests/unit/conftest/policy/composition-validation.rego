package composition_validation

# Test that Composition references correct XRD
deny[msg] {
    input.spec.compositeTypeRef.kind != "XAzureSubscription"
    msg = sprintf("Composition must reference XAzureSubscription, got '%s'", [input.spec.compositeTypeRef.kind])
}

# Test that pipeline mode is used (Crossplane v2 best practice)
deny[msg] {
    input.spec.mode != "Pipeline"
    msg = "Composition should use Pipeline mode for Crossplane v2"
}

# Test that subscription resource exists in composition
deny[msg] {
    not has_subscription_resource
    msg = "Composition must include a Subscription resource"
}

has_subscription_resource {
    input.spec.pipeline[_].input.resources[_].base.kind == "Subscription"
}

# Test that resource group is created
deny[msg] {
    not has_resource_group
    msg = "Composition must include a ResourceGroup resource"
}

has_resource_group {
    input.spec.pipeline[_].input.resources[_].base.kind == "ResourceGroup"
}

# Test that required patches are present for subscription
deny[msg] {
    resource := input.spec.pipeline[_].input.resources[_]
    resource.name == "subscription"
    not has_required_subscription_patches(resource)
    msg = "Subscription resource must patch: billingAccountId, subscriptionName, workload, tags"
}

has_required_subscription_patches(resource) {
    patches := {p.fromFieldPath | p := resource.patches[_]}
    required := {
        "spec.parameters.billingAccountId",
        "spec.parameters.subscriptionName",
        "spec.parameters.workload",
        "spec.parameters.tags"
    }
    count(patches & required) == count(required)
}
