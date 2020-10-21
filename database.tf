resource "mysql_database" "database" {
  name = var.database_name
}

resource "random_string" "name" {
  length  = 5
  special = false
}

resource "random_string" "project_rw" {
  length  = 20
  special = true
}

locals{
    rw_users = { for i in var.database_rw_users : i => i }
    ro_users = { for i in var.database_ro_users : i => i }
}

resource "random_string" "rw_pass" {
  for_each = local.rw_users
  length   = 20
  special  = true
}

resource "random_string" "ro_pass" {
  for_each = local.ro_users
  length   = 20
  special  = true
}

resource "mysql_user" "project_rw" {
  user = "${length(var.project_name) > 13 ? format(
    "%s_%s",
    substr(var.project_name, 0, min(7, length(var.project_name))),
    random_string.name.result,
  ) : var.project_name}_rw"
  host               = "%"
  plaintext_password = random_string.project_rw.result
}

resource "mysql_user" "rw_users" {
  for_each           = local.rw_users
  user               = "${each.key}_rw"
  host               = "%"
  plaintext_password = random_string.rw_pass[each.key].result
}

resource "mysql_user" "ro_users" {
  for_each           = local.ro_users
  user               = "${each.key}_ro"
  host               = "%"
  plaintext_password = random_string.ro_pass[each.key].result
}

resource "mysql_grant" "grant" {
  user       = mysql_user.project_rw.user
  host       = mysql_user.project_rw.host
  database   = mysql_database.database.name
  privileges = ["ALL"]
}

resource "mysql_grant" "grant_ro" {
  for_each   = local.ro_users
  user       = "${each.key}_ro"
  host       = "%"
  database   = mysql_database.database.name
  privileges = ["SELECT"]
}

resource "mysql_grant" "grant_rw" {
  for_each   = local.rw_users
  user       = "${each.key}_rw"
  host       = "%"
  database   = mysql_database.database.name
  privileges = ["SELECT,UPDATE"]
}

