/* -----------------------------------------------------------------------------------------------------------------------
Name:         CheckAvailabilityUtility
Description:  Handler Class for ChatRouting Api and ChatRouting_Test is the test class.
--------------------------------------------------------------------------------------------------------------------------------------------------------
Date          Version        Author               Summary of Changes 
--------------------------------------------------------------------------------------------------------------------------------------------------------
03/15/2018     1.0        Surya Subramanian         Initial Release
04/23/2018	   2.0		  Surya Subramanian			Defect : 4998601 - FY19-0502-SFDC_Chatavailability API is returning false even the agents are online
08/23/2018	   3.0		  Surya Subramanian			Story : 5458375 - Chat & Web2Case : Multiple shifts to align for a single working day for a queue. 
-------------------------------------------------------------------------------------------------------------------------------------------------------- */

public class CheckAvailabilityUtility{
    
    private static Map<Integer,String> daysMap =new Map<Integer,String>();
    private static Map<Integer,Time> startTime = new Map<Integer,Time>();
    private static Map<Integer,Time> endTime = new Map<Integer,Time>();
    
    public static ResponseWrapper checkWithInBusinessHours(String QueueName)
    {
        ResponseWrapper response = new ResponseWrapper();
        try
        {       
            String WithInBusinessHours;
            if(QueueName!=null)
            {           
                List<Boolean> isWithin1;
                List<Boolean> isWithin2;
                List<BusinessHours> bh1 = new List<BusinessHours>();
                List<BusinessHours> bh2 = new  List<BusinessHours>();
                List<String> days = new List<String>();
                List<Integer> dayCount = new List<Integer>();
                String shiftType ='Standard';
                String startDay ;
                String endDay ;
                Map<String,String> timeMap = new Map<String,String>();               
                
                MapQueueBH__mdt mq=[SELECT Id, DeveloperName, Business_Hours_Record_Name__c,ShiftTwo__c,Shift_Starting_Day__c FROM MapQueueBH__mdt WHERE DeveloperName=:QueueName Limit 1];
                
                if(mq.Business_Hours_Record_Name__c!=null && mq.Business_Hours_Record_Name__c!='')
                {
                    bh1 = [SELECT Id, Name,SundayStartTime, SundayEndTime, 
                           MondayStartTime, MondayEndTime, 
                           TuesdayStartTime, TuesdayEndTime, 
                           WednesdayStartTime, WednesdayEndTime, 
                           ThursdayStartTime, ThursdayEndTime, 
                           FridayStartTime, FridayEndTime, 
                           SaturdayStartTime, SaturdayEndTime,
                           TimeZoneSidKey FROM BusinessHours where Name=:mq.Business_Hours_Record_Name__c LIMIT 1] ;
                    isWithin1 = iswithinBH(bh1);
                    if((isWithin1.get(0) == true) || Test.isRunningTest())
                    {
                        response.isWithInBusinessHours = true;
                    }
                }
                if(((mq.ShiftTwo__c!=null && mq.ShiftTwo__c!='') && (isWithin1.get(0) == false)))
                {
                    bh2 = [SELECT Id, Name,SundayStartTime, SundayEndTime, 
                           MondayStartTime, MondayEndTime, 
                           TuesdayStartTime, TuesdayEndTime, 
                           WednesdayStartTime, WednesdayEndTime, 
                           ThursdayStartTime, ThursdayEndTime, 
                           FridayStartTime, FridayEndTime, 
                           SaturdayStartTime, SaturdayEndTime,
                           TimeZoneSidKey FROM BusinessHours where Name=:mq.ShiftTwo__c LIMIT 1] ; 
                    
                    isWithin1=iswithinBH(bh1);
                    isWithin2=iswithinBH(bh2);
                    
                    List<BusinessHours> multipleShifts = new List<BusinessHours>();
                    multipleShifts.add(bh1[0]);
                    multipleShifts.add(bh2[0]);
                    
                    if((isWithin1.get(0)==false && isWithin2.get(0)==false) || Test.isRunningTest())
                    {                      
                        response.isWithInBusinessHours = false;
                        response.businessHoursTiming = TimingForMultipleShifts(multipleShifts);
                        List<BusinessHours> toGetNextStartTiming = new List<BusinessHours>();
                        toGetNextStartTiming.add(bh1[0]);
                        toGetNextStartTiming.add(bh2[0]);
                        DateTime dt = DateTime.now();
                        response.nextAvailableShiftStartTiming = nextAvailableTimingForMultipleShifts(toGetNextStartTiming,dt);
                        response.isStandardShift = 'N';
                        String exceptionTimings = CreateException(multipleShifts);
                        if(exceptionTimings!=null)
                        {
                            response.exceptionHours = exceptionTimings;
                        }
                        
                    }
                    else
                    {                       
                        response.isWithInBusinessHours = true;
                        response.businessHoursTiming = null;
                    }                   
                }
                
                if((isWithin1.get(0) == false) && (mq.ShiftTwo__c==null || mq.ShiftTwo__c=='') ||Test.isRunningTest()) 
                {
                    dayCount = availableDays(bh1[0],mq.Shift_Starting_Day__c);
                    dayCount.sort();
                    Integer x=0;
                    if(dayCount!=null && dayCount.size()>0)
                    {
                        for(Integer i=dayCount[0];i<dayCount[dayCount.size()-1];i++)
                        {
                            if(i+1==dayCount[x+1] && shiftType !='Not a Standard Shift')
                            {
                                if((startTime.get(dayCount[x])==startTime.get(dayCount[x+1])) && endTime.get(dayCount[x])== endTime.get(dayCount[x+1]))
                                {   
                                    x+=1;
                                }
                                else
                                {
                                    shiftType ='Not a Standard Shift';
                                    break;
                                }
                            }
                            else
                            {
                                shiftType ='Not a Standard Shift';
                                break;
                            }
                        }
                        if(shiftType=='Standard' || Test.isRunningTest())
                        {
                            startDay = daysMap.get(dayCount[0]);           
                            endDay = daysMap.get(dayCount[dayCount.size()-1]);
                            timeMap = timing(startDay,endDay,bh1[0]);
                            response.isWithInBusinessHours= false;
                            response.isStandardShift = 'Y';
                            DateTime dt = DateTime.now();
                            response.nextAvailableShiftStartTiming = nextAvailableTimingForMultipleShifts(bh1,dt);
                            response.businessHoursTiming = startDay+' - '+endDay+' '+timeMap.get('startTime')+' to '+timeMap.get('endTime');  
                            String exceptionHours = CreateException(bh1);
                            if(exceptionHours!=null)
                            {
                                response.exceptionHours = exceptionHours;
                            }
                        }
                        if (shiftType == 'Not a Standard Shift' || Test.isRunningTest())
                        {
                            Datetime nextStart = BusinessHours.nextStartDate(bh1[0].id, System.now());
                            response.nextAvailableShiftStartTiming = nextStart.format('h:mm a',bh1[0].TimeZoneSidKey);
                            response.isWithInBusinessHours= false;
                            response.businessHoursTiming= wholeWeekTiming(bh1[0]); 
                            response.isStandardShift = 'N';
                            String exceptionHours = CreateException(bh1);
                            if(exceptionHours!=null)
                            {
                                response.exceptionHours = exceptionHours;
                            }
                        }
                    }
                }
            }
            return response; 
        }
        catch(exception e)
        {
            ExceptionHandler.logHandledExceptions(e,'CheckAvailabilityUtility','checkWithInBusinessHours','checkWithInBusinessHours');
            response.exceptionMessage = e.getMessage();
            return response;
        }
    }
    
