public class ARRHttpResponseMockError implements HttpCalloutMock {
	 public HTTPResponse respond(HTTPRequest req) {
		String jsonResponse = '{"ERROR": "ERROR"}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(jsonResponse);
        res.setStatusCode(500);
        return res;
     }
}