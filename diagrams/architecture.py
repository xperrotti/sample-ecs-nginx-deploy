"""
Architecture diagram for the AWS ECS Fargate deployment.

Prerequisites:
  - Python 3.9+
  - pip install -r requirements.txt
  - brew install graphviz  (macOS) or apt-get install graphviz (Linux)

Usage:
  cd diagrams && python architecture.py

Output:
  architecture.png
"""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import ECS, Fargate
from diagrams.aws.compute import ECR
from diagrams.aws.database import Dynamodb
from diagrams.aws.management import Cloudwatch
from diagrams.aws.network import ALB, InternetGateway, NATGateway, Route53
from diagrams.aws.security import ACM, IAMRole
from diagrams.aws.storage import S3
from diagrams.onprem.client import Users
from diagrams.onprem.vcs import Github

with Diagram(
    "AWS ECS Fargate - nginxdemos/hello",
    filename="architecture",
    show=False,
    direction="TB",
    graph_attr={"fontsize": "14", "pad": "0.5"},
):
    users = Users("Users")
    github = Github("GitHub Actions\nCI/CD")

    # -------------------------------------------------------------------------
    # Management Account (Route53 hosted zone lives here)
    # -------------------------------------------------------------------------
    with Cluster("Management Account"):
        dns = Route53("Route53\nHosted Zone")
        oidc_role = IAMRole("GitHub OIDC\nRole")
        state_bucket = S3("Terraform\nState")
        lock_table = Dynamodb("State Lock")

    # -------------------------------------------------------------------------
    # Workload Account
    # -------------------------------------------------------------------------
    with Cluster("Workload Account"):
        workload_role = IAMRole("Workload\nIAM Role")
        ecr = ECR("ECR\nRegistry")
        logs = Cloudwatch("CloudWatch\nLogs")

        with Cluster("VPC - 10.0.0.0/16 (us-east-2)"):
            with Cluster("Public Subnets (3 AZs)"):
                alb = ALB("Application\nLoad Balancer")
                cert = ACM("ACM\nCertificate")
                igw = InternetGateway("Internet\nGateway")
                nat_gws = [
                    NATGateway("NAT GW\n2a"),
                    NATGateway("NAT GW\n2b"),
                    NATGateway("NAT GW\n2c"),
                ]

            with Cluster("Private Subnets (3 AZs)"):
                ecs_cluster = ECS("ECS Cluster")
                tasks = [
                    Fargate("Task 1\n2a"),
                    Fargate("Task 2\n2b"),
                    Fargate("Task N\n2c"),
                ]

    # -------------------------------------------------------------------------
    # Connections
    # -------------------------------------------------------------------------

    # User traffic flow
    users >> Edge(label="HTTPS") >> dns
    dns >> alb
    cert - alb
    alb >> Edge(label="port 80") >> tasks

    # ECS internals
    ecs_cluster - tasks
    ecr >> Edge(label="image pull", style="dashed") >> ecs_cluster
    tasks >> Edge(style="dashed") >> logs

    # Outbound via NAT
    for task, nat in zip(tasks, nat_gws):
        task >> Edge(style="dotted") >> nat >> igw

    # CI/CD flow
    github >> Edge(label="OIDC", style="dashed") >> oidc_role
    oidc_role >> Edge(label="assume role", style="dashed") >> workload_role
    github >> Edge(style="dashed") >> state_bucket
