/*******************************************************************************************************

ShouldAutomaticallyCreateChildProject -  GIVEN an object that needs a project to be created,
                                    WHEN the required fields are populated,
                                    THEN automate the project creation.
                                    
ShouldUpdateProjectKickoffToCurrentDate -   GIVEN a project has been created from a template,
                                            WHEN the project is inserted,
                                            THEN automatically set start date to today.
                                            
ShouldCascadeForwardDateShift - GIVEN an existing project,
								WHEN the project kickoff date is delayed,
								THEN cascade date shift to milestone and tasks.
								
ShouldCascadeBackwardDateShift -    GIVEN an existing project,
									WHEN the project kickoff and deadline dates are rescheduled to an earlier date,
									THEN cascade date shift to milestone and tasks.
									
ShouldAllowNonAdminUsersToCreateProjects - GIVEN an object that needs a project to be created,
										   WHEN the required fields are populated and the user triggering the automated project creation is not an admin,
										   THEN the project should successfully be created. 									

*******************************************************************************************************/


@isTest
public class Milestone1_Project_Creation_Behavior {
    
    private static Account acc = new Account(
    name = 'Test'
    );
    private static Opportunity opp = new Opportunity(
    name = 'test opp',
    StageName = 'Prospecting',
    closeDate = date.today()
    );
    private static Opportunity oldOpp = new Opportunity(
        name = 'test opp',
        StageName = 'Prospecting',
        closeDate = date.today()
        );
    private static Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('Closed Won' + System.now());
    private static Milestone1_Project__c testProject2 = Milestone1_Test_Utility.sampleProject('test2' + System.now());
    
    static {
    	
    	testProject.Kickoff__c = date.today().addDays(-5);
        testProject.Deadline__c = date.today();
        insert testProject;

         
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'Milestone 1' + System.now());
        testMilestone.Kickoff__c = date.today().addDays(-5);
        testMilestone.Deadline__c = date.today();
        insert testMilestone;
        
