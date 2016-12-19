# Right Height [![Build Status](https://travis-ci.org/cferdinandi/right-height.svg)](https://travis-ci.org/cferdinandi/right-height)
Dynamically set content areas of different lengths to the same height.

[Download Right Height](https://github.com/cferdinandi/right-height/archive/master.zip) / [View the demo](http://cferdinandi.github.io/right-height/)



## Getting Started

Compiled and production-ready code can be found in the `dist` directory. The `src` directory contains development code. Unit tests are located in the `test` directory.

### 1. Include Right Height on your site.

```html
<script src="dist/js/right-height.js"></script>
```

### 2. Add the markup to your HTML.

```html
<div class="row" data-right-height>
	<div class="grid-third" data-right-height-content>
		Content 1
	</div>
	<div class="grid-third" data-right-height-content>
		Content 2
	</div>
	<div class="grid-third" data-right-height-content>
		Content 3
	</div>
</div>
```

Add the `[data-right-height]` data attribute to the wrapper div for your content areas. This let's Right Height adjust heights for different sections of content independently from each other.

Give each content area that you want Right Height to adjust a `[data-right-height-content]` data attribute.

*You can style your content areas (and their wrappers) however you see fit. The `.row` and `.grid-third` classes are used for demonstration purposes only.*

### 3. Initialize Right Height.

```html
<script>
	rightHeight.init();
</script>
```

In the footer of your page, after the content, initialize Right Height. And that's it, you're done. Nice work!



## Installing with Package Managers

You can install Right Height with your favorite package manager.

* **NPM:** `npm install cferdinandi/right-height`
* **Bower:** `bower install https://github.com/cferdinandi/right-height.git`
* **Component:** `component install cferdinandi/right-height`



## Working with the Source Files

If you would prefer, you can work with the development code in the `src` directory using the included [Gulp build system](http://gulpjs.com/). This compiles, lints, and minifies code, and runs unit tests. It's the same build system that's used by [Kraken](http://cferdinandi.github.io/kraken/), so it includes some unnecessary tasks and Sass variables but can be dropped right in to the boilerplate without any configuration.

### Dependencies
Make sure these are installed first.

* [Node.js](http://nodejs.org)
* [Gulp](http://gulpjs.com) `sudo npm install -g gulp`

### Quick Start

1. In bash/terminal/command line, `cd` into your project directory.
2. Run `npm install` to install required files.
3. When it's done installing, run one of the task runners to get going:
	* `gulp` manually compiles files.
	* `gulp watch` automatically compiles files when changes are made and applies changes using [LiveReload](http://livereload.com/).
	* `gulp test` compiles files and runs unit tests.



## Options and Settings

Right Height includes smart defaults and works right out of the box. But if you want to customize things, it also has a robust API that provides multiple ways for you to adjust the default options and settings.

### Global Settings

You can pass options and callbacks into Right Height through the `init()` function:

```javascript
rightHeight.init({
	selector: '[data-right-height]', // The selector for content containers (must use a valid CSS selector)
	selectorContent: '[data-right-height-content]', // The selector for content (must use a valid CSS selector)
	callback: function ( container ) {} // Function that runs after content height is adjusted
});
```

### Use Right Height events in your own scripts

You can also call the Right Height adjust height function in your own scripts.

#### adjustContainerHeight()
Set all content areas in a container to the same height.

```javascript
rightHeight.adjustContainerHeight(
	container, // Node that contains the content areas. ex. document.querySelector('#content-wrapper')
	options // Callbacks. Same options as those passed into the init() function.
);
```

**Example**

```javascript
var container = document.querySelector('#container');
rightHeight.adjustContainerHeight( container );
```

#### destroy()
Destroy the current `rightHeight.init()`. This is called automatically during the init function to remove any existing initializations.

```javascript
rightHeight.destroy();
```



## Browser Compatibility

Right Height works in all modern browsers, and IE 9 and above.

Right Height is built with modern JavaScript APIs, and uses progressive enhancement. If the JavaScript file fails to load, or if your site is viewed on older and less capable browsers, content areas will render at their default heights.



## How to Contribute

In lieu of a formal style guide, take care to maintain the existing coding style. Please apply fixes to both the development and production code. Don't forget to update the version number, and when applicable, the documentation.



## License

The code is available under the [MIT License](LICENSE.md).