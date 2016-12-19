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