import ballerina/http;

final json MOCK_DATA = [
    {"id": 1, "name": "Alice", "role": "admin"},
    {"id": 2, "name": "Bob", "role": "user"},
    {"id": 3, "name": "Charlie", "role": "guest"}
];

service /retrieve on new http:Listener(8090) {
    resource function get .() returns json {
        return MOCK_DATA;
    }
}
