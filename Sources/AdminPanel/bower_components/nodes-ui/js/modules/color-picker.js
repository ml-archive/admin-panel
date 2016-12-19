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