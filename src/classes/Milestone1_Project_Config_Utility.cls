global class Milestone1_Project_Config_Utility {
	public static integer numberOfDaysToShift {get; set;}
	public boolean workDay {get; set;}
	private static datetime saturday = (dateTime)Date.newInstance(1900, 1, 6);
	private static datetime sunday = (dateTime)Date.newInstance(1900, 1, 7);
	private static map<string, sObject> recordsToUpdate = new map<string, sObject>();
	private static list<sobject> projUpdateList = new list<sobject>();
	private static list<sobject> milestoneUpdateList = new list<sobject>();
	private static list<sobject> taskUpdateList = new list<sobject>();
	public static string projectId {get; set;}
	public static Milestone1_Project__c project {get;set;}
	
	public Milestone1_Project_Config_Utility(){
		projectId = ApexPages.CurrentPage().getparameters().get('id');
		project = [select id, ownerId from Milestone1_Project__c where id = :projectId];
		numberOfDaysToShift = 0;
		workDay = false;
		
	}
	
	public Milestone1_Project_Config_Utility(ApexPages.StandardController std){
		projectId = ApexPages.CurrentPage().getparameters().get('id');
		project = [select id, ownerId from Milestone1_Project__c where id = :projectId];
		numberOfDaysToShift = 0;
		workDay = false;
	}
	
	public void adjustProjectForWorkWeek(string projId){
		Milestone1_Project__c proj = new Milestone1_Project__c();
		list<sobject> projects = new list<sobject>();
		list<sObject> milestones = new list<sObject>();
		list<sobject> tasks = new list<sobject>();
		
		projects = [select id, Kickoff__c, Deadline__c, ownerId, Exclude_Weekend_Work__c from Milestone1_Project__c where id = :projId AND Kickoff__c != null AND Deadline__c != null];
		milestones = [select id, Kickoff__c, Deadline__c, ownerId, Predecessor_Milestone__c, Predecessor_Milestone__r.Deadline__c, project__c, project__r.Kickoff__c, Exclude_Weekend_Work__c from Milestone1_Milestone__c where Complete__c != true AND Kickoff__c != null AND Deadline__c != null ORDER BY Kickoff__c ASC, Deadline__c ASC, Predecessor_Milestone__r.Deadline__c ASC, Predecessor_Milestone__r.Kickoff__c ASC];
		tasks = [select id, Start_Date__c, Due_Date__c, Assigned_To__c, Predecessor_Task__c, Predecessor_Task__r.Due_Date__c, Project_Milestone__c, Project_Milestone__r.Kickoff__c, Exclude_Weekend_Work__c from Milestone1_Task__c where Complete__c != true AND Start_Date__c != null AND Due_Date__c != null ORDER BY Start_Date__c ASC, Due_Date__c ASC, Predecessor_Task__r.Due_Date__c ASC, Predecessor_Task__r.Start_Date__c ASC];
			
		if(projects.size() > 0){
			adjustAllRecordsForWorkDays(projects, 'project');
		}
		if(milestones.size() > 0){
			adjustAllRecordsForWorkDays(milestones, 'milestone');
		}
		if(tasks.size() > 0){
			adjustAllRecordsForWorkDays(tasks, 'task');
		}
		
/*		
		for(sObject updateRec : recordsToUpdate.values()){
			if(updateRec.getSObjectType().getDescribe().getName().contains('Milestone1_Project__c')){
			projUpdateList.add(updateRec);
			}
			else if(updateRec.getSObjectType().getDescribe().getName().contains('Milestone1_Milestone__c')){
			milestoneUpdateList.add(updateRec);
			}
			else if(updateRec.getSObjectType().getDescribe().getName().contains('Milestone1_Task__c')){
			taskUpdateList.add(updateRec);
			}
		}
		
		update projUpdateList;
		update milestoneUpdateList;
		update taskUpdateList;
*/	
	}
	
	public static void adjustAllRecordsForWorkDays(list<sObject> records, string objType){
		map<string, integer> lagPeriodMap = new map<string, integer>();
		map<string, integer> successorShiftMap = new map<string, integer>();
		string endDateField;
		date PredecessorDeadline;
		string startDateField;
		string predecessorField;
		string predecessorLookup;
		
		if(objType.equalsIgnoreCase('project')){
			endDateField = 'Deadline__c';
			startDateField = 'Kickoff__c';
		}
		if(objType.equalsIgnoreCase('milestone')){
			endDateField = 'Deadline__c';
			startDateField = 'Kickoff__c';
			predecessorField = 'Predecessor_Milestone__c';
			predecessorLookup = 'Predecessor_Milestone__r';
		}else if(objType.equalsIgnoreCase('task')){
			endDateField = 'Due_Date__c';
			startDateField = 'Start_Date__c';
			predecessorField = 'Predecessor_Task__c';
			predecessorLookup = 'Predecessor_Task__r';
		}
		
		
		
		for(sobject successor : records){
			sObject predecessor;
			if(predecessorField != null && successor.get(predecessorField) != null){
				predecessor = successor.getSObject(predecessorLookup);
				PredecessorDeadline = date.valueOf(predecessor.get(endDateField));
			}
			else if(objType.equalsIgnoreCase('task') && successor.get('Predecessor_Task__c') == null){
				predecessor = successor.getSObject('Project_Milestone__r');
				PredecessorDeadline = date.valueOf(predecessor.get('Kickoff__c'));
			}
			else if(objType.equalsIgnoreCase('milestone') && successor.get('Predecessor_Milestone__c') == null){
				predecessor = successor.getSObject('project__r');
				PredecessorDeadline = date.valueOf(predecessor.get('Kickoff__c'));
			}
			
			if(PredecessorDeadline != null){
				lagPeriodMap.put(successor.Id, PredecessorDeadline.daysBetween(date.valueOf(successor.get(startDateField))));
			}
		}
		
		for(sobject rec : records){

			if(lagPeriodMap.get(rec.Id) != null){	
				rec = adjustRecordForWorkDay(rec, lagPeriodMap.get(rec.Id), objType, date.valueOf(rec.get(startDateField)), date.valueOf(rec.get(endDateField)));
				recordsToUpdate.put((string)rec.Id, rec);
			}else{
				rec = adjustRecordForWorkDay(rec, 0, objType, date.valueOf(rec.get(startDateField)), date.valueOf(rec.get(endDateField)));
				recordsToUpdate.put((string)rec.Id, rec);
			}
			
			
		}

	}
	
	public static sobject adjustRecordForWorkDay(sobject rec, integer lag, string objType, date oldStart, date oldEnd){
		sObject predecessor;
		string endDateField;
		date PredecessorDeadline;
		string startDateField;
		string predecessorField;
		string predecessorLookup;
		integer remainingDays;
		integer initialLength;
		date newStart, newEnd, fromDate, toDate;
		sobject newRec = rec;
		
		if(objType.equalsIgnoreCase('project')){
			endDateField = 'Deadline__c';
			startDateField = 'Kickoff__c';
		}else if(objType.equalsIgnoreCase('milestone')){
			endDateField = 'Deadline__c';
			startDateField = 'Kickoff__c';
			predecessorField = 'Predecessor_Milestone__c';
			predecessorLookup = 'Predecessor_Milestone__r';
			if(rec.get(predecessorField) != null){
				predecessor = rec.getSObject(predecessorLookup);
				PredecessorDeadline = date.valueOf(predecessor.get(endDateField));
			}
			else if(recordsToUpdate.get((string)rec.get('Project__c')) != null && rec.get(predecessorField) == null){
				PredecessorDeadline = date.valueOf(recordsToUpdate.get((string)rec.get('Project__c')).get('Kickoff__c'));
			}
		}else if(objType.equalsIgnoreCase('task')){
			endDateField = 'Due_Date__c';
			startDateField = 'Start_Date__c';
			predecessorField = 'Predecessor_Task__c';
			predecessorLookup = 'Predecessor_Task__r';
			if(rec.get(predecessorField) != null){
				predecessor = rec.getSObject(predecessorLookup);
				PredecessorDeadline = date.valueOf(predecessor.get(endDateField));
			}
			else if(recordsToUpdate.get((string)rec.get('Project_Milestone__c')) != null && rec.get(predecessorField) == null){
				PredecessorDeadline = date.valueOf(recordsToUpdate.get((string)rec.get('Project_Milestone__c')).get('Kickoff__c'));
			}
		}
		
		initialLength = oldStart.daysBetween(oldEnd);
		
		if((predecessorField != null && recordsToUpdate.get((string)rec.get(predecessorField)) != null) || PredecessorDeadline != null){
			if(rec.get(predecessorField) != null && recordsToUpdate.get((string)rec.get(predecessorField)) != null){
				newStart = date.ValueOf(recordsToUpdate.get((string)rec.get(predecessorField)).get(endDateField)).addDays(lag);
			}else{
				newStart = PredecessorDeadline.addDays(lag);
			}
			newEnd = newStart.addDays(initialLength);
		}else{
			newStart = oldStart;
			newEnd = oldEnd;
		}
		
		if(isNotWorkDay((datetime)newStart)){
			//adjuct start date and endDate so start date will not land on weekend.
			integer daysToAdjust = getNumberOfNonWorkdays((datetime)newStart, (datetime)newStart.addDays(1));
			if(daysToAdjust != null && daysToAdjust > 0){
				newStart = newStart.addDays(daysToAdjust);
				newEnd = newStart.addDays(oldStart.daysBetween(oldEnd));
			}
		}
		
		if(newStart != null && newEnd != null){
			
			fromDate = newStart;
			toDate = newEnd;
			
			remainingDays = getNumberOfNonWorkDays((DateTime) fromDate, (DateTime) toDate);
						
				for(integer i = remainingDays; i > 0; i = remainingDays){
		
					fromDate = toDate.addDays(1);
					toDate = toDate.addDays(remainingDays); 

					remainingDays = getNumberOfNonWorkDays((DateTime) fromDate, (DateTime) toDate);
					
					newEnd = toDate;
				}
		}
		
		//update record with new dates
		newRec.put(startDateField, newStart);
		newRec.put(endDateField, newEnd);
		newRec.put('Exclude_Weekend_Work__c', true);
		
		return newRec;
	}
	
	public static boolean isNotWorkDay(datetime d){
		if (d.format('E') == saturday.format('E') || d.format('E') == sunday.format('E'))
        {
        	return true;
        }
        
        return false;
	}
	
	public static integer getNumberOfNonWorkdays(Datetime startDate, Datetime endDate){
		Integer nonWorkDays = 0;
		
        while (startDate <= endDate) 
        {
            if (startDate.format('E') == saturday.format('E') || startDate.format('E') == sunday.format('E'))
            {
                nonWorkDays = nonWorkDays + 1;
            }
            startDate = startDate.addDays(1);
        }
        
        return nonWorkDays;
	}
	
//////////////////////////////////////////////	
	
	public void moveAndReassignProject(string projId){
		Milestone1_Project__c proj;
		boolean updateFlg = false;
		proj = [select id, Kickoff__c, Deadline__c, ownerId, Exclude_Weekend_Work__c from Milestone1_Project__c where id = :projId AND Kickoff__c != null AND Deadline__c != null];
		
		if(numberOfDaysToShift != null && numberOfDaysToShift > 0 || numberOfDaysToShift < 0){
			proj.Kickoff__c = date.valueOf(project.Kickoff__c).addDays(numberOfDaysToShift);
			proj.Deadline__c = date.valueOf(project.Deadline__c).addDays(numberOfDaysToShift);
			updateFlg = true;
		}
		if(proj.ownerId != project.OwnerId){
			proj.ownerId = project.OwnerId;
			updateFlg = true;
		}
		if(updateFlg){
			update project;
		}
		
	}
	
	public pageReference saveProjectConfig(){
		
		projectId = ApexPages.CurrentPage().getparameters().get('id');
		project = [select id, ownerId from Milestone1_Project__c where id = :projectId];

		system.debug(logginglevel.error, projectId);		
		if(projectId != null){
			
			moveAndReassignProject(projectId);
			
			if(workDay == true){
				adjustProjectForWorkWeek(projectId);
			}
		}
		
		if(recordsToUpdate.size() > 0){
			for(sObject updateRec : recordsToUpdate.values()){
				if(updateRec.getSObjectType().getDescribe().getName().contains('Milestone1_Project__c')){
				projUpdateList.add(updateRec);
				}
				else if(updateRec.getSObjectType().getDescribe().getName().contains('Milestone1_Milestone__c')){
				milestoneUpdateList.add(updateRec);
				}
				else if(updateRec.getSObjectType().getDescribe().getName().contains('Milestone1_Task__c')){
				taskUpdateList.add(updateRec);
				}
			}
			
			update projUpdateList;
			update milestoneUpdateList;
			update taskUpdateList;
	        
        	}
        	
		PageReference projectPage = new PageReference('/' + projectId);
		projectPage.setRedirect(true);
	    return projectPage;
	}
	
	public pagereference cancel(){
		PageReference projectPage = new PageReference('/' + projectId);
		projectPage.setRedirect(true);
	    return projectPage;
	}

}