locals {
  hw_todo_service_name = "hw-todo-service"
  tags = {
    CreatedBy : "Terraform"
    App : var.application_name
    Company : var.company_name
    Workspace : terraform.workspace
    OU : var.department_name
    Owner : var.owner_name
  }
}