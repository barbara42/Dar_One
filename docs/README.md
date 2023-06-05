# Documentation Info 

Documentation is build using [Documenter](https://github.com/JuliaDocs/Documenter.jl) 

Documentation is published from the `gh-pages` branch. 

`gh-pages` contains the build directory and all built pages. No other branch should contain /docs/build 

Workflow for updating documentation 
- modify `make.jl` or  files in `/src` folder 
- build the docs 
    - run command `julia make.jl`
- check that everything looks good and works well! 
- create a PR to the `test` branch (should NOT contain docs/build folder)
    - PR merged into `test` 

TODO: finish 

when committing to `gh-pages` branch, include the build folder. You have to override the .gitignore by using the "force" option, -f 

when changes are pushed to `gh-pages`, documentation will be automatically deployed 


