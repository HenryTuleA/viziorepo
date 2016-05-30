trigger CheckCaseStatus on Case (before insert) {
 if(trigger.new[0].Status =='Close'){
            trigger.new[0].RecordType.Name = 'Closed Force Unleashed'; 
     
        }      
}