(function() {
  window.connectPredictionToSensor = function (pred_dom, sensor_dom) {
    var predictionPhone = phones[pred_dom],
        sensorPhone     = phones[sensor_dom];

    var _registerRelay = function(eventName) {
        predictionPhone.addListener("prediction-dataset-"+eventName, function(evt) {
          sensorPhone.post('sendDatasetEvent', {eventName: eventName, datasetName: 'sensor-dataset', data: evt.data });
        });
        predictionPhone.post('listenForDatasetEvent', {eventName: eventName, datasetName: 'prediction-dataset'});
    };

    var setupCoordination = function() {
      var events = ['sampleAdded', 'sampleRemoved', 'dataReset'],
          i;
      for (i = 0; i < events.length; i++) {
        _registerRelay(events[i]);
      }
    };

    setupCoordination();
  };
})();
