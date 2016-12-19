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