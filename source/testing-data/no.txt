##03 Examples

Here are a some examples of everything you'll probably need.

Let's start with paragraphs. This is a paragraph.

This is another paragraph.
This is a new line, but is also part of the same paragraph. You need a blank line between paragraphs.

Like that.

###Headings

That was an H3. 

(The document gets one H1, and an H2 for the start of each section.)

####Subheadings

That was an H4. 

Bit smaller, see. See how it all works?

#####And even smaller

That was an H5.

(You probably shouldn't need to go below that for now.)


###Text formatting

This is **strong** and so is __this__.

This is *emphasised* and so is _this_.

This is ^supertext^.

> Right angle brackets &gt; are used for block quotes. 
> They can be run over multiple lines if you need them to.

###Lists

####  Ordered Lists

Ordered lists are created using numbers followed by a dot and a space. (NB: there has to be at least one blank line if you want to follow a paragraph with a list.)

1. Ordered list item
2. Ordered list item
3. Ordered list item

#### Unordered Lists

Unordered list are created using a '*' followed by a space.

* Unordered list item
* Unordered list item
* Unordered list item 

Or, if you prefer, '-' followed by a space also works:

- Unordered list item
- Unordered list item
- Unordered list item


Lists can be nested too, using four spaces or a tab

- Aa
    - Aardvark
    - Apple
- Bb
    - Beatles
        - John
        - Paul
        - George
        - Ringo                
	- Beetles
		- Dung
		- Stag
- Cc
	- Camp
	- Coin

###Links

Inline links are easy; here are two examples. We use [Kramdown](http://kramdown.rubyforge.org/quickref.html) which is an extension of [Markdown](http://daringfireball.net/projects/markdown/basics).

Reference style links are also possible. Useful for re-use of the same link. The full [markdown syntax][mdsyntax] is a link you might want to keep handy. Perhaps even [repeatedly][mdsyntax]. Having been defined, links can be used anywhere in the doc with corresponding id.

[mdsyntax]: http://daringfireball.net/projects/markdown/syntax "Markdown syntax"
[google]: http://google.com "Google"


###Tables

Tables are quite simple.

| First Header | Second Header | Third Header |
| ------------ | ------------- | ------------ |
| Content      | Content       | Content      |
| Content      | Content       | Content      |


Alignement for each column can be specific by adding colons to separator lines.

| First Header | Second Header | Third Header| 
| :----------- | :-----------: | -----------:| 
| Left         | Center        | Right       |
| Left         | Center        | Right       |

###Images

Embedding images work like this. Images live in an `images` subdirectory.

![Title](images/cabinetofficelogo.gif)

######Figure 1: Cabinet Office logo
