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
you can use to interactively correct this.
