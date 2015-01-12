public class Milestone1_Report_Handler {
	
	public PageReference redirectToProjectReport() {
		Map<String,String> params = ApexPages.currentPage().getParameters();
		
		report projReport = [select ID from report where DeveloperName = 'Project_Report' and name = 'Project Report' limit 1];
	
		PageReference pgRef;
	
		if(projReport != null){
			pgRef = new PageReference('/' + projReport.Id);
			pgRef.getParameters().putAll(params);
		}
		
		pgRef.setRedirect(true);
        return pgRef;
		
	}

}