public class ARRHttpResponseMockSuccess implements HttpCalloutMock {
    private string response;
    public ARRHttpResponseMockSuccess(){
        this.response = '{"SUCESS": "OK"}';
    }
    public ARRHttpResponseMockSuccess(string response){
        this.response = response;
    }
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(response);
        res.setStatusCode(200);
        return res;
    }
}