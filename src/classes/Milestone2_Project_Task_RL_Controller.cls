public with sharing class Milestone2_Project_Task_RL_Controller 
{
    public list<milestone1_task__c> lstTask {get;set;}
    public String pageMode { get; set; }
    public String taskKeyPrefix {public get; private set;}
    
    private milestone1_milestone__c parentMilestone;
    
    public Milestone2_Project_Task_RL_Controller(ApexPages.StandardController controller) 
    {
        
        if(Test.isRunningTest() == false){
        	controller.addFields(new String[]{'Name'});
        }
        
        parentMilestone = (milestone1_milestone__c)controller.getRecord();
        
        this.pagemode = 'detail';
        populateTasks();
        
        taskKeyPrefix = Milestone1_Task__c.sobjectType.getDescribe().getKeyPrefix();
        
    }
    
    private void populateTasks()
    {
        string SOQL = 'SELECT  ';
        string recId =  parentMilestone.id;
        
        for(Schema.FieldSetMember eachField : this.getFieldSetMembers())
        {
            SOQL += eachField.getFieldPath() + ', ';
        }
        
        SOQL += 'Id from Milestone1_task__c where project_milestone__c = \'' + recId + '\'';        
        this.lstTask = database.query(SOQL);
    }
    
    public pageReference saveTasks() 
    {        
        update lstTask;
        
        return null;
    }

    public pageReference newTask() 
    {
        
        String strURL = URL.getSalesforceBaseUrl().toExternalForm() + 
        	'/setup/ui/recordtypeselect.jsp?ent=01Ia00000026UrL&retURL=%2F';
        
        strURL += parentMilestone.Id + '&save_new_url=%2F' + taskKeyPrefix + '%2Fe%3FCF00Na0000009in41%3D' +
        	EncodingUtil.urlEncode(parentMilestone.Name, 'UTF-8') + '%26CF00Na0000009in41_lkid%3D' +
        	parentMilestone.Id + '%26retURL%3D%252F' + parentMilestone.Id + '&top=1';
        
        PageReference pr = new PageReference(strURL);
        pr.setRedirect(true);
        
        return pr;
    }
    
    public List<Schema.FieldSetMember> getFieldSetMembers()
    {
    	Map<String, Schema.FieldSet> fieldSets = SobjectType.milestone1_task__c.FieldSets.getMap();
    	Schema.FieldSet results;
    	
    	for(String FSName : fieldSets.keySet()){
    		if(FSName.containsIgnoreCase('Task_Mass_Edit_Fields')) {
    			results = fieldSets.get(FSName);
    			break;
    		}
    	}
    	
        return results.getFields();
    }
}