trigger Milestone1_Project_Trigger on Milestone1_Project__c (before update, before delete, before insert ) {
    
    if( Trigger.isUpdate ){
        Milestone1_Project_Trigger_Utility.handleProjectUpdateTrigger(trigger.new);
        Milestone1_project_Trigger_Utility.checkForDateShift(trigger.oldMap, trigger.newMap);
        Milestone1_project_Trigger_Utility.updateMilestoneOwners(trigger.oldMap, trigger.newMap);
    } 
    else if( Trigger.isDelete ) {
    	//cascades through milestones
        Milestone1_Project_Trigger_Utility.handleProjectDeleteTrigger(trigger.old);
    }
    else if( Trigger.isInsert ) {
    	//checks for duplicate names
        Milestone1_Project_Trigger_Utility.handleProjectInsertTrigger( trigger.new );
    }

}