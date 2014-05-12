// JavaScript Document
CDV = ( typeof CDV == 'undefined' ? {} : CDV );
var cordova = window.cordova || window.Cordova;

CDV.XocializeScanner = {

	getBC: function(params,cb) {
	  
	 var settings = {
		
		QRCode			: true,
		PDF417Code		: true,
		UPCECode 		: false,
		Code39Code 		: false,
		Code39Mod43Code : false
		
	}; 
	
	params = JSON.stringify(params);
	
	console.log('starting plugin');
	  
	cordova.exec(function callback(data) {
                // data comes from the NSDictionary instance (jsonObj) from our Objective C code.
                // Take a look at the cordovaGetFileContents method from FileWriter.m and you'll see
                // where we add dateStr as a property to that Dictionary object.
				
				console.log("Plugin Results: "+JSON.stringify(data));
				
				if(typeof cb == 'function'){ cb.call(this,data); }
               
				
            },
			function errorHandler(err){
				
			},'XocializeScanner','cordovaGetBC',[params] );
  }
  
  
	
}
