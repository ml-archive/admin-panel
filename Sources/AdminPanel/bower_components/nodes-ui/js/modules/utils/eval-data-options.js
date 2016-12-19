function evalDataOptions(str) {
	try {
		return eval( '(' + str + ')' )
	} catch(e) {
		throw e;
	}
}