.pragma library
/**
*  Version of the response data format.
*  Increase this number to force a refresh.
*/
var RESPONSE_DATA_VERSION = 20130801;

/**
* Helper functions
*/
function calcFahrenheit(celsius) {
        return celsius * 1.8 + 32;
}
function calcMph(ms) {
    return ms*2.24;
}
function calcInch(mm) {
    return mm/25.4;
}
function calcKmh(ms) {
    return ms*3.6;
}

var OpenWeatherMapApi = (function() {
    /**
      provides neccessary methods for requesting and preparing data from OpenWeatherMap.org
    */
    var _baseUrl = "http://api.openweathermap.org/data/2.5/";
    //
    function _buildSearchResult(request, data) {
        var searchResult = { locations: [], request: request };
        if(data.cod === "200" && data.list) {
            data.list.forEach(function(r) {
               searchResult.locations.push({
                    service: "openweathermap",
                    service_id: r.id,
                    name: r.name,
                    coord: r.coord,
                    country: (r.sys && r.sys.country) ? r.sys.country : ""
                });
            })
        }
        return searchResult;
    }
    //
    function _buildDataPoint(data) {
        // TODO add snow or rain data
        var result = {
            timestamp: data.dt,
            date: Qt.formatDateTime(new Date(data.dt*1000), "yyyy-MM-dd hh:mm"),
            metric: { temp:data.main.temp, windSpeed: calcKmh(data.main.speed), rain: data.main.rain},
            imperial: { temp: calcFahrenheit(data.main.temp), windSpeed: calcMph(data.main.speed), rain: calcInch(data.main.rain)},
            humidity: data.main.humidity,
            pressure: data.main.pressure,
            windDeg: data.main.deg,
            condition: data.weather[0]
        };
        if(data.id !== undefined) {
            result["service"] = "openweathermap";
            result["service_id"] =  data.id;
        }
        return result;
    }
    //
    function _buildDayFormat(date, data) {
        var result = {
            date: date,
            timestamp: data.dt,
            metric: {
                tempMin: data.temp.min,
                tempMax: data.temp.max,
                windSpeed: calcKmh(data.speed),
                rain: data.rain
            },
            imperial: {
                tempMin: calcFahrenheit(data.temp.min),
                tempMax: calcFahrenheit(data.temp.max),
                windSpeed: calcMph(data.speed),
                rain: calcInch(data.rain)
            },
            pressure: data.pressure,
            humidity: data.humidity,
            condition: data.weather[0],
            windDeg: data.deg,
            hourly: []
        }
        return result;
    }
    //
    function formatResult(data) {
        var tmpResult = {},
            result = [],
            day=null,
            today = Qt.formatDateTime(new Date(), "yyyy-MM-dd");
        data["daily"]["list"].forEach(function(dayData) {
            day = Qt.formatDateTime(new Date(dayData.dt*1000), "yyyy-MM-dd")
            tmpResult[day] = _buildDayFormat(day, dayData);
        })
        tmpResult[today]["current"] = _buildDataPoint(data["current"]);
        if(data["forecast"] !== undefined) {
            data["forecast"]["list"].forEach(function(hourData) {
                var date = new Date(hourData.dt*1000)
                day = Qt.formatDateTime(date, "yyyy-MM-dd");
                tmpResult[day]["hourly"].push(_buildDataPoint(hourData));
            })
        }
        for(var d in tmpResult) {
            result.push(tmpResult[d]);
        }
        return result;
    }
    //
    return {
        //
        search: function(mode, params, apiCaller, onSuccess, onError) {
            var request,
                retryHandler = (function(err) {
                        console.log("search retry of "+err.request.url);
                        apiCaller(request, searchResponseHandler, onError);
                }),
                searchResponseHandler = function(request, data) {
                    onSuccess(_buildSearchResult(request, data));
                };
            if(mode === "point") {
                request = { type: "search",
                            url: _baseUrl+"find?lat="+encodeURIComponent(params.coords.lat)
                                +"&lon="+encodeURIComponent(params.coords.lon)+"&units="+params.units}
            } else {
                request = { type: "search",
                            url: _baseUrl+"find?q="+encodeURIComponent(params.name)+"&units="+params.units}
            }
            apiCaller(request, searchResponseHandler, retryHandler);
        },
        //
        getData: function(params, apiCaller, onSuccess, onError) {
            var handlerMap = {
                current: { type: "current",
                           url: _baseUrl + "weather?id="+params.location.service_id+"&units="+params.units},
                daily: { type: "daily",
                         url: _baseUrl + "forecast/daily?id="+params.location.service_id
                                +"&cnt=10&units="+params.units},
                forecast: { type: "forecast",
                            url: _baseUrl + "forecast?id="+params.location.service_id+"&units="+params.units}},
            response = {
                location: params.location,
                db: (params.db) ? params.db : null,
                format: RESPONSE_DATA_VERSION
            },
            respData = {},
            addDataToResponse = (function(request, data) {
                var formattedResult;
                respData[request.type] = data;
                if(respData["current"] !== undefined
                        //&& respData["forecast"] !== undefined
                            && respData["daily"] !== undefined) {
                    response["data"] = formatResult(respData)
                    onSuccess(response);
                }
            }),
            onErrorHandler = (function(err) {
                onError(err);
            }),
            retryHandler = (function(err) {
                console.log("retry of "+err.request.url);
                var retryFunc = handlerMap[err.request.type];
                apiCaller(retryFunc, addDataToResponse, onErrorHandler);
            })
            apiCaller(handlerMap.current, addDataToResponse, retryHandler);
            //apiCaller(handlerMap.forecast, addDataToResponse, retryHandler);
            apiCaller(handlerMap.daily, addDataToResponse, retryHandler);
        }
    }

})();

