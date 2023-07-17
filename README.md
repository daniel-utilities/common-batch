<!--
    NOTE: To preview this file in VSCode, press F1 and run "Markdown: Open Preview to the Side".
-->

<!-- Reference Links -->
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

<!-- TODO: Find and replace the following within this file.
* Uncheck "whole word" match
* Do NOT edit the Reference Links section!!
ORG:    daniel-templates
REPO:   template_vscode_project
-->


# [![GitHub Organization][icon_daniel-templates]][home_daniel-templates]  template_vscode_project

<!-- TODO: Edit description. -->
##### Base template for Git projects using VSCode. Other project templates can be found at [daniel-templates][home_daniel-templates].

<!-- OPTIONAL: Add Title Image -->
<!--
![Title image alt-text](res/gallery/title.png "Title image mouseover text")
-->

<br/>



<!-- OPTIONAL: Add System Requirements section. -->
<!--
## System Requirements

#### Windows:
- Windows 10 or later (tested on Windows 11)
- Autodesk Inventor 2023
- Git ([from here](https://git-scm.com/download/win), or similar)

#### Linux:
- Ubuntu 20.04 (tested)
- Bash 5.0 or later

<br/>
-->



<!-- OPTIONAL: Add Installation section. -->
<!--
## Installation

#### Downloading the repository:
In a terminal window, clone this repo to your system *with submodules*:
```
git clone --recurse-submodules https://github.com/daniel-templates/template_vscode_project.git
```
If you already cloned the repository without ```--recurse-submodules```, you'll need to run the following from the root directory of the repository:
```
git submodule update --init --recursive
```

#### Installing the software:
Enter the project directory using ```cd template_vscode_project``` , then run the following commands to install:
```
chmod +x install.sh
./install.sh
```

<br/>
-->



## Usage

<!-- OPTIONAL: Add Usage section. -->

#### Creating a new project from this template:
1. Create a new repository on Github, i.e. `new_repo`.
2. Create a new local repository with a remote named `origin` pointing to Github,
and a remote for each parent template:  
```
    mkdir new_repo
    cd new_repo
    git init
    git remote add origin git@github.com:my_organization/new_repo.git
    git remote add template_vscode_project https://github.com/daniel-templates/template_vscode_project.git
    git fetch --all
```
3. Create branch `main` (setting as default), point it at the parent's `main`, and set its *upstream* (push/pull) `origin`.
```
    git branch -M main
    git reset --hard template_vscode_project/main
    git push --force -u origin main
```
4. Create branch `dev`, point it to the same commit as `main`, and set its *upstream* (push/pull) to `origin`.
```
    git checkout -B dev main
    git push --force -u origin dev
```
5. Install the repo's .gitconfig file and make scripts executable:
```
    git config --local include.path ../.gitconfig
    chmod +x ./scripts/git/hooks/*
```


#### Committing changes to the project:
1. Only commit changes to `dev` branch; **never** commit to `main`!  
Commits to `main` are blocked by the pre-commit hook. See scripts/git/hooks/pre-commit for details.
```
    git checkout dev
    ... change files ...
    git add *
    git commit -m "commit message"
    git push
```
2. Fast-forward `main` to `dev` when ready to release:
```
    git checkout main
    git merge --ff-only dev
    git push
    git checkout dev
```

#### Merging template changes into the project:
1. Check for updates:
```
    git fetch --all
```
2. Merge each parent template's `main` branch into the local `dev` branch:
```
    git checkout dev
    git merge --no-ff template_vscode_project/main
    git push
```

<br/>



<!-- OPTIONAL: Add Project Structure section. -->
<!--
## Project structure:
```
.gitignore                  File types and paths to exclude from repository.
LICENSE.txt                 Licensing terms.
template_vscode_project.code-workspace      VSCode workspace config options.
README.md                   This file.
.vscode/                    VSCode project folder config.
        extensions.json         Extensions required for project development.
        launch.json             Debug configurations.
        settings.json           VSCode project-specific settings.
        tasks.json
build/                      Build output.
config/                     Configuration files needed during build and/or runtime.
doc/                        Documentation.
lib/                        Libraries required during build and/or runtime.
        A/                      Library A project directory.
            src/                    Source code for A.
        B.a(.so,.dll,.jar)      Library B (pre-built binary).
log/                        Log files.
res/                        Miscellaneous resources needed during build and/or runtime.
        gallery/                Images used by README.md.
scripts/                    Utility scripts.
        git/hooks/              Bash scripts triggered by various Git commands.
            pre-commit              Bash script which runs before every commit.
src/                        Project source code.
test/                       Unit testing scripts.
```

<br/>
-->



<!-- OPTIONAL: Add Documentation section. -->
<!--
## Documentation:
Please refer to documentation directory: [doc/](doc/)

<br/>
-->



<!-- OPTIONAL: Add photo gallery. -->
<!--
## Gallery

#### Image Title 1:

![](res/gallery/image1.png)

<br/>
-->




---
*Author: Daniel Kennedy* ([GitHub][home_danielk-98])
<!-- TODO: Add additional credits -->

<br/>