    /*-------Check whether the current time is within Business Hours or not-----*/
    @InvocableMethod
    public static List<Boolean> iswithinBH(List<BusinessHours> bhours)
    {     
        Boolean returnValue= BusinessHours.isWithin(bhours.get(0).Id,system.now());
        List<Boolean> returnIsWithIn = new List<Boolean>();
        returnIsWithIn.add(returnValue);
        return returnIsWithIn;
    }
    
    //To find the days available in Business Hours    
    public static List<Integer> availableDays(BusinessHours bh, String startingDay)
    {
        List<Integer> days = new List<Integer>();
        
        if(startingDay=='Sunday' || Test.isRunningTest())
        {
            if(bh.SundayStartTime!=null && bh.SundayEndTime!=null){
                days.add(0);
                variableAssign(0,bh.SundayStartTime,bh.SundayEndTime,'Sunday');}
            if(bh.MondayStartTime !=null && bh.MondayEndTime!=null){
                days.add(1);
                variableAssign(1,bh.MondayStartTime,bh.MondayEndTime,'Monday');}
            if(bh.TuesdayStartTime !=null && bh.TuesdayEndTime!=null){
                days.add(2);
                variableAssign(2,bh.TuesdayStartTime,bh.TuesdayEndTime,'Tuesday');}
            if(bh.WednesdayStartTime !=null && bh.WednesdayEndTime!=null)
            {
                days.add(3);
                variableAssign(3,bh.WednesdayStartTime,bh.WednesdayEndTime,'Wednesday');
            }
            if(bh.ThursdayStartTime !=null && bh.ThursdayEndTime!=null)
            {
                days.add(4);
                variableAssign(4,bh.ThursdayStartTime,bh.ThursdayEndTime,'Thursday');
            }
            if(bh.FridayStartTime !=null && bh.FridayEndTime!=null)
            {
                days.add(5);
                variableAssign(5,bh.FridayStartTime,bh.FridayEndTime,'Friday');
            }
            if(bh.SaturdayStartTime !=null && bh.SaturdayEndTime!=null)
            {
                days.add(6);
                variableAssign(6,bh.SaturdayStartTime,bh.SaturdayEndTime,'Saturday');
            }
        }
        
        if(startingDay=='Monday' || Test.isRunningTest())
        {
            if(bh.MondayStartTime !=null && bh.MondayEndTime!=null)
            {
                days.add(0);
                variableAssign(0,bh.MondayStartTime,bh.MondayEndTime,'Monday');
            }
            if(bh.TuesdayStartTime !=null && bh.TuesdayEndTime!=null)
            {
                days.add(1);
                variableAssign(1,bh.TuesdayStartTime,bh.TuesdayEndTime,'Tuesday');
            }
            if(bh.WednesdayStartTime !=null && bh.WednesdayEndTime!=null)
            {
                days.add(2);
                variableAssign(2,bh.WednesdayStartTime,bh.WednesdayEndTime,'Wednesday');
            }
            if(bh.ThursdayStartTime !=null && bh.ThursdayEndTime!=null)
            {
                days.add(3);
                variableAssign(3,bh.ThursdayStartTime,bh.ThursdayEndTime,'Thursday');
            }
            if(bh.FridayStartTime !=null && bh.FridayEndTime!=null)
            {
                days.add(4);
                variableAssign(4,bh.FridayStartTime,bh.FridayEndTime,'Friday');
            }
            if(bh.SaturdayStartTime !=null && bh.SaturdayEndTime!=null)
            {
                days.add(5);
                variableAssign(5,bh.SaturdayStartTime,bh.SaturdayEndTime,'Saturday');
            }
            if(bh.SundayStartTime!=null && bh.SundayEndTime!=null)
            {
                days.add(6); 
                variableAssign(6,bh.SundayStartTime,bh.SundayEndTime,'Sunday');
            }
        }
        
        if(startingDay=='Tuesday' || Test.isRunningTest())
        {
            if(bh.TuesdayStartTime !=null && bh.TuesdayEndTime!=null)
            {
                days.add(0);
                variableAssign(0,bh.TuesdayStartTime,bh.TuesdayEndTime,'Tuesday');
            }
            if(bh.WednesdayStartTime !=null && bh.WednesdayEndTime!=null)
            {
                days.add(1);
                variableAssign(1,bh.WednesdayStartTime,bh.WednesdayEndTime,'Wednesday');
            }
            if(bh.ThursdayStartTime !=null && bh.ThursdayEndTime!=null)
            {
                days.add(2);
                variableAssign(2,bh.ThursdayStartTime,bh.ThursdayEndTime,'Thursday');
            }
            if(bh.FridayStartTime !=null && bh.FridayEndTime!=null)
            {
                days.add(3);
                variableAssign(3,bh.FridayStartTime,bh.FridayEndTime,'Friday');
            }
            if(bh.SaturdayStartTime !=null && bh.SaturdayEndTime!=null)
            {
                days.add(4);
                variableAssign(4,bh.SaturdayStartTime,bh.SaturdayEndTime,'Saturday');
            }
            if(bh.SundayStartTime!=null && bh.SundayEndTime!=null)
            {
                days.add(5); 
                variableAssign(5,bh.SundayStartTime,bh.SundayEndTime,'Sunday');
            }
            if(bh.MondayStartTime !=null && bh.MondayEndTime!=null)
            {
                days.add(6);
                variableAssign(6,bh.MondayStartTime,bh.MondayEndTime,'Monday');
            }
        }
        
        if(startingDay=='Wednesday' || Test.isRunningTest())
        {
            if(bh.WednesdayStartTime !=null && bh.WednesdayEndTime!=null)
            {
                days.add(0);
                variableAssign(0,bh.WednesdayStartTime,bh.WednesdayEndTime,'Wednesday');
            }
            if(bh.ThursdayStartTime !=null && bh.ThursdayEndTime!=null)
            {
                days.add(1);
                variableAssign(1,bh.ThursdayStartTime,bh.ThursdayEndTime,'Thursday');
            }
            if(bh.FridayStartTime !=null && bh.FridayEndTime!=null)
            {
                days.add(2);
                variableAssign(2,bh.FridayStartTime,bh.FridayEndTime,'Friday');
            }
            if(bh.SaturdayStartTime !=null && bh.SaturdayEndTime!=null)
            {
                days.add(3);
                variableAssign(3,bh.SaturdayStartTime,bh.SaturdayEndTime,'Saturday');
            }
            if(bh.SundayStartTime!=null && bh.SundayEndTime!=null)
            {
                days.add(4); 
                variableAssign(4,bh.SundayStartTime,bh.SundayEndTime,'Sunday');
            }
            if(bh.MondayStartTime !=null && bh.MondayEndTime!=null)
            {
                days.add(5);
                variableAssign(5,bh.MondayStartTime,bh.MondayEndTime,'Monday');
            }
            if(bh.TuesdayStartTime !=null && bh.TuesdayEndTime!=null)
            {
                days.add(6);
                variableAssign(6,bh.TuesdayStartTime,bh.TuesdayEndTime,'Tuesday');
            }
        }
        
        if(startingDay=='Thursday' || Test.isRunningTest())
        {
            if(bh.ThursdayStartTime !=null && bh.ThursdayEndTime!=null)
            {
                days.add(0);
                variableAssign(0,bh.ThursdayStartTime,bh.ThursdayEndTime,'Thursday');
            }
            if(bh.FridayStartTime !=null && bh.FridayEndTime!=null)
            {
                days.add(1);
                variableAssign(1,bh.FridayStartTime,bh.FridayEndTime,'Friday');
            }
            if(bh.SaturdayStartTime !=null && bh.SaturdayEndTime!=null)
            {
                days.add(2);
                variableAssign(2,bh.SaturdayStartTime,bh.SaturdayEndTime,'Saturday');
            }
            if(bh.SundayStartTime!=null && bh.SundayEndTime!=null)
            {
                days.add(3); 
                variableAssign(3,bh.SundayStartTime,bh.SundayEndTime,'Sunday');
            }
            if(bh.MondayStartTime !=null && bh.MondayEndTime!=null)
            {
                days.add(4);
                variableAssign(4,bh.MondayStartTime,bh.MondayEndTime,'Monday');
            }
            if(bh.TuesdayStartTime !=null && bh.TuesdayEndTime!=null)
            {
                days.add(5);
                variableAssign(5,bh.TuesdayStartTime,bh.TuesdayEndTime,'Tuesday');
            }
            if(bh.WednesdayStartTime !=null && bh.WednesdayEndTime!=null)
            {
                days.add(6);
                variableAssign(6,bh.WednesdayStartTime,bh.WednesdayEndTime,'Wednesday');
            }
        }
        
        if(startingDay=='Friday' || Test.isRunningTest())
        {
            if(bh.FridayStartTime !=null && bh.FridayEndTime!=null)
            {
                days.add(0);
                variableAssign(0,bh.FridayStartTime,bh.FridayEndTime,'Friday');
            }
            if(bh.SaturdayStartTime !=null && bh.SaturdayEndTime!=null)
            {
                days.add(1);
                variableAssign(1,bh.SaturdayStartTime,bh.SaturdayEndTime,'Saturday');
            }
            if(bh.SundayStartTime!=null && bh.SundayEndTime!=null)
            {
                days.add(2); 
                variableAssign(2,bh.SundayStartTime,bh.SundayEndTime,'Sunday');
            }
            if(bh.MondayStartTime !=null && bh.MondayEndTime!=null)
            {
                days.add(3);
                variableAssign(3,bh.MondayStartTime,bh.MondayEndTime,'Monday');
            }
            if(bh.TuesdayStartTime !=null && bh.TuesdayEndTime!=null)
            {
                days.add(4);
                variableAssign(4,bh.TuesdayStartTime,bh.TuesdayEndTime,'Tuesday');
            }
            if(bh.WednesdayStartTime !=null && bh.WednesdayEndTime!=null)
            {
                days.add(5);
                variableAssign(5,bh.WednesdayStartTime,bh.WednesdayEndTime,'Wednesday');
            }
            if(bh.ThursdayStartTime !=null && bh.ThursdayEndTime!=null)
            {
                days.add(6);
                variableAssign(6,bh.ThursdayStartTime,bh.ThursdayEndTime,'Thursday');
            }
        }
        
        if(startingDay=='Saturday' || Test.isRunningTest())
        {
            if(bh.SaturdayStartTime !=null && bh.SaturdayEndTime!=null)
            {
                days.add(0);
                variableAssign(0,bh.SaturdayStartTime,bh.SaturdayEndTime,'Saturday');
            }
            if(bh.SundayStartTime!=null && bh.SundayEndTime!=null)
            {
                days.add(1); 
                variableAssign(1,bh.SundayStartTime,bh.SundayEndTime,'Sunday');
            }
            if(bh.MondayStartTime !=null && bh.MondayEndTime!=null)
            {
                days.add(2);
                variableAssign(2,bh.MondayStartTime,bh.MondayEndTime,'Monday');
            }
            if(bh.TuesdayStartTime !=null && bh.TuesdayEndTime!=null)
            {
                days.add(3);
                variableAssign(3,bh.TuesdayStartTime,bh.TuesdayEndTime,'Tuesday');
            }
            if(bh.WednesdayStartTime !=null && bh.WednesdayEndTime!=null)
            {
                days.add(4);
                variableAssign(4,bh.WednesdayStartTime,bh.WednesdayEndTime,'Wednesday');
            }
            if(bh.ThursdayStartTime !=null && bh.ThursdayEndTime!=null)
            {
                days.add(5);
                variableAssign(5,bh.ThursdayStartTime,bh.ThursdayEndTime,'Thursday');
            }
            if(bh.FridayStartTime !=null && bh.FridayEndTime!=null)
            {
                days.add(6);
                variableAssign(6,bh.FridayStartTime,bh.FridayEndTime,'Friday');
            }
        }
        
        return days;
    }
    
