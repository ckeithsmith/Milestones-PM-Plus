/***************************************************************************************

shouldAllowDateShiftWhenSuccessorMilestonesDatesAreNull - Given a successor milestone 
									does not have a start or due date, WHEN the predecessor
									milestone is shifted, THEN do not modify the successor
									milestone dates.

****************************************************************************************/

@isTest 
public class Milestone1_Milestone_Utility_Behavior {
	
	private static Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('Closed Won' + System.now());
	private static Milestone1_Milestone__c testMilestone = new Milestone1_Milestone__c();
	private static Milestone1_Milestone__c testMilestone2 = new Milestone1_Milestone__c();
	
	 static {
    	
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

}