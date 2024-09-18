output "repositories" {
  value = {
    for key, repo in module.this :
    key => {
      name = repo.name
      url  = repo.ecr_repository_url
      arn  = repo.ecr_arn
    }
  }
}


