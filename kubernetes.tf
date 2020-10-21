resource "kubernetes_namespace" "namespace" {
  metadata {
    annotations = {
      name = replace(var.project_name, "_", "-")
    }

    name = replace(var.project_name, "_", "-")
  }
}

resource "kubernetes_secret" "pull_secret" {
  metadata {
    name      = "dockerhub-secret"
    namespace = kubernetes_namespace.namespace.id
  }

  data = {
    ".dockercfg" = file("${path.module}/docker-config.json")
  }

  type = "kubernetes.io/dockercfg"
}

resource "kubernetes_secret" "project_secret" {
  metadata {
    name      = "secrets"
    namespace = kubernetes_namespace.namespace.id
  }

  data = merge(
    {
      "database_name"      = mysql_database.database.name
      "database_user"      = mysql_user.project_rw.user
      "database_password"  = random_string.project_rw.result
      "database_host"      = var.database_endpoint_host
      "database_port"      = var.database_endpoint_port
      "database_dsn"       = "pdo_mysql://${mysql_user.project_rw.user}:${random_string.project_rw.result}@${var.database_endpoint_host}:${var.database_endpoint_port}/${mysql_database.database.name}"
      "bucket_name"        = var.bucket_name
      "bucket_arn"         = var.bucket_arn
      "secret_bucket_arn"  = var.secret_bucket_arn
      "secret_bucket_name" = var.secret_bucket_name
      "bucket_account_id"  = aws_iam_access_key.project_rw.id
      "bucket_secret_key"  = aws_iam_access_key.project_rw.secret
      "bucket_public_url"  = "https://${var.bucket_name}.s3.amazonaws.com/${var.project_name}"
      "bucket_region"      = var.bucket_region
      "bucket_path"        = var.project_name
      "session_host"       = var.session_endpoint_host
      "session_port"       = var.session_endpoint_port
      "session_dsn"        = "redis://${var.session_endpoint_host}:${var.session_endpoint_port}"
      "project_name"       = var.project_name
    },
    var.extra_secrets,
  )

  type = "Opaque"
}

data "template_file" "values" {
  template = file("${path.module}/helm-values.tpl")

  vars = {
    "bucket_public_url" = "https://${var.bucket_name}.s3.amazonaws.com/${var.project_name}"
    "bucket_region"     = var.bucket_region
    "bucket_path"       = var.project_name
    "project_name"      = var.project_name
  }
}

resource "local_file" "secrets" {
  content  = data.template_file.values.rendered
  filename = "${path.cwd}/${replace(var.project_name, "_", "-")}-values.yaml"
}

resource "local_file" "launcher" {
  content  = "#!/bin/sh\nexec helm upgrade ${replace(var.project_name, "_", "-")} ./application --install --namespace ${kubernetes_namespace.namespace.id} --values ${replace(var.project_name, "_", "-")}-values.yaml --values ${replace(var.project_name, "_", "-")}-config.yaml $@\n"
  filename = "${path.cwd}/deploy-${replace(var.project_name, "_", "-")}"
}

resource "kubernetes_secret" "tls_secret" {
  count = var.ingress_certificate_body == "" ? 0 : 1

  metadata {
    name      = "tls"
    namespace = kubernetes_namespace.namespace.id
  }

  data = {
    "tls.crt" = var.ingress_certificate_body
    "tls.key" = var.ingress_certificate_key
  }
}

