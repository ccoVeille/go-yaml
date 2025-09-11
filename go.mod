// Deprecated: use go.yaml.in/yaml/v2 instead.
module github.com/yaml/go-yaml/v2

go 1.15

require gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405

// these tags come from gopkg.in/yaml.v2
// they cannot be installed from go.yaml.in/yaml/v2 as it doesn't match
// so they are invalid and are retracted.
retract [v2.0.0, v2.4.0] // v2.4.1 is the first one with go.yaml.in/yaml/v2 module.
retract v2.4.3 // only about retracts v2.0.0-v2.4.0 on go.yaml.in/yaml/v2
retract v2.4.4 // about retracting things for github.com/yaml/go-yaml, this version is broken to be able to retract