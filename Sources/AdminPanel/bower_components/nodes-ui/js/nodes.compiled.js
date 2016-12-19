// the semi-colon before function invocation is a safety net against concatenated
// scripts and/or other plugins which may not be closed properly.
;(function ( $, window, document, undefined ) {
	"use strict";

	/*
	 Settings (data-*):
	 - options
	 - language

	 On init:
	 - Configure and initialize ace-editor plugin

	 Helper Methods (Private):
	 - Eval data-options

	 */

	/*!
	 * ...
	 * Author: Alexander Hafstad <alhl@nodes.dk>
	 */
	var aceEditorWrapper = {
		init: function( options, elem ) {
			// Save the element reference, both as a jQuery
			// reference and a normal reference
			this.elem  = elem;
			this.$elem = $(elem);

			this.$output = this.$elem.parent().find('.ace-editor-output textarea');

			var ACE_MODE_PREFIX = 'ace/mode/';

			// Most options are NOT configurable
			var ACE_OPTIONS = {
				minLines: 5,
				maxLines: 30
			};

			// Mix in the passed-in options with the default options
			this.options = $.extend( {}, this.options, options );

			// Set langauge depending on data-toggle
			this.language = this.$elem.data('language');
			var LANG;

			if(!this.language) {
				LANG = ACE_MODE_PREFIX + 'json';
			} else {
				LANG = ACE_MODE_PREFIX + this.language;
			}

			// Mix in the data-options with the options
			this.options = $.extend( {}, this.options, _evalDataOptions( this.$elem.data('options') ) );

			// Initialize ace-editor plugin
			this.editorInstance = ace.edit(this.elem);
			this.editorInstance.setTheme(this.options.theme);
			this.editorInstance.getSession().setMode(LANG);

			if(this.$output.length > 0) {
				this.$output.hide();
				this.editorInstance.setValue(this.$output.val());

				var thatOutput = this.$output;
				var thatInstance = this.editorInstance;

				thatInstance.getSession().on('change', function() {
					thatOutput.val(thatInstance.getSession().getValue());
				});
			}

			// Loop through and apply options
			for(var key in ACE_OPTIONS) {
				if(ACE_OPTIONS.hasOwnProperty(key)) {
					this.editorInstance.setOption(key, ACE_OPTIONS[key]);
				}
			}

			// return this so that we can chain and use the bridge with less code.
			return this;
		},
		options: {
			theme: 'ace/theme/chrome'
		}
	};

	/*
	 Helper Methods
	 */
	function _evalDataOptions(options) {
		options = eval('(' + options + ')');
		return options;
	}

	// Object.create support test, and fallback for browsers without it
	if ( typeof Object.create !== "function" ) {
		Object.create = function (o) {
			function F() {}
			F.prototype = o;
			return new F();
		};
	}

	// Create a plugin based on a defined object
	$.plugin = function( name, object ) {
		$.fn[name] = function( options ) {
			return this.each(function() {
				if ( ! $.data( this, name ) ) {
					$.data( this, name, Object.create(object).init(
						options, this ) );
				}
			});
		};
	};

	// Register the plugin
	$.plugin('aceEditorWrapper', aceEditorWrapper);

})( jQuery, window, document );
;(function ( $, window, document, undefined ) {
	"use strict";
	/*
	 * ...
	 * Author: Dennis Haulund Nielsen <dhni@nodes.dk>
	 */
	var autoCompleteWrapper = {
		init: function( options, elem ) {

			if(!options) {
				throw 'Error: Missing options argument!';
			}
			if(_objectIsEmpty(options)) {
				throw 'Error: Options must not be empty'
			}
			if(!options.hasOwnProperty('serviceUrl')) {
				throw 'Error: Missing serviceUrl option';
			}
			if(!_isFunction(options.serviceUrl)) {
				throw 'Error: serviceUrl option must be a function';
			}
			if(!options.hasOwnProperty('transformResult')) {
				throw 'Error: Missing transformResult option';
			}
			if(!_isFunction(options.transformResult)) {
				throw 'Error: transformResult option must be a function';
			}

			var self = this;

			// Save the element reference, both as a jQuery
			// reference and a normal reference
			this.elem  = elem;
			this.$elem = $(elem);

			this.$input = this.$elem.find('input[type="text"]');

			// Mix in the passed-in options with the default options
			this.options = $.extend( {}, this.options, options );

			// Mix in the data-options with the options
			this.options = $.extend( {}, this.options, _evalDataOptions( this.$elem.data('options') ) );


			this.$elem.append(this.options.spinnerMarkup);

			this.$loadingIndicator = this.$elem.find('.auto-complete__loading-indicator');
			var loadingIndicatorActiveClass = 'auto-complete__loading-indicator--active';

			this.options.onSearchStart = function() {
				self.$loadingIndicator.addClass(loadingIndicatorActiveClass);
			};
			this.options.onSearchError = function() {
				self.$loadingIndicator.removeClass(loadingIndicatorActiveClass);
			};
			this.options.onSearchComplete = function() {
				self.$loadingIndicator.removeClass(loadingIndicatorActiveClass);
			};

			if(this.$elem.hasClass('auto-complete--inverse')) {
				this.options.containerClass += ' autocomplete-suggestions--inverse';
			}

			// Initialize datetimepicker plugin
			this.$input.autocomplete(this.options);

			// return this so that we can chain and use the bridge with less code.
			return this;

		},
		options: {
			ignoreParams: true,
			showNoSuggestionNotice: true,
			containerClass: 'autocomplete-suggestions',
			spinnerMarkup: '<div class="auto-complete__loading-indicator"><i class="fa fa-circle-o-notch fa-spin"></i></div>'
		}
	};

	/*
	 Helper Methods
	 */
	function _evalDataOptions(options) {
		options = eval('(' + options + ')');
		return options;
	}

	function _isFunction(v) {
		return v instanceof Function;
	}

	function _objectIsEmpty(obj) {
		for(var key in obj) {
			if(obj.hasOwnProperty(key)) {
				return false;
			}
		}
		return true;
	}

	// Object.create support test, and fallback for browsers without it
	if ( typeof Object.create !== "function" ) {
		Object.create = function (o) {
			function F() {}
			F.prototype = o;
			return new F();
		};
	}

	// Create a plugin based on a defined object
	$.plugin = function( name, object ) {
		$.fn[name] = function( options ) {
			return this.each(function() {
				if ( ! $.data( this, name ) ) {
					$.data( this, name, Object.create(object).init(
							options, this ) );
				}
			});
		};
	};

	// Register the plugin
	$.plugin('autoCompleteWrapper', autoCompleteWrapper);

})( jQuery, window, document );
// the semi-colon before function invocation is a safety net against concatenated
// scripts and/or other plugins which may not be closed properly.
;(function ( $, window, document, undefined ) {
	"use strict";
	/*
	 * ...
	 * Author: Dennis Haulund Nielsen <dhni@nodes.dk>
	 */
	var colorpickerWrapper = {
		init: function( options, elem ) {
			// Save the element reference, both as a jQuery
			// reference and a normal reference
			this.elem  = elem;
			this.$elem = $(elem);

			this.$input = this.$elem.find('input');

			// Mix in the passed-in options with the default options
			this.options = $.extend( {}, this.options, options );

			this.size = this.$elem.data('size');

			if(this.size === 'large') {
				this.options.customClass = 'color-picker--large';
				this.options.sliders = {
					saturation: {
						maxLeft: 200,
								maxTop: 200
					},
					hue: {
						maxTop: 200
					},
					alpha: {
						maxTop: 200
					}
				}
			}

			// Mix in the data-options with the options
			this.options = $.extend( {}, this.options, _evalDataOptions( this.$elem.data('options') ) );

			// Initialize datetimepicker plugin
			this.$elem.colorpicker(this.options);

			this.$input.on('focus', function() {
				$(elem).colorpicker('show');
			});
			this.$input.on('blur', function() {
				$(elem).colorpicker('hide');
			});

			// return this so that we can chain and use the bridge with less code.
			return this;

		}
	};

	/*
	 Helper Methods
	 */
	function _evalDataOptions(options) {
		options = eval('(' + options + ')');
		return options;
	}

	// Object.create support test, and fallback for browsers without it
	if ( typeof Object.create !== "function" ) {
		Object.create = function (o) {
			function F() {}
			F.prototype = o;
			return new F();
		};
	}

	// Create a plugin based on a defined object
	$.plugin = function( name, object ) {
		$.fn[name] = function( options ) {
			return this.each(function() {
				if ( ! $.data( this, name ) ) {
					$.data( this, name, Object.create(object).init(
						options, this ) );
				}
			});
		};
	};

	// Register the plugin
	$.plugin('colorpickerWrapper', colorpickerWrapper);

})( jQuery, window, document );
// the semi-colon before function invocation is a safety net against concatenated
// scripts and/or other plugins which may not be closed properly.
;(function ( $, window, document, undefined ) {
	"use strict";

	/*
	 Settings (data-*):
	 - options
	 - toggle

	 On init:
	 - Configure and initialize datetimepicker plugin <https://eonasdan.github.io/bootstrap-datetimepicker>

	 Helper Methods (Private):
	 - Eval data-options

	 */

	/*!
	 * ...
	 * Author: Alexander Hafstad <alhl@nodes.dk>
	 */
	var datetimepickerWrapper = {
		init: function( options, elem ) {
			// Save the element reference, both as a jQuery
			// reference and a normal reference
			this.elem  = elem;
			this.$elem = $(elem);

			// Mix in the passed-in options with the default options
			this.options = $.extend( {}, this.options, options );

			// Set format depending on data-toggle
			this.toggle = this.$elem.data('toggle');

			if(this.toggle === 'date') {
				this.options.format = 'YYYY-MM-DD';
			} else if(this.toggle === 'time') {
				this.options.format = 'HH:mm';
			}

			// Mix in the data-options with the options
			this.options = $.extend( {}, this.options, _evalDataOptions( this.$elem.data('options') ) );

			var viewInput = this.elem.getElementsByTagName('input');
			if(viewInput[0]) {

				var name = viewInput[0].getAttribute('name');
				if(name) {
					var form = viewInput[0].form;

					// Rename original input field as this is just for the view, and should not be sent to the server
					viewInput[0].removeAttribute('name');

					// Create hidden input field
					var input = document.createElement('input');
					input.setAttribute('type', 'hidden');
					input.setAttribute('name', name);

					// Format existing value
					var date = moment(viewInput[0].getAttribute('value'));

					if(date && this.options.parseISO) {
						input.value = date.format('YYYY-MM-DDTHH:mm:ssZZ');
					} else if (date && !this.options.parseISO) {
						input.value = date.format('YYYY-MM-DD HH:mm:ss');
					}

					form.appendChild(input);
				}
			}

			var datetimepickerOptions = this.options;
			delete datetimepickerOptions.parseISO;

			// Initialize datetimepicker plugin
			this.$elem.datetimepicker(datetimepickerOptions).on('dp.change', function() {

				if(input) {
					var date = this.$elem.data('DateTimePicker').date();

					if(!date) {
						input.value = '';
					} else if(this.options.parseISO) {
						input.value = date.format('YYYY-MM-DDTHH:mm:ssZZ');
					} else {
						input.value = date.format('YYYY-MM-DD HH:mm:ss');
					}
				}
			}.bind(this));

			// return this so that we can chain and use the bridge with less code.
			return this;
		},
		options: {
			format: 'YYYY-MM-DD HH:mm',
			allowInputToggle: true,
			icons: {
				time: 'fa fa-clock-o',
				date: 'fa fa-calendar',
				up: 'fa fa-arrow-up',
				down: 'fa fa-arrow-down',
				previous: 'fa fa-arrow-left',
				next: 'fa fa-arrow-right',
				today: 'fa fa-calendar-times-o',
				clear: 'fa fa-trash',
				close: 'fa fa-times'
			},
			parseInputDate: function (inputDate) {
				inputDate = moment(inputDate);
				return inputDate;
			},
			parseISO: false
		}
	};

	/*
	 Helper Methods
	 */
	function _evalDataOptions(options) {
		options = eval('(' + options + ')');
		return options;
	}

	// Object.create support test, and fallback for browsers without it
	if ( typeof Object.create !== "function" ) {
		Object.create = function (o) {
			function F() {}
			F.prototype = o;
			return new F();
		};
	}

	// Create a plugin based on a defined object
	$.plugin = function( name, object ) {
		$.fn[name] = function( options ) {
			return this.each(function() {
				if ( ! $.data( this, name ) ) {
					$.data( this, name, Object.create(object).init(
						options, this ) );
				}
			});
		};
	};

	// Register the plugin
	$.plugin('datetimepickerWrapper', datetimepickerWrapper);

})( jQuery, window, document );
// the semi-colon before function invocation is a safety net against concatenated
// scripts and/or other plugins which may not be closed properly.
;(function ( $, window, document, undefined ) {
	/*!
	 * ...
	 * Author: Dennis Haulund Nielsen
	 */

	/*
	 Events:
	 - file-input on change (bliver også trigger af valg af fil, og af drop)
	 - body on drop prevent default
	 - file-picker on dropover, dropleave, drop
	 - clear-button on click

	 Methods:
	 - get/set preview
	 - get/set icon
	 - get/set filename

	 Super Methods (should call above based on if/elses):
	 - on file update
	 - on file clear

	 Settings (data-*):
	 - disablePreview
	 - filePatterns

	 On init:
	 - if has preview image already, switch from "new" to "in use"

	 Helper Methods (Private):
	 - map file-extension to .fa icon
	 - is image

	 */


	// myObject - an object representing a concept that you want
	// to model (e.g. a car)
	var filePicker = {
		init: function( options, elem ) {

			var self = this;

			var dragEnterTarget = null;

			// Save the element reference, both as a jQuery
			// reference and a normal reference
			this.elem  = elem;
			this.$elem = $(elem);

			// Mix in the passed-in options with the default options
			this.options = $.extend( {}, this.options, options );

			if(this.$elem.data('disable-preview')) {
				this.options.disablePreview = this.$elem.data('disable-preview');
			}

			this.$fileInput = this.$elem.find('.file-picker__file-input');
			this.$fileOutput = this.$elem.find('.file-picker__file-name');
			this.$previewImg = this.$elem.find('.file-picker__preview');
			this.$previewIcon = this.$elem.find('.file-picker__icon');
			this.$clearInputBtn = this.$elem.find('.file-picker__clear');
			this.$dropZone = this.$elem.find('.file-picker__zone');

			if(this.options.disablePreview) {
				this.$elem.addClass('file-picker--no-preview');
				this.$dropZone.hide();
			}

			/*
			 If the component is preconfigured
			 */
			if(this.$elem.data('image') && !this.$elem.data('file')) {
				this.$previewImg.attr('src', this.$elem.data('image'));
				this.$clearInputBtn.show();
				fileName(this.$fileOutput, this.$elem.data('image'));
			}

			if(this.$elem.data('file') && !this.$elem.data('image')) {
				previewIcon(this.$previewIcon, {name: this.$elem.data('file')}, this.options.filePatterns);
				this.$clearInputBtn.show();
				fileName(this.$fileOutput, this.$elem.data('file'));
			}

			this.$fileInput.bind('change', function(e) {
				var file = this.files[0];
				if(file) {
					if(_fileIsImage(file) && !self.options.disablePreview) {
						previewImg(self.$previewImg, file);
					} else {
						previewIcon(self.$previewIcon, file, self.options.filePatterns);
					}

					fileName(self.$fileOutput, file.name);

					self.$clearInputBtn.show();
				} else {
					removeFile(e, self.$previewImg, self.$previewIcon, self.$fileInput, self.$fileOutput, self.$clearInputBtn);
				}
			});
			this.$elem.bind('dragover', function(e) {
				e.preventDefault();
			});
			this.$elem.bind('dragenter', function(e) {
				dragEnterTarget = e.originalEvent.target;
				e.stopPropagation();
				e.preventDefault();
				self.$dropZone.addClass('highlight');
				return false;
			});
			this.$elem.bind('dragleave', function(e) {
				if(dragEnterTarget == e.originalEvent.target) {
					e.stopPropagation();
					e.preventDefault();
					self.$dropZone.removeClass('highlight');
				}
			});
			this.$elem.bind('drop', function(e) {
				if(e.originalEvent.dataTransfer && e.originalEvent.dataTransfer.files) {
					e.preventDefault();
					self.$fileInput.prop('files', e.originalEvent.dataTransfer.files);
					self.$dropZone.removeClass('highlight');
				}
			});
			this.$clearInputBtn.bind('click', function(e) {
				removeFile(e, self.$previewImg, self.$previewIcon, self.$fileInput, self.$fileOutput, self.$clearInputBtn);
			});
			window.addEventListener('dragover',function(e){
				e = e || event;
				e.preventDefault();
			},false);
			window.addEventListener('drop',function(e){
				e = e || event;
				e.preventDefault();
			},false);

			// return this so that we can chain and use the bridge with less code.
			return this;
		},
		options: {
			disablePreview: false,
			filePatterns: {
				'PDF': {
					icon: 'fa-file-pdf-o',
					match: /\.(pdf)$/i
				},
				'VIDEO': {
					icon: 'fa-file-video-o',
					match: /\.(mp4|mov|avi)$/i
				},
				'PRESENTATION': {
					icon: 'fa-file-powerpoint-o',
					match: /\.(ppt|pptx|key)$/i
				},
				'AUDIO': {
					icon: 'fa-file-audio-o',
					match: /\.(wav|mp3|ogg|midi)$/i
				},
				'SPREADSHEET': {
					icon: 'fa-file-excel-o',
					match: /\.(xls|xlt)$/i
				},
				'RICHTEXT': {
					icon: 'fa-file-word-o',
					match: /\.(docx|rtf)$/i
				},
				'TEXT': {
					icon: 'fa-file-text-o',
					match: /\.(txt|md)$/i
				},
				'ARCHIVE': {
					icon: 'fa-file-archive-o',
					match: /\.(rar|zip)$/i
				},
				'IMG': {
					icon: 'fa-file-image-o',
					match: /\.(gif|jpg|jpeg|tiff|png)$/i
				},
				'CODE': {
					icon: 'fa-file-code-o',
					match: /\.(php|js|css|html|json)$/i
				},
				'FALLBACK': 'fa-file-o'
			}
		},
		myMethod: function( msg ){
			// You have direct access to the associated and cached
			// jQuery element
			console.log("myMethod triggered");
			// this.$elem.append('<p>'+msg+'</p>');
		}
	};

	/*
	 Event Methods
	 */
	function inputOnChange(e) {

	}

	function bodyOnDrop(e) {

	}

	function inputOnDrop(e) {

	}

	function inputOnDragOver(e) {

	}

	function inputOnDragLeave(e) {

	}

	/*
	 Primary Methods
	 */
	function previewImg($img, file) {
		if(!file) {
			return $img.attr('src');
		}

		var reader = new FileReader();
		reader.onload = function(e) {
			$img.attr('src', e.target.result);
		};
		return reader.readAsDataURL(file);
	}

	function previewIcon($icon, file, patterns) {

		var iconClass = _mapFileExtensionToIcon(file, patterns);
		$icon.addClass(iconClass).show();

	}

	function fileName($fileOutput, fileName) {
		if(!fileName) {
			return $fileOutput.val();
		}

		$fileOutput.val(fileName);
	}

	function setFile() {

	}

	function removeFile(e, $img, $icon, $fileInput, $fileOutput, $clearBtn) {
		e.preventDefault();

		$fileInput.wrap('<form>').closest('form').get(0).reset();
		$fileInput.unwrap();

		if($img) {
			$img.attr('src', '');
		}
		if($icon) {
			var newClass = $icon.attr('class').split(' ')[0];
			$icon.attr('class', newClass + ' fa').hide();
		}

		$clearBtn.hide();

		$fileOutput.val('');

	}

	/*
	 Helper Methods
	 */
	function _safeEval(obj) {

	}

	function _mapFileExtensionToIcon(file, patterns) {

		var iconClass = patterns['FALLBACK'];

		for(var key in patterns) {
			if(patterns.hasOwnProperty(key)) {
				if(checkFiletype(patterns[key], file.name)) {
					iconClass = patterns[key].icon;
				}
			}
		}

		return iconClass;

		function checkFiletype(filePattern, file) {
			return file.match(filePattern.match);
		}
	}

	function _fileIsImage(file) {
		return file.type.match(/image[\/\-\w]*/);
	}

	function _inputHasFile($input) {
		return $input.files[0] || false;
	}

	// Object.create support test, and fallback for browsers without it
	if ( typeof Object.create !== "function" ) {
		Object.create = function (o) {
			function F() {}
			F.prototype = o;
			return new F();
		};
	}

	// Create a plugin based on a defined object
	$.plugin = function( name, object ) {
		$.fn[name] = function( options ) {
			return this.each(function() {
				if ( ! $.data( this, name ) ) {
					$.data( this, name, Object.create(object).init(
						options, this ) );
				}
			});
		};
	};

	// Register the plugin
	$.plugin('filePicker', filePicker);

})( jQuery, window, document );
function evalDataOptions(str) {
	try {
		return eval( '(' + str + ')' )
	} catch(e) {
		throw e;
	}
}
var BREAKPOINTS = {
	xs: 480,
	sm: 768,
	md: 992,
	lg: 1200,
	xl: 1440,
	xxl: 1920
};

