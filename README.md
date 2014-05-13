XocializeScanner
================

Native IOS barcode scanner for Cordova.  Requires IOS 7 for AV Foundation native barcode implementation.

Important
=========

This is a very basic barcode scanner and one of my very first plugins.  Much could be horribly wrong but at least it's working for me.  Feel free to fork and improve.

Installation
============

To add the barcode scanner to your Cordova project install with the command line tools:

cordova plugin add https://github.com/dunielson/XocializeScanner

Usage
=====

To execute the plugin use something like:


```

var params = {};
		
params.AztecCode = true;

CDV.XocializeScanner.getBC(params,function(data){

    if(data[2]=="1"){

        console.log('barcode: '+data[0]+' Type: '+data[1]);

    }
}

```

The plugin returns an array with 3 string elements: 

[0] The barcode

[1] The barcode type

[2] Status ( 0 = cancelled / 1 = success )

Options
=======

By default the scanner will look for PDF417Code, QRCode	and EAN13Code.  

You can override and return other barcodes supported by AV Foundation by sending in params.

````

var params = {};
		
params.AztecCode = true;

````

Inversely you can disable barcodes by using:

````

var params = {};
		
params.QRCode = false;

````

Or a combination of both:

````

var params = {};

params.AztecCode = true;
params.QRCode = false;

````

A list of available barcode types:

PDF417Code, QRCode, EAN13Code, UPCECode, Code39Code, Code39Mod43Code, EAN8Code, Code93Code, Code128Code, AztecCode