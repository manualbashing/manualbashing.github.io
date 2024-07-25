---
title: Open Azure DevOps Wikis in Obsidian
date: 2024-07-24
draft: false
tags:
  - Obsidian
  - AzureDevOps
---
## Prerequisites

First, clone the repository that contains the wiki pages. If the wiki was created as a project wiki (not by publishing code as a wiki) and is not listed in the repository view, you can still clone it by using its "secret path":

```bash
git clone https://dev.azure.com/<organization>/<project>/_git/<name of wiki>.wiki
```

Now make sure that the stage is clean and that all changes have been commited. 

Note that the following instructions keep all "customizations" local to each committer, so the wiki does not require the use of Obsidian. This means that the following steps must be performed by anyone who wants to use Obsidian to work with the wiki files.

## Make sure to use a global attachments folder

Azure DevOps allows you to use a global folder for attachments and images called `/.attachments`. This allows you to link to attachments without using absolute or relative paths. For example, `![Img1](.attachments/img1.png)` is a valid path to `img1.png` regardless of where the page containing that file is located in the repository. The same is possible in Obsidian, with the restriction that the global attachments folder **cannot** start with a dot. At the same time, in Azure DevOps, it has to start with a dot, which creates a problem that we have to work around.

We can work around this problem by creating a separate `_attachment` folder for Obsidian and making sure that all images are included from there when checked out locally, and from the appropriate `.attachments` folder when the wiki is opened in Azure DevOps.

> 🤔 Unfortunately symlinks or directory junctions are also not supported by Obsidian...

This requires to change the linking of attachments and pictures in the markdown files when checking them out locally, which can be done by using [git clean/smudge filters](https://medium.com/@dimst23/a-hidden-gem-of-git-clean-smudge-filter-6c27bee20081). (Make sure you have [Git 2.25.0](https://git-scm.com/downloads) or greater for this to work.)

Change to the root of your local reposity and delete the working directory:

```bash
rm .git/index
git clean -df
```

If your repo already has an `.gitignore` file check it out. If it doesn't, create one and make sure it ignores the folders `_attachments`, `.obsidian` and all of their contents.

```bash
git checkout HEAD .gitignore # If repo has a .gitignore
echo "_attachments/" >> .gitignore
echo ".obsidian/" >> .gitignore
```

If your repo already has a `.gitattributes` file check it out. If it doesn't, create one and add a rule that applies a text filter called "attachmentsFolder" to all markdown files.

```bash
git checkout HEAD .gitattributes # If repo has a .gitattributes
echo "*.md text filter=attachmentsFolder" >> .gitattributes
```

Now add the respective filter to your repo local git configuration:

```powershell
git config filter.attachmentsFolder.smudge "sed -e 's/\.attachments/_attachments/g'"
git config filter.attachmentsFolder.clean "sed -e 's/_attachments/.attachments/g'"
```

Next we create git hooks that trigger a sync of the content of the two attachment folders. For the sync we use [robocopy](https://learn.microsoft.com/de-de/windows-server/administration/windows-commands/robocopy) which is a built in tool in Windows 11. Use [rsync](https://lifehacker.com/geek-to-live-mirror-files-across-systems-with-rsync-196122) if you are a Linux user.

Add the following to `.git/hooks/pre-commit` (create if it does not exist) to copy new attachments from `_attachments` (Obsidian) to `.attachments` (Repo) when creating a new commit.

```bash
#!/bin/sh

echo "[pre-commit hook] Updating repo with local attachments"
pwsh -noprofile -c 'iex "robocopy _attachments .attachments /mir /njh /njs /ndl"'
git add .attachments
```

The following code copies attachments from `.attachments` (Repo) to `_attachments` (Obsidian):

```shell
#!/bin/sh

echo "[post-checkout hook] Updating local attachments with updates from repo"
pwsh -noprofile -c 'iex "robocopy .attachments _attachments /mir /njh /njs /ndl"'
```

In order to work reliably it needs to be added to the following files (create if they do not exist):
- `.git/hooks/post-checkout` (applied after git pull and change of branches)
- `.git/hooks/post-rewrite` (applied after rebase)
- `.git/hooks/post-merge` (applied after merge)

Check out the working directory to apply the smudge filter to all Markdown files (may take some time):

```bash
git checkout HEAD .
```

## Open the repository in Obsidian as vault

- Open vault from folder
- Disable unnecessary plugins
- Change attachment folder path to  `_attachments` 
- Disable wiki links
- Set the format for new links to "relative"

## Recommended plugins

### Plugin Folder Note

Creates a note that automatically serves as the index of a folder. (This is supported by Azure DevOps.) 

 - In the plugin settings: Set the "Note File Method" to "Folder Name Outside" 
- If the code `[[_ TOSP _]]` is added to the "Initial Content" of such a folder file it will be shown as a dynamic table of contents of the respective folder in Azure DevOps ([TOSP: Table of Sub Pages](https://learn.microsoft.com/en-us/azure/devops/project/wiki/markdown-guidance?view=azure-devops#add-a-subpages-table)).
- Set the "Hide Folder Node" and "Auto Rename" option.

![Screenshot Folder Note.png](/static/ScreenshotFolderNote.png)
