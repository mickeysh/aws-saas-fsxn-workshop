
resource "aws_iam_policy" "fsxn-csi-policy" {
  name        = "AmazonFSXNCSIDriverPolicy_${random_string.suffix.result}"
  description = "FSxN CSI Driver Policy"


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "fsx:DescribeFileSystems",
          "fsx:DescribeVolumes",
          "fsx:CreateVolume",
          "fsx:RestoreVolumeFromSnapshot",
          "fsx:DescribeStorageVirtualMachines",
          "fsx:UntagResource",
          "fsx:UpdateVolume",
          "fsx:TagResource",
          "fsx:DeleteVolume"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "secretsmanager:GetSecretValue",
        "Resource" : "${aws_secretsmanager_secret.fsxn_password_secret.arn}"
      }
    ]
  })
}


locals {
  k8s_service_account_namespace = "trident"
  k8s_service_account_name      = "trident-controller"
}

resource "aws_secretsmanager_secret" "fsxn_password_secret" {
  name        = local.secret_name
  description = "FSxN CSI Driver Password"
}

resource "aws_secretsmanager_secret_version" "fsxn_password_secret" {
  secret_id = aws_secretsmanager_secret.fsxn_password_secret.id
  secret_string = jsonencode({
    username = "vsadmin"
    password = "${random_string.fsx_password.result}"
  })
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "fsxn-csi-role" {
  name               = "AmazonEKS_FSXN_CSI_DriverRole_${random_string.suffix.result}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "fsxn-csi-policy-attachment" {
  policy_arn = aws_iam_policy.fsxn-csi-policy.arn
  role       = aws_iam_role.fsxn-csi-role.name
}

resource "aws_eks_pod_identity_association" "fsxn-csi-pod-identity-association1" {
  cluster_name    = module.eks.cluster_name
  namespace       = local.k8s_service_account_namespace
  service_account = local.k8s_service_account_name
  role_arn        = aws_iam_role.fsxn-csi-role.arn
}

resource "aws_eks_pod_identity_association" "fsxn-csi-pod-identity-association2" {
  cluster_name    = module.eks2.cluster_name
  namespace       = local.k8s_service_account_namespace
  service_account = local.k8s_service_account_name
  role_arn        = aws_iam_role.fsxn-csi-role.arn
}
