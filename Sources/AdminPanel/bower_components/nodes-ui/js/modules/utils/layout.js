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