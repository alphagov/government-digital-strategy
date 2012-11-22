# Assets


## Sass and CSS

All the Sass lives in `/assets/sass`. The files in this folder are used to generate the CSS files in `/assets/css`.

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


