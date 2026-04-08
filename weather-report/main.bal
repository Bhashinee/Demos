import ballerina/io;
import ballerinax/openweathermap;

configurable string appId = "c8697ceb5a7c46aa4b6b6d88ce5bd8c4";

final openweathermap:Client weatherClient = check new ({appid: appId});

public function main() returns error? {
    openweathermap:CurrentWeatherData weatherData = check weatherClient->getCurretWeatherData(q = "Colombo", units = "metric");

    string cityName = weatherData.name ?: "Colombo";
    openweathermap:Main? mainData = weatherData.main;
    openweathermap:Wind? windData = weatherData.wind;
    openweathermap:Clouds? cloudsData = weatherData.clouds;
    openweathermap:Weather[]? weatherConditions = weatherData.weather;
    openweathermap:Sys? sysData = weatherData.sys;

    io:println("========================================");
    io:println("  Weather Report - ", cityName);
    io:println("========================================");

    if mainData is openweathermap:Main {
        decimal currentTemp = mainData.temp ?: 0.0d;
        decimal minTemp = mainData.temp_min ?: 0.0d;
        decimal maxTemp = mainData.temp_max ?: 0.0d;
        int humidity = mainData.humidity ?: 0;
        int pressure = mainData.pressure ?: 0;

        io:println("Temperature   : ", currentTemp, " °C");
        io:println("Min Temp      : ", minTemp, " °C");
        io:println("Max Temp      : ", maxTemp, " °C");
        io:println("Humidity      : ", humidity, " %");
        io:println("Pressure      : ", pressure, " hPa");
    }

    if weatherConditions is openweathermap:Weather[] && weatherConditions.length() > 0 {
        openweathermap:Weather condition = weatherConditions[0];
        string conditionMain = condition.main ?: "N/A";
        string conditionDesc = condition.description ?: "N/A";
        io:println("Condition     : ", conditionMain, " (", conditionDesc, ")");
    }

    if windData is openweathermap:Wind {
        decimal windSpeed = windData.speed ?: 0.0d;
        int windDeg = windData.deg ?: 0;
        io:println("Wind Speed    : ", windSpeed, " m/s");
        io:println("Wind Direction: ", windDeg, "°");
    }

    if cloudsData is openweathermap:Clouds {
        int cloudiness = cloudsData.all ?: 0;
        io:println("Cloudiness    : ", cloudiness, " %");
    }

    if sysData is openweathermap:Sys {
        string country = sysData.country ?: "N/A";
        io:println("Country       : ", country);
    }

    io:println("========================================");
}
