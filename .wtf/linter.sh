#!/bin/bash

set -e

terraform fmt -recursive
terragrunt hclfmt
