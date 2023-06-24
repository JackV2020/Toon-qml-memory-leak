import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0;
import FileIO 1.0

/*

    The GUI process in Toon does not do a very good job in cleaning up
    temprary variables etc. This app demonstrates how you can limit the
    loss of memory which causes restarts of the GUI process.
    
    The app has a basic and a saving mode and only shows 1 tile with :

        - the current mode,
        - the uptime of your Toon,
        - the uptime of the GUI, 
        - the memory size of the GUI,
        - the free linux memory

    You switch between basic and saving mode by clicking on the tile.
    
    In the basic mode we use functions that create the new XMLHttpRequest
    and onreadystatechange each time the functions are called. 
    The GUI process should do a cleanup of everything in the function 
    when a function ends. When you look at the data on the tile you 
    will see that 'the memory size of the GUI' keeps growing rapidly.
    At the end of the functions we even try to force to remove the objects
    by assigning a null to them. Unfortunately this does not help.

    In saving mode we use global XMLHttpRequests and corresponding 
    global onreadystatechanges which are created only once after startup.
    We also use global json variables to store the response data.
    In saving mode you will see a strong reduction in the growth of
    'the memory size of the GUI'.
    Not in this app but in other apps we have the experience that
    creating global variables for other variables used in the 
    onreadystatechanges has the same effect on the growth of the GUI.

    For both modes we have 5 GET functions which get data from :
     https://fakerapi.it/    
    using the next queries :
     https://fakerapi.it/api/v1/companies?_quantity=1
     https://fakerapi.it/api/v1/companies?_quantity=2
     https://fakerapi.it/api/v1/companies?_quantity=3
     https://fakerapi.it/api/v1/companies?_quantity=4
     https://fakerapi.it/api/v1/companies?_quantity=5
     
    There are 5 timers and each timer either calls the function for the
    basic way or the saving way, depending on the mode.
    There are 5 booleans, debug1,2,3,4 and 5 to enable/disable logging.
    
    We want to show the figures mentioned above on the tile.
    To do this we need to trigger the tsc script to run our sh script.
    Our sh script is in the app folder and creates a file with the info.
    We read that file and update the info on the tile.

    REMARKS :
    
    1) Sometimes you see fault messages in the logging like :
    
    xmlHttpRequest Test : saving_GET_4 fault response : <!DOCTYPE html>
    
    This is most likely because we issue sometimes too many requests to
    the web site in a too short period. This "solves" itself very fast.
    Just ignore them or see them as a signal that the app is alive.

    2) Saving by changing other functions and variables
    
    This app shows the saving effect for xmlHttpRequest and that is why
    it has the name XmlHttpRequestHowTo.
    I think creating global variables for all variables in functions
    will have the same effect of less GUI growth. 

*/

