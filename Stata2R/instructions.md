# Conversion of the artbin Stata package to R

We used Claude Code (Claude Sonnet 4.6) to convert the Stata artbin package to an R package. 
Following are the prompts we used along with some explanatory notes.


Install [claude code](https://claude.ai/code/family) and start terminal interface
Download the latest version of artbin

```
git clone https://github.com/UCL/artbin.git
```

Start the claude code terminal interface
```
./claude
```

Start prompting claude
```
convert {path to artbin}/artbin to an R tidyverse package
```
Claude will prompt you throughout the process (which took around 20 minutes). 
If you have R installed Claude will use it to run tests and correct failures, installing any required packages in your global R environment.
Creating the following output. 
```
.
├── DESCRIPTION
├── man
│   └── artbin.Rd
├── NAMESPACE
├── R
│   ├── art2bin.R
│   ├── artbin.R
│   ├── kgroup.R
│   └── utils.R
└── tests
    └── testthat
        └── test-artbin.R

5 directories, 8 files
```
Commit the output with git
```
commit this
```

You should now be able to open R, install the package and run artbin functions interactively.

At present there are several important elements missing. 

## Checking and adding tests
Claude has only implemented a subset of the tests in R. We created an [add-missing-tests](./skills/add-missing-tests/SKILL.md) skill that 
you can use to interactively correct this. Instructions for installing a skill can be found [here](https://code.claude.com/docs/en/skills).

Claude will interactively add tests to the R package, run the tests and produce [a summary](../testing/R_test_coverage.md) of the tests in each language. During this process Claude attempted to fix some failing tests in [test-ltfu.R](../R-package/tests/testthat/test-ltfu.R) by relaxing the float comparison tolerance. I instead opted to fix the tests by altering the implementation with the prompt;
```
use convcrit 1e-8 in the r tests to match stata tests
```
Commit results
```
commit new tests
```
## Add github actions to run tests
```
write a github workflow to run tests on push to main, pull requests to main, and workflow dispatch
```
```
commit workflow
```
## Adding dialog boxes
Claude did not translate the Stata dialog box `artbin.dlg`

```
create an R dialog to match package/artbin.dlg
```
Will create the files `R-package/inst/shiny/artbin/app.R` and `R-package/R/artbin_dialog.R`
Running `artbin::artbin_dialog()` gave an error, fixed with
```
got Error: 'artbin_dialog' is not an exported object from 'namespace:artbin'
```
You should now be able to run artbin interactively from R, using `artbin::artbin_dialog()`
Commit the dialog box with git.
```
commit dialog box 
```
## Documentation / Helpfiles / Vignettes
