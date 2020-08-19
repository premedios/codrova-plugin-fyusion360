/** 
    Innovagency - Team Mobile
    Pedro Remedios
*/
function Fyusion360() {
}

exports.startCaptureSession = function (successCallback, errorCallback, options) {
    cordova.exec(successCallback, errorCallback, "Fyusion360", "startSession", [options]);
};

exports.showFyuse = function (successCallback, errorCallback, fyuseID) {
    cordova.exec(successCallback, errorCallback, "Fyusion360", "showFyuse", [fyuseID]);
}

exports.getFyuseThumbnail = function(successCallback, errorCallback, fyuseID) {
    cordova.exec(successCallback, errorCallback, "Fyusion360", "getFyuseThumbnail", [fyuseID]);
}

exports.getDetailPhotos = function(successCallback, errorCallback, sessionID, resolution) {
    cordova.exec(successCallback, errorCallback, "Fyusion360", "getDetailPhotos", [sessionID, resolution]);
}
