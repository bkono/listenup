var Observable = require("FuseJS/Observable");
var SnowboySDK = require("SnowboySDK");
var Bundle = require("FuseJS/Bundle");
var FileSystem = require("FuseJS/FileSystem");

var count = Observable(0);
var messages = Observable();
var commonResPath = FileSystem.dataDirectory + '/common.res';
var commonResExtracted = Observable(false);
var snowboyUmdlPath = FileSystem.dataDirectory + '/snowboy.umdl';
var snowboyUmdlExtracted = Observable(false);
var dingPath = FileSystem.dataDirectory + '/ding.wav';
var dingExtracted = Observable(false);

var resourcesExtracted = Observable(function() {
	return commonResExtracted.value && snowboyUmdlExtracted.value && dingExtracted.value;
});

var canListen = Observable(false);

extractSnowboyResources();
SnowboySDK.EnsurePerms();

function test() {
	var result = SnowboySDK.Test();
	console.dir(result);
	count.value += 1;
}

function extractSnowboyResources() {
	console.log("starting extract");

	if(FileSystem.existsSync(commonResPath)) {
		commonResExtracted.value = true;
	} else {
		Bundle.extract('lib/common.res', commonResPath)
		.then(function(resultPath) {
			console.dir(resultPath);
			commonResExtracted.value = true;
		}, function(error) {
			console.log("unable to extract common.res");
			console.dir(error);
		});	
	}

	if(FileSystem.existsSync(snowboyUmdlPath)) {
		snowboyUmdlExtracted.value = true;
	} else {
		Bundle.extract('lib/snowboy.umdl', snowboyUmdlPath)
		.then(function(resultPath){
			console.dir(resultPath);
			snowboyUmdlExtracted.value = true;
		}, function(error) {
			console.log("unable to extract snowboy.umdl");
			console.dir(error);
		});
	}

	if(FileSystem.existsSync(dingPath)) {
		dingExtracted.value = true;
	} else {
		Bundle.extract('lib/ding.wav', dingPath)
		.then(function(resultPath){
			console.dir(resultPath);
			dingExtracted.value = true;
		}, function(error) {
			console.log("unable to extract ding.wav");
			console.dir(error);
		});
	}
}

function listen() {
	SnowboySDK.InitDetector(commonResPath, snowboyUmdlPath);
}

SnowboySDK.on("canListenChanged", function(change) {
	console.log("canListenChanged, new value: " + change);
	canListen.value = change;
});


// function send() {
//   console.log("starting to send");
//   MsgMeSDK.Send("client side", "some message");
//   console.log("sent");
// }

// function listen() {
//   console.log("starting to listen");
//   MsgMeSDK.Listen();
//   console.log("... listening");
// }

// MsgMeSDK.on("messageReceived", function (message) {
//   console.log("Message received " + message);
//   messages.add({ content: message });
// });

module.exports = {
  count: count,
  test: test,
  resourcesExtracted: resourcesExtracted,
  listen: listen,
  canListen: canListen
};
