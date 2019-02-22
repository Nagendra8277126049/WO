/**
 * Created by tdavis on 11/1/18.
 */

public class ProcessTaskExResponse
{

    public class Status
    {
        public Integer Key { get; set; }
        public String DisplayString { get; set; }

        public Status(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'Key')
                        {
                            Key = parser.getIntegerValue();
                        }
                        else if (text == 'DisplayString')
                        {
                            DisplayString = parser.getText();
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Status consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Assignment
    {
        public String objectType { get; set; }
        public Integer Key { get; set; }
        public Integer Revision { get; set; }
        public Status Task { get; set; }
        public String Start { get; set; }
        public String Finish { get; set; }
        public String PS_EngineerID { get; set; }

        public Assignment(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'objectType')
                        {
                            objectType = parser.getText();
                        }
                        else if (text == 'Key')
                        {
                            Key = parser.getIntegerValue();
                        }
                        else if (text == 'Revision')
                        {
                            Revision = parser.getIntegerValue();
                        }
                        else if (text == 'Task')
                        {
                            Task = new Status(parser);
                        }
                        else if (text == 'Start')
                        {
                            Start = parser.getText();
                        }
                        else if (text == 'Finish')
                        {
                            Finish = parser.getText();
                        }
                        else if (text == 'PS_EngineerID')
                        {
                            PS_EngineerID = parser.getText();
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Assignment consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Task
    {
        public String objectType { get; set; }
        public Integer Key { get; set; }
        public Integer Revision { get; set; }
        public String CallID { get; set; }
        public Integer Number_Z { get; set; } // in json: Number
        public Status Status { get; set; }
        public String ExternalRefID { get; set; }

        public Task(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'objectType')
                        {
                            objectType = parser.getText();
                        }
                        else if (text == 'Key')
                        {
                            Key = parser.getIntegerValue();
                        }
                        else if (text == 'Revision')
                        {
                            Revision = parser.getIntegerValue();
                        }
                        else if (text == 'CallID')
                        {
                            CallID = parser.getText();
                        }
                        else if (text == 'Number')
                        {
                            Number_Z = parser.getIntegerValue();
                        }
                        else if (text == 'Status')
                        {
                            Status = new Status(parser);
                        }
                        else if (text == 'ExternalRefID')
                        {
                            ExternalRefID = parser.getText();
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Task consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class InnerArray
    {
        public Task Task { get; set; }
        public Assignment Assignment { get; set; }

        public InnerArray(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'Task')
                        {
                            Task = new Task(parser);
                        }
                        else if (text == 'Assignment')
                        {
                            Assignment = new Assignment(parser);
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'InnerArray consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public String ReturnCode { get; set; }
    public Task Task { get; set; }
    public Assignment Assignment { get; set; }
    public LinkedTasks LinkedTasks { get; set; }
    public Object SchedulingError { get; set; }

    public ProcessTaskExResponse(JSONParser parser)
    {
        while (parser.nextToken() != System.JSONToken.END_OBJECT)
        {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
            {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                {
                    if (text == 'ReturnCode')
                    {
                        ReturnCode = parser.getText();
                    }
                    else if (text == 'Task')
                    {
                        Task = new Task(parser);
                    }
                    else if (text == 'Assignment')
                    {
                        Assignment = new Assignment(parser);
                    }
                    else if (text == 'LinkedTasks')
                    {
                        LinkedTasks = new LinkedTasks(parser);
                    }
                    else if (text == 'SchedulingError')
                    {
                        SchedulingError = parser.readValueAs(Object.class);
                    }
                    else
                    {
                        System.debug(LoggingLevel.WARN, 'ProcessTaskExResponse consuming unrecognized property: ' + text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public class LinkedTasks
    {
        public List<InnerArray> InnerArray { get; set; }

        public LinkedTasks(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'InnerArray')
                        {
                            InnerArray = arrayOfInnerArray(parser);
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'LinkedTasks consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }


    public static ProcessTaskExResponse parse(String json)
    {
        System.JSONParser parser = System.JSON.createParser(json);
        return new ProcessTaskExResponse(parser);
    }

    public static void consumeObject(System.JSONParser parser)
    {
        Integer depth = 0;
        do
        {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT ||
                    curr == System.JSONToken.START_ARRAY)
            {
                depth++;
            }
            else if (curr == System.JSONToken.END_OBJECT ||
                    curr == System.JSONToken.END_ARRAY)
            {
                depth--;
            }
        }
        while (depth > 0 && parser.nextToken() != null);
    }


    private static List<InnerArray> arrayOfInnerArray(System.JSONParser p)
    {
        List<InnerArray> res = new List<InnerArray>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY)
        {
            res.add(new InnerArray(p));
        }
        return res;
    }
}