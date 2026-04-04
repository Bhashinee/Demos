import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;

listener http:Listener apiListener = new (apiPort);

final mysql:Client dbClient = checkpanic new (
	host = dbHost,
	port = dbPort,
	user = dbUser,
	password = dbPassword,
	database = dbName
);

function init() returns error? {
	var _ = check dbClient->execute(`
		CREATE TABLE IF NOT EXISTS ingest_records (
			id INT AUTO_INCREMENT PRIMARY KEY,
			data_source VARCHAR(100) NOT NULL,
			payload TEXT NOT NULL,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)
	`);
}

function collectRecords(stream<IngestRecord, sql:Error?> recordStream) returns IngestRecord[]|error {
	IngestRecord[] records = [];
	record {|IngestRecord value;|}|sql:Error? nextResult = check recordStream.next();
	while nextResult is record {|IngestRecord value;|} {
		records.push(nextResult.value);
		nextResult = check recordStream.next();
	}
	return records;
}

service /api on apiListener {
	resource function post records(IngestRequest request) returns json|error {
		sql:ExecutionResult result = check dbClient->execute(
			`INSERT INTO ingest_records (data_source, payload) VALUES (${request.dataSource}, ${request.payload})`
		);

		int insertedId = <int>result.lastInsertId;
		return {
			message: "Record ingested successfully",
			id: insertedId
		};
	}

	resource function get records() returns IngestRecord[]|error {
		stream<IngestRecord, sql:Error?> recordStream = dbClient->query(
			`SELECT id, data_source AS dataSource, payload, DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') AS createdAt
			 FROM ingest_records
			 ORDER BY id DESC`
		);

		return check collectRecords(recordStream);
	}

	resource function get records/[int id]() returns IngestRecord|json|error {
		IngestRecord|sql:Error row = dbClient->queryRow(
			`SELECT id, data_source AS dataSource, payload, DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') AS createdAt
			 FROM ingest_records
			 WHERE id = ${id}`
		);

		if row is sql:NoRowsError {
			return {message: "Record not found", id: id};
		}
		if row is sql:Error {
			return row;
		}

		return row;
	}
}
