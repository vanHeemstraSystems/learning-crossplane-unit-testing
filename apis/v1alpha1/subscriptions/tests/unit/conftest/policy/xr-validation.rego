package xr_validation

# Test that XR has required metadata labels
deny[msg] {
    not input.metadata.labels.environment
    msg = "XR must have 'environment' label"
}

deny[msg] {
    not input.metadata.labels["managed-by"]
    msg = "XR must have 'managed-by' label"
}

# Test that environment label matches spec
deny[msg] {
    input.metadata.labels.environment != input.spec.parameters.environment
    msg = "Environment label must match spec.parameters.environment"
}

# Test that required parameters are provided
deny[msg] {
    not input.spec.parameters.subscriptionName
    msg = "XR must specify subscriptionName"
}

deny[msg] {
    not input.spec.parameters.billingAccountId
    msg = "XR must specify billingAccountId"
}

# Test that workload matches environment
deny[msg] {
    input.spec.parameters.environment == "prod"
    input.spec.parameters.workload != "Production"
    msg = "Production environment must use 'Production' workload"
}

# Test that tags include required fields
deny[msg] {
    not input.spec.parameters.tags["cost-center"]
    msg = "XR must include 'cost-center' tag"
}

deny[msg] {
    not input.spec.parameters.tags.project
    msg = "XR must include 'project' tag"
}

deny[msg] {
    not input.spec.parameters.tags.owner
    msg = "XR must include 'owner' tag"
}

# Test naming conventions
deny[msg] {
    not startswith(input.spec.parameters.subscriptionName, "atlas-")
    msg = "Subscription name must start with 'atlas-'"
}

deny[msg] {
    not startswith(input.spec.parameters.defaultResourceGroup.name, "rg-atlas-")
    msg = "Resource group name must start with 'rg-atlas-'"
}

# Test location is valid Azure region
deny[msg] {
    location := input.spec.parameters.defaultResourceGroup.location
    not valid_azure_region(location)
    msg = sprintf("Invalid Azure region: '%s'", [location])
}

valid_azure_region(location) {
    valid_regions := {
        "westeurope", "northeurope", "eastus", "westus", 
        "centralus", "southeastasia", "japaneast"
    }
    valid_regions[location]
}
