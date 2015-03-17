@isTest
public class Milestone1_Project_Config_Behavior {
	
	private static Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('Closed Won' + System.now());
    private static Milestone1_Milestone__c testMilestone = new Milestone1_Milestone__c();
    private static Milestone1_Milestone__c testMilestone2 = new Milestone1_Milestone__c();
    private static list<Milestone1_Task__c> starterTasks = new list<Milestone1_Task__c>(); //tasks before predecessor is added
    private static list<Milestone1_Task__c> tasksToUpdate = new list<Milestone1_Task__c>(); //update tasks with predecessors
    
    static {
    		
    	testProject.Kickoff__c = Date.newInstance(1900, 1, 1);
        testProject.Deadline__c = Date.newInstance(1900, 1, 30);
        insert testProject;
		
		testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'Milestone 1' + System.now());
        testMilestone.Kickoff__c = Date.newInstance(1900, 1, 1);
        testMilestone.Deadline__c = Date.newInstance(1900, 1, 15);
        insert testMilestone;
        
        testMilestone2 = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'Milestone 2' + System.now());
        testMilestone2.Predecessor_Milestone__c = testMilestone.Id;
        testMilestone2.Kickoff__c = Date.newInstance(1900, 1, 16);
        testMilestone2.Deadline__c = Date.newInstance(1900, 1, 30);
        insert testMilestone2;
    	
    	/*testMilestone tasks*/
    	Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
    	task1.name = 'task1'; 
        task1.Start_Date__c = Date.newInstance(1900, 1, 1);
        task1.Due_Date__c = Date.newInstance(1900, 1, 5);
        starterTasks.add(task1);  
        
        Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        task2.name = 'task2';
        task2.Start_Date__c = Date.newInstance(1900, 1, 6);
        task2.Due_Date__c = Date.newInstance(1900, 1, 10);
        starterTasks.add(task2);
        
        Milestone1_Task__c task3 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        task3.name = 'task3';
        task3.Start_Date__c = Date.newInstance(1900, 1, 11);
        task3.Due_Date__c = Date.newInstance(1900, 1, 15);
        starterTasks.add(task3);
        
        /*testMilestone2 tasks*/
        Milestone1_Task__c task7 = Milestone1_Test_Utility.sampleTask(testMilestone2.Id);
        task7.name = 'task7'; 
        task7.Start_Date__c = Date.newInstance(1900, 1, 16);
        task7.Due_Date__c = Date.newInstance(1900, 1, 20);
        starterTasks.add(task7);
        
        Milestone1_Task__c task8 = Milestone1_Test_Utility.sampleTask(testMilestone2.Id);
        task8.name = 'task8';
        task8.Start_Date__c = Date.newInstance(1900, 1, 21);
        task8.Due_Date__c = Date.newInstance(1900, 1, 25);
        starterTasks.add(task8);
        
        Milestone1_Task__c task9 = Milestone1_Test_Utility.sampleTask(testMilestone2.Id);
        task9.name = 'task9';
        task9.Start_Date__c = Date.newInstance(1900, 1, 26);
        task9.Due_Date__c = Date.newInstance(1900, 1, 30);
        starterTasks.add(task9);

		insert starterTasks; // single insert for all tasks
		
		task2.Predecessor_Task__c = task1.Id;
		tasksToUpdate.add(task2);
		task3.Predecessor_Task__c = task2.Id;
		tasksToUpdate.add(task3);
		task8.Predecessor_Task__c = task7.Id;
		tasksToUpdate.add(task8);
		task9.Predecessor_Task__c = task8.Id;
		tasksToUpdate.add(task9);
		
		update tasksToUpdate; // single update to map tasks to predecessors
        
    }
    
    static testmethod void shouldAdjustForWorkDays(){
    	PageReference pageRef = Page.Milestone1_Project_Config;
    	test.setCurrentPage(pageRef);
    	ApexPages.StandardController stdCont = new ApexPages.StandardController(testProject);
    	ApexPages.currentPage().getParameters().put('Id', testProject.id);
    	Milestone1_Project_Config_Utility pcu = new Milestone1_Project_Config_Utility(stdCont);
    	pcu.workDay = true;
    	pcu.saveProjectConfig();
    	
    	testProject = [select Kickoff__c, Deadline__c from Milestone1_Project__c where id = :testProject.Id];
    	
    	system.assertEquals(Date.newInstance(1900, 1, 1), testProject.Kickoff__c);
    	system.assertEquals(Date.newInstance(1900, 2, 9), testProject.Deadline__c);
    	
    	testMilestone = [select Kickoff__c, Deadline__c from Milestone1_Milestone__c where id = :testMilestone.Id];
    	testMilestone2 = [select Kickoff__c, Deadline__c from Milestone1_Milestone__c where id = :testMilestone2.Id];
    	
    	system.assertEquals(Date.newInstance(1900, 1, 1), testMilestone.Kickoff__c);
    	system.assertEquals(Date.newInstance(1900, 1, 19), testMilestone.Deadline__c);
    	system.assertEquals(Date.newInstance(1900, 1, 22), testMilestone2.Kickoff__c);
    	system.assertEquals(Date.newInstance(1900, 2, 9), testMilestone2.Deadline__c);
    	
    	Milestone1_Task__c task1 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task1'];
    	Milestone1_Task__c task2 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task2'];
    	Milestone1_Task__c task3 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task3'];
    	Milestone1_Task__c task7 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task7'];
    	Milestone1_Task__c task8 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task8'];
    	Milestone1_Task__c task9 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task9'];
    	
    	system.assertEquals(Date.newInstance(1900, 1, 1), task1.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 5), task1.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 8), task2.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 12), task2.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 15), task3.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 19), task3.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 22), task7.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 26), task7.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 29), task8.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 2, 2), task8.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 2, 5), task9.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 2, 9), task9.Due_Date__c);
    	
    }
    
    static testmethod void shouldReassignProject(){
    	user testUser = Milestone1_Test_Utility.createSFUser();
    	
    	PageReference pageRef = Page.Milestone1_Project_Config;
    	test.setCurrentPage(pageRef);
    	ApexPages.StandardController stdCont = new ApexPages.StandardController(testProject);
    	ApexPages.currentPage().getParameters().put('Id', testProject.id);
    	Milestone1_Project_Config_Utility pcu = new Milestone1_Project_Config_Utility(stdCont);
    	
    	testProject = [select Kickoff__c, Deadline__c, ownerId from Milestone1_Project__c where id = :testProject.Id];
    	
    	system.assertEquals(UserInfo.getUserId(), testProject.OwnerId);
    	
	   	pcu.project.OwnerId = testUser.Id;
    	
    	pcu.saveProjectConfig();
    	
    	testProject = [select Kickoff__c, Deadline__c, ownerId from Milestone1_Project__c where id = :testProject.Id];
    	
    	system.assertEquals(testUser.Id, testProject.OwnerId);
    	
    }
    
    static testmethod void shouldShiftProject(){
    	PageReference pageRef = Page.Milestone1_Project_Config;
    	test.setCurrentPage(pageRef);
    	ApexPages.StandardController stdCont = new ApexPages.StandardController(testProject);
    	ApexPages.currentPage().getParameters().put('Id', testProject.id);
    	Milestone1_Project_Config_Utility pcu = new Milestone1_Project_Config_Utility(stdCont);
    	pcu.numberOfDaysToShift = 30;
    	
    	pcu.saveProjectConfig();
    	
    	testProject = [select Kickoff__c, Deadline__c from Milestone1_Project__c where id = :testProject.Id];
    	system.assertEquals(Date.newInstance(1900, 1, 1).addDays(30), testProject.Kickoff__c);
    	system.assertEquals(Date.newInstance(1900, 1, 30).addDays(30), testProject.Deadline__c);
    	
    	testMilestone = [select Kickoff__c, Deadline__c from Milestone1_Milestone__c where id = :testMilestone.Id];
    	testMilestone2 = [select Kickoff__c, Deadline__c from Milestone1_Milestone__c where id = :testMilestone2.Id];
    	
    	system.assertEquals(Date.newInstance(1900, 1, 1).addDays(30), testMilestone.Kickoff__c);
    	system.assertEquals(Date.newInstance(1900, 1, 15).addDays(30), testMilestone.Deadline__c);
    	system.assertEquals(Date.newInstance(1900, 1, 16).addDays(30), testMilestone2.Kickoff__c);
    	system.assertEquals(Date.newInstance(1900, 1, 30).addDays(30), testMilestone2.Deadline__c);
    	
    	Milestone1_Task__c task1 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task1'];
    	Milestone1_Task__c task2 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task2'];
    	Milestone1_Task__c task3 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task3'];
    	Milestone1_Task__c task7 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task7'];
    	Milestone1_Task__c task8 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task8'];
    	Milestone1_Task__c task9 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task9'];
    	
    	system.assertEquals(Date.newInstance(1900, 1, 1).addDays(30), task1.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 5).addDays(30), task1.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 6).addDays(30), task2.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 10).addDays(30), task2.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 11).addDays(30), task3.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 15).addDays(30), task3.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 16).addDays(30), task7.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 20).addDays(30), task7.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 21).addDays(30), task8.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 25).addDays(30), task8.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 26).addDays(30), task9.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 30).addDays(30), task9.Due_Date__c);
    	
    	
    }
    
    static testmethod void shouldUpdateShiftAndAdjustForWorkWeek(){
    	user testUser = Milestone1_Test_Utility.createSFUser();
    	
    	PageReference pageRef = Page.Milestone1_Project_Config;
    	test.setCurrentPage(pageRef);
    	ApexPages.StandardController stdCont = new ApexPages.StandardController(testProject);
    	ApexPages.currentPage().getParameters().put('Id', testProject.id);
    	Milestone1_Project_Config_Utility pcu = new Milestone1_Project_Config_Utility(stdCont);
    	pcu.numberOfDaysToShift = 7;
    	pcu.project.OwnerId = testUser.Id;
    	pcu.workDay = true;
    	
    	pcu.saveProjectConfig();
    	
    	testProject = [select Kickoff__c, Deadline__c, ownerId from Milestone1_Project__c where id = :testProject.Id];
    	
    	system.assertEquals(Date.newInstance(1900, 1, 1).addDays(7), testProject.Kickoff__c);
    	system.assertEquals(Date.newInstance(1900, 2, 9).addDays(7), testProject.Deadline__c);
    	system.assertEquals(testUser.Id, testProject.OwnerId);
    	
    	testMilestone = [select Kickoff__c, Deadline__c from Milestone1_Milestone__c where id = :testMilestone.Id];
    	testMilestone2 = [select Kickoff__c, Deadline__c from Milestone1_Milestone__c where id = :testMilestone2.Id];
    	
    	system.assertEquals(Date.newInstance(1900, 1, 1).addDays(7), testMilestone.Kickoff__c);
    	system.assertEquals(Date.newInstance(1900, 1, 19).addDays(7), testMilestone.Deadline__c);
    	system.assertEquals(Date.newInstance(1900, 1, 22).addDays(7), testMilestone2.Kickoff__c);
    	system.assertEquals(Date.newInstance(1900, 2, 9).addDays(7), testMilestone2.Deadline__c);
    	
    	Milestone1_Task__c task1 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task1'];
    	Milestone1_Task__c task2 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task2'];
    	Milestone1_Task__c task3 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task3'];
    	Milestone1_Task__c task7 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task7'];
    	Milestone1_Task__c task8 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task8'];
    	Milestone1_Task__c task9 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task9'];
    	
    	system.assertEquals(Date.newInstance(1900, 1, 1).addDays(7), task1.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 5).addDays(7), task1.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 8).addDays(7), task2.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 12).addDays(7), task2.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 15).addDays(7), task3.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 19).addDays(7), task3.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 22).addDays(7), task7.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 26).addDays(7), task7.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 29).addDays(7), task8.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 2, 2).addDays(7), task8.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 2, 5).addDays(7), task9.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 2, 9).addDays(7), task9.Due_Date__c);
    	
    	
    }

    static testmethod void shouldShiftProjectBackwards(){
    	PageReference pageRef = Page.Milestone1_Project_Config;
    	test.setCurrentPage(pageRef);
    	ApexPages.StandardController stdCont = new ApexPages.StandardController(testProject);
    	ApexPages.currentPage().getParameters().put('Id', testProject.id);
    	Milestone1_Project_Config_Utility pcu = new Milestone1_Project_Config_Utility(stdCont);
    	pcu.numberOfDaysToShift = -7;
    	
    	pcu.saveProjectConfig();
    	
    	testProject = [select Kickoff__c, Deadline__c from Milestone1_Project__c where id = :testProject.Id];
    	system.assertEquals(Date.newInstance(1900, 1, 1).addDays(-7), testProject.Kickoff__c);
    	system.assertEquals(Date.newInstance(1900, 1, 30).addDays(-7), testProject.Deadline__c);
    	
    	testMilestone = [select Kickoff__c, Deadline__c from Milestone1_Milestone__c where id = :testMilestone.Id];
    	testMilestone2 = [select Kickoff__c, Deadline__c from Milestone1_Milestone__c where id = :testMilestone2.Id];
    	
    	system.assertEquals(Date.newInstance(1900, 1, 1).addDays(-7), testMilestone.Kickoff__c);
    	system.assertEquals(Date.newInstance(1900, 1, 15).addDays(-7), testMilestone.Deadline__c);
    	system.assertEquals(Date.newInstance(1900, 1, 16).addDays(-7), testMilestone2.Kickoff__c);
    	system.assertEquals(Date.newInstance(1900, 1, 30).addDays(-7), testMilestone2.Deadline__c);
    	
    	Milestone1_Task__c task1 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task1'];
    	Milestone1_Task__c task2 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task2'];
    	Milestone1_Task__c task3 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task3'];
    	Milestone1_Task__c task7 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task7'];
    	Milestone1_Task__c task8 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task8'];
    	Milestone1_Task__c task9 = [select Start_Date__c, Due_Date__c FROM Milestone1_Task__c where name = 'task9'];
    	
    	system.assertEquals(Date.newInstance(1900, 1, 1).addDays(-7), task1.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 5).addDays(-7), task1.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 6).addDays(-7), task2.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 10).addDays(-7), task2.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 11).addDays(-7), task3.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 15).addDays(-7), task3.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 16).addDays(-7), task7.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 20).addDays(-7), task7.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 21).addDays(-7), task8.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 25).addDays(-7), task8.Due_Date__c);
    	
    	system.assertEquals(Date.newInstance(1900, 1, 26).addDays(-7), task9.Start_Date__c);
    	system.assertEquals(Date.newInstance(1900, 1, 30).addDays(-7), task9.Due_Date__c);
    	
    	
    }
    
    static testmethod void shouldReturnToProject(){
    	PageReference pageRef = Page.Milestone1_Project_Config;
    	test.setCurrentPage(pageRef);
    	ApexPages.StandardController stdCont = new ApexPages.StandardController(testProject);
    	ApexPages.currentPage().getParameters().put('Id', testProject.id);
    	Milestone1_Project_Config_Utility pcu = new Milestone1_Project_Config_Utility(stdCont);
    	
    	pcu.cancel();
    	
    	pageRef = ApexPages.currentPage();
    	
    	system.assertEquals((string)testProject.Id, pageRef.getParameters().get('id'));
    }
    
/************************************/    

}