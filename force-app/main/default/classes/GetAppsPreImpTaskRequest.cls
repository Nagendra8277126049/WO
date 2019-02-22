/**
 * Created by tdavis on 10/31/18.
 */

public with sharing class GetAppsPreImpTaskRequest
{
    public Task Task { get; set; }
    public RelatedTasks RelatedTasks { get; set; }
    public Integer TimeOut { get; set; }
    public String Profile { get; set; }
    public Period Period { get; set; }
    public SameSlotTasks SameSlotTasks { get; set; }

    public GetAppsPreImpTaskRequest(Boolean isRemote)
    {
        this.Task = new Task(isRemote);
        this.RelatedTasks = new RelatedTasks();
        this.Period = new Period();
        this.SameSlotTasks = new SameSlotTasks();

    }

    public class Task
    {
        public String objectType { get; set; }
        public Boolean createOrUpdate { get; set; }
        public String CallID { get; set; }
        public String ExternalRefID { get; set; }
        public Integer Number_Z { get; set; } // in json: Number
        public Integer Duration { get; set; }
        public String EarlyStart { get; set; }
        public String DueDate { get; set; }
        public String Latitude { get; set; }
        public String Longitude { get; set; }
        public Boolean IsAppointment { get; set; }
        public PS_TimeZone PS_TimeZone { get; set; }
        public TaskType TaskType { get; set; }
        public PS_BusinessUnit PS_BusinessUnit { get; set; }
        public List<RequiredSkills1> RequiredSkills1 { get; set; }
        public Boolean Critical { get; set; }
        public List<RequiredEngineers> RequiredEngineers { get; set; }
        public List<TimeDependencies> TimeDependencies { get; set; }
        public List<EngineerDependencies> EngineerDependencies { get; set; }
        public Boolean PS_IsRemote { get; set; }
        public Continent Continent { get; set; }
        public WorkingArea WorkingArea { get; set; }

        public Task(Boolean isRemote)
        {
            this.PS_TimeZone = new PS_TimeZone();
            this.TaskType = new TaskType();
            this.PS_BusinessUnit = new PS_BusinessUnit();
            this.RequiredSkills1 = new List<RequiredSkills1>();
            this.RequiredEngineers = new List<RequiredEngineers>();
            this.TimeDependencies = new List<TimeDependencies>();
            this.EngineerDependencies = new List<EngineerDependencies>();
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

    public class InnerArray
    {
        public String objectType { get; set; }
        public Boolean createOrUpdate { get; set; }
        public String CallID { get; set; }
        public String ExternalRefID { get; set; }
        public Integer Number_Z { get; set; } // in json: Number
        public Integer Duration { get; set; }
        public String Latitude { get; set; }
        public String Longitude { get; set; }
        public Boolean IsAppointment { get; set; }
        public String EarlyStart { get; set; }
        public String DueDate { get; set; }
        public PS_TimeZone PS_TimeZone { get; set; }
        public TaskType TaskType { get; set; }
        public PS_BusinessUnit PS_BusinessUnit { get; set; }
        public List<RequiredSkills1> RequiredSkills1 { get; set; }
        public Boolean Critical { get; set; }
        public Boolean PS_IsRemote { get; set; }
        public Continent Continent { get; set; }
        public WorkingArea WorkingArea { get; set; }

        public InnerArray(Boolean isRemote)
        {
            this.PS_TimeZone = new PS_TimeZone();
            this.TaskType = new TaskType();
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

    public class EngineerDependencies
    {
        public String objectType { get; set; }
        public TaskKey TaskKey { get; set; }
        public Integer RelationType { get; set; }

        public EngineerDependencies()
        {
            this.TaskKey = new TaskKey();
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

    public class SameSlotTasks
    {
        public List<InnerArray_Z> InnerArray { get; set; }

        public SameSlotTasks()
        {
            this.InnerArray = new List<InnerArray_Z>();
        }
    }

    public class TaskKey
    {
        public String ExternalRefID { get; set; }

        public TaskKey()
        {

        }
    }

    public class InnerArray_Z
    {
        public String objectType { get; set; }
        public String ExternalRefID { get; set; }

        public InnerArray_Z()
        {

        }
    }


    public class TimeDependencies
    {
        public String objectType { get; set; }
        public TaskKey TaskKey { get; set; }
        public Integer UpperBound { get; set; }
        public Integer LowerBound { get; set; }
        public Integer RelationType { get; set; }
        public Integer RelationOperator { get; set; }
        public Boolean Critical { get; set; }

        public TimeDependencies()
        {
            this.TaskKey = new TaskKey();
        }
    }

    public class RelatedTasks
    {
        public List<InnerArray> InnerArray { get; set; }

        public RelatedTasks()
        {
            this.InnerArray = new List<InnerArray>();
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