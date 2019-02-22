/**
 * Created by tdavis on 10/25/18.
 */

public class GetAppsResponse
{

    public class TimeInterval
    {
        public String Start { get; set; }
        public String Finish { get; set; }
        public Integer Grade { get; set; }
        public Object SuggestedArrangement { get; set; }

        public TimeInterval(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'Start')
                        {
                            Start = parser.getText();
                        }
                        else if (text == 'Finish')
                        {
                            Finish = parser.getText();
                        }
                        else if (text == 'Grade')
                        {
                            Grade = parser.getIntegerValue();
                        }
                        else if (text == 'SuggestedArrangement')
                        {
                            SuggestedArrangement = parser.readValueAs(Object.class);
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'TimeInterval consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public List<TimeInterval> TimeInterval { get; set; }

    public GetAppsResponse(JSONParser parser)
    {
        while (parser.nextToken() != System.JSONToken.END_OBJECT)
        {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
            {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                {
                    if (text == 'TimeInterval')
                    {
                        TimeInterval = arrayOfTimeInterval(parser);
                    }
                    else
                    {
                        System.debug(LoggingLevel.WARN, 'GetAppsResponse consuming unrecognized property: ' + text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public static GetAppsResponse parse(String json)
    {
        System.JSONParser parser = System.JSON.createParser(json);
        return new GetAppsResponse(parser);
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

    private static List<TimeInterval> arrayOfTimeInterval(System.JSONParser p)
    {
        List<TimeInterval> res = new List<TimeInterval>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY)
        {
            res.add(new TimeInterval(p));
        }
        return res;
    }
}