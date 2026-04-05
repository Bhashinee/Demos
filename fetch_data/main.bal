import ballerina/http;

configurable string serviceurl = ?;
http:Client httpClient = check new (serviceurl);

service / on new http:Listener(9090) {

    resource function get fetch() returns json|error {
        json payload = check httpClient->/retrieve();
        return payload;
    }

}

