/**
 * Created by tdavis on 11/1/18.
 */

public class ProcessTaskExSLARequest
{
    public Task Task { get; set; }
    public List<String> TaskRequestedProperties { get; set; }
    public List<String> AssignmentRequestedProperties { get; set; }
    public Boolean ReturnAssignment { get; set; }
    public Boolean ReturnSchedulingError { get; set; }

    public ProcessTaskExSLARequest(Boolean isRemote)
    {
        this.Task = new Task(isRemote);
        this.TaskRequestedProperties = new List<String>();
        this.AssignmentRequestedProperties = new List<String>();
    }

    public class Task
    {
        public String objectType { get; set; }
        public Boolean createOrUpdate { get; set; }
        public String CallID { get; set; }
        public String ExternalRefID { get; set; }
        public Integer Number_Z { get; set; } // in json: Number
        public String DueDate { get; set; }
        public String EarlyStart { get; set; }
        public String City { get; set; }
        public String State { get; set; }
        public String Street { get; set; }
        public String Postcode { get; set; }
        public CountryID CountryID { get; set; }
        public PS_TimeZone PS_TimeZone { get; set; }
        public PS_BusinessUnit PS_BusinessUnit { get; set; }
        public List<ExcludedEngineers> ExcludedEngineers { get; set; }
        public List<RequiredEngineers> RequiredEngineers { get; set; }
        public TaskType TaskType { get; set; }
        public String Latitude { get; set; }
        public String Longitude { get; set; }
        public Integer Duration { get; set; }
        public List<RequiredSkills1> RequiredSkills1 { get; set; }
        public Boolean PS_IsRemote { get; set; }
        public Continent Continent { get; set; }
        public String PS_WorkOrderNumber_String { get; set; }
        public String PS_SRNumber_String { get; set; }
        public String PS_SANumber { get; set; }
        public String PS_SRID { get; set; }
        public String PS_WorkOrderID { get; set; }
        public String PS_OpenTextNodeID { get; set; }
        public WorkingArea WorkingArea { get; set; }
        public String Customer { get; set; }

        public Task(Boolean isRemote)
        {
            this.CountryID = new CountryID();
            this.PS_TimeZone = new PS_TimeZone();
            this.PS_BusinessUnit = new PS_BusinessUnit();
            this.ExcludedEngineers = new List<ExcludedEngineers>();
            this.RequiredEngineers = new List<RequiredEngineers>();
            this.TaskType = new TaskType();
            this.RequiredSkills1 = new List<RequiredSkills1>();
            this.WorkingArea = new WorkingArea();

            if (isRemote)
            {
                this.Continent = new Continent();
                this.Continent.Name = 'IDS Offshore';
            }
            else
            {
                this.Continent = null;
            }
        }
    }

    public class Continent
    {
        public String Name { get; set; }

        public Continent()
        {

        }
    }

    public class WorkingArea
    {
        public Integer Key { get; set; }

        public WorkingArea()
        {

        }
    }

    public class CountryID
    {
        public String Name { get; set; }

        public CountryID() 
        {

        }
    }

    public class PS_TimeZone
    {
        public String Name { get; set; }

        public PS_TimeZone()
        {

        }
    }

    public class RequiredSkills1
    {
        public String objectType { get; set; }
        public Key Key { get; set; }
        public Integer SkillLevel { get; set; }

        public RequiredSkills1()
        {
            this.Key = new Key();
        }
    }

    public class PS_BusinessUnit
    {
        public String Name { get; set; }

        public PS_BusinessUnit()
        {

        }
    }

    public class RequiredEngineers
    {
        public String ID { get; set; }

        public RequiredEngineers()
        {

        }
    }

    public class ExcludedEngineers
    {
        public String ID { get; set; }

        public ExcludedEngineers()
        {

        }
    }

    public class TaskType
    {
        public String Name { get; set; }

        public TaskType()
        {

        }
    }

    public class Key
    {
        public String ID { get; set; }

        public Key()
        {

        }
    }
}