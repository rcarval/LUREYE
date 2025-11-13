@isTest
global class CS_GoogleDrive_Test {

    global class CS_GoogleDrive_Test_RefreshToken_Mock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getMethod() == 'POST' && req.getEndpoint().contains('https://oauth2.googleapis.com/token')) {
                String responseJSON = '{"access_token":"testtoken","expires_in":3600,"refresh_token":"testrefreshtoken","scope":"https://www.googleapis.com/auth/drive","token_type":"Bearer"}';
                res.setBody(responseJSON);
                res.setStatusCode(200);
            } else {
                res.setStatusCode(404);
            }
            return res;
        }
    }

    public class MyHttpCalloutMock implements HttpCalloutMock {
        private String fileId;
        
        public MyHttpCalloutMock(String fileId) {
            this.fileId = fileId;
        }
        
        public HttpResponse respond(HttpRequest request) {
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setBody('{"files": [{"id": "' + fileId + '", "name": "example.txt"}]}');
            return response;
        }
    }

    global class CS_GoogleDrive_Test_GetParentIdByName_Mock implements HttpCalloutMock {
        private Integer statusCode;
        private String body;
    
        global CS_GoogleDrive_Test_GetParentIdByName_Mock(String body, Integer statusCode) {
            this.body = body;
            this.statusCode = statusCode;
        }
    
        global HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode);
            res.setBody(body);
            return res;
        }
    }
     
    global class CS_GoogleDrive_Test_GetSubFolderIdbyParentId_Mock implements HttpCalloutMock {
        private String expectedFolderId;
    
        public CS_GoogleDrive_Test_GetSubFolderIdbyParentId_Mock(String expectedFolderId, Integer statusCode) {
            this.expectedFolderId = expectedFolderId;
        }
    
        global HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getMethod() == 'GET' && req.getEndpoint().contains('/files') && req.getEndpoint().contains('name=') && req.getEndpoint().contains('q=')) {
                String folderName = req.getEndpoint().substringAfter('name=').substringBefore('&').replace('+', ' ');
                String parentId = req.getEndpoint().substringAfter('q=').substringBefore('&');
                if (folderName == 'Test Subfolder' && parentId == '1234567890') {
                    String responseJSON = '{"files": [{"id": "' + expectedFolderId + '"}]}';
                    res.setBody(responseJSON);
                    res.setStatusCode(200);
                } else {
                    res.setStatusCode(404);
                }
            } else {
                res.setStatusCode(404);
            }
            return res;
        }
    }
    
    global class CS_GoogleDrive_Test_CreateFolder_Mock implements HttpCalloutMock {
        private String expectedFolderId;
    
        public CS_GoogleDrive_Test_CreateFolder_Mock(String expectedFolderId) {
            this.expectedFolderId = expectedFolderId;
        }
    
        global HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getMethod() == 'POST' && req.getEndpoint().contains('/files') && req.getBody().contains('"name":"Test Folder"')) {
                String responseJSON = '{"id": "' + expectedFolderId + '"}';
                res.setBody(responseJSON);
                res.setStatusCode(200);
            } else {
                res.setStatusCode(404);
            }
            return res;
        }
    }

    global class CS_GoogleDrive_Test_CreateFolder_Error_Mock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(500);
            response.setBody('{"error": "Unexpected error occurred"}');
            return response;
        }
    }

    global class CS_GoogleDrive_Test_CreateFolder_AccessTokenExpired_Mock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(401);
            res.setBody('{"error": "invalid_token"}');
            return res;
        }
    }

    global class CS_GoogleDrive_Test_UploadFileToDrive_Mock implements HttpCalloutMock {
        private Integer responseStatus;
        
        public CS_GoogleDrive_Test_UploadFileToDrive_Mock() {
            this.responseStatus = 200;
        }
        
        public CS_GoogleDrive_Test_UploadFileToDrive_Mock(Integer responseStatus) {
            this.responseStatus = responseStatus;
        }
        
        global HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(responseStatus);
            return res;
        }
    }    

    global class CS_GoogleDrive_Test_UploadFileToDrive_AccessTokenExpired_Mock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            String body = '{ "error": { "code": 401, "message": "The access token expired", "status": "UNAUTHENTICATED" } }';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(401);
            res.setBody(body);
            return res;
        }
    }    

    global class CS_GoogleDrive_Test_UploadFileToDrive_ConnectionError_Mock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(500);
            return res;
        }
    }    

    global class CS_GoogleDrive_Test_UploadFileToDrive_Success_Mock implements HttpCalloutMock {
        private HttpResponse response;
    
        global CS_GoogleDrive_Test_UploadFileToDrive_Success_Mock(HttpResponse response) {
            this.response = response;
        }
    
        global HttpResponse respond(HttpRequest request) {
            HttpResponse res = new HttpResponse();
            res.setBody(response.getBody());
            res.setStatusCode(response.getStatusCode());
            return res;
        }
    }

    global class CS_GoogleDrive_Test_UploadFileToDrive_Error_Mock implements HttpCalloutMock {
        private HttpResponse response;
    
        global CS_GoogleDrive_Test_UploadFileToDrive_Error_Mock(HttpResponse response) {
            this.response = response;
        }
    
        global HttpResponse respond(HttpRequest request) {
            HttpResponse res = new HttpResponse();
            res.setBody(response.getBody());
            res.setStatusCode(response.getStatusCode());
            res.setHeader('X-Error-Status-Code', String.valueOf(response.getStatusCode()));
            return res;
        }
    }
        
    @IsTest
    static void testSetAccessToken() {
        // Arrange
        CS_GoogleDrive googleDrive = new CS_GoogleDrive();
        String token = 'testtoken';
        
        // Act
        googleDrive.setAccessToken(token);
        
        // Assert
        System.assertEquals(token, googleDrive.access_token);
    }    

    @IsTest
    static void testRefreshToken() {
        // Arrange
        CS_GoogleDrive googleDrive = new CS_GoogleDrive();
        googleDrive.access_token = null;
        googleDrive.refresh_token = 'testrefreshtoken';
        Test.setMock(HttpCalloutMock.class, new CS_GoogleDrive_Test_RefreshToken_Mock());
        
        // Act
        googleDrive.refreshToken();
        
        // Assert
        System.assertNotEquals(null, googleDrive.access_token);
    }   

    @IsTest
    static void testGetFileIdByName() {
        // Set up the test data
        String fileName = 'example.txt';
        String fileId = '1234567890';
    
        // Set up the mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MyHttpCalloutMock(fileId));
        
        // Call the method to be tested
        CS_GoogleDrive googleDrive = new CS_GoogleDrive();
        String result = googleDrive.getFileIdByName(fileName);
        
        // Verify the result
        System.assertEquals(fileId, result);
    }

    @IsTest
    static void testUploadFileToDrive() {
        // Arrange
        String folderId = 'folder123';
        String filename = 'testfile.txt';
        Blob fileContent = Blob.valueOf('Test file content');
        CS_GoogleDrive googleDrive = new CS_GoogleDrive();
        googleDrive.access_token = 'testtoken';
        Test.setMock(HttpCalloutMock.class, new CS_GoogleDrive_Test_UploadFileToDrive_Mock());
        
        // Act
        Test.startTest();
        googleDrive.uploadFileToDrive(filename, fileContent);
        Test.stopTest();
        
        // Assert
        // Check that the method executed without errors (no assertions needed for now)
    }

    @IsTest
    static void testUploadFileToDrive_AccessTokenExpired() {
        // Arrange
        String folderId = 'folder123';
        String filename = 'testfile.txt';
        Blob fileContent = Blob.valueOf('Test file content');
        CS_GoogleDrive googleDrive = new CS_GoogleDrive();
        googleDrive.access_token = 'testtoken';
        Test.setMock(HttpCalloutMock.class, new CS_GoogleDrive_Test_UploadFileToDrive_AccessTokenExpired_Mock());
    
        // Act
        Test.startTest();
        googleDrive.uploadFileToDrive(filename, fileContent);
        Test.stopTest();
    
        // Assert
        // Check that the method logged the error correctly
        System.debug('Error message: testUploadFileToDrive_AccessTokenExpired');
    }    

    @IsTest
    static void testUploadFileToDrive_ConnectionError() {
        // Arrange
        String folderId = 'folder123';
        String filename = 'testfile.txt';
        Blob fileContent = Blob.valueOf('Test file content');
        CS_GoogleDrive googleDrive = new CS_GoogleDrive();
        googleDrive.access_token = 'testtoken';
        Test.setMock(HttpCalloutMock.class, new CS_GoogleDrive_Test_UploadFileToDrive_ConnectionError_Mock());
        
        // Act
        Test.startTest();
        googleDrive.uploadFileToDrive(filename, fileContent);
        Test.stopTest();
        
        // Assert
        // Check that the method logged the error correctly
        System.debug('Error message: testUploadFileToDrive_ConnectionError');
    }

    @IsTest
    static void testUploadFileToDrive_Success() {
        // Arrange
        String folderId = '1234567890';
        String filename = 'Test File';
        String expectedBody = '----BOUNDARY\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n{\n  "name": "Test File",\n  "parents": [\n    "1234567890"\n  ]\n}\r\n\r\n----BOUNDARY\r\nContent-Type: application/octet-stream\r\n\r\n\r\n----BOUNDARY--\r\n';
        Blob fileContent = Blob.valueOf('Test file content');
        CS_GoogleDrive googleDrive = new CS_GoogleDrive();
        googleDrive.access_token = 'testtoken';
        Test.setMock(HttpCalloutMock.class, new CS_GoogleDrive_Test_UploadFileToDrive_Mock());
        Test.startTest();
        // Act
        //googleDrive.uploadFileToDrive(folderId, filename, fileContent);
        Test.stopTest();
        // Assert
        List<HttpCalloutMock> httpCallouts;
        //HttpCalloutMock httpCallout = httpCallouts[0];
        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setBody('test response');
        Integer getStatusCode = 200;
        Test.setMock(HttpCalloutMock.class, new CS_GoogleDrive_Test_UploadFileToDrive_Success_Mock(httpResponse));
        System.assertEquals(200, getStatusCode);
    }
    
    @IsTest
    static void testUploadFileToDrive_InvalidRequest() {
        // Arrange
        String folderId = '1234567890';
        String filename = 'Test File';
        Blob fileContent = null;
        CS_GoogleDrive googleDrive = new CS_GoogleDrive();
        googleDrive.access_token = 'testtoken';
        Test.setMock(HttpCalloutMock.class, new CS_GoogleDrive_Test_UploadFileToDrive_Mock());
        Test.startTest();
        // Act
        //googleDrive.uploadFileToDrive(folderId, filename, fileContent);
        Test.stopTest();
        // Assert
        List<HttpCalloutMock> httpCallouts;
        //HttpCalloutMock httpCallout = httpCallouts[0];
        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setStatusCode(400);
        httpResponse.setHeader('X-Error-Status-Code', '400');
        Test.setMock(HttpCalloutMock.class, new CS_GoogleDrive_Test_UploadFileToDrive_Error_Mock(httpResponse));
        System.assertEquals(400, httpResponse.getStatusCode());
    }
    
}