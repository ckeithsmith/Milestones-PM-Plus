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
/*        
        Milestone1_Task__c task4 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        task4.Start_Date__c = Date.newInstance(1900, 1, 8);
        task4.Due_Date__c = Date.newInstance(1900, 1, 10);
        starterTasks.add(task4);
        
        Milestone1_Task__c task5 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        task5.Start_Date__c = Date.newInstance(1900, 1, 11);
        task5.Due_Date__c = Date.newInstance(1900, 1, 13);
        starterTasks.add(task5);
        
        Milestone1_Task__c task6 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        task6.Start_Date__c = Date.newInstance(1900, 1, 14);
        task6.Due_Date__c = Date.newInstance(1900, 1, 15);
        starterTasks.add(task6);
*/        
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
/*        
        Milestone1_Task__c task10 = Milestone1_Test_Utility.sampleTask(testMilestone2.Id);
        task10.Start_Date__c = date.today().addDays(-2);
        task10.Due_Date__c = date.today().addDays(-2);
        starterTasks.add(task10);
        
        Milestone1_Task__c task11 = Milestone1_Test_Utility.sampleTask(testMilestone2.Id);
        task11.Start_Date__c = date.today().addDays(-1);
        task11.Due_Date__c = date.today().addDays(-1);
        starterTasks.add(task11);

        
        Milestone1_Task__c task12 = Milestone1_Test_Utility.sampleTask(testMilestone2.Id);
        task12.Start_Date__c = date.today();
        task12.Due_Date__c = date.today();
        starterTasks.add(task12);
*/
		insert starterTasks; // single insert for all tasks
		
		task2.Predecessor_Task__c = task1.Id;
		tasksToUpdate.add(task2);
		task3.Predecessor_Task__c = task2.Id;
		tasksToUpdate.add(task3);
/*		task4.Predecessor_Task__c = task3.Id;
		tasksToUpdate.add(task4);
		task5.Predecessor_Task__c = task4.Id;
		tasksToUpdate.add(task5);
		task6.Predecessor_Task__c = task5.Id;
		tasksToUpdate.add(task6);
*/		task8.Predecessor_Task__c = task7.Id;
		tasksToUpdate.add(task8);
		task9.Predecessor_Task__c = task8.Id;
		tasksToUpdate.add(task9);
/*		task10.Predecessor_Task__c = task9.Id;
		tasksToUpdate.add(task10);
		task11.Predecessor_Task__c = task10.Id;
		tasksToUpdate.add(task11);
		task12.Predecessor_Task__c = task11.Id;
		tasksToUpdate.add(task12);
*/		
		update tasksToUpdate; // single update to map tasks to predecessors
        
    }
    
    static testmethod void shouldAdjustForWorkDays(){
    	Milestone1_Project_Config_Utility pcu = new Milestone1_Project_Config_Utility();
    	pcu.workDay = true;
    	pcu.adjustProjectForWorkWeek(testProject.Id);
    	
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
    
    

}