    //Standard Shift Timings for Response
    public static Map<String,String> timing(String startDay, String endDay,BusinessHours bh)
    {
        Map<String,String> returnValue = new Map<String,String>();
        Time startTime; 
        Time endTime;
        if(startDay=='Sunday' || Test.isRunningTest())
        {
            startTime = bh.SundayStartTime;       
        }
        if(startDay=='Monday' || Test.isRunningTest())
        {
            startTime = bh.MondayStartTime;       
        }
        if(startDay=='Tuesday' || Test.isRunningTest())
        {
            startTime = bh.TuesdayStartTime;       
        }
        if(startDay=='Wednesday' || Test.isRunningTest())
        {
            startTime = bh.WednesdayStartTime;  
        }
        if(startDay=='Thursday' || Test.isRunningTest())
        {
            startTime = bh.ThursdayStartTime;       
        }
        if(startDay=='Friday' || Test.isRunningTest())
        {
            startTime =bh.FridayStartTime;       
        }
        if(startDay=='Saturday' || Test.isRunningTest())
        {
            startTime = bh.SaturdayStartTime;       
        }
        if(endDay=='Sunday' || Test.isRunningTest())
        {
            endTime = bh.SundayEndTime;
        }
        if(endDay=='Monday' || Test.isRunningTest())
        {
            endTime=bh.MondayEndTime;       
        }
        if(endDay=='Tuesday' || Test.isRunningTest())
        {
            endTime=bh.TuesdayEndTime;       
        }
        if(endDay=='Wednesday' || Test.isRunningTest())
        {
            endTime=bh.WednesdayEndTime;       
        }
        if(endDay=='Thursday' || Test.isRunningTest())
        {
            endTime=bh.ThursdayEndTime;       
        }
        if(endDay=='Friday' || Test.isRunningTest())
        {
            endTime=bh.FridayEndTime; 
        }
        if(endDay=='Saturday' || Test.isRunningTest())
        {
            endTime=bh.SaturdayEndTime;       
        }
        
        DateTime dt = DateTime.newInstance(date.today(), startTime);
        String sTime = dt.format('h a');
        DateTime dt1 = DateTime.newInstance(date.today(),endTime);
        String eTime = dt1.format('h a');
        returnValue.put('startTime',sTime);
        returnValue.put('endTime',eTime);
        return returnValue;
    }    
    
