package xrd_validation

test_xrd_missing_name {
    deny["XRD must have a name"] with input as {"metadata": {}}
}

test_xrd_wrong_group {
    deny[msg] with input as {
        "metadata": {"name": "test"},
        "spec": {"group": "wrong.group"}
    }
    contains(msg, "XRD group must be")
}

test_xrd_valid_environments {
    not deny[_] with input as {
        "metadata": {"name": "test"},
        "spec": {
            "group": "atlas.teamrockstars.cloud",
            "versions": [{
                "schema": {
                    "openAPIV3Schema": {
                        "properties": {
                            "spec": {
                                "properties": {
                                    "parameters": {
                                        "properties": {
                                            "environment": {
                                                "enum": ["dev", "staging", "prod"]
                                            },
                                            "workload": {
                                                "enum": ["Production", "DevTest"]
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }]
        }
    }
}
