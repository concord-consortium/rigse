(function() {
  window.connectPredictionToSensor = function (pred_dom, sensor_dom) {
    var predictionPhone = phones[pred_dom],
        sensorPhone     = phones[sensor_dom],
        haveSeenEvents  = false;

    var _registerRelay = function(eventName) {
        predictionPhone.addListener("prediction-dataset-"+eventName, function(evt) {
          haveSeenEvents = true;
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

    var setupPeriodicSync = function() {
      // periodically send the complete prediction dataset over
      predictionPhone.addListener("dataset", function(evt) {
        sensorPhone.post('sendDatasetEvent', {eventName: 'dataReset', datasetName: 'sensor-dataset', data: evt.value.initialData });
      });
      setInterval(function() {
        if (haveSeenEvents) {
          predictionPhone.post('getDataset', 'prediction-dataset');
          haveSeenEvents = false;
        }
      }, 10000);

      // Also send the complete prediction dataset if the sensor interactive is loaded/reset
      sensorPhone.addListener("modelLoaded", function(evt) {
        predictionPhone.post('getDataset', 'prediction-dataset');
      });
    };

    setupCoordination();
    setupPeriodicSync();
  };
})();
