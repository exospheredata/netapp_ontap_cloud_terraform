
# Example Terraform Templates for ONTAP Cloud and OnCommand Cloud Manager solutions
### _Provides examples for deploying NetApp solutions via Terraform and using [CHEF cookbook for NetApp ONTAP Cloud](https://github.com/exospheredata/netapp_ontap_cloud) as provided by Exosphere Data, LLC_

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Templates](#templates)
  - [aws_standalone](#aws_standalone)
- [Contribute](#contribute)
- [License & Authors](#license-&-authors)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Templates

### aws_standalone
This template will deploy a single NetApp OnCommand Cloud Manager (OCCM) server into the designated AWS subnet.  As part of this process, a new IAM EC2 Role will be created to provide the OCCM server with the correct credentials and access policy.  Upon deploymentment, the OCCM server will create a new ONTAP Cloud for AWS system based on the sizing and design choices in the Terraform variables.

## Contribute
 - Fork it
 - Create your feature branch (git checkout -b my-new-feature)
 - Commit your changes (git commit -am 'Add some feature')
 - Push to the branch (git push origin my-new-feature)
 - Create new Pull Request

## License & Authors

**Author:** Jeremy Goodrum ([jeremy@exospheredata.com](mailto:jeremy@exospheredata.com))

**Copyright:** 2017 Exosphere Data, LLC

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
