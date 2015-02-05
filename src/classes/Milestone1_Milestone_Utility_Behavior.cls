@isTest(SeeAllData=true)
public class Milestone1_Milestone_Utility_Behavior {
	
	private static Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('Closed Won' + System.now());
	private static Milestone1_Milestone__c testMilestone = new Milestone1_Milestone__c();
	private static Milestone1_Milestone__c testMilestone2 = new Milestone1_Milestone__c();
	private static Milestone1_Settings__c setting = Milestone1_Settings__c.getOrgDefaults();
	
	 static {
    	setting.Auto_Milestone_Task_Completion__c = true;
    	upsert setting;
    	
    	testProject.Kickoff__c = date.today().addDays(-5);
        testProject.Deadline__c = date.today();
        insert testProject;

        testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'Milestone 1' + System.now());
        testMilestone.Kickoff__c = date.today().addDays(-5);
        testMilestone.Deadline__c = date.today();
        insert testMilestone;
        
        testMilestone2 = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'Milestone 2' + System.now());
        testMilestone2.Kickoff__c = null;
        testMilestone2.Deadline__c = null;
        testMilestone2.Predecessor_Milestone__c = testMilestone.Id;
        insert testMilestone2;
        
	 }
	 
	 /***************************************************************************************

		shouldAllowDateShiftWhenSuccessorMilestonesDatesAreNull - Given a successor milestone 
									does not have a start or due date, WHEN the predecessor
									milestone is shifted, THEN do not modify the successor
									milestone dates.

	****************************************************************************************/
	 static testmethod void shouldAllowDateShiftWhenSuccessorMilestonesDatesAreNull(){
	 	
	 	test.startTest();
	 	testMilestone.Kickoff__c = testMilestone.Kickoff__c.addDays(5);
	 	testMilestone.Deadline__c = testMilestone.Deadline__c.addDays(5);
	 	update testMilestone;
	 	test.stopTest();
	 	
	 	testMilestone = [select id, Kickoff__c, Deadline__c from Milestone1_Milestone__c where id = :testMilestone.Id];
	 	system.assertEquals(date.today(), testMilestone.Kickoff__c);
	 	system.assertEquals(date.today().addDays(5), testMilestone.Deadline__c);
	 	
	 	testMilestone2 = [select id, Kickoff__c, Deadline__c from Milestone1_Milestone__c where id = :testMilestone2.Id];
	 	system.assertEquals(null, testMilestone2.Kickoff__c);
	 	system.assertEquals(null, testMilestone2.Deadline__c);
	 	
	 }

	/***************************************************************************************
	
	shouldMarkMilestoneComplete - Given a parent milestone, WHEN all of the child task have
								  been marked complete, THEN the milestone should be marked
								  complete as well.
	
	****************************************************************************************/
	static testmethod void shouldMarkMilestoneComplete() 
	{
		Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.id);
		Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(testMilestone.id);
		setting.Auto_Milestone_Task_Completion__c = true;
		upsert setting;
		
		testMilestone.kickoff__c = null;
		testMilestone.deadline__c = null;
		update testMilestone;
		
		task1.Start_Date__c = null;
		task1.Due_Date__c = null;
		insert task1;
		task2.Start_Date__c = null;
		task2.Due_Date__c = null;
		insert task2;
		
		task1.complete__c = true;
		task2.complete__c = true;
		
		test.startTest();
		update task1;
		update task2;
		test.stopTest();
		
		testMilestone = [SELECT complete__c FROM Milestone1_Milestone__c WHERE id = :testMilestone.id];
		
		System.assertEquals(true, testMilestone.complete__c);		
	}
	
	/***************************************************************************************
	
	shouldMarkTasksComplete - Given a milestone with tasks, WHEN the parent milestone has
							 been marked complete, THEN all child tasks should be marked
							 complete as well.
	
	****************************************************************************************/
	static testmethod void shouldMarkTasksComplete() 
	{
		Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.id);
		Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(testMilestone.id);
		setting.Auto_Milestone_Task_Completion__c = true;
		upsert setting;
		
		testMilestone.kickoff__c = null;
		testMilestone.deadline__c = null;
		update testMilestone;
		
		task1.Start_Date__c = null;
		task1.Due_Date__c = null;
		insert task1;
		task2.Start_Date__c = null;
		task2.Due_Date__c = null;
		insert task2;
		
		testMilestone.complete__c = true;
		
		test.startTest();
		update testMilestone;
		test.stopTest();
		
		task1 = [SELECT complete__c FROM Milestone1_Task__c WHERE id = :task1.id];
		task2 = [SELECT complete__c FROM Milestone1_Task__c WHERE id = :task2.id];
		
		System.assertEquals(true, task1.complete__c);
		System.assertEquals(true, task2.complete__c);
	}
	
	/***************************************************************************************
	
	shouldMarkMilestoneIncomplete - Given a parent milestone, WHEN some of its child milestones
									have been marked incomplete, THEN the milestone should be 
									marked incomplete as well.
	
	****************************************************************************************/
	
	static testmethod void shouldMarkMilestoneIncomplete() 
	{
		Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.id);
		Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(testMilestone.id);
		setting.Auto_Milestone_Task_Completion__c = true;
		upsert setting;
		
		insert task1;
		insert task2;
		
		task1.complete__c = true;
		task2.complete__c = true;
		
		update task1;
		update task2;

		testMilestone = [SELECT complete__c FROM Milestone1_Milestone__c WHERE id = :testMilestone.id];
		
		System.assertEquals(true, testMilestone.complete__c);
		
		test.starttest();
		task1.Complete__c = false;
		update task1;
		test.stopTest();
		
		testMilestone = [SELECT complete__c FROM Milestone1_Milestone__c WHERE id = :testMilestone.id];
		System.assertEquals(false, testMilestone.complete__c);
	}


	/***************************************************************************************
	
	shouldMarkMilestoneIncompleteWhenNewTaskIsAdded - Given a complete milestone that has tasks, 
													  WHEN a new task is added to the milestone, 
													  THEN the milestone should be marked incomplete.
	
	****************************************************************************************/

	static testmethod void shouldMarkMilestoneIncompleteWhenNewTaskIsAdded() 
	{
		Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.id);
		Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(testMilestone.id);
		Milestone1_Task__c task3 = Milestone1_Test_Utility.sampleTask(testMilestone.id);
		setting.Auto_Milestone_Task_Completion__c = true;
		upsert setting;
		
		insert task1;
		insert task2;
		
		task1.complete__c = true;
		task2.complete__c = true;
		
		update task1;
		update task2;

		testMilestone = [SELECT complete__c FROM Milestone1_Milestone__c WHERE id = :testMilestone.id];
		
		System.assertEquals(true, testMilestone.complete__c);
		
		test.starttest();
		insert task3;
		test.stopTest();
		
		testMilestone = [SELECT complete__c FROM Milestone1_Milestone__c WHERE id = :testMilestone.id];
		System.assertEquals(false, testMilestone.complete__c);
	}
	
	/***************************************************************************************
	
	shouldNotUpdateMilestoneIfSettingDisabled - Given the auto milestone/task completion setting is disabled, 
												WHEN a milestone or its tasks are marked as complete, 
												THEN the milestone and tasks should not be updated.
	
	****************************************************************************************/
	
	static testmethod void shouldNotUpdateMilestoneIfSettingDisabled() 
	{
		Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.id);
		Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(testMilestone.id);
		Milestone1_Task__c task3 = Milestone1_Test_Utility.sampleTask(testMilestone.id);
		setting.Auto_Milestone_Task_Completion__c = false;
		upsert setting;

		insert task1;
		insert task2;
		
		task1.complete__c = true;
		task2.complete__c = true;
		
		update task1;
		update task2;

		testMilestone = [SELECT complete__c FROM Milestone1_Milestone__c WHERE id = :testMilestone.id];
		
		System.assertEquals(false, testMilestone.complete__c);
		
		task1.complete__c = false;
		task2.complete__c = false;
		update task1;
		update task2;
		
		test.starttest();
		testMilestone.Complete__c = true;
		update testMilestone;
		test.stopTest();
		
		task1 = [SELECT complete__c FROM Milestone1_task__c WHERE id = :task1.id];
		task2 = [SELECT complete__c FROM Milestone1_task__c WHERE id = :task2.id];
		System.assertEquals(false, task1.complete__c);
		System.assertEquals(false, task2.complete__c);
	}
}