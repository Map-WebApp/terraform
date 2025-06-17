# This resource uses a local provisioner to configure Helm repositories.
# It ensures that the necessary chart repositories are added and updated
# automatically when you run 'terraform apply'.
resource "null_resource" "helm_repo_setup" {
  provisioner "local-exec" {
    # These commands are idempotent. 'helm repo add' will not fail if the repo already exists.
    command = <<EOT
      helm repo add eks https://aws.github.io/eks-charts
      helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
      helm repo add autoscaler https://kubernetes.github.io/autoscaler
      helm repo add jenkins https://charts.jenkins.io
      helm repo add argo https://argoproj.github.io/argo-helm
      helm repo update
    EOT
    # Assuming you are running on Windows with PowerShell.
    # For Linux/macOS, this interpreter line can be removed.
    interpreter = ["powershell", "-Command"]
  }
} 