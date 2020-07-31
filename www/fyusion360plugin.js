/** 
    Innovagency - Team Mobile
    Pedro Remedios
*/
function Fyusion360() {
}

exports.startCaptureSession = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Fyusion360", "startSession");
};

exports.showFyuse = function (successCallback, errorCallback, fyuseID) {
    cordova.exec(successCallback, errorCallback, "Fyusion360", "showFyuse", [fyuseID]);
}