        Milestone1_Milestone__c testMilestone2 = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'Milestone 2' + System.now());
        testMilestone2.Kickoff__c = date.today().addDays(-5);
        testMilestone2.Deadline__c = date.today();
        insert testMilestone2;
    	
    	/*testMilestone tasks*/
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.Id); 
        task1.Start_Date__c = date.today().addDays(-5);
        task1.Due_Date__c = date.today().addDays(-5);   
        insert task1;
        
        Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        task2.Start_Date__c = date.today().addDays(-4);
        task2.Due_Date__c = date.today().addDays(-4);
        task2.Predecessor_Task__c = task1.Id;
        insert task2;
        
        Milestone1_Task__c task3 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        task3.Start_Date__c = date.today().addDays(-3);
        task3.Due_Date__c = date.today().addDays(-3);
        task3.Predecessor_Task__c = task2.Id;
        insert task3;
        
        Milestone1_Task__c task4 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        task4.Start_Date__c = date.today().addDays(-2);
        task4.Due_Date__c = date.today().addDays(-2);
        task4.Predecessor_Task__c = task3.Id;
        insert task4;
        
        Milestone1_Task__c task5 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        task5.Start_Date__c = date.today().addDays(-1);
        task5.Due_Date__c = date.today().addDays(-1);
        task5.Predecessor_Task__c = task4.Id;
        insert task5;
        
        Milestone1_Task__c task6 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        task6.Start_Date__c = date.today();
        task6.Due_Date__c = date.today();
        task6.Predecessor_Task__c = task5.Id;
        insert task6;
        
        /*testMilestone2 tasks*/
        Milestone1_Task__c task7 = Milestone1_Test_Utility.sampleTask(testMilestone2.Id); 
        task7.Start_Date__c = date.today().addDays(-5);
        task7.Due_Date__c = date.today().addDays(-5);   
        insert task7;
        
        Milestone1_Task__c task8 = Milestone1_Test_Utility.sampleTask(testMilestone2.Id);
        task8.Start_Date__c = date.today().addDays(-4);
        task8.Due_Date__c = date.today().addDays(-4);
        task8.Predecessor_Task__c = task7.Id;
        insert task8;
        
        Milestone1_Task__c task9 = Milestone1_Test_Utility.sampleTask(testMilestone2.Id);
        task9.Start_Date__c = date.today().addDays(-3);
        task9.Due_Date__c = date.today().addDays(-3);
        task9.Predecessor_Task__c = task8.Id;
        insert task9;
        
        Milestone1_Task__c task10 = Milestone1_Test_Utility.sampleTask(testMilestone2.Id);
        task10.Start_Date__c = date.today().addDays(-2);
        task10.Due_Date__c = date.today().addDays(-2);
        task10.Predecessor_Task__c = task9.Id;
        insert task10;
        
        Milestone1_Task__c task11 = Milestone1_Test_Utility.sampleTask(testMilestone2.Id);
        task11.Start_Date__c = date.today().addDays(-1);
        task11.Due_Date__c = date.today().addDays(-1);
        task11.Predecessor_Task__c = task10.Id;
        insert task11;

        
        Milestone1_Task__c task12 = Milestone1_Test_Utility.sampleTask(testMilestone2.Id);
        task12.Start_Date__c = date.today();
        task12.Due_Date__c = date.today();
        task12.Predecessor_Task__c = task11.Id;
        insert task12;
        
        
    	
    }
    
    static testmethod void ShouldAutomaticallyCreateChildProject(){
        Milestone1_Project__c proj = new Milestone1_Project__c();
        list<Milestone1_Milestone__c> Milestones = new list<Milestone1_Milestone__c>();
        list<Milestone1_Task__c> Tasks = new list<Milestone1_Task__c>();
        Milestone1_Project_Creation_Utility projCreationUtil = new Milestone1_Project_Creation_Utility();
        map<id, sObject> oldMap = new map<id, sObject>();
        map<id, sObject> newMap = new map<id, sObject>();
            
        Milestone1_Export_Project_Controller controller = new Milestone1_Export_Project_Controller(new ApexPages.StandardController(testProject));
        controller.createExportXML();
        
        Document doc = [Select Name, Id, Body, ContentType From Document];
        doc.Name = 'Closed Won';
        doc.AuthorId = UserInfo.getUserId();
        doc.FolderId = UserInfo.getUserId();
        upsert doc;
        
        insert acc; 

        opp.AccountId = acc.Id;
        insert opp;

        oldOpp.AccountId = acc.Id;
        insert oldOpp;
        oldMap = new map<id, sObject>{opp.Id => oldOpp};
                
        opp.StageName = 'Closed Won';
        update opp;
        opp = [select StageName, AccountId, Name from Opportunity where id =:opp.Id];
        newMap = new map<id, sObject>{opp.Id => opp};
        
        test.starttest();
        projCreationUtil.CreateChildProject(oldMap, newMap, new Map<string, object>{'projectCreationField' => 'StageName', 'projectLookupField1' => 'Opportunity__c', 'projectLookupField2' => 'Account__c', 'secondaryLookup' => 'AccountId', 'projectNamingConventionField' => 'Name'});
        test.stoptest();
        
        list<Milestone1_Project__c> projList = [select id, Name from Milestone1_Project__c where Opportunity__c = :opp.Id];
        system.assertequals(1, projList.Size());
        
        proj = [select id, Name, Total_Late_Task_Count__c, Total_Open_Task_Count__c, kickoff__c from Milestone1_Project__c where Opportunity__c = :opp.Id limit 1];
        system.assert(proj != null, 'Did not insert Project');
        system.assertequals('test opp',  proj.name);
        system.assertequals(date.today(), proj.kickoff__c);
        system.assertequals(12, proj.Total_Open_Task_Count__c);
        system.assertequals(0, proj.Total_Late_Task_Count__c);
        
        milestones = [select id from Milestone1_Milestone__c where Project__c = :proj.Id];
        system.assertEquals(2, milestones.size());
        
        for(Milestone1_Milestone__c ms : milestones){
            tasks.AddAll([select id from Milestone1_Task__c where Project_Milestone__c = :ms.Id and start_Date__c > :date.Today().addDays(-1)]);
        }
        system.assertEquals(12, tasks.size());
        
    
    }

    

 
    static testmethod void ShouldUpdateProjectKickoffToCurrentDate(){
        
        Milestone1_Project__c proj = new Milestone1_Project__c();
        list<Milestone1_Milestone__c> Milestones = new list<Milestone1_Milestone__c>();
        list<Milestone1_Task__c> Tasks = new list<Milestone1_Task__c>();
        Milestone1_Project_Creation_Utility projCreationUtil = new Milestone1_Project_Creation_Utility();
        map<id, sObject> oldMap = new map<id, sObject>();
        map<id, sObject> newMap = new map<id, sObject>();
        
        Milestone1_Export_Project_Controller controller = new Milestone1_Export_Project_Controller(new ApexPages.StandardController(testProject));
        controller.createExportXML();
        
        Document doc = [Select Name, Id, Body, ContentType From Document];
        doc.Name = 'Closed Won';
        doc.AuthorId = UserInfo.getUserId();
        doc.FolderId = UserInfo.getUserId();
        upsert doc; 
    
        insert acc; 

        opp.AccountId = acc.Id;
        insert opp;

        oldOpp.AccountId = acc.Id;
        insert oldOpp;
        oldMap = new map<id, sObject>{opp.Id => oldOpp};        
        
        opp.StageName = 'Closed Won';
        update opp;
        opp = [select StageName, AccountId, Name from Opportunity where id =:opp.Id];
        newMap = new map<id, sObject>{opp.Id => opp};
        
        test.starttest();
        projCreationUtil.CreateChildProject(oldMap, newMap, new Map<string, object>{'projectCreationField' => 'StageName', 'projectLookupField1' => 'Opportunity__c', 'projectLookupField2' => 'Account__c', 'secondaryLookup' => 'AccountId', 'projectNamingConventionField' => 'Name'});
        test.stoptest();
        
        list<Milestone1_Project__c> projList = [select id, Name from Milestone1_Project__c where Opportunity__c = :opp.Id];
        system.assertequals(1, projList.Size());
        
        proj = [select id, Name, Kickoff__c, Deadline__c from Milestone1_Project__c where Opportunity__c = :opp.Id limit 1];
        system.assert(proj != null, 'Did not insert Project');
        system.assertequals(date.today(),  proj.KickOff__c);
        system.assertequals(date.today().adddays(5), proj.Deadline__c);


    }
    
    static testmethod void shouldCascadeForwardDateShift(){
    	
    	Milestone1_Project__c proj = new Milestone1_Project__c();
    	list<Milestone1_Milestone__c> milestones = new list<Milestone1_Milestone__c>();
        list<Milestone1_Task__c> Tasks = new list<Milestone1_Task__c>();
        Milestone1_Project_Creation_Utility projCreationUtil = new Milestone1_Project_Creation_Utility();
        map<id, sObject> oldMap = new map<id, sObject>();
        map<id, sObject> newMap = new map<id, sObject>();
       
        Milestone1_Export_Project_Controller controller = new Milestone1_Export_Project_Controller(new ApexPages.StandardController(testProject));
        controller.createExportXML();
        
        Document doc = [Select Name, Id, Body, ContentType From Document];
        doc.Name = 'Closed Won';
        doc.AuthorId = UserInfo.getUserId();
        doc.FolderId = UserInfo.getUserId();
        upsert doc; 
    
        insert acc; 

        opp.AccountId = acc.Id;
        insert opp;

        oldOpp.AccountId = acc.Id;
        insert oldOpp;
        oldMap = new map<id, sObject>{opp.Id => oldOpp};        
        
        opp.StageName = 'Closed Won';
        update opp;
        opp = [select StageName, AccountId, Name from Opportunity where id =:opp.Id];
        newMap = new map<id, sObject>{opp.Id => opp};
        
        test.starttest();
        projCreationUtil.CreateChildProject(oldMap, newMap, new Map<string, object>{'projectCreationField' => 'StageName', 'projectLookupField1' => 'Opportunity__c', 'projectLookupField2' => 'Account__c', 'secondaryLookup' => 'AccountId', 'projectNamingConventionField' => 'Name'});
        test.stoptest();
        
        list<Milestone1_Project__c> projList = [select id, Name from Milestone1_Project__c where Opportunity__c = :opp.Id];
        system.assertequals(1, projList.Size());
        
        proj = [select id, Name, Kickoff__c, Deadline__c from Milestone1_Project__c where Opportunity__c = :opp.Id limit 1];
        system.assert(proj != null, 'Did not insert Project');
        system.assertequals(date.today(),  proj.KickOff__c);
        system.assertequals(date.today().addDays(5), proj.Deadline__c);
        
        milestones = [select id, KickOff__c, Deadline__c from Milestone1_Milestone__c where Project__c = :proj.Id];
        
        for(Milestone1_Milestone__c ms : milestones){
        system.assertequals(date.today(), ms.KickOff__c);
        system.assertequals(date.today().addDays(5), ms.Deadline__c);
        }
        
        for(Milestone1_Milestone__c ms : milestones){
            tasks.AddAll([select id from Milestone1_Task__c where Project_Milestone__c = :ms.Id and start_Date__c > :date.Today().addDays(-1)]);
        }
        system.assertEquals(12, tasks.size());
        
    	
    }
    
    static testmethod void shouldCascadeBackwardDateShift(){
    	
    	Milestone1_Project__c proj = new Milestone1_Project__c();
        list<Milestone1_Task__c> Tasks = new list<Milestone1_Task__c>();
        Milestone1_Project_Creation_Utility projCreationUtil = new Milestone1_Project_Creation_Utility();
        map<id, sObject> oldMap = new map<id, sObject>();
        map<id, sObject> newMap = new map<id, sObject>();

        testProject2.Kickoff__c = date.today().addDays(5);
        testProject2.DeadLine__c = date.today().addDays(9);
        testProject2.Status__c = 'Active';
        insert testProject2;
         
        Milestone1_Milestone__c Milestone = Milestone1_Test_Utility.sampleMilestone(testProject2.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        Milestone.Kickoff__c = date.today().addDays(5);
        Milestone.Deadline__c = date.today().addDays(8);
        insert Milestone;
        
        Milestone1_Task__c t1 = Milestone1_Test_Utility.sampleTask(Milestone.Id);
        t1.Start_Date__c = date.today().addDays(5);
        t1.Due_Date__c = date.today().addDays(8);
        t1.Name = 'Task1';   
        insert t1;
        
        Milestone1_Task__c t2 = Milestone1_Test_Utility.sampleTask(Milestone.Id);
        t2.Start_Date__c = date.today().addDays(3);
        t2.Due_Date__c = date.today().addDays(4);
        t2.Name = 'Task2';    
        insert t2;
        
        Milestone1_Export_Project_Controller controller = new Milestone1_Export_Project_Controller(new ApexPages.StandardController(testProject2));
        controller.createExportXML();
        
        Document doc = [Select Name, Id, Body, ContentType From Document];
        doc.Name = 'Closed Won';
        doc.AuthorId = UserInfo.getUserId();
        doc.FolderId = UserInfo.getUserId();
        upsert doc; 
    
        insert acc; 

        opp.AccountId = acc.Id;
        insert opp;

        oldOpp.AccountId = acc.Id;
        insert oldOpp;
        oldMap = new map<id, sObject>{opp.Id => oldOpp};        
        
        opp.StageName = 'Closed Won';
        update opp;
        opp = [select StageName, AccountId, Name from Opportunity where id =:opp.Id];
        newMap = new map<id, sObject>{opp.Id => opp};
        
        test.starttest();
        projCreationUtil.CreateChildProject(oldMap, newMap, new Map<string, object>{'projectCreationField' => 'StageName', 'projectLookupField1' => 'Opportunity__c', 'projectLookupField2' => 'Account__c', 'secondaryLookup' => 'AccountId', 'projectNamingConventionField' => 'Name'});
        test.stoptest();
        
        list<Milestone1_Project__c> projList = [select id, Name from Milestone1_Project__c where Opportunity__c = :opp.Id];
        system.assertequals(1, projList.Size());
        
        proj = [select id, Name, Kickoff__c, Deadline__c from Milestone1_Project__c where Opportunity__c = :opp.Id limit 1];
        system.assert(proj != null, 'Did not insert Project');
        system.assertequals(date.today(),  proj.KickOff__c);
        system.assertequals(date.today().addDays(4), proj.Deadline__c);
        
        milestone = [select id, KickOff__c, Deadline__c from Milestone1_Milestone__c where Project__c = :proj.Id limit 1];
        system.assertequals(date.today(), milestone.KickOff__c);
        system.assertequals(date.today().addDays(3), milestone.Deadline__c);
        
        t1 = [select id, Start_Date__c, Due_Date__c from Milestone1_Task__c where Project_Milestone__c = :milestone.Id and name = 'Task1'];
        system.assertequals(date.today(), t1.Start_Date__c);
        system.assertequals(date.today().addDays(3), t1.Due_Date__c);
        
        t2 = [select id, Start_Date__c, Due_Date__c from Milestone1_Task__c where Project_Milestone__c = :milestone.Id and name = 'Task2'];
        system.assertequals(date.today().addDays(-2), t2.Start_Date__c);
        system.assertequals(date.today().addDays(-1), t2.Due_Date__c);
        
        
        
    	
    }
    
    static testmethod void shouldImportProjectUsingDefaultTemplateNameIfTemplateNotRenamed(){
    	
    	Milestone1_Project__c proj = new Milestone1_Project__c();
    	list<Milestone1_Milestone__c> milestones = new list<Milestone1_Milestone__c>();
        list<Milestone1_Task__c> Tasks = new list<Milestone1_Task__c>();
        Milestone1_Project_Creation_Utility projCreationUtil = new Milestone1_Project_Creation_Utility();
        map<id, sObject> oldMap = new map<id, sObject>();
        map<id, sObject> newMap = new map<id, sObject>();
      
        Milestone1_Export_Project_Controller controller = new Milestone1_Export_Project_Controller(new ApexPages.StandardController(testProject));
        controller.createExportXML();
        
        Document doc = [Select Name, Id, Body, ContentType From Document];
        doc.AuthorId = UserInfo.getUserId();
        doc.FolderId = UserInfo.getUserId();
        upsert doc; 
    
        insert acc; 

        opp.AccountId = acc.Id;
        insert opp;

        oldOpp.AccountId = acc.Id;
        insert oldOpp;
        oldMap = new map<id, sObject>{opp.Id => oldOpp};        
        
        opp.StageName = 'Closed Won';
        update opp;
        opp = [select StageName, AccountId, Name from Opportunity where id =:opp.Id];
        newMap = new map<id, sObject>{opp.Id => opp};
        
        test.starttest();
        projCreationUtil.CreateChildProject(oldMap, newMap, new Map<string, object>{'projectCreationField' => 'StageName', 'projectLookupField1' => 'Opportunity__c', 'projectLookupField2' => 'Account__c', 'secondaryLookup' => 'AccountId', 'projectNamingConventionField' => 'Name'});
        test.stoptest();
        
        list<Milestone1_Project__c> projList = [select id, Name from Milestone1_Project__c where Opportunity__c = :opp.Id];
        system.assertequals(1, projList.Size());
        
        proj = [select id, Name, Total_Late_Task_Count__c, Total_Open_Task_Count__c, kickoff__c from Milestone1_Project__c where Opportunity__c = :opp.Id limit 1];
        system.assert(proj != null, 'Did not insert Project');
        system.assertequals('test opp',  proj.name);
        system.assertequals(date.today(), proj.kickoff__c);
        system.assertequals(12, proj.Total_Open_Task_Count__c);
        system.assertequals(0, proj.Total_Late_Task_Count__c);
        
        milestones = [select id from Milestone1_Milestone__c where Project__c = :proj.Id];
        system.assertEquals(2, milestones.size());
        
        for(Milestone1_Milestone__c ms : milestones){
            tasks.AddAll([select id from Milestone1_Task__c where Project_Milestone__c = :ms.Id and start_Date__c > :date.Today().addDays(-1)]);
        }
        system.assertEquals(12, tasks.size());
        
    	
    }
    
    static testmethod void shouldAllowNonAdminsToCreateProjects(){
    	
    	Profile profileUsed;
		User userObj;
		if(!Milestone1_Schema_Helper.isOrgChatterEnabled())
		return; //chatter is disabled - we can't run this test.
		
		//Setup project information
		Milestone1_Project__c proj = new Milestone1_Project__c();
        list<Milestone1_Milestone__c> Milestones = new list<Milestone1_Milestone__c>();
        list<Milestone1_Task__c> Tasks = new list<Milestone1_Task__c>();
        Milestone1_Project_Creation_Utility projCreationUtil = new Milestone1_Project_Creation_Utility();
        map<id, sObject> oldMap = new map<id, sObject>();
        map<id, sObject> newMap = new map<id, sObject>();
        
        Milestone1_Export_Project_Controller controller = new Milestone1_Export_Project_Controller(new ApexPages.StandardController(testProject));
        controller.createExportXML();
        
        Document doc = [Select Name, Id, Body, ContentType From Document];
        doc.AuthorId = UserInfo.getUserId();
        doc.FolderId = UserInfo.getUserId();
        upsert doc; 
    
        insert acc; 

        opp.AccountId = acc.Id;
        insert opp;

        oldOpp.AccountId = acc.Id;
        insert oldOpp;
        oldMap = new map<id, sObject>{opp.Id => oldOpp};        
        
        opp.StageName = 'Closed Won';
        update opp;
        opp = [select StageName, AccountId, Name from Opportunity where id =:opp.Id];
        newMap = new map<id, sObject>{opp.Id => opp};

		//Create a non-admin user
		for( Profile p : [ Select Id, PermissionsViewAllData, Name from Profile
						   where userLicense.licenseDefinitionKey = 'SFDC'
						   AND PermissionsViewAllData = false
						   AND PermissionsModifyAllData = false] ){
			profileUsed = p;
			break;
		}
		
		userObj = Milestone1_Test_Utility.createSFUser(profileUsed);
		system.debug('user Id for test ' + userObj.Id);
		
		Test.startTest();
		System.runAs(userObj) {

        	projCreationUtil.CreateChildProject(oldMap, newMap, new Map<string, object>{'projectCreationField' => 'StageName', 'projectLookupField1' => 'Opportunity__c', 'projectLookupField2' => 'Account__c', 'secondaryLookup' => 'AccountId', 'projectNamingConventionField' => 'Name'});
	
		}
		test.stopTest();
		
		list<Milestone1_Project__c> projList = [select id, Name from Milestone1_Project__c where Opportunity__c = :opp.Id];
        system.assertequals(1, projList.Size());
        
        proj = [select id, Name, Kickoff__c, Deadline__c from Milestone1_Project__c where Opportunity__c = :opp.Id limit 1];
        system.assert(proj != null, 'Did not insert Project');
        system.assertequals(date.today(),  proj.KickOff__c);
        system.assertequals(date.today().addDays(5), proj.Deadline__c);
        
        milestones = [select id, KickOff__c, Deadline__c from Milestone1_Milestone__c where Project__c = :proj.Id];
        for(Milestone1_Milestone__c ms : milestones){
        system.assertequals(date.today(), ms.KickOff__c);
        system.assertequals(date.today().addDays(5), ms.Deadline__c);
        }
        
        for(Milestone1_Milestone__c ms : milestones){
            tasks.AddAll([select id from Milestone1_Task__c where Project_Milestone__c = :ms.Id and start_Date__c > :date.Today().addDays(-1)]);
        }
        system.assertEquals(12, tasks.size());
        
    }
    
/****************************************/

}