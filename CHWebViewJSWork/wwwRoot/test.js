
var dateString;

function initSelects(){
    
    var dateType = ["select_year", "select_month", "select_day"] ;
    var dateCountMax = [2010, 12, 30] ;
    var selectType;
    
    for (i = 1949; i <= 2010 ; i++) { 
        selectType = document.getElementById(dateType[0]);
        var option = document.createElement("option");
        option.text = i;
        selectType.add(option);  
    }
    
    for (i = 1; i <= 12 ; i++) { 
        selectType = document.getElementById(dateType[1]);
        var option = document.createElement("option");
        option.text = i;
        selectType.add(option);  
    }
    
    for (i = 1; i <= 31 ; i++) { 
        selectType = document.getElementById(dateType[2]);
        var option = document.createElement("option");
        option.text = i;
        selectType.add(option);  
    }
    
    selectDidChange('select_month');
    
}

function selectDidChange(dateType,dateValue){
    
    //year
    var year_select  = document.getElementById("select_year");
    var year_result = year_select.options[year_select.selectedIndex].text;
    
    //month
    var month_select = document.getElementById("select_month");
    var month_result = month_select.options[month_select.selectedIndex].text;
    
    //day
    var day_select   = document.getElementById("select_day");
    var day_result = day_select.options[day_select.selectedIndex].text;
    
   
    
    if(dateType == "select_month"){
        
        var countMax =30;
        var currentMonth = parseInt(month_result,10); 
        var day31Array = [1,3,5,7,8,10,12];
        
        for (i = 0; i < day31Array.length ; i++) { 
            if (day31Array[i] == month_select.selectedIndex+1)
                countMax = 31;
        }
        
        document.getElementById('select_day').options.length = 0;
        
        for (i = 1; i <= countMax ; i++) { 
            var option = document.createElement("option");
            option.text = i;
            day_select.add(option);  
        }
    }
    
//    dateString = year_result.concat(".", month_result,".", day_result);
    dateString = year_result.concat("年", month_result,"月", day_result ,"日");
    updateIOSInfo('updateText');
    
}

function selectDidChangeByIOS(dateType,dateValue){
    
    var x;
    var counMax = 99;

    if( dateType == "year" ){
        x = document.getElementById("select_year");
    }else if(dateType == "month"){
        x = document.getElementById("select_month");
    }else{
        x = document.getElementById("select_day");
    }
    
    var preDateValue = x.options[x.selectedIndex].value;
    x.value = dateValue;
    
    if(x.selectedIndex == -1){
        
        x.value = preDateValue;
    }else{
        
        //year
        var year_select  = document.getElementById("select_year");
        var year_result = year_select.options[year_select.selectedIndex].text;
        
        //month
        var month_select = document.getElementById("select_month");
        var month_result = month_select.options[month_select.selectedIndex].text;
        
        //day
        var day_select   = document.getElementById("select_day");
        var day_result = day_select.options[day_select.selectedIndex].text;
        
        dateString = year_result.concat(".", month_result,".", day_result);
//        dateString = year_result.concat("年", month_result,"月", day_result ,"日");
    }
    
}

function updateIOSInfo(funName) {
    
    //注意, 資料有中文時, 請先進行unicode編碼, 否則webview 讀取url時會有亂碼問題
    var callInfo = {};
    callInfo.funcName = funName;
    callInfo.arg = encodeURIComponent(dateString);
    
    var url = "js2ios://";
    url += JSON.stringify(callInfo)

    var iFrame = createIFrame(url);
    //remove the frame now
    iFrame.parentNode.removeChild(iFrame);
    
}

function createIFrame(src)
{
    var rootElm = document.documentElement;
    var newFrameElm = document.createElement("IFRAME");
    newFrameElm.setAttribute("src",src);
    rootElm.appendChild(newFrameElm);
    return newFrameElm;
}



