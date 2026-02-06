package xrd_validation

# Test that XRD has required metadata
deny[msg] {
    not input.metadata.name
    msg = "XRD must have a name"
}

# Test that XRD belongs to correct group
deny[msg] {
    input.spec.group != "example.io"
    msg = sprintf("XRD group must be 'example.io', got '%s'", [input.spec.group])
}

# Test that required parameters are defined
deny[msg] {
    not input.spec.versions[_].schema.openAPIV3Schema.properties.spec.properties.parameters
    msg = "XRD must define parameters in spec"
}

# Test that environment enum contains valid values
deny[msg] {
    environments := input.spec.versions[_].schema.openAPIV3Schema.properties.spec.properties.parameters.properties.environment.enum
    not valid_environments(environments)
    msg = "Environment enum must contain: dev, staging, prod"
}

valid_environments(environments) {
    required := {"dev", "staging", "prod"}
    provided := {e | e := environments[_]}
    required == provided
}

# Test that workload enum is correct
deny[msg] {
    workloads := input.spec.versions[_].schema.openAPIV3Schema.properties.spec.properties.parameters.properties.workload.enum
    not valid_workloads(workloads)
    msg = "Workload enum must contain: Production, DevTest"
}

valid_workloads(workloads) {
    required := {"Production", "DevTest"}
    provided := {w | w := workloads[_]}
    required == provided
}
