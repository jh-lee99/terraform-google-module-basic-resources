# short-lived access token 토큰을 생성할 공급자 
# provider "google" {
#   alias = "impersonation"
#   scopes = [
#     "https://www.googleapis.com/auth/cloud-platform",
#     "https://www.googleapis.com/auth/userinfo.email",
#   ]
# }

# 토큰 생성 
# data "google_service_account_access_token" "default" {
#   provider               = google.impersonation
#   target_service_account = var.service_account_email
#   scopes                 = ["cloud-platform", "userinfo-email"]
#   lifetime               = "3600s"
# }

# 토큰을 사용할 default provider
# provider "google" {
#   project      = var.project_id
#   region       = var.region
#   access_token = data.google_service_account_access_token.default.access_token
# }