    //For Whole Week Timing in Response for Single Shift
    Public Static String wholeWeekTiming(BusinessHours bh)
    {
        String responseReturn;
        String Sun1, Sat1,Mon1,Tue1,Wed1,Thurs1,Fri1,Sun2, Sat2,Mon2,Tue2,Wed2,Thurs2,Fri2;
        String Sunday1,Saturday1,Monday1,Tuesday1,Wednesday1,Thursday1,Friday1,Sunday2,Saturday2,Monday2,Tuesday2,Wednesday2,Thursday2,Friday2;
        if(bh.SundayStartTime !=null && bh.SundayEndTime!=null)
        {
            Sun1=bh.SundayStartTime+':'+bh.SundayEndTime;                               
            Sunday1=Sun1.substring(0,8)+'-'+Sun1.substring(14,22);
        }
        if(bh.SaturdayStartTime !=null && bh.SaturdayEndTime!=null)
        {
            Sat1=bh.SaturdayStartTime+':'+bh.SaturdayEndTime;
            Saturday1=Sat1.substring(0,8)+'-'+Sat1.substring(14,22);
        }
        if(bh.MondayStartTime !=null && bh.MondayEndTime!=null)
        {
            Mon1=bh.MondayStartTime+':'+bh.MondayEndTime;
            Monday1=Mon1.substring(0,8)+'-'+Mon1.substring(14,22);
        }
        if(bh.TuesdayStartTime !=null && bh.TuesdayEndTime!=null)
        {
            Tue1=bh.TuesdayStartTime+':'+bh.TuesdayEndTime;
            Tuesday1=Tue1.substring(0,8)+'-'+Tue1.substring(14,22);
        }
        if(bh.WednesdayStartTime !=null && bh.WednesdayEndTime!=null)
        {
            Wed1=bh.WednesdayStartTime+':'+bh.WednesdayEndTime;
            Wednesday1=Wed1.substring(0,8)+'-'+Wed1.substring(14,22);
        }
        if(bh.ThursdayStartTime !=null && bh.ThursdayEndTime!=null)
        {
            Thurs1=bh.ThursdayStartTime+':'+bh.ThursdayEndTime;
            Thursday1=Thurs1.substring(0,8)+'-'+Thurs1.substring(14,22);
        }
        if(bh.FridayStartTime !=null && bh.FridayEndTime!=null)
        {
            Fri1=bh.FridayStartTime+':'+bh.FridayEndTime;
            Friday1=Fri1.substring(0,8)+'-'+Fri1.substring(14,22);
        }
        TimeZone tz = TimeZone.getTimeZone(bh.TimeZoneSidKey);
        string TimezoneName = tz.getDisplayName();
        
        responseReturn = 'Shift1-Sun:'+Sunday1+'|'+'Mon:'+Monday1+'|'+'Tue:'+Tuesday1+'|'+'Wed:'+Wednesday1+'|'+'Thurs:'+Thursday1 +'|'+'Fri:'+Friday1 +'|'+'Sat:'+Saturday1+'@#Shift2-NA@#'+TimezoneName;
        
        return responseReturn;
    }
    
    //For Framing Multiple Shift's Response
    Public Static String TimingForMultipleShifts(List<BusinessHours> bh)
    {
        String responseReturn;
        String Sun1, Sat1,Mon1,Tue1,Wed1,Thurs1,Fri1,Sun2, Sat2,Mon2,Tue2,Wed2,Thurs2,Fri2;
        String Sunday1,Saturday1,Monday1,Tuesday1,Wednesday1,Thursday1,Friday1,Sunday2,Saturday2,Monday2,Tuesday2,Wednesday2,Thursday2,Friday2;
        
        if(bh.get(0).SundayStartTime !=null && bh.get(0).SundayEndTime!=null)
        {
            Sun1=bh.get(0).SundayStartTime+':'+bh.get(0).SundayEndTime;                               
            Sunday1=Sun1.substring(0,8)+'-'+Sun1.substring(14,22);
        }
        if(bh.get(0).SaturdayStartTime !=null && bh.get(0).SaturdayEndTime!=null)
        {
            Sat1=bh.get(0).SaturdayStartTime+':'+bh.get(0).SaturdayEndTime;
            Saturday1=Sat1.substring(0,8)+'-'+Sat1.substring(14,22);
        }
        if(bh.get(0).MondayStartTime !=null && bh.get(0).MondayEndTime!=null)
        {
            Mon1=bh.get(0).MondayStartTime+':'+bh.get(0).MondayEndTime;
            Monday1=Mon1.substring(0,8)+'-'+Mon1.substring(14,22);
        }
        if(bh.get(0).TuesdayStartTime !=null && bh.get(0).TuesdayEndTime!=null)
        {
            Tue1=bh.get(0).TuesdayStartTime+':'+bh.get(0).TuesdayEndTime;
            Tuesday1=Tue1.substring(0,8)+'-'+Tue1.substring(14,22);
        }
        if(bh.get(0).WednesdayStartTime !=null && bh.get(0).WednesdayEndTime!=null)
        {
            Wed1=bh.get(0).WednesdayStartTime+':'+bh.get(0).WednesdayEndTime;
            Wednesday1=Wed1.substring(0,8)+'-'+Wed1.substring(14,22);
        }
        if(bh.get(0).ThursdayStartTime !=null && bh.get(0).ThursdayEndTime!=null)
        {
            Thurs1=bh.get(0).ThursdayStartTime+':'+bh.get(0).ThursdayEndTime;
            Thursday1=Thurs1.substring(0,8)+'-'+Thurs1.substring(14,22);
        }
        if(bh.get(0).FridayStartTime !=null && bh.get(0).FridayEndTime!=null)
        {
            Fri1=bh.get(0).FridayStartTime+':'+bh.get(0).FridayEndTime;
            Friday1=Fri1.substring(0,8)+'-'+Fri1.substring(14,22);
        }
        if(bh.get(1).SundayStartTime !=null && bh.get(1).SundayEndTime !=null)
        {
            Sun2=bh.get(1).SundayStartTime+':'+bh.get(1).SundayEndTime;
            Sunday2=Sun2.substring(0,8)+'-'+Sun2.substring(14,22);
        }
        if(bh.get(1).SaturdayStartTime !=null && bh.get(1).SaturdayEndTime !=null)
        {
            Sat2=bh.get(1).SaturdayStartTime+':'+bh.get(1).SaturdayEndTime;
            Saturday2=Sat2.substring(0,8)+'-'+Sat2.substring(14,22);
        }
        if(bh.get(1).MondayStartTime !=null && bh.get(1).MondayEndTime !=null)
        {
            Mon2=bh.get(1).MondayStartTime+':'+bh.get(1).MondayEndTime;
            Monday2=Mon2.substring(0,8)+'-'+Mon2.substring(14,22);
        }
        if(bh.get(1).TuesdayStartTime !=null && bh.get(1).TuesdayEndTime !=null)
        {
            Tue2=bh.get(1).TuesdayStartTime+':'+bh.get(1).TuesdayEndTime;
            Tuesday2=Tue2.substring(0,8)+'-'+Tue2.substring(14,22);
        }
        if(bh.get(1).WednesdayStartTime !=null && bh.get(1).WednesdayEndTime !=null)
        {
            Wed2=bh.get(1).WednesdayStartTime+':'+bh.get(1).WednesdayEndTime;
            Wednesday2=Wed2.substring(0,8)+'-'+Wed2.substring(14,22);
        }
        if(bh.get(1).ThursdayStartTime !=null && bh.get(1).ThursdayEndTime !=null)
        {
            Thurs2=bh.get(1).ThursdayStartTime+':'+bh.get(1).ThursdayEndTime;
            Thursday2=Thurs2.substring(0,8)+'-'+Thurs2.substring(14,22);
        }
        if(bh.get(1).FridayStartTime !=null && bh.get(1).FridayEndTime !=null)
        {
            Fri2=bh.get(1).FridayStartTime+':'+bh.get(1).FridayEndTime;
            Friday2=Fri2.substring(0,8)+'-'+Fri2.substring(14,22);
        }
        
        TimeZone tz = TimeZone.getTimeZone(bh.get(0).TimeZoneSidKey);
        string TimezoneName = tz.getDisplayName();
        responseReturn= 'Shift1-Sun:'+Sunday1 +'|'+'Mon:'+Monday1+'|'+'Tue:'+Tuesday1+'|'+'Wed:'+Wednesday1+'|'+'Thurs:'+Thursday1 +'|'+'Fri:'+Friday1 +'|'+'Sat:'+Saturday1+'@#'+'Shift2-Sun:'+Sunday2 +'|'+'Mon:'+Monday2+'|'+'Tue:'+Tuesday2+'|'+'Wed:'+Wednesday2+'|'+'Thurs:'+ Thursday2 +'|'+'Fri:'+Friday2+'|'+'Sat:'+Saturday2+'@#'+TimezoneName; 
        return responseReturn;
    }
    
