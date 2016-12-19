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