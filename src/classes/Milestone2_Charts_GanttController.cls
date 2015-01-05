public with sharing class Milestone2_Charts_GanttController {

    public String myTarget {get; 
        set{
            this.mytarget = value;
            init();
        }
    }
    public String mySize {get;
        set{
            this.mySize = value;
        }
    }
    public String myOptions {get;
        set{
            this.myOptions = value;
        }
    }
    public String drawDepend {get;
    	set{
    		this.drawDepend = value;
    	}
    }
    
    public List<List<String>> taskItems {get;set;}
    public List<List<String>> childTaskItems {get;set;}
    
    public Map<String, String> localeMap = createLocaleMap();
    public String userDateFormat {get; set;}
    
  
    public String objectType {get;set;}
    public String startDateFieldName {get;set;}
    public String endDateFieldName {get;set;}
    public String idFieldName {get;set;}
    public String fullViewURL {get;set;}
 
    private String nameFieldName;
    private String completedFieldName;
    private String filterFieldName;
    private String predecessor;

    /////////////////////////////////////
    public String childObjectType {get;set;}
    public String childStartDateFieldName {get;set;}
    public String childEndDateFieldName {get;set;}
    public String childIdFieldName {get;set;}
    public String childFullViewURL {get;set;}
 
    private String childNameFieldName;
    private String childCompletedFieldName;
    private String childFilterFieldName;
    private String childPredecessor;
    /////////////////////////////////////
  
    public List<Sobject> sObjectList {get; set;}
    public List<Sobject> childsObjectList {get; set;}
    
    public static final String COLOR_COMPLETE = '009933'; //Dark Grey
    public static final String COLOR_LATE = 'ee3322'; //Red
    public static final String COLOR_FUTURE = '666666'; //Light Grey
    public static final String COLOR_CURRENT = '2299bb'; //Blue
    
    public void init()
    {
    	childTaskItems = new List<List<String>>();
        if (myTarget != null)
        {
            initFieldNames();
            retrieveData();
            toJSon();
        }
    }
    
    /*
    *   Initialize the variables depending on the object type possible values: 
    *   Milestone1_Milestone__c and Milestone1_Task__c
    */
    private void initFieldNames(){
        if(mytarget != null){
            if(mytarget.startsWith(Schema.SObjectType.Milestone1_Project__c.getKeyPrefix())){

                startDateFieldName = Milestone1_Milestone__c.Kickoff__c.getDescribe().getName();
                endDateFieldName = Milestone1_Milestone__c.Deadline__c.getDescribe().getName();
                nameFieldName = Milestone1_Milestone__c.NameClean__c.getDescribe().getName();
                filterFieldName = Milestone1_Milestone__c.Project__c.getDescribe().getName();
                predecessor = Milestone1_Milestone__c.Predecessor_Milestone__c.getDescribe().getName();

                objectType = Schema.SObjectType.Milestone1_Milestone__c.getName();
                completedFieldName = 'Complete__c';

                childstartDateFieldName = Milestone1_Task__c.Start_Date__c.getDescribe().getName();
                childendDateFieldName = Milestone1_Task__c.Due_Date__c.getDescribe().getName();
                childnameFieldName = Milestone1_Task__c.Name.getDescribe().getName();
                childfilterFieldName = Milestone1_Task__c.Project_Milestone__c.getDescribe().getName();
                childpredecessor = Milestone1_Task__c.Predecessor_Task__c.getDescribe().getName();
                                
                childobjectType = Schema.SObjectType.Milestone1_Task__c.getName();
                childcompletedFieldName = 'Complete__c';

            }else if(mytarget.startsWith(Schema.SObjectType.Milestone1_Milestone__c.getKeyPrefix())){

                startDateFieldName = Milestone1_Task__c.Start_Date__c.getDescribe().getName();
                endDateFieldName = Milestone1_Task__c.Due_Date__c.getDescribe().getName();
                nameFieldName = Milestone1_Task__c.Name.getDescribe().getName();
                filterFieldName = Milestone1_Task__c.Project_Milestone__c.getDescribe().getName();
                predecessor = Milestone1_Task__c.Predecessor_Task__c.getDescribe().getName();
                                
                objectType = Schema.SObjectType.Milestone1_Task__c.getName();
                completedFieldName = 'Complete__c';

                
            }else if(mytarget.startsWith(Schema.SObjectType.Milestone1_Program__c.getKeyPrefix())){
                startDateFieldName = Milestone1_Project__c.Kickoff__c.getDescribe().getName();
                endDateFieldName = Milestone1_Project__c.Deadline__c.getDescribe().getName();
                nameFieldName = Milestone1_Project__c.Name.getDescribe().getName();
                filterFieldName = Milestone1_Project__c.Program__c.getDescribe().getName();
                predecessor = Milestone1_Project__c.Predecessor_Project__c.getDescribe().getName();

                objectType = Schema.SObjectType.Milestone1_Project__c.getName();
                completedFieldName = 'Status__c';

                childstartDateFieldName = Milestone1_Milestone__c.Kickoff__c.getDescribe().getName();
                childendDateFieldName = Milestone1_Milestone__c.Deadline__c.getDescribe().getName();
                childnameFieldName = Milestone1_Milestone__c.NameClean__c.getDescribe().getName();
                childfilterFieldName = Milestone1_Milestone__c.Project__c.getDescribe().getName();
                childpredecessor = Milestone1_Milestone__c.Predecessor_Milestone__c.getDescribe().getName();

                childobjectType = Schema.SObjectType.Milestone1_Milestone__c.getName();
                childcompletedFieldName = 'Complete__c';
            }
             else {
                throw new Milestone1_Exception('[initFieldNames] Unable to generate JSON for ' + mytarget);
            }
            idFieldName = 'Id';
            childIdFieldName = 'Id';

             
        }
    }
    
    /*
    *   Retrieve the data doing a dynamic query by object type.
    */
    private void retrieveData(){
        
        List<Id> parentRecords = new List<Id>();
        String query = 'Select ' + idFieldName + ',' + startDateFieldName + ',' + endDateFieldName + ',' + nameFieldName + ',' + completedFieldName + ',' + predecessor +
                    ' from ' + objectType + ' where ' + filterFieldName +'=\'' + mytarget + '\' order by ' + startDateFieldName + ',' + endDateFieldName + ',' + nameFieldName;
        String childQuery;
        
        sobjectList = Database.query(query);


        for(sObject obj : sObjectList){
            parentRecords.add(obj.Id);

        }

		if(objectType != Schema.SObjectType.Milestone1_Task__c.getName()){
        //add child records for multi level gantt
        childQuery = 'Select ' + childidFieldName + ',' + childstartDateFieldName + ',' + childendDateFieldName + ',' + childnameFieldName + ',' + childcompletedFieldName + ',' + childpredecessor + ',' + childfilterFieldName + 
        			 ' from ' + childobjectType + ' where ' + childfilterFieldName +' IN :parentRecords '+  'order by ' + childstartDateFieldName + ',' + childendDateFieldName + ',' + childnameFieldName;
            
            childsObjectList = Database.query(childQuery);

            if(childsObjectList.size() > 0){
                buildChildTaskObjects();
            }
            
		}

    }
    
    /**
    *   Generate the output in json format to be rendered in the jquery gantt.
    */
    private void toJSon(){

        Date startDate,endDate;
        String name, id, color, sDateString, eDateString, urlString, hasChildren, dependencies = '';
        Integer i, completed;
        
        taskItems = new List<List<String>>();
        
        i = 0;
        for (Sobject current : sobjectList){ 
            if(current.get(startDateFieldName) == null){
                startDate = Date.today();
            }else{
                startDate = Date.valueOf(current.get(startDateFieldName));
            }
            //sDateString = startDate.month() + '/' + startDate.day() + '/' + startDate.year();
            sDateString = startDate.format();
            
            if(current.get(endDateFieldName) == null){
                endDate = startDate;
            }else{
                endDate = Date.valueOf(current.get(endDateFieldName));
            }
            //eDateString = endDate.month() + '/' + endDate.day() + '/' + endDate.year();
            eDateString = endDate.format();
            
			if(current.get(completedFieldName) == true)
                completed = 1;
            else{
                completed = 0;
                if(current.get(completedFieldName) == 'Completed'){
                completed = 1;
                }
                
            }

            hasChildren = checkIfParent((Id)current.get(idFieldName));
            
            name = String.valueOf(current.get(nameFieldName));
            id = String.valueOf(current.get(idFieldName));
            urlString = URL.getSalesforceBaseUrl().toExternalForm() + '/' + id;
            dependencies = String.valueOf(current.get(predecessor));

            color=COLOR_CURRENT;
            if (completed == 1) {
                color=COLOR_COMPLETE;
            } else if (endDate < Date.today()) {
                color=COLOR_LATE;
            } else if (startDate > Date.today()) {
                color=COLOR_FUTURE;
            }
            
/***************************************************************
pID: (required) is a unique ID used to identify each row for parent functions and for setting dom id for hiding/showing
pName: (required) is the task Label
pStart: (required) the task start date, can enter empty date ('') for groups. You can also enter specific time (2/10/2008 12:00) for additional percision or half days.
pEnd: (required) the task end date, can enter empty date ('') for groups
pColor: (required) the html color for this task; e.g. '00ff00'
pLink: (optional) any http link navigated to when task bar is clicked.
pMile:(optional) represent a milestone
pRes: (optional) resource name
pComp: (required) completion percent
pGroup: (optional) indicates whether this is a group(parent) - 0=NOT Parent; 1=IS Parent
pParent: (required) identifies a parent pID, this causes this task to be a child of identified task
pOpen: can be initially set to close folder when chart is first drawn
pDepend: optional list of id's this task is dependent on ... line drawn from dependent to this item
pCaption: optional caption that will be added after task bar if CaptionType set to "Caption"
*/

            //last argument isn't used but should be kept to avoid page error   
            taskItems.add(new String[]{id, name, sDateString, 
                                       eDateString, color, urlString, '0','Brent',
                                       String.valueOf(completed), hasChildren,'0','1', dependencies, '', objectType});

        }
    }

    private string checkIfParent(Id parentId){
	
		if(childsObjectList != null){
	        for(sObject child : childsObjectList){
	            if(child.get(childfilterFieldName) == parentId){
	                return '1';
	            }
	        }
		}
        return '0';
    }

    private void buildChildTaskObjects(){

                Date startDate,endDate;
        String name, id, color, sDateString, eDateString, urlString, hasChildren, parentRec, dependencies = '';
        Integer i, completed;
        
        taskItems = new List<List<String>>();
        
        i = 0;
        for (Sobject current : childsObjectList){ 
            if(current.get(childstartDateFieldName) == null){
                startDate = Date.today();
            }else{
                startDate = Date.valueOf(current.get(childstartDateFieldName));
            }
            //sDateString = startDate.month() + '/' + startDate.day() + '/' + startDate.year();
            sDateString = startDate.format();
            
            if(current.get(childendDateFieldName) == null){
                endDate = startDate;
            }else{
                endDate = Date.valueOf(current.get(childendDateFieldName));
            }
            //eDateString = endDate.month() + '/' + endDate.day() + '/' + endDate.year();
            eDateString = endDate.format();
            
            if(current.get(childcompletedFieldName) == true)
                completed = 1;
            else{
                completed = 0;
                if(current.get(childcompletedFieldName) == 'Completed'){
                completed = 1;
                }
                
            }
            
            name = String.valueOf(current.get(childnameFieldName));
            id = String.valueOf(current.get(childidFieldName));
            urlString = URL.getSalesforceBaseUrl().toExternalForm() + '/' + id;
            parentRec = String.ValueOf(current.get(childFilterFieldName));
            
            if(String.valueOf(current.get(childpredecessor)) != null){
            	dependencies = String.valueOf(current.get(childpredecessor));
            }
            else{
            	dependencies = '';
            }
            

            color=COLOR_CURRENT;
            if (completed == 1) {
                color=COLOR_COMPLETE;
            } else if (endDate < Date.today()) {
                color=COLOR_LATE;
            } else if (startDate > Date.today()) {
                color=COLOR_FUTURE;
            }
                                    
            childTaskItems.add(new String[]{id, name, sDateString, 
                                       eDateString, color, urlString, '0','Brent',
                                       String.valueOf(completed), '0','0','1', dependencies, '', parentRec});

        }

    }
    
    private Map<String, String> createLocaleMap() 
    {
	    Map<String, String> locale_map = new Map<String, String>(); //holds the locale to timedate formats
	    locale_map.put('ar', 'dd/MM/yyyy hh:mm a');
	    locale_map.put('ar_AE', 'dd/MM/yyyy hh:mm a');
	    locale_map.put('ar_BH', 'dd/MM/yyyy hh:mm a');
	    locale_map.put('ar_JO', 'dd/MM/yyyy hh:mm a');
	    locale_map.put('ar_KW', 'dd/MM/yyyy hh:mm a');
	    locale_map.put('ar_LB', 'dd/MM/yyyy hh:mm a');
	    locale_map.put('ar_SA', 'dd/MM/yyyy hh:mm a');
	    locale_map.put('bg_BG', 'yyyy-M-d H:mm');
	    locale_map.put('ca', 'dd/MM/yyyy HH:mm');
	    locale_map.put('ca_ES', 'dd/MM/yyyy HH:mm');
	    locale_map.put('ca_ES_EURO', 'dd/MM/yyyy HH:mm');
	    locale_map.put('cs', 'd.M.yyyy H:mm');
	    locale_map.put('cs_CZ', 'd.M.yyyy H:mm');
	    locale_map.put('da', 'dd-MM-yyyy HH:mm');
	    locale_map.put('da_DK', 'dd-MM-yyyy HH:mm');
	    locale_map.put('de', 'dd.MM.yyyy HH:mm');
	    locale_map.put('de_AT', 'dd.MM.yyyy HH:mm');
	    locale_map.put('de_AT_EURO', 'dd.MM.yyyy HH:mm');
	    locale_map.put('de_CH', 'dd.MM.yyyy HH:mm');
	    locale_map.put('de_DE', 'dd.MM.yyyy HH:mm');
	    locale_map.put('de_DE_EURO', 'dd.MM.yyyy HH:mm');
	    locale_map.put('de_LU', 'dd.MM.yyyy HH:mm');
	    locale_map.put('de_LU_EURO', 'dd.MM.yyyy HH:mm');
	    locale_map.put('el_GR', 'd/M/yyyy h:mm a');
	    locale_map.put('en_AU', 'd/MM/yyyy HH:mm');
	    locale_map.put('en_B', 'M/d/yyyy h:mm a');
	    locale_map.put('en_BM', 'M/d/yyyy h:mm a');
	    locale_map.put('en_CA', 'dd/MM/yyyy h:mm a');
	    locale_map.put('en_GB', 'dd/MM/yyyy');
	    locale_map.put('en_GH', 'M/d/yyyy h:mm a');
	    locale_map.put('en_ID', 'M/d/yyyy h:mm a');
	    locale_map.put('en_IE', 'dd/MM/yyyy HH:mm');
	    locale_map.put('en_IE_EURO', 'dd/MM/yyyy HH:mm');
	    locale_map.put('en_NZ', 'd/MM/yyyy HH:mm');
	    locale_map.put('en_SG', 'M/d/yyyy h:mm a');
	    locale_map.put('en_US', 'M/d/yyyy');
	    locale_map.put('en_ZA', 'yyyy/MM/dd hh:mm a');
	    locale_map.put('es', 'd/MM/yyyy H:mm');
	    locale_map.put('es_AR', 'dd/MM/yyyy HH:mm');
	    locale_map.put('es_BO', 'dd-MM-yyyy hh:mm a');
	    locale_map.put('es_CL', 'dd-MM-yyyy hh:mm a');
	    locale_map.put('es_CO', 'd/MM/yyyy hh:mm a');
	    locale_map.put('es_CR', 'dd/MM/yyyy hh:mm a');
	    locale_map.put('es_EC', 'dd/MM/yyyy hh:mm a');
	    locale_map.put('es_ES', 'd/MM/yyyy H:mm');
	    locale_map.put('es_ES_EURO', 'd/MM/yyyy H:mm');
	    locale_map.put('es_GT', 'd/MM/yyyy hh:mm a');
	    locale_map.put('es_HN', 'MM-dd-yyyy hh:mm a');
	    locale_map.put('es_MX', 'd/MM/yyyy hh:mm a');
	    locale_map.put('es_PE', 'dd/MM/yyyy hh:mm a');
	    locale_map.put('es_PR', 'MM-dd-yyyy hh:mm a');
	    locale_map.put('es_PY', 'dd/MM/yyyy hh:mm a');
	    locale_map.put('es_SV', 'MM-dd-yyyy hh:mm a');
	    locale_map.put('es_UY', 'dd/MM/yyyy hh:mm a');
	    locale_map.put('es_VE', 'dd/MM/yyyy hh:mm a');
	    locale_map.put('et_EE', 'd.MM.yyyy H:mm');
	    locale_map.put('fi', 'd.M.yyyy H:mm');
	    locale_map.put('fi_FI', 'd.M.yyyy H:mm');
	    locale_map.put('fi_FI_EURO', 'd.M.yyyy H:mm');
	    locale_map.put('fr', 'dd/MM/yyyy HH:mm');
	    locale_map.put('fr_BE', 'd/MM/yyyy H:mm');
	    locale_map.put('fr_CA', 'yyyy-MM-dd HH:mm');
	    locale_map.put('fr_CH', 'dd.MM.yyyy HH:mm');
	    locale_map.put('fr_FR', 'dd/MM/yyyy HH:mm');
	    locale_map.put('fr_FR_EURO', 'dd/MM/yyyy HH:mm');
	    locale_map.put('fr_LU', 'dd/MM/yyyy HH:mm');
	    locale_map.put('fr_MC', 'dd/MM/yyyy HH:mm');
	    locale_map.put('hr_HR', 'yyyy.MM.dd HH:mm');
	    locale_map.put('hu', 'yyyy.MM.dd. H:mm');
	    locale_map.put('hy_AM', 'M/d/yyyy h:mm a');
	    locale_map.put('is_IS', 'd.M.yyyy HH:mm');
	    locale_map.put('it', 'dd/MM/yyyy H.mm');
	    locale_map.put('it_CH', 'dd.MM.yyyy HH:mm');
	    locale_map.put('it_IT', 'dd/MM/yyyy H.mm');
	    locale_map.put('iw', 'HH:mm dd/MM/yyyy');
	    locale_map.put('iw_IL', 'HH:mm dd/MM/yyyy');
	    locale_map.put('ja', 'yyyy/MM/dd H:mm');
	    locale_map.put('ja_JP', 'yyyy/MM/dd H:mm');
	    locale_map.put('kk_KZ', 'M/d/yyyy h:mm a');
	    locale_map.put('km_KH', 'M/d/yyyy h:mm a');
	    locale_map.put('ko', 'yyyy. M. d a h:mm');
	    locale_map.put('ko_KR', 'yyyy. M. d a h:mm');
	    locale_map.put('lt_LT', 'yyyy.M.d HH.mm');
	    locale_map.put('lv_LV', 'yyyy.d.M HH:mm');
	    locale_map.put('ms_MY', 'dd/MM/yyyy h:mm a');
	    locale_map.put('nl', 'd-M-yyyy H:mm');
	    locale_map.put('nl_BE', 'd/MM/yyyy H:mm');
	    locale_map.put('nl_NL', 'd-M-yyyy H:mm');
	    locale_map.put('nl_SR', 'd-M-yyyy H:mm');
	    locale_map.put('no', 'dd.MM.yyyy HH:mm');
	    locale_map.put('no_NO', 'dd.MM.yyyy HH:mm');
	    locale_map.put('pl', 'yyyy-MM-dd HH:mm');
	    locale_map.put('pt', 'dd-MM-yyyy H:mm');
	    locale_map.put('pt_AO', 'dd-MM-yyyy H:mm');
	    locale_map.put('pt_BR', 'dd/MM/yyyy HH:mm');
	    locale_map.put('pt_PT', 'dd-MM-yyyy H:mm');
	    locale_map.put('ro_RO', 'dd.MM.yyyy HH:mm');
	    locale_map.put('ru', 'dd.MM.yyyy H:mm');
	    locale_map.put('sk_SK', 'd.M.yyyy H:mm');
	    locale_map.put('sl_SI', 'd.M.y H:mm');
	    locale_map.put('sv', 'yyyy-MM-dd HH:mm');
	    locale_map.put('sv_SE', 'yyyy-MM-dd HH:mm');
	    locale_map.put('th', 'M/d/yyyy h:mm a');
	    locale_map.put('th_TH', 'd/M/yyyy, H:mm ?.');
	    locale_map.put('tr', 'dd.MM.yyyy HH:mm');
	    locale_map.put('ur_PK', 'M/d/yyyy h:mm a');
	    locale_map.put('vi_VN', 'HH:mm dd/MM/yyyy');
	    locale_map.put('zh', 'yyyy-M-d ah:mm');
	    locale_map.put('zh_CN', 'yyyy-M-d ah:mm');
	    locale_map.put('zh_HK', 'yyyy-M-d ah:mm');
	    locale_map.put('zh_TW', 'yyyy/M/d a h:mm');
	    return locale_map; //return the map
	}
	
	public String getUserDateFormat()
	{
		return localeMap.get(UserInfo.getLocale()).toLowerCase();
	}

}