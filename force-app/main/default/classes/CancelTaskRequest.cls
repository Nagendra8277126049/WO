/**
 * Created by tdavis on 11/2/18.
 */

public class CancelTaskRequest
{
    public Task Task { get; set; }
    public Boolean ReturnAssignment { get; set; }
    public Boolean ReturnSchedulingError { get; set; }
    public List<String> TaskRequestedProperties { get; set; }

    public CancelTaskRequest()
    {
        this.Task = new Task();
        this.TaskRequestedProperties = new List<String>();
    }

    public class Status
    {
        public String Name { get; set; }

        public Status()
        {

        }
    }

    public class Task
    {
        public String objectType { get; set; }
        public Boolean createOrUpdate { get; set; }
        public String CallID { get; set; }
        public String ExternalRefID { get; set; }
        public Integer Number_Z { get; set; } // in json: Number
        public Status Status { get; set; }

        public Task()
        {
            this.Status = new Status();
        }
    }
}