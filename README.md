<!--
    NOTE: To preview this file in VSCode, press F1 and run "Markdown: Open Preview to the Side".
-->

<!-- TODO: Find and replace the following within this file.
* Uncheck "whole word" match
* Do NOT edit the Reference Links section!!
ORG:    daniel-templates
REPO:   template_project
-->


# [![daniel-templates/][icon_daniel-templates]][home_daniel-templates]  template_project

<!-- TODO: Edit description. -->
##### A base template for Git-managed projects. Other project templates can be found at [daniel-templates][home_daniel-templates].

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
- Make ([from here](https://gnuwin32.sourceforge.net/packages/make.htm), or similar)

#### Linux:
- Ubuntu 20.04 (tested)
- Bash 5.0 or later

<br/>
-->


## Initial Setup

### Creating a new project from this template:
1. Create a new repository on Github, i.e. `new_repo`.
2. Create a new local repository with a remote named `origin` pointing to Github,
and a remote for each parent template:
```
    mkdir new_repo
    cd new_repo
    git init
    git remote add origin git@github.com:my_organization/new_repo.git
    git remote add template_project https://github.com/daniel-templates/template_project.git
    git fetch --all
```
3. Create branch `main` (setting as default), point it at the parent's `main`, and set its *upstream* (push/pull) to `origin`.
```
    git branch -M main
    git reset --hard template_project/main
    git push --force -u origin main
```
4. Create branch `dev`, point it to the same commit as `main`, and set its *upstream* (push/pull) to `origin`.
```
    git checkout -B dev main
    git push --force -u origin dev
```
5. Install the repo's .gitconfig file and make scripts executable:
```
    git config --local include.path ../.project/git/.gitconfig
    chmod --recursive --verbose +x ".project"
```


<!-- OPTIONAL: Add download and installation instructions -->
<!--
#### Downloading the repository:
In a terminal window, clone this repo to your system *with submodules*:
```
git clone --recurse-submodules https://github.com/daniel-templates/template_project.git
```
If you already cloned the repository without ```--recurse-submodules```, you'll need to run the following from the root directory of the repository:
```
git submodule update --init --recursive
```


#### Installing the software:
Enter the project directory using ```cd template_project``` , then run the following commands to install:
```
chmod +x install.sh
./install.sh
```
-->

<br/>



## Usage

### Project file structure:

All projects will contain the following files (at minimum):

```
.vscode/                    VSCode settings applied to this folder.
├── extensions.json           Extensions required for project development.
├── launch.json               Debugger launch configurations.
├── tasks.json                Non-debug task configurations.
├── settings.all.json         Settings applied on all systems.
├── settings.linux.json       Settings applied when developing on Linux.
└── settings.windows.json     Settings applied when developing on Windows.

.project/                      Development config and management scripts
└── git/
    ├── hooks/                  Shell scripts triggered by various Git commands.
    |   └── pre-commit            Blocks commits to specific branches (but not merges)
    ├── .gitconfig              Project-wide Git settings
    ├── init.bat
    ├── init.sh
    |
    make/
        └── system_map.mak        Defines platform-independent operations for Make

src/                        Project source code.

.gitattributes              Git settings for specific filetypes.
.gitignore                  File types and paths to exclude from repository.
LICENSE.txt                 Licensing terms.
project.code-workspace      VSCode settings applied to the whole workspace.
README.md                   This file.
```

Projects may include additional files/folders, but should use the following naming convention wherever possible:

```
.devcontainer/              VSCode config for developing inside a Docker container.
└── devcontainer.json
.github/                    Github config files.
└── workflows/                YML files for Github Actions.
    └── action.yml
bin/                        Binary executables needed during build and/or runtime.
└── do_something.exe
build/                      Build/compilation intermediate files.
└── myclass.o(.d,.class)
config/                     Config files needed during build and/or runtime.
└── settings.json
data/                       Data files consumed or produced by the program.
└── data.csv(.json,.xlsx)
docs/                       Documentation.
└── package.md(.html)
lib/                        Libraries required during build and/or runtime.
├── A/                        Library A project directory. May be a Git Submodule.
│   └── src/
└── B.a(.so,.dll,.jar)        Library B (pre-built binary).
logs/                       Log files.
└── out.log(.txt)
model/                      CAD files or other hardware description files.
└── part.ipt(.sld)
res/                        Miscellaneous resources needed during build and/or runtime.
└── gallery/                  Images used by README.md.
scripts/                    Utility scripts.
└── script.sh(.bat,.ps1)
tests/                      Unit testing scripts.
```


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
    git merge --no-ff template_project/main
    git push origin dev
```

<br/>



<!--
## Documentation:
Please refer to documentation directory: [doc/](doc/)

<br/>
-->



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
