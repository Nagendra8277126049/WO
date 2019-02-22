/**
 * Created by tdavis on 10/19/18.
 */

public class GetAppsPlanningTaskRequest
{
    public Task Task { get; set; }
    public Integer TimeOut { get; set; }
    public String Profile { get; set; }
    public Period Period { get; set; }

    public GetAppsPlanningTaskRequest(Boolean isRemote)
    {
        this.Task = new Task(isRemote);
        this.Period = new Period();

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
        public String Latitude { get; set; }
        public String Longitude { get; set; }
        public Integer Duration { get; set; }
        public Boolean IsAppointment { get; set; }
        public PS_TimeZone PS_TimeZone { get; set; }
        public TaskType TaskType { get; set; }
        public List<RequiredEngineers> RequiredEngineers { get; set; }
        public List<ExcludedEngineers> ExcludedEngineers { get; set; }
        public PS_BusinessUnit PS_BusinessUnit { get; set; }
        public List<RequiredSkills1> RequiredSkills1 { get; set; }
        public Boolean PS_IsRemote { get; set; }
        public Continent Continent { get; set; }
        public WorkingArea WorkingArea { get; set; }

        public Task(Boolean isRemote)
        {
            this.PS_TimeZone = new PS_TimeZone();
            this.TaskType = new TaskType();
            this.RequiredEngineers = new List<RequiredEngineers>();
            this.ExcludedEngineers = new List<ExcludedEngineers>();
            this.PS_BusinessUnit = new PS_BusinessUnit();
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

    public class PS_TimeZone
    {
        public String Name { get; set; }

        public PS_TimeZone()
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

    public class PS_BusinessUnit
    {
        public String Name { get; set; }

        public PS_BusinessUnit()
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

    public class Key
    {
        public String ID { get; set; }

        public Key()
        {

        }
    }

    public class Period
    {
        public String Start { get; set; }
        public String Finish { get; set; }

        public Period()
        {

        }
    }
}