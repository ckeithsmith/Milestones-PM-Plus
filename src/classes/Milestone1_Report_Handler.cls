public class Milestone1_Report_Handler {
	
	public PageReference redirectToProjectReport() {
		Map<String,String> params = ApexPages.currentPage().getParameters();
		Milestone1_Settings__c MPMSettings = Milestone1_Settings__c.getOrgDefaults();
		PageReference pgRef;
		report projReport;
		
		if(MPMSettings.Report_Id_Project_Report__c != null){
			pgRef = new PageReference('/' + MPMSettings.Report_Id_Project_Report__c);
			pgRef.getParameters().putAll(params);
		}
		else{
			projReport = [select ID from report where DeveloperName = 'Project_Report' and name = 'Project Report' limit 1];
			if(projReport != null){
				pgRef = new PageReference('/' + projReport.Id);
				pgRef.getParameters().putAll(params);
			}
		}
		
		pgRef.setRedirect(true);
	    return pgRef;	
	}
	
}