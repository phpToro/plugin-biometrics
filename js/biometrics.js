phpToro.biometrics = {
    authenticate: function(reason, options) {
        return phpToro.nativeCall('biometrics', 'authenticate', Object.assign({ reason: reason }, options || {}));
    },
    isAvailable: function() {
        return phpToro.nativeCall('biometrics', 'isAvailable', {});
    },
    biometryType: function() {
        return phpToro.nativeCall('biometrics', 'biometryType', {});
    }
};