App {

// A debug for general messages

    property bool debug                     : true

    property url    tileUrl                 : "XmlHttpRequestHowToTile.qml"
    property XmlHttpRequestHowToTile           xmlHttpRequestHowToTile

/*
    purpose of the boolean basicSaving which is created below
    
    true  : basic mode is where "new XMLHttpRequest()" etc. is 
            called for every GET
    
    false : saving mode is where we use "new XMLHttpRequest()"'s etc. which 
            are created only once by Component.onCompleted
*/

    property bool basicSaving                : true

    // The debugs for the 5 different GETs in both basic and saving mode

    property bool debug1                    : true  
    property bool debug2                    : false
    property bool debug3                    : false
    property bool debug4                    : false
    property bool debug5                    : false

    // The interval for the 5 functions :

    property int get_1_TimerInterval : 5000
    property int get_2_TimerInterval : 7000
    property int get_3_TimerInterval : 11000
    property int get_4_TimerInterval : 19000
    property int get_5_TimerInterval : 35000

    // We show some info on the tile
    
    property string tileInfo

    // File in which we write the trigger for tsc to execute the script

    property string reportFileTriggerFile   : "file:///tmp/tsc.command"  

    // The file handle to write that file

    property variant reportFileTriggerHandle  

    // The trigger which we write in reportFileTriggerFile

    property string trigger             : "external-xmlHttpRequestHowTo"

    // The file created by our sh script

    property string reportFile : "file:///tmp/xmlHttpRequestHowTo.sh.json"
    
    // The data in the reportFile is a JSON string

    property variant jsonReportData 

    // Fields we read from the jsonReportData and show on the tile

    property int toonUptime : 0
    property int guiUptime : 0
    property int guiVmSize : 0
    property int freeMemory : 0

// ------------------------------------------ Needed To Append To A File

// The 'reportFileTriggerFile' for tsc may already contain other triggers
//  so we can not just write the file, we need to append to the file.
// Since I can not (do not know how to) open a file for append
//  I have a function below which reads the complete file, adds a line
//  and writes the lot back to the file. Result is the same :-)

    FileIO {
        id: appendFileFile
        source: reportFileTriggerFile
     }
     
    property string appendFileData

    property variant appendFileHandle

// ------- Location of the report file which is created by our sh script

    FileIO {
        id: jsonReportFile
        source: "file:///tmp/xmlHttpRequestHowTo.sh.json"
     }

// ------------------------------------ All global things for saving mode 

    property variant xhrsaving_GET_1
    property variant jsonObjectsaving_GET_1
    
    property variant xhrsaving_GET_2
    property variant jsonObjectsaving_GET_2
    
    property variant xhrsaving_GET_3
    property variant jsonObjectsaving_GET_3
    
    property variant xhrsaving_GET_4
    property variant jsonObjectsaving_GET_4
    
    property variant xhrsaving_GET_5
    property variant jsonObjectsaving_GET_5

// The function called by 'Component.onCompleted:' to create some things

    function initXMLHttpRequests() {

        xhrsaving_GET_1 = new XMLHttpRequest();
// Set optional fields
//        xhrsaving_GET_1.withCredentials = true;
        xhrsaving_GET_1.onreadystatechange = function() {
            if( xhrsaving_GET_1.readyState === 4){
                if (xhrsaving_GET_1.status === 200 || xhrsaving_GET_1.status === 300  || xhrsaving_GET_1.status === 302) {
                    debug1 && log("saving_GET_1 response : " + xhrsaving_GET_1.responseText)
                    jsonObjectsaving_GET_1= JSON.parse(xhrsaving_GET_1.responseText)
                }else{
                    log("saving_GET_1 fault response : " + xhrsaving_GET_1.responseText)
                }
            }
        }

        xhrsaving_GET_2 = new XMLHttpRequest();
// Set optional fields
//        xhrsaving_GET_2.withCredentials = true;
        xhrsaving_GET_2.onreadystatechange = function() {
            if( xhrsaving_GET_2.readyState === 4){
                if (xhrsaving_GET_2.status === 200 || xhrsaving_GET_2.status === 300  || xhrsaving_GET_2.status === 302) {
                    debug2 && log("saving_GET_2 response : " + xhrsaving_GET_2.responseText)
                    jsonObjectsaving_GET_2= JSON.parse(xhrsaving_GET_2.responseText)
                }else{
                    log("saving_GET_2 fault response : " + xhrsaving_GET_2.responseText)
                }
            }
        }

        xhrsaving_GET_3 = new XMLHttpRequest();
// Set optional fields
//        xhrsaving_GET_2.withCredentials = true;
        xhrsaving_GET_3.onreadystatechange = function() {
            if( xhrsaving_GET_3.readyState === 4){
                if (xhrsaving_GET_3.status === 200 || xhrsaving_GET_3.status === 300  || xhrsaving_GET_3.status === 302) {
                    debug3 && log("saving_GET_3 response : " + xhrsaving_GET_3.responseText)
                    jsonObjectsaving_GET_3= JSON.parse(xhrsaving_GET_3.responseText)
                }else{
                    log("saving_GET_3 fault response : " + xhrsaving_GET_3.responseText)
                }
            }
        }

        xhrsaving_GET_4 = new XMLHttpRequest();
// Set optional fields
//        xhrsaving_GET_2.withCredentials = true;
        xhrsaving_GET_4.onreadystatechange = function() {
            if( xhrsaving_GET_4.readyState === 4){
                if (xhrsaving_GET_4.status === 200 || xhrsaving_GET_4.status === 300  || xhrsaving_GET_4.status === 302) {
                    debug4 && log("saving_GET_4 response : " + xhrsaving_GET_4.responseText)
                    jsonObjectsaving_GET_4= JSON.parse(xhrsaving_GET_4.responseText)
                }else{
                    log("saving_GET_4 fault response : " + xhrsaving_GET_4.responseText)
                }
            }
        }

        xhrsaving_GET_5 = new XMLHttpRequest();
// Set optional fields
//        xhrsaving_GET_2.withCredentials = true;
        xhrsaving_GET_5.onreadystatechange = function() {
            if( xhrsaving_GET_5.readyState === 4){
                if (xhrsaving_GET_5.status === 200 || xhrsaving_GET_5.status === 300  || xhrsaving_GET_5.status === 302) {
                    debug5 && log("saving_GET_5 response : " + xhrsaving_GET_5.responseText)
                    jsonObjectsaving_GET_5= JSON.parse(xhrsaving_GET_5.responseText)
                }else{
                    log("saving_GET_5 fault response : " + xhrsaving_GET_5.responseText)
                }
            }
        }

    }

// ---------------------------------------- Register the tile in the GUI
    
    function init() {

        const args = {
            thumbCategory       : "general",
            thumbLabel          : "XHR Test",
            thumbIcon           : "qrc:/tsc/pushon.png",
            thumbIconVAlignment : "center",
            thumbWeight         : 30
        }

        registry.registerWidget("tile", tileUrl, this, "xmlHttpRequestHowToTile", args);

    }

// ------------------------------------- Actions right after APP startup

    Component.onCompleted: {
    
// 2 File handles we only create once 

        appendFileHandle = new XMLHttpRequest();
        reportFileTriggerHandle = new XMLHttpRequest();

// The XMLHttpRequests and onreadystatechanges for saving mode

        initXMLHttpRequests()
    }
    
// -------------------- A function to log to the console with timestamps

    function log(tolog) {

        var now      = new Date();
        var dateTime = now.getFullYear() + '-' +
                ('00'+(now.getMonth() + 1)   ).slice(-2) + '-' +
                ('00'+ now.getDate()         ).slice(-2) + ' ' +
                ('00'+ now.getHours()        ).slice(-2) + ":" +
                ('00'+ now.getMinutes()      ).slice(-2) + ":" +
                ('00'+ now.getSeconds()      ).slice(-2) + "." +
                ('000'+now.getMilliseconds() ).slice(-3);
        console.log(dateTime+' xmlHttpRequest Test : ' + tolog.toString())

    }

// -------------------- Add a line to an existing file / create the file

    function appendFile(file, line) {

        try {
            appendFileData = appendFileFile.read();
            appendFileData = appendFileData + line
/*
 For some reason there are 2 newline characters added between
 the old data and the line we added so we need to replace the last 
 2 newline characters by a single newline character.
 To do that we reverse the complete string, replace the first 2 newline
 characters by a single one and reverse the string again.
*/
            appendFileData = appendFileData.split("").reverse().join("");
            appendFileData = appendFileData.replace(/\n\n/ , "\n")
            appendFileData = appendFileData.split("").reverse().join("");
        } catch(e) {
//            log("No data to append to " + e)
            log("No data to append to")
            appendFileData = line
        }

        appendFileHandle.open("PUT", file);
        appendFileHandle.send(appendFileData);        
    }

// -------------------- Trigger the tsc process to execute our sh script

    function triggerReport() {
        appendFile(reportFileTriggerFile, trigger)
    }
    
// ------------------------------ Read the file created by our sh script

    function readReport() {

        try {
            jsonReportData = JSON.parse(jsonReportFile.read());

            toonUptime=jsonReportData["toonUptime"]
            guiUptime=jsonReportData["guiUptime"]
            guiVmSize=jsonReportData["guiVmSize"]
            freeMemory=jsonReportData["freeMemory"]
            
        } catch(e) {
// This happens every now and then when the script is running and
//      did not finish writing into the file.
//            debug && log("No script data available " + e)
            debug && log("No script data available")
        }
    }

// ------------------------ The tile shows 1 variable which we fill here

    function updateTile() {
        if (basicSaving) { tileInfo="Basic" } 
        else { tileInfo="Saving" }
        tileInfo=tileInfo+"\n\nToon Uptime : "+toonUptime
        tileInfo=tileInfo  +"\nGUI Uptime  : "+guiUptime
        tileInfo=tileInfo  +"\nGUI VmSize  : "+guiVmSize
        tileInfo=tileInfo  +"\nFreeMemory  : "+freeMemory
    }

// ------------------------------------------- Get the data for the tile

    Timer {
        id              : reportTimer
        interval        : 10000
        running         : true
        repeat          : true
        onTriggered : {
//            debug && log("Report Timer")
            triggerReport()
            readReport()
            updateTile()
        }
    }

// ------------------- 5 Blocks with a basic and saving GET function each

// ------------------- basic and saving GET functions group 1 with timer

    function basic_GET_1() {
        debug1 && log("Basic Mode GET 1")
        var xhrbasic_GET_1  = new XMLHttpRequest();
        xhrbasic_GET_1.open("GET", "https://fakerapi.it/api/v1/companies?_quantity=1");
        xhrbasic_GET_1.onreadystatechange = function() {
            if( xhrbasic_GET_1.readyState === 4){
                if (xhrbasic_GET_1.status === 200 || xhrbasic_GET_1.status === 300  || xhrbasic_GET_1.status === 302) {
                    debug1 && log("basic_GET_1 response : " + xhrbasic_GET_1.responseText)
                    var jsonObjectbasic_GET_1= JSON.parse(xhrbasic_GET_1.responseText)
                    jsonObjectbasic_GET_1 = null
                    xhrbasic_GET_1.onreadystatechange = null
                    xhrbasic_GET_1 = null
                }else{
                    log("basic_GET_1 fault response : " + xhrbasic_GET_1.responseText)
                }
            }
        }
// here you could add headers for this GET request
//        xhrbasic_GET_1.setRequestHeader("Authorization", "Bearer " + token);
//        xhrbasic_GET_1.setRequestHeader("Content-Type", "application/json");
        xhrbasic_GET_1.send()
        debug1 && log("Basic Mode GET 1 sent")
    }

    function saving_GET_1() {
        debug1 && log("Saving Mode GET 1")
        xhrsaving_GET_1.open("GET", "https://fakerapi.it/api/v1/companies?_quantity=1");
// here you could add headers for this GET request
//        xhrsaving_GET_1.setRequestHeader("Authorization", "Bearer " + token);
//        xhrsaving_GET_1.setRequestHeader("Content-Type", "application/json");
        xhrsaving_GET_1.send()
        debug1 && log("Saving Mode GET 1 sent")
    }
    
    Timer {
        id              : get_1_Timer
        interval        : get_1_TimerInterval
        running         : true
        repeat          : true
        onTriggered : {
            if (basicSaving) {
                basic_GET_1()
            } else {
                saving_GET_1()
            }
        }
    }

// ------------------- basic and saving GET functions group 2 with timer

    function basic_GET_2() {
        debug2 && log("Basic Mode GET 2")
        var xhrbasic_GET_2  = new XMLHttpRequest();
        xhrbasic_GET_2.open("GET", "https://fakerapi.it/api/v1/companies?_quantity=2");
        xhrbasic_GET_2.onreadystatechange = function() {
            if( xhrbasic_GET_2.readyState === 4){
                if (xhrbasic_GET_2.status === 200 || xhrbasic_GET_2.status === 300  || xhrbasic_GET_2.status === 302) {
                    debug2 && log("basic_GET_2 response : " + xhrbasic_GET_2.responseText)
                    var jsonObjectbasic_GET_2= JSON.parse(xhrbasic_GET_2.responseText)
                    jsonObjectbasic_GET_2 = null
                    xhrbasic_GET_2.onreadystatechange = null
                    xhrbasic_GET_2 = null
                }else{
                    log("basic_GET_2 fault response : " + xhrbasic_GET_2.responseText)
                }
            }
        }
// here you could add headers for this GET request
//        xhrbasic_GET_2.setRequestHeader("Authorization", "Bearer " + token);
//        xhrbasic_GET_2.setRequestHeader("Content-Type", "application/json");
        xhrbasic_GET_2.send()
        debug2 && log("Basic Mode GET 2 sent")
    }

    function saving_GET_2() {
        debug2 && log("Saving Mode GET 2")
        xhrsaving_GET_2.open("GET", "https://fakerapi.it/api/v1/companies?_quantity=2");
// here you could add headers for this GET request
//        xhrsaving_GET_2.setRequestHeader("Authorization", "Bearer " + token);
//        xhrsaving_GET_2.setRequestHeader("Content-Type", "application/json");
        xhrsaving_GET_2.send()
        debug2 && log("Saving Mode GET 2 sent")
    }
    
    Timer {
        id              : get_2_Timer
        interval        : get_2_TimerInterval
        running         : true
        repeat          : true
        onTriggered : {
            if (basicSaving) {
                basic_GET_2()
            } else {
                saving_GET_2()
            }
        }
    }
    
// ------------------- basic and saving GET functions group 3 with timer

    function basic_GET_3() {
        debug3 && log("Basic Mode GET 3")
        var xhrbasic_GET_3  = new XMLHttpRequest();
        xhrbasic_GET_3.open("GET", "https://fakerapi.it/api/v1/companies?_quantity=3");
        xhrbasic_GET_3.onreadystatechange = function() {
            if( xhrbasic_GET_3.readyState === 4){
                if (xhrbasic_GET_3.status === 200 || xhrbasic_GET_3.status === 300  || xhrbasic_GET_3.status === 302) {
                    debug3 && log("basic_GET_3 response : " + xhrbasic_GET_3.responseText)
                    var jsonObjectbasic_GET_3= JSON.parse(xhrbasic_GET_3.responseText)
                    jsonObjectbasic_GET_3= null
                    xhrbasic_GET_3.onreadystatechange = null
                    xhrbasic_GET_3 = null
                }else{
                    log("basic_GET_3 fault response : " + xhrbasic_GET_3.responseText)
                }
            }
        }
// here you could add headers for this GET request
//        xhrbasic_GET_3.setRequestHeader("Authorization", "Bearer " + token);
//        xhrbasic_GET_3.setRequestHeader("Content-Type", "application/json");
        xhrbasic_GET_3.send()
        debug3 && log("Basic Mode GET 3 sent")
    }

    function saving_GET_3() {
        debug3 && log("Saving Mode GET 3")
        xhrsaving_GET_3.open("GET", "https://fakerapi.it/api/v1/companies?_quantity=3");
// here you could add headers for this GET request
//        xhrsaving_GET_3.setRequestHeader("Authorization", "Bearer " + token);
//        xhrsaving_GET_3.setRequestHeader("Content-Type", "application/json");
        xhrsaving_GET_3.send()
        debug3 && log("Saving Mode GET 3 sent")
    }
    
    Timer {
        id              : get_3_Timer
        interval        : get_3_TimerInterval
        running         : true
        repeat          : true
        onTriggered : {
            if (basicSaving) {
                basic_GET_3()
            } else {
                saving_GET_3()
            }
        }
    }

// ------------------- basic and saving GET functions group 4 with timer

    function basic_GET_4() {
        debug4 && log("Basic Mode GET 4")
        var xhrbasic_GET_4  = new XMLHttpRequest();
        xhrbasic_GET_4.open("GET", "https://fakerapi.it/api/v1/companies?_quantity=4");
        xhrbasic_GET_4.onreadystatechange = function() {
            if( xhrbasic_GET_4.readyState === 4){
                if (xhrbasic_GET_4.status === 200 || xhrbasic_GET_4.status === 300  || xhrbasic_GET_4.status === 302) {
                    debug4 && log("basic_GET_4 response : " + xhrbasic_GET_4.responseText)
                    var jsonObjectbasic_GET_4= JSON.parse(xhrbasic_GET_4.responseText)
                    jsonObjectbasic_GET_4 = null
                    xhrbasic_GET_4.onreadystatechange = null
                    xhrbasic_GET_4 = null
                }else{
                    log("basic_GET_4 fault response : " + xhrbasic_GET_4.responseText)
                }
            }
        }
// here you could add headers for this GET request
//        xhrbasic_GET_4.setRequestHeader("Authorization", "Bearer " + token);
//        xhrbasic_GET_4.setRequestHeader("Content-Type", "application/json");
        xhrbasic_GET_4.send()
        debug4 && log("Basic Mode GET 4 sent")
    }

    function saving_GET_4() {
        debug4 && log("Saving Mode GET 4")
        xhrsaving_GET_4.open("GET", "https://fakerapi.it/api/v1/companies?_quantity=4");
// here you could add headers for this GET request
//        xhrsaving_GET_4.setRequestHeader("Authorization", "Bearer " + token);
//        xhrsaving_GET_4.setRequestHeader("Content-Type", "application/json");
        xhrsaving_GET_4.send()
        debug4 && log("Saving Mode GET 4 sent")
    }
    
    Timer {
        id              : get_4_Timer
        interval        : get_4_TimerInterval
        running         : true
        repeat          : true
        onTriggered : {
            if (basicSaving) {
                basic_GET_4()
            } else {
                saving_GET_4()
            }
        }
    }

// ------------------- basic and saving GET functions group 5 with timer

    function basic_GET_5() {
        debug5 && log("Basic Mode GET 5")
        var xhrbasic_GET_5  = new XMLHttpRequest();
        xhrbasic_GET_5.open("GET", "https://fakerapi.it/api/v1/companies?_quantity=5");
        xhrbasic_GET_5.onreadystatechange = function() {
            if( xhrbasic_GET_5.readyState === 4){
                if (xhrbasic_GET_5.status === 200 || xhrbasic_GET_5.status === 300  || xhrbasic_GET_5.status === 302) {
                    debug5 && log("basic_GET_5 response : " + xhrbasic_GET_5.responseText)
                    var jsonObjectbasic_GET_5= JSON.parse(xhrbasic_GET_5.responseText)
                    jsonObjectbasic_GET_5 = null
                    xhrbasic_GET_5.onreadystatechange = null
                    xhrbasic_GET_5 = null
                }else{
                    log("basic_GET_5 fault response : " + xhrbasic_GET_5.responseText)
                }
            }
        }
// here you could add headers for this GET request
//        xhrbasic_GET_5.setRequestHeader("Authorization", "Bearer " + token);
//        xhrbasic_GET_5.setRequestHeader("Content-Type", "application/json");
        xhrbasic_GET_5.send()
        debug5 && log("Basic Mode GET 5 sent")
    }

    function saving_GET_5() {
        debug5 && log("Saving Mode GET 5")
        xhrsaving_GET_5.open("GET", "https://fakerapi.it/api/v1/companies?_quantity=5");
// here you could add headers for this GET request
//        xhrsaving_GET_5.setRequestHeader("Authorization", "Bearer " + token);
//        xhrsaving_GET_5.setRequestHeader("Content-Type", "application/json");
        xhrsaving_GET_5.send()
        debug5 && log("Saving Mode GET 5 sent")
    }
    
    Timer {
        id              : get_5_Timer
        interval        : get_5_TimerInterval
        running         : true
        repeat          : true
        onTriggered : {
            if (basicSaving) {
                basic_GET_5()
            } else {
                saving_GET_5()
            }
        }
    }

// ---------------------------------------------------------------------

}
