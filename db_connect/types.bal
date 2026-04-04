public type IngestRequest record {| 
	string dataSource;
	string payload;
|};

public type IngestRecord record {| 
	int id;
	string dataSource;
	string payload;
	string createdAt;
|};
