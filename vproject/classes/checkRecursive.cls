public with sharing class checkRecursive {
	private static boolean firstRun = true;
	private static boolean secondRun = true;
    public static boolean runOnce() {
	    if (firstRun) {
	    	firstRun = false;
	    	return true;
	    } else {
	        return firstRun;
	    }
    }
    public static boolean runtwice() {
    	if (firstRun) {
	    	firstRun = false;
	    	return true;
	    } else {
	        if (secondRun) {
		    	secondRun = false;
		    	return true;
		    } else {
		        return secondRun;
		    }
	    }
    }
    
    public static void resetRun() {
    	firstRun = true;
    	secondRun = true;
    }
}