global without sharing class Milestone1_Project_Creation_Utility {
	
	global void CreateProject(Map<Id, sObject> oldMap, Map<Id, sObject> newMap, Map<string, object> params){
		string projectCreationField = (string)params.get('projectCreationField');
		string projectLookupField1 = (string)params.get('projectLookupField1');
		string projectLookupField2 = (string)params.get('projectLookupField2');
		string secondaryLookup = (string)params.get('secondaryLookup');
		string projectNamingConventionField = (string)params.get('projectNamingConventionField');
		integer daysShifted;
		
		Document projectTemplate;
		string xml;
		Milestone1_Project__c proj;
		Milestone1_XML_Import_Utility importUtil = new Milestone1_XML_Import_Utility();
		list<Milestone1_Project__c> projectsToUpdate = new list<Milestone1_Project__c>();
		boolean updateflag;
		
		for(sObject rec : newMap.values()){
			
			//deremine if project creation is required.
			if(oldMap == null && rec.get(projectCreationField) != null || (oldMap != null && rec.get(projectCreationField) != oldMap.get(rec.Id).get(projectCreationField))){
				
				string projectType = (string)rec.get(projectCreationField);
				if(projectType != null){
					projectTemplate = [select name, Id, body, contentType from Document where name =:projectType limit 1];
					
					if(projectTemplate != null){
						xml = projectTemplate.Body.toString();
						proj = importUtil.importProject(xml);
					}
					
					if(proj != null){
						updateflag = false;
						
						if(projectLookupField1 != null && proj.get(projectLookupField1) == null){
							proj.put(projectLookupField1, rec.Id);
							
							if(projectLookupField2 != null && proj.get(projectLookupField2) == null)
								proj.put(projectLookupField2, rec.get(secondaryLookup));

							updateflag = true;
						}
						
						if(projectNamingConventionField != null && rec.get(projectNamingConventionField) != null){
							system.debug(logginglevel.error, (string)rec.get(projectNamingConventionField));
							proj.Name =	(string)rec.get(projectNamingConventionField);
							updateflag = true;
						}
								
						if(proj.Kickoff__c != null && proj.Kickoff__c != date.today()){
							daysShifted = proj.Kickoff__c.daysbetween(date.today());
							
							proj.Kickoff__c = date.today();
							
							if(proj.Deadline__c != null){
								proj.Deadline__c += daysShifted;	
							}
							
							updateflag = true;
						}
						
						if(updateflag){
							projectsToUpdate.add(proj);
						}
					}
					
				}
			}
		
		}
		
		if(projectsToUpdate.size() > 0){
			update projectsToUpdate;
		}
	}

}