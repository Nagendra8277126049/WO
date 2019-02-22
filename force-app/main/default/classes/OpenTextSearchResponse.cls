/**
 * Created by tdavis on 2018-12-04.
 */

public class OpenTextSearchResponse
{

    public class Paging
    {
        public Integer limit_Z { get; set; } // in json: limit
        public Integer page { get; set; }
        public Integer page_total { get; set; }
        public Integer range_max { get; set; }
        public Integer range_min { get; set; }
        public String result_header_string { get; set; }
        public Integer total_count { get; set; }

        public Paging(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'limit')
                        {
                            limit_Z = parser.getIntegerValue();
                        }
                        else if (text == 'page')
                        {
                            page = parser.getIntegerValue();
                        }
                        else if (text == 'page_total')
                        {
                            page_total = parser.getIntegerValue();
                        }
                        else if (text == 'range_max')
                        {
                            range_max = parser.getIntegerValue();
                        }
                        else if (text == 'range_min')
                        {
                            range_min = parser.getIntegerValue();
                        }
                        else if (text == 'result_header_string')
                        {
                            result_header_string = parser.getText();
                        }
                        else if (text == 'total_count')
                        {
                            total_count = parser.getIntegerValue();
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Paging consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Data
    {
        public Asc_OTObjectDate self { get; set; }

        public Data(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'self')
                        {
                            self = new Asc_OTObjectDate(parser);
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Properties
    {
        public Boolean container { get; set; }
        public Integer container_size { get; set; }
        public String create_date { get; set; }
        public Integer create_user_id { get; set; }
        public String description { get; set; }
        public Description_multilingual description_multilingual { get; set; }
        public Object external_create_date { get; set; }
        public String external_identity { get; set; }
        public String external_identity_type { get; set; }
        public Object external_modify_date { get; set; }
        public String external_source { get; set; }
        public Boolean favorite { get; set; }
        public Integer id { get; set; }
        public Object mime_type { get; set; }
        public String modify_date { get; set; }
        public Integer modify_user_id { get; set; }
        public String name { get; set; }
        public Description_multilingual name_multilingual { get; set; }
        public Integer owner_group_id { get; set; }
        public Integer owner_user_id { get; set; }
        public Integer parent_id { get; set; }
        public String permissions_model { get; set; }
        public Boolean reserved { get; set; }
        public Object reserved_date { get; set; }
        public Boolean reserved_shared_collaboration { get; set; }
        public Integer reserved_user_id { get; set; }
        public Boolean rm_enabled { get; set; }
        public String short_summary { get; set; }
        public Integer size { get; set; }
        public String size_formatted { get; set; }
        public String summary { get; set; }
        public Integer type_Z { get; set; } // in json: type
        public String type_name { get; set; }
        public Boolean versions_control_advanced { get; set; }
        public Integer volume_id { get; set; }

        public Properties(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'container')
                        {
                            container = parser.getBooleanValue();
                        }
                        else if (text == 'container_size')
                        {
                            container_size = parser.getIntegerValue();
                        }
                        else if (text == 'create_date')
                        {
                            create_date = parser.getText();
                        }
                        else if (text == 'create_user_id')
                        {
                            create_user_id = parser.getIntegerValue();
                        }
                        else if (text == 'description')
                        {
                            description = parser.getText();
                        }
                        else if (text == 'description_multilingual')
                        {
                            description_multilingual = new Description_multilingual(parser);
                        }
                        else if (text == 'external_create_date')
                        {
                            external_create_date = parser.readValueAs(Object.class);
                        }
                        else if (text == 'external_identity')
                        {
                            external_identity = parser.getText();
                        }
                        else if (text == 'external_identity_type')
                        {
                            external_identity_type = parser.getText();
                        }
                        else if (text == 'external_modify_date')
                        {
                            external_modify_date = parser.readValueAs(Object.class);
                        }
                        else if (text == 'external_source')
                        {
                            external_source = parser.getText();
                        }
                        else if (text == 'favorite')
                        {
                            favorite = parser.getBooleanValue();
                        }
                        else if (text == 'id')
                        {
                            id = parser.getIntegerValue();
                        }
                        else if (text == 'mime_type')
                        {
                            mime_type = parser.readValueAs(Object.class);
                        }
                        else if (text == 'modify_date')
                        {
                            modify_date = parser.getText();
                        }
                        else if (text == 'modify_user_id')
                        {
                            modify_user_id = parser.getIntegerValue();
                        }
                        else if (text == 'name')
                        {
                            name = parser.getText();
                        }
                        else if (text == 'name_multilingual')
                        {
                            name_multilingual = new Description_multilingual(parser);
                        }
                        else if (text == 'owner_group_id')
                        {
                            owner_group_id = parser.getIntegerValue();
                        }
                        else if (text == 'owner_user_id')
                        {
                            owner_user_id = parser.getIntegerValue();
                        }
                        else if (text == 'parent_id')
                        {
                            parent_id = parser.getIntegerValue();
                        }
                        else if (text == 'permissions_model')
                        {
                            permissions_model = parser.getText();
                        }
                        else if (text == 'reserved')
                        {
                            reserved = parser.getBooleanValue();
                        }
                        else if (text == 'reserved_date')
                        {
                            reserved_date = parser.readValueAs(Object.class);
                        }
                        else if (text == 'reserved_shared_collaboration')
                        {
                            reserved_shared_collaboration = parser.getBooleanValue();
                        }
                        else if (text == 'reserved_user_id')
                        {
                            reserved_user_id = parser.getIntegerValue();
                        }
                        else if (text == 'rm_enabled')
                        {
                            rm_enabled = parser.getBooleanValue();
                        }
                        else if (text == 'short_summary')
                        {
                            short_summary = parser.getText();
                        }
                        else if (text == 'size')
                        {
                            size = parser.getIntegerValue();
                        }
                        else if (text == 'size_formatted')
                        {
                            size_formatted = parser.getText();
                        }
                        else if (text == 'summary')
                        {
                            summary = parser.getText();
                        }
                        else if (text == 'type')
                        {
                            type_Z = parser.getIntegerValue();
                        }
                        else if (text == 'type_name')
                        {
                            type_name = parser.getText();
                        }
                        else if (text == 'versions_control_advanced')
                        {
                            versions_control_advanced = parser.getBooleanValue();
                        }
                        else if (text == 'volume_id')
                        {
                            volume_id = parser.getIntegerValue();
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Properties consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Ancestors
    {
        public String href { get; set; }
        public String name { get; set; }

        public Ancestors(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'href')
                        {
                            href = parser.getText();
                        }
                        else if (text == 'name')
                        {
                            name = parser.getText();
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Ancestors consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Sorting
    {
        public Links links { get; set; }

        public Sorting(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'links')
                        {
                            links = new Links(parser);
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Sorting consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public Collection collection { get; set; }
    public Links_Z links { get; set; }
    public List<Results> results { get; set; }

    public OpenTextSearchResponse(JSONParser parser)
    {
        while (parser.nextToken() != System.JSONToken.END_OBJECT)
        {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
            {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                {
                    if (text == 'collection')
                    {
                        collection = new Collection(parser);
                    }
                    else if (text == 'links')
                    {
                        links = new Links_Z(parser);
                    }
                    else if (text == 'results')
                    {
                        results = arrayOfResults(parser);
                    }
                    else
                    {
                        System.debug(LoggingLevel.WARN, 'SearchResponse consuming unrecognized property: ' + text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public class Search_result_metadata
    {
        public Object current_version { get; set; }
        public Object object_href { get; set; }
        public String object_id { get; set; }
        public String result_type { get; set; }
        public String source_id { get; set; }
        public Object version_type { get; set; }

        public Search_result_metadata(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'current_version')
                        {
                            current_version = parser.readValueAs(Object.class);
                        }
                        else if (text == 'object_href')
                        {
                            object_href = parser.readValueAs(Object.class);
                        }
                        else if (text == 'object_id')
                        {
                            object_id = parser.getText();
                        }
                        else if (text == 'result_type')
                        {
                            result_type = parser.getText();
                        }
                        else if (text == 'source_id')
                        {
                            source_id = parser.getText();
                        }
                        else if (text == 'version_type')
                        {
                            version_type = parser.readValueAs(Object.class);
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Search_result_metadata consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Links_Z
    {
        public Data data { get; set; }

        public Links_Z(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'data')
                        {
                            data = new Data(parser);
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Links_Z consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Description_multilingual
    {
        public String en_US { get; set; }

        public Description_multilingual(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'en_US')
                        {
                            en_US = parser.getText();
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Description_multilingual consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Data_Z
    {
        public Properties properties { get; set; }

        public Data_Z(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'properties')
                        {
                            properties = new Properties(parser);
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Data_Z consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Searching
    {
        public Integer cache_id { get; set; }
        public String result_title { get; set; }

        public Searching(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'cache_id')
                        {
                            cache_id = parser.getIntegerValue();
                        }
                        else if (text == 'result_title')
                        {
                            result_title = parser.getText();
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Searching consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Links_Y
    {
        public List<Ancestors> ancestors { get; set; }
        public List<Ancestors> ancestors_nodes { get; set; }
        public Ancestors parent { get; set; }
        public Ancestors parent_nodes { get; set; }

        public Links_Y(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'ancestors')
                        {
                            ancestors = arrayOfAncestors(parser);
                        }
                        else if (text == 'ancestors_nodes')
                        {
                            ancestors_nodes = arrayOfAncestors(parser);
                        }
                        else if (text == 'parent')
                        {
                            parent = new Ancestors(parser);
                        }
                        else if (text == 'parent_nodes')
                        {
                            parent_nodes = new Ancestors(parser);
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Links_Y consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Results
    {
        public Data_Z data { get; set; }
        public Links_Y links { get; set; }
        public Search_result_metadata search_result_metadata { get; set; }

        public Results(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'data')
                        {
                            data = new Data_Z(parser);
                        }
                        else if (text == 'links')
                        {
                            links = new Links_Y(parser);
                        }
                        else if (text == 'search_result_metadata')
                        {
                            search_result_metadata = new Search_result_metadata(parser);
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Results consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Links
    {
        public Asc_OTObjectDate asc_OTObjectDate { get; set; }
        public Asc_OTObjectDate asc_OTObjectSize { get; set; }
        public Asc_OTObjectDate desc_OTObjectDate { get; set; }
        public Asc_OTObjectDate desc_OTObjectSize { get; set; }
        public Asc_OTObjectDate relevance { get; set; }

        public Links(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'asc_OTObjectDate')
                        {
                            asc_OTObjectDate = new Asc_OTObjectDate(parser);
                        }
                        else if (text == 'asc_OTObjectSize')
                        {
                            asc_OTObjectSize = new Asc_OTObjectDate(parser);
                        }
                        else if (text == 'desc_OTObjectDate')
                        {
                            desc_OTObjectDate = new Asc_OTObjectDate(parser);
                        }
                        else if (text == 'desc_OTObjectSize')
                        {
                            desc_OTObjectSize = new Asc_OTObjectDate(parser);
                        }
                        else if (text == 'relevance')
                        {
                            relevance = new Asc_OTObjectDate(parser);
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Links consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Collection
    {
        public Paging paging { get; set; }
        public Searching searching { get; set; }
        public Sorting sorting { get; set; }

        public Collection(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'paging')
                        {
                            paging = new Paging(parser);
                        }
                        else if (text == 'searching')
                        {
                            searching = new Searching(parser);
                        }
                        else if (text == 'sorting')
                        {
                            sorting = new Sorting(parser);
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Collection consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Asc_OTObjectDate
    {
        public String body { get; set; }
        public String content_type { get; set; }
        public String href { get; set; }
        public String method { get; set; }
        public String name { get; set; }

        public Asc_OTObjectDate(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'body')
                        {
                            body = parser.getText();
                        }
                        else if (text == 'content_type')
                        {
                            content_type = parser.getText();
                        }
                        else if (text == 'href')
                        {
                            href = parser.getText();
                        }
                        else if (text == 'method')
                        {
                            method = parser.getText();
                        }
                        else if (text == 'name')
                        {
                            name = parser.getText();
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Asc_OTObjectDate consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }


    public static OpenTextSearchResponse parse(String json)
    {
        System.JSONParser parser = System.JSON.createParser(json);
        return new OpenTextSearchResponse(parser);
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


    private static List<Ancestors> arrayOfAncestors(System.JSONParser p)
    {
        List<Ancestors> res = new List<Ancestors>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY)
        {
            res.add(new Ancestors(p));
        }
        return res;
    }


    private static List<Results> arrayOfResults(System.JSONParser p)
    {
        List<Results> res = new List<Results>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY)
        {
            res.add(new Results(p));
        }
        return res;
    }


}