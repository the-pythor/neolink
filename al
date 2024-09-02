//@version=5
indicator('ICT Sessions_One Setup for Life [MK]', overlay=true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

//INPUTS
tZone = input.string("America/New_York", "Timezone", options=["America/New_York", "GMT+0", "GMT+1", "GMT+2", "GMT+3","GMT+4","GMT+5","GMT+6","GMT+7","GMT+8","GMT+9","GMT+10","GMT+11","GMT+12","GMT-1", "GMT-2", "GMT-3","GMT-4","GMT-5","GMT-6","GMT-7","GMT-8","GMT-9","GMT-10","GMT-11","GMT-12"], confirm=true)

i_maxtf_RTHsess             = input.int         (15, "Max Timeframe", 1, 240, inline="x1", confirm=true)
disp_RTHsess                = timeframe.isintraday and timeframe.multiplier <= i_maxtf_RTHsess

defaultEuropeColor = color.new(#F0FFFF, 100)
defaultUSAColor = color.new(#FFE4E1, 100)
defaultAsiaColor = color.new(#FFFFED, 100)

AsiaBorderColor = input(title='Border', defval=color.new(color.orange,100), group="Colors", inline="0")
AsiaBackgroundColor = input(title='Box', defval=color.new(color.orange,80), group="Colors", inline="0")
AsiaHLColor = input(title='Line', defval=color.new(color.orange,0), group="Colors", inline="0")
asia = input(title='Asia Session', defval=true, group="Colors", inline="0")

EuropeBorderColor = input(title='Border', defval=color.new(color.red,100), group="Colors", inline="1")
EuropeBackgroundColor = input(title='Box', defval=color.new(color.red,80), group="Colors", inline="1")
EuropeHLColor = input(title='Line', defval=color.new(color.red,0), group="Colors", inline="1")
europe = input(title='London Session', defval=true, group="Colors", inline="1")

USABorderColor = input(title='Border', defval=color.new(color.green,100), group="Colors", inline="2")
USABackgroundColor = input(title='Box', defval=color.new(color.green,80), group="Colors", inline="2")
USAHLColor = input(title='Line', defval=color.new(color.green,0), group="Colors", inline="2")
usa = input(title='New York AM Session', defval=true, group="Colors", inline="2")

nylBorderColor = input(title='Border', defval=color.new(color.gray,100), group="Colors", inline="2b")
nylBackgroundColor = input(title='Box', defval=color.new(color.gray,80), group="Colors", inline="2b")
nylHLColor = input(title='Line', defval=color.new(color.gray,0), group="Colors", inline="2b")
nyl = input(title='New York Lunch Session', defval=true, group="Colors", inline="2b")

USA2BorderColor = input(title='Border', defval=color.new(color.blue,100), group="Colors", inline="3")
USA2BackgroundColor = input(title='Box', defval=color.new(color.blue,80), group="Colors", inline="3")
USA2HLColor = input(title='Line', defval=color.new(color.blue,0), group="Colors", inline="3")
usa2 = input(title='New York PM Session', defval=true, group="Colors", inline="3")

lineWidth = input(title='Border width', defval=1, group="Colors", inline="3b")
lines = input.bool(defval = true, title="Session High/Low Lines", group="Colors", inline="3c")
mids = input.bool(defval = false, title="Session 50% Line", group="Colors", inline="3c")

// t1H = input.int(16, title = 'Hour', inline="1", group="Extend Boxes")
// t1m = input.int(01, title = 'Minute', inline="1", group="Extend Boxes")
// ext_2last = input.bool(defval=false, title="Extend to Future Time", inline="1", group="Extend Boxes")
// t1 = timestamp(tZone, year, month, dayofmonth, t1H, t1m, 00)

RTH_txt = input(title='Text', defval=color.new(color.silver,0), group="Colors", inline="4")
RTH_txt_on = input(title='Text', defval=true, group="Colors", inline="4")

///Sessions
Asia = input.session(title='Asia Session', defval='2000-0000')
Europe = input.session(title='London Session', defval='0200-0500')
USA = input.session(title='New York AM Session', defval='0930-1200')
NYL = input.session(title='New York Lunch Session', defval='1200-1330')
USA2 = input.session(title='New York PM Session', defval='1330-1600')

//variables
var line asiaH_ln = na
var line asiamid_ln = na
var line asiaL_ln = na
var line europeH_ln = na
var line europemid_ln = na
var line europeL_ln = na
var line usaH_ln = na
var line usamid_ln = na
var line usaL_ln = na
var line nylH_ln = na
var line nylmid_ln = na
var line nylL_ln = na
var line usa2H_ln = na
var line usa2mid_ln = na
var line usa2L_ln = na

var box asia_box = na
var box europe_box = na
var box usa_box = na
var box nyl_box = na
var box usa2_box = na

var label asia_lbl = na
var label europe_lbl = na
var label usa_lbl = na
var label nyl_lbl = na
var label usa2_lbl = na

//Bars
is_newbar(sess) =>
    t = time('D', sess, tZone)
    na(t[1]) and not na(t) or t[1] < t

is_session(sess) =>
    not na(time('D', sess, tZone))

//get line styles
line_style_function(input_var) =>
    switch input_var
        "dotted (┈)" => line.style_dotted
        "dashed (╌)" => line.style_dashed
        => line.style_solid
    
//high line right 
_highmit(_line) =>
    result = false
    _line.set_x2(time)
    if high > _line.get_y1() 
        result := true
    result
    
//low line right 
_lowmit(_line) =>
    result = false
    _line.set_x2(time)
    if low < _line.get_y1() 
        result := true
    result

//use todays date as start point for study lookback range
YearCTD = year(timenow)
monthCTD = month(timenow)
dateCTD = dayofmonth(timenow)
hour3 = hour(timenow)
min3 = hour(timenow)
starttime = timestamp(tZone, YearCTD, monthCTD, dateCTD, 23, 59)
event_days  = input.int(defval = 10, title="Previous Days to Show", tooltip="You must include weekend days if for example, you are looking back from Monday to Friday", group="Lookback", inline="1")
bgrnd_prev_clr = input.color(defval=color.new(color.silver,90), title="Background", group="Lookback", inline="2")
showdaysbg  = input.bool(defval=true, title="Show Days Background", group="Lookback", inline="2")

//calc how many days back to use for study period
pre_ts = starttime - 86400000 * event_days
pre_range = time >= pre_ts and time < starttime

// background color for study period
bgcolor(pre_range and showdaysbg and disp_RTHsess? bgrnd_prev_clr : na)

//today only
isToday = false

if year(timenow) == year(time) and month(timenow) == month(time) and dayofmonth(timenow) == dayofmonth(time) 
    isToday := true

//Asia Session
asiaNewbar = is_newbar(Asia)
asiaSession = is_session(Asia)

if asia and asiaSession and pre_range and disp_RTHsess

    float asiaLow = na
    asiaLow := if asiaSession
        if asiaNewbar
            low
        else
            math.min(asiaLow[1], low)
    else
        asiaLow[1]

    float asiaHigh = na
    asiaHigh := if asiaSession
        if asiaNewbar
            high
        else
            math.max(asiaHigh[1], high)
    else
        asiaHigh[1]

    int asiaStart = na
    asiaStart := if asiaSession
        if asiaNewbar
            time
        else
            math.min(asiaStart[1], time)
    else
        na
    int asiaEnd = na
    asiaEnd := if asiaSession
        if asiaNewbar
            time_close
        else
            math.max(asiaEnd[1], time_close)
    else
        na
    asiaMid = (asiaStart+asiaEnd)/2
    asia50 = (asiaHigh+asiaLow)/2
    if asiaNewbar   
        asiaH_ln := line.new(asiaStart, asiaHigh, asiaEnd, asiaHigh, color=AsiaHLColor, xloc = xloc.bar_time)
        asiaL_ln := line.new(asiaStart, asiaLow, asiaEnd, asiaLow, color=AsiaHLColor, xloc = xloc.bar_time)
        asiamid_ln := line.new(asiaStart, asia50, asiaEnd, asia50, color=AsiaHLColor, xloc = xloc.bar_time)
        asia_box := box.new(left=asiaStart, bottom=asiaLow, right=asiaEnd, top=asiaHigh, border_width=lineWidth, xloc=xloc.bar_time, border_style=line.style_solid, border_color=AsiaBorderColor, bgcolor=AsiaBackgroundColor, text="", text_valign = text.align_center)
        asia_lbl := label.new(asiaMid, asiaHigh, text=RTH_txt_on ? "Asia" : na, textcolor=RTH_txt, xloc = xloc.bar_time, color=color.new(color.black,100), style=label.style_label_down)

    else if asiaSession
        line.set_y2(asiaH_ln[1], asiaHigh)
        line.set_y1(asiaH_ln[1], asiaHigh)
        line.set_x2(asiaH_ln[1], asiaEnd)
        line.set_x2(asiaL_ln[1], asiaEnd)
        line.set_y2(asiaL_ln[1], asiaLow)
        line.set_y1(asiaL_ln[1], asiaLow)
        box.set_right(asia_box[1], asiaEnd)
        box.set_top(asia_box[1], asiaHigh)
        box.set_bottom(asia_box[1], asiaLow)
        label.set_x(asia_lbl[1], asiaMid)
        label.set_y(asia_lbl[1], asiaHigh)
        if mids
            line.set_x2(asiamid_ln[1], asiaEnd)
            line.set_y2(asiamid_ln[1], asia50)
            line.set_y1(asiamid_ln[1], asia50)
        //line.set_x2(asiaH_ln[1], last_bar_time)
    
else if not asiaSession
    if _highmit(asiaH_ln)
        asiaH_ln := na
    if _lowmit(asiaL_ln)
        asiaL_ln := na
    
    if not lines
        line.set_color(asiaH_ln, color.new(color.black,100))
        line.set_color(asiaL_ln, color.new(color.black,100))

//London Session
europeNewbar = is_newbar(Europe)
europeSession = is_session(Europe)

if europe and europeSession and pre_range and disp_RTHsess
    
    float europeLow = na
    europeLow := if europeSession
        if europeNewbar
            low
        else
            math.min(europeLow[1], low)
    else
        europeLow[1]

    float europeHigh = na
    europeHigh := if europeSession
        if europeNewbar
            high
        else
            math.max(europeHigh[1], high)
    else
        europeHigh[1]

    int europeStart = na
    europeStart := if europeSession
        if europeNewbar
            time
        else
            math.min(europeStart[1], time)
    else
        na
    int europeEnd = na
    europeEnd := if europeSession
        if europeNewbar
            time_close
        else
            math.max(europeEnd[1], time_close)
    else
        na
    europeMid = (europeStart+europeEnd)/2
    europe50 = (europeHigh+europeLow)/2
    if europeNewbar   
        europeH_ln := line.new(europeStart, europeHigh, europeEnd, europeHigh, color=EuropeHLColor, xloc = xloc.bar_time)
        europeL_ln := line.new(europeStart, europeLow, europeEnd, europeLow, color=EuropeHLColor, xloc = xloc.bar_time)
        europemid_ln := line.new(europeStart, europe50, europeEnd, europe50, color=EuropeHLColor, xloc = xloc.bar_time)
        europe_box := box.new(left=europeStart, bottom=europeLow, right=europeEnd, top=europeHigh, border_width=lineWidth, xloc=xloc.bar_time, border_style=line.style_solid, border_color=EuropeBorderColor, bgcolor=EuropeBackgroundColor, text="", text_valign = text.align_center)
        europe_lbl := label.new(europeMid, europeHigh, text=RTH_txt_on ? "London" : na, textcolor=RTH_txt, xloc = xloc.bar_time, color=color.new(color.black,100), style=label.style_label_down)

    else if europeSession
        line.set_y2(europeH_ln[1], europeHigh)
        line.set_y1(europeH_ln[1], europeHigh)
        line.set_x2(europeH_ln[1], europeEnd)
        line.set_x2(europeL_ln[1], europeEnd)
        line.set_y2(europeL_ln[1], europeLow)
        line.set_y1(europeL_ln[1], europeLow)
        box.set_right(europe_box[1], europeEnd)
        box.set_top(europe_box[1], europeHigh)
        box.set_bottom(europe_box[1], europeLow)
        label.set_x(europe_lbl[1], europeMid)
        label.set_y(europe_lbl[1], europeHigh)
        if mids
            line.set_x2(europemid_ln[1], europeEnd)
            line.set_y2(europemid_ln[1], europe50)
            line.set_y1(europemid_ln[1], europe50)
    
else if not europeSession
    if _highmit(europeH_ln)
        europeH_ln := na
    if _lowmit(europeL_ln)
        europeL_ln := na
    
    if not lines
        line.set_color(europeH_ln, color.new(color.black,100))
        line.set_color(europeL_ln, color.new(color.black,100))   

//New York AM Session
usaNewbar = is_newbar(USA)
usaSession = is_session(USA)

if usa and usaSession and pre_range and disp_RTHsess
    float usaLow = na
    usaLow := if usaSession
        if usaNewbar
            low
        else
            math.min(usaLow[1], low)
    else
        usaLow[1]

    float usaHigh = na
    usaHigh := if usaSession
        if usaNewbar
            high
        else
            math.max(usaHigh[1], high)
    else
        usaHigh[1]

    int usaStart = na
    usaStart := if usaSession
        if usaNewbar
            time
        else
            math.min(usaStart[1], time)
    else
        na

    int usaEnd = na
    usaEnd := if usaSession
        if usaNewbar
            time_close
        else
            math.max(usaEnd[1], time_close)
    else
        na
    usaMid = (usaStart + usaEnd)/2
    usa50 = (usaHigh+usaLow)/2

    if usaNewbar   
        usaH_ln := line.new(usaStart, usaHigh, usaEnd, usaHigh, color=USAHLColor, xloc = xloc.bar_time)
        usaL_ln := line.new(usaStart, usaLow, usaEnd, usaLow, color=USAHLColor, xloc = xloc.bar_time)
        usamid_ln := line.new(usaStart, usa50, usaEnd, usa50, color=USAHLColor, xloc = xloc.bar_time)
        usa_box := box.new(left=usaStart, bottom=usaLow, right=usaEnd, top=usaHigh, border_width=lineWidth, xloc=xloc.bar_time, border_style=line.style_solid, border_color=USABorderColor, bgcolor=USABackgroundColor, text="", text_valign = text.align_center)
        usa_lbl := label.new(usaMid, usaHigh, text=RTH_txt_on ? "NY AM" : na, textcolor=RTH_txt, xloc = xloc.bar_time, color=color.new(color.black,100), style=label.style_label_down)

    else if usaSession
        line.set_y2(usaH_ln[1], usaHigh)
        line.set_y1(usaH_ln[1], usaHigh)
        line.set_x2(usaH_ln[1], usaEnd)
        line.set_x2(usaL_ln[1], usaEnd)
        line.set_y2(usaL_ln[1], usaLow)
        line.set_y1(usaL_ln[1], usaLow)
        box.set_right(usa_box[1], usaEnd)
        box.set_top(usa_box[1], usaHigh)
        box.set_bottom(usa_box[1], usaLow)
        label.set_x(usa_lbl[1], usaMid)
        label.set_y(usa_lbl[1], usaHigh)
        if mids
            line.set_x2(usamid_ln[1], usaEnd)
            line.set_y2(usamid_ln[1], usa50)
            line.set_y1(usamid_ln[1], usa50)
        //line.set_x2(usaH_ln[1], last_bar_time)
    
else if not usaSession
    if _highmit(usaH_ln)
        usaH_ln := na
    if _lowmit(usaL_ln)
        usaL_ln := na
    
    if not lines
        line.set_color(usaH_ln, color.new(color.black,100))
        line.set_color(usaL_ln, color.new(color.black,100))


// New York Lunch Session
nylNewbar = is_newbar(NYL)
nylSession = is_session(NYL)

if nyl and nylSession and pre_range and disp_RTHsess
    float nylLow = na
    nylLow := if nylSession
        if nylNewbar
            low
        else
            math.min(nylLow[1], low)
    else
        nylLow[1]

    float nylHigh = na
    nylHigh := if nylSession
        if nylNewbar
            high
        else
            math.max(nylHigh[1], high)
    else
        nylHigh[1]

    int nylStart = na
    nylStart := if nylSession
        if nylNewbar
            time
        else
            math.min(nylStart[1], time)
    else
        na

    int nylEnd = na
    nylEnd := if nylSession
        if nylNewbar
            time_close
        else
            math.max(nylEnd[1], time_close)
    else
        na
    nylMid = (nylStart + nylEnd)/2
    nyl50 = (nylHigh+nylLow)/2

    if nylNewbar   
        nylH_ln := line.new(nylStart, nylHigh, nylEnd, nylHigh, color=nylHLColor, xloc = xloc.bar_time)
        nylL_ln := line.new(nylStart, nylLow, nylEnd, nylLow, color=nylHLColor, xloc = xloc.bar_time)
        nyl_box := box.new(left=nylStart, bottom=nylLow, right=nylEnd, top=nylHigh, border_width=lineWidth, xloc=xloc.bar_time, border_style=line.style_solid, border_color=nylBorderColor, bgcolor=nylBackgroundColor, text="", text_valign = text.align_center)
        nyl_lbl := label.new(nylMid, nylHigh, text=RTH_txt_on ? "NY \nLunch" : na, textcolor=RTH_txt, xloc = xloc.bar_time, color=color.new(color.black,100), style=label.style_label_down)

    else if nylSession
        line.set_y2(nylH_ln[1], nylHigh)
        line.set_y1(nylH_ln[1], nylHigh)
        line.set_x2(nylH_ln[1], nylEnd)
        line.set_x2(nylL_ln[1], nylEnd)
        line.set_y2(nylL_ln[1], nylLow)
        line.set_y1(nylL_ln[1], nylLow)
        box.set_right(nyl_box[1], nylEnd)
        box.set_top(nyl_box[1], nylHigh)
        box.set_bottom(nyl_box[1], nylLow)
        label.set_x(nyl_lbl[1], nylMid)
        label.set_y(nyl_lbl[1], nylHigh)
        if mids
            line.set_x2(nylmid_ln[1], nylEnd)
            line.set_y2(nylmid_ln[1], nyl50)
            line.set_y1(nylmid_ln[1], nyl50)
        //line.set_x2(nylH_ln[1], last_bar_time)
    
else if not nylSession
    if _highmit(nylH_ln)
        nylH_ln := na
    if _lowmit(nylL_ln)
        nylL_ln := na
    
    if not lines
        line.set_color(nylH_ln, color.new(color.black,100))
        line.set_color(nylL_ln, color.new(color.black,100))

//NY PM Session
usa2Newbar = is_newbar(USA2)
usa2Session = is_session(USA2)
if usa2 and usa2Session and pre_range and disp_RTHsess

    float usa2Low = na
    usa2Low := if usa2Session
        if usa2Newbar
            low
        else
            math.min(usa2Low[1], low)
    else
        usa2Low[1]

    float usa2High = na
    usa2High := if usa2Session
        if usa2Newbar
            high
        else
            math.max(usa2High[1], high)
    else
        usa2High[1]

    int usa2Start = na
    usa2Start := if usa2Session
        if usa2Newbar
            time
        else
            math.min(usa2Start[1], time)
    else
        na

    int usa2End = na
    usa2End := if usa2Session
        if usa2Newbar
            time_close
        else
            math.max(usa2End[1], time_close)
    else
        na

    usa2Mid = (usa2Start + usa2End)/2
    usa250 = (usa2High+usa2Low)/2

    if usa2Newbar   
        usa2H_ln := line.new(usa2Start, usa2High, usa2End, usa2High, color=USA2HLColor, xloc = xloc.bar_time)
        usa2L_ln := line.new(usa2Start, usa2Low, usa2End, usa2Low, color=USA2HLColor, xloc = xloc.bar_time)
        usa2mid_ln := line.new(usa2Start, usa250, usa2End, usa250, color=USA2HLColor, xloc = xloc.bar_time)
        usa2_box := box.new(left=usa2Start, bottom=usa2Low, right=usa2End, top=usa2High, border_width=lineWidth, xloc=xloc.bar_time, border_style=line.style_solid, border_color=USA2BorderColor, bgcolor=USA2BackgroundColor, text="", text_valign = text.align_center)
        usa2_lbl := label.new(usa2Mid, usa2High, text=RTH_txt_on ? "NY PM" : na, textcolor=RTH_txt, xloc = xloc.bar_time, color=color.new(color.black,100), style=label.style_label_down)

    else if usa2Session
        line.set_y2(usa2H_ln[1], usa2High)
        line.set_y1(usa2H_ln[1], usa2High)
        line.set_x2(usa2H_ln[1], usa2End)
        line.set_x2(usa2L_ln[1], usa2End)
        line.set_y2(usa2L_ln[1], usa2Low)
        line.set_y1(usa2L_ln[1], usa2Low)
        box.set_right(usa2_box[1], usa2End)
        box.set_top(usa2_box[1], usa2High)
        box.set_bottom(usa2_box[1], usa2Low)
        label.set_x(usa2_lbl[1], usa2Mid)
        label.set_y(usa2_lbl[1], usa2High)
        if mids
            line.set_x2(usa2mid_ln[1], usa2End)
            line.set_y2(usa2mid_ln[1], usa250)
            line.set_y1(usa2mid_ln[1], usa250)
        //line.set_x2(usa2H_ln[1], last_bar_time)
    
else if not usa2Session
    if _highmit(usa2H_ln)
        usa2H_ln := na
    if _lowmit(usa2L_ln)
        usa2L_ln := na
    
    if not lines
        line.set_color(usa2H_ln, color.new(color.black,100))
        line.set_color(usa2L_ln, color.new(color.black,100))


/////RTH Gaps
///////////////////////////////////////////////////////////RTH Gaps II
longDay = 24*1000*3600
isSPY = str.tostring(syminfo.ticker) =="SPY"? true:false
_16_15= timestamp(tZone, year, month, dayofmonth, 16, 15, 00)
_9_30 = timestamp(tZone, year, month, dayofmonth, 9, 30, 00)
colorNone = color.new(color.white, 100)
showBox = input.bool(true, "RTH Opening Gap ", inline ='0', group = 'RTH Gaps II---------------------------------------------', tooltip = "Shows the standard RTH gap from the close at 4pm to 9:30am open (New York Time)")
boxColor = input.color(color.new(color.purple, 75), "Standard Gap Box", inline ='-1', group = 'RTH Gaps II------------
