/*
 * Copyright (c) 2013, UC Innovation, Inc.  All Rights Reserved.
 *                     http://www.ucinnovation.com
 *
 * This source code is licensed, not sold, and is subject to a written
 * license agreement.  Among other things, no portion of this source
 * code may be copied, transmitted, disclosed, displayed, distributed,
 * translated, used as the basis for a derivative work, or used, in
 * whole or in part, for any program or purpose other than its intended
 * use in compliance with the license agreement as part of UC Innovation's
 * software.  This source code and certain of the algorithms contained
 * within it are confidential trade secrets of UC Innovation, Inc.
 * and may not be used as the basis for any other
 * software, hardware, product or service.
 */

/**
 * SerialNumberCheck. Chect the Serial Number is fullfilled or not. 
 *
 * @author              Xin Zhang
 * @version             1.0
 * @since               1.0
 */ 
public without sharing class SerialNumberCheck {

    public List<Asset> assetList {get;set;}
    public String serialNum {get;set;}
    public String selectLanguage {get;set;}
    
    /**
     * Definition of the constructor.
     * Initial all variables.
     *
     * @param      None
     * @return     None
     * @since      1.0
     */ 
    public SerialNumberCheck () {
        assetList = new List<Asset>(); 
        serialNum = ApexPages.currentPage().getParameters().get('serial-number');
        selectLanguage = ApexPages.currentPage().getParameters().get('language');
    }
   
    /**
     * The action of button Submit
     *
     * @param                   None
     * @return                  None
     * @since                   1.0
     */   
    public PageReference submit() {
    	PageReference pageRef;
    	if (serialNum == null) {
    		return null;
    	}
	    assetList = [SELECT Id, SerialNumber, Product2Id, Status FROM Asset WHERE SerialNumber =: serialNum];
	    
	    /* the serial number is not in the database */
	    if (assetList.isEmpty()) {	
	        pageRef = new PageReference('/s/SafetyNotice_Not?language='+selectLanguage);		
	    } else {
	    	
	    	/* The SerialNumber is fullfilled or not */
	    	if (assetList[0].Status == null) {
		    	pageRef = new PageReference('/s/SafetyNotice_Form?serial='+serialNum+'&language='+selectLanguage);
	    	} else if (assetList[0].Status == 'Registered') {
	    		pageRef = new PageReference('/s/SafetyNotice_Registered?language='+selectLanguage);
	    	}
		}
		return pageRef;
    } 
}