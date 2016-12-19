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