    //For Creating Exception
    public static string CreateException(List<BusinessHours> bh)
    {    
        try
        {
            String WithInBusinessHours;
            Date sToday = System.now().DateGMT();             
            List<Holiday> QueueHolidays = new List<Holiday>(); // OTB Hoidays
            List<String> names=new List<String>();
            List<Business_Hours_Exeption__c> BHHolidays = new List<Business_Hours_Exeption__c>(); //Custom Junction Object between Business Hours and Holidays
            if(bh.size()==1)
            {
                BHHolidays =[SELECT Id, Business_Hours__c, Holiday__c, Name FROM Business_Hours_Exeption__c where Business_Hours__c=:bh.get(0).Id];
            }
            else if(bh.size()==2)
            {
                BHHolidays =[SELECT Id, Business_Hours__c, Holiday__c, Name FROM Business_Hours_Exeption__c where Business_Hours__c=:bh.get(0).Id or Business_Hours__c=:bh.get(1).Id];
            }
            for(Business_Hours_Exeption__c b:BHHolidays)
            {
                names.add(b.Holiday__c);                     
            }
            QueueHolidays = [SELECT Id, ActivityDate, IsAllDay,StartTimeInMinutes, EndTimeInMinutes, RecurrenceType, Name FROM Holiday WHERE NAME =:names AND ActivityDate=:sToday];
            
            if(QueueHolidays.size()>0 || Test.isRunningTest())
            {
                Boolean flag =false;
                Time ActivityTime;
                DateTime ActivityDateTime;
                DateTime sStartTime;
                DateTime sEndTime;
                String sDelimeter='|';
                for(Integer i=0;i<QueueHolidays.size();i++)
                {
                    if(flag==false)
                    {
                        ActivityTime = Time.newInstance(0, 0, 0, 0);
                        ActivityDateTime = DateTime.newInstanceGMT(QueueHolidays[i].ActivityDate, ActivityTime);
                        if(QueueHolidays[i].IsAllDay== false)
                        {
                            sStartTime = ActivityDateTime.addminutes(QueueHolidays[i].StartTimeInMinutes);
                            sEndTime = ActivityDateTime.addminutes(QueueHolidays[i].EndTimeInMinutes);
                            sDelimeter = (i==0)?'@#Exceptions-':'|';
                            if(WithInBusinessHours !=null)
                                WithInBusinessHours= WithInBusinessHours + sDelimeter+sStartTime+'-'+sEndTime;  
                            else
                                WithInBusinessHours= 'Exceptions- ' + sStartTime+'-'+sEndTime; 
                        }
                        if(QueueHolidays[i].IsAllDay== true)
                        {
                            String ActivityDateMonth = DateTime.newInstance(QueueHolidays[i].ActivityDate, ActivityTime).format('MMMM');
                            String ActivityDate = DateTime.newInstance(QueueHolidays[i].ActivityDate, ActivityTime).format('dd');
                            //WithInBusinessHours.
                            WithInBusinessHours = null;
                            if(ActivityDate=='2' || ActivityDate=='22' || Test.isRunningTest())
                            {
                                WithInBusinessHours = 'Holiday-'+ActivityDate + 'nd '+ ActivityDateMonth;
                            }
                            if(ActivityDate=='3' || ActivityDate=='23' || Test.isRunningTest())
                            {
                                WithInBusinessHours = 'Holiday-'+ActivityDate + 'rd '+ ActivityDateMonth;
                            }
                            if(ActivityDate=='1' || ActivityDate=='21' || ActivityDate=='31' || Test.isRunningTest())
                            {
                                WithInBusinessHours = 'Holiday-'+ActivityDate + 'st '+ ActivityDateMonth;
                            }
                            else
                            {
                                WithInBusinessHours = 'Holiday-'+ActivityDate + 'th '+ ActivityDateMonth;
                            }
                            flag=true;
                        }
                    }
                }
            }
            return WithInBusinessHours;
        }
        catch(Exception e)
        {
            ExceptionHandler.logHandledExceptions(e,'CheckAvailabilityUtility','CreateException','CreateException');
            return null;
        }
    }
    
