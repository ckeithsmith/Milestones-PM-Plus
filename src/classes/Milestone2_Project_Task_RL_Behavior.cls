/***************************************************************

	shouldAccesFieldSet - GIVEN a project, milestones, and task exists
						  WHEN the user visits a milestone record
						  THEN the fieldset created for task should be visible

***************************************************************/

@istest(SeeAllData=true)
public class Milestone2_Project_Task_RL_Behavior {
	
	private static Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('Closed Won' + System.now());
    private static Milestone1_Milestone__c testMilestone = new Milestone1_Milestone__c();
    
    static{
    	insert testProject;
		
		testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'Milestone 1' + System.now());
        testMilestone.Kickoff__c = date.today().addDays(-5);
        testMilestone.Deadline__c = date.today();
        insert testMilestone;
        
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.Id); 
        task1.Start_Date__c = date.today().addDays(-5);
        task1.Due_Date__c = date.today().addDays(-5);   
        insert task1;
    	
    }
	
	static testmethod void ShouldAccessFieldSet(){
		ApexPages.StandardController sc = new ApexPages.StandardController(testMilestone);
        Milestone2_Project_Task_RL_Controller testController = new Milestone2_Project_Task_RL_Controller(sc);
        
        List<Schema.FieldSetMember> fieldset = testController.getFieldSetMembers();
        
        system.assert(fieldset != null, 'There is no field set');
	}

}