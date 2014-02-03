*"Publish, don't send."* - Mike Bracken

# The Digital Strategy has moved

We now publish and host this document on [GOV.UK](https://www.gov.uk):

https://www.gov.uk/government/collections/government-digital-strategy-reports-and-research

This code base is maintained for historical purposes only.

# What is this?

This repository contains the code and content behind the Government Digital
Strategy site as seen online at [http://publications.cabinetoffice.gov.uk/digital/](http://publications.cabinetoffice.gov.uk/digital/ "Government Digital Strategy online publication")

By following the instructions below anyone comfortable with using command line can set up a local, working, copy of the site, and view the content as it appears online.

These instructions are based on Mac OS X. They should also work on Linux systems, but will not work on Windows.

# Quick Start

The following 10 steps should get you up and running pretty quickly. All steps are further documented below.

1. Install [Node.js](http://nodejs.org/), and [npm](https://npmjs.org/). Most installs of Node come with npm, it's very unlikely that you'll need to explicitly install npm. To check, run `node -v` and `npm -v` on the command line.
2. Install [Ruby](http://www.ruby-lang.org/en/) v1.9+ and [RubyGems](http://rubygems.org/). Check these versions with `ruby -v` and `gem -v` (We recommend you don't install over the system version of Ruby. Tools like [rbenv](https://github.com/sstephenson/rbenv) let you manage Ruby versions nicely.)
3. Install the [Bundler gem](http://gembundler.com/) with `gem install bundler`
4. Clone the project: `git clone git@github.com:alphagov/government-digital-strategy.git` (Or you may decide to fork and clone your own version).
5. `cd` into the project directory.
6. Run `npm install` to install all Node dependencies.
7. Run `bundle` (short for `bundle install`) to install all Ruby dependencies.
8. Run the build script: `bundle exec ./local-build.sh`
9. Run the server: `ruby scripts/built-server.rb`
10. Visit `http://localhost:8080/digital` to view.

# Before running the build script

Make sure you've got Node & npm installed (see links above), and then CD into the directory and run:

```
npm install
```

This uses the `package.json` file to install dependencies.

Similarly, run `bundle` to make sure all the Gems are installed

```
bundle
```


__If you ever get any errors, in particular Ruby errors or Node / JS errors, you probably just need to make sure all dependencies are met. Run both the above commands to make sure you're up to date.__


# Local Build Script

Run the shell script:

```
bundle exec ./local-build.sh
```

Calling these scripts with `bundle exec` makes sure the commands are run within the context of your local Bundle (the gems defined in `Gemfile`).

This compiles everything into the `built` folder. To view it locally, run `ruby scripts/built-server.rb` and head to `http://localhost:8080`

This wont attempt to pull in any content from other Github repositories, so can be run when you're sans-internet.

# Production Build Script

The local-build script is great for viewing locally but doesn't do any of the performance stuff we want - minifying CSS, JS and so on. The production build script does.

```
bundle exec ./deploy.sh
```

It will compile and minify the JS and CSS. This uses the RequireJS optimizer, so you need to have run `npm install` first.

To make it generate the PDFs, you need to pass in the argument:

```
bundle exec ./deploy.sh pdf
```

Once it's done, you're left with a `deploy/` folder which is the production-ready files. This is what should be deployed to the server.

If you want to test that the deploy folder works fine, run `ruby scripts/deploy-server.rb`, which serves up the `deploy/` folder on port 9090.

# PDFs

The PDFs are generated through [PDF Crowd](http://pdfcrowd.com/). You'll need to register for a free account and get a username and API Key. Then edit `config/pdf.config.yml.sample`, adding the details. Then rename the file, removing `.sample` from the end.

Then simply run `./pdf.sh`, passing in the folder name. For example: `./pdf.sh built/digital/efficiency`. There's no need to do a build first, the PDF script does it for you.

The PDF JavaScript assets are stored within the [pdf-only](https://github.com/alphagov/government-digital-strategy/tree/master/assets/pdf-only) folder. We upload a ZIP to PDF Crowd that contains the JavaScript, some CSS and the HTML we need. This lets us have full control over the generated PDF.

# Uploading

Make sure the S3 credentials are okay in `config/s3.config.yml`. Then run:

```
bundle exec ./deploy.sh
bundle exec ruby scripts/push_to_s3.rb
```

Then you need to check the site, and once you're happy, invalidate the Cloudfront cache so the live site updates.

```
bundle exec ruby scripts/clear_s3_cache.rb
```

# Assets

__NEVER EDIT A FILE in the `built/` folder__. These get overwritten by the build script and are not tracked by Github. The same goes for the `deploy/` folder.

__Never edit the CSS directly__, as it will get overwritten by the build script

Templates, partials, code, images and so on live in `assets/`

Content goes into `source/`

All the CSS lives in `/assets/css`. The files in this folder are generated from the .scss files in `/assets/sass`.

/assets/sass/  | Notes
----------------------- | --------------------------------------------------------|
strategy-site.scss      | Styles for the Strategy home page and action pages |
publication.scss        | Styles for the 'web publication' format (ie. the Strategy, Research, Report etc.) |
...ie6,7,8,9.scss       | Versions of the above files for specific IE browsers |
print.scss              | Print and PDF styles for the  'web publication' format |
media-player.scss       | Styles for the Nomensa media player used on the assets pages |

/assets/sass/partials/  | Notes
----------------------- | --------------------------------------------------------|
_common.scss            | Styles that are common to both the 'web publication' format and the Strategy site pages |
_colours.scss           | Sass variables for colours used throughout the site. Used by _common.scss |
_typography.scss        | Typographic styles. Used by _common.scss |
_yui-reset.scss         | Basic cross-browser styles reset. Used by _common.scss |
_regular-grid.scss      | Mixin for doing regular grids of content. Used by strategy-site.scss for laying out the document links towards the bottom of the home page |
_css3.scss | Mixins for vendor prefixes. Part of the GOV.UK Website Toolkit |
_conditionals.scss | Mixins for designing for screen-size, browser and print. Part of the GOV.UK Website Toolkit |
_shims.scss | Mixins for plugging known gaps in browser CSS support. Part of the GOV.UK Website Toolkit |
magna-charta.scss | Styles for creating baic charts using [Magn Charta](https://github.com/alphagov/magna-charta) |


# Partials and Templates and Syntax

You should check `source/sample-document` for a living demo of how everything works.

Partials live in `source/partials` and should be named with an underscore at the start, eg `_mypartial.html`

A partial can contain Markdown or HTML, just name it as `.md` or `.html`

To include a Markdown, in either your HTML or MD file, use:

```
{include action-text.md}
```

That would look for `source/partials/_action-text.md`

You can put partials within subfolders:

```
{include digital/action-01.md}
```

Looks for `source/partials/digital/_action-01.md`.

If you include a MD partial in an HTML page, the MD is compiled first.

# Templates

Similarly to partials, for the HTML pages we have templates you can use. These are in `assets/templates/`

The main line you need to look for is `<!--REPLACE-->`. The contents of the page that uses this template are put into the file, in place of that shortcut.

The line `<!--TIME-->` is replaced with the compilation time. This is mainly for debugging.

The line `<!--META-->` gets replaced with the contents of `meta.html` within the document directory, if there is one. This is where extra stuff to be put in the `<head>` on a per-document basis exists.

To assign a template to a HTML file, insert, at the very top of the HTML file, a tag, for example, here's one of the HTML files that uses the home_template:

```
{home_template}
      <div class="document-title">
        <div class="title">
          <h2>Digital services so good people prefer to use them</h2>
        </div>
      </div>
      ...
</body>
</html>
```

That would look for `asset/templates/home_template.html` and the above contents would be put into the template where `<!--REPLACE-->` is.

The digital documents use the `digital_doc_template.html`. The others use `generic_template.html`. Individual files can use any template they like, as defined above.

# Tests
Tests are run with RSpec. While they do not cover every feature of the system, they offer a good indication if everything is working as it should or not.

Tests all live within the `spec` folder.

To run them, run `rspec`. You can also run them through Guard with `bundle exec guard`, which will rerun the tests everytime one of the spec files is changed.

Tests also offer good documentation, in particular `compiling/processcontents_spec.rb` documents all the Regular Expressions we use nicely.

## Pre-Processing Markdown
Authors write their content in Markdown, but before it's parsed we do some extra things to it, to help us style it. This is all done in [processcontents.rb](https://github.com/alphagov/government-digital-strategy/blob/master/compiling/processcontents.rb). Below we've listed some of the main ones we do, but for a comprehensive list, check out the source. All the Regexes we use are commented.

#### Section Headings
```markdown
##Annex 01 - Lorem Ipsum
##02 Introduction
```
Gets converted to:
```markdown
##<span class='title-index'>Annex 01</span><span class='title-text'>Lorem Ipsum</span>\n{: .section-title}
##<span class='title-index'>02</span><span class='title-text'>Introduction</span>\n{: .section-title}
```

#### PDF Linking
```markdown
{PDF=blah.pdf}
```
Gets converted to:
```markdown
[PDF Format](blah.pdf)
```

#### Extra HTML Input
A slightly easier way for authors to input arbitary HTML. For example, this:
```markdown
{div .foo}
hello world
{/div}
```
Gets turned into:
```html
<div class="foo">hello world</div>
```

This isn't that fully featured through; it only supports adding one class and nothing more.

#### Action Headings
```markdown
####Action 01: Lorem Ipsum
```
Converted into:
```markdown
<h4 id='action-01' class='section-title'><span class='title-index'><span>Action </span> 01</span><span class='title-text'>Lorem Ipsum</span></h4>
```

#### Last edited Timestamp
```markdown
{TIMESTAMP}
```
If this is used within a document, we'll use Git to calculate the last time this folder was edited, and provide it as the timestamp, linking to the repository. For example, this might be replaced with something like:
```markdown
[1 Dec 2012 at 1:30 pm](http://github.com/alphagov/government-digital-strategy/commits/master/source/digital/strategy)
```

Remember, all this parsing is done __before__ the Markdown is parsed. Kramdown is very good at parsing HTML within Markdown, which made it perfect for this project.



## Changelist

_These document all the larger updates to the site we've done sinch the launch. If you'd like a full list, just view the commits log. A lot of minor changes or very small bug fixes are not listed here, else we'd just be duplicating the Git commit log._

__15/03/13__
- switched to our version of the Accessible video player. Many improvements to this.

__21/12/12__
- Added the department responses to each Actions
- Published the Assisted Digital Paper
- lots more small tweaks and bug fixing

__18/12/12__
- fixed bug with the video on the strategy site that meant it wouldn't work in some versions of Firefox.

__17/12/12__
- fix videos on Print stylesheet. These are hidden and a link is added to Youtube.
- added transcripts to every video on the site
- fixed bug that made the page jump when it first loaded
- fixed Markdown parsing bug

__06/12/12__
- add Tim O'Reilly video to "Government as a Platform" case study.
- refactored the Ruby compilation scripts to be much tidier.
- moved Ruby scripts into `/scripts` folder.
- tidied up command line output of the scripts, much easier to follow now.

__03/12/12__
- added V3 of Magna Charta, toggle links on charts to switch between chart and table view
- Fixed some small CSS mobile bugs
- added "title" attribute values to "Read More" links
- Tweaked Print CSS - added underlines to links, general tidying
- moved R.js out of the root and use the Require JS npm module.

__27/11/12__
- new script to auto-generate PDF, that gives us bar-charts in our PDFs instead of the tables.

__26/11/12__
- no more bar chart images! We've switched to using our own JS bar chart plugin, [Magna Charta](http://github.com/alphagov/magna-charta).

__21/11/12__
- replacing "service owner" / "service manager" text with "Service Manager" to be consistent.
- bump every "Read More" link in case-study down onto its own line, to avoid awkward line breaks in the middle of the link which don't look right.

__19/11/12__
- added in Phil Pavett case study.
- added Carolyn Williams profile image to case study.

__15/11/12__
- added in timestamps for each document that show the last updated date, generated automatically from Git for us, and linking to the relevant document folder on Github.

__14/11/12__
- added watch task to automatically build locally on changes ( run `ruby watch-build.rb` ).

__13/11/12__
- switched to retina resolution logo.
- CO crest now in HTML rather than CSS BG image.
- updated the Partials syntax so it's easier and more clear.

__9/11/12__
- fixed some labelling on some of the graphs that made it unclear (extra "-").
- added profile images to case study pages.

__8/11/12__
- stopped using blue for words within charts, so they don't look like links.

__7/11/12__
- initial release!
