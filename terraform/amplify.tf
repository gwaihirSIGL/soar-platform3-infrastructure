resource "aws_amplify_app" "front_app" {
  name         = "front"
  repository   = "https://github.com/gwaihirSIGL/soar-platform-3-front"
  access_token = yamldecode(file("env.yml"))["GITHUB_PAT"]

  enable_auto_branch_creation = true
  enable_branch_auto_deletion = true
  auto_branch_creation_config {
    enable_auto_build = true
  }
  auto_branch_creation_patterns = [
    "*",
    "*/**",
  ]
  platform = "WEB"

  build_spec = <<EOF
    version: 1
    applications:
      - frontend:
          phases:
            build:
              commands: []
          artifacts:
            baseDirectory: /
            files:
              - '**/*'
          cache:
            paths: []
        appRoot: front-webapp
  EOF

}

resource "aws_amplify_branch" "develop" {
  app_id            = aws_amplify_app.front_app.id
  branch_name       = "main"
  stage             = "PRODUCTION"
  enable_auto_build = true
}

