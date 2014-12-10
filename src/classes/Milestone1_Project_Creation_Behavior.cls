/*******************************************************************************************************

ShouldAutomaticallyCreateChildProject -  GIVEN an asset that needs a project,
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
    private static Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('Circuit' + System.now());
    
    static testmethod void ShouldAutomaticallyCreateChildProject(){
        Milestone1_Project__c proj = new Milestone1_Project__c();
        list<Milestone1_Milestone__c> Milestones = new list<Milestone1_Milestone__c>();
        list<Milestone1_Task__c> Tasks = new list<Milestone1_Task__c>();
        Milestone1_Project_Creation_Utility projCreationUtil = new Milestone1_Project_Creation_Utility();
        map<id, sObject> oldMap = new map<id, sObject>();
        map<id, sObject> newMap = new map<id, sObject>();
        
        testProject.Kickoff__c = date.today().addDays(-5);
        testProject.Status__c = 'Active';
        insert testProject;
        testProject = [select Id, Name from Milestone1_Project__c where Name = :testProject.Name limit 1];
         
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        insert testMilestone;
        testMilestone = [select Id, Name from Milestone1_Milestone__c where Name = :testMilestone.Name limit 1];
        
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);      
        insert task1;
        
        Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        insert task2;
                
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
        system.debug(logginglevel.error, [select Name from Opportunity where id =:opp.Id]);
        projCreationUtil.CreateChildProject(oldMap, newMap, new Map<string, object>{'projectCreationField' => 'StageName', 'projectLookupField1' => 'Opportunity__c', 'projectLookupField2' => 'Account__c', 'secondaryLookup' => 'AccountId', 'projectNamingConventionField' => 'Name'});
        test.stoptest();
        
        proj = [select id, Name from Milestone1_Project__c where Opportunity__c = :opp.Id limit 1];
        system.assert(proj != null, 'Did not insert Project');
        system.assertequals('test opp',  proj.name);
        
        milestones = [select id from Milestone1_Milestone__c where Project__c = :proj.Id];
        system.assertEquals(1, milestones.size());
        
        for(Milestone1_Milestone__c ms : milestones){
            tasks.AddAll([select id from Milestone1_Task__c where Project_Milestone__c = :ms.Id]);
        }
        system.assertEquals(2, tasks.size());
        
    
    }

    

    
    static testmethod void ShouldUpdateProjectKickoffToCurrentDate(){
        
        Milestone1_Project__c proj = new Milestone1_Project__c();
        list<Milestone1_Milestone__c> Milestones = new list<Milestone1_Milestone__c>();
        list<Milestone1_Task__c> Tasks = new list<Milestone1_Task__c>();
        Milestone1_Project_Creation_Utility projCreationUtil = new Milestone1_Project_Creation_Utility();
        map<id, sObject> oldMap = new map<id, sObject>();
        map<id, sObject> newMap = new map<id, sObject>();

        testProject.Kickoff__c = date.today().addDays(-5);
        testProject.DeadLine__c = date.today().addDays(-4);
        testProject.Status__c = 'Active';
        insert testProject;
        testProject = [select Id, Name from Milestone1_Project__c where Name = :testProject.Name limit 1];
         
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        insert testMilestone;
        testMilestone = [select Id, Name from Milestone1_Milestone__c where Name = :testMilestone.Name limit 1];
        
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);      
        insert task1;
        
        Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        insert task2;
        
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
        system.debug(logginglevel.error, [select Name from Opportunity where id =:opp.Id]);
        projCreationUtil.CreateChildProject(oldMap, newMap, new Map<string, object>{'projectCreationField' => 'StageName', 'projectLookupField1' => 'Opportunity__c', 'projectLookupField2' => 'Account__c', 'secondaryLookup' => 'AccountId', 'projectNamingConventionField' => 'Name'});
        test.stoptest();
        
        proj = [select id, Name, Kickoff__c, Deadline__c from Milestone1_Project__c where Opportunity__c = :opp.Id limit 1];
        system.assert(proj != null, 'Did not insert Project');
        system.assertequals(date.today(),  proj.KickOff__c);
        system.assertequals(date.today().adddays(1), proj.Deadline__c);


    }
    
    static testmethod void shouldCascadeForwardDateShift(){
    	
    	Milestone1_Project__c proj = new Milestone1_Project__c();
        Milestone1_Milestone__c Milestone;
        list<Milestone1_Task__c> Tasks = new list<Milestone1_Task__c>();
        Milestone1_Project_Creation_Utility projCreationUtil = new Milestone1_Project_Creation_Utility();
        map<id, sObject> oldMap = new map<id, sObject>();
        map<id, sObject> newMap = new map<id, sObject>();

        testProject.Kickoff__c = date.today().addDays(-5);
        testProject.DeadLine__c = date.today().addDays(-1);
        testProject.Status__c = 'Active';
        insert testProject;
        testProject = [select Id, Name from Milestone1_Project__c where Name = :testProject.Name limit 1];
         
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Kickoff__c = date.today().addDays(-5);
        testMilestone.Deadline__c = date.today().addDays(-2);
        insert testMilestone;
        testMilestone = [select Id, Name from Milestone1_Milestone__c where Name = :testMilestone.Name limit 1];
        
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        task1.Start_Date__c = date.today().addDays(-5);
        task1.Due_Date__c = date.today().addDays(-2);
        task1.Name = 'Task1';   
        insert task1;
        
        Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        task2.Start_Date__c = date.today().addDays(-3);
        task2.Due_Date__c = date.today().addDays(-2);
        task2.Name = 'Task2';    
        insert task2;
        
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
        system.debug(logginglevel.error, [select Name from Opportunity where id =:opp.Id]);
        projCreationUtil.CreateChildProject(oldMap, newMap, new Map<string, object>{'projectCreationField' => 'StageName', 'projectLookupField1' => 'Opportunity__c', 'projectLookupField2' => 'Account__c', 'secondaryLookup' => 'AccountId', 'projectNamingConventionField' => 'Name'});
        test.stoptest();
        
        proj = [select id, Name, Kickoff__c, Deadline__c from Milestone1_Project__c where Opportunity__c = :opp.Id limit 1];
        system.assert(proj != null, 'Did not insert Project');
        system.assertequals(date.today(),  proj.KickOff__c);
        system.assertequals(date.today().addDays(4), proj.Deadline__c);
        
        milestone = [select id, KickOff__c, Deadline__c from Milestone1_Milestone__c where Project__c = :proj.Id limit 1];
        system.assertequals(date.today(), milestone.KickOff__c);
        system.assertequals(date.today().addDays(3), milestone.Deadline__c);
        
        task1 = [select id, Start_Date__c, Due_Date__c from Milestone1_Task__c where Project_Milestone__c = :milestone.Id and name = 'Task1'];
        system.assertequals(date.today(), task1.Start_Date__c);
        system.assertequals(date.today().addDays(3), task1.Due_Date__c);
        
        task2 = [select id, Start_Date__c, Due_Date__c from Milestone1_Task__c where Project_Milestone__c = :milestone.Id and name = 'Task2'];
        system.assertequals(date.today().addDays(2), task2.Start_Date__c);
        system.assertequals(date.today().addDays(3), task2.Due_Date__c);
        
    	
    }
    
    static testmethod void shouldCascadeBackwardDateShift(){
    	
    	Milestone1_Project__c proj = new Milestone1_Project__c();
        Milestone1_Milestone__c Milestone;
        list<Milestone1_Task__c> Tasks = new list<Milestone1_Task__c>();
        Milestone1_Project_Creation_Utility projCreationUtil = new Milestone1_Project_Creation_Utility();
        map<id, sObject> oldMap = new map<id, sObject>();
        map<id, sObject> newMap = new map<id, sObject>();

        testProject.Kickoff__c = date.today().addDays(5);
        testProject.DeadLine__c = date.today().addDays(1);
        testProject.Status__c = 'Active';
        insert testProject;
        testProject = [select Id, Name from Milestone1_Project__c where Name = :testProject.Name limit 1];
         
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Kickoff__c = date.today().addDays(5);
        testMilestone.Deadline__c = date.today().addDays(2);
        insert testMilestone;
        testMilestone = [select Id, Name from Milestone1_Milestone__c where Name = :testMilestone.Name limit 1];
        
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        task1.Start_Date__c = date.today().addDays(5);
        task1.Due_Date__c = date.today().addDays(2);
        task1.Name = 'Task1';   
        insert task1;
        
        Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        task2.Start_Date__c = date.today().addDays(3);
        task2.Due_Date__c = date.today().addDays(2);
        task2.Name = 'Task2';    
        insert task2;
        
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
        system.debug(logginglevel.error, [select Name from Opportunity where id =:opp.Id]);
        projCreationUtil.CreateChildProject(oldMap, newMap, new Map<string, object>{'projectCreationField' => 'StageName', 'projectLookupField1' => 'Opportunity__c', 'projectLookupField2' => 'Account__c', 'secondaryLookup' => 'AccountId', 'projectNamingConventionField' => 'Name'});
        test.stoptest();
        
        proj = [select id, Name, Kickoff__c, Deadline__c from Milestone1_Project__c where Opportunity__c = :opp.Id limit 1];
        system.assert(proj != null, 'Did not insert Project');
        system.assertequals(date.today(),  proj.KickOff__c);
        system.assertequals(date.today().addDays(-4), proj.Deadline__c);
        
        milestone = [select id, KickOff__c, Deadline__c from Milestone1_Milestone__c where Project__c = :proj.Id limit 1];
        system.assertequals(date.today(), milestone.KickOff__c);
        system.assertequals(date.today().addDays(-3), milestone.Deadline__c);
        
        task1 = [select id, Start_Date__c, Due_Date__c from Milestone1_Task__c where Project_Milestone__c = :milestone.Id and name = 'Task1'];
        system.assertequals(date.today(), task1.Start_Date__c);
        system.assertequals(date.today().addDays(-3), task1.Due_Date__c);
        
        task2 = [select id, Start_Date__c, Due_Date__c from Milestone1_Task__c where Project_Milestone__c = :milestone.Id and name = 'Task2'];
        system.assertequals(date.today().addDays(-2), task2.Start_Date__c);
        system.assertequals(date.today().addDays(-3), task2.Due_Date__c);
        
    	
    }
    
    static testmethod void shouldImportProjectUsingDefaultTemplateNameIfTemplateNotRenamed(){
    	
    	Milestone1_Project__c proj = new Milestone1_Project__c();
        Milestone1_Milestone__c Milestone;
        list<Milestone1_Task__c> Tasks = new list<Milestone1_Task__c>();
        Milestone1_Project_Creation_Utility projCreationUtil = new Milestone1_Project_Creation_Utility();
        map<id, sObject> oldMap = new map<id, sObject>();
        map<id, sObject> newMap = new map<id, sObject>();

        testProject.Kickoff__c = date.today().addDays(5);
        testProject.DeadLine__c = date.today().addDays(1);
        testProject.Status__c = 'Active';
        testProject.Name = 'Closed Won';
        insert testProject;
        testProject = [select Id, Name from Milestone1_Project__c where Name = :testProject.Name limit 1];
         
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        testMilestone.Kickoff__c = date.today().addDays(5);
        testMilestone.Deadline__c = date.today().addDays(2);
        insert testMilestone;
        testMilestone = [select Id, Name from Milestone1_Milestone__c where Name = :testMilestone.Name limit 1];
        
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        task1.Start_Date__c = date.today().addDays(5);
        task1.Due_Date__c = date.today().addDays(2);
        task1.Name = 'Task1';   
        insert task1;
        
        Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        task2.Start_Date__c = date.today().addDays(3);
        task2.Due_Date__c = date.today().addDays(2);
        task2.Name = 'Task2';    
        insert task2;
        
        Milestone1_Export_Project_Controller controller = new Milestone1_Export_Project_Controller(new ApexPages.StandardController(testProject));
        controller.createExportXML();
        
        Document doc = [Select Name, Id, Body, ContentType From Document];
        system.debug(logginglevel.error, doc.name);
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
        system.debug(logginglevel.error, [select Name from Opportunity where id =:opp.Id]);
        projCreationUtil.CreateChildProject(oldMap, newMap, new Map<string, object>{'projectCreationField' => 'StageName', 'projectLookupField1' => 'Opportunity__c', 'projectLookupField2' => 'Account__c', 'secondaryLookup' => 'AccountId', 'projectNamingConventionField' => 'Name'});
        test.stoptest();
        
        proj = [select id, Name, Kickoff__c, Deadline__c from Milestone1_Project__c where Opportunity__c = :opp.Id limit 1];
        system.assert(proj != null, 'Did not insert Project');
        system.assertequals(date.today(),  proj.KickOff__c);
        system.assertequals(date.today().addDays(-4), proj.Deadline__c);
        
        milestone = [select id, KickOff__c, Deadline__c from Milestone1_Milestone__c where Project__c = :proj.Id limit 1];
        system.assertequals(date.today(), milestone.KickOff__c);
        system.assertequals(date.today().addDays(-3), milestone.Deadline__c);
        
        task1 = [select id, Start_Date__c, Due_Date__c from Milestone1_Task__c where Project_Milestone__c = :milestone.Id and name = 'Task1'];
        system.assertequals(date.today(), task1.Start_Date__c);
        system.assertequals(date.today().addDays(-3), task1.Due_Date__c);
        
        task2 = [select id, Start_Date__c, Due_Date__c from Milestone1_Task__c where Project_Milestone__c = :milestone.Id and name = 'Task2'];
        system.assertequals(date.today().addDays(-2), task2.Start_Date__c);
        system.assertequals(date.today().addDays(-3), task2.Due_Date__c);
        
    	
    }
    

}