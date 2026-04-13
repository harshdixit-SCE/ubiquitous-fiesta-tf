terraform {
  backend "s3" {
    # Bucket and key are provided via -backend-config per environment:
    #   terraform init -backend-config="../environments/dev/backend.hcl"
    #
    # bucket         = provided via backend.hcl
    # key            = provided via backend.hcl
    # region         = provided via backend.hcl
    encrypt  = true
    # use_lockfile = true is set per environment in backend.hcl
  }
}
