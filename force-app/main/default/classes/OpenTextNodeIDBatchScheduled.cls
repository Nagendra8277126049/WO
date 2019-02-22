/**
 * Created by tdavis on 2018-12-04.
 */

public class OpenTextNodeIDBatchScheduled implements Schedulable
{
    public void execute(SchedulableContext sc)
    {
        Database.executeBatch(new OpenTextNodeIDBatch(), 1);
    }
}