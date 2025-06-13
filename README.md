<!--
    NOTE: To preview this file in VSCode, press F1 and run "Markdown: Open Preview to the Side".
-->


# [![daniel-templates/][icon_daniel-templates]][home_daniel-templates]  template-project

<!-- TODO: Edit description. -->
##### Common library of scripts, functions, and macros for projects based around Windows CMD.exe scripts (Batch files).

<br/>




#### Developer Notes

### Committing changes to the project:
1. Only commit changes to `dev` branch; **never** commit directly to `main`!
Commits (other than Merge commits) to `main` will be blocked by the pre-commit hook. See .project/git/hooks/pre-commit for details.
```
    git checkout dev
    ... change files ...
    git add *
    git commit -m "commit message"
    git push origin dev
```
2. Fast-forward `main` to `dev` when ready to release:
```
    git checkout main
    git merge --ff-only dev
    git push origin main
    git checkout dev
```


### Merging changes from the parent template into the project:
1. Check for updates:
```
    git fetch --all
```
2. Merge each parent template's `main` branch into the local `dev` branch:
```
    git checkout dev
    git merge --no-ff template-project/main
    git push origin dev
```

<br/>


---
*Author: Daniel Kennedy* ([GitHub][home_danielk-98])

<br/>



<!-- Reference Links -->
<!-- DO NOT MODIFY! -->
[home_danielk-98]: https://github.com/danielk-98?tab=repositories
[home_daniel-templates]: https://github.com/orgs/daniel-templates/repositories
[home_daniel-contrib]: https://github.com/orgs/daniel-contrib/repositories
[home_daniel-experiments]: https://github.com/orgs/daniel-experiments/repositories
[home_daniel-hardware]: https://github.com/orgs/daniel-hardware/repositories
[home_daniel-robotics]: https://github.com/orgs/daniel-robotics/repositories
[home_daniel-utilities]: https://github.com/orgs/daniel-utilities/repositories
[icon_danielk-98]: https://avatars.githubusercontent.com/u/78428703?&s=60 "Github User: danielk-98"
[icon_daniel-templates]: https://avatars.githubusercontent.com/u/132400164?s=60 "Github Organization: daniel-templates"
[icon_daniel-contrib]: https://avatars.githubusercontent.com/u/107002767?s=60 "Github Organization: daniel-contrib"
[icon_daniel-experiments]: https://avatars.githubusercontent.com/u/111267723?s=60 "Github Organization: daniel-experiments"
[icon_daniel-hardware]: https://avatars.githubusercontent.com/u/111267783?s=60 "Github Organization: daniel-hardware"
[icon_daniel-robotics]: https://avatars.githubusercontent.com/u/107002723?s=60 "Github Organization: daniel-robotics"
[icon_daniel-utilities]: https://avatars.githubusercontent.com/u/107002832?s=60 "Github Organization: daniel-utilities"
