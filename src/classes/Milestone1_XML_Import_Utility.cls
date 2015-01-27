/* 
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.
 
Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
Public with sharing class Milestone1_XML_Import_Utility {
    
   Public with sharing class XML_Metadata {
     String ExportVersion; 
     String ExportAuthor;
     String ExportPackage;
     String ExportOrganization;
     DateTime ExportCreateDate;
   }
    
    Milestone1_Project__c project;
    List<Milestone1_Milestone__c> milestones;
    List<Milestone1_Milestone__c> subMilestones;
    /**
      *Bug # 44.
      *Modified Date:04-18-2012.
      *Owner: Persistent.
      *Comments:Importing the project with all the relationships intact.
    */
    List<Milestone1_Milestone__c> successorsList;
    List<Milestone1_Task__c> tasks;
    List<Milestone1_Task__c> subTasks;
    List<Milestone1_Time__c> times;
    XML_Metadata metadata = new XML_Metadata();

    Public Milestone1_XML_Import_Utility()
    {
        project = new Milestone1_Project__c();
        milestones = new List<Milestone1_Milestone__c>();
        subMilestones = new List<Milestone1_Milestone__c>();
        /**
      	 *Bug # 44.
      	 *Modified Date:04-18-2012.
       	 *Owner: Persistent.
         *Comments:Importing the project with all the relationships intact.
        */
        successorsList=new List<Milestone1_Milestone__c>();
        tasks = new List<Milestone1_Task__c>();
        subTasks = new List<Milestone1_Task__c>();
        times = new List<Milestone1_Time__c>();
    }
    
    Public Milestone1_Project__c importProject(String xml) {

	Savepoint sp = Database.setSavepoint();
		try{
			Xmlstreamreader reader = new Xmlstreamreader(xml);
			while (reader.hasNext()) {
				if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_META) {
					parseMeta(reader);		
				}
				if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_PROJECT) {
					parseProject(reader);
				}
				reader.next();
			}
			insertSalesforceObjects();
		}catch(Exception ex){
			Database.rollback(sp);
			throw ex;
		//throw new Milestone1_Import_Exception(Milestone1_Import_Exception.ERROR_INVALID_XML);
		}
        return project;
    }

    private void insertSalesforceObjects()
    {
        if(project == null || project.Name == null || project.ImportID__c == null || project.ImportID__c.length() < 15)
        {
            throw new Milestone1_Import_Exception(system.label.Milestone1_ProjectCannotBeNull);
        }
        
        //attempt to validate 10 variations of the name
        String targetName = '%' + project.Name + '%';
        Integer existingLikeName = [Select Count() from Milestone1_Project__c where Name LIKE :targetName];
        if(existingLikeName!=null && existingLikeName > 0)
        {
            project.Name = project.Name + ' Copy ' + (existingLikeName +1);
        }
        
        insert project;
         /**
	      *Bug # 44.
	      *Modified Date:04-18-2012.
	      *Owner: Persistent.
	      *Comments:Importing the project with all the relationships intact.
    	 */
        
	        for(Milestone1_Milestone__c currentMilestone : milestones)
	        {
	        	currentMilestone.Project_Creation_Context__c = true;
	            currentMilestone.Project__c = project.Id;
	            if(currentMilestone.Predecessor_Milestone__c!=null)
	            	{
	            		successorsList.add(currentMilestone);
	            		currentMilestone.Predecessor_Milestone_Import_Id__c=currentMilestone.Predecessor_Milestone__c;
	            		currentMilestone.Predecessor_Milestone__c=null;
	            	}
	        }
        
        insert milestones;
        
        for(Milestone1_Milestone__c currentMilestone : milestones)
        {
            currentMilestone.Project__c = project.Id;
            matchMilestonesToMilestones(subMilestones,currentMilestone);
        }
        for(Milestone1_Milestone__c currentMilestone : subMilestones)
        {
        	currentMilestone.Project_Creation_Context__c = true;
       		if(currentMilestone.Predecessor_Milestone__c!=null)
	            	{
	            		successorsList.add(currentMilestone);
	            		currentMilestone.Predecessor_Milestone_Import_Id__c=currentMilestone.Predecessor_Milestone__c;
	            		currentMilestone.Predecessor_Milestone__c=null;
	            	}
        }
	    insert subMilestones;
        
        for(Milestone1_Milestone__c currentMilestone : milestones){
        	updatePredecessorMilestones(currentMilestone);
        }
        for(Milestone1_Milestone__c currentMilestone: subMilestones){
        	updatePredecessorMilestones(currentMilestone);
        }
        
		update successorsList;
        for(Milestone1_Task__c currentTask : tasks)
        {
            Boolean foundMatch = false;
            foundMatch = matchTaskToMilestone(milestones,currentTask);
            foundMatch = matchTaskToMilestone(subMilestones,currentTask);
        }
        
        for(Milestone1_Task__c currentTask : tasks)
        	{
        		currentTask.Predecessor_Task_Import_Id__c=currentTask.Predecessor_Task__c;
        		currentTask.Predecessor_Task__c=null;
        	}
        insert tasks;
        
        for(Milestone1_Task__c currentTask : tasks){
        		matchTaskToTask(currentTask);
        }
        update subtasks;
        
        for(Milestone1_Time__c currentTime : times){
         matchTimetoTask(tasks,currentTime);
        }
        
        insert times;
    }
    
    Public void updatePredecessorMilestones(Milestone1_Milestone__c currentMilestone){
    	
    	for(Milestone1_Milestone__c milestone:successorsList){
    		
    		if(milestone.Predecessor_Milestone_Import_Id__c==currentMilestone.ImportID__c)
    			{
    				milestone.Predecessor_Milestone__c=currentMilestone.Id;
    			    milestone.Project__c = currentMilestone.Project__c;
    			}
    	}
    }
    
    Public void matchMilestonesToMilestones(List<Milestone1_Milestone__c> milestones, Milestone1_Milestone__c currentMilestone){
        for(Milestone1_Milestone__c currentSubMilestone : milestones)
        {
            if(currentSubMilestone.Parent_Milestone__c == currentMilestone.ImportID__c)
            {
                currentSubMilestone.Parent_Milestone__c = currentMilestone.Id;
                currentSubMilestone.Project__c = currentMilestone.Project__c;
            }
        }
    }
    
    Public Boolean matchTaskToMilestone(List<Milestone1_Milestone__c> milestones, Milestone1_Task__c currentTask){
        for(Milestone1_Milestone__c currentMilestone : milestones){
            if(currentTask.Project_Milestone__c == currentMilestone.ImportID__c){
                currentTask.Project_Milestone__c = currentMilestone.Id;
                return true;
            }
        }
        return false;
    }
	Public void matchTaskToTask(Milestone1_Task__c currentTask){
		for(Milestone1_Task__c task:subTasks){
			 if(task.Predecessor_Task_Import_Id__c==currentTask.ImportID__c){
                 task.Predecessor_Task__c=currentTask.id;
             }
		}
	}
	Public Boolean matchTimeToTask(List<Milestone1_Task__c> tasks, Milestone1_Time__c currentTime){
	for(Milestone1_Task__c currentTask : tasks){
	if(currentTime.Project_Task__c == currentTask.ImportID__c){
	currentTime.Project_Task__c = currentTask.Id;
	return true;
	}
	}
	return false;
	}

    Public void parseProject(Xmlstreamreader reader) {
        //name goes to name
        //id goes to importid
        while (reader.hasNext()) {
            //handle name field
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Name') {
                reader.next();
                project.Name = getDecodedString(reader);
                if (project.Name.length() == 0) {
                    throw new Milestone1_Import_Exception(system.label.Milestone1_InvalidName);
                }
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Description__c') {
                reader.next();
                project.Description__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Total_Hours_Budget__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val == null || val == 'null')
                    val = '0.0';
                project.Total_Hours_Budget__c = Decimal.valueOf(val);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Total_Expense_Budget__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val == null || val == 'null')
                    val = '0.0';
                project.Total_Expense_Budget__c = Decimal.valueOf(val);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Status__c') {
                reader.next();
                project.Status__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_MILESTONE) {
                reader.next();
                parseMilestone(reader,null);
                }
            //handle import id field
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Id') {
                reader.next();
                project.ImportId__c = getDecodedString(reader);
                if (project.ImportId__c.length() > 15) {
                    project.ImportId__c = project.ImportId__c.substring(0,15);
                }
                if (project.ImportId__c.length() != 15) {
                    throw new Milestone1_Import_Exception('Invalid Import ID (length must be 15)');
                }
            }
            //import kickoff field          
			if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Kickoff__c') {
                reader.next();
                String val=getDecodedString(reader);
                if(val == null || val == 'null')
                    val= '';
                project.Kickoff__c = date.valueof(val);
            }
            //import deadline field
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Deadline__c') {
                reader.next();
                String val=getDecodedString(reader);
                if(val == null || val == 'null')
                    val= '';
                project.Deadline__c = date.valueof(val);
            }           
            //validate that we're done
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_PROJECT){
                break;
            }
            reader.next();
        }
    }
    
    Public void parseMilestone(Xmlstreamreader reader, Milestone1_Milestone__c parentMilestone)
    {
        
        Milestone1_Milestone__c currentMilestone = new Milestone1_Milestone__c();
        if(parentMilestone != null)
        {
            currentMilestone.Parent_Milestone__c = parentMilestone.ImportID__c;
        }
        currentMilestone.Project__c = project.ImportID__c;
        
        while (reader.hasNext()){
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Id') {
                reader.next();
                currentMilestone.ImportID__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Name') {
                reader.next();
                currentMilestone.Name = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Expense_Budget__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val == null || val == 'null')
                    val = '0.0';
                currentMilestone.Expense_Budget__c = Decimal.valueOf(val);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Description__c') {
                reader.next();
                currentMilestone.Description__c = getDecodedString(reader);
            }
            
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Hours_Budget__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val == null || val == 'null')
                    val = '0.0';
                currentMilestone.Hours_Budget__c = Decimal.valueOf(val);
            }
            /**
              *Bug # 44.
              *Modified Date:04-18-2012.
              *Owner: Persistent.
              *Comments:Importing the project with all the relationships intact.
            */
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Predecessor_Milestone__c'){
                reader.next();
                currentMilestone.Predecessor_Milestone__c =getDecodedString(reader);
               
             }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Kickoff__c'){
                reader.next();
                String val=getDecodedString(reader);
                if(val == null || val == 'null')
                    val= '';
                currentMilestone.Kickoff__c=date.valueOf(val);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Deadline__c'){
                reader.next();
                String val=getDecodedString(reader);
                if(val == null || val == 'null')
                    val= '';
                currentMilestone.Deadline__c=date.valueOf(val);
                
            }
          
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_MILESTONE) {
                reader.next();
                parseMilestone(reader,currentMilestone);
            }
           
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_TASK) {
                reader.next();
                parseTask(reader,currentMilestone);
            }
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_MILESTONE)
            {
                break;
            }
            reader.next();
        }
        if(parentMilestone != null)
        {
            subMilestones.add(currentMilestone);
        }else
        {
            milestones.add(currentMilestone);
        }
    }
    
    Public void parseTask(XMLStreamreader reader, Milestone1_Milestone__c currentMilestone){
        Milestone1_Task__c currentTask = new Milestone1_Task__c();
        currentTask.Project_Milestone__c = currentMilestone.ImportID__c;
        while(reader.hasNext())
        {
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Id') {
                reader.next();
                currentTask.ImportID__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Description__c') {
                reader.next();
                currentTask.Description__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Name') {
                reader.next();
                currentTask.Name = getDecodedString(reader);
                if(currentTask.Name == null){currentTask.Name = 'Name Blank';}
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Estimated_Hours__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val == null || val == 'null')
                    val = '0.0';currentTask.Estimated_Hours__c = Decimal.valueOf(val);
            }
            
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Estimated_Hours__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val == null || val == 'null')
                    val = '0.0';currentTask.Estimated_Hours__c = Decimal.valueOf(val);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Estimated_Expense__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val == null || val == 'null')
                    val = '0.0';
                currentTask.Estimated_Expense__c = Decimal.valueOf(val);
            }
            /**
              *Bug # 44.
              *Modified Date:04-18-2012.
              *Owner: Persistent.
              *Comments:Importing the project with all the relationships intact.
            */
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Predecessor_Task__c') {
                reader.next();
                currentTask.Predecessor_Task__c=getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Project_Milestone__c') {
                reader.next();
                currentTask.Project_Milestone__c=getDecodedString(reader);
            }
             if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Start_Date__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val == null || val == 'null')
                    val='';
                currentTask.Start_Date__c=date.valueOf(val);
            }
             if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Due_Date__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val == null || val == 'null')
                    val='';
                currentTask.Due_Date__c=date.valueOf(val);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_TIME) {
                reader.next();
                parseTime(reader,currentTask);
            }
            
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_TASK)
            {
                break;
            }
            reader.next();
        }
        
        if( currentTask.Predecessor_Task__c != null)
        {
             subTasks.add(currentTask);
        }
        tasks.add(currentTask);
    }
    
    Public void parseTime(XMLStreamreader reader, Milestone1_Task__c currentTask){
        Milestone1_Time__c currentTime = new Milestone1_Time__c();
        currentTime.Project_Task__c = currentTask.ImportID__c;
        while(reader.hasNext())
        {
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Id') {
                reader.next();
                currentTime.ImportID__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Description__c') {
                reader.next();
                currentTime.Description__c = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == 'Hours__c') {
                reader.next();
                String val = getDecodedString(reader);
                if(val != null || val != 'null'){
                    currentTime.Hours__c = Decimal.valueOf(val);
                }
            }
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.OBJ_NAME_TIME)
            {
                break;
            }
            reader.next();
        }
        times.add(currentTime);
    }
    
    Public void parseMeta(Xmlstreamreader reader) {
        while (reader.hasNext()) {
            //handle name field
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_VERSION) {
                reader.next();
                metadata.ExportVersion = getDecodedString(reader);
                if(metadata.ExportVersion != Milestone1_Constants.XML_EXPORT_VERSION_VAL)
                {
                    throw new Milestone1_Import_Exception(system.label.Milestone1_InvalidVersion + metadata.ExportVersion + system.label.Milestone1_OrganizationsVersion + Milestone1_Constants.XML_EXPORT_VERSION_VAL + system.label.Milestone1_ProjectsMustBeExported);
                }
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_PACKAGE) {
                reader.next();
                metadata.ExportPackage = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_AUTHOR) {
                reader.next();
                metadata.ExportAuthor = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_ORG) {
                reader.next();
                metadata.ExportOrganization = getDecodedString(reader);
            }
            if (reader.getEventType() == XMLTag.START_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_EXPORT_DATE) {
                reader.next();
                metadata.ExportCreateDate = DateTime.valueOf(getDecodedString(reader));
            }
            if(reader.getEventType() == XMLTag.END_ELEMENT && reader.getLocalName() == Milestone1_Constants.XML_META)
            {
                break;
            }
            reader.next();
        }
    }
    
    Public String getDecodedString(Xmlstreamreader reader) {
        return EncodingUtil.urlDecode(reader.getText(), 'UTF-8').trim();
    }

}