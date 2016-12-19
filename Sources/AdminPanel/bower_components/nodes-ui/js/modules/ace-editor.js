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