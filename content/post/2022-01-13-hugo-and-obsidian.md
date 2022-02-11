---
title: "Hugo and Obsidian"
date: 2022-01-13T12:33:07+01:00
draft: true
---

## Why obsidian?

## Why hugo?

- Publish on github pages
- Easier to setup than jekyll

## Two repositories

- One for all files that are needed to generate the blog 
  - minus template, pictures and the actual markdown files

## The way  obsidian references images

- Central attachmetn folder
- How to make this work with hugo?
- First in your posts always refer to the static folder 
- Use default markdown linking syntax

```markdown
![Some file](/static/somefile.png)
```

- configure hugo to look for the static files in the same place by adding this to the config (if the folder is not called "static")

```toml
[[module.mounts]] 
source = "static" 
target = "attachments"
```

## The way I want to maintain by blog posts and static fils

I dont want any clutter in my obsidian and I lke the idea of having my blog posts separately from the static site generator

- using git submodules

```bash
git submodule add -b mother https://github.com/manualbashing/posts.git content/post
git submodule add -b mother https://github.com/manualbashing/posts.git static
```

- this will checkout both folders in both location, which is not what we want

```bash
git submodule update --recursive --remote --init
cd ./content/post
git filter-branch --subdirectory-filter posts -f
cd ../../static
git filter-branch --subdirectory-filter static -f
```

this updates posts and static files and I can have a look at my new posts with `hugo serve`

## Makes this work on github

This is done with a github actions workflow

#action/🕵🏻  Maybe this can also be done with going to each folder and pulling with the `--directory-fiter`

[How do I clone a subdirectory only of a Git repository? - Stack Overflow](https://stackoverflow.com/questions/600079/how-do-i-clone-a-subdirectory-only-of-a-git-repository)

[Using submodules in Git - Tutorial (vogella.com)](https://www.vogella.com/tutorials/GitSubmodules/article.html)rflow.com/questions/600079/how-do-i-clone-a-subdirectory-only-of-a-git-repository)

```yaml
name: github pages

on:
  push:
    branches:
      - master  # Set a branch to deploy
  pull_request:

jobs:
  deploy:
    runs-on: ubuntu-20.04
    steps:
      - uses: actions/checkout@v2
        with:
          submodules: true  # Fetch Hugo themes (true OR recursive)
          fetch-depth: 0    # Fetch all history for .GitInfo and .Lastmod

      - name: submoduleFilter
        run: |
          cd content/post
          git filter-branch --subdirectory-filter posts -f

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: 'latest'
          # extended: true

      - name: Build
        run: hugo --minify

      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        if: github.ref == 'refs/heads/master'
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
      
      - name: submoduleFilter
        run: |
          git checkout gh-pages
          cd static
          git filter-branch --subdirectory-filter static -f
```


[Host on GitHub | Hugo (gohugo.io)](https://gohugo.io/hosting-and-deployment/hosting-on-github/)

Now I need to trigger 

[peter-evans/repository-dispatch: A GitHub action to create a repository dispatch event](https://github.com/peter-evans/repository-dispatch)