/**
 * Remove layout styles/classes from:
 * .core-layout, .core-layout__sidebar-wrapper and core-layout__sidebar
 * If window.innerWidth is greater than BREAKPOINTS.sm - 1
 */
function removeLayoutStyles() {
	var winWidth = window.innerWidth;

	if(winWidth > BREAKPOINTS.sm - 1) {
		$('.core-layout').removeClass('core-layout--left-open');
		$('.core-layout__sidebar-wrapper').removeAttr('style');
		$('.core-layout__sidebar').removeAttr('style');
	}
}
function leftSidebarToggleClick() {

	var LEFT_MENU_OPEN_CLASS 	= 'core-layout--left-open',
		$coreLayout 			= $('.core-layout'),
		$sidebar 				= $('.core-layout__sidebar-wrapper'),
		$content 				= $('.core-layout__sidebar');

	var isSidebarVisible = $coreLayout.hasClass('core-layout--left-open');

	isSidebarVisible ? _animateOut() : _animateIn();

	function _animateIn() {

		$sidebar.velocity({
			opacity: 1
		}, {
			duration: 200,
			display: 'block',
			complete: function() {
				$coreLayout.addClass(LEFT_MENU_OPEN_CLASS);
				$sidebar.on('click', function(e) {
					if(e.target.className !== 'core-layout__sidebar-wrapper') {
						return;
					}
					_animateOut();
				});
			}
		});

		$content.velocity({
			translateX: ['0%', '-100%']
		}, {
			duration: 200
		});
	}

	function _animateOut() {
		$sidebar.velocity({
			opacity: 0
		}, {
			duration: 200,
			display: 'none',
			complete: function() {
				$coreLayout.removeClass(LEFT_MENU_OPEN_CLASS);
			}
		});

		$content.velocity({
			translateX: '-100%'
		}, {
			duration: 200
		});
	}

}
(function($,sr){

	// debouncing function from John Hann
	// http://unscriptable.com/index.php/2009/03/20/debouncing-javascript-methods/
	var debounce = function (func, threshold, execAsap) {
		var timeout;

		return function debounced () {
			var obj = this, args = arguments;
			function delayed () {
				if (!execAsap)
					func.apply(obj, args);
				timeout = null;
			}

			if (timeout)
				clearTimeout(timeout);
			else if (execAsap)
				func.apply(obj, args);

			timeout = setTimeout(delayed, threshold || 100);
		};
	};
	// smartresize
	jQuery.fn[sr] = function(fn){  return fn ? this.bind('resize', debounce(fn)) : this.trigger(sr); };

})(jQuery,'smartresize');
// the semi-colon before function invocation is a safety net against concatenated
// scripts and/or other plugins which may not be closed properly.
;(function ( $, window, document, undefined ) {
	"use strict";
	/*
	 * ...
	 * Author: Dennis Haulund Nielsen <dhni@nodes.dk>
	 */
	var wysiwygWrapper = {
		init: function( options, elem ) {
			// Save the element reference, both as a jQuery
			// reference and a normal reference
			this.elem  = elem;
			this.$elem = $(elem);

			// Mix in the passed-in options with the default options
			this.options = $.extend( {}, this.options, options );

			this.wysiwygType = this.$elem.data('wysiwyg-type') || 'advanced';

			// Mix in the data-options with the options
			this.options = $.extend( {}, this.options, _evalDataOptions( this.$elem.data('options') ) );

			// Initialize wysiwyg plugin
			CKEDITOR.replace(this.$elem.attr('id'), this.options[this.wysiwygType]);

			// return this so that we can chain and use the bridge with less code.
			return this;

		},
		options: {
			simple: {
				format_tags: 'p;h1;h2;h3;h4;h5;h6',
				'toolbar': [
					{
						name: 'document',
						items: [ 'Source' ]
					},
					{
						name: 'clipboard',
						items: [ 'Undo', 'Redo' ]
					},
					{
						name: 'tools',
						items: [ 'Maximize', 'ShowBlocks' ]
					},
					{
						name: 'clearformat',
						items: [ 'RemoveFormat' ]
					},
					'/',
					{
						name: 'insert',
						items: [ 'Table', 'HorizontalRule']
					},
					{
						name: 'basicstyles',
						items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript' ]
					},

					{
						name: 'paragraph',
						items: [ 'NumberedList', 'BulletedList', 'Blockquote' ]
					},
					{
						name: 'links',
						items: [ 'Link', 'Unlink', 'Anchor' ]
					},
					{
						name: 'styles',
						items: [ 'Format', 'FontSize' ]
					},

				]
			},
			advanced: {
				format_tags: 'p;h1;h2;h3;h4;h5;h6;pre;address;div',
				'toolbar': [
					{
						'name': 'clipboard',
						'items': ['Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo']
					}, {
						'name': 'links',
						'items': ['Link', 'Unlink']
					}, {
						'name': 'source',
						'items': ['Source']
					}, {
						name: 'tools',
						items: [ 'Maximize', 'ShowBlocks' ]
					}, {
						name: 'clearformat',
						items: [ 'RemoveFormat' ]
					}, '/', {
						'name': 'basicstyles',
						'groups': ['basicstyles'],
						'items': ['Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript']
					}, {
						'name': 'paragraph',
						'items': ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote']
					}, {
						'name': 'elements',
						'items': ['Image', 'Table', 'HorizontalRule']
					}, {
						'name': 'styles',
						'items': ['Styles', 'Format', 'Font', 'Fontsize', 'TextColor', 'BGColor']
					}
				]
			}
		}
	};

	/*
	 Helper Methods
	 */
	function _evalDataOptions(options) {
		options = eval('(' + options + ')');
		return options;
	}

	// Object.create support test, and fallback for browsers without it
	if ( typeof Object.create !== "function" ) {
		Object.create = function (o) {
			function F() {}
			F.prototype = o;
			return new F();
		};
	}

	// Create a plugin based on a defined object
	$.plugin = function( name, object ) {
		$.fn[name] = function( options ) {
			return this.each(function() {
				if ( ! $.data( this, name ) ) {
					$.data( this, name, Object.create(object).init(
						options, this ) );
				}
			});
		};
	};

	// Register the plugin
	$.plugin('wysiwyg', wysiwygWrapper);

})( jQuery, window, document );
var Nodes = (function() {
	return {
		/**
		 * Centers an element in the middle of the view port
		 * @author  Morten Rugaard
		 * @param   element
		 * @returns void
		 */
		centerInViewport: function(element) {
			// Viewport dimensions
			var viewportWidth = $(window).width();
			var viewportHeight = $(window).height();

			// Element dimensions
			var elementWidth = element.outerWidth();
			var elementHeight = element.outerHeight();

			// Set new position for element
			element.css({
				top: ((viewportHeight - elementHeight) / 2),
				left: ((viewportWidth - elementWidth) / 2),
				position: 'relative'
			}).show();
		},

		/**
		 * Add "roll effect" to links on hover
		 * @author  Morten Rugaard
		 * @param   element
		 * @returns void
		 */
		linkEffect: function(element) {
			var linkText = element.text();
			element.html($('<span/>').data('hover', linkText).html(element.html()));
		},

		/**
		 * Select all checkboxes/radios
		 * @author  Morten Rugaard
		 * @param   element
		 * @returns void
		 */
		selectAll: function(element) {
			// Target group
			var target = element.data('target');

			// Target items
			var items = $(target).find('input[type="checkbox"],input[type="radio"]');

			// Attach click event to element
			element.click(function() {
				// Make sure our element is an input with type of either 'checkbox' or 'radio'
				// and make sure the element also have a target before continuing
				if (!element.is('input') || (element.attr('type') != 'checkbox' && element.attr('type') != 'radio') || !target) {
					return;
				}

				// Select/Deselect checkboxes or radios
				if (element.is(':checked')) {
					items.each(function() {
						$(this).prop('checked', true);
						if ($(this).attr('type') == 'radio') {
							$(this).parents('.radio').find('label').addClass('selected');
						} else {
							$(this).parents('.checkbox').find('label').addClass('selected');
						}
					});
				} else {
					items.each(function() {
						$(this).prop('checked', false);
						if ($(this).attr('type') == 'radio') {
							$(this).parents('.radio').find('label').removeClass('selected');
						} else {
							$(this).parents('.checkbox').find('label').removeClass('selected');
						}
					});
				}
			});

			// If all items in target container is checked
			// we should also mark the "trigger" as checked
			var totalChecked = $(target).find('input[type="checkbox"]:checked,input[type="radio"]:checked').length;
			if (totalChecked > 0 && totalChecked == items.length) {
				$(element).prop('checked', true).parent().find('label').addClass('selected');
			}
		},

		/**
		 * Generic confirm modal
		 * @author  Morten Rugaard
		 * @param   element
		 * @returns void
		 */
		confirmModal: function(element)
		{
			// Confirm modal title
			var modalTitle = $(element).data('confirm-title');
			modalTitle = !modalTitle ? 'Please confirm' : modalTitle;

			// Confirm modal text
			var modalText = $(element).data('confirm-text');
			modalText = !modalText ? 'Are you sure you want to do this?' : modalText;

			// Confirm modal method
			var method = $(element).data('method');
			method = !method ? 'GET' : method.toUpperCase();

			// Generate confirm modal
			var closure = function(e) {
				// Prevent default action
				e.preventDefault();

				// Build confirm modal
				bootbox.dialog({
					title: modalTitle,
					message: '<span class="fa fa-warning"></span> ' + modalText,
					className: 'nodes-confirm',
					buttons: {
						cancel: {
							label: 'Cancel',
							className: 'btn-default'
						},
						success: {
							label: 'OK',
							className: 'btn-primary',
							callback: function () {
								if ($(element).is('form')) {
									$(element).trigger('submit');
								} else if (method != 'GET') {
									// Since we're posting data, we need to add our CSRF token
									// to our form so Laravel will accept our form
									var csrfToken = $(element).data('token');
									if (!csrfToken) {
										alert('Missing CSRF token');
										console.log('Missing CSRF token');
										return;
									}

									// Generate form element
									var form = $('<form/>', {
										'method': 'POST',
										'action': $(element).attr('href')
									});

									// Add CSRF token to our form
									form.prepend(
										$('<input/>', {
											'name': '_token',
											'type': 'hidden',
											'value': csrfToken
										})
									);

									// If we're trying to submit with a "custom" method
									// we need to spoof it for Laravel
									if (method != 'POST') {
										form.prepend(
											$('<input/>', {
												'name': '_method',
												'type': 'hidden',
												'value': method
											})
										)
									}

									form.appendTo('body').submit();
								}
							}
						}
					},
					onEscape: true
				});
			};

			if ($(element).is('form')) {
				$(element).find(':submit').click(closure);
			} else {
				$(element).click(closure);
			}
		},

		/**
		 * Confirm delete modal
		 * @author  Morten Rugaard
		 * @param   element
		 * @returns void
		 */
		confirmDelete: function(element) {
			// Confirm modal title
			var modalTitle = $(element).data('delete-title');
			modalTitle = !modalTitle ? 'Please confirm' : modalTitle;

			// Confirm modal text
			var modalText = $(element).data('delete-text');
			modalText = !modalText ? 'Are you sure you want to delete?' : modalText;

			var closure = function(e) {
				// Prevent default action
				e.preventDefault();

				// Generate bootbox dialog
				bootbox.dialog({
					title: modalTitle,
					message: '<span class="fa fa-warning"></span> ' + modalText,
					className: 'nodes-delete',
					buttons: {
						cancel: {
							label: 'Cancel',
							className: 'btn-default'
						},
						success: {
							label: 'Delete',
							className: 'btn-danger',
							callback: function () {
								if ($(element).is('form')) {
									$(element).trigger('submit');
								} else {
									// Since we're posting data, we need to add our CSRF token
									// to our form so Laravel will accept our form
									var csrfToken = $(element).data('token');
									if (!csrfToken) {
										alert('Missing CSRF token');
										console.log('Missing CSRF token');
										return;
									}

									// Since <form>'s can't send a DELETE request
									// we need to "spoof" it for Laravel
									$('<form/>', {
										'method': 'POST',
										'action': $(element).attr('href')
									}).prepend(
										$('<input/>', {
											'name': '_token',
											'type': 'hidden',
											'value': csrfToken
										})
									).prepend(
										$('<input/>', {
											'name': '_method',
											'type': 'hidden',
											'value': 'DELETE'
										})
									).appendTo('body').submit();
								}
							}
						}
					},
					onEscape: true
				});
			};

			if ($(element).is('form')) {
				$(element).find(':submit').click(closure);
			} else {
				$(element).click(closure);
			}
		},

		slugifyElement: function(element) {
			// Slugify target "window"
			var target = $(element).data('slugify');
			if (!target) {
				return;
			}

			// Slugify value of element
			var slug = this.slugify($(element).val());

			// Update preview and value with slug
			if (slug) {
				$(target).find('.slugify-value').val(slug).end()
					.find('.slugify-preview').text(slug);
			} else {
				$(target).find('.slugify.value').val('').end()
					.find('.slugify-preview').text('N/A');
			}
		},

		slugify: function(text) {
			return text.toString().toLowerCase()
				.replace(/\s+/g, '-')       // Replace spaces with -
				.replace(/[^\w\-]+/g, '')   // Remove all non-word chars
				.replace(/\-\-+/g, '-')     // Replace multiple - with single -
				.replace(/^-+/, '')         // Trim - from start of text
				.replace(/-+$/, '');        // Trim - from end of text
		},

		capabilityToggleSlug: function(element) {
			element.click(function(e) {
				// Get all capabilities list
				var capabilities = $('.capabilities-list').find('.checkbox');

				// Determine action depending on state of checkbox
				if ($(this).is(':checked')) {
					capabilities.each(function() {
						// Update capability text
						var capabilitySlug = $(this).data('capability-slug');
						$(this).find('label').text(capabilitySlug);

						// Add selected state
						$(element).parent().find('label').addClass('selected');
					});
				} else {
					capabilities.each(function() {
						// Update capability text
						var capabilityTitle = $(this).data('capability-title');
						$(this).find('label').text(capabilityTitle);

						// Remove selected state
						$(element).parent().find('label').removeClass('selected');
					});
				}
			});
		},

		/**
		 * DEPRECATION WARNING:
		 * This method will be deprecated in favor of the UMD modules introduced in 1.1+
		 *
		 * If you experience ANY issue instantiating through the new API feel free to go back to the old way.
		 * Please report the bug though!
		 */
		wysiwyg: function(element) {
			$(element).wysiwyg();
			//CKEDITOR.replace(element.attr('id'));
		},

		// Set default configuration for all Chart.js charts
		defaultChartJsLineColors: {
			primary: {
				fillColor: 'rgba(118,245,168,1)',
				strokeColor: 'rgba(55,239,129,1)',
				pointColor: 'rgba(19,206,94,1)',
				pointStrokeColor: 'rgba(19,206,94,1)',
				pointHighlightFill: 'rgba(0,146,58,1)',
				pointHighlightStroke: 'rgba(0,146,58,1)'
			},
			secondary: {
				fillColor: 'rgba(99,135,150,1)',
				strokeColor: 'rgba(43,68,84,1)',
				pointColor: 'rgba(18,34,47,1)',
				pointStrokeColor: 'rgba(18,34,47,1)',
				pointHighlightFill: 'rgba(18,16,22,1)',
				pointHighlightStroke: 'rgba(18,16,22,1)'
			}
		},

		floatingLabels: function() {

			// Class naming variables
			var elementIdentifier = '.form-group.floating-label';
			var valueModifier = 'floating-label--value';
			var focusModifier = 'floating-label--focus';

			// Init "Plugin"
			_init();

			// Bind Events
			$('body').on('input propertychange', elementIdentifier, _toggleClass)
				.on('focus', elementIdentifier, _addClass)
				.on('blur', elementIdentifier, _removeClass);

			/**
			 * Toggles the Value Modifier class based on wether or not the target of the event
			 * has a .value.
			 * @param e {Event}
			 * @private
			 */
			function _toggleClass(e) {
				$(this).toggleClass(valueModifier, !!$(e.target).val());
			}

			/**
			 * Adds the Focus Modifier class to target of the event
			 * @param e {Event}
			 * @private
			 */
			function _addClass(e) {
				$(this).addClass(focusModifier);
			}

			/**
			 * Removes the Focus Modifier class to target of the event
			 * @param e {Event}
			 * @private
			 */
			function _removeClass(e) {
				$(this).removeClass(focusModifier);
			}

			/**
			 * Checks all .floating-label inputs for a value, and adds the appropriate Value Modifier class
			 * where applicable
			 * @private
			 */
			function _init() {
				$('.form-group.floating-label').each(function() {
					var el = $(this);
					var input = $(this).find('input')[0];

					if(input.value.length > 0) {
						el.addClass(valueModifier);
					}
				});
			}

		},

		alerts: {
			autoCloseDelay: 8000,
			activeAlerts: [],
			animateIn: function(element, staggerDelay) {

				$(element).delay(staggerDelay || 0).queue(function() {
					$(element).removeClass('to-be-animated-in').dequeue();
				});

				Nodes.alerts.activeAlerts.push($(element));
			},
			animateOut: function(element, staggerDelay) {
				$(element).delay(staggerDelay || 0).queue(function() {
					$(element).addClass('to-be-animated-out').dequeue();
				});
				$(element).one('transitionend webkitTransitionEnd oTransitionEnd', function() {
					$(this).remove();
				});
			}
		},
	};
})();
jQuery(document).ready(function($) {

	/**
	 * Datetime picker
	 */
	$('.date-picker').datetimepickerWrapper();

	/**
	 * File picker
	 */
	$('.file-picker').filePicker();

	/**
	 * Color picker
	 */
	$('.color-picker').colorpickerWrapper();

	/**
	 * Ace-editor
	 */
	$('.ace-editor').aceEditorWrapper();

	/**
	 * Init dropdown-menu
	 * @param el
	 */
	$('[data-dropdown]').each(function(i, el) {
		initDrop($(this));
	});

	function initDrop(el) {

		var $el = $(el);

		var $dropdownContent = $(el).parent().find('.dropdown-menu');

		var opts = evalDataOptions($el.data('options'));

		opts.target = $el[0];
		opts.content = $dropdownContent[0];

		new Drop(opts);

	}
	
	/**
	 * Layout
	 */
	$(window).smartresize(function() {
		removeLayoutStyles();
	});

	$('.core__left-sidebar-toggle').on('click', leftSidebarToggleClick);

	// Configure Chart.js globals
	Chart.defaults.global.responsive 			= true;
	Chart.defaults.global.maintainAspectRatio 	= false;

	// Initialize Floating Labels on forms
	Nodes.floatingLabels();

	// Viewport resize event
	$(window).resize(function() {
		$('.nodes-center').each(function() {
			Nodes.centerInViewport($(this));
		});
	}).resize();

	// Add "roll effect" to links
	$('a.nodes-link').each(function() {
		Nodes.linkEffect($(this));
	});

	// Tooltips
	$('[data-toggle="tooltip"]').tooltip();
	$('[data-tooltip="true"]').tooltip();

	// Popover
	$('[data-popover="true"]').each(function() {
		var trigger = $(this).data('trigger');
		$(this).popover({
			trigger: trigger ? trigger : 'click',
			html: true
		});
	});

	// Init equalheight plugin
	//rightHeight.init();

	/**
	 * Toggles .selected class for label of [type="radio"] and [type="checkbox"]
	 */
	$('.checkbox,.radio').each(function() {

		$(this).find(':radio,:checkbox').click(function() {

			var $elm	= $(this),
				checked = $elm.is(':checked'),
				type 	= $elm.attr('type'),
				label   = $elm.parents('.' + type).find('label');

			if(checked) {
				label.addClass('selected');
			} else {
				label.removeClass('selected');
			}
		})
	});

	// Select all checkbox/radio buttons
	$('.nodes-select-all[data-target]').each(function() {
		Nodes.selectAll($(this));
	});

	// Confirm dialog
	$('[data-confirm="true"]').each(function() {
		Nodes.confirmModal($(this));
	});

	// Confirm deletion dialog
	$('[data-delete="true"]').each(function() {
		Nodes.confirmDelete($(this));
	});

	// Slugify element
	$('input[type="text"][data-slugify],textarea[data-slugify]').on('input', function() {
		Nodes.slugifyElement($(this));
	});

	// WYSIWYG
	$('[data-wysiwyg="true"]').each(function() {
		Nodes.wysiwyg($(this));
	});

	//----------------------------------------------------------------
	// Roles
	//----------------------------------------------------------------
	$('#roleModal').each(function() {
		// Role modal
		var modal = $(this).modal({
			'show': false
		});

		// Default form values
		var modalDefaults = {
			'title': modal.find('.modal-title').text(),
			'action': modal.find('form').attr('action'),
			'button': modal.find('form [type="submit"]').text()
		};

		// Attach modal events
		modal.on('show.bs.modal', function(e) {
			// Event trigger
			var trigger = $(e.relatedTarget);

			// Only continue if the button clicked
			// is our 'edit role' button
			if (!trigger.hasClass('role-edit')) {
				return;
			}

			// Pre-fill form with role name
			$(this).find('.modal-title').text('Edit role').end()
				.find('form').attr('action', trigger.data('href'))
				.prepend($('<input/>', {
					'name': '_method',
					'type': 'hidden',
					'class': 'role-edit',
					'value': 'PATCH'
				}), $('<input/>', {
					'name': 'id',
					'type': 'hidden',
					'class': 'role-edit',
					'value': trigger.data('role-id')
				})).end()
				.find('#roleName').val(trigger.data('role')).end()
				.find('[type="submit"]').text('Edit role');
		}).on('hidden.bs.modal', function(e) {
			// Reset form to initial state
			$(this).find('.modal-title').text(modalDefaults.title).end()
				.find('form').attr('action', modalDefaults.action)
				.find('.role-edit').remove().end()
				.find('#roleName').val('').end()
				.find('[type="submit"]').text(modalDefaults.button);
		});
	});

	//----------------------------------------------------------------
	// Capabilities
	//----------------------------------------------------------------
	$('#rolesCapabilitiesCapabilityModal').each(function() {
		var group = $(this).find('#capabilityGroup');
		var capabilityName = $(this).find('#capabilityName');
		var capabilitySlug = $(this).find('#capabilitySlug');
		var capabilitySlugPreview = $(this).find('#capabilitySlugPreview');

		// Create re-usable callback
		var updateCapabilitySlug = function(value) {
			// Slugify capability name
			var capabilityName = Nodes.slugify(value);

			// Prepend selected group slug (if one is selected)
			var groupSlug = group.find('option:selected').data('slug');
			if (groupSlug) {
				capabilityName = groupSlug + '_' + capabilityName;
			}

			// Set generated capability slug
			if (capabilityName) {
				capabilitySlug.val(capabilityName);
				capabilitySlugPreview.text(capabilityName);
			} else {
				capabilitySlug.val('');
				capabilitySlugPreview.text('N/A');
			}
		};

		// Attach events to group and capability name
		capabilityName.on('input', function() {
			updateCapabilitySlug($(this).val())
		});
		group.on('change', function() {
			updateCapabilitySlug(capabilityName.val());
		})
	});

	$('.capabilities-wrapper').each(function() {
		var rolesCapabilities = $(this);
		$(this).find(':checkbox').click(function() {
			if (rolesCapabilities.find('.capabilities-list :checked').length > 0) {
				rolesCapabilities.find('button[type="submit"]').addClass('btn-danger').removeClass('disabled').prop('disabled', false).attr('aria-disabled', 'false');
			} else {
				rolesCapabilities.find('button[type="submit"]').removeClass('btn-danger').addClass('disabled').prop('disabled', true).attr('aria-disabled', 'true');
			}
		});
	});

	$('#capabilities-toggle-slug :checkbox').each(function() {
		Nodes.capabilityToggleSlug($(this));
	});

	/**
	 * Session-based "Alerts" / "Toasts"
	 *
	 * These alerts are inserted into the DOM from Laravel, and not inserted by JS. Still deserves some animation love.
	 * We animate them in, and fade them out again after Nodes.alerts.autoCloseDelay seconds...
	 */
	if($('.alert.to-be-animated-in').length > 0) {

		$('.alert.to-be-animated-in').each(function(i) {


			if(i > 0) {
				Nodes.alerts.animateIn($(this), 100*i, true);
			} else {
				Nodes.alerts.animateIn($(this), 0, true);
			}

		});

		setTimeout(function() {
			$( $('.alert:not(.to-be-animated-in)').get().reverse() ).each(function(i) {

				if(i > 0) {
					Nodes.alerts.animateOut($(this), 100*i, true);
				} else {
					Nodes.alerts.animateOut($(this), 0, true);
				}
			})
		}, Nodes.alerts.autoCloseDelay);
	}
});