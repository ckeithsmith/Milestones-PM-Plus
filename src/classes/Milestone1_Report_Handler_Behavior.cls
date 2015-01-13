@isTest(SeeAllData=true)
public class Milestone1_Report_Handler_Behavior {

    static testmethod void ShouldLoadProjectReport() {
    	Milestone1_Settings__c MPMSettings = Milestone1_Settings__c.getOrgDefaults();
 
        // Get a report to work with
        List<Report> reports = [
            select Id, DeveloperName
            from Report where DeveloperName = 'Project_Report' and name = 'Project Report'
            limit 1
        ];
        
        //create test proj
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('test' + System.now());
        insert proj;
        
        //if custom setting holding project report is not blank.
        if(MPMSettings.Report_Id_Project_Report__c != null){
        	
        	// Load up our Visualforce Page
            PageReference p = System.Page.Milestone1_Project_report;
            p.getParameters().put('pv0', proj.Id);
            Test.setCurrentPage(p);
            
            // Load up our Controller
            Milestone1_Report_Handler ctl = new Milestone1_Report_Handler();
 
            // Manually call the redirect() action,
            // and store the page that we are returned
            PageReference ret = ctl.redirectToProjectReport();
 
            // We should be sent to the View page for our Report
            System.assert(ret.getURL().contains('/' + MPMSettings.Report_Id_Project_Report__c));
            // Also, make sure that our Filter Criterion values
            // got passed along
            System.assert(ret.getURL().contains('pv0=' + proj.Id));
        	
            MPMSettings.Report_Id_Project_Report__c = null;
            upsert MPMSettings;
        }
 
        // Assuming that we have reports and the custom setting for the project report ID is blank...
        if (!reports.isEmpty() && MPMSettings.Report_Id_Project_Report__c == null) {
            // Get the first one in our list
            Report r = reports[0];
            
            // Load up our Visualforce Page
            PageReference p = System.Page.Milestone1_Project_report;
            p.getParameters().put('pv0', proj.Id);
            Test.setCurrentPage(p);
            
            // Load up our Controller
            Milestone1_Report_Handler ctl = new Milestone1_Report_Handler();
 
            // Manually call the redirect() action,
            // and store the page that we are returned
            PageReference ret = ctl.redirectToProjectReport();
 
            // We should be sent to the View page for our Report
            System.assert(ret.getURL().contains('/' + r.Id));
            // Also, make sure that our Filter Criterion values
            // got passed along
            System.assert(ret.getURL().contains('pv0=' + proj.Id));
        }
 
	}
}