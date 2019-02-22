@isTest()
global class GscvCalloutMock implements HttpCalloutMock {
	global HttpResponse respond(HttpRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Code":"WISTR","status":"success"}');
        res.setStatusCode(200);
        return res; 
    }
}