var WeatherApi = (function(_services) {
    /**
      proxy for requesting weather apis, the passed _services are providing the respective api endpoints
      and formatters to build a uniform response object
    */
    function _getService(name) {
        if(_services[name] !== undefined) {
            return _services[name];
        } 
        return _services["openweathermap"];
    }
    //
    function _sendRequest(request, onSuccess, onError) {        
            var xmlHttp = new XMLHttpRequest();
            if (xmlHttp) {
                console.log(request.url);
                xmlHttp.open('GET', request.url, true);
                xmlHttp.onreadystatechange = function () {
                    try {
                        if (xmlHttp.readyState == 4) {
                            //console.log(xmlHttp.responseText);
                            var json = JSON.parse(xmlHttp.responseText);
                            if(xmlHttp.status === 200) {
                                onSuccess(request,json);
                            } else {
                                onError({
                                    msg: "wrong response http code, got "+xmlHttp.status,
                                    request: request
                                });
                            }
                        }
                    } catch (e) {
                        onError({msg: "wrong response data format", request: request});
                    }
                };
                xmlHttp.send(null);
            }
    }
    //
    return  {
        //
        search: function(mode, params, onSuccess, onError) {            
            var service = _getService();
            service.search(mode, params, _sendRequest, onSuccess, onError);
        },
        //
        getLocationData: function(params, onSuccess, onError) {
            var service = _getService();
            service.getData(params, _sendRequest, onSuccess, onError);
        },
    }
})({
    "openweathermap": OpenWeatherMapApi
});

/**
*  following WorkerScript handles the data requests against the weather API.
*  "message" requires a "params" property with the required params to perform
*  the API call and an "action" property, which will be added also to the response.
*/
if(typeof WorkerScript != "undefined") {
    WorkerScript.onMessage = function(message) {
        // handles the response data
        var finished = function(result) {            
            WorkerScript.sendMessage({
                action: message.action,
                result: result
            })
        }
        // handles errors
        var onError = function(err) {
            console.log(JSON.stringify(err, null, true));
            WorkerScript.sendMessage({ 'error': err})
        }
        // keep order of locations, sort results
        var sortDataResults = function(locA, locB) {
            return locA.db.id - locB.db.id;
        }
        // perform the api calls
        if(message.action === "searchByName") {
            WeatherApi.search("name", message.params, finished, onError);
        } else if(message.action === "searchByPoint") {
            WeatherApi.search("point", message.params, finished, onError);
        } else if(message.action === "updateData") {
            var locLength = message.params.locations.length,
                locUpdated = 0,
                result = [],
                now = new Date().getTime();
            if(locLength > 0) {
                message.params.locations.forEach(function(loc) {
                    var updatedHnd = function (newData, cached) {
                            locUpdated += 1;                            
                            newData["save"] = (cached === true) ? false : true;
                            result.push(newData);
                            if(locUpdated === locLength) {
                                result.sort(sortDataResults);
                                finished(result);
                            }
                        },
                        params = {
                            location:loc.location,
                            db: loc.db,
                            units: 'metric'
                        },
                        secsFromLastFetch = (now-loc.updated)/1000;
                    //
                    if( message.params.force===true || loc.format !== RESPONSE_DATA_VERSION || secsFromLastFetch > 1800){
                        // data older than 30min, location is new or data format is deprecated
                        WeatherApi.getLocationData(params, updatedHnd, onError);
                    } else {
                        console.log("["+loc.location.name+"] returning cached data, time from last fetch: "+secsFromLastFetch)
                        updatedHnd(loc, true);
                    }
                })
            } else {
                finished(result);
            }
        }
    }
}
