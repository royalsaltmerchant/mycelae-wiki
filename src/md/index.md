# Markaml
This is a quick and dirty site generator that takes markdown files and produces html pages with a sidebar. 

The script is making use of Jingoo templates and the Omd markdown lib.

This is just a hobby project, if you want to add features feel free to make a PR.

## Generate

The command takes in two arguments
1. The folder location that contains all your markdown files to be generated.
2. The output directory.

Example: `dune exec markaml src/md dist`

The output folder will be structured like so:
```
Dir
  - first_item
    - index.html
  - second_item
    - index.html
  ...

```
Each markdown item creates a folder with its corresponding name and an index. 

This is done so that navigation does not append .html when statically hosted. 

### Index
The script looks for a markdown file called "index.md" which creates an index.html file at the root of the output dir as well as a subfolder called index. 