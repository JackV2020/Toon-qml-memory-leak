### Toon qml memory leak

When using apps on a rooted Eneco Toon you may have experienced that when you install too many apps, especially on Toon 1, the GUI begins to restart more often. This is caused by resource availability issues and mainly by memory issues caused by a memory leak in the qml of the GUI process.

When you write your own apps for Toon or apps for the ToonStore, there is a way to work around that memory leak.

When you use apps developed by others contact them and share this github repository with them.

The app in the xmlHttpRequestHowTo folder demonstrates how you can reduce the effect of the memory leak. The app is named xmlHttpRequestHowTo because it uses XMLHttpRequest to demonstrate what can be done. That what is done can be used in other cases too.

### This is what happens

Apps are written in qml and javascript and are loaded into the GUI process during the startup of the GUI. After they are loaded they become an active part of the GUI and all Timers which are configured to start running start the functions they call. When a function ends, all objects and variables which are local to the function should be removed by the garbadge collector and memory should be made free. This is where the garbadge collector does a terrible job resulting in a memory leak of the GUI process.

To minimize that leaking :

    - define variables you use in functions as global variables at app level
    - create 1 initialisation function for all these variables
    - call this function in 'Component.onCompleted'
    
This way the variables do not need to be deleted at the end of a function and be recreated during the next call.

This is not a way you would like to write your functions because it is not a good practice because you should keep your data local in the functions.

However this helps in reducing the effect of the memory leak.

### The xmlHttpRequestHowTo app

The app has a basic and a saving mode and only shows 1 tile with :

    - the current mode,
    - the uptime of your Toon,
    - the uptime of the GUI, 
    - the memory size of the GUI,
    - the free linux memory

You switch between basic and saving mode by clicking on the tile.

Basic mode is the mode in which would want to write your app and saving mode is minimizing the leak.

Both modes use the same URL's to get fake JSON data from https://fakerapi.it/

Basic mode uses functions which include everything needed for the communication and saving mode functions use global variables for the XMLHttpRequest including onreadystatechange and the JSON response.

For more detailed documentation on the app look into XmlHttpRequestHowToApp.qml itself.

### Install the app

To install the app :

    - on Toon create a folder /qmf/qml/apps/xmlHttpRequestHowTo
    - put the contensts of the xmlHttpRequestHowTo folder in there
    - restart the GUI / reboot your Toon
    - add a tile for 'XHR Test'

You will see a red tile and the data mentioned above will show up after some time and will be updated about every 10 seconds.

### Get familiar with the app

To get familiar with the app we make 2 measurements and compare the results.

To make a measurement in basic mode make sure you have no other apps installed than the ToonStore and the xmlHttpRequestHowTo app. After each restart of the GUI the app is in basic mode and the tile is red. After startup you see some data on the tile after a while. At least make a note of the 'uptime of the GUI' and 'the memory size of the GUI'. Let it run for some hours and make a note of the 'uptime of the GUI' and 'the memory size of the GUI' again. Calculate the runtime by substracting the two uptimes and calculate the memory growth by substracting the two memory sizes. Divide the growth by the runtime and you have the growth in kB/second in basic mode.

To make a measurement in saving mode you reboot Toon and after startup you click on the tile and it turns green. Like previous time, at least make a note of the 'uptime of the GUI' and 'the memory size of the GUI'. Let it run for some hours and make a note of the 'uptime of the GUI' and 'the memory size of the GUI' again. Calculate the runtime by substracting the two uptimes and calculate the memory growth by substracting the two memory sizes. Divide the growth by the runtime and you have the growth in kB/second in saving mode.

Now compare what you found and multiply the results by 86400 to get an idea of the difference in kB memory loss in 24 hours.

You may run both measurements for 24 hours when you have the time for it and compare to what you just calculated. You may find that the numbers are a little bit larger which is caused by the ToonStore which does some app version checking every now and then.

### Option : Domoticz plugin with control buttons and many devices to create graphs

When you have Domoticz you can also use my plugin which I use during app developoment. It has 6 controls and more that 30 devices to measure what is going on in Toon. See https://github.com/JackV2020/Domoticz-ToonMonitor for that.

### Changing your app and measuring the difference.

To change your app and measure the improvement you make a baseline first. Install your app as it is and run xmlHttpRequestHowTo in saving mode and you do a measurement and a calculation for kB/sec. You know the kB/sec for the saving mode so you can substract that to find the kB/sec for your app.

Next you optimize your app, measure and calculate the kB/sec for your app again and compare to what you found before.

The more active your app is and the bigger the onreadystatechanges, when you have these, and the data structures are the bigger your savings will be.

Thanks for reading and enjoy optimizing.
