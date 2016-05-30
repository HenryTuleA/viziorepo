global class insertControlNumberShare implements Database.Batchable<Control_Number__Share> {
	
	public List<Control_Number__Share> listToInsert;

	global insertControlNumberShare(List<Control_Number__Share> cnsList) {
		listToInsert = cnsList;
	}
	 
	global Iterable<Control_Number__Share> start(Database.BatchableContext BC) {
		//System.debug(Logginglevel.ERROR, 'search query ' + query);
		return new insertControlNumberShareIterable(listToInsert);
	}
	 
	global void execute(Database.BatchableContext BC, List<Control_Number__Share> scope) {
		
		System.debug(Logginglevel.ERROR, 'search123 ' + scope);
		insert scope;
	}
	 
	global void finish(Database.BatchableContext BC)
	{
	              
	}
	
	global class insertControlNumberShareIterable implements Iterable<Control_Number__Share> {
        List<Control_Number__Share> listToInsert;
        
        /**
         * The class constructor which assigns the list of sobjects to insert.
         *
         * @param	sobjectList		The list of sobjects which could not be inserted due to the Mixed DML error
         * @return	None.
         * @since	1.0 
         */
        global insertControlNumberShareIterable(List<Control_Number__Share> sobjectList) {
            listToInsert = sobjectList; 
        }
        
        /**
         * This method returns a custom iterator which was built for the iterable.
         * 
         * @param	None.
         * @return	Returns a custom iterator which behaves as an iterator should.
         * @since	1.0
         */
        global Iterator<Control_Number__Share> Iterator() {
        	return new insertControlNumberShareIterator(listToInsert);
        }
     }
     
     global with sharing class insertControlNumberShareIterator implements Iterator<Control_Number__Share> {
        List<Control_Number__Share> sobjectList {get; set;}
        Integer i {get; set;}
        
        /**
         * The class constructor which sets the index to zero and assigns the list to iterate
         *
         * @param	insertList		The list of sobjects to iterate through
         * @return	None.
         * @since	1.0
         */
        public insertControlNumberShareIterator(List<Control_Number__Share> insertList) {
    		sobjectList = insertList;
        	i = 0;
        }
        
        /**
         * Returns a boolean based on whether or not there is still items left in the list of sobjects
         * that have not yet been iterated over.
         * 
         * @param	None.
         * @return	Returns true if there are still items in the list of sobjects, otherwise false. 
         * @since	1.0
         */
        global boolean hasNext() {
    		if (i >= sobjectList.size()) {
                return false;
            } else {
                return true;
            }
        }
        
        /** 
         * This method gets the next sobject to iterate over and moves the index by one.
         *
         * @param	None.
         * @return	Returns the next sobject to iterate over or null if it has reached the end.
         * @since	1.0
         */
        global Control_Number__Share next() {
        	if (i >= sobjectList.size()) {
                return null;
            }
            
            i = i + 1;
            return sobjectList[i - 1];
        }
    }
}