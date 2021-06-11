# GitHub Action: Flarum Build

## Workflow Syntax

```yml
name: "Flarum Build"

on:
  schedule:
    - cron:  "0 22 * * *"

jobs:
  mirror:
    runs-on: ubuntu-latest
    name: "Build"
    steps:
      - uses: "pkgstore/github-action-flarum-build@main"
        with:
          repo: "https://github.com/${{ github.repository }}.git"
          user: "${{ secrets.BUILD_USER_NAME }}"
          email: "${{ secrets.BUILD_USER_EMAIL }}"
          token: "${{ secrets.BUILD_USER_TOKEN }}"
```
