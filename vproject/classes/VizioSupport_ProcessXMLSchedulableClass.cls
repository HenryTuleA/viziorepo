/***************************************************************************
Created By : Henry Akpala
Created Date : 03/28/2016
    
    Schedulable Class that will be used to call the  Vizio_ProcessXMLSchedulableClass class
    
   
***************************************************************************/
global class VizioSupport_ProcessXMLSchedulableClass implements Schedulable
{
/*
  global static void scheduleMe(String mode)
  {
    VizioSupport_ProcessXMLSchedulableClass msc = new VizioSupport_ProcessXMLSchedulableClass();
    String sch = '0 0,30 * * * *';  
    String jobID = system.schedule('Scheduled Job', sch, msc);
  }
*/
  global void execute(SchedulableContext sc)
  {
    VizioSupport_ProcessXML.readGetFromStaticVirtualS3();
    // w = new VizioSupport_ProcessXML();
   // w.readGetFromVirtualS3();
  }
  
}