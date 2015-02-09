@istest
public class Milestone1_Project_Utility_Behavior {
	
private static Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('Closed Won' + System.now());
private static Milestone1_Milestone__c m1;
private static Milestone1_Milestone__c m2;
private static User user1;
private static User user2;
private static User user3;


static {
	
		user1 = Milestone1_Test_Utility.createSFUser();
		user2 = Milestone1_Test_Utility.createSFUser();
		user3 = Milestone1_Test_Utility.createSFUser();
		
    	testProject.Kickoff__c = date.today().addDays(-5);
        testProject.Deadline__c = date.today();
        testProject.OwnerId = user1.Id;
        insert testProject;
        
        m1 = Milestone1_Test_Utility.sampleMilestone(testProject);
		m2 = Milestone1_Test_Utility.sampleMilestone(testProject);
		m1.OwnerId = user2.Id;
		m1.Complete__c = false;
        insert m1;
        m2.OwnerId = user1.Id;
        m2.Complete__c = false;
		insert m2;
		
}
	
/***************************************************************************************
	
shouldUpdateMilestoneOwners - Given a project with milestones, WHEN the parent project has
							 had owner changed, THEN all incomplete, child milestones having 
							 the same old owner should be updated and with completed milestones left alone.
	
****************************************************************************************/
	static testmethod void shouldUpdateMilestoneOwners() 
	{
		
		Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(m1.id);
		Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(m2.id);
		Milestone1_Task__c task3 = Milestone1_Test_Utility.sampleTask(m2.id);
		Milestone1_Task__c task4 = Milestone1_Test_Utility.sampleTask(m2.id);

		task1.Assigned_To__c = user1.Id;
		insert task1;
		
		task2.Assigned_To__c = user1.Id;
		insert task2;
		task3.Assigned_To__c = user2.Id;
		insert task3;
		task4.Assigned_To__c = user1.Id;
		task4.Complete__c = true;
		insert task4;

		test.startTest();
		testProject.OwnerId = user3.Id;
		update testProject;
		test.stopTest();
		
		m1 = [SELECT Id, OwnerId, project__c FROM Milestone1_Milestone__c WHERE id = :m1.id];
		m2 = [SELECT Id, OwnerId, project__c FROM Milestone1_Milestone__c WHERE id = :m2.id];
		
		testproject = [SELECT OwnerId FROM Milestone1_Project__c WHERE id =: testproject.id];
		
		//Owner of m1 did not change because it was a different user
		System.assertEquals(user2.Id, m1.OwnerId);
		//owner changed for incomplete milestones having same name
		System.assertEquals(user3.Id, m2.OwnerId);
		
		task1 = [select id, assigned_to__c from Milestone1_Task__c where id = :task1.id];
		task2 = [select id, assigned_to__c from Milestone1_Task__c where id = :task2.id];
		task3 = [select id, assigned_to__c from Milestone1_Task__c where id = :task3.id];
		task4 = [select id, assigned_to__c from Milestone1_Task__c where id = :task4.id];
		
		system.assertEquals(user1.Id, task1.Assigned_To__c);
		system.assertEquals(user3.Id, task2.Assigned_To__c);
		system.assertEquals(user2.Id, task3.Assigned_To__c);
		system.assertEquals(user1.Id, task4.Assigned_To__c);

	}

}