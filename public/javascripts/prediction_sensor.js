(function() {
  var verbose = true;
  var log     = function(msg) { if(console && verbose) { console.log(msg); }};

  window.connectPredictionToSensor = function (pred_dom, sensor_dom) {

    var predictionPhone = new iframePhone.ParentEndpoint(pred_dom, function () {
      log("Connection with prediction Lab iframe established.");
    });

    var sensorPhone = new iframePhone.ParentEndpoint(sensor_dom, function () {
      log("Connection with sensor Lab iframe established.");
    });

    var predictionModelLoaded = false,
        sensorModelLoaded = false;

    var _registerRelay = function(eventName) {
        predictionPhone.addListener("prediction-dataset-"+eventName, function(evt) {
          sensorPhone.post('sendDatasetEvent', {eventName: eventName, datasetName: 'sensor-dataset', data: evt.data });
        });
        predictionPhone.post('listenForDatasetEvent', {eventName: eventName, datasetName: 'prediction-dataset'});
    };

    var setupCoordination = function() {
      var events = ['sampleAdded', 'sampleRemoved'],
          i;
      for (i = 0; i < events.length; i++) {
        _registerRelay(events[i]);
      }
    };

    var initializeInteractives = function() {
      predictionPhone.addListener('modelLoaded', function(){
        predictionModelLoaded = true;
        if (sensorModelLoaded) {
          setupCoordination();
        }
      });
      sensorPhone.addListener('modelLoaded', function(){
        sensorModelLoaded = true;
        if (predictionModelLoaded) {
          setupCoordination();
        }
      });
    };

    initializeInteractives();
  };
})();