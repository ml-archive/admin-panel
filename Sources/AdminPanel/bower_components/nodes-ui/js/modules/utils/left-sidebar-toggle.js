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