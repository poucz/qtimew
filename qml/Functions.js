.pragma library

function formatDuration2(sec) {
    var h = Math.floor(sec / 3600)
    var m = Math.floor((sec % 3600) / 60)
    var s = sec % 60

    if (h > 0)
        return h + ":" +
               (m < 10 ? "0" + m : m) + ":" +
               (s < 10 ? "0" + s : s)
    else
        return m + ":" +
               (s < 10 ? "0" + s : s)
}


function formatDuration(sec) {
    var h = Math.floor(sec / 3600)
    var m = Math.floor((sec % 3600) / 60)

    return (h < 10 ? "0" + h : h) + ":" +
           (m < 10 ? "0" + m : m)
}
