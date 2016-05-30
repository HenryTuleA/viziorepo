public with sharing class VizioSupport_ModelComparisonController 
{
    
    //This Wrapper Class allows the table to display the information the opposite way so each column will represent a different product
    public class RowWrapper 
    {
    	// These are the values that will make a single row
    	public List<String> values { get;set; }
    	
    	public RowWrapper()
    	{
    		values = new List<String>();
    	}
    	
    	public void addValue(String value)
    	{
    		values.add(value);
    	}
    }
    

    
    private RowWrapper headings;
    private ID caseID;
    
    
    // retrieves the row wrapper containing the wrapped account headings
    public RowWrapper getHeadWrap()
    {
		// set up the headings
        if (null==headings)
        {
        	headings=new RowWrapper();
        	headings.addValue(' ');
        	
    		for (Integer idx=1; idx<=prodList.size(); idx++)
    		{
    			headings.addValue('Specs ' + idx);
    		}
        }
                                  	 
        return headings;
    }
    
    
    
    
    
    public List<product2> prodList { get; set; }
    public List<RowWrapper> rowsTable { get; set; }
    //This is the number that is coming in as an argument
    private String modelNo; 
    

	
	public VizioSupport_ModelComparisonController()
	{
		List<String> modelList = new List<String>();
		modelList.add(apexpages.currentpage().getparameters().get('model1'));
		modelList.add(apexpages.currentpage().getparameters().get('model2'));
		modelList.add(apexpages.currentpage().getparameters().get('model3'));
		
		
		prodList = 
			[
				SELECT ID, Name, Model__c, Size__c, PhysicalSizeStand__c, PhysicalSize__c, WeightStand__c, Weight__c, Resolution__c, 
					NativePanelResolution__c, BacklightType__c, ActiveLEDZones__c, DynamicContrastRatio__c, RefreshRate__c, ResponseTime__c,
					Colors__c, X3D__c, SmoothMotion__c, ClearAction__c, PIPPOP__c, HDMI__c, SharedCompAV__c, Comp__c, AV__c, StandType__c, 
					SVideo__c, CoaxRF__c, RGBVGA__c, AnalogOut__c, SPDIF__c, DigitalCoax__c, USB__c, Ethernet__c, WIFI__c, VIAVersion__c, Bluetooth__c, 
					Speakers__c, DolbyDigital__c, DTSSRS__c, CircleCinema__c, SoundStage__c, StudioSound__c, TruSurround__c, TruVolume__c,
					ARC__c, CEC__c, MediaSharing__c, Category__c, ODM__c, isActive
				FROM Product2
				WHERE Model__c IN: modelList
			];
		
		getRowWrappers();
	}
	

	
	//retrieves the list of row wrappers
	public List<RowWrapper> getRowWrappers()
	{
		//checks if there are not rows yet
		if(rowsTable == null)
		{
			rowsTable = new List<RowWrapper>();
			
			//This creates a row for each field
			for (Integer i = 0; i < 48; i++)
			{
				rowsTable.add(new RowWrapper());
			}
			
			rowsTable[0].addValue('Model');
			rowsTable[1].addValue('Size');
			rowsTable[2].addValue('Physical Size W/ Stand');
			rowsTable[3].addValue('Physical Size W/O Stand');
			rowsTable[4].addValue('Weigth W/ Stand');
			rowsTable[5].addValue('Weight W/O Stand');
			rowsTable[6].addValue('Resolution');
			rowsTable[7].addValue('Native Panel Resolution');
			rowsTable[8].addValue('Backlight Type');
			rowsTable[9].addValue('Active Led Zones');
			rowsTable[10].addValue('Dynamic Contrast Ratio');
			rowsTable[11].addValue('Refresh Rate');
			rowsTable[12].addValue('Response Time');
			rowsTable[13].addValue('Colors');
			rowsTable[14].addValue('3D');
			rowsTable[15].addValue('Smooth Motion');
			rowsTable[16].addValue('Clear Action');
			rowsTable[17].addValue('PIP/POP');
			rowsTable[18].addValue('HDMI');
			rowsTable[19].addValue('Shared Comp/AV');
			rowsTable[20].addValue('Comp');
			rowsTable[21].addValue('AV');
			rowsTable[22].addValue('Stand Type');
			rowsTable[23].addValue('SVideo');
			rowsTable[24].addValue('CoaxRF');
			rowsTable[25].addValue('RGB VGA');
			rowsTable[26].addValue('Analog Out');
			rowsTable[27].addValue('SPDIF');
			rowsTable[28].addValue('Digital Coax');
			rowsTable[29].addValue('USB');
			rowsTable[30].addValue('Ethernet');
			rowsTable[31].addValue('WIFI');
			rowsTable[32].addValue('VIA Version');
			rowsTable[33].addValue('Bluetooth');
			rowsTable[34].addValue('Speakers');
			rowsTable[35].addValue('Dolby Digital');
			rowsTable[36].addValue('DTSSRS');
			rowsTable[37].addValue('Circle Cinema');
			rowsTable[38].addValue('Sound Stage');
			rowsTable[39].addValue('Studio Sound');
			rowsTable[40].addValue('Tru Surround');
			rowsTable[41].addValue('Tru Volume');
			rowsTable[42].addValue('ARC');
			rowsTable[43].addValue('CEC');
			rowsTable[44].addValue('Media Sharing');
			rowsTable[45].addValue('Category');
			rowsTable[46].addValue('ODM');
			rowsTable[47].addValue('isActive');
			


			//iterate the accounts in order to populate the rows
			for(product2 p : prodList)
			{
				
				rowsTable[0].addValue(p.Model__c);
				rowsTable[1].addValue( String.valueOf(p.Size__c) );
				rowsTable[2].addValue( String.valueOf(p.PhysicalSizeStand__c) );
				rowsTable[3].addValue( String.valueOf(p.PhysicalSize__c) );
				rowsTable[4].addValue( String.valueOf(p.WeightStand__c) );
				rowsTable[5].addValue( String.valueOf(p.Weight__c) );
				rowsTable[6].addValue( String.valueOf(p.Resolution__c) );
				rowsTable[7].addValue( String.valueOf(p.NativePanelResolution__c) );
				rowsTable[8].addValue( String.valueOf(p.BacklightType__c) );
				rowsTable[9].addValue( String.valueOf(p.ActiveLEDZones__c) );
				rowsTable[10].addValue( String.valueOf(p.DynamicContrastRatio__c) );
				rowsTable[11].addValue( String.valueOf(p.RefreshRate__c) );
				rowsTable[12].addValue( String.valueOf(p.ResponseTime__c) );
				rowsTable[13].addValue( String.valueOf(p.Colors__c) );
				rowsTable[14].addValue( String.valueOf(p.X3D__c) );
				rowsTable[15].addValue( String.valueOf(p.SmoothMotion__c) );
				rowsTable[16].addValue( String.valueOf(p.ClearAction__c) );
				rowsTable[17].addValue( String.valueOf(p.PIPPOP__c) );
				rowsTable[18].addValue( String.valueOf(p.HDMI__c) );
				rowsTable[19].addValue( String.valueOf(p.SharedCompAV__c) );
				rowsTable[20].addValue( String.valueOf(p.Comp__c) );
				rowsTable[21].addValue( String.valueOf(p.AV__c) );
				rowsTable[22].addValue( String.valueOf(p.StandType__c) );
				rowsTable[23].addValue( String.valueOf(p.SVideo__c) );
				rowsTable[24].addValue( String.valueOf(p.CoaxRF__c) );
				rowsTable[25].addValue( String.valueOf(p.RGBVGA__c) );
				rowsTable[26].addValue( String.valueOf(p.AnalogOut__c) );
				rowsTable[27].addValue( String.valueOf(p.SPDIF__c) );
				rowsTable[28].addValue( String.valueOf(p.DigitalCoax__c) );
				rowsTable[29].addValue( String.valueOf(p.USB__c) );
				rowsTable[30].addValue( String.valueOf(p.Ethernet__c) );
				rowsTable[31].addValue( String.valueOf(p.WIFI__c) );
				rowsTable[32].addValue( String.valueOf(p.VIAVersion__c) );
				rowsTable[33].addValue( String.valueOf(p.Bluetooth__c) );
				rowsTable[34].addValue( String.valueOf(p.Speakers__c) );
				rowsTable[35].addValue( String.valueOf(p.DolbyDigital__c) );
				rowsTable[36].addValue( String.valueOf(p.DTSSRS__c) );
				rowsTable[37].addValue( String.valueOf(p.CircleCinema__c) );
				rowsTable[38].addValue( String.valueOf(p.SoundStage__c) );
				rowsTable[39].addValue( String.valueOf(p.StudioSound__c) );
				rowsTable[40].addValue( String.valueOf(p.TruSurround__c) );
				rowsTable[41].addValue( String.valueOf(p.TruVolume__c) );
				rowsTable[42].addValue( String.valueOf(p.ARC__c) );
				rowsTable[43].addValue( String.valueOf(p.CEC__c) );
				rowsTable[44].addValue( String.valueOf(p.MediaSharing__c) );
				rowsTable[45].addValue( String.valueOf(p.Category__c) );
				rowsTable[46].addValue( String.valueOf(p.ODM__c) );
				rowsTable[47].addValue( String.valueOf(p.isActive) );
				
			}
		}
		
		return rowsTable;
	}
	
	
	public PageReference goBack()
	{
		caseID = apexpages.currentpage().getparameters().get('caseID'); 
		
		PageReference pageRef = new PageReference('/apex/vizioSupport_createServiceRequest?CaseId=' + caseID);
        return pageRef; 
	}
	
}