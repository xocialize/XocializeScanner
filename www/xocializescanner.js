// JavaScript Document
CDV = ( typeof CDV == 'undefined' ? {} : CDV );
var cordova = window.cordova || window.Cordova;

CDV.XocializeScanner = {

	getBC: function(cb) {
	  
	//url ="https://xocialize.com/106977845796/passbook";
    
    cordova.exec(function callback(data) {
                // data comes from the NSDictionary instance (jsonObj) from our Objective C code.
                // Take a look at the cordovaGetFileContents method from FileWriter.m and you'll see
                // where we add dateStr as a property to that Dictionary object.
				
				if(typeof cb == 'function'){ cb.call(this,data); }
               
				
            },
			function errorHandler(err){
				
			},'XocializeScanner','cordovaGetBC',[] );
  }
	
}
