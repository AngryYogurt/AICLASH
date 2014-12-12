AICLASH
=======

AIClash is clashing live AIs safely &amp; harmoniously. 

## Usage

This paragraph is tranlated and compiled from [here](https://github.com/fex-team/fex-team.github.io/blob/master/README.md). 

This programme is build with [jekyll](http://jekyllrb.com/). To preview please visit [online edition](http://simonmysun.github.io/AICLASH) or run a Jekyll server locally. 

### Mac/Linux

    gem install jekyll

If some error occured, you may try [Brew](http://brew.sh/) to install the lateset ruby: 

    brew install ruby

### Windows

[Building portable Jekyll for Windows](http://www.madhur.co.in/blog/2013/07/20/buildportablejekyll.html) is recommended. 

Take PortableJekyll with a location of `e:\jekyll` as an example: 

1. Add a new enviroment viriable: JEKYLL_HOME = `e:\jekyll`;
1. Add to PATH: 

	`%JEKYLL_HOME%\ruby\bin;%JEKYLL_HOME%\devkit\bin;%JEKYLL_HOME%\git\bin;%JEKYLL_HOME%\Python\App;%JEKYLL_HOME%\devkit\mingw\bin;%JEKYLL_HOME%\curl\bin`

Check if succeeded: 
	
	jekyll -h 

### Local Preview

    jekyll serve --watch

View `http://localhost:4000/AICLASH`. 