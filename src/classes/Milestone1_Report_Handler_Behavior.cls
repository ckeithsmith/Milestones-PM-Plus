@isTest(SeeAllData=true)
public class Milestone1_Report_Handler_Behavior {

    static testmethod void ShouldLoadProjectReport() {
 
        // Get a report to work with
        List<Report> reports = [
            select Id, DeveloperName
            from Report where DeveloperName = 'Project_Report' and name = 'Project Report'
            limit 1
        ];
 
        // Assuming that we have reports...
        if (!reports.isEmpty()) {
            // Get the first one in our list
            Report r = reports[0];
            
            Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('test' + System.now());
            insert proj;

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
            System.assert(ret.getURL().contains('/'+r.Id));
            // Also, make sure that our Filter Criterion values
            // got passed along
            System.assert(ret.getURL().contains('pv0=' + proj.Id));
        }
 
	}
}