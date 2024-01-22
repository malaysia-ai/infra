resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
  }
}

resource "helm_release" "karpenter" {

    name       = "karpenter"
    chart      = "karpenter"
    repository = "oci://public.ecr.aws/karpenter"
    version    = "v0.33.1"
    namespace  = kubernetes_namespace.karpenter.id

    values     = [templatefile("${path.module}/karpenter-helm/values.yaml", {
      cluster_name     = aws_eks_cluster.deployment-3.name,
      cluster_endpoint = aws_eks_cluster.deployment-3.endpoint,
      serviceAccount_arn  = aws_iam_role.karpenter-controller-role.arn,
      nodeRole_arn  = aws_iam_role.karpenter-node-role.arn
    })]

}

resource "aws_sqs_queue" "karpenter_interruption_queue" {
  name                      = aws_eks_cluster.deployment-3.name
  message_retention_seconds = 300
  kms_master_key_id         = "alias/aws/sqs"
}

resource "aws_sqs_queue_policy" "karpenter_interruption_queue_policy" {
  queue_url = aws_sqs_queue.karpenter_interruption_queue.id

  policy = jsonencode({
    "Version": "2008-10-17",
    "Id": "EC2InterruptionPolicy",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": ["events.amazonaws.com", "sqs.amazonaws.com"]
        },
        "Action": "sqs:SendMessage",
        "Resource": "${aws_sqs_queue.karpenter_interruption_queue.arn}"
      }
    ]
  })
}


resource "aws_cloudwatch_event_rule" "scheduled_change_rule" {
  name        = "ScheduledChangeRule"
  event_pattern = jsonencode({
    "source": ["aws.health"],
    "detail-type": ["AWS Health Event"]
  })
}

resource "aws_cloudwatch_event_target" "scheduled_change_target" {
  rule      = aws_cloudwatch_event_rule.scheduled_change_rule.name
  arn       = aws_sqs_queue.karpenter_interruption_queue.arn
}

resource "aws_cloudwatch_event_rule" "spot_interruption_rule" {
  name        = "SpotInterruptionRule"
  event_pattern = jsonencode({
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Spot Instance Interruption Warning"]
  })
}

resource "aws_cloudwatch_event_target" "spot_interruption_target" {
  rule      = aws_cloudwatch_event_rule.spot_interruption_rule.name
  arn       = aws_sqs_queue.karpenter_interruption_queue.arn
}

resource "aws_cloudwatch_event_rule" "rebalance_rule" {
  name        = "RebalanceRule"
  event_pattern = jsonencode({
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Instance Rebalance Recommendation"]
  })
}

resource "aws_cloudwatch_event_target" "rebalance_target" {
  rule      = aws_cloudwatch_event_rule.rebalance_rule.name
  arn       = aws_sqs_queue.karpenter_interruption_queue.arn
}

resource "aws_cloudwatch_event_rule" "instance_state_change_rule" {
  name        = "InstanceStateChangeRule"
  event_pattern = jsonencode({
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Instance State-change Notification"]
  })
}

resource "aws_cloudwatch_event_target" "instance_state_change_target" {
  rule      = aws_cloudwatch_event_rule.instance_state_change_rule.name
  arn       = aws_sqs_queue.karpenter_interruption_queue.arn
}

resource "aws_iam_role" "karpenter-node-role" {
  name = "KarpenterNodeRole-${aws_eks_cluster.deployment-3.name}"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "pods.eks.amazonaws.com"
        },
        "Action": [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "sts:AssumeRoleWithWebIdentity",
          "sts:TagSession"
        ],
        "Principal": {
          "Federated": "${aws_iam_openid_connect_provider.deployment-3.arn}"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}
resource "aws_eks_pod_identity_association" "karpenter" {
  depends_on = [aws_eks_addon.eks-pod-identity-agent-addons]
  cluster_name    = aws_eks_cluster.deployment-3.name
  namespace       = "karpenter"
  service_account = "karpenter"
  role_arn        = aws_iam_role.karpenter-controller-role.arn
}
resource "aws_iam_role" "karpenter-controller-role" {
  name = "KarpenterControllerRole-${aws_eks_cluster.deployment-3.name}"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "pods.eks.amazonaws.com"
        },
        "Action": [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "sts:AssumeRoleWithWebIdentity",
          "sts:TagSession"
        ],
        "Principal": {
          "Federated": "${aws_iam_openid_connect_provider.deployment-3.arn}"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "karpenter" {
  name = "KarpenterControllerPolicy-${aws_eks_cluster.deployment-3.name}"
  role = aws_iam_role.karpenter-controller-role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowScopedEC2InstanceActions",
        "Effect": "Allow",
        "Resource": [
          "arn:aws:ec2:us-west-2::image/*",
          "arn:aws:ec2:us-west-2::snapshot/*",
          "arn:aws:ec2:us-west-2:*:security-group/*",
          "arn:aws:ec2:us-west-2:*:subnet/*",
          "arn:aws:ec2:us-west-2:*:launch-template/*"
        ],
        "Action": [
          "ec2:RunInstances",
          "ec2:CreateFleet"
        ]
      },
      {
        "Sid": "AllowScopedEC2InstanceActionsWithTags",
        "Effect": "Allow",
        "Resource": [
          "arn:aws:ec2:us-west-2:*:fleet/*",
          "arn:aws:ec2:us-west-2:*:instance/*",
          "arn:aws:ec2:us-west-2:*:volume/*",
          "arn:aws:ec2:us-west-2:*:network-interface/*",
          "arn:aws:ec2:us-west-2:*:launch-template/*",
          "arn:aws:ec2:us-west-2:*:spot-instances-request/*"
        ],
        "Action": [
          "ec2:RunInstances",
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate"
        ],
        "Condition": {
          "StringEquals": {
            "aws:RequestTag/kubernetes.io/cluster/${aws_eks_cluster.deployment-3.name}": "owned"
          },
          "StringLike": {
            "aws:RequestTag/karpenter.sh/nodepool": "*"
          }
        }
      },
      {
        "Sid": "AllowScopedResourceCreationTagging",
        "Effect": "Allow",
        "Resource": [
          "arn:aws:ec2:us-west-2:*:fleet/*",
          "arn:aws:ec2:us-west-2:*:instance/*",
          "arn:aws:ec2:us-west-2:*:volume/*",
          "arn:aws:ec2:us-west-2:*:network-interface/*",
          "arn:aws:ec2:us-west-2:*:launch-template/*",
          "arn:aws:ec2:us-west-2:*:spot-instances-request/*"
        ],
        "Action": "ec2:CreateTags",
        "Condition": {
          "StringEquals": {
            "aws:RequestTag/kubernetes.io/cluster/${aws_eks_cluster.deployment-3.name}": "owned",
            "ec2:CreateAction": [
              "RunInstances",
              "CreateFleet",
              "CreateLaunchTemplate"
            ]
          },
          "StringLike": {
            "aws:RequestTag/karpenter.sh/nodepool": "*"
          }
        }
      },
      {
        "Sid": "AllowScopedResourceTagging",
        "Effect": "Allow",
        "Resource": "arn:aws:ec2:us-west-2:*:instance/*",
        "Action": "ec2:CreateTags",
        "Condition": {
          "StringEquals": {
            "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.deployment-3.name}": "owned"
          },
          "StringLike": {
            "aws:ResourceTag/karpenter.sh/nodepool": "*"
          },
          "ForAllValues:StringEquals": {
            "aws:TagKeys": [
              "karpenter.sh/nodeclaim",
              "Name"
            ]
          }
        }
      },
      {
        "Sid": "AllowScopedDeletion",
        "Effect": "Allow",
        "Resource": [
          "arn:aws:ec2:us-west-2:*:instance/*",
          "arn:aws:ec2:us-west-2:*:launch-template/*"
        ],
        "Action": [
          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate"
        ],
        "Condition": {
          "StringEquals": {
            "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.deployment-3.name}": "owned"
          },
          "StringLike": {
            "aws:ResourceTag/karpenter.sh/nodepool": "*"
          }
        }
      },
      {
        "Sid": "AllowRegionalReadActions",
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSubnets"
        ],
        "Condition": {
          "StringEquals": {
            "aws:RequestedRegion": "us-west-2"
          }
        }
      },
      {
        "Sid": "AllowSSMReadActions",
        "Effect": "Allow",
        "Resource": "arn:aws:ssm:us-west-2::parameter/aws/service/*",
        "Action": "ssm:GetParameter"
      },
      {
        "Sid": "AllowPricingReadActions",
        "Effect": "Allow",
        "Resource": "*",
        "Action": "pricing:GetProducts"
      },
      {
        "Sid": "AllowInterruptionQueueActions",
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage"
        ]
      },
      {
        "Sid": "AllowPassingInstanceRole",
        "Effect": "Allow",
        "Resource": "arn:aws:iam::896280034829:role/KarpenterNodeRole-${aws_eks_cluster.deployment-3.name}",
        "Action": "iam:PassRole",
        "Condition": {
          "StringEquals": {
            "iam:PassedToService": "ec2.amazonaws.com"
          }
        }
      },
      {
        "Sid": "AllowScopedInstanceProfileCreationActions",
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
          "iam:CreateInstanceProfile"
        ],
        "Condition": {
          "StringEquals": {
            "aws:RequestTag/kubernetes.io/cluster/${aws_eks_cluster.deployment-3.name}": "owned",
            "aws:RequestTag/topology.kubernetes.io/region": "us-west-2"
          },
          "StringLike": {
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
          }
        }
      },
      {
        "Sid": "AllowScopedInstanceProfileTagActions",
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
          "iam:TagInstanceProfile"
        ],
        "Condition": {
          "StringEquals": {
            "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.deployment-3.name}": "owned",
            "aws:ResourceTag/topology.kubernetes.io/region": "us-west-2",
            "aws:RequestTag/kubernetes.io/cluster/${aws_eks_cluster.deployment-3.name}": "owned",
            "aws:RequestTag/topology.kubernetes.io/region": "us-west-2"
          },
          "StringLike": {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*",
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
          }
        }
      },
      {
        "Sid": "AllowScopedInstanceProfileActions",
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile"
        ],
        "Condition": {
          "StringEquals": {
            "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.deployment-3.name}": "owned",
            "aws:ResourceTag/topology.kubernetes.io/region": "us-west-2"
          },
          "StringLike": {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*"
          }
        }
      },
      {
        "Sid": "AllowInstanceProfileReadActions",
        "Effect": "Allow",
        "Resource": "*",
        "Action": "iam:GetInstanceProfile"
      },
      {
        "Sid": "AllowAPIServerEndpointDiscovery",
        "Effect": "Allow",
        "Resource": "arn:aws:eks:us-west-2:896280034829:cluster/${aws_eks_cluster.deployment-3.name}",
        "Action": "eks:DescribeCluster"
      },
      {
        "Action": [
          "iam:PassRole"
        ],
        "Effect": "Allow",
        "Resource": "${aws_iam_role.nodegroup.arn}"
      }
    ]
  })
}