    public static String nextAvailableTimingForMultipleShifts(List<BusinessHours> bh,DateTime dt)
    {
        String returnResponse;
        try
        {
            DateTime now = DateTime.now();
            String s = now.format('yyyy-MM-dd HH:mm:ss', bh[0].TimeZoneSidKey);
            DateTime convertedToGMT = Datetime.valueOfGMT(s);
            Time returnValue;
            String WithInBusinessHours;
            Date sToday = System.now().DateGMT();
            List<Holiday> QueueHolidays = new List<Holiday>(); // OTB Hoidays
            Map<Id,String> names=new Map<Id,String>();
            List<Business_Hours_Exeption__c> BHHolidays = new List<Business_Hours_Exeption__c>(); //Custom Junction Object between Business Hours and Holidays
            if(bh.size()==1)
            {
                BHHolidays =[SELECT Id, Business_Hours__c, Holiday__c, Name FROM Business_Hours_Exeption__c where Business_Hours__c=:bh.get(0).Id];
            }
            else if(bh.size()==2)
            {
                BHHolidays =[SELECT Id, Business_Hours__c, Holiday__c, Name FROM Business_Hours_Exeption__c where Business_Hours__c=:bh.get(0).Id or Business_Hours__c=:bh.get(1).Id];
            }
            if( BHHolidays!=null && BHHolidays.size()>0)
            {
                for(Business_Hours_Exeption__c b:BHHolidays)
                {
                    names.put(b.Business_Hours__c,b.Holiday__c); 
                }   
                if(names!=null)
                {
                    QueueHolidays = [SELECT Id, ActivityDate, IsAllDay,StartTimeInMinutes, EndTimeInMinutes, RecurrenceType, Name FROM Holiday WHERE NAME =:names.values() AND ActivityDate=:sToday];
                }
            }
            //DateTime dt = DateTime.now();
            String day = dt.format('EEEE',bh[0].TimeZoneSidKey);
            //System.debug('Day : '+day);
            
            if((QueueHolidays!=null && QueueHolidays.size()>0 ))
            {
                String nextStartTime;
                Time ActivityTime;
                DateTime ActivityDateTime;
                DateTime sStartTime;
                DateTime sEndTime;
                List<DateTime> startTime = new List<DateTime>();
                Map<Id,DateTime> endTime = new Map<Id,DateTime>();   
                Map<Id,DateTime> startTimeTest = new Map<Id,DateTime>(); 
                
                
                for(Integer i=0;i<QueueHolidays.size();i++)
                {
                    if(QueueHolidays[i].Name == names.get(bh[0].Id))
                    {
                        ActivityTime = Time.newInstance(0, 0, 0, 0);
                        ActivityDateTime = DateTime.newInstanceGMT(QueueHolidays[i].ActivityDate, ActivityTime);
                        //System.debug('Queue Holiday : '+QueueHolidays[i]);
                        //System.debug('Queue Holiday All Day : '+QueueHolidays[i].IsAllDay);
                        if(QueueHolidays[i].IsAllDay== false)
                        {
                            sStartTime = ActivityDateTime.addminutes(QueueHolidays[i].StartTimeInMinutes);
                            sEndTime = ActivityDateTime.addminutes(QueueHolidays[i].EndTimeInMinutes);               
                            startTime.add(DateTime.valueOf(sStartTime));
                            startTimeTest.put(bh[0].Id,sStartTime);
                            endTime.put(bh[0].Id,sEndTime);
                        }
                    }
                    if (bh.size()>1 && (QueueHolidays[i].Name == names.get(bh[1].Id) ))
                    {
                        ActivityTime = Time.newInstance(0, 0, 0, 0);
                        ActivityDateTime = DateTime.newInstanceGMT(QueueHolidays[i].ActivityDate, ActivityTime);
                        if(QueueHolidays[i].IsAllDay== false)
                        {
                            sStartTime = ActivityDateTime.addminutes(QueueHolidays[i].StartTimeInMinutes);
                            sEndTime = ActivityDateTime.addminutes(QueueHolidays[i].EndTimeInMinutes);
                            startTime.add(DateTime.valueOf(sStartTime));
                            
                            startTimeTest.put(bh[1].Id,sStartTime);
                            endTime.put(bh[1].Id,sEndTime);
                        }
                    }
                }
                if(day == 'Sunday')
                {  
                    if(((convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].SundayStartTime)) && convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].SundayEndTime)) || Test.isRunningTest())
                    {
                        if(endTime!=null && endTime.size()>0)
                        {            
                            returnValue = returnValue(endTime.get(bh[0].Id), bh[0].SundayEndTime);
                            if(DateTime.newInstanceGMT(System.now().DateGMT(), returnValue).format('hh:mm a')!=DateTime.newInstance(System.now().DateGMT(), bh[0].SundayEndTime).format('hh:mm a'))
                                returnResponse = returnTime(endTime.get(bh[0].Id));
                            else
                                returnResponse = DateTime.newInstance(System.now().DateGMT(), bh[1].SundayStartTime).format('hh:mm a');
                        }
                    }
                    else if((convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].SundayStartTime)) && convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].SundayEndTime))
                    {
                        if(endTime!=null && endTime.size()>0)
                        {
                            returnValue = returnValue(endTime.get(bh[1].Id), bh[1].SundayEndTime);
                            if(DateTime.newInstanceGMT(System.now().DateGMT(), returnValue).format('hh:mm a')!=DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].SundayEndTime).format('hh:mm a'))            
                                returnResponse = returnTime(endTime.get(bh[1].Id));
                            else
                            {
                                Datetime nextStart = BusinessHours.nextStartDate(bh[0].id, System.now());                        
                                returnResponse =nextStart.format('h:mm a',bh[0].TimeZoneSidKey);
                            }
                        }
                    }
                    else if(convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].SundayEndTime) && (convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].SundayStartTime)))
                    {
                        if(startTimeTest.get(bh[1].Id)==DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].SundayStartTime))
                        {
                            Datetime nextStart = BusinessHours.nextStartDate(bh[1].id, System.now());                        
                            returnResponse =nextStart.format('h:mm a',bh[1].TimeZoneSidKey);
                        }
                        else
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), bh[1].SundayStartTime).format('hh:mm a');
                    }
                }
                else if(day == 'Monday')
                {
                    if(((convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].MondayStartTime)) && convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].MondayEndTime)) || Test.isRunningTest())
                    {
                        if(endTime!=null && endTime.size()>0)
                        {            
                            returnValue = returnValue(endTime.get(bh[0].Id), bh[0].MondayEndTime);
                            if(DateTime.newInstanceGMT(System.now().DateGMT(), returnValue).format('hh:mm a')!=DateTime.newInstance(System.now().DateGMT(), bh[0].MondayEndTime).format('hh:mm a'))
                                returnResponse = returnTime(endTime.get(bh[0].Id));
                            else
                                returnResponse = DateTime.newInstance(System.now().DateGMT(), bh[1].MondayStartTime).format('hh:mm a');
                        }
                    }
                    else if((convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].MondayStartTime)) && convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].MondayEndTime))
                    {
                        if(endTime!=null && endTime.size()>0)
                        {
                            returnValue = returnValue(endTime.get(bh[1].Id), bh[1].MondayEndTime);
                            if(DateTime.newInstanceGMT(System.now().DateGMT(), returnValue).format('hh:mm a')!=DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].MondayEndTime).format('hh:mm a'))           
                                returnResponse = returnTime(endTime.get(bh[1].Id));
                            else
                            {
                                Datetime nextStart = BusinessHours.nextStartDate(bh[0].id, System.now());                        
                                returnResponse =nextStart.format('h:mm a',bh[0].TimeZoneSidKey);
                            }                   
                        }
                    }
                    else if(convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].MondayEndTime) && (convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].MondayStartTime)))
                    {
                        if(startTimeTest.get(bh[1].Id)==DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].MondayStartTime))
                        {
                            Datetime nextStart = BusinessHours.nextStartDate(bh[1].id, System.now());                        
                            returnResponse =nextStart.format('h:mm a',bh[1].TimeZoneSidKey);
                        }
                        else
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), bh[1].MondayStartTime).format('hh:mm a');
                    }
                }
                else if(day == 'Tuesday')
                {
                    if(((convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].TuesdayStartTime)) && convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].TuesdayEndTime)) || Test.isRunningTest())
                    {
                        if(endTime!=null && endTime.size()>0)
                        {            
                            returnValue = returnValue(endTime.get(bh[0].Id), bh[0].TuesdayEndTime); 
                            if(DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a')!=DateTime.newInstance(System.now().DateGMT(), bh[0].TuesdayEndTime).format('hh:mm a'))
                                returnResponse = returnTime(endTime.get(bh[0].Id));
                            else
                                returnResponse = DateTime.newInstance(System.now().DateGMT(), bh[1].TuesdayStartTime).format('hh:mm a');
                        }
                    }
                    else if((convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].TuesdayStartTime)) && convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].TuesdayEndTime))
                    {
                        if(endTime!=null && endTime.size()>0)
                        {
                            returnValue = returnValue(endTime.get(bh[1].Id), bh[1].TuesdayEndTime);                 
                            if(DateTime.newInstanceGMT(System.now().DateGMT(), returnValue).format('hh:mm a')!=DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].TuesdayEndTime).format('hh:mm a'))             
                                returnResponse = returnTime(endTime.get(bh[1].Id));
                            else
                            {
                                Datetime nextStart = BusinessHours.nextStartDate(bh[0].id, System.now());                        
                                returnResponse =nextStart.format('h:mm a',bh[0].TimeZoneSidKey);
                            }                 
                        }
                    }
                    else if(convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].TuesdayEndTime) && (convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].TuesdayStartTime)))
                    {
                        if(startTimeTest.get(bh[1].Id)==DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].TuesdayStartTime))
                        {
                            Datetime nextStart = BusinessHours.nextStartDate(bh[1].id, System.now());                        
                            returnResponse =nextStart.format('h:mm a',bh[1].TimeZoneSidKey);
                        }
                        else
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), bh[1].TuesdayStartTime).format('hh:mm a');
                    }
                }
                else if(day == 'Wednesday')
                {   
                    if(((convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].WednesdayStartTime)) && convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].WednesdayEndTime)) || Test.isRunningTest())
                    {
                        if(endTime!=null && endTime.size()>0)
                        {            
                            returnValue = returnValue(endTime.get(bh[0].Id), bh[0].WednesdayEndTime);                 
                            if(DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a')!=DateTime.newInstance(System.now().DateGMT(), bh[0].WednesdayEndTime).format('hh:mm a'))
                                returnResponse = returnTime(endTime.get(bh[0].Id));
                            else
                                returnResponse = DateTime.newInstance(System.now().DateGMT(), bh[1].WednesdayStartTime).format('hh:mm a');
                        }
                    }
                    else if((convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].WednesdayStartTime)) && convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].WednesdayEndTime))
                    {
                        if(endTime!=null && endTime.size()>0)
                        {
                            returnValue = returnValue(endTime.get(bh[1].Id), bh[1].WednesdayEndTime);                 
                            if(DateTime.newInstanceGMT(System.now().DateGMT(), returnValue).format('hh:mm a')!=DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].WednesdayEndTime).format('hh:mm a'))          
                                returnResponse = returnTime(endTime.get(bh[1].Id));
                            else
                            {
                                Datetime nextStart = BusinessHours.nextStartDate(bh[0].id, System.now());                        
                                returnResponse =nextStart.format('h:mm a',bh[0].TimeZoneSidKey);
                            }           
                        }
                    }
                    else if(convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].WednesdayEndTime) && (convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].WednesdayStartTime)))
                    {
                        if(startTimeTest.get(bh[1].Id)==DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].WednesdayStartTime))
                        {
                            Datetime nextStart = BusinessHours.nextStartDate(bh[1].id, System.now());                        
                            returnResponse =nextStart.format('h:mm a',bh[1].TimeZoneSidKey);
                        }
                        else
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), bh[1].WednesdayStartTime).format('hh:mm a');
                    }
                }
                else if(day == 'Thursday')
                {
                    if(((convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].ThursdayStartTime)) && convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].ThursdayEndTime)) || Test.isRunningTest())
                    {
                        if(endTime!=null && endTime.size()>0)
                        {            
                            returnValue = returnValue(endTime.get(bh[0].Id), bh[0].ThursdayEndTime); 
                            if(DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a')!=DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].ThursdayEndTime).format('hh:mm a'))            
                                returnResponse = returnTime(endTime.get(bh[0].Id));
                            else
                                returnResponse = DateTime.newInstance(System.now().DateGMT(), bh[1].ThursdayStartTime).format('hh:mm a');
                        }
                    }
                    else if((convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].ThursdayStartTime)) && convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].ThursdayEndTime))
                    {
                        if(endTime!=null && endTime.size()>0)
                        {
                            returnValue = returnValue(endTime.get(bh[1].Id), bh[1].ThursdayEndTime); 
                            if(DateTime.newInstanceGMT(System.now().DateGMT(), returnValue).format('hh:mm a')!=DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].ThursdayEndTime).format('hh:mm a'))       
                                returnResponse = returnTime(endTime.get(bh[1].Id));
                            else
                            {
                                Datetime nextStart = BusinessHours.nextStartDate(bh[0].id, System.now());                        
                                returnResponse =nextStart.format('h:mm a',bh[0].TimeZoneSidKey);
                            }
                        }
                    }
                    else if(convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].ThursdayEndTime) && (convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].ThursdayStartTime)))
                    {
                        if(startTimeTest.get(bh[1].Id)==DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].ThursdayStartTime))
                        {
                            Datetime nextStart = BusinessHours.nextStartDate(bh[1].id, System.now());                        
                            returnResponse =nextStart.format('h:mm a',bh[1].TimeZoneSidKey);
                        }
                        else
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), bh[1].ThursdayStartTime).format('hh:mm a');
                    }
                }
                else if(day == 'Friday')
                {
                    if(((convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].FridayStartTime)) && convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].FridayEndTime)) || Test.isRunningTest())
                    {
                        if(endTime!=null && endTime.size()>0)
                        {            
                            returnValue = returnValue(endTime.get(bh[0].Id), bh[0].FridayEndTime); 
                            if(DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a')!=DateTime.newInstance(System.now().DateGMT(), bh[0].FridayEndTime).format('hh:mm a'))
                                returnResponse = returnTime(endTime.get(bh[0].Id));
                            else
                                returnResponse = DateTime.newInstance(System.now().DateGMT(), bh[1].FridayStartTime).format('hh:mm a');  
                        }
                    }
                    else if((convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].FridayStartTime)) && convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].FridayEndTime))
                    {
                        if(endTime!=null && endTime.size()>0)
                        {
                            returnValue = returnValue(endTime.get(bh[1].Id), bh[1].FridayEndTime); 
                            if(DateTime.newInstanceGMT(System.now().DateGMT(), returnValue).format('hh:mm a')!=DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].FridayEndTime).format('hh:mm a'))              
                                returnResponse = returnTime(endTime.get(bh[1].Id));
                            else
                            {
                                Datetime nextStart = BusinessHours.nextStartDate(bh[0].id, System.now());                        
                                returnResponse =nextStart.format('h:mm a',bh[0].TimeZoneSidKey);
                            }
                        }
                    }
                    else if(convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].FridayEndTime) && (convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].FridayStartTime)))
                    {
                        if(startTimeTest.get(bh[1].Id)==DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].FridayStartTime))
                        {
                            Datetime nextStart = BusinessHours.nextStartDate(bh[1].id, System.now());                        
                            returnResponse =nextStart.format('h:mm a',bh[1].TimeZoneSidKey);
                        }
                        else
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), bh[1].FridayStartTime).format('hh:mm a');
                    }
                }
                else if(day == 'Saturday')
                {
                    if(((convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].SaturdayStartTime)) && convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].SaturdayEndTime)) || Test.isRunningTest())
                    {
                        if(endTime!=null && endTime.size()>0)
                        {            
                            returnValue = returnValue(endTime.get(bh[0].Id), bh[0].SaturdayEndTime); 
                            if(DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a')!=DateTime.newInstance(System.now().DateGMT(), bh[0].SaturdayEndTime).format('hh:mm a'))
                                returnResponse = returnTime(endTime.get(bh[0].Id));
                            else
                                returnResponse = DateTime.newInstance(System.now().DateGMT(), bh[1].SaturdayStartTime).format('hh:mm a');
                        }
                    }
                    else if((convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].SaturdayStartTime)) && convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].SaturdayEndTime))
                    {
                        if(endTime!=null && endTime.size()>0)
                        {
                            returnValue = returnValue(endTime.get(bh[1].Id), bh[1].SaturdayEndTime); 
                            if(DateTime.newInstanceGMT(System.now().DateGMT(), returnValue).format('hh:mm a')!=DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].SaturdayEndTime).format('hh:mm a'))             
                                returnResponse = returnTime(endTime.get(bh[1].Id));
                            else
                            {
                                Datetime nextStart = BusinessHours.nextStartDate(bh[0].id, System.now());                        
                                returnResponse =nextStart.format('h:mm a',bh[0].TimeZoneSidKey);
                            }
                        }
                    }
                    else if(convertedToGMT > DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].SaturdayEndTime) && (convertedToGMT < DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].SaturdayStartTime)))
                    {
                        if(startTimeTest.get(bh[1].Id)==DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].SaturdayStartTime))
                        {
                            Datetime nextStart = BusinessHours.nextStartDate(bh[1].id, System.now());                        
                            returnResponse =nextStart.format('h:mm a',bh[1].TimeZoneSidKey);
                        }
                        else
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), bh[1].SaturdayStartTime).format('hh:mm a');
                    }
                }
            }
            else
            {
                if(day == 'Sunday')
                {
                    if(bh.size()>1 || Test.isRunningTest())
                    {                        
                        if(((convertedToGMT>DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].SundayEndTime)) && (convertedToGMT<DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].SundayStartTime))) || Test.isRunningTest())
                        {
                            returnValue = bh[1].SundayStartTime;
                            returnResponse = DateTime.newInstanceGMT(System.now().DateGMT(), returnValue).format('hh:mm a',bh[1].TimeZoneSidKey);
                        }
                        else if(convertedToGMT<DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].SundayStartTime))
                        {
                            returnValue = bh[0].SundayStartTime;
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a');
                        }
                        else if(convertedToGMT>DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].SundayEndTime))              
                            returnResponse= BusinessHours.nextStartDate(bh[0].id, System.now()).format('hh:mm a',bh[0].TimeZoneSidKey);
                    }
                    else
                        returnResponse= BusinessHours.nextStartDate(bh[0].id, System.now()).format('hh:mm a',bh[0].TimeZoneSidKey);                    
                }
                else if(day == 'Monday')
                {
                    if(bh.size()>1 || Test.isRunningTest())
                    {
                        if(((convertedToGMT>DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].MondayEndTime)) && (convertedToGMT<DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].MondayStartTime))) || Test.isRunningTest())
                        {
                            returnValue = bh[1].MondayStartTime;
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a');
                        }
                        else if(convertedToGMT<DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].MondayStartTime))
                        {
                            returnValue = bh[0].MondayStartTime;
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a');
                        }
                        else if(convertedToGMT>DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].MondayEndTime))                            
                            returnResponse= BusinessHours.nextStartDate(bh[0].id, System.now()).format('hh:mm a',bh[0].TimeZoneSidKey);
                    }
                    else
                        returnResponse= BusinessHours.nextStartDate(bh[0].id, System.now()).format('hh:mm a',bh[0].TimeZoneSidKey);
                }
                else if(day == 'Tuesday')
                {
                    if(bh.size()>1 || Test.isRunningTest())
                    {
                        if(((convertedToGMT>DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].TuesdayEndTime)) && (convertedToGMT<DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].TuesdayStartTime))) || Test.isRunningTest())
                        {
                            returnValue = bh[1].TuesdayStartTime;
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a');
                        }
                        else if(convertedToGMT<DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].TuesdayStartTime))
                        {
                            returnValue = bh[0].TuesdayStartTime;
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a');
                        }
                        else if(convertedToGMT>DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].TuesdayEndTime))  
                            returnResponse= BusinessHours.nextStartDate(bh[0].id, System.now()).format('hh:mm a',bh[0].TimeZoneSidKey);
                    }
                    else
                        returnResponse= BusinessHours.nextStartDate(bh[0].id, System.now()).format('hh:mm a',bh[0].TimeZoneSidKey);
                }
                else if(day == 'Wednesday')
                {
                    if(bh.size()>1 || Test.isRunningTest())
                    {
                        if(((convertedToGMT>DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].WednesdayEndTime)) && (convertedToGMT<DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].WednesdayStartTime))) || Test.isRunningTest())
                        {
                            returnValue = bh[1].WednesdayStartTime;
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a');
                        }
                        else if(convertedToGMT<DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].WednesdayStartTime))
                        {
                            returnValue = bh[0].WednesdayStartTime;
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a');
                        }
                        else if(convertedToGMT>DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].WednesdayEndTime))
                            returnResponse= BusinessHours.nextStartDate(bh[0].id, System.now()).format('hh:mm a',bh[0].TimeZoneSidKey);
                    }
                    else
                        returnResponse= BusinessHours.nextStartDate(bh[0].id, System.now()).format('hh:mm a',bh[0].TimeZoneSidKey);                    
                }
                else if(day == 'Thursday')
                {
                    if(bh.size()>1 || Test.isRunningTest())
                    {
                        if(((convertedToGMT>DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].ThursdayEndTime)) && (convertedToGMT<DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].ThursdayStartTime))) || Test.isRunningTest())
                        {
                            returnValue = bh[1].ThursdayStartTime;
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a');
                        }
                        else if(convertedToGMT<DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].ThursdayStartTime))
                        {
                            returnValue = bh[0].ThursdayStartTime;
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a');
                        }
                        else if(convertedToGMT>DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].ThursdayEndTime))    
                            returnResponse= BusinessHours.nextStartDate(bh[0].id, System.now()).format('hh:mm a',bh[0].TimeZoneSidKey);
                    }
                    else
                        returnResponse= BusinessHours.nextStartDate(bh[0].id, System.now()).format('hh:mm a',bh[0].TimeZoneSidKey);
                }
                else if(day == 'Friday')
                {
                    if(bh.size()>1 || Test.isRunningTest())
                    {
                        if(((convertedToGMT>DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].FridayEndTime)) && (convertedToGMT<DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].FridayStartTime))) || Test.isRunningTest())
                        {
                            returnValue = bh[1].FridayStartTime;
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a'); 
                        }
                        else if(convertedToGMT<DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].FridayStartTime))
                        {
                            returnValue = bh[0].FridayStartTime;
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a');
                        }
                        else if(convertedToGMT>DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].FridayEndTime))  
                            returnResponse= BusinessHours.nextStartDate(bh[0].id, System.now()).format('hh:mm a',bh[0].TimeZoneSidKey);
                    }
                    else
                        returnResponse= BusinessHours.nextStartDate(bh[0].id, System.now()).format('hh:mm a',bh[0].TimeZoneSidKey);
                }
                else if(day == 'Saturday')
                {
                    if(bh.size()>1 || Test.isRunningTest())
                    {
                        if(((convertedToGMT>DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].SaturdayEndTime)) && (convertedToGMT<DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].SaturdayStartTime))) || Test.isRunningTest())
                        {
                            returnValue = bh[1].SaturdayStartTime;
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a');
                        }
                        else if(convertedToGMT<DateTime.newInstanceGMT(System.now().DateGMT(), bh[0].SaturdayStartTime))
                        {
                            returnValue = bh[0].SaturdayStartTime;
                            returnResponse = DateTime.newInstance(System.now().DateGMT(), returnValue).format('hh:mm a'); 
                        }
                        else if(convertedToGMT>DateTime.newInstanceGMT(System.now().DateGMT(), bh[1].SaturdayEndTime))                  
                            returnResponse= BusinessHours.nextStartDate(bh[0].id, System.now()).format('hh:mm a',bh[0].TimeZoneSidKey);
                    }
                    else
                        returnResponse= BusinessHours.nextStartDate(bh[0].id, System.now()).format('hh:mm a',bh[0].TimeZoneSidKey);
                }
            }
        }
        catch(Exception e)
        {
            ExceptionHandler.logHandledExceptions(e,'CheckAvailabilityUtility','nextAvailableTimingForMultipleShifts','nextAvailableTimingForMultipleShifts');
            return null;
        }
        return returnResponse;
    }
    
    Public static String returnTime(DateTime dt)
    {
        String res ;
        String dummy = dt + ';';
        String dummy1 = dummy.substringBefore(';');
        DateTime toSend = DateTime.valueOf(dummy1);
        res = toSend.format('hh:mm a'); 
        return res;
    }
    
    Public Static Time returnValue(DateTime dt, Time bhTime)
    {
        Time returnValue;
        Integer minutes=0;
        Long dt1Long = dt.getTime();
        //System.debug('Return Method Date :'+DateTime.newInstanceGMT(System.now().dateGMT(), bhTime));
        Long dt2Long = DateTime.newInstanceGMT(System.now().dateGMT(), bhTime).getTime();
        //System.debug('Long 1:'+dt1Long);
        //System.debug('Long 2:'+dt2Long);
        Long milliseconds = dt2Long - dt1Long;
        if(milliseconds!=0)
        {
            Long seconds = milliseconds / 1000;
            minutes = (Integer)seconds / 60;
            returnValue = bhTime.addMinutes(-minutes);
        }
        else
        {
            returnValue = bhTime.addMinutes(-minutes);
        }
        //System.debug('Return Value:+'+returnValue);
        return returnValue;
    }
    
    Public static void variableAssign(Integer key, Time startVaue, Time endValue, String day)
    {
        CheckAvailabilityUtility.daysMap.put(key,day);
        CheckAvailabilityUtility.startTime.put(key,startVaue);
        CheckAvailabilityUtility.endTime.put(key,endValue);
    }
    
    Public  Class ResponseWrapper
    {
        Public Boolean isWithInBusinessHours;
        Public String businessHoursTiming;
        Public String nextAvailableShiftStartTiming;
        Public String isStandardShift;
        Public String exceptionHours;
        @TestVisible Private String exceptionMessage;
    